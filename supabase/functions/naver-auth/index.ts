import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface NaverProfile {
  id: string;
  email?: string;
  nickname?: string;
  profile_image?: string;
  name?: string;
}

interface NaverApiResponse {
  resultcode: string;
  message: string;
  response: NaverProfile;
}

serve(async (req) => {
  // CORS Preflight 처리
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { access_token, agreed_to_terms, agreed_to_privacy } =
      await req.json();

    if (!access_token) {
      throw new Error("access_token is required");
    }

    // ============================================
    // STEP 1: Naver API로 토큰 검증 (보안 필수!)
    // ============================================
    const naverResponse = await fetch("https://openapi.naver.com/v1/nid/me", {
      headers: { Authorization: `Bearer ${access_token}` },
    });

    if (!naverResponse.ok) {
      throw new Error("Invalid Naver access token");
    }

    const naverData: NaverApiResponse = await naverResponse.json();

    // Naver API 응답 형식: { resultcode: "00", message: "success", response: {...} }
    if (naverData.resultcode !== "00") {
      throw new Error(`Naver API error: ${naverData.message}`);
    }

    const naverProfile = naverData.response;
    const naverId: string = naverProfile.id;
    const naverEmail: string | undefined = naverProfile.email;

    // 이메일 미제공 시 가상 이메일 생성 (네이버는 이메일 제공 거부 가능)
    const userEmail =
      naverEmail || `naver_${naverId}@naver.placeholder.local`;

    // ============================================
    // STEP 2: Supabase 클라이언트 생성
    // ============================================
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

    // Admin Client (사용자 생성, Magic Link 생성용)
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // Public Client (verifyOtp용 - Admin API에는 verifyOtp가 없음)
    const supabasePublic = createClient(supabaseUrl, anonKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // ============================================
    // STEP 3: 사용자 Get or Create
    // ============================================
    let isNewUser = false;

    // createUser 먼저 시도 (이미 존재하면 에러 발생)
    const { data: newUserData, error: createError } =
      await supabaseAdmin.auth.admin.createUser({
        email: userEmail,
        email_confirm: true, // 필수: 이메일 인증 자동 완료
        user_metadata: {
          provider: "naver",
          naver_id: naverId,
          naver_nickname: naverProfile.nickname || null,
          naver_profile_image: naverProfile.profile_image || null,
          naver_email: naverEmail || null, // 실제 이메일 별도 저장
          name: naverProfile.nickname || naverProfile.name || "User",
        },
      });

    if (createError) {
      // 이미 존재하는 사용자인 경우
      if (
        createError.message.includes("already") ||
        createError.message.includes("exists")
      ) {
        console.log("User already exists, proceeding to generate session");
        isNewUser = false;
      } else {
        throw createError;
      }
    } else {
      console.log("New user created:", newUserData.user?.id);
      isNewUser = true;
    }

    // ============================================
    // STEP 4: Magic Link 생성 (Admin API)
    // ============================================
    const { data: linkData, error: linkError } =
      await supabaseAdmin.auth.admin.generateLink({
        type: "magiclink",
        email: userEmail,
      });

    if (linkError) {
      throw new Error(`Failed to generate magic link: ${linkError.message}`);
    }

    if (!linkData?.properties?.hashed_token) {
      throw new Error("Magic link generated but hashed_token is missing");
    }

    // ============================================
    // STEP 5: OTP 검증으로 세션 획득 (Public Client 사용)
    // 중요: verifyOtp는 Admin API가 아닌 일반 Auth API
    // ============================================
    const { data: otpData, error: otpError } =
      await supabasePublic.auth.verifyOtp({
        token_hash: linkData.properties.hashed_token,
        type: "magiclink",
      });

    if (otpError) {
      throw new Error(`Failed to verify OTP: ${otpError.message}`);
    }

    if (!otpData.session) {
      throw new Error("Session not created after OTP verification");
    }

    const userId = otpData.user?.id;
    if (!userId) {
      throw new Error("User ID not found after OTP verification");
    }

    // ============================================
    // STEP 6: public.users 테이블 UPSERT
    // Database Trigger가 auth.users INSERT 시 자동 생성할 수 있으나,
    // Race Condition 방지를 위해 UPSERT 사용
    // ============================================
    await supabaseAdmin.from("users").upsert(
      {
        id: userId,
        oauth_provider: "naver",
        oauth_user_id: naverId,
        name: naverProfile.nickname || naverProfile.name || "User",
        email: naverEmail || "",
        profile_image_url: naverProfile.profile_image || null,
        last_login_at: new Date().toISOString(),
      },
      { onConflict: "id" }
    );

    // ============================================
    // STEP 7: 동의 기록 저장 (신규 사용자인 경우)
    // ============================================
    if (isNewUser && agreed_to_terms !== undefined) {
      await supabaseAdmin.from("consent_records").insert({
        user_id: userId,
        terms_of_service: agreed_to_terms ?? true,
        privacy_policy: agreed_to_privacy ?? true,
      });
    }

    // ============================================
    // STEP 8: 세션 정보 반환
    // ============================================
    return new Response(
      JSON.stringify({
        success: true,
        refresh_token: otpData.session.refresh_token,
        access_token: otpData.session.access_token,
        is_new_user: isNewUser,
        user: {
          id: otpData.user?.id,
          email: otpData.user?.email,
          user_metadata: otpData.user?.user_metadata,
        },
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Naver auth error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : String(error),
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});

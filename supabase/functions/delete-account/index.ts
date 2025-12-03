import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/**
 * Delete Account Edge Function
 *
 * 사용자 계정을 완전히 삭제합니다.
 *
 * 삭제 순서 (FK CASCADE 고려):
 * 1. auth.users 삭제 (supabase.auth.admin.deleteUser)
 *    - 이로 인해 public.users ON DELETE CASCADE 트리거
 *    - public.users 삭제 시 모든 관련 테이블 자동 CASCADE 삭제
 *
 * 보안:
 * - Authorization 헤더에서 현재 사용자 JWT 검증
 * - 자신의 계정만 삭제 가능 (타인 계정 삭제 불가)
 * - service_role 키로 auth.admin.deleteUser 호출
 */
serve(async (req) => {
  // CORS Preflight 처리
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ============================================
    // STEP 1: 환경 변수 및 클라이언트 초기화
    // ============================================
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Admin Client (사용자 삭제용)
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // ============================================
    // STEP 2: Authorization 헤더에서 사용자 검증
    // ============================================
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new Error("Missing or invalid Authorization header");
    }

    const accessToken = authHeader.replace("Bearer ", "");

    // JWT에서 사용자 정보 추출
    const {
      data: { user },
      error: authError,
    } = await supabaseAdmin.auth.getUser(accessToken);

    if (authError || !user) {
      throw new Error("Invalid or expired token");
    }

    const userId = user.id;
    console.log(`Deleting account for user: ${userId}`);

    // ============================================
    // STEP 3: public.users 삭제 (CASCADE로 관련 데이터 삭제)
    // ============================================
    // public.users와 auth.users 사이에 FK 제약조건이 없으므로
    // public.users를 먼저 삭제해야 CASCADE가 동작함
    //
    // CASCADE 삭제 순서:
    // public.users 삭제 → 모든 관련 테이블 자동 삭제:
    // - audit_logs
    // - user_badges
    // - notification_settings
    // - daily_checkins
    // - dose_records (via dosage_plans)
    // - dose_schedules (via dosage_plans)
    // - dosage_plans
    // - weight_logs
    // - symptom_logs
    // - emergency_symptom_checks
    // - guide_feedback
    // - consent_records
    // - user_profiles

    const { error: publicDeleteError } = await supabaseAdmin
      .from("users")
      .delete()
      .eq("id", userId);

    if (publicDeleteError) {
      console.error("Failed to delete public.users:", publicDeleteError);
      throw new Error(`Failed to delete user data: ${publicDeleteError.message}`);
    }

    console.log(`Deleted public.users and related data for user: ${userId}`);

    // ============================================
    // STEP 4: auth.users 삭제
    // ============================================
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(
      userId,
      false // shouldSoftDelete: false = 완전 삭제
    );

    if (deleteError) {
      throw new Error(`Failed to delete auth user: ${deleteError.message}`);
    }

    console.log(`Successfully deleted auth.users for user: ${userId}`);

    // ============================================
    // STEP 5: 성공 응답
    // ============================================
    return new Response(
      JSON.stringify({
        success: true,
        message: "Account deleted successfully",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Delete account error:", error);
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

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Instruction prompt based on llm-message-spec.md
// Note: google/gemma-3n-e2b-it:free doesn't support system prompts
const INSTRUCTION_PROMPT = `당신은 GLP-1 치료 여정을 함께하는 따뜻한 동반자입니다.

핵심 원칙:
1. 판단하지 않습니다. 어떤 상황도 있는 그대로 인정합니다.
2. 감정을 먼저 알아챕니다. 정보나 조언보다 공감이 먼저입니다.
3. 정상화합니다. "당신만 그런 게 아니에요"라는 메시지를 전합니다.
4. 해결책을 강요하지 않습니다. 제안은 부드럽게, 선택은 사용자에게.

톤:
- 따뜻하지만 과하지 않게
- 친구 같지만 가볍지 않게
- 존댓말, 부드러운 종결어미 (~예요, ~죠)
- 느낌표, 이모지, 과장된 칭찬 금지

메시지 구조:
[상황 인식] + [감정 인정] + [정상화/안심] + (선택: 부드러운 제안)

길이: 2-4문장`;

/**
 * Build user prompt from context data
 */
function buildUserPrompt(
  userContext: any,
  healthData: any,
  recentMessages: string[]
): string {
  let prompt = `사용자 상황:
- 이름: ${userContext.name}
- 여정 ${userContext.journey_day}일째, ${userContext.current_week}주차
- 현재 용량: ${userContext.current_dose_mg}mg
- 마지막 투여: ${userContext.days_since_last_dose}일 전
- 다음 투여: ${userContext.days_until_next_dose}일 후`;

  if (userContext.days_since_escalation != null) {
    prompt += `\n- 증량 후: ${userContext.days_since_escalation}일`;
  }
  if (userContext.next_escalation_in_days != null) {
    prompt += `\n- 다음 증량: ${userContext.next_escalation_in_days}일 후`;
  }

  prompt += `\n\n건강 데이터:
- 이번 주 체중 변화: ${healthData.weight_change_this_week_kg}kg
- 체중 추세: ${healthData.weight_trend}
- 전반적 컨디션: ${healthData.overall_condition}
- 기록률: ${(healthData.completion_rate * 100).toFixed(0)}%`;

  if (healthData.top_concern) {
    prompt += `\n- 주요 관심사: ${healthData.top_concern}`;
  }
  if (healthData.recent_checkin_summary) {
    prompt += `\n- 오늘 체크인: ${healthData.recent_checkin_summary}`;
  }

  if (recentMessages.length > 0) {
    prompt += `\n\n최근 메시지 (톤 참고용):\n${recentMessages.join("\n")}`;
  }

  prompt += "\n\n위 상황에 맞는 공감 메시지를 작성해주세요.";
  return prompt;
}

/**
 * Generate AI Message Edge Function
 *
 * Calls OpenRouter API to generate contextual empathetic messages
 * based on user's GLP-1 journey context.
 *
 * Security:
 * - Verifies user JWT from Authorization header
 * - Uses service_role to save message to database
 * - OPENROUTER_API_KEY is kept secret on server side
 */
serve(async (req) => {
  // CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ============================================
    // STEP 1: Parse request
    // ============================================
    const { user_context, health_data, recent_messages, trigger_type } =
      await req.json();

    // ============================================
    // STEP 2: Verify authentication
    // ============================================
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new Error("Missing or invalid Authorization header");
    }

    const accessToken = authHeader.replace("Bearer ", "");

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    const {
      data: { user },
      error: authError,
    } = await supabaseAdmin.auth.getUser(accessToken);

    if (authError || !user) {
      throw new Error("Unauthorized");
    }

    console.log(`Generating AI message for user: ${user.id}`);

    // ============================================
    // STEP 3: Call OpenRouter API
    // ============================================
    const openrouterApiKey = Deno.env.get("OPENROUTER_API_KEY");
    if (!openrouterApiKey) {
      throw new Error("OPENROUTER_API_KEY not configured");
    }

    // Build combined prompt (instruction + context) for models without system prompt support
    const userPromptContent = `${INSTRUCTION_PROMPT}\n\n${buildUserPrompt(
      user_context,
      health_data,
      recent_messages || []
    )}`;

    const openrouterResponse = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${openrouterApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "google/gemma-3n-e2b-it:free",
          messages: [
            {
              role: "user",
              content: userPromptContent,
            },
          ],
          max_tokens: 200,
        }),
      }
    );

    let generatedMessage: string;

    // ============================================
    // STEP 4: Handle OpenRouter response (with fallback)
    // ============================================
    if (!openrouterResponse.ok) {
      console.error(
        "OpenRouter API error:",
        openrouterResponse.status,
        await openrouterResponse.text()
      );

      // Fallback: Fetch last successful message
      const { data: lastMessage } = await supabaseAdmin
        .from("ai_generated_messages")
        .select("message")
        .eq("user_id", user.id)
        .order("generated_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      generatedMessage = lastMessage?.message ?? "오늘도 함께해요.";

      return new Response(
        JSON.stringify({
          success: true,
          message: generatedMessage,
          is_fallback: true,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const openrouterData = await openrouterResponse.json();
    generatedMessage =
      openrouterData.choices?.[0]?.message?.content?.trim() ||
      "오늘도 함께해요.";

    console.log(`Generated message: ${generatedMessage}`);

    // ============================================
    // STEP 5: Save message to database
    // ============================================
    await supabaseAdmin.from("ai_generated_messages").insert({
      user_id: user.id,
      message: generatedMessage,
      context_snapshot: { user_context, health_data },
      trigger_type: trigger_type || "daily_first_open",
    });

    // ============================================
    // STEP 6: Return success response
    // ============================================
    return new Response(
      JSON.stringify({
        success: true,
        message: generatedMessage,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Generate AI message error:", error);
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

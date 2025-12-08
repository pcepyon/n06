import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Instruction prompt based on llm-message-spec.md
const INSTRUCTION_PROMPT = `당신은 GLP-1 치료를 함께하는 친구입니다. 처음 만난 사람이 아니라, 이미 여러 번 대화한 사이예요.

## 핵심 역할
- 의학적 조언이 아닌 **감정적 지지와 격려**가 목적입니다
- 사용자가 "이 사람은 내 상황을 알고 있고, 옆에서 응원해주고 있다"고 느끼게 해주세요
- LLM이 생성한 느낌이 아닌, **친구가 건네는 한마디**처럼 자연스럽게

## 대화 연속성 (필수)
- 최근 메시지들을 확인하고, **이전 대화와 연결**되도록 작성하세요
- 매번 새로운 인사로 시작하지 마세요. 이어지는 대화처럼.
- 같은 말 반복 금지. 이전에 했던 격려와 다른 각도로 접근하세요

## 상황 인식 방법
- 데이터(숫자, 퍼센트)를 직접 언급하지 마세요
- "14일째" 대신 "벌써 2주가 지났네요"
- "85%" 대신 "꾸준히 기록하고 있어요"
- "0.5kg 감소" 대신 "조금씩 변화가 보여요"

## 톤 (엄격히 준수)
- 친구처럼 편안하게, 하지만 가볍지 않게
- 존댓말 사용하되 형식적이지 않게 (~예요, ~죠)

## 절대 금지
- 이모지 (😊, ✨, 😉 등)
- 느낌표 (!)
- "안녕하세요", "~님" 으로 시작하는 인사
- 과장된 칭찬 ("정말 대단해요", "놀라워요", "최고예요")
- 의학적 정보나 조언 ("적응 기간", "부작용은 정상")
- 질문으로 마무리 ("어떠세요?", "말씀해주세요")
- 데이터 직접 언급 (숫자, 퍼센트, mg)

## 메시지 구조
[상황을 알고 있다는 신호] + [감정적 지지] + [따뜻한 마무리]

## 길이
2-4문장`;

/**
 * Build user prompt from context data
 */
function buildUserPrompt(
  userContext: any,
  healthData: any,
  recentMessages: string[]
): string {
  let prompt = `## 사용자 상황 (참고용, 직접 언급 금지)
- 이름: ${userContext.name}
- 여정: ${userContext.journey_day}일째 (${userContext.current_week}주차)
- 용량: ${userContext.current_dose_mg}mg
- 투여 주기: 마지막 ${userContext.days_since_last_dose}일 전, 다음 ${userContext.days_until_next_dose}일 후`;

  if (userContext.days_since_escalation != null) {
    prompt += `\n- 증량: ${userContext.days_since_escalation}일 전`;
  }
  if (userContext.next_escalation_in_days != null) {
    prompt += `\n- 다음 증량: ${userContext.next_escalation_in_days}일 후`;
  }

  prompt += `\n\n## 건강 상태 (참고용, 직접 언급 금지)
- 체중 변화: ${healthData.weight_change_this_week_kg}kg (${healthData.weight_trend})
- 컨디션: ${healthData.overall_condition}
- 기록률: ${(healthData.completion_rate * 100).toFixed(0)}%`;

  if (healthData.top_concern) {
    prompt += `\n- 주요 이슈: ${healthData.top_concern}`;
  }
  if (healthData.recent_checkin_summary) {
    prompt += `\n- 오늘 체크인: ${healthData.recent_checkin_summary}`;
  }

  if (recentMessages.length > 0) {
    prompt += `\n\n## 이전 대화 (연속성 유지 필수, 반복 금지)
${recentMessages.join("\n")}`;
  }

  prompt += `\n\n---
위 상황을 바탕으로, 이전 대화와 자연스럽게 이어지는 따뜻한 한마디를 작성해주세요.
이모지, 느낌표, 인사말, 숫자 언급 없이.`;

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

    // Build prompts - gpt-4o-mini supports system prompts
    const userPromptContent = buildUserPrompt(
      user_context,
      health_data,
      recent_messages || []
    );

    const openrouterResponse = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${openrouterApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "openai/gpt-4o-mini",
          messages: [
            {
              role: "system",
              content: INSTRUCTION_PROMPT,
            },
            {
              role: "user",
              content: userPromptContent,
            },
          ],
          max_tokens: 300,
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

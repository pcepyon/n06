import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Instruction prompt based on llm-message-spec.md
const INSTRUCTION_PROMPT = `당신은 GLP-1 치료를 함께하는 친구입니다. 이미 여러 번 대화한 사이예요.

## 핵심: 구체적인 상황에 반응하기
일반적인 격려("잘하고 있어요", "힘내세요")가 아니라, **지금 이 사람의 구체적인 상황**에 반응해야 합니다.

### 반드시 확인하고 반응할 것:
1. **오늘 체크인 내용** (가장 중요)
   - "속 편안함: 불편" → 속이 안 좋다는 거니까 그걸 알아채줘야 해요
   - "에너지: 피곤" → 피곤하다는 거니까 쉬라고 해줘야 해요
   - "기분: 우울" → 힘든 감정을 인정해줘야 해요

2. **투여 일정**
   - 내일 투여 → "내일 주사 맞는 날이네요"
   - 오늘 투여 → "오늘 투여하셨군요"
   - 증량 직후(1-3일) → 힘든 시기임을 알아채줘야 해요

3. **이전 대화와 연결**
   - 지난번에 한 말을 기억하고 연결해야 해요
   - 같은 말 반복하면 안 돼요

## 메시지 구조
[상황 인식] + [공감/조언] + [격려로 마무리]

## 좋은 예시
- 체크인에서 "속 편안함: 불편" → "오늘 속이 좀 안 좋다고 했는데, 무리하지 말고 천천히 해요. 잘 이겨내고 있어요."
- 체크인에서 "에너지: 피곤" → "요즘 좀 피곤하죠. 몸이 열심히 일하고 있는 거예요. 충분히 잘하고 있어요."
- 내일 투여 예정 → "내일 투여 날이네요. 긴장되기도 하죠. 여기까지 온 것만으로도 대단한 거예요."
- 증량 후 3일 → "증량하고 며칠 됐는데, 이때가 제일 힘들긴 해요. 그래도 잘 버티고 있어요."
- 체중 변화 있음 → "요즘 몸이 조금씩 달라지고 있는 거 느껴지죠. 꾸준히 해온 덕분이에요."

## 나쁜 예시 (이렇게 하면 안 됨)
- "긍정적인 변화가 계속되고 있어서 기쁩니다" → 너무 일반적, 구체적인 상황 반영 없음
- "작은 성취들이 쌓여서 큰 힘이 될 거예요" → 뻔한 격려, 상황과 무관
- "지금처럼 꾸준히 해나가면 좋은 결과가 있을 거예요" → 일반적인 말, 누구에게나 할 수 있는 말

## 톤
- 친구처럼 편안하게, 존댓말(~예요, ~죠)
- 느낌표, 이모지 금지
- "안녕하세요", "~님" 인사 금지
- 과장된 칭찬 금지

## 길이
2-3문장`;

/**
 * Detect special situation and return guidance
 */
function detectSpecialSituation(userContext: any, healthData: any): string | null {
  // 우선순위 1: 첫 시작 (journey_day <= 1)
  if (userContext.journey_day <= 1) {
    return `## 🚨 특별 상황: 첫 시작
이 사람은 오늘 막 치료를 시작했어요.
- "잘 버텨왔다", "꾸준히 해왔다" 같은 말 금지 (아직 시작도 안 했으니까)
- "시작한 것 자체가 용기예요"
- "여기까지 오기까지 고민 많았을 텐데"
- "첫 발을 내딛은 거예요"
`;
  }

  // 우선순위 2: 증량 직후 (1-3일) - 가장 힘든 시기
  if (userContext.days_since_escalation != null && userContext.days_since_escalation <= 3) {
    return `## 🚨 특별 상황: 증량 직후 (힘든 시기)
증량한 지 ${userContext.days_since_escalation}일째예요. 이때가 제일 힘들어요.
- "지금이 제일 힘든 시기예요"
- "버티기만 해도 충분해요"
- "며칠만 지나면 나아져요"
`;
  }

  // 우선순위 3: 오랜만에 복귀 (14일 이상 투여 공백)
  if (userContext.days_since_last_dose >= 14) {
    return `## 🚨 특별 상황: 오랜만에 복귀
마지막 투여가 ${userContext.days_since_last_dose}일 전이에요. 한동안 쉬었다가 돌아온 거예요.
- 판단하거나 이유 묻지 않기
- "다시 와줬네요, 그것만으로도 충분해요"
- "쉬어도 괜찮아요, 여기 있는 것만으로도"
`;
  }

  // 우선순위 4: 체중 정체기 (2주 이상 + 변화 없음)
  if (userContext.journey_day >= 14 && healthData.weight_change_this_week_kg === 0) {
    return `## 🚨 특별 상황: 체중 정체기
2주 이상 지났는데 체중 변화가 없어요. 답답할 수 있어요.
- "정체기는 누구나 겪어요"
- "답답하죠, 충분히 그럴 수 있어요"
- 긍정적으로만 해석하지 말고 답답함을 인정해주기
`;
  }

  // 우선순위 5: 장기 사용자 (90일 이상)
  if (userContext.journey_day >= 90) {
    return `## 🚨 특별 상황: 장기 사용자
벌써 ${userContext.journey_day}일째, 3개월 이상 함께했어요.
- "벌써 3개월이나 됐네요"
- "여기까지 온 것 자체가 대단한 거예요"
- 여정의 의미를 되돌아보게
`;
  }

  // 우선순위 6: 기록률 저조 (20% 미만)
  if (healthData.completion_rate < 0.2 && userContext.journey_day > 7) {
    return `## 🚨 특별 상황: 기록을 잘 안 하는 사용자
기록률이 낮아요. 압박하면 안 돼요.
- "기록 안 해도 괜찮아요"
- "여기 와준 것만으로도 충분해요"
- 기록하라고 유도하지 않기
`;
  }

  return null;
}

/**
 * Build user prompt from context data
 */
function buildUserPrompt(
  userContext: any,
  healthData: any,
  recentMessages: string[]
): string {
  let prompt = "";

  // 특수 상황 감지 및 지침 추가
  const specialSituation = detectSpecialSituation(userContext, healthData);
  if (specialSituation) {
    prompt += specialSituation + "\n";
  }

  // 오늘 체크인 (있을 때만)
  if (healthData.recent_checkin_summary) {
    prompt += `## 오늘 체크인 (이것에 반응해야 함)
${healthData.recent_checkin_summary}

`;
  }

  // 투여 일정
  prompt += `## 투여 일정
- 다음 투여: ${userContext.days_until_next_dose === 0 ? "오늘" : userContext.days_until_next_dose === 1 ? "내일" : `${userContext.days_until_next_dose}일 후`}`;

  if (userContext.days_since_escalation != null && userContext.days_since_escalation <= 7) {
    prompt += `\n- 증량한 지 ${userContext.days_since_escalation}일째`;
  }

  // 여정 정보
  prompt += `\n\n## 여정 정보
- ${userContext.current_week}주차 (${userContext.journey_day}일째)
- 체중: ${healthData.weight_change_this_week_kg > 0 ? "증가" : healthData.weight_change_this_week_kg < 0 ? "감소 중" : "유지"}`;

  // 이전 대화
  if (recentMessages.length > 0) {
    prompt += `\n\n## 이전에 했던 말 (반복 금지)
${recentMessages.join("\n")}`;
  }

  prompt += `\n\n---
위 상황 중 가장 눈에 띄는 것에 반응해주세요. 특별 상황이 있으면 그것을 우선으로.`;

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

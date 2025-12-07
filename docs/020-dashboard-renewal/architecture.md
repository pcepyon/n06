# AI 메시지 생성 아키텍처 검증 문서

## 전체 플로우

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│ Supabase Edge Func   │────▶│   OpenRouter    │
│                 │     │ (generate-ai-message)│     │  (gpt-oss-20b)  │
│                 │◀────│                      │◀────│                 │
└─────────────────┘     └──────────────────────┘     └─────────────────┘
        │                         │
        │                         ▼
        │               ┌──────────────────────┐
        │               │     Supabase DB      │
        │               │ (ai_generated_       │
        └──────────────▶│     messages)        │
                        └──────────────────────┘
```

## Step-by-Step 플로우

### 1. Flutter → Edge Function 호출

**기존 패턴 (검증됨):**
```dart
// lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart:757
final response = await _supabase.functions.invoke(
  'delete-account',
  headers: {
    'Authorization': 'Bearer ${session.accessToken}',
  },
);
```

**새 구현:**
```dart
final response = await _supabase.functions.invoke(
  'generate-ai-message',
  headers: {
    'Authorization': 'Bearer ${session.accessToken}',
  },
  body: {
    'user_context': { ... },
    'health_data': { ... },
    'recent_messages': [ ... ],
  },
);

// 응답 처리
if (response.status == 200) {
  final data = response.data;
  final message = data['message'] as String;
}
```

### 2. Edge Function 구조

**기존 패턴 기반 (검증됨):**
```typescript
// supabase/functions/generate-ai-message/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. 요청 파싱
    const { user_context, health_data, recent_messages } = await req.json();

    // 2. 인증 검증
    const authHeader = req.headers.get("Authorization");
    const accessToken = authHeader?.replace("Bearer ", "");

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: { user }, error } = await supabaseAdmin.auth.getUser(accessToken);
    if (error || !user) throw new Error("Unauthorized");

    // 3. OpenRouter API 호출
    const openrouterResponse = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${Deno.env.get("OPENROUTER_API_KEY")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "openai/gpt-oss-20b:free",
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "user", content: buildUserPrompt(user_context, health_data, recent_messages) },
          ],
        }),
      }
    );

    const openrouterData = await openrouterResponse.json();
    const generatedMessage = openrouterData.choices[0].message.content;

    // 4. DB에 메시지 저장
    await supabaseAdmin.from("ai_generated_messages").insert({
      user_id: user.id,
      message: generatedMessage,
      context_snapshot: { user_context, health_data },
      trigger_type: user_context.trigger_type,
    });

    // 5. 응답 반환
    return new Response(
      JSON.stringify({ success: true, message: generatedMessage }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
```

### 3. OpenRouter API 호출

**검증된 API 포맷:**
```
POST https://openrouter.ai/api/v1/chat/completions

Headers:
  Authorization: Bearer <OPENROUTER_API_KEY>
  Content-Type: application/json

Body:
{
  "model": "openai/gpt-oss-20b:free",
  "messages": [
    { "role": "system", "content": "..." },
    { "role": "user", "content": "..." }
  ]
}

Response:
{
  "id": "...",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "생성된 메시지 텍스트"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": { "prompt_tokens": N, "completion_tokens": N }
}
```

**모델 ID 주의:**
- ✅ 정확: `openai/gpt-oss-20b:free` (`:free` suffix 필수)
- ❌ 오류: `openai/gpt-oss-20b` (free tier 사용 불가)

## 환경 변수 설정

### 필요한 Secrets

| 변수명 | 용도 | 설정 방법 |
|--------|------|----------|
| `OPENROUTER_API_KEY` | OpenRouter API 인증 | `supabase secrets set` |
| `SUPABASE_URL` | (기본 제공) | 자동 |
| `SUPABASE_SERVICE_ROLE_KEY` | (기본 제공) | 자동 |

### 설정 명령어

```bash
# 로컬 개발
echo "OPENROUTER_API_KEY=sk-or-..." >> supabase/functions/.env

# 프로덕션
supabase secrets set OPENROUTER_API_KEY=sk-or-...
```

## DB 테이블 스키마

```sql
CREATE TABLE ai_generated_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  context_snapshot JSONB,
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('daily_first_open', 'post_checkin'))
);

-- 인덱스: 최근 메시지 조회 최적화
CREATE INDEX idx_ai_messages_user_date
  ON ai_generated_messages(user_id, generated_at DESC);

-- RLS 정책
ALTER TABLE ai_generated_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own messages"
  ON ai_generated_messages FOR SELECT
  USING (auth.uid() = user_id);
```

## 검증 체크리스트

### Flutter → Edge Function

- [x] `_supabase.functions.invoke()` 패턴 검증됨 (기존 코드에서 사용 중)
- [x] Authorization 헤더 전달 방식 검증됨
- [x] JSON body 전달 방식 검증됨
- [x] 응답 처리 패턴 (`response.status`, `response.data`) 검증됨

### Edge Function 구조

- [x] CORS 헤더 패턴 검증됨 (기존 함수와 동일)
- [x] 인증 검증 패턴 검증됨 (`supabaseAdmin.auth.getUser`)
- [x] 외부 API fetch 가능 (Deno 기본 지원)
- [x] 환경 변수 접근 (`Deno.env.get()`) 검증됨
- [x] DB 저장 패턴 검증됨 (`supabaseAdmin.from().insert()`)

### OpenRouter API

- [x] 엔드포인트: `https://openrouter.ai/api/v1/chat/completions`
- [x] 인증: `Authorization: Bearer <API_KEY>`
- [x] 모델 ID: `openai/gpt-oss-20b:free` (`:free` suffix 필수)
- [x] 요청/응답 JSON 구조 확인됨

## 잠재적 이슈 및 해결책

### 1. Edge Function 타임아웃

**문제**: Supabase Edge Function 기본 타임아웃은 ~60초

**해결**: OpenRouter API 응답은 보통 2-5초 이내. 문제없을 것으로 예상.

### 2. OpenRouter API 오류

**문제**: API 키 오류, 모델 사용 불가, Rate Limit 등

**해결**:
```typescript
if (!openrouterResponse.ok) {
  // Fallback: 마지막 성공 메시지 조회
  const { data: lastMessage } = await supabaseAdmin
    .from("ai_generated_messages")
    .select("message")
    .eq("user_id", user.id)
    .order("generated_at", { ascending: false })
    .limit(1)
    .single();

  return new Response(
    JSON.stringify({
      success: true,
      message: lastMessage?.message ?? DEFAULT_MESSAGE,
      is_fallback: true,
    }),
    { status: 200, headers: corsHeaders }
  );
}
```

### 3. 네트워크 오류

**문제**: Flutter에서 Edge Function 호출 실패

**해결**: Flutter 측에서도 fallback 처리
```dart
try {
  final response = await _supabase.functions.invoke(...);
  // ...
} catch (e) {
  // 로컬 캐시된 마지막 메시지 사용
  return _getLastCachedMessage();
}
```

## 비용 예측

| 항목 | 단가 | DAU 1,000 기준 |
|------|------|---------------|
| gpt-oss-20b (free) | $0 | $0 |
| **일일 예상 비용** | | **$0** |
| **월간 예상 비용** | | **$0** |

*gpt-oss-20b:free 모델은 무료 tier로 비용 발생 없음*

## 결론

현재 설계된 플로우는 기존 프로젝트 패턴과 완벽히 호환되며, OpenRouter API 스펙과도 일치합니다. 구현을 진행해도 됩니다.

**Sources:**
- [OpenRouter API Reference](https://openrouter.ai/docs/api/reference/overview)
- [OpenRouter Quickstart](https://openrouter.ai/docs/quickstart)
- [gpt-oss-20b (free) on OpenRouter](https://openrouter.ai/openai/gpt-oss-20b:free)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Supabase Functions Invoke (Dart)](https://supabase.com/docs/reference/dart/functions-invoke)
- [Supabase Edge Function Secrets](https://supabase.com/docs/guides/functions/secrets)

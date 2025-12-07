# 대시보드 Emotion-Driven 개선 구현 스펙

## 개요

대시보드를 "정보 나열"에서 "맥락 인식 감정 지지"로 전환하여, 사용자가 매일 앱을 열 때 진정으로 이해받고 지지받는 느낌을 받도록 한다.

## 배경

- 현재 문제: 대시보드가 숫자와 위젯을 나열하는 "기능 자랑" 형태. 사용자의 감정 상태나 여정 맥락을 고려하지 않아 공허한 칭찬만 제공
- 기대 효과: GLP-1 치료 여정의 특수한 감정(증량 두려움, 정체기 좌절, 부작용 불안)을 앱이 "먼저 알아채고" 적절한 메시지를 제공하여 사용자가 동반자와 함께하는 느낌을 받음

## 목표

- [ ] 대시보드 구조를 3섹션(인사 / 상태 요약 / AI 메시지)으로 재구성
- [ ] 사용자 맥락(여정 단계, 증량 시점, 체중 트렌드 등)을 기반으로 LLM이 공감 메시지 생성
- [ ] 메시지 생성 타이밍: 하루 첫 접속 + 데일리 체크인 완료 시
- [ ] 최근 7개 메시지를 컨텍스트로 포함하여 톤 일관성 유지

## 사용자 시나리오

### 시나리오 1: 증량 후 힘든 날 첫 접속

1. 사용자가 증량 3일째 아침에 앱 실행
2. 인사 섹션: "좋은 아침이에요, 민수님. 15일째 함께하고 있어요."
3. 상태 요약: 현재 주차, 진행률, 다음 투여일, 컨디션 표시
4. AI 메시지 섹션: "증량하고 3일째예요. 지금이 제일 힘든 시기예요. 메스꺼움이 있다면 정상이에요. 대부분 일주일 안에 나아져요."
5. 결과: 사용자가 "앱이 내 상황을 안다"고 느낌

### 시나리오 2: 체중 정체기 사용자

1. 사용자가 2주 연속 체중 변화 없는 상태로 앱 실행
2. AI 메시지: "2주째 비슷한 체중이네요. 답답하실 수 있어요. 정체기는 거의 모든 분이 겪는 과정이에요. 몸이 새로운 상태에 적응하는 중이에요."
3. 결과: 판단 없이 상황 인정, 정상화 메시지로 안심

### 시나리오 3: 데일리 체크인 완료 후

1. 사용자가 데일리 체크인에서 "속이 불편함" 선택
2. 체크인 완료 시 AI 메시지 재생성
3. AI 메시지: "오늘 속이 불편하셨군요. GLP-1 초기에 흔한 반응이에요. 천천히 식사하고 물을 자주 마셔보세요."
4. 결과: 방금 입력한 데이터가 즉시 반영된 맞춤 메시지

### 시나리오 4: 메시지 로딩 중

1. 사용자가 앱 실행, AI 메시지 생성 중
2. AI 메시지 섹션에 스켈레톤 UI + "메시지 준비 중..." 표시
3. 생성 완료 후 자연스럽게 메시지 표시
4. 결과: 로딩 중에도 인사/상태 요약은 즉시 표시되어 기다림이 부담되지 않음

## 기술 결정 사항

| 항목 | 결정 | 이유 |
|------|------|------|
| LLM 호출 위치 | Supabase Edge Function | API 키 보안, 비용 통제, 프롬프트 버전 관리 |
| LLM API | OpenRouter | 다양한 모델 선택 가능, 단일 API로 모델 교체 용이 |
| LLM 모델 | OpenAI gpt-oss-20b (free) | 무료, 빠른 응답, MoE 아키텍처 |
| 모델 ID | `openai/gpt-oss-20b:free` | `:free` suffix 필수 |
| Fallback 전략 | 마지막 성공 메시지 재사용 | 구현 단순, 항상 맥락 있는 메시지 제공 |

### 아키텍처

```
Flutter App
    ↓ (메시지 요청)
Supabase Edge Function
    ↓ (OpenRouter API)
LLM (gpt-oss-20b)
    ↓
메시지 반환 → DB 저장 → 클라이언트 응답
```

## 제약 조건

- LLM API 호출은 하루 최대 2회 (첫 접속 + 체크인 완료)
- 메시지 생성 실패 시 마지막 성공 메시지 표시 (fallback)
- 기존 DashboardData, TrendInsight 데이터 구조 최대한 활용
- 메시지는 서버(Supabase)에 저장하여 기기 간 동기화
- 메시지 톤: 판단하지 않음, 정상화, 동반자 느낌 (DBT 검증 원칙 기반)
- 메시지 생성 원칙은 `llm-message-spec.md` 참조

## 참조 코드

> 에이전트는 아래 파일을 먼저 읽고 패턴을 따를 것

| 참조 대상 | 경로 | 참조 이유 |
|----------|------|----------|
| 현재 대시보드 화면 | `lib/features/dashboard/presentation/screens/home_dashboard_screen.dart` | 기존 구조 파악 |
| 대시보드 데이터 | `lib/features/dashboard/domain/entities/dashboard_data.dart` | 사용 가능한 데이터 |
| 대시보드 노티파이어 | `lib/features/dashboard/application/notifiers/dashboard_notifier.dart` | 상태 관리 패턴 |
| 트렌드 인사이트 | `lib/features/tracking/domain/entities/trend_insight.dart` | 컨디션 요약 데이터 |
| 트렌드 인사이트 카드 | `lib/features/tracking/presentation/widgets/trend_insight_card.dart` | 컨디션 표시 UI 패턴 |
| 주간 컨디션 차트 | `lib/features/tracking/presentation/widgets/weekly_condition_chart.dart` | 차트 UI 패턴 |
| 다음 일정 엔티티 | `lib/features/dashboard/domain/entities/next_schedule.dart` | 투여/증량 일정 데이터 |
| 데일리 체크인 완료 흐름 | `lib/features/daily_checkin/` | 체크인 완료 시점 파악 |
| 기존 Edge Function 패턴 | `supabase/functions/delete-account/index.ts` | Edge Function 구조, 인증 패턴 |
| 기존 Functions 호출 | `lib/features/authentication/.../supabase_auth_repository.dart:757` | Flutter에서 Edge Function 호출 패턴 |

## 데이터 구조

### LLM에 전달할 컨텍스트 (JSON)

```
user_context:
  - name, journey_day, current_week
  - current_dose_mg, days_since_last_dose, days_until_next_dose
  - days_since_escalation, next_escalation_in_days (nullable)

health_data:
  - weight_change_this_week_kg, weight_trend (increasing/stable/decreasing)
  - overall_condition (improving/stable/worsening)
  - completion_rate, top_concern (nullable)
  - recent_checkin_summary (오늘 체크인 데이터, nullable)

recent_messages:
  - 최근 7개 생성 메시지 (톤 일관성용)
```

### 메시지 저장 테이블

```
ai_generated_messages:
  - id (UUID)
  - user_id (FK)
  - message (TEXT)
  - context_snapshot (JSONB) - 생성 시점의 컨텍스트
  - generated_at (TIMESTAMPTZ)
  - trigger_type (TEXT) - 'daily_first_open' | 'post_checkin'
```

## 화면 구조

### 섹션 1: 인사 (GreetingSection)

- 시간대별 인사 + 사용자 이름 + 연속 기록일
- LLM 사용 없이 앱 자체 로직으로 구현
- 예: "좋은 아침이에요, 민수님. 14일째 함께하고 있어요."

### 섹션 2: 상태 요약 (StatusSummarySection)

- 현재 주차 + 다음 투여일 (간결한 카드)
- 주간 진행률 (프로그레스 바)
- 체중 트렌드 (숫자 또는 미니 표시)
- 전반적 컨디션 요약 (TrendInsight 활용)
- 기존 위젯 스타일 참조하되 간결하게 재구성

### 섹션 3: AI 메시지 (AIMessageSection)

- 맥락 기반 공감/지지 메시지 표시
- 로딩 중: 스켈레톤 + "메시지 준비 중..."
- 생성 실패 시: 마지막 성공 메시지 또는 기본 메시지

## 구현 전 확인사항

1. `lib/features/dashboard/` 전체 구조 파악
2. `DashboardNotifier`가 어떤 데이터를 어떻게 로드하는지 확인
3. `TrendInsight` 데이터를 대시보드에서 어떻게 가져올 수 있는지 확인
4. 데일리 체크인 완료 시점 이벤트 처리 방법 확인
5. ~~기존 Supabase Edge Function 패턴 확인~~ → **완료** (`architecture.md` 참조)

## 환경 변수 설정

```bash
# 프로덕션 배포 전 필수
supabase secrets set OPENROUTER_API_KEY=sk-or-v1-...

# 로컬 개발
echo "OPENROUTER_API_KEY=sk-or-v1-..." >> supabase/functions/.env
```

## 구현 순서 (권장)

1. 먼저 새 대시보드 UI 구조만 구현 (AI 메시지는 더미)
2. AI 메시지 저장 테이블 생성
3. LLM 컨텍스트 JSON 구성 로직 구현
4. LLM API 연동 및 메시지 생성 구현
5. 생성 타이밍 (첫 접속/체크인 완료) 연동
6. 로딩/에러 상태 처리

## 성공 지표

- [ ] 앱 첫 접속 시 3섹션 구조의 대시보드 표시
- [ ] 시간대 + 이름 + 연속기록일 인사 메시지 표시
- [ ] 상태 요약에 주차/진행률/다음투여/체중/컨디션 표시
- [ ] LLM 생성 메시지가 사용자 맥락(증량 시점 등)을 반영
- [ ] 같은 날 재접속 시 캐시된 메시지 즉시 표시
- [ ] 데일리 체크인 완료 시 메시지 재생성
- [ ] 최근 메시지 7개가 컨텍스트에 포함되어 톤 일관성 유지
- [ ] 메시지 생성 중 로딩 UI 표시
- [ ] API 실패 시 fallback 메시지 표시
- [ ] 기존 테스트 통과 및 빌드 성공

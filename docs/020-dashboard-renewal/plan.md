# 대시보드 Emotion-Driven 개선 구현 계획

## 구현 순서

### Phase 1: 대시보드 UI 구조 변경

**목표**: 기존 6개 위젯 나열 → 3섹션 구조로 재구성

**작업**:
1. 새 대시보드 화면 구조 구현
   - GreetingSection: 시간대 인사 + 이름 + 연속기록일
   - StatusSummarySection: 주차/진행률/다음투여/체중/컨디션
   - AIMessageSection: 더미 메시지로 우선 구현
2. 기존 위젯에서 필요한 데이터/로직 재사용
3. 기존 `home_dashboard_screen.dart` 대체

**참조**:
- `lib/features/dashboard/presentation/screens/home_dashboard_screen.dart`
- `lib/features/dashboard/presentation/widgets/`
- `lib/features/tracking/presentation/widgets/trend_insight_card.dart`

**완료 조건**:
- [ ] 3섹션 구조 화면 표시
- [ ] 기존 데이터(DashboardData, TrendInsight) 연동
- [ ] 빌드 성공

---

### Phase 2: AI 메시지 저장소 구현

**목표**: 생성된 메시지를 저장/조회하는 인프라 구축

**작업**:
1. Supabase 테이블 생성
   ```sql
   ai_generated_messages (
     id, user_id, message, context_snapshot,
     generated_at, trigger_type
   )
   ```
2. Repository 인터페이스 정의 (Domain)
3. Supabase Repository 구현 (Infrastructure)
4. Provider 구성

**참조**:
- `lib/features/dashboard/domain/repositories/`
- `lib/features/dashboard/infrastructure/repositories/`
- `docs/database.md` (테이블 패턴)

**완료 조건**:
- [ ] 테이블 마이그레이션 완료
- [ ] 메시지 저장/조회 API 동작
- [ ] 최근 7개 메시지 조회 기능

---

### Phase 3: LLM 컨텍스트 구성

**목표**: 사용자 맥락을 JSON으로 구성하는 로직 구현

**작업**:
1. 컨텍스트 데이터 수집 로직
   - user_context: 여정일, 주차, 용량, 투여/증량 일정
   - health_data: 체중 변화, 컨디션, 기록률, 체크인 요약
2. JSON 직렬화
3. 최근 메시지 7개 포함

**참조**:
- `lib/features/dashboard/domain/entities/dashboard_data.dart`
- `lib/features/dashboard/domain/entities/next_schedule.dart`
- `lib/features/tracking/domain/entities/trend_insight.dart`
- `lib/features/daily_checkin/domain/entities/daily_checkin.dart`

**완료 조건**:
- [ ] 컨텍스트 JSON 생성 함수 구현
- [ ] 모든 필드 정상 매핑 확인

---

### Phase 4: LLM API 연동 (Supabase Edge Function + OpenRouter)

**목표**: Edge Function에서 OpenRouter API로 메시지 생성

**작업**:
1. Supabase Edge Function 생성 (`generate-ai-message`)
   - 기존 패턴 참조: `supabase/functions/delete-account/index.ts`
   - OpenRouter API 키 환경 변수: `OPENROUTER_API_KEY`
   - 시스템 프롬프트 (llm-message-spec.md 기반)
2. OpenRouter API 연동
   - 엔드포인트: `https://openrouter.ai/api/v1/chat/completions`
   - 모델 ID: `openai/gpt-oss-20b:free` (`:free` suffix 필수)
   - 요청/응답 파싱
3. Flutter에서 Edge Function 호출
   - 기존 패턴 참조: `supabase_auth_repository.dart:757`
4. 에러 핸들링 (타임아웃, 실패 시 마지막 성공 메시지 반환)

**참조**:
- `supabase/functions/delete-account/index.ts` (Edge Function 구조)
- `lib/features/authentication/.../supabase_auth_repository.dart:757` (Flutter 호출 패턴)
- `docs/020-dashboard-renewal/llm-message-spec.md` (프롬프트 원칙)
- `docs/020-dashboard-renewal/architecture.md` (상세 플로우 검증)

**완료 조건**:
- [ ] Edge Function 배포 완료
- [ ] OpenRouter API 호출 성공
- [ ] 메시지 생성 및 DB 저장
- [ ] 실패 시 마지막 성공 메시지 fallback 동작

---

### Phase 5: 생성 타이밍 연동

**목표**: 적절한 시점에 메시지 생성 트리거

**작업**:
1. 하루 첫 접속 감지 로직
   - 마지막 메시지 생성 시간 확인
   - 날짜 변경 시 새 메시지 생성
2. 데일리 체크인 완료 시 재생성
   - 체크인 완료 이벤트 연동
   - 새 데이터 반영하여 메시지 갱신

**참조**:
- `lib/features/daily_checkin/application/`
- `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

**완료 조건**:
- [ ] 하루 첫 접속 시 메시지 생성
- [ ] 같은 날 재접속 시 캐시된 메시지 표시
- [ ] 체크인 완료 시 메시지 재생성

---

### Phase 6: 로딩/에러 상태 처리

**목표**: 사용자 경험 최적화

**작업**:
1. 로딩 상태 UI
   - 스켈레톤 + "메시지 준비 중..." 텍스트
   - 인사/상태 섹션은 즉시 표시
2. 에러 상태 처리
   - API 실패 시 마지막 성공 메시지 표시
   - 메시지 없을 시 기본 메시지 표시
3. 애니메이션
   - 메시지 표시 시 fade-in

**완료 조건**:
- [ ] 로딩 중 스켈레톤 표시
- [ ] 에러 시 fallback 메시지
- [ ] 자연스러운 전환 애니메이션

---

## 의존성 그래프

```
Phase 1 (UI 구조)
    ↓
Phase 2 (저장소) ←──┐
    ↓              │
Phase 3 (컨텍스트) ──┤
    ↓              │
Phase 4 (LLM API) ──┘
    ↓
Phase 5 (타이밍)
    ↓
Phase 6 (UX 처리)
```

## 기술 결정 사항 (확정)

| 항목 | 결정 | 이유 |
|------|------|------|
| LLM 호출 위치 | Supabase Edge Function | API 키 보안, 비용 통제, 프롬프트 버전 관리 |
| LLM API | OpenRouter | 다양한 모델 선택 가능, 단일 API로 모델 교체 용이 |
| LLM 모델 | OpenAI gpt-oss-20b (free) | 무료, 빠른 응답, MoE 아키텍처 |
| Fallback 전략 | 마지막 성공 메시지 재사용 | 구현 단순, 항상 맥락 있는 메시지 제공 |

## 테스트 계획

| Phase | 테스트 항목 |
|-------|-----------|
| 1 | UI 렌더링, 데이터 바인딩 |
| 2 | Repository CRUD 동작 |
| 3 | 컨텍스트 JSON 정확성 |
| 4 | LLM 응답 파싱, 에러 핸들링 |
| 5 | 타이밍 로직 (날짜 변경, 체크인 완료) |
| 6 | 로딩/에러 상태 전환 |

# 홈 대시보드 (F006) Plan 검증 결과

## 검증 날짜
2025-11-07

## 검증 결과: 수정 필요

---

## 1. 누락된 기능

### 1.1 인사이트 메시지 생성 (GenerateInsightMessageUseCase)
**문제점:**
- spec.md에서 명시적으로 "인사이트 생성" 요구사항이 없으나, plan.md에서 P1(Priority 1)으로 포함
- spec.md의 Edge Case "인사이트 생성 조건 미충족" 항목이 있어 기능이 필요함을 암시하지만, Main Scenario에는 명시되지 않음

**권고사항:**
- GenerateInsightMessageUseCase를 P0(필수)로 변경하거나, spec.md에 해당 기능을 Main Scenario에 추가 필요
- 또는 MVP 범위에서 제외하고 plan.md에서 완전히 삭제

### 1.2 축하 효과 (Celebration Animation)
**spec.md 요구사항:**
- "### 9. 투여 완료 시 축하 효과" - 투여 완료 시 축하 애니메이션 표시
- "### 10. 주간 목표 100% 달성 시" - 100% 달성 항목 시각적 강조

**plan.md 상태:**
- DashboardScreen Implementation Order에 "Achievement Animation" 항목만 존재
- 구체적인 Widget이나 UseCase가 없음

**권고사항:**
- CelebrationAnimationWidget 추가 필요
- 또는 DashboardScreen 내부 로직으로 처리하되, 테스트 시나리오에 명시 필요

### 1.3 스켈레톤 UI / 로딩 인디케이터
**spec.md 요구사항:**
- Edge Case "데이터 로딩 지연" - 스켈레톤 UI 또는 로딩 인디케이터 표시

**plan.md 상태:**
- DashboardScreen 테스트에 "should show loading indicator initially" 존재
- 하지만 스켈레톤 UI에 대한 구체적인 구현 계획 없음

**권고사항:**
- 로딩 상태 처리를 명확히 정의 (스켈레톤 UI vs 로딩 인디케이터)
- Widget 구현 계획에 추가

---

## 2. 설계 검증 필요 사항

### 2.1 실시간 통계 재계산 (BR-010)
**spec.md 요구사항:**
- BR-010: "퀵 액션으로 기록 완료 후: 즉시 갱신"
- Edge Case "과거 데이터 수정으로 통계 변동": "BE는 변경 감지 시 실시간으로 통계를 재계산"

**plan.md 상태:**
- DashboardNotifier에 refresh() method 존재
- 하지만 자동 갱신 트리거 메커니즘이 명시되지 않음

**문제점:**
- Phase 0에서는 Local DB(Isar)를 사용하므로 "BE가 변경 감지" 불가능
- Riverpod의 StreamProvider나 Isar watch() 기능 활용이 필요하나 plan.md에 명시되지 않음

**권고사항:**
- TrackingRepository에서 Isar watch()를 통한 실시간 변경 감지 구현 필요
- 또는 DashboardNotifier가 특정 Repository의 Stream을 구독하는 구조 추가
- 또는 기록 완료 후 명시적으로 refresh() 호출하는 구조 명시

### 2.2 뱃지 획득 우선순위 처리 (Edge Case)
**spec.md 요구사항:**
- Edge Case "뱃지 획득 조건 동시 충족": "BE는 우선순위에 따라 뱃지 획득을 순차 처리"

**plan.md 상태:**
- VerifyBadgeConditionsUseCase 테스트에 "should verify" 개별 뱃지 검증만 존재
- 동시 충족 시 우선순위 처리 로직 없음

**권고사항:**
- VerifyBadgeConditionsUseCase에 우선순위 처리 로직 추가
- 테스트 시나리오에 "should handle multiple badge conditions by priority" 추가

### 2.3 데이터 집계 성능 최적화
**spec.md 요구사항:**
- 암묵적으로 홈 화면 로딩은 빠르게 이루어져야 함 (사용자 경험)

**plan.md 상태:**
- Phase 5에 "Performance Profiling: 대시보드 로딩 시간 측정 (< 1초 목표)" 존재
- 하지만 구체적인 최적화 전략이 없음

**문제점:**
- DashboardNotifier가 7개의 UseCase와 4개의 Repository를 순차적으로 호출하면 성능 문제 발생 가능

**권고사항:**
- Repository 병렬 호출 전략 명시 (Future.wait 활용)
- 또는 Database 쿼리 최적화 방안 추가 (Aggregation Query)

---

## 3. 아키텍처 원칙 위반 검증

### 3.1 Layer 의존성 확인
**검증 결과:** 정상
- Presentation → Application → Domain ← Infrastructure 구조 준수
- Repository Pattern 정상 적용 (BadgeRepository Interface + IsarBadgeRepository Implementation)

### 3.2 Repository Interface 정의 확인
**검증 결과:** 정상
- BadgeRepository Interface가 Domain Layer에 정의됨
- IsarBadgeRepository Implementation이 Infrastructure Layer에 정의됨

### 3.3 TDD 적용 확인
**검증 결과:** 정상
- 모든 Layer에서 Test First 전략 명시
- Red → Green → Refactor 사이클 준수

---

## 4. 데이터 모델 검증

### 4.1 Entity vs DTO 분리
**문제점:**
- plan.md에서 Badge Entity가 명시되지 않음
- BadgeDefinitionDto, UserBadgeDto는 Infrastructure에 정의되어 있으나, Domain Entity 누락

**권고사항:**
- Domain Layer에 Badge, BadgeDefinition, UserBadge Entity 추가 필요
- 또는 기존 Entity를 재사용하는 경우 명시 필요

### 4.2 NextSchedule Entity
**spec.md 요구사항:**
- "다음 투여 예정일 및 용량, 다음 증량 예정일(해당 시), 목표 달성 예상 시기"

**plan.md 상태:**
- NextSchedule Entity 정의됨
- 테스트 시나리오: "should handle null escalation date" 존재

**검증 결과:** 정상

### 4.3 TimelineEvent Entity
**spec.md 요구사항:**
- BR-008: "용량 증량 시점, 체중 감량 목표 달성"

**plan.md 상태:**
- TimelineEvent Entity 정의됨
- 테스트 시나리오: "should create milestone event", "should sort events by date"

**검증 결과:** 정상

---

## 5. 테스트 전략 검증

### 5.1 Test Pyramid 비율
**plan.md 목표:**
- Unit: 70%
- Integration: 20%
- Acceptance: 10%

**실제 계획:**
- Domain UseCases: 7개 (Unit Test)
- Domain Entities: 5개 (Unit Test)
- Application Notifier: 1개 (Integration Test)
- Application Providers: 4개 (Provider Test)
- Infrastructure Repository: 1개 (Integration Test)
- Presentation Widgets: 7개 (Widget Test + Golden Test)
- Presentation Screen: 1개 (Acceptance Test)

**계산:**
- Unit: 12개 (Domain 7 + Entities 5) ≈ 46%
- Integration: 6개 (Application 5 + Infrastructure 1) ≈ 23%
- Widget/Acceptance: 8개 (Widgets 7 + Screen 1) ≈ 31%

**문제점:**
- Unit Test 비율이 70% 목표에 미달 (46%)
- Widget Test 비율이 높음 (31%)

**권고사항:**
- Widget Test를 간소화하거나, Domain UseCase를 더 세분화하여 비율 조정
- 또는 Test Pyramid 비율 목표를 현실적으로 재설정

### 5.2 Golden Test 범위
**plan.md 상태:**
- 모든 Widget과 DashboardScreen에 Golden Test 포함

**문제점:**
- Golden Test 유지보수 비용이 높음
- 디자인 변경 시 전체 Golden File 갱신 필요

**권고사항:**
- 핵심 Widget만 Golden Test 적용 (예: DashboardScreen, WeeklyProgressWidget)
- 나머지는 Widget Test로 대체

---

## 6. Edge Case 처리 검증

### 6.1 신규 사용자 (데이터 없음)
**spec.md:** FE는 환영 메시지 표시, 첫 기록 입력 유도 안내
**plan.md:** DashboardScreen 테스트에 "should display empty state for new user" 존재

**검증 결과:** 정상

### 6.2 연속 기록일 중단
**spec.md:** BE는 연속 기록일을 0으로 리셋, 격려 메시지 표시
**plan.md:** CalculateContinuousRecordDaysUseCase 테스트에 "should reset to 0 when gap exists in records" 존재

**검증 결과:** 정상

### 6.3 네트워크 오류 (로컬 캐시)
**spec.md:** FE는 로컬 캐시된 데이터를 표시, 재시도 버튼 제공
**plan.md:** Phase 0에서는 Local DB 사용으로 네트워크 오류 없음

**문제점:**
- Phase 0에서는 해당 Edge Case가 발생하지 않음
- Phase 1 전환 시 고려 필요

**권고사항:**
- Phase 0에서는 해당 Edge Case를 제외하거나, "추후 구현" 명시

### 6.4 퀵 액션 연속 클릭
**spec.md:** FE는 중복 방지 처리(debounce) 적용
**plan.md:** QuickActionWidget 테스트에 "should prevent duplicate taps (debounce)" 존재

**검증 결과:** 정상

---

## 7. Business Rules 구현 검증

### 7.1 BR-001: 연속 기록일 계산
**spec.md:** 마지막 기록 날짜부터 현재까지 일수 계산, 기록 없는 날 발생 시 0 리셋
**plan.md:** CalculateContinuousRecordDaysUseCase 구현됨

**검증 결과:** 정상

### 7.2 BR-004: 목표 달성 예상 시기 계산
**spec.md:** 최근 4주 체중 감량 추세를 선형 회귀 분석
**plan.md:** CalculateWeightGoalEstimateUseCase 구현됨

**검증 결과:** 정상

### 7.3 BR-006: 뱃지 획득 조건
**spec.md:** 5가지 뱃지 조건 정의
**plan.md:** VerifyBadgeConditionsUseCase에서 모든 조건 검증

**검증 결과:** 정상

### 7.4 BR-007: 뱃지 진행도 계산
**spec.md:** 각 뱃지별 진행 상황을 백분율로 계산
**plan.md:** VerifyBadgeConditionsUseCase 테스트에 "should calculate progress percentage correctly" 존재

**검증 결과:** 정상

---

## 8. 권고 사항 요약

### 8.1 필수 수정 사항 (P0)
1. **Badge Entity 추가**: Domain Layer에 Badge 관련 Entity 정의 필요
2. **실시간 갱신 메커니즘 명시**: Isar watch() 활용 또는 명시적 refresh() 호출 구조 추가
3. **뱃지 우선순위 처리 로직**: 동시 충족 시 처리 방안 추가
4. **축하 효과 구현 계획**: 구체적인 Widget 또는 Screen 로직 명시

### 8.2 선택적 수정 사항 (P1)
1. **GenerateInsightMessageUseCase 우선순위 결정**: MVP 포함 여부 명확화
2. **스켈레톤 UI vs 로딩 인디케이터**: 구체적인 UI 방향 결정
3. **Test Pyramid 비율 재조정**: 현실적인 목표 설정
4. **Golden Test 범위 축소**: 유지보수 비용 고려
5. **성능 최적화 전략**: Repository 병렬 호출 또는 쿼리 최적화 방안 추가

### 8.3 문서 개선 사항
1. Phase 0에서 발생하지 않는 Edge Case 제외 또는 명시
2. 각 UseCase의 Input/Output 명확화
3. Provider 간 의존성 다이어그램 추가

---

## 9. 최종 결론

**전체 평가:** 양호 (70/100)

**강점:**
- 4-Layer Architecture 원칙 준수
- Repository Pattern 정확히 적용
- TDD 전략 명확
- 대부분의 Business Rules 구현 계획 존재

**약점:**
- 일부 기능 누락 (Badge Entity, 실시간 갱신 메커니즘)
- Edge Case 처리 불완전 (뱃지 우선순위, 축하 효과)
- 성능 최적화 전략 미흡
- Test Pyramid 비율 불균형

**권고사항:**
- 필수 수정 사항(P0) 8개 항목 반영 후 구현 시작
- 선택적 수정 사항(P1)은 팀 논의 후 결정

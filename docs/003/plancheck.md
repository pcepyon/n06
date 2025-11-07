# UF-F001 Plan Review - 설계 검증 결과

## 검증 일시
2025-11-07

## 검증 결과: 수정 필요 (Medium Priority)

---

## 1. 누락된 기능 (Critical)

### 1.1 투여 알림 기능 미설계
**문제**: spec.md에서 명시된 "투여 알림" 시나리오(4번)가 plan.md에서 완전히 누락됨

**Spec 요구사항**:
- 투여 예정일 당일 지정 시간에 푸시 알림 생성
- 알림 메시지에 예정 용량 정보 포함
- 알림 클릭 시 투여 스케줄러 화면 이동

**현재 Plan**:
- Integration Points에서 "알림 (UF-012)" 언급만 있음
- 실제 구현 모듈 없음

**필요 조치**:
```
추가 필요 모듈:
- DoseNotificationUseCase (Domain Layer)
  - 알림 스케줄링 로직
  - 알림 페이로드 생성
  - 알림 클릭 딥링크 처리

- NotificationService (Infrastructure Layer)
  - 플랫폼별 푸시 알림 구현
  - 알림 권한 관리
  - 백그라운드 작업 스케줄링

- MedicationNotifier 확장
  - scheduleNotification() 메서드
  - cancelNotification() 메서드
```

---

### 1.2 증량 계획 변경 이력 조회 미설계
**문제**: spec.md의 BR-007에서 "변경 이력은 영구 보관" 명시했으나 조회 기능 누락

**Spec 요구사항**:
- 모든 증량 계획 변경은 이력 기록 필수
- 변경 이력은 날짜, 변경 전/후 계획 포함
- 변경 이력은 영구 보관

**현재 Plan**:
- Repository 인터페이스에 `savePlanChangeHistory` 존재
- 조회 메서드 없음 (getPlanChangeHistory)
- UI에서 이력 표시 설계 없음

**필요 조치**:
```
Repository 인터페이스 추가:
Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId);

MedicationNotifier 추가:
AsyncValue<List<PlanChangeHistory>> getPlanHistory();

UI 추가:
- PlanHistoryScreen 또는 PlanHistoryDialog
- QA Sheet에 이력 조회 시나리오 추가
```

---

## 2. 설계 불일치 (High Priority)

### 2.1 스케줄 수동 변경 로직 불완전
**문제**: spec.md의 "스케줄 수동 변경" 시나리오가 MedicationNotifier에만 있고 독립적인 UseCase 없음

**Spec 시나리오 5번**:
1. 사용자가 특정 투여일 또는 용량 수정 요청
2. 수정 가능 항목 표시
3. 입력 검증 (날짜 논리, 용량 범위)
4. 변경 지점 이후 모든 스케줄 재계산
5. 업데이트된 스케줄 반영

**현재 Plan**:
- MedicationNotifier.updateDosagePlan()만 존재
- "특정 투여일 수정" 기능 없음 (계획 전체 변경만 가능)

**권장 사항**:
```
추가 UseCase:
- ScheduleModificationUseCase
  - validateScheduleChange(schedule, newDate, newDose)
  - applyScheduleChange(schedule, changes)
  - 단일 스케줄 변경 로직 (전체 재계산과 분리)

MedicationNotifier 추가:
- updateSingleSchedule(scheduleId, newDate, newDose)
- updateDosagePlan은 계획 수준 변경에만 사용
```

---

### 2.2 누락 관리 정기 체크 메커니즘 미설계
**문제**: spec.md 시나리오 7번에서 "시스템이 매일 투여 완료 여부 확인" 명시했으나 구현 방안 없음

**Spec 요구사항**:
- 매일 투여 완료 여부 확인
- 예정일 경과 시 누락 일수 계산
- 자동 알림 생성

**현재 Plan**:
- MissedDoseAnalyzerUseCase는 분석만 수행 (정기 체크 없음)
- MedicationNotifier.getMissedDoseAnalysis()는 computed property (수동 조회)

**필요 조치**:
```
Infrastructure Layer 추가:
- BackgroundTaskService
  - 매일 정기 체크 스케줄링 (예: WorkManager)
  - 백그라운드에서 MissedDoseAnalyzerUseCase 실행
  - 누락 감지 시 알림 생성

또는 Cloud Function (Phase 1 준비):
- daily_missed_dose_check()
- Supabase Edge Functions 또는 Firebase Functions
```

---

## 3. 아키텍처 위반 (Medium Priority)

### 3.1 Presentation Layer에서 UseCase 직접 호출 가능성
**문제**: Architecture Diagram에서 Presentation → UseCase 직접 연결선 없음에도 불구하고, 향후 실수 가능성 존재

**Clean Architecture 규칙**:
- Presentation은 Application Layer(Notifier)만 참조
- UseCase는 Application Layer에서만 호출

**권장 사항**:
```
명시적 규칙 추가:
- CLAUDE.md에 "Presentation에서 UseCase 직접 import 금지" 추가
- Plan.md에 "UseCase는 private으로 Notifier 내부에서만 사용" 명시
- 린트 규칙 설정 (custom_lint 사용)
```

---

## 4. 테스트 전략 개선 (Low Priority)

### 4.1 Edge Case 테스트 시나리오 누락
**문제**: spec.md의 Edge Cases 섹션이 plan.md의 Test Scenarios에 일부만 반영됨

**누락된 Edge Case 테스트**:
```
DosagePlan Entity:
- [ ] 시작일이 과거인 경우 (spec: 현재 날짜로 자동 조정 제안)
- [ ] 스케줄 생성 중 앱 종료 (spec: 다음 실행 시 자동 재생성)

DoseRecord Entity:
- [ ] 같은 날 중복 투여 기록 시도 (spec: 중복 방지 확인 메시지)
- [ ] 투여 완료 후 기록 삭제 (spec: 삭제 확인 대화상자 및 스케줄 재계산)

ScheduleGeneratorUseCase:
- [ ] 투여일 변경으로 증량 시점 앞당겨짐 (spec: 안전성 경고 표시)
- [ ] 증량 계획 삭제 (spec: 현재 용량 유지 스케줄로 재계산)

MedicationNotifier:
- [ ] 여러 투여 예정일이 같은 날 (spec: 한 번만 알림 발송)
- [ ] 네트워크 오류로 저장 실패 (spec: 로컬 저장 후 재시도 큐)
```

**필요 조치**:
각 모듈의 Test Scenarios에 위 항목 추가

---

### 4.2 Integration Test 범위 불명확
**문제**: Repository Integration Test는 명시했으나 end-to-end 통합 테스트 누락

**권장 추가**:
```
Phase 4.5: Integration Test (Optional)
- 온보딩 → 스케줄 생성 → 투여 기록 → 계획 변경 전체 플로우
- Widget Test (flutter_test)
- Golden Test (UI 회귀 방지)
```

---

## 5. 성능 최적화 고려사항 (Low Priority)

### 5.1 대량 데이터 처리 시나리오 미명시
**문제**: 1년 이상 장기 사용자의 경우 수백 개의 기록 처리 성능 목표 없음

**현재 성능 목표**:
- 스케줄 생성 (6개월) < 1초
- 배치 저장 (100개) < 500ms

**추가 필요**:
```
Performance Targets 추가:
| 작업 | 목표 | 측정 방법 |
|------|------|-----------|
| 1년치 기록 조회 (500개) | < 200ms | Stopwatch |
| 부위별 이력 시각화 (30일) | < 100ms | Stopwatch |
| Stream 초기 로드 | < 300ms | Stopwatch |
```

---

### 5.2 메모리 최적화 전략 부재
**문제**: 대량 스케줄 로드 시 메모리 사용량 목표 없음

**권장 추가**:
```
Domain Layer:
- Pagination 지원 (DoseSchedule, DoseRecord)
- Repository에 limit/offset 파라미터 추가

Application Layer:
- Notifier에서 무한 스크롤 구현 (가상화)
```

---

## 6. Business Rule 검증 누락 (Medium Priority)

### 6.1 BR-004 검증 로직 위치 불명확
**문제**: "증량은 단조 증가만 허용" 규칙을 어디서 검증하는지 불명확

**Spec BR-004**:
- 증량은 단조 증가만 허용 (감량 불가)
- 증량 시점은 시간 순서 유지 필수
- 증량 단계는 최대 용량 범위 내 제한

**현재 Plan**:
- DosagePlan Entity에서 "validate escalation plan is monotonically increasing" 테스트만 있음
- "최대 용량 범위" 정의 없음
- 시간 순서 검증 로직 명시 없음

**필요 조치**:
```
DosagePlan Entity 개선:
- MAX_DOSE 상수 정의 (예: 2.4mg for Ozempic)
- validateEscalationPlan() 메서드 확장:
  - 단조 증가 검증
  - 시간 순서 검증
  - 최대 용량 범위 검증
```

---

### 6.2 BR-005 중복 방지 로직 미설계
**문제**: "각 투여일은 1회만 완료 기록 허용" 규칙의 구현 방안 없음

**현재 Plan**:
- DoseRecord Entity에 중복 검증 테스트 없음
- Repository에 uniqueness 보장 메커니즘 없음

**필요 조치**:
```
Infrastructure Layer:
- DoseRecordDto에 Isar Unique Index 추가
  - @Index(unique: true, composite: [planId, scheduledDate])

Application Layer:
- MedicationNotifier.recordDose()에 중복 체크 로직
  - 기존 기록 존재 시 "이미 기록된 투여입니다" 에러

Test Scenarios 추가:
- test('should throw exception when recording duplicate dose for same date')
```

---

## 7. Phase 0 → Phase 1 준비사항 (Low Priority)

### 7.1 데이터 동기화 전략 부재
**문제**: spec.md Edge Cases에서 "여러 기기 동시 변경: 최신 타임스탬프 우선 (Phase 1)" 언급했으나 plan.md에 반영 없음

**필요 조치**:
```
Domain Layer 확장:
- 모든 Entity에 updatedAt 필드 추가
- ConflictResolutionStrategy enum 정의

Infrastructure Layer:
- SupabaseMedicationRepository 스텁 생성
- Real-time subscription 인터페이스 정의

Plan.md에 "Phase 1 Migration Plan" 섹션 추가
```

---

## 8. 문서화 개선 (Low Priority)

### 8.1 Sequence Diagram과 Architecture Diagram 불일치
**문제**: spec.md의 Sequence Diagram이 3-tier(FE/BE/DB)인 반면, plan.md는 4-layer 구조

**권장 사항**:
- spec.md를 4-layer 용어로 수정 또는
- plan.md에 "Spec의 BE는 Application + Domain + Infrastructure를 포함" 명시

---

### 8.2 Value Object 정의 부재
**문제**: Plan에서 `EscalationStep`, `InjectionSite`를 언급했으나 상세 정의 없음

**필요 추가**:
```markdown
### 3.X. Value Objects

#### EscalationStep
**Location**: `lib/features/tracking/domain/value_objects/escalation_step.dart`

**Fields**:
- weekNumber: int (증량 시점 주차)
- dose: double (증량 용량)

**Validation**:
- weekNumber > 0
- dose >= 0

#### InjectionSite (Enum)
**Location**: `lib/features/tracking/domain/value_objects/injection_site.dart`

**Values**:
- abdomen: 복부
- thigh: 허벅지
- arm: 상완
```

---

## 9. 우선순위별 조치 사항 요약

### Immediate (Week 1)
1. **투여 알림 기능 설계 추가** (Section 1.1)
   - DoseNotificationUseCase
   - NotificationService
   - MedicationNotifier 확장

2. **중복 방지 로직 설계** (Section 6.2)
   - Unique Index
   - 중복 체크 로직

3. **BR-004 검증 로직 명확화** (Section 6.1)
   - 최대 용량 정의
   - 검증 메서드 확장

### High Priority (Week 2)
4. **스케줄 수동 변경 UseCase 분리** (Section 2.1)
   - ScheduleModificationUseCase
   - updateSingleSchedule 메서드

5. **증량 계획 변경 이력 조회 기능** (Section 1.2)
   - getPlanChangeHistory 메서드
   - 이력 조회 UI

6. **누락 관리 정기 체크 메커니즘** (Section 2.2)
   - BackgroundTaskService

### Medium Priority (Week 3-4)
7. **Edge Case 테스트 시나리오 추가** (Section 4.1)
8. **Value Object 정의 문서화** (Section 8.2)
9. **아키텍처 규칙 명시** (Section 3.1)

### Low Priority (Phase 1 준비)
10. **대량 데이터 처리 최적화** (Section 5.1, 5.2)
11. **Phase 1 마이그레이션 전략** (Section 7.1)
12. **문서 일관성 개선** (Section 8.1)

---

## 10. 검증 결론

**총평**: plan.md는 전반적으로 spec.md의 핵심 요구사항을 반영하고 있으나, **투여 알림 기능**, **스케줄 수동 변경 로직**, **증량 계획 이력 조회** 등 중요 기능이 누락되어 있어 **수정 필수**입니다.

**강점**:
- TDD 기반 체계적인 구현 계획
- Clean Architecture 레이어 분리 명확
- 성능 목표 구체적 제시
- QA Sheet 포함한 실용적 테스트 전략

**개선 필요**:
- spec.md의 모든 시나리오를 plan.md에 1:1 매핑 확인
- Edge Cases를 Test Scenarios에 전부 반영
- Business Rules 검증 로직 위치 명시
- Phase 1 전환을 위한 확장 지점 사전 설계

**다음 단계**:
1. 본 plancheck.md의 Immediate 조치사항 반영
2. plan.md 업데이트
3. 구현 전 최종 리뷰

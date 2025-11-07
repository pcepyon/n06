# 투여 계획 수정 Plan 검증 결과

## 검증 일시
2025-11-07

## 검증 결과: 설계 누락 및 오류 발견

---

## 1. 치명적 누락 (Critical)

### 1.1 투여 스케줄 재계산 로직 완전 누락 ⚠️

**spec.md 요구사항 (Main Scenario Step 5)**:
```
- FE는 스케줄 재계산 로직 실행
- FE는 변경된 계획 기준으로 dose_schedules 재생성:
  - 기존 dose_schedules 중 미래 일정 삭제
  - 새 계획 기반으로 전체 스케줄 재생성
  - 증량 계획 반영
  - 1초 이내 완료
- FE는 재계산된 스케줄을 BE에 저장
```

**plan.md 현황**:
- 스케줄 재계산 UseCase 없음
- 스케줄 생성 로직 없음
- 증량 계획 적용 로직 없음

**필요 추가 모듈**:
```
Module X: RecalculateDoseScheduleUseCase (Domain)
Location: lib/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart

Responsibility:
- 변경된 투여 계획 기반으로 미래 스케줄 재계산
- 증량 계획 반영
- 1초 이내 완료 (성능 요구사항)

Input:
- DosagePlan (변경된 계획)
- DateTime (현재 시점)

Output:
- List<DoseSchedule> (재계산된 스케줄 배열)

Business Rules:
- BR-4: 현재 시점 이후만 재계산
- BR-5: 1초 이내 완료
- 증량 계획 단계별 용량 적용
```

---

### 1.2 DoseScheduleRepository 의존성 누락 ⚠️

**spec.md 요구사항 (Sequence Diagram)**:
```
DELETE /dose-schedules/future?plan_id={id}
POST /dose-schedules/batch (스케줄 배열)
```

**plan.md 현황**:
- DoseScheduleRepository 인터페이스 언급 없음
- 미래 스케줄 삭제 메서드 없음
- 배치 스케줄 저장 메서드 없음

**필요 추가 인터페이스**:
```dart
abstract class DoseScheduleRepository {
  /// 미래 스케줄 삭제
  Future<void> deleteFutureSchedules(String dosagePlanId, DateTime fromDate);

  /// 배치 스케줄 저장
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules);

  /// 특정 계획의 스케줄 조회
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId);
}
```

**의존성 추가 필요**:
- UpdateDosagePlanUseCase → DoseScheduleRepository
- RecalculateDoseScheduleUseCase → DoseScheduleRepository

---

## 2. 주요 누락 (Major)

### 2.1 변경사항 영향 분석 로직 누락

**spec.md 요구사항 (Main Scenario Step 3)**:
```
- FE는 변경사항이 기존 투여 기록에 미치는 영향 분석
- FE는 영향 확인 메시지 표시: "투여 계획 변경 시 이후 스케줄이 재계산됩니다. 진행하시겠습니까?"
```

**plan.md 현황**:
- 영향 분석 로직 없음
- 확인 다이얼로그 구체적 테스트 없음

**필요 추가**:
```
Module Y: AnalyzePlanChangeImpactUseCase (Domain)

Input:
- DosagePlan oldPlan
- DosagePlan newPlan
- DateTime currentDate

Output:
- PlanChangeImpact {
    int affectedScheduleCount;
    DateTime firstAffectedDate;
    List<String> changedFields;
    bool hasEscalationChange;
  }

Test Scenarios:
- TC-1: 시작일 변경 시 영향 분석
- TC-2: 주기 변경 시 영향 분석
- TC-3: 증량 계획 변경 시 영향 분석
```

**EditDosagePlanScreen 추가 테스트**:
```dart
// TC-3: 영향 분석 결과 표시
testWidgets('should show impact analysis dialog before save', (tester) async {
  // ...
  await tester.tap(find.byKey(Key('save_button')));
  await tester.pumpAndSettle();

  expect(find.text('투여 계획 변경 시 이후 스케줄이 재계산됩니다'), findsOneWidget);
  expect(find.text('진행하시겠습니까?'), findsOneWidget);
});
```

---

### 2.2 변경사항 없음 감지 로직 누락

**spec.md 요구사항 (EC-6)**:
```
- 사용자가 아무 값도 변경하지 않고 저장 버튼 클릭
- FE는 변경사항 없음을 감지하고 즉시 설정 화면으로 복귀
- 불필요한 DB 업데이트 방지
```

**plan.md 현황**:
- 변경사항 감지 로직 없음
- 관련 테스트 없음

**필요 추가**:
```
DosagePlanNotifier 추가 메서드:

bool hasChanges(DosagePlan oldPlan, DosagePlan newPlan) {
  return oldPlan != newPlan;
}

Test:
// TC-3: 변경사항 없을 때 조기 복귀
test('should return early when no changes detected', () async {
  final oldPlan = ...;
  final newPlan = oldPlan; // 동일

  await notifier.updatePlan(oldPlan, newPlan);

  verifyNever(mockRepository.updateDosagePlan(any));
  verifyNever(mockRepository.savePlanChangeHistory(any));
});
```

---

### 2.3 네트워크 오류 재시도 로직 누락

**spec.md 요구사항 (EC-7)**:
```
- FE는 로컬에 변경사항 임시 저장
- 재시도 옵션 제공
- 연결 복구 시 자동 재시도 (최대 3회)
```

**plan.md 현황**:
- 에러 처리만 언급, 재시도 로직 없음
- 로컬 임시 저장 로직 없음

**필요 추가**:
```
Module Z: LocalDraftRepository (Infrastructure)

Responsibility:
- 네트워크 오류 시 변경사항 로컬 저장
- 재시도 대기 중인 변경사항 관리

Methods:
- saveDraft(DosagePlan plan)
- getDraft()
- clearDraft()

DosagePlanNotifier 추가 로직:
- 재시도 카운터 관리
- 자동 재시도 로직 (최대 3회)
```

---

## 3. 부수적 누락 (Minor)

### 3.1 과거 시작일 경고 로직 구체화 부족

**spec.md 요구사항 (EC-1)**:
```
- 시작일이 과거 날짜로 변경되는 경우
- FE는 경고 메시지 표시: "시작일이 과거 날짜입니다. 계속하시겠습니까?"
```

**필요 추가**:
```
ValidateDosagePlanUseCase 추가 검증:

ValidationResult validateStartDate(DateTime startDate) {
  if (startDate.isBefore(DateTime.now())) {
    return ValidationResult.warning(
      '시작일이 과거 날짜입니다. 계속하시겠습니까?'
    );
  }
  return ValidationResult.success();
}
```

---

### 3.2 증량 계획 대폭 변경 안전성 경고 누락

**spec.md 요구사항 (EC-5)**:
```
- 증량 속도나 최종 용량이 크게 변경되는 경우
- FE는 안전성 경고 표시: "용량 변경이 큽니다. 의료진과 상담 후 진행하세요."
```

**필요 추가**:
```
ValidateDosagePlanUseCase 추가 검증:

ValidationResult validateEscalationChange(
  List<EscalationStep>? oldPlan,
  List<EscalationStep>? newPlan,
) {
  // 최종 용량 50% 이상 변경 시 경고
  if (변경폭 > 50%) {
    return ValidationResult.warning(
      '용량 변경이 큽니다. 의료진과 상담 후 진행하세요.'
    );
  }
  return ValidationResult.success();
}
```

---

### 3.3 진행 중인 증량 계획 변경 안내 누락

**spec.md 요구사항 (EC-2)**:
```
- 이미 일부 증량이 진행된 상태에서 증량 계획 변경
- FE는 영향 범위 명확히 안내: "현재 N주차 진행 중입니다. 변경 시 이후 증량 일정이 조정됩니다."
```

**필요 추가**:
```
AnalyzePlanChangeImpactUseCase에 추가:

int getCurrentWeek(DosagePlan plan, DateTime now);
String getProgressMessage(int currentWeek);
```

---

## 4. 아키텍처 구조 개선 제안

### 4.1 UpdateDosagePlanUseCase 역할 재정의

**현재 plan.md**:
```
UpdateDosagePlanUseCase
- 검증
- 이력 저장
- 업데이트
```

**수정 필요**:
```
UpdateDosagePlanUseCase
- 검증 (ValidateDosagePlanUseCase 호출)
- 영향 분석 (AnalyzePlanChangeImpactUseCase 호출)
- 변경사항 감지
- 이력 저장 (DosagePlanRepository)
- 계획 업데이트 (DosagePlanRepository)
- 스케줄 재계산 (RecalculateDoseScheduleUseCase 호출)
- 미래 스케줄 삭제 (DoseScheduleRepository)
- 새 스케줄 저장 (DoseScheduleRepository)
```

**이유**: spec.md의 Sequence Diagram과 일치시키기 위함

---

### 4.2 트랜잭션 처리 명확화

**spec.md 요구사항 (BR-6)**:
```
- 투여 계획 업데이트와 변경 이력 저장은 하나의 트랜잭션으로 처리
- 일부만 성공하는 경우 전체 롤백
```

**필요 추가**:
```
IsarDosagePlanRepository 추가 메서드:

Future<void> updatePlanWithHistory(
  DosagePlan plan,
  PlanChangeHistory history,
) async {
  await isar.writeTxn(() async {
    // 1. 이력 저장
    await isar.planChangeHistories.put(history.toDto());
    // 2. 계획 업데이트
    await isar.dosagePlans.put(plan.toDto());
  });
}
```

**Test 추가**:
```dart
// TC-4: 트랜잭션 실패 시 롤백
test('should rollback both history and plan on error', () async {
  // 이력 저장 성공, 계획 업데이트 실패 시나리오
  // 전체 롤백 확인
});
```

---

## 5. 누락된 모듈 요약

### 추가 필요 모듈:

1. **RecalculateDoseScheduleUseCase** (Domain) ⚠️
   - 투여 스케줄 재계산 로직
   - 증량 계획 반영
   - 성능 요구사항 (1초 이내)

2. **DoseScheduleRepository Interface** (Domain) ⚠️
   - deleteFutureSchedules 메서드
   - saveBatchSchedules 메서드
   - getSchedulesByPlanId 메서드

3. **AnalyzePlanChangeImpactUseCase** (Domain)
   - 변경사항 영향 분석
   - 영향받는 스케줄 카운트
   - 현재 증량 진행 주차 계산

4. **LocalDraftRepository** (Infrastructure)
   - 네트워크 오류 시 임시 저장
   - 재시도 대기 중인 변경사항 관리

5. **PlanChangeConfirmationDialog** (Presentation)
   - 영향 분석 결과 표시
   - 진행 확인 다이얼로그

---

## 6. 수정된 의존성 그래프

```mermaid
graph TD
    subgraph Presentation
        A[EditDosagePlanScreen]
        B[DosagePlanFormWidget]
        C[PlanChangeConfirmationDialog] %% 추가
    end

    subgraph Application
        D[DosagePlanNotifier]
        E[UpdateDosagePlanUseCase]
    end

    subgraph Domain
        F[DosagePlan Entity]
        G[PlanChangeHistory Entity]
        H[DoseSchedule Entity] %% 추가
        I[DosagePlanRepository Interface]
        J[DoseScheduleRepository Interface] %% 추가
        K[ValidateDosagePlanUseCase]
        L[RecalculateDoseScheduleUseCase] %% 추가
        M[AnalyzePlanChangeImpactUseCase] %% 추가
    end

    subgraph Infrastructure
        N[IsarDosagePlanRepository]
        O[IsarDoseScheduleRepository] %% 추가
        P[LocalDraftRepository] %% 추가
        Q[DosagePlanDto]
        R[DoseScheduleDto] %% 추가
    end

    A --> D
    A --> C
    D --> E
    E --> K
    E --> M
    E --> L
    E --> I
    E --> J
    I --> N
    J --> O
    L --> J
    M --> H
    L --> H
```

---

## 7. 수정 우선순위

### P0 (즉시 수정 필수):
1. RecalculateDoseScheduleUseCase 추가
2. DoseScheduleRepository 의존성 추가
3. UpdateDosagePlanUseCase에 스케줄 재계산 로직 통합

### P1 (주요 기능):
4. AnalyzePlanChangeImpactUseCase 추가
5. 변경사항 없음 감지 로직
6. 트랜잭션 처리 명확화

### P2 (사용성 개선):
7. 네트워크 오류 재시도 로직
8. 과거 시작일 경고
9. 증량 계획 안전성 경고

---

## 8. 테스트 커버리지 보완

### 추가 필요 테스트:

**RecalculateDoseScheduleUseCase**:
- TC-1: 주기 변경 시 스케줄 재계산
- TC-2: 증량 계획 반영 확인
- TC-3: 1초 이내 완료 (성능)
- TC-4: 과거 기록 보존 확인

**UpdateDosagePlanUseCase**:
- TC-3: 변경사항 없을 때 조기 복귀
- TC-4: 스케줄 재계산 실패 시 롤백
- TC-5: 네트워크 오류 시 로컬 저장

**DosagePlanNotifier**:
- TC-3: 재시도 로직 동작 확인
- TC-4: 최대 재시도 횟수 초과 처리

**EditDosagePlanScreen**:
- TC-3: 영향 분석 다이얼로그 표시
- TC-4: 재시도 버튼 동작

---

## 9. QA Sheet 보완

**추가 항목**:
- [ ] 변경사항 없이 저장 시 즉시 복귀 확인
- [ ] 영향 분석 다이얼로그 표시 확인
- [ ] 스케줄 재계산 1초 이내 완료 확인
- [ ] 미래 스케줄 삭제 확인
- [ ] 새 스케줄 생성 확인
- [ ] 증량 계획 반영 확인
- [ ] 과거 기록 보존 확인
- [ ] 트랜잭션 실패 시 롤백 확인
- [ ] 네트워크 오류 시 재시도 옵션 표시
- [ ] 자동 재시도 (최대 3회) 동작 확인

---

## 10. 결론

**현재 plan.md는 spec.md의 핵심 요구사항을 누락하고 있습니다.**

특히:
1. **투여 스케줄 재계산 로직 전체 누락** (치명적)
2. **DoseScheduleRepository 의존성 누락** (치명적)
3. **영향 분석 및 확인 프로세스 누락** (주요)
4. **네트워크 오류 처리 미흡** (주요)

**권장 조치**:
1. RecalculateDoseScheduleUseCase 모듈 추가
2. DoseScheduleRepository 인터페이스 및 구현체 추가
3. UpdateDosagePlanUseCase 역할 재정의
4. 누락된 테스트 시나리오 추가
5. QA Sheet 보완

**재검토 필요**:
- plan.md 전체 리팩토링 후 재검증 필요
- TDD Workflow에 스케줄 재계산 추가
- Architecture Diagram 업데이트

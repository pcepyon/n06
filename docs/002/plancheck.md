# UF-F000: 온보딩 및 목표 설정 - Plan 검증 보고서

## 검증 일시
2025-11-07

## 검증 결과: 수정 필요

---

## 1. 누락된 엔티티 및 비즈니스 로직

### 1.1 User 엔티티 누락
**문제점**:
- spec.md에서는 `users` 테이블 업데이트를 명시함 (line 190: "users 업데이트(필요 시 이름 갱신)")
- plan.md에는 User Entity 및 UserRepository가 정의되지 않음
- UserProfile과 User의 관계가 불명확함

**수정 방안**:
```
Domain Layer에 추가:
- User Entity (lib/features/onboarding/domain/entities/user.dart)
  - id: String (소셜 로그인에서 받은 userId)
  - name: String (온보딩에서 입력받은 이름)
  - createdAt: DateTime

- UserRepository Interface (lib/features/onboarding/domain/repositories/user_repository.dart)
  - updateUserName(userId, name): Future<void>

Infrastructure Layer에 추가:
- UserDto (lib/features/onboarding/infrastructure/dtos/user_dto.dart)
- IsarUserRepository (lib/features/onboarding/infrastructure/repositories/isar_user_repository.dart)

Application Layer 수정:
- OnboardingNotifier에서 UserRepository.updateUserName() 호출 추가
```

### 1.2 투여 스케줄 생성 로직 누락
**문제점**:
- spec.md line 68: "시스템이 투여 스케줄 생성 트리거(F001 연동)"
- spec.md line 196-198: "투여 스케줄 생성 트리거", "dose_schedules 삽입"
- plan.md에는 투여 스케줄 생성 로직이 전혀 없음

**수정 방안**:
```
Domain Layer에 추가:
- DoseSchedule Entity (lib/features/onboarding/domain/entities/dose_schedule.dart)
  - userId: String
  - dosagePlanId: String
  - scheduledDate: DateTime
  - doseMg: double
  - status: ScheduleStatus (예정/완료/지연)

- ScheduleRepository Interface (lib/features/onboarding/domain/repositories/schedule_repository.dart)
  - generateSchedulesFromPlan(dosagePlan): Future<List<DoseSchedule>>

- GenerateDoseSchedulesUseCase (lib/features/onboarding/domain/usecases/generate_dose_schedules_usecase.dart)
  - execute(DosagePlan): List<DoseSchedule>
  - 로직: startDate, cycleDays, escalationPlan을 기반으로 향후 N일간의 스케줄 생성

Infrastructure Layer에 추가:
- DoseScheduleDto
- IsarScheduleRepository

Application Layer 수정:
- OnboardingNotifier.saveOnboardingData()에서 스케줄 생성 로직 추가:
  1. DosagePlan 저장
  2. GenerateDoseSchedulesUseCase 실행
  3. ScheduleRepository.save() 호출
```

---

## 2. 데이터 저장 트랜잭션 로직 불명확

### 2.1 원자적 트랜잭션 구현 미정의
**문제점**:
- spec.md line 63, 95: "Repository 패턴을 통해 모든 데이터 저장", "트랜잭션을 구현하여 전체 저장 또는 저장 없음을 보장"
- spec.md line 189-198: 명시적 트랜잭션 시퀀스
- plan.md section 3.3.2 OnboardingNotifier Test 3: "트랜잭션 롤백 (모두 저장 안 됨)"
- **하지만** 실제 구현 방법이 정의되지 않음

**수정 방안**:
```
Infrastructure Layer에 추가:
- TransactionService (lib/features/onboarding/infrastructure/services/transaction_service.dart)
  - executeInTransaction<T>(Future<T> Function() operation): Future<T>
  - 내부적으로 Isar.writeTxn() 사용

Application Layer 수정:
- OnboardingNotifier.saveOnboardingData() 구조:
  ```dart
  Future<void> saveOnboardingData() async {
    try {
      await transactionService.executeInTransaction(() async {
        // 1. User 이름 업데이트
        await userRepository.updateUserName(userId, name);

        // 2. UserProfile 저장
        await profileRepository.save(userProfile);

        // 3. DosagePlan 저장
        await medicationRepository.save(dosagePlan);

        // 4. 초기 WeightLog 저장
        await trackingRepository.save(initialWeightLog);

        // 5. DoseSchedule 생성 및 저장
        final schedules = generateDoseSchedulesUseCase.execute(dosagePlan);
        await scheduleRepository.saveAll(schedules);
      });

      state = AsyncValue.data(void);
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }
  ```

Test Scenario 수정:
- "트랜잭션 중 한 단계라도 실패 시 전체 롤백" 시나리오 추가
```

---

## 3. 검증 로직 불일치

### 3.1 검증 위치의 모순
**문제점**:
- spec.md에서는 백엔드 검증을 명시 (line 159-162, 177-178)
- plan.md에서는 ValidationService를 Application Layer에 배치
- **하지만** 검증은 Domain Layer의 책임임

**수정 방안**:
```
Domain Layer로 이동:
- ValidationService → ValueObjectValidation으로 변경
  - 위치: lib/features/onboarding/domain/value_objects/
  - Weight Value Object:
    - Weight.create(double kg): Result<Weight, ValidationError>
    - 검증: 20 <= kg <= 300
  - MedicationName Value Object:
    - MedicationName.create(String name): Result<MedicationName, ValidationError>
    - 검증: 비어있지 않음
  - StartDate Value Object:
    - StartDate.create(DateTime date): Result<StartDate, ValidationError>
    - 검증: 7일 이상 과거 아님

Entity 수정:
- UserProfile, DosagePlan에서 Value Object 사용
  ```dart
  class UserProfile {
    final Weight currentWeight;
    final Weight targetWeight;
    // ...
  }
  ```

Application Layer:
- ValidationService 제거
- Value Object의 create() 메서드 사용
```

### 3.2 주간 감량 목표 계산 위치 모순
**문제점**:
- spec.md line 32-34, 161-162: "시스템이 주간 감량 목표 자동 계산", "백엔드에서 계산"
- plan.md section 3.1.5: CalculateWeeklyGoalUseCase (Domain Layer)
- **하지만** spec.md line 118-119에서는 클라이언트 계산을 암시

**명확화 필요**:
```
계산 위치 확정:
- Domain Layer: CalculateWeeklyGoalUseCase 유지 (올바름)
- Application Layer: OnboardingNotifier에서 호출
- Presentation Layer: WeightGoalForm에서 실시간 계산 결과 표시

Test Scenario 추가:
- WeightGoalForm Widget Test:
  - 사용자가 목표 기간 입력 시 UseCase 호출 확인
  - 계산 결과 UI 업데이트 확인
```

---

## 4. 시퀀스 다이어그램과 구현 불일치

### 4.1 프론트엔드/백엔드 분리 모호
**문제점**:
- spec.md의 Sequence Diagram은 FE ↔ BE 분리를 가정
- plan.md는 모바일 앱 단일 구조 (Phase 0: Isar 로컬)
- **모순**: spec.md line 159 "FE -> BE: 체중 입력 검증"은 Phase 0에서 불필요

**수정 방안**:
```
Phase 0 (Isar 로컬) 기준으로 재설계:
- Application Layer에서 모든 검증 및 계산 수행
- Infrastructure Layer는 Isar 저장만 담당
- Sequence Diagram 수정:
  - FE, BE 구분 제거
  - Presentation → Application → Domain ← Infrastructure 흐름으로 단순화

Phase 1 전환 시:
- Application Layer 변경 없음
- Infrastructure Layer만 Supabase Repository로 교체
- 이때 백엔드 검증 추가 가능 (선택적)
```

### 4.2 온보딩 상태 확인 로직 누락
**문제점**:
- spec.md line 142-145: "온보딩 상태 확인 → user_profiles 조회"
- plan.md에는 온보딩 완료 여부 확인 로직이 없음

**수정 방안**:
```
Domain Layer에 추가:
- CheckOnboardingStatusUseCase
  - execute(userId): Future<bool>
  - 로직: ProfileRepository에서 userId로 프로필 존재 여부 확인

Application Layer에 추가:
- OnboardingStatusNotifier
  - checkStatus(userId): Future<bool>
  - 결과에 따라 온보딩/홈 화면 분기

Presentation Layer:
- AppRouter에서 OnboardingStatusNotifier 사용
  - 로그인 성공 → checkStatus() → 온보딩 필요 시 OnboardingScreen
```

---

## 5. 비즈니스 룰 구현 누락

### 5.1 BR-2: 시작일 과거 7일 제한
**문제점**:
- spec.md line 106: "시작일은 과거 7일 이내여야 함"
- plan.md section 3.1.2 Test 5: "7일 이상 과거인 경우 경고 (허용)"
- **모순**: 제한인지 경고인지 불명확

**명확화 필요**:
```
Business Rule 확정:
- 시작일이 7일 이상 과거인 경우 → 경고 표시, 진행 허용
- 시작일이 30일 이상 과거인 경우 → 에러, 진행 차단

Domain Layer:
- StartDate Value Object에서 구현
  ```dart
  enum StartDateValidation {
    valid,
    warning,  // 7~29일 과거
    error,    // 30일 이상 과거
  }
  ```

Test Scenario 추가:
- 7~29일 과거: warning 반환, 진행 허용
- 30일 이상 과거: error 반환, 진행 차단
```

### 5.2 BR-6: 주간 기록 목표 기본값 적용 시점
**문제점**:
- spec.md line 128-130: "기본 주간 체중 기록 목표: 7회, 증상 기록 목표: 7회"
- plan.md section 3.1.1: UserProfile에 필드는 있으나 기본값 로직 없음

**수정 방안**:
```
Domain Layer:
- UserProfile Entity 수정
  ```dart
  class UserProfile {
    final int weeklyWeightRecordGoal;
    final int weeklySymptomRecordGoal;

    UserProfile({
      // ...
      this.weeklyWeightRecordGoal = 7,  // 기본값
      this.weeklySymptomRecordGoal = 7, // 기본값
    });
  }
  ```

Test Scenario:
- "기본값 미지정 시 7로 설정" (plan.md line 106-108에 이미 존재, 유지)
```

---

## 6. Edge Case 처리 불충분

### 6.1 저장 실패 후 재시도 로직
**문제점**:
- spec.md line 91, 93-95: "재시도 허용"
- plan.md에는 재시도 로직이 없음

**수정 방안**:
```
Application Layer:
- OnboardingNotifier에 재시도 메서드 추가
  ```dart
  Future<void> retrySave() async {
    if (state.hasError) {
      await saveOnboardingData();
    }
  }
  ```

Presentation Layer:
- SummaryScreen에서 에러 시 재시도 버튼 표시
  ```dart
  if (state.hasError) {
    ElevatedButton(
      onPressed: () => ref.read(onboardingNotifierProvider.notifier).retrySave(),
      child: Text('재시도'),
    )
  }
  ```

Test Scenario 추가:
- "저장 실패 후 재시도 시 정상 저장" (Application Layer)
- "재시도 버튼 클릭 시 saveOnboardingData() 재호출" (Presentation Layer)
```

### 6.2 세션 중단 시 임시 저장
**문제점**:
- spec.md line 90: "온보딩 중 앱 종료: 데이터가 저장되지 않음, 다음 실행 시 온보딩 재시작"
- **UX 문제**: 사용자가 많은 정보를 입력한 후 앱 종료 시 모두 손실

**수정 방안 (선택적)**:
```
Application Layer:
- DraftOnboardingNotifier 추가
  - saveDraft(): 입력 중인 데이터를 Isar에 임시 저장
  - loadDraft(): 앱 재실행 시 임시 데이터 복원
  - clearDraft(): 온보딩 완료 시 임시 데이터 삭제

Presentation Layer:
- OnboardingScreen에서 각 단계 이동 시 saveDraft() 자동 호출
- 앱 재실행 시 loadDraft() → 데이터 있으면 복원 옵션 제시

참고: 이는 MVP 범위를 벗어날 수 있으므로 우선순위 하향 고려
```

---

## 7. 테스트 전략 개선 사항

### 7.1 Integration Test 범위 불명확
**문제점**:
- plan.md section 3.2: "Integration (Isar 의존)"
- **하지만** Isar를 실제로 사용할지, Mock을 사용할지 불명확

**명확화 필요**:
```
Test Strategy 수정:
- Infrastructure Layer:
  - Unit Test: DTO 변환 로직만 (Isar 없이 가능)
    - toEntity(), fromEntity() 테스트
  - Integration Test: Repository 구현 (실제 Isar 사용)
    - Isar.initializeIsarCore() 호출
    - 테스트용 Isar 인스턴스 생성
    - save/get/update/delete 테스트

파일 분리:
- test/features/onboarding/infrastructure/dtos/ (Unit)
- test/features/onboarding/infrastructure/repositories/ (Integration)
```

### 7.2 Acceptance Test 시나리오 불충분
**문제점**:
- plan.md section 3.4: Widget Test만 정의
- E2E 시나리오가 Phase 5에만 언급되고 구체적 내용 없음

**수정 방안**:
```
Phase 5: End-to-End Integration Test 시나리오 추가:
1. 전체 온보딩 플로우
   - Given: 신규 사용자가 소셜 로그인 완료
   - When: 온보딩 4단계 모두 입력 후 확인
   - Then:
     - Isar에 UserProfile, DosagePlan, WeightLog, DoseSchedule 저장됨
     - 홈 대시보드로 이동
     - 대시보드에 초기 데이터 표시됨

2. 저장 실패 및 재시도
   - Given: 온보딩 마지막 단계
   - When: Isar 저장 실패 시뮬레이션
   - Then: 에러 메시지 표시 → 재시도 성공 → 홈 이동

3. 경고 무시하고 진행
   - Given: 주간 감량 목표 1.5kg 입력
   - When: 경고 무시하고 진행
   - Then: 정상 저장, 목표는 1.5kg로 저장됨

파일:
- integration_test/onboarding_e2e_test.dart
```

---

## 8. 아키텍처 다이어그램 수정 필요

### 8.1 누락된 컴포넌트
**수정 방안**:
```mermaid
graph TB
    subgraph Presentation
        OnboardingScreen[OnboardingScreen]
        BasicProfileForm[BasicProfileForm Widget]
        WeightGoalForm[WeightGoalForm Widget]
        DosagePlanForm[DosagePlanForm Widget]
        SummaryScreen[SummaryScreen Widget]
    end

    subgraph Application
        OnboardingNotifier[OnboardingNotifier]
        OnboardingStatusNotifier[OnboardingStatusNotifier]  %% 추가
        TransactionService[TransactionService]  %% 추가
    end

    subgraph Domain
        User[User Entity]  %% 추가
        UserProfile[UserProfile Entity]
        DosagePlan[DosagePlan Entity]
        WeightLog[WeightLog Entity]
        DoseSchedule[DoseSchedule Entity]  %% 추가

        Weight[Weight Value Object]  %% 추가
        MedicationName[MedicationName Value Object]  %% 추가
        StartDate[StartDate Value Object]  %% 추가

        UserRepository[UserRepository Interface]  %% 추가
        ProfileRepository[ProfileRepository Interface]
        MedicationRepository[MedicationRepository Interface]
        TrackingRepository[TrackingRepository Interface]
        ScheduleRepository[ScheduleRepository Interface]  %% 추가

        CalculateWeeklyGoalUseCase[CalculateWeeklyGoalUseCase]
        ValidateDosagePlanUseCase[ValidateDosagePlanUseCase]
        GenerateDoseSchedulesUseCase[GenerateDoseSchedulesUseCase]  %% 추가
        CheckOnboardingStatusUseCase[CheckOnboardingStatusUseCase]  %% 추가
    end

    subgraph Infrastructure
        IsarUserRepository[IsarUserRepository]  %% 추가
        IsarProfileRepository[IsarProfileRepository]
        IsarMedicationRepository[IsarMedicationRepository]
        IsarTrackingRepository[IsarTrackingRepository]
        IsarScheduleRepository[IsarScheduleRepository]  %% 추가

        UserDto[UserDto]  %% 추가
        UserProfileDto[UserProfileDto]
        DosagePlanDto[DosagePlanDto]
        WeightLogDto[WeightLogDto]
        DoseScheduleDto[DoseScheduleDto]  %% 추가
    end

    OnboardingScreen --> OnboardingNotifier
    OnboardingScreen --> OnboardingStatusNotifier  %% 추가

    OnboardingNotifier --> TransactionService  %% 추가
    OnboardingNotifier --> CalculateWeeklyGoalUseCase
    OnboardingNotifier --> ValidateDosagePlanUseCase
    OnboardingNotifier --> GenerateDoseSchedulesUseCase  %% 추가
    OnboardingNotifier --> UserRepository  %% 추가
    OnboardingNotifier --> ProfileRepository
    OnboardingNotifier --> MedicationRepository
    OnboardingNotifier --> TrackingRepository
    OnboardingNotifier --> ScheduleRepository  %% 추가

    OnboardingStatusNotifier --> CheckOnboardingStatusUseCase  %% 추가
    CheckOnboardingStatusUseCase --> ProfileRepository  %% 추가

    UserProfile --> Weight  %% 추가
    DosagePlan --> MedicationName  %% 추가
    DosagePlan --> StartDate  %% 추가

    UserRepository -.implements.-> IsarUserRepository  %% 추가
    ProfileRepository -.implements.-> IsarProfileRepository
    MedicationRepository -.implements.-> IsarMedicationRepository
    TrackingRepository -.implements.-> IsarTrackingRepository
    ScheduleRepository -.implements.-> IsarScheduleRepository  %% 추가

    TransactionService --> IsarInstance[Isar Instance]  %% 추가

    IsarUserRepository --> UserDto  %% 추가
    IsarProfileRepository --> UserProfileDto
    IsarMedicationRepository --> DosagePlanDto
    IsarTrackingRepository --> WeightLogDto
    IsarScheduleRepository --> DoseScheduleDto  %% 추가

    UserDto -.toEntity.-> User  %% 추가
    UserProfileDto -.toEntity.-> UserProfile
    DosagePlanDto -.toEntity.-> DosagePlan
    WeightLogDto -.toEntity.-> WeightLog
    DoseScheduleDto -.toEntity.-> DoseSchedule  %% 추가
```

---

## 9. 우선순위별 수정 계획

### P0 (Critical - MVP 필수)
1. User Entity 및 Repository 추가
2. DoseSchedule 생성 로직 추가
3. 트랜잭션 구현 명확화
4. 온보딩 상태 확인 로직 추가
5. 검증 로직을 Value Object로 Domain Layer 이동

### P1 (High - 기능 완성도)
6. 재시도 로직 구현
7. Integration Test 전략 명확화
8. E2E Test 시나리오 작성
9. Business Rule 모순 해결 (시작일 제한)

### P2 (Medium - UX 개선)
10. 세션 중단 시 임시 저장 (선택적)
11. Sequence Diagram Phase 0 기준 재작성
12. QA Sheet 구체화

---

## 10. 다음 단계

### 즉시 수정
1. plan.md에 P0 항목 반영
2. 아키텍처 다이어그램 업데이트
3. TDD Workflow에 누락된 컴포넌트 추가

### 구현 전 검증
1. 수정된 plan.md를 spec.md와 재대조
2. CLAUDE.md의 Layer Dependency 룰 준수 확인
3. Repository Pattern 유지 확인

### 구현 시작
1. P0 항목부터 TDD 사이클 시작
2. Domain Layer → Infrastructure Layer → Application Layer → Presentation Layer 순서 유지
3. 각 Phase 완료 후 Commit Point 준수

---

## 요약

**총 발견 이슈**: 10개 카테고리, 20+ 개별 항목
**Critical 이슈**: 5개 (P0)
**설계 완성도**: 60% (누락된 핵심 컴포넌트 다수)

**권장 사항**:
- P0 항목을 모두 반영한 후 구현 시작
- 특히 트랜잭션 로직과 스케줄 생성은 MVP 핵심 기능이므로 최우선 수정 필요
- Value Object 패턴 도입으로 Domain Layer 순수성 확보

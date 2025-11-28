---
id: state-management
keywords: [riverpod, provider, notifier, asyncvalue, state, watch, read, ref]
read_when: Provider 타입, Notifier 패턴, 상태 관리, AsyncValue 사용 시
related: [code-structure, tdd]
---

# State Management Design (Flutter/Riverpod)

> GLP-1 치료 관리 MVP의 상태 관리 설계. Riverpod 3.x Code Generation + 4-Layer Architecture + Repository Pattern.

---

## 1. State Inventory

| Category | State | Type | Feature | Description |
|----------|-------|------|---------|-------------|
| **Domain** | User | `User` | Auth | 사용자 계정 정보 |
| **Domain** | UserProfile | `UserProfile` | F000 | 목표 체중, 주간 목표 설정 |
| **Domain** | DosagePlan | `DosagePlan` | F001 | 투여 계획 |
| **Domain** | DoseSchedule | `List<DoseSchedule>` | F001 | 투여 스케줄 목록 |
| **Domain** | DoseRecord | `List<DoseRecord>` | F001 | 투여 완료 기록 |
| **Domain** | WeightLog | `List<WeightLog>` | F002 | 체중 기록 |
| **Domain** | SymptomLog | `List<SymptomLog>` | F002 | 증상 기록 |
| **Domain** | EmergencySymptomCheck | `List<EmergencySymptomCheck>` | F005 | 심각 증상 체크 기록 |
| **Domain** | BadgeDefinition | `List<BadgeDefinition>` | F006 | 뱃지 정의 (정적) |
| **Domain** | UserBadge | `List<UserBadge>` | F006 | 사용자 뱃지 획득 현황 |
| **Domain** | CopingGuide | `CopingGuide` | F004 | 증상별 대처 가이드 (정적) |
| **Domain** | NotificationSettings | `NotificationSettings` | UF-012 | 알림 시간 및 활성화 설정 |
| **Domain** | AuditLog | `List<AuditLog>` | UF-011 | 기록 수정 이력 |
| **UI** | AuthState | `AsyncValue<User?>` | Auth | 인증 상태 (keepAlive) |
| **UI** | OnboardingState | `AsyncValue<void>` | F000 | 온보딩 완료 상태 |
| **UI** | MedicationState | `AsyncValue<MedicationState>` | F001 | 투여 관련 통합 상태 |
| **UI** | TrackingState | `AsyncValue<TrackingState>` | F002 | 체중/증상 기록 통합 상태 |
| **UI** | DashboardData | `AsyncValue<DashboardData>` | F006 | 대시보드 통합 상태 |
| **UI** | DataSharingState | `DataSharingState` | F003 | 데이터 공유 모드 상태 |
| **UI** | CopingGuideState | `AsyncValue<CopingGuideState>` | F004 | 대처 가이드 상태 |
| **UI** | ProfileState | `AsyncValue<UserProfile?>` | UF-008 | 프로필 상태 |
| **Form** | WeightRecordEdit | `AsyncValue<void>` | UF-011 | 체중 기록 편집 상태 |
| **Form** | SymptomRecordEdit | `AsyncValue<void>` | UF-011 | 증상 기록 편집 상태 |
| **Form** | DoseRecordEdit | `AsyncValue<void>` | UF-011 | 투여 기록 편집 상태 |

---

## 2. State Transitions

| Current State | Trigger | Next State | UI Impact |
|---------------|---------|------------|-----------|
| `AsyncValue.loading()` | 로그인 성공 | `AsyncValue.data(User)` | 홈 대시보드 진입 |
| `AsyncValue.data(User)` | 로그아웃 | `AsyncValue.data(null)` | 로그인 화면 전환 |
| `AsyncValue.loading()` | 온보딩 완료 | `AsyncValue.data(void)` | 투여 계획 생성, 홈 진입 |
| `AsyncValue.data(state)` | 투여 기록 추가 | `AsyncValue.loading() → data` | 리스트 갱신, 달성률 업데이트 |
| `AsyncValue.data(state)` | 체중 기록 추가 | `AsyncValue.loading() → data` | 차트 갱신, 대시보드 리렌더링 |
| `AsyncValue.data(state)` | 증상 기록 추가 | `AsyncValue.loading() → data` | 가이드 표시 자동 |
| `DataSharingState(isActive: false)` | 공유 모드 활성화 | `DataSharingState(isActive: true)` | 읽기 전용 UI 전환 |
| `DataSharingState(isActive: true)` | 공유 모드 종료 | `DataSharingState(isActive: false)` | 일반 화면 복귀 |
| `AsyncValue.data(plan)` | 투여 계획 수정 | `AsyncValue.loading() → data` | 스케줄 재계산, 대시보드 갱신 |
| `AsyncValue.data(profile)` | 프로필 수정 | `AsyncValue.loading() → data` | 목표 재계산, 대시보드 갱신 |
| `AsyncValue.data(record)` | 기록 삭제 | `AsyncValue.loading() → data` | 목록 갱신, 통계 재계산 |

---

## 3. Provider Architecture

### Core Providers (keepAlive: true)

```dart
// core/providers.dart
@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref);  // 글로벌 Supabase 클라이언트

// authentication/application/notifiers/auth_notifier.dart
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier;  // 글로벌 인증 상태
```

### Repository Providers (feature별)

**Tracking Feature:**
```dart
@riverpod MedicationRepository medicationRepository(ref);
@riverpod DosagePlanRepository dosagePlanRepository(ref);
@riverpod DoseScheduleRepository doseScheduleRepository(ref);
@riverpod TrackingRepository trackingRepository(ref);
@riverpod EmergencyCheckRepository emergencyCheckRepository(ref);
@riverpod AuditRepository auditRepository(ref);
```

**Other Features:**
```dart
@riverpod AuthRepository authRepository(ref);
@riverpod ProfileRepository profileRepository(ref);
@riverpod BadgeRepository badgeRepository(ref);
@riverpod NotificationRepository notificationRepository(ref);
@riverpod CopingGuideRepository copingGuideRepository(ref);
@riverpod SharedDataRepository sharedDataRepository(ref);
```

### UseCase Providers

**Schedule Management:**
```dart
@riverpod ScheduleGeneratorUseCase scheduleGeneratorUseCase(ref);
@riverpod RecalculateDoseScheduleUseCase recalculateDoseScheduleUseCase(ref);
```

**Dosage Plan Management (UF-009):**
```dart
@riverpod ValidateDosagePlanUseCase validateDosagePlanUseCase(ref);
@riverpod AnalyzePlanChangeImpactUseCase analyzePlanChangeImpactUseCase(ref);
@riverpod UpdateDosagePlanUseCase updateDosagePlanUseCase(ref);
```

**Injection & Dose Analysis:**
```dart
@riverpod InjectionSiteRotationUseCase injectionSiteRotationUseCase(ref);
@riverpod MissedDoseAnalyzerUseCase missedDoseAnalyzerUseCase(ref);
```

### Feature Notifiers

**Code Generation 방식 (@riverpod class):**
```dart
@riverpod class AuthNotifier extends _$AuthNotifier;           // keepAlive: true
@riverpod class OnboardingNotifier extends _$OnboardingNotifier;
@riverpod class MedicationNotifier extends _$MedicationNotifier;
@riverpod class DashboardNotifier extends _$DashboardNotifier;
@riverpod class ProfileNotifier extends _$ProfileNotifier;
@riverpod class NotificationNotifier extends _$NotificationNotifier;
@riverpod class CopingGuideNotifier extends _$CopingGuideNotifier;
@riverpod class DataSharingNotifier extends _$DataSharingNotifier;
@riverpod class EmergencyCheckNotifier extends _$EmergencyCheckNotifier;
```

**수동 정의 방식 (StateNotifierProvider):**
```dart
// TrackingNotifier는 StateNotifier 상속 (수동 Provider 정의 필요)
final trackingNotifierProvider = StateNotifierProvider.autoDispose<
  TrackingNotifier,
  AsyncValue<TrackingState>
>((ref) => TrackingNotifier(
  repository: ref.watch(trackingRepositoryProvider),
  userId: ref.watch(authNotifierProvider).value?.id,
));
```

**UF-011 Record Edit Notifiers (수동 정의):**
```dart
final weightRecordEditNotifierProvider =
    AsyncNotifierProvider<WeightRecordEditNotifier, void>(() => WeightRecordEditNotifier());

final symptomRecordEditNotifierProvider =
    AsyncNotifierProvider<SymptomRecordEditNotifier, void>(() => SymptomRecordEditNotifier());

final doseRecordEditNotifierProvider =
    AsyncNotifierProvider<DoseRecordEditNotifier, void>(() => DoseRecordEditNotifier());
```

---

## 4. State Classes

### Auth Feature

```dart
// domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
}
```

### Onboarding Feature (F000)

```dart
// domain/entities/user_profile.dart
class UserProfile {
  final String userId;
  final String? userName;
  final Weight targetWeight;           // Value Object
  final Weight currentWeight;          // Value Object
  final int? targetPeriodWeeks;
  final double? weeklyLossGoalKg;
  final int weeklyWeightRecordGoal;    // 기본값: 7
  final int weeklySymptomRecordGoal;   // 기본값: 7
}

// domain/entities/dosage_plan.dart
class DosagePlan {
  final String id;
  final String userId;
  final String medicationName;
  final DateTime startDate;
  final int cycleDays;
  final double initialDoseMg;
  final List<EscalationStep>? escalationPlan;
  final bool isActive;
}
```

### Medication Feature (F001)

```dart
// application/notifiers/medication_notifier.dart
class MedicationState {
  final DosagePlan? activePlan;        // 직접 타입 (AsyncValue 아님)
  final List<DoseSchedule> schedules;  // 직접 타입
  final List<DoseRecord> records;      // 직접 타입

  const MedicationState({
    this.activePlan,
    required this.schedules,
    required this.records,
  });
}

// AsyncNotifier의 state가 AsyncValue<MedicationState>를 관리
@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  @override
  Future<MedicationState> build() async {
    // AsyncValue.data(MedicationState(...)) 형태로 저장됨
  }
}
```

### Tracking Feature (F002)

```dart
// application/notifiers/tracking_notifier.dart
class TrackingState {
  final AsyncValue<List<WeightLog>> weights;   // AsyncValue 유지
  final AsyncValue<List<SymptomLog>> symptoms; // AsyncValue 유지

  const TrackingState({
    required this.weights,
    required this.symptoms,
  });
}

// StateNotifier 방식 (수동 정의)
class TrackingNotifier extends StateNotifier<AsyncValue<TrackingState>> {
  TrackingNotifier({
    required TrackingRepository repository,
    String? userId,
  }) : super(const AsyncValue.loading()) {
    _init();
  }
}
```

### Dashboard Feature (F006)

```dart
// domain/entities/dashboard_data.dart
class DashboardData {
  final String userName;
  final int continuousRecordDays;
  final int currentWeek;
  final WeeklyProgress weeklyProgress;
  final NextSchedule nextSchedule;
  final WeeklySummary weeklySummary;
  final List<UserBadge> badges;
  final List<TimelineEvent> timeline;
  final String? insightMessage;
}

class WeeklyProgress {
  final int doseCompletedCount;
  final int doseTargetCount;
  final double doseRate;         // 0.0 ~ 1.0
  final int weightRecordCount;
  final int weightTargetCount;
  final double weightRate;
  final int symptomRecordCount;
  final int symptomTargetCount;
  final double symptomRate;
}
```

### Notification Feature (UF-012)

```dart
// domain/entities/notification_settings.dart
class NotificationSettings {
  final String userId;
  final NotificationTime notificationTime;
  final bool notificationEnabled;
}

// domain/value_objects/notification_time.dart
class NotificationTime {
  final int hour;    // 0-23
  final int minute;  // 0-59
}
```

### Coping Guide Feature (F004)

```dart
// domain/entities/coping_guide.dart
class CopingGuide {
  final String symptomName;
  final String shortGuide;
  final List<GuideSection>? detailedGuide;
}

// domain/entities/coping_guide_state.dart
class CopingGuideState {
  final CopingGuide guide;
  final bool showSeverityWarning;  // 심각도 7-10점 & 24h 지속 시 true
}
```

### Data Sharing Feature (F003)

```dart
// application/notifiers/data_sharing_notifier.dart
class DataSharingState {
  final bool isActive;
  final DateRange? selectedPeriod;
  final SharedDataReport? report;  // 리포트 데이터
  final String? error;             // 에러 메시지
  final bool isLoading;            // 로딩 상태
}
```

### Emergency Feature (F005)

```dart
// domain/entities/emergency_symptom_check.dart
class EmergencySymptomCheck {
  final String id;
  final String userId;
  final DateTime checkedAt;
  final List<String> checkedSymptoms;  // 선택된 심각 증상 목록
}
```

---

## 5. Provider Signatures (실제 구현)

### Global Providers

```dart
// core/providers.dart
@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref) {
  throw UnimplementedError('Override in main.dart');
}
```

### Auth Feature

```dart
// authentication/application/providers.dart
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  throw UnimplementedError('Override in main.dart');
}

@riverpod
SecureStorageRepository secureStorageRepository(SecureStorageRepositoryRef ref);

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref);

// authentication/application/notifiers/auth_notifier.dart
@Riverpod(keepAlive: true)  // 글로벌 인증 상태이므로 keepAlive 필수
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build();
  Future<bool> loginWithKakao({required bool agreedToTerms, required bool agreedToPrivacy});
  Future<bool> loginWithNaver({required bool agreedToTerms, required bool agreedToPrivacy});
  Future<void> logout();
  Future<bool> ensureValidToken();
}
```

### Onboarding Feature (F000)

```dart
// onboarding/application/providers.dart
@riverpod
UserRepository userRepository(UserRepositoryRef ref);

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref);

@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref);

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref);

@riverpod
TransactionService transactionService(TransactionServiceRef ref);

@riverpod
CheckOnboardingStatusUseCase checkOnboardingStatusUseCase(CheckOnboardingStatusUseCaseRef ref);

// onboarding/application/notifiers/onboarding_notifier.dart
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<void> build();

  Future<void> saveOnboardingData({
    required String userId,
    required String name,
    required double currentWeight,
    required double targetWeight,
    int? targetPeriodWeeks,
    required String medicationName,
    required DateTime startDate,
    required int cycleDays,
    required double initialDose,
    List<EscalationStep>? escalationPlan,
  });

  Future<void> retrySave({...});
}
```

### Medication Feature (F001)

```dart
// tracking/application/providers.dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref);

@riverpod
DosagePlanRepository dosagePlanRepository(DosagePlanRepositoryRef ref);

@riverpod
DoseScheduleRepository doseScheduleRepository(DoseScheduleRepositoryRef ref);

@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref);

@riverpod
EmergencyCheckRepository emergencyCheckRepository(EmergencyCheckRepositoryRef ref);

@riverpod
AuditRepository auditRepository(AuditRepositoryRef ref);

// UseCase Providers
@riverpod
ScheduleGeneratorUseCase scheduleGeneratorUseCase(ScheduleGeneratorUseCaseRef ref);

@riverpod
InjectionSiteRotationUseCase injectionSiteRotationUseCase(InjectionSiteRotationUseCaseRef ref);

@riverpod
MissedDoseAnalyzerUseCase missedDoseAnalyzerUseCase(MissedDoseAnalyzerUseCaseRef ref);

@riverpod
ValidateDosagePlanUseCase validateDosagePlanUseCase(ValidateDosagePlanUseCaseRef ref);

@riverpod
RecalculateDoseScheduleUseCase recalculateDoseScheduleUseCase(RecalculateDoseScheduleUseCaseRef ref);

@riverpod
AnalyzePlanChangeImpactUseCase analyzePlanChangeImpactUseCase(AnalyzePlanChangeImpactUseCaseRef ref);

@riverpod
UpdateDosagePlanUseCase updateDosagePlanUseCase(UpdateDosagePlanUseCaseRef ref);

@riverpod
NotificationService notificationService(NotificationServiceRef ref);

// tracking/application/notifiers/medication_notifier.dart
@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  @override
  Future<MedicationState> build();

  Future<RotationCheckResult?> recordDose(DoseRecord record);
  Future<void> updateDosagePlan(DosagePlan newPlan);
  MissedDoseAnalysisResult? getMissedDoseAnalysis();
  Future<void> deleteDoseRecord(String recordId);
  Future<List<dynamic>> getPlanHistory();
  Future<RotationCheckResult> checkInjectionSiteRotation(String newSite);
}
```

### Tracking Feature (F002)

```dart
// tracking/application/providers.dart (수동 정의)
final trackingNotifierProvider = StateNotifierProvider.autoDispose<
  TrackingNotifier,
  AsyncValue<TrackingState>
>((ref) {
  final repository = ref.watch(trackingRepositoryProvider);
  final userId = ref.watch(authNotifierProvider).value?.id;
  return TrackingNotifier(repository: repository, userId: userId);
});

// tracking/application/notifiers/tracking_notifier.dart
class TrackingNotifier extends StateNotifier<AsyncValue<TrackingState>> {
  Future<void> saveWeightLog(WeightLog log);
  Future<void> saveSymptomLog(SymptomLog log);
  Future<void> deleteWeightLog(String id);
  Future<void> deleteSymptomLog(String id);
  Future<void> updateWeightLog(String id, double newWeight);
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog);
  Future<bool> hasWeightLogOnDate(String userId, DateTime date);
  Future<WeightLog?> getWeightLog(String userId, DateTime date);
  Future<DateTime?> getLatestDoseEscalationDate(String userId);
}
```

### Dashboard Feature (F006)

```dart
// dashboard/application/providers.dart
@riverpod
BadgeRepository badgeRepository(BadgeRepositoryRef ref);

// dashboard/application/notifiers/dashboard_notifier.dart
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  Future<DashboardData> build();
  Future<void> refresh();
}
```

### Profile Feature (UF-008)

```dart
// profile/application/notifiers/profile_notifier.dart
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build();

  Future<void> loadProfile(String userId);
  Future<void> updateProfile(UserProfile profile);  // UpdateProfileUseCase 사용
  Future<void> updateWeeklyGoals(int weightGoal, int symptomGoal);
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  throw UnimplementedError('Override in main.dart');
}
```

### Notification Feature (UF-012)

```dart
// notification/application/providers.dart
@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref);

@riverpod
NotificationScheduler notificationScheduler(NotificationSchedulerRef ref);

// notification/application/notifiers/notification_notifier.dart
@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<NotificationSettings> build();

  Future<void> updateNotificationTime(NotificationTime newTime);
  Future<void> toggleNotificationEnabled();
}
```

### Coping Guide Feature (F004)

```dart
// coping_guide/application/providers.dart
@riverpod
CopingGuideRepository copingGuideRepository(CopingGuideRepositoryRef ref) {
  return StaticCopingGuideRepository();  // 정적 데이터
}

@riverpod
FeedbackRepository feedbackRepository(FeedbackRepositoryRef ref);

// coping_guide/application/notifiers/coping_guide_notifier.dart
@riverpod
class CopingGuideNotifier extends _$CopingGuideNotifier {
  @override
  Future<CopingGuideState> build();

  Future<void> getGuideBySymptom(String symptomName);
  Future<void> checkSeverityAndGuide(String symptomName, int severity, bool isPersistent24h);
  Future<void> submitFeedback(String symptomName, {required bool helpful});
}

@riverpod
class CopingGuideListNotifier extends _$CopingGuideListNotifier {
  @override
  Future<List<CopingGuide>> build();
  Future<void> loadAllGuides();
}
```

### Data Sharing Feature (F003)

```dart
// data_sharing/application/providers.dart
@riverpod
SharedDataRepository sharedDataRepository(SharedDataRepositoryRef ref);

// data_sharing/application/notifiers/data_sharing_notifier.dart
@riverpod
class DataSharingNotifier extends _$DataSharingNotifier {
  @override
  DataSharingState build();  // 동기 상태 (AsyncNotifier 아님)

  Future<void> enterSharingMode(String userId, DateRange period);
  Future<void> changePeriod(String userId, DateRange period);
  void exitSharingMode();
}
```

### Emergency Feature (F005)

```dart
// tracking/application/providers.dart (수동 정의)
final emergencyCheckNotifierProvider = AsyncNotifierProvider.autoDispose<
  EmergencyCheckNotifier,
  List<EmergencySymptomCheck>
>(() => EmergencyCheckNotifier());

// tracking/application/notifiers/emergency_check_notifier.dart
class EmergencyCheckNotifier extends AutoDisposeAsyncNotifier<List<EmergencySymptomCheck>> {
  @override
  Future<List<EmergencySymptomCheck>> build();
  Future<void> saveSymptomCheck(List<String> symptoms);
}
```

### Record Edit Feature (UF-011)

```dart
// tracking/application/providers.dart (수동 정의)
final weightRecordEditNotifierProvider =
    AsyncNotifierProvider<WeightRecordEditNotifier, void>(() => WeightRecordEditNotifier());

final symptomRecordEditNotifierProvider =
    AsyncNotifierProvider<SymptomRecordEditNotifier, void>(() => SymptomRecordEditNotifier());

final doseRecordEditNotifierProvider =
    AsyncNotifierProvider<DoseRecordEditNotifier, void>(() => DoseRecordEditNotifier());
```

---

## 6. Initial State (빌드 시점 정의)

Riverpod code generation 사용 시, 초기 상태는 각 Notifier의 `build()` 메서드에서 반환됩니다.

```dart
@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  @override
  Future<MedicationState> build() async {
    // 이 반환값이 초기 상태 (AsyncValue.data(MedicationState(...)) 형태로 저장)
    return MedicationState(
      activePlan: null,
      schedules: [],
      records: [],
    );
  }
}

@riverpod
class DataSharingNotifier extends _$DataSharingNotifier {
  @override
  DataSharingState build() {
    // 동기 초기 상태
    return DataSharingState(isActive: false);
  }
}
```

**수동 정의 Provider의 초기 상태:**
```dart
class TrackingNotifier extends StateNotifier<AsyncValue<TrackingState>> {
  TrackingNotifier({...}) : super(const AsyncValue.loading()) {
    // AsyncValue.loading()이 초기 상태
    _init();
  }
}
```

---

## 7. Repository Integration Patterns

### Pattern 1: AsyncNotifier + CRUD (MedicationNotifier)

```dart
@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  MedicationRepository get _repository => ref.read(medicationRepositoryProvider);

  @override
  Future<MedicationState> build() async {
    final userId = ref.watch(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    return await _loadMedicationData(userId);
  }

  Future<MedicationState> _loadMedicationData(String userId) async {
    final plan = await _repository.getActiveDosagePlan(userId);
    final schedules = plan != null
        ? await _repository.getDoseSchedules(plan.id)
        : <DoseSchedule>[];
    final records = plan != null
        ? await _repository.getDoseRecords(plan.id)
        : <DoseRecord>[];

    // MedicationState는 직접 타입 (AsyncValue 없음)
    return MedicationState(
      activePlan: plan,
      schedules: schedules,
      records: records,
    );
  }

  Future<RotationCheckResult?> recordDose(DoseRecord record) async {
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    // ... 비즈니스 로직 ...

    await _repository.saveDoseRecord(record);

    // 상태 재로딩
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _loadMedicationData(userId);
    });

    return rotationResult;
  }
}
```

### Pattern 2: StateNotifier + AsyncValue (TrackingNotifier)

```dart
class TrackingNotifier extends StateNotifier<AsyncValue<TrackingState>> {
  final TrackingRepository _repository;
  final String? _userId;

  TrackingNotifier({
    required TrackingRepository repository,
    String? userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    if (_userId == null) {
      state = const AsyncValue.data(TrackingState(
        weights: AsyncValue.data([]),
        symptoms: AsyncValue.data([]),
      ));
      return;
    }

    final result = await AsyncValue.guard(() async {
      final weights = await _repository.getWeightLogs(_userId);
      final symptoms = await _repository.getSymptomLogs(_userId);

      return TrackingState(
        weights: AsyncValue.data(weights),
        symptoms: AsyncValue.data(symptoms),
      );
    });

    state = result;
  }

  Future<void> saveWeightLog(WeightLog log) async {
    // 저장 전 현재 상태 백업
    final previousState = state.asData?.value ?? const TrackingState(
      weights: AsyncValue.data([]),
      symptoms: AsyncValue.data([]),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveWeightLog(log);

      if (_userId != null) {
        final weights = await _repository.getWeightLogs(_userId);
        return previousState.copyWith(weights: AsyncValue.data(weights));
      }

      return previousState;
    });
  }
}
```

### Pattern 3: Notifier (동기 상태 - DataSharingNotifier)

```dart
@riverpod
class DataSharingNotifier extends _$DataSharingNotifier {
  @override
  DataSharingState build() {
    return DataSharingState(isActive: false);
  }

  Future<void> enterSharingMode(String userId, DateRange period) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(sharedDataRepositoryProvider);
      final report = await repository.getReportData(userId, period);

      state = state.copyWith(
        isActive: true,
        selectedPeriod: period,
        report: report,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void exitSharingMode() {
    state = DataSharingState(isActive: false);
  }
}
```

---

## 8. Repository Interface 예시

### Medication Repository (분리된 구조)

```dart
// domain/repositories/medication_repository.dart
abstract class MedicationRepository {
  Future<DosagePlan?> getActiveDosagePlan(String userId);
  Future<List<DoseSchedule>> getDoseSchedules(String planId);
  Future<List<DoseRecord>> getDoseRecords(String planId);
  Future<void> saveDoseRecord(DoseRecord record);
  Future<void> deleteDoseRecord(String id);
  Future<bool> isDuplicateDoseRecord(String planId, DateTime date);
  Future<List<DoseRecord>> getRecentDoseRecords(String planId, int days);
}

// domain/repositories/dosage_plan_repository.dart
abstract class DosagePlanRepository {
  Future<void> saveDosagePlan(DosagePlan plan);
  Future<void> updateDosagePlan(DosagePlan plan);
  Future<void> savePlanChangeHistory(String planId, Map<String, dynamic> before, Map<String, dynamic> after);
  Future<List<dynamic>> getPlanChangeHistory(String planId);
}

// domain/repositories/dose_schedule_repository.dart
abstract class DoseScheduleRepository {
  Future<void> saveDoseSchedules(List<DoseSchedule> schedules);
  Future<void> deleteDoseSchedulesFrom(String planId, DateTime fromDate);
}
```

### Tracking Repository

```dart
// domain/repositories/tracking_repository.dart
abstract class TrackingRepository {
  Future<List<WeightLog>> getWeightLogs(String userId);
  Future<List<SymptomLog>> getSymptomLogs(String userId);
  Future<void> saveWeightLog(WeightLog log);
  Future<void> saveSymptomLog(SymptomLog log);
  Future<void> deleteWeightLog(String id);
  Future<void> deleteSymptomLog(String id);
  Future<void> updateWeightLog(String id, double newWeight);
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog);
  Future<WeightLog?> getWeightLog(String userId, DateTime date);
  Future<DateTime?> getLatestDoseEscalationDate(String userId);
  Stream<List<WeightLog>> watchWeightLogs(String userId);
  Stream<List<SymptomLog>> watchSymptomLogs(String userId);
}
```

**Repository Pattern 구현:**
- Repository Interface만 의존 (Domain Layer는 변경 없음)
- Infrastructure Layer에서 `SupabaseXxxRepository` 구현
- Provider DI로 의존성 주입

---

## 9. 핵심 원칙

### DO ✅
- **Repository Interface만 의존**, 구현 분리
- **Entity는 Domain, JSON 직렬화 지원** (Layer 분리)
- **비즈니스 로직은 Domain Layer에만** (UseCase 활용)
- **모든 Repository 호출은 Application Layer**에서만
- **비동기 상태는 `AsyncValue<T>` 사용** (loading/error/data 자동 처리)
- **글로벌 상태는 `keepAlive: true` 설정** (supabaseProvider, authNotifierProvider)
- **userId는 authNotifier에서 추출** (하드코딩 금지)
- **Notifier에서 state 접근 시 null 체크** (`asData?.value ?? defaultState`)

### DON'T ❌
- **Application에서 Supabase 직접 사용** (Repository를 통해서만)
- **Presentation에서 Repository 직접 호출** (Notifier를 통해서만)
- **Domain Layer에 Flutter/Supabase 의존성** (순수 Dart만)
- **Provider 의존성 순환** (단방향 의존성 유지)
- **userId 하드코딩** (항상 authNotifier에서 가져오기)
- **autoDispose Provider + async 저장 후 즉시 모달 표시** (Provider 조기 해제 가능)

---

## 10. 실전 예시

### userId 추출 패턴

```dart
// ✅ 올바른 방법
@override
Future<MedicationState> build() async {
  final userId = ref.watch(authNotifierProvider).value?.id;
  if (userId == null) throw Exception('User not authenticated');

  return await _loadMedicationData(userId);
}

// ❌ 잘못된 방법
const userId = 'current-user-id';  // 하드코딩 금지
```

### State 안전한 접근 패턴

```dart
// ✅ 올바른 방법
Future<void> saveWeightLog(WeightLog log) async {
  final previousState = state.asData?.value ?? const TrackingState(
    weights: AsyncValue.data([]),
    symptoms: AsyncValue.data([]),
  );
  // ...
}

// ❌ 잘못된 방법
final previousState = state.asData!.value;  // null 가능성 무시
```

### AutoDispose 모달 표시 패턴

```dart
// ✅ 올바른 방법
await notifier.save(data);
if (!mounted) return;  // 위젯이 dispose되었는지 확인
await showDialog(...);

// ❌ 잘못된 방법
await notifier.save(data);
await showDialog(...);  // Provider가 dispose되어 state 손실 가능
```

### Repository Override (테스트)

```dart
// test/features/tracking/medication_notifier_test.dart
testWidgets('투여 기록 저장', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicationRepositoryProvider.overrideWith(
          (ref) => MockMedicationRepository(),
        ),
      ],
      child: const MaterialApp(home: DoseListScreen()),
    ),
  );

  expect(find.text('0.5 mg'), findsOneWidget);
});
```

---

## 참고 문서

- [Riverpod 공식 문서](https://riverpod.dev)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [docs/external/riverpod_설정가이드.md](./external/riverpod_설정가이드.md) - 상세 설정 방법
- [docs/code_structure.md](./code_structure.md) - 4-Layer Architecture
- [docs/userflow.md](./userflow.md) - Feature별 요구사항

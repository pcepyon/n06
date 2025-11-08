# 008 기능 구현 점검 보고서 (F006 홈 대시보드)

## 최종 상태: 부분 완료

---

## 1. 기능명
F006 홈 대시보드 (Home Dashboard)

---

## 2. 구현 상태 요약

### 상태: 부분 완료 (60% ~ 70%)
- 정의: 핵심 비즈니스 로직은 완성되었으나 테스트 커버리지와 몇 가지 중요한 기능이 미구현 또는 불완전한 상태

---

## 3. 구현된 항목 (완료)

### 3.1 Domain Layer - Entities (완료)
- **DashboardData**: 대시보드 전체 데이터 구조 (7개 필드, copyWith, Equatable)
- **WeeklyProgress**: 주간 목표 진행도 (3개 항목 × 3개 필드 = 9개 필드)
- **NextSchedule**: 다음 투여 일정 (4개 필드)
- **WeeklySummary**: 주간 요약 (4개 필드)
- **TimelineEvent**: 타임라인 이벤트 (6개 필드, 4개 이벤트 타입)
- **BadgeDefinition**: 뱃지 정의 (6개 필드, 4개 카테고리)
- **UserBadge**: 사용자 뱃지 상태 (8개 필드, 3개 상태)

**품질 평가**: ⭐⭐⭐⭐ (프로덕션 레벨)
- Equatable 구현으로 equality 비교 지원
- copyWith 메서드로 불변성 보장
- 명확한 필드 정의와 타입 안정성

### 3.2 Domain Layer - UseCases (완료)
- **CalculateContinuousRecordDaysUseCase**: 연속 기록일 계산
  - 구현: 체중/증상 기록 통합, 오늘부터 역순 계산, 빈 날 감지

- **CalculateCurrentWeekUseCase**: 현재 주차 계산
  - 구현: 투여 시작일 기준, 7일 = 1주 계산

- **CalculateWeeklyProgressUseCase**: 주간 목표 진행도 계산
  - 구현: 투여/체중/부작용 각각 지난 7일 기준 계산, clamp(0.0, 1.0)

- **CalculateAdherenceUseCase**: 투여 순응도 계산
  - 구현: 완료한 투여 / 예정 투여, 미래 일정 제외

- **CalculateWeightGoalEstimateUseCase**: 목표 체중 도달 예상일 계산
  - 구현: 선형 회귀 (간단한 버전), 최근 4주 데이터 기반, null 반환 조건 명확

- **VerifyBadgeConditionsUseCase**: 뱃지 조건 검증
  - 구현: 5개 뱃지 조건 검증 (streak_7, streak_30, weight_5%, weight_10%, first_dose)
  - 진행도 계산 및 상태 업데이트 포함

**품질 평가**: ⭐⭐⭐⭐ (프로덕션 레벨)
- 비즈니스 로직 명확하고 구현 정확
- 엣지 케이스 처리 (null 처리, 범위 제한)
- 단일 책임 원칙 준수

### 3.3 Domain Layer - Repository Interface (완료)
- **BadgeRepository**: 5개 메서드 인터페이스
  - getBadgeDefinitions()
  - getUserBadges(userId)
  - updateBadgeProgress(badge)
  - achieveBadge(userId, badgeId)
  - initializeUserBadges(userId)

**품질 평가**: ⭐⭐⭐⭐ (프로덕션 레벨)
- 명확한 메서드 시그니처
- Repository Pattern 준수

### 3.4 Infrastructure Layer (완료)

#### DTOs
- **BadgeDefinitionDto**: Isar Collection, toEntity() / fromEntity() 구현
- **UserBadgeDto**: Isar Collection, enum 문자열 변환 로직 포함

#### Repository Implementation
- **IsarBadgeRepository**: BadgeRepository 구현
  - getBadgeDefinitions(): Isar 쿼리 (모든 정의 조회)
  - getUserBadges(userId): 필터 쿼리 구현
  - updateBadgeProgress(): 트랜잭션 포함
  - achieveBadge(): 상태 업데이트 로직
  - initializeUserBadges(): 모든 뱃지 초기화

**품질 평가**: ⭐⭐⭐⭐ (프로덕션 레벨)
- Isar 트랜잭션으로 데이터 무결성 보장
- 필터 쿼리 정확한 구현

### 3.5 Application Layer (부분 완료)

#### DashboardNotifier
**구현된 부분**:
- build() 메서드: 대시보드 데이터 로드
  - 프로필 조회
  - 투여/체중/증상 기록 조회
  - 활성 투여 계획 조회
  - 모든 UseCase 호출 및 데이터 집계

- refresh() 메서드: 데이터 갱신

- 뱃지 검증 로직 통합

- 인사이트 메시지 생성 (기본적인 3가지 조건)

**문제점**:
1. `_calculateNextSchedule()` 메서드: **하드코딩된 더미 데이터** (임시)
   - 실제로는 다음 투여 일정을 계획에서 조회해야 함
   - 현재: `nextDoseDate = now + 1일`, `nextDoseMg = 0.5` (고정)
   - 개선 필요: DoseSchedule 엔티티에서 실제 데이터 추출

2. `_calculateWeeklySummary()` 메서드: 동적 타입 캐스팅 (안전하지 않음)
   - 현재: `(weights as List)` 등으로 캐스팅
   - 문제: 런타임 에러 위험
   - 개선 필요: 정적 타입 지정

3. `_buildTimeline()` 메서드: **완전히 미구현**
   - 현재: 빈 배열 반환
   - 필요: 투여 기록/체중 마일스톤/뱃지 획득 이벤트 생성 로직

4. `_generateInsightMessage()` 메서드: 매우 기본적인 구현
   - 현재: 3가지 경우만 처리
   - Spec 요구사항: 7가지 인사이트 메시지 타입

**품질 평가**: ⭐⭐⭐ (개선 필요)

#### Derived Providers
**구현된 부분**:
- badgeRepositoryProvider: IsarBadgeRepository 인스턴스 생성

**미구현 부분**:
- continuousRecordDaysProvider (Spec 3.6에 명시)
- currentWeekProvider (Spec 3.6에 명시)
- weeklyProgressProvider (Spec 3.6에 명시)
- insightMessageProvider (Spec 3.6에 명시, P1으로 표시)

**품질 평가**: ⭐⭐ (미완료)

### 3.6 Presentation Layer (완료)

#### DashboardScreen
- 로딩/에러/데이터 상태 처리 (when 메서드)
- Pull-to-Refresh 구현
- 모든 위젯 통합
- 에러 상태에서 재시도 버튼 제공

**품질 평가**: ⭐⭐⭐⭐ (프로덕션 레벨)

#### Widgets (모두 완성)
1. **GreetingWidget**: 사용자명, 연속 기록일, 현재 주차, 인사이트 메시지
2. **WeeklyProgressWidget**: 3개 항목 진행 바 (투여/체중/부작용), 100% 달성 시 녹색 강조
3. **QuickActionWidget**: 3개 버튼 (체중 기록/부작용 기록/투여 완료) - **네비게이션 미구현**
4. **NextScheduleWidget**: 다음 투여/증량/목표 달성 일정
5. **WeeklyReportWidget**: 주간 요약 (투여/체중/부작용 통계), 순응도 표시
6. **TimelineWidget**: 타임라인 이벤트 렌더링
7. **BadgeWidget**: 뱃지 그리드 (획득/진행 중/잠금 상태 구분)

**문제점**:
- QuickActionWidget의 onTap 콜백이 구현되지 않음 (라우팅 미처리)

**품질 평가**: ⭐⭐⭐⭐ (프로덕션 레벨, 라우팅 제외)

---

## 4. 미구현 항목

### 4.1 Application Layer - Derived Providers
```dart
// 구현 필요
@riverpod
int continuousRecordDaysProvider(ContinuousRecordDaysProviderRef ref) {
  final tracking = ref.watch(trackingRepositoryProvider);
  final useCase = CalculateContinuousRecordDaysUseCase();
  // 구현
}

@riverpod
int currentWeekProvider(CurrentWeekProviderRef ref) {
  final medication = ref.watch(medicationRepositoryProvider);
  final useCase = CalculateCurrentWeekUseCase();
  // 구현
}

@riverpod
WeeklyProgress weeklyProgressProvider(WeeklyProgressProviderRef ref) {
  final tracking = ref.watch(trackingRepositoryProvider);
  final medication = ref.watch(medicationRepositoryProvider);
  // 구현
}

@riverpod
String? insightMessageProvider(InsightMessageProviderRef ref) {
  final dashboard = ref.watch(dashboardNotifierProvider);
  // 구현
}
```

### 4.2 DashboardNotifier - Timeline 생성 로직
```dart
List<TimelineEvent> _buildTimeline(
  List<DoseRecord> doseRecords,
  List<DoseSchedule> schedules,
  List<WeightLog> weights,
) {
  // 필요한 로직:
  // 1. 투여 시작일 이벤트 생성
  // 2. 용량 증량 시점 이벤트 생성
  // 3. 체중 마일스톤 (25%, 50%, 75%, 100%) 이벤트 생성
  // 4. 뱃지 획득 이벤트 생성
  // 5. 시간순으로 정렬
}
```

### 4.3 DashboardNotifier - NextSchedule 실제 데이터 계산
```dart
NextSchedule _calculateNextSchedule(
  List<DoseSchedule> schedules,
  List<WeightLog> weights,
  DosagePlan plan,
) {
  // 현재: 하드코딩 더미 데이터
  // 필요:
  // 1. DoseSchedule에서 다음 예정 투여 조회
  // 2. escalation 날짜 실제 계산 (dose_schedules에서)
  // 3. 목표 체중 도달 예상일 계산 (WeightGoalEstimateUseCase 활용)
}
```

### 4.4 Insight Message Generation (세부 구현)
Plan 3.2의 GenerateInsightMessageUseCase가 미구현. 현재는 DashboardNotifier 내 기본 로직만 있음:

필요한 메시지 타입 (7가지):
1. 체중 감량 메시지 (> 1%)
2. 연속 기록 메시지 (>= 7일)
3. 부작용 개선 메시지
4. 패턴 인식 메시지
5. 목표 진행 메시지
6. 순응도 상관관계 메시지
7. 기본 격려 메시지

### 4.5 Quick Action Widget - Navigation
```dart
// 현재 빈 콜백
onTap: () {
  // 체중 기록 화면으로 이동 필요
  // 부작용 기록 화면으로 이동 필요
  // 투여 완료 화면으로 이동 필요
}
```

### 4.6 CelebrationAnimationWidget
Spec 9번 시나리오 (투여 완료 시 축하 효과)에서 요구하는 애니메이션 위젯 미구현

### 4.7 Achievement Highlight
Spec 10번 시나리오 (주간 목표 100% 달성 시 시각적 강조)의 고급 비주얼 효과 미구현

---

## 5. 테스트 커버리지

### 현재 상태: 극도로 부족 (5% 미만)

#### 작성된 테스트 (2개 파일)
1. **dashboard_data_test.dart** (6개 테스트)
   - DashboardData 생성/equality/copyWith 기본 테스트

2. **calculate_continuous_record_days_usecase_test.dart** (6개 테스트)
   - CalculateContinuousRecordDaysUseCase의 엣지 케이스 테스트

#### 미작성 테스트 (Spec 요구사항 대비)

**Domain Layer Entity Tests (미작성)**:
- WeeklyProgress (3개 테스트)
- NextSchedule (2개 테스트)
- WeeklySummary (2개 테스트)
- TimelineEvent (2개 테스트)
- BadgeDefinition (3개 테스트)
- UserBadge (4개 테스트)

**Domain Layer UseCase Tests (미작성)**:
- CalculateCurrentWeekUseCase (3개 테스트)
- CalculateWeeklyProgressUseCase (6개 테스트)
- CalculateAdherenceUseCase (5개 테스트)
- CalculateWeightGoalEstimateUseCase (5개 테스트)
- VerifyBadgeConditionsUseCase (8개 테스트)

**Infrastructure Layer Tests (미작성)**:
- IsarBadgeRepository (6개 integration 테스트)

**Application Layer Tests (미작성)**:
- DashboardNotifier (10개 integration 테스트)
- Derived Providers (4개 테스트)

**Presentation Layer Tests (미작성)**:
- GreetingWidget (4개 widget 테스트)
- WeeklyProgressWidget (4개 widget 테스트)
- QuickActionWidget (4개 widget 테스트)
- NextScheduleWidget (4개 widget 테스트)
- WeeklyReportWidget (4개 widget 테스트)
- TimelineWidget (4개 widget 테스트)
- BadgeWidget (4개 widget 테스트)
- DashboardScreen Acceptance Tests (10개 테스트)

**예상 필요 테스트**: 최소 100개 이상

---

## 6. 개선 필요사항

### 우선순위 1 (필수 - Production Ready)

#### 6.1 DashboardNotifier 완성
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

**문제**:
1. `_calculateNextSchedule()` - 하드코딩 더미 데이터
2. `_calculateWeeklySummary()` - 동적 타입 캐스팅
3. `_buildTimeline()` - 완전히 빈 구현
4. `_generateInsightMessage()` - 기본적인 구현

**해결 방안**:
```dart
// 1. NextSchedule 실제 계산
NextSchedule _calculateNextSchedule(
  List<DoseSchedule> schedules,
  List<WeightLog> weights,
  UserProfile profile,
  DosagePlan plan,
) {
  // schedules를 정렬해서 다음 투여 조회
  final futureSchedules = schedules
      .where((s) => s.scheduledDate.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  final nextSchedule = futureSchedules.isNotEmpty
      ? futureSchedules.first
      : null;

  // escalation 날짜 조회 (dose_schedules에서 용량 변경 시점)
  final escalationSchedules = schedules
      .where((s) => s.scheduledDoseMg > (futureSchedules.isNotEmpty
          ? futureSchedules.first.scheduledDoseMg
          : 0.25))
      .toList();

  final nextEscalation = escalationSchedules.isNotEmpty
      ? escalationSchedules.first.scheduledDate
      : null;

  // 목표 체중 도달 예상일
  final goalEstimate = _calculateWeightGoalEstimate.execute(
    currentWeight: weights.isNotEmpty
        ? weights.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b).weightKg
        : profile.targetWeightKg + 5,
    targetWeight: profile.targetWeightKg,
    weightLogs: weights,
  );

  return NextSchedule(
    nextDoseDate: nextSchedule?.scheduledDate ?? DateTime.now(),
    nextDoseMg: nextSchedule?.scheduledDoseMg ?? 0.25,
    nextEscalationDate: nextEscalation,
    goalEstimateDate: goalEstimate,
  );
}

// 2. Timeline 생성
List<TimelineEvent> _buildTimeline(
  List<DoseRecord> doseRecords,
  List<DoseSchedule> schedules,
  List<WeightLog> weights,
  DosagePlan plan,
  UserProfile profile,
) {
  final events = <TimelineEvent>[];

  // 치료 시작 이벤트
  events.add(TimelineEvent(
    id: 'treatment_start',
    dateTime: plan.startDate,
    eventType: TimelineEventType.treatmentStart,
    title: '치료 시작',
    description: '${plan.initialDoseMg}mg 투여 시작',
  ));

  // 용량 증량 이벤트
  final escalations = schedules
      .map((s) => s.scheduledDoseMg)
      .toSet()
      .toList()
    ..sort();
  for (int i = 1; i < escalations.length; i++) {
    final firstScheduleWithDose = schedules
        .firstWhere((s) => s.scheduledDoseMg == escalations[i]);
    events.add(TimelineEvent(
      id: 'escalation_${escalations[i]}',
      dateTime: firstScheduleWithDose.scheduledDate,
      eventType: TimelineEventType.escalation,
      title: '용량 증량',
      description: '${escalations[i]}mg로 증량',
    ));
  }

  // 체중 마일스톤 이벤트
  if (weights.isNotEmpty) {
    final startWeight = weights.reduce((a, b) =>
        a.logDate.isBefore(b.logDate) ? a : b).weightKg;
    final targetWeight = profile.targetWeightKg;
    final totalLossNeeded = startWeight - targetWeight;

    for (final milestone in [0.25, 0.50, 0.75, 1.0]) {
      final targetLoss = totalLossNeeded * milestone;
      final milestoneWeight = startWeight - targetLoss;

      final firstLogBelowMilestone = weights
          .firstWhere((w) => w.weightKg <= milestoneWeight,
              orElse: () => null);

      if (firstLogBelowMilestone != null) {
        events.add(TimelineEvent(
          id: 'milestone_${(milestone * 100).toInt()}',
          dateTime: firstLogBelowMilestone.logDate,
          eventType: TimelineEventType.weightMilestone,
          title: '목표 진행도 ${(milestone * 100).toInt()}%',
          description: '${firstLogBelowMilestone.weightKg}kg 달성',
        ));
      }
    }
  }

  // 정렬
  events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

  return events;
}

// 3. WeeklySummary 개선 (타입 안정화)
WeeklySummary _calculateWeeklySummary(
  List<DoseRecord> doseRecords,
  List<WeightLog> weights,
  List<SymptomLog> symptoms,
  List<DoseSchedule> schedules,
) {
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(Duration(days: 7));

  final doseCount = doseRecords
      .where((r) => r.administeredAt.isAfter(sevenDaysAgo))
      .length;

  final firstWeight = weights.isNotEmpty
      ? weights.reduce((a, b) => a.logDate.isBefore(b.logDate) ? a : b).weightKg
      : 0.0;
  final latestWeight = weights.isNotEmpty
      ? weights.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b).weightKg
      : 0.0;
  final weightChange = firstWeight - latestWeight;

  final symptomCount = symptoms
      .where((s) => s.logDate.isAfter(sevenDaysAgo))
      .length;

  final adherence = _calculateAdherence.execute(doseRecords, schedules);

  return WeeklySummary(
    doseCompletedCount: doseCount,
    weightChangeKg: weightChange,
    symptomRecordCount: symptomCount,
    adherencePercentage: adherence,
  );
}
```

#### 6.2 Application Layer - Derived Providers 구현
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/dashboard/application/providers.dart`

```dart
@riverpod
int continuousRecordDaysProvider(ContinuousRecordDaysProviderRef ref) {
  final tracking = ref.watch(trackingRepositoryProvider);
  final useCase = CalculateContinuousRecordDaysUseCase();

  return AsyncValue.guard(() async {
    final weights = await tracking.getWeightLogs();
    final symptoms = await tracking.getSymptomLogs();
    return useCase.execute(weights, symptoms);
  });
}

@riverpod
int currentWeekProvider(CurrentWeekProviderRef ref) async {
  final medication = ref.watch(medicationRepositoryProvider);
  final useCase = CalculateCurrentWeekUseCase();

  final plan = await medication.getActiveDosagePlan();
  if (plan == null) throw Exception('No active dosage plan');

  return useCase.execute(plan.startDate);
}

@riverpod
WeeklyProgress weeklyProgressProvider(WeeklyProgressProviderRef ref) async {
  final tracking = ref.watch(trackingRepositoryProvider);
  final medication = ref.watch(medicationRepositoryProvider);
  final profile = ref.watch(profileRepositoryProvider);
  final useCase = CalculateWeeklyProgressUseCase();

  final doseRecords = await medication.getDoseRecords(null);
  final schedules = await medication.getDoseSchedules(null);
  final weights = await tracking.getWeightLogs();
  final symptoms = await tracking.getSymptomLogs();
  final userProfile = await profile.getUserProfile();

  if (userProfile == null) throw Exception('User profile not found');

  return useCase.execute(
    doseRecords: doseRecords,
    weightLogs: weights,
    symptomLogs: symptoms,
    doseTargetCount: schedules
        .where((s) => s.scheduledDate.isAfter(DateTime.now().subtract(Duration(days: 7))))
        .length,
    weightTargetCount: userProfile.weeklyWeightRecordGoal,
    symptomTargetCount: userProfile.weeklySymptomRecordGoal,
  );
}

@riverpod
String? insightMessageProvider(InsightMessageProviderRef ref) async {
  final dashboard = ref.watch(dashboardNotifierProvider);

  return dashboard.whenData((data) {
    // GenerateInsightMessageUseCase 호출 (미구현 UseCase)
    // 또는 인라인 로직 구현
    return data.insightMessage;
  }).asData?.value;
}
```

#### 6.3 QuickActionWidget - Navigation 구현
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/dashboard/presentation/widgets/quick_action_widget.dart`

```dart
class QuickActionWidget extends ConsumerWidget {
  const QuickActionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('빠른 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.scale,
              label: '체중 기록',
              color: Colors.blue,
              onTap: () => context.go('/tracking/weight'),
            ),
            _QuickActionButton(
              icon: Icons.favorite,
              label: '부작용 기록',
              color: Colors.pink,
              onTap: () => context.go('/tracking/symptom'),
            ),
            _QuickActionButton(
              icon: Icons.check_circle,
              label: '투여 완료',
              color: Colors.green,
              onTap: () => context.go('/medication/record-dose'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 우선순위 2 (중요 - 테스트 커버리지)

#### 6.4 Domain Layer UseCase Tests
모든 UseCase에 대한 unit 테스트 작성
- 각 UseCase별 5-8개 테스트 케이스
- 엣지 케이스와 normal case 모두 포함
- 예상: 45개 테스트 추가

#### 6.5 Infrastructure Layer Integration Tests
IsarBadgeRepository에 대한 integration 테스트
- In-Memory Isar DB 사용
- CRUD 연산 모두 검증
- 예상: 6개 테스트

#### 6.6 Application Layer Integration Tests
DashboardNotifier와 Derived Providers에 대한 integration 테스트
- Mock Repository 사용
- 데이터 흐름 검증
- 예상: 14개 테스트

### 우선순위 3 (선택 - Advanced Features)

#### 6.7 CelebrationAnimationWidget 구현
Lottie 또는 confetti 패키지 사용하여 투여 완료 시 축하 애니메이션

#### 6.8 GenerateInsightMessageUseCase 세부 구현
7가지 인사이트 메시지 타입별 로직 구현

#### 6.9 Timeline Advanced Features
- 타임라인 시각화 개선
- 스크롤 가능한 그래프
- 인터랙티브 요소 추가

---

## 7. Code Quality Issues

### 7.1 IsarBadgeRepository의 achieveBadge() 메서드
**현재 코드**:
```dart
final updated = badge.copyWith(
  status: 'achieved',  // 문자열 하드코딩
  progressPercentage: 100,
  achievedAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

**문제**: BadgeStatus enum이 있는데 문자열 사용
**개선**:
```dart
final updated = badge.copyWith(
  status: BadgeStatus.achieved.toString().split('.').last,
  progressPercentage: 100,
  achievedAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### 7.2 TimelineWidget의 조건 오류
**현재 코드** (line 76):
```dart
if (event != event) // 항상 false - 버그
```

**문제**: 자기 자신과 비교 → 조건 항상 거짓
**개선**: 마지막 이벤트가 아니면 라인 그리기
```dart
if (index < timeline.length - 1)
```

### 7.3 CalculateWeightGoalEstimateUseCase의 선형 회귀
**현재 구현**: 첫 번째와 마지막 기록만 사용
**개선 필요**: 실제 선형 회귀 분석 (최소제곱법) 구현 고려

---

## 8. Architecture Compliance Check

### Repository Pattern ✓
- Domain에서 인터페이스 정의 (BadgeRepository)
- Infrastructure에서 구현 (IsarBadgeRepository)
- Application에서 의존성 주입 (providers.dart)

### Layer Separation ✓
- Domain: 비즈니스 로직 (UseCases, Entities)
- Application: 상태 관리 (DashboardNotifier)
- Presentation: UI (Widgets, Screen)
- Infrastructure: 데이터 접근 (IsarBadgeRepository)

### No Layer Violations ✓
- Domain은 Flutter 의존성 없음
- Application은 Domain만 의존
- Presentation은 Application 의존

---

## 9. Performance Considerations

### 현재 구현의 성능 이슈

1. **DashboardNotifier build()에서 모든 데이터 동시 로드**
   - 6개의 레포지토리 메서드 순차 호출
   - 네트워크 지연 시 전체 로딩 시간 증가
   - 개선: 병렬 로드 또는 캐싱 전략 필요

2. **Timeline 생성의 O(n²) 복잡도 가능성**
   - 모든 로그에 대해 마일스톤 확인
   - 개선: 인덱싱 또는 사전 계산 필요

3. **메모리 사용**
   - 전체 DoseRecord/WeightLog 메모리에 로드
   - 대안: 페이지네이션 또는 필터링

---

## 10. Security Considerations

### 현재 구현 확인 ✓

1. **사용자 ID 필터링**
   - BadgeRepository.getUserBadges(userId)
   - TrackingRepository.getWeightLogs() - userId 내재

2. **데이터 무결성**
   - Isar 트랜잭션 사용
   - DateTime 검증

### 개선 추천

1. **입력 검증**: DashboardNotifier에서 null check 강화
2. **권한 검증**: 현재 사용자의 userId만 접근 확인
3. **감시 로깅**: 뱃지 획득 등 중요 이벤트 로깅

---

## 11. Testing Strategy Recommendations

### 우선순위 순서

1. **Phase 1**: Domain Layer Unit Tests (2-3일)
   - Entity serialization (4개)
   - UseCase 비즈니스 로직 (45개)
   - 총 50개 테스트

2. **Phase 2**: Infrastructure Integration Tests (1-2일)
   - Isar CRUD 연산 (6개)
   - DTO 변환 (4개)
   - 총 10개 테스트

3. **Phase 3**: Application Tests (2-3일)
   - DashboardNotifier 상태 관리 (10개)
   - Derived Providers (4개)
   - 총 14개 테스트

4. **Phase 4**: Presentation Widget Tests (3-5일)
   - 각 Widget 별 4개 테스트 (28개)
   - DashboardScreen acceptance (10개)
   - 총 38개 테스트

**총 테스트**: 최소 112개 (현재 2개 → 약 5500% 증가 필요)

---

## 12. Deployment Readiness Checklist

- [x] 핵심 UseCase 로직 구현
- [x] Repository Pattern 준수
- [x] Layer Architecture 준수
- [ ] 전체 테스트 커버리지 (필수: 최소 60%)
- [ ] 모든 Spec 요구사항 구현 (90% 완료)
- [ ] 코드 리뷰 및 정적 분석
- [ ] 성능 프로파일링
- [ ] 문서화 (현재: Spec/Plan만, 코드 주석 필요)

---

## 13. 최종 권장사항

### 즉시 조치 (Production Ready 위해)

1. **DashboardNotifier 완성** (Priority 1)
   - Timeline 생성 로직 구현
   - NextSchedule 실제 데이터 계산
   - WeeklySummary 타입 안정화

2. **Derived Providers 구현** (Priority 1)
   - 4개 provider 모두 구현

3. **라우팅 통합** (Priority 1)
   - QuickActionWidget 네비게이션 연결

4. **테스트 작성 최소화** (Priority 2)
   - Domain Layer: 50개 테스트 (필수)
   - Infrastructure: 10개 테스트 (필수)
   - Application: 14개 테스트 (필수)
   - 총 74개 추가 테스트

### 선택사항 (Phase 2)

1. CelebrationAnimationWidget 추가
2. GenerateInsightMessageUseCase 세부 구현
3. Presentation Layer Widget Tests 추가
4. 성능 최적화

---

## 14. 결론

### 상태: 부분 완료 (60-70%)

**강점**:
- 전체 아키텍처 설계 완료
- Domain Layer 로직 완벽한 구현
- Repository Pattern 엄격히 준수
- 기본적인 Presentation Layer 완성

**약점**:
- 테스트 커버리지 극도로 부족 (5% 미만)
- DashboardNotifier의 일부 메서드 미완성
- Derived Providers 미구현
- 고급 기능(Timeline, Insight Messages) 미완성
- 라우팅 통합 부분적 미완성

**예상 완성 시간**:
- 최소 구현(Priority 1): 3-4일
- 전체 테스트 포함: 8-10일

**다음 단계**: `/docs/008/plan.md`의 TDD Workflow에 따라 Phase 2 (Infrastructure Layer Integration Tests)부터 시작 권장

---

**작성일**: 2025-11-08
**검토자**: Claude Code
**최종 확인**: 코드베이스 기반 정적 분석

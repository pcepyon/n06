import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';
import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_continuous_record_days_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_current_week_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_weight_goal_estimate_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_weekly_progress_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/verify_badge_conditions_usecase.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart'
    as onboarding_medication_repo;
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart'
    as onboarding_dosage_plan;
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart'
    as tracking_medication_repo;
import 'package:n06/features/onboarding/application/providers.dart'
    as onboarding_providers;
import 'package:n06/features/tracking/application/providers.dart'
    as tracking_providers;
import 'package:n06/features/dashboard/application/providers.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_notifier.g.dart';

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  late ProfileRepository _profileRepository;
  late TrackingRepository _trackingRepository;
  late onboarding_medication_repo.MedicationRepository _medicationRepository;
  late tracking_medication_repo.MedicationRepository _trackingMedicationRepository;
  late BadgeRepository _badgeRepository;

  final _calculateContinuousRecordDays = CalculateContinuousRecordDaysUseCase();
  final _calculateCurrentWeek = CalculateCurrentWeekUseCase();
  final _calculateWeeklyProgress = CalculateWeeklyProgressUseCase();
  final _calculateWeightGoalEstimate = CalculateWeightGoalEstimateUseCase();
  final _verifyBadgeConditions = VerifyBadgeConditionsUseCase();

  @override
  Future<DashboardData> build() async {
    // 인증 상태에서 userId 가져오기
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.value?.id;

    if (userId == null) {
      throw Exception(DashboardMessageType.errorNotAuthenticated.toString());
    }

    // repositories 초기화
    _profileRepository = ref.watch(onboarding_providers.profileRepositoryProvider);
    _trackingRepository = ref.watch(tracking_providers.trackingRepositoryProvider);
    _medicationRepository =
        ref.watch(onboarding_providers.medicationRepositoryProvider);
    _trackingMedicationRepository =
        ref.watch(tracking_providers.medicationRepositoryProvider);
    _badgeRepository = ref.watch(badgeRepositoryProvider);

    return _loadDashboardData(userId);
  }

  Future<void> refresh() async {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.value?.id;

    if (userId == null) {
      throw Exception(DashboardMessageType.errorNotAuthenticated.toString());
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboardData(userId));
  }

  Future<DashboardData> _loadDashboardData(String userId) async {
    // 프로필 조회
    final profile = await _profileRepository.getUserProfile(userId);
    if (profile == null) {
      throw Exception(DashboardMessageType.errorProfileNotFound.toString());
    }

    // 활성 투여 계획 조회
    final activePlan =
        await _medicationRepository.getActiveDosagePlan(userId);
    if (activePlan == null) {
      throw Exception(DashboardMessageType.errorActivePlanNotFound.toString());
    }

    // 체중 기록, 투여 기록 조회
    final weights = await _trackingRepository.getWeightLogs(userId);
    final doseRecords = await _trackingMedicationRepository.getDoseRecords(activePlan.id);

    // 연속 기록일 계산 (증상 로그는 빈 리스트)
    final continuousRecordDays = _calculateContinuousRecordDays.execute(
        weights, []);

    // 현재 주차 계산
    final currentWeek =
        _calculateCurrentWeek.execute(activePlan.startDate);

    // 주간 목표 진행도 계산 (증상 로그는 빈 리스트)
    final weeklyProgress = _calculateWeeklyProgress.execute(
      doseRecords: doseRecords,
      weightLogs: weights,
      symptomLogs: [],
      doseTargetCount: 1,
      weightTargetCount: profile.weeklyWeightRecordGoal,
      symptomTargetCount: profile.weeklySymptomRecordGoal,
    );

    // 다음 투여 일정
    final nextSchedule = _calculateNextSchedule(activePlan, weights, profile);

    // 주간 요약
    final weeklySummary = _calculateWeeklySummary(weights, [], doseRecords);

    // 뱃지 조회 및 검증
    final userBadges = await _badgeRepository.getUserBadges(userId);
    final currentWeightKg = weights.isNotEmpty
        ? weights.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b).weightKg
        : profile.targetWeight.value + 5;
    final startWeightKg = weights.isNotEmpty
        ? weights
            .reduce((a, b) => a.logDate.isBefore(b.logDate) ? a : b)
            .weightKg
        : currentWeightKg;
    final weightLossPercentage = startWeightKg > 0
        ? ((startWeightKg - currentWeightKg) / startWeightKg) * 100
        : 0.0;

    final updatedBadges = _verifyBadgeConditions.execute(
      currentBadges: userBadges,
      continuousRecordDays: continuousRecordDays,
      weightLossPercentage: weightLossPercentage,
      hasFirstDose: doseRecords.isNotEmpty,
      allDoseRecords: doseRecords,
    );

    // 타임라인 생성
    final timeline = _buildTimeline(activePlan, profile, weights);

    return DashboardData(
      userId: userId,
      userName: profile.userName ?? profile.userId.split('@').first,
      continuousRecordDays: continuousRecordDays,
      currentWeek: currentWeek,
      weeklyProgress: weeklyProgress,
      nextSchedule: nextSchedule,
      weeklySummary: weeklySummary,
      badges: updatedBadges,
      timeline: timeline,
      insightMessageData: _generateInsightMessageData(
        continuousRecordDays,
        weightLossPercentage,
        weeklyProgress,
      ),
    );
  }

  NextSchedule _calculateNextSchedule(
    onboarding_dosage_plan.DosagePlan activePlan,
    List<WeightLog> weights,
    UserProfile profile,
  ) {
    final now = DateTime.now();

    // 현재 체중 가져오기
    final currentWeightKg = weights.isNotEmpty
        ? weights
            .reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b)
            .weightKg
        : profile.targetWeight.value + 5.0;

    // 목표 체중 도달 예상일 계산
    final goalEstimateDate = _calculateWeightGoalEstimate.execute(
      currentWeight: currentWeightKg,
      targetWeight: profile.targetWeight.value,
      weightLogs: weights,
    );

    return NextSchedule(
      nextDoseDate: now.add(Duration(days: 1)),
      nextDoseMg: activePlan.initialDoseMg,
      nextEscalationDate: null,
      goalEstimateDate: goalEstimateDate,
    );
  }

  WeeklySummary _calculateWeeklySummary(
    List<WeightLog> weights,
    List<dynamic> symptoms,
    List<DoseRecord> doseRecords,
  ) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));

    // 지난 7일간 체중 변화
    final recentWeights = weights
        .where((w) => w.logDate.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => a.logDate.compareTo(b.logDate));

    final weightChange = recentWeights.length >= 2
        ? recentWeights.last.weightKg - recentWeights.first.weightKg
        : 0.0;

    // 지난 7일간 증상 개수
    final symptomCount = symptoms
        .where((s) => s.logDate.isAfter(sevenDaysAgo))
        .length;

    // 지난 7일간 투여 기록 개수
    final recentDoseRecords = doseRecords
        .where((d) => d.administeredAt.isAfter(sevenDaysAgo))
        .toList();

    // 순응도 계산 (임시: 기록이 있으면 85%, 없으면 0%)
    final adherencePercentage = recentDoseRecords.isNotEmpty ? 85.0 : 0.0;

    return WeeklySummary(
      doseCompletedCount: recentDoseRecords.length,
      weightChangeKg: weightChange,
      symptomRecordCount: symptomCount,
      adherencePercentage: adherencePercentage,
    );
  }

  List<TimelineEvent> _buildTimeline(
    onboarding_dosage_plan.DosagePlan activePlan,
    UserProfile profile,
    List<WeightLog> weights,
  ) {
    final events = <TimelineEvent>[];

    // 1. 치료 시작일 이벤트 (항상 표시)
    events.add(
      TimelineEvent(
        id: 'treatment_start',
        dateTime: activePlan.startDate,
        eventType: TimelineEventType.treatmentStart,
        titleMessageType: DashboardMessageType.timelineTreatmentStart,
        doseMg: activePlan.initialDoseMg.toString(),
      ),
    );

    // 2. 용량 증량 이벤트 (escalationPlan이 있을 경우)
    if (activePlan.escalationPlan != null &&
        activePlan.escalationPlan!.isNotEmpty) {
      for (final step in activePlan.escalationPlan!) {
        final escalationDate = activePlan.startDate
            .add(Duration(days: step.weeksFromStart * 7));
        events.add(
          TimelineEvent(
            id: 'escalation_${step.doseMg.toStringAsFixed(1)}',
            dateTime: escalationDate,
            eventType: TimelineEventType.escalation,
            titleMessageType: DashboardMessageType.timelineEscalation,
            doseMg: step.doseMg.toStringAsFixed(2),
          ),
        );
      }
    }

    // 3. 체중 마일스톤 이벤트 (25%, 50%, 75%, 100%)
    if (weights.isNotEmpty) {
      final startWeight = weights
          .reduce((a, b) => a.logDate.isBefore(b.logDate) ? a : b)
          .weightKg;
      final targetWeight = profile.targetWeight.value;
      final totalLossNeeded = startWeight - targetWeight;

      if (totalLossNeeded > 0) {
        for (final milestone in [0.25, 0.50, 0.75, 1.0]) {
          final targetLoss = totalLossNeeded * milestone;
          final milestoneWeight = startWeight - targetLoss;

          WeightLog? firstLogBelowMilestone;
          for (final w in weights) {
            if (w.weightKg <= milestoneWeight) {
              if (firstLogBelowMilestone == null ||
                  w.logDate.isBefore(firstLogBelowMilestone.logDate)) {
                firstLogBelowMilestone = w;
              }
            }
          }

          if (firstLogBelowMilestone != null) {
            events.add(
              TimelineEvent(
                id: 'milestone_${(milestone * 100).toInt()}',
                dateTime: firstLogBelowMilestone.logDate,
                eventType: TimelineEventType.weightMilestone,
                titleMessageType: DashboardMessageType.timelineWeightMilestone,
                milestonePercent: (milestone * 100).toInt(),
                weightKg: firstLogBelowMilestone.weightKg.toStringAsFixed(1),
              ),
            );
          }
        }
      }
    }

    // 4. 정렬 (오래된 순서대로)
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return events;
  }

  InsightMessageData? _generateInsightMessageData(
    int continuousRecordDays,
    double weightLossPercentage,
    dynamic weeklyProgress,
  ) {
    // 우선순위 1: 연속 기록일 달성
    if (continuousRecordDays >= 30) {
      return InsightMessageData(
        type: DashboardMessageType.insight30DaysStreak,
      );
    }

    if (continuousRecordDays >= 7) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeeklyStreak,
        continuousRecordDays: continuousRecordDays,
      );
    }

    // 우선순위 2: 체중 감량 진행
    if (weightLossPercentage >= 10.0) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeight10Percent,
      );
    }

    if (weightLossPercentage >= 5.0) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeight5Percent,
      );
    }

    if (weightLossPercentage >= 1.0) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeight1Percent,
      );
    }

    // 우선순위 3: 기본 격려 메시지
    if (continuousRecordDays > 0) {
      return InsightMessageData(
        type: DashboardMessageType.insightKeepRecording,
        continuousRecordDays: continuousRecordDays,
      );
    }

    return InsightMessageData(
      type: DashboardMessageType.insightFirstRecord,
    );
  }
}

/// Alias for backwards compatibility
const dashboardNotifierProvider = dashboardProvider;

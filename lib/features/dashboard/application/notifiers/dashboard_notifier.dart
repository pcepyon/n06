import 'package:n06/core/constants/milestone_constants.dart';
import 'package:n06/core/constants/weight_constants.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_message_type.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';
import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_current_week_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_weight_goal_estimate_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_weekly_progress_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/verify_badge_conditions_usecase.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/daily_checkin/application/providers.dart'
    as checkin_providers;
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
  late DailyCheckinRepository _dailyCheckinRepository;

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
    _dailyCheckinRepository =
        ref.watch(checkin_providers.dailyCheckinRepositoryProvider);

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

    // 체중 기록, 투여 기록, 체크인 기록 조회
    final weights = await _trackingRepository.getWeightLogs(userId);
    final doseRecords = await _trackingMedicationRepository.getDoseRecords(activePlan.id);

    // 체크인 기록 조회 (타임라인용)
    final checkins = await _dailyCheckinRepository.getByDateRange(
      userId,
      DateTime(2024, 1, 1),
      DateTime.now(),
    );

    // 연속 기록일 계산 - DailyCheckin SSOT 사용
    final continuousRecordDays =
        await _dailyCheckinRepository.getConsecutiveDays(userId);

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
    final nextSchedule = _calculateNextSchedule(activePlan, weights, profile, doseRecords);

    // 주간 요약
    final weeklySummary = _calculateWeeklySummary(weights, checkins, doseRecords, activePlan);

    // 뱃지 조회 - 비어있으면 초기화
    var userBadges = await _badgeRepository.getUserBadges(userId);
    if (userBadges.isEmpty) {
      await _badgeRepository.initializeUserBadges(userId);
      userBadges = await _badgeRepository.getUserBadges(userId);
    }

    final currentWeightKg = weights.isNotEmpty
        ? weights.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b).weightKg
        : profile.targetWeight.value + WeightConstants.defaultWeightOffset;
    final startWeightKg = weights.isNotEmpty
        ? weights
            .reduce((a, b) => a.logDate.isBefore(b.logDate) ? a : b)
            .weightKg
        : currentWeightKg;

    // 목표 체중까지의 진행률 계산 (0-100%)
    final weightProgressPercentage = WeightConstants.calculateProgressToGoal(
      currentWeight: currentWeightKg,
      startWeight: startWeightKg,
      targetWeight: profile.targetWeight.value,
    );

    final updatedBadges = _verifyBadgeConditions.execute(
      currentBadges: userBadges,
      continuousRecordDays: continuousRecordDays,
      weightProgressPercentage: weightProgressPercentage,
      hasFirstDose: doseRecords.isNotEmpty,
      allDoseRecords: doseRecords,
    );

    // 뱃지 상태 변경 시 DB에 저장
    await _syncBadgesToDatabase(userBadges, updatedBadges);

    // 타임라인 생성
    final timeline = _buildTimeline(
      activePlan: activePlan,
      profile: profile,
      weights: weights,
      doseRecords: doseRecords,
      checkins: checkins,
      badges: updatedBadges,
    );

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
        weightProgressPercentage,
        weeklyProgress,
      ),
    );
  }

  NextSchedule _calculateNextSchedule(
    onboarding_dosage_plan.DosagePlan activePlan,
    List<WeightLog> weights,
    UserProfile profile,
    List<DoseRecord> doseRecords,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 다음 투여일 계산
    DateTime nextDoseDate;
    if (doseRecords.isEmpty) {
      // 투여 기록이 없으면 → 오늘이 첫 투여일
      nextDoseDate = today;
    } else {
      // 마지막 투여일 + cycleDays
      final sortedRecords = List<DoseRecord>.from(doseRecords)
        ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
      final lastDoseDate = sortedRecords.first.administeredAt;
      final lastDoseDateOnly = DateTime(lastDoseDate.year, lastDoseDate.month, lastDoseDate.day);
      nextDoseDate = lastDoseDateOnly.add(Duration(days: activePlan.cycleDays));
    }

    // 현재 체중 가져오기
    final currentWeightKg = weights.isNotEmpty
        ? weights
            .reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b)
            .weightKg
        : profile.targetWeight.value + WeightConstants.defaultWeightOffset;

    // 목표 체중 도달 예상일 계산
    final goalEstimateDate = _calculateWeightGoalEstimate.execute(
      currentWeight: currentWeightKg,
      targetWeight: profile.targetWeight.value,
      weightLogs: weights,
    );

    // 현재 용량 계산
    final weeksElapsed = activePlan.getWeeksElapsed();
    final currentDoseMg = activePlan.getCurrentDose(weeksElapsed: weeksElapsed);

    return NextSchedule(
      nextDoseDate: nextDoseDate,
      nextDoseMg: currentDoseMg,
      nextEscalationDate: null,
      goalEstimateDate: goalEstimateDate,
    );
  }

  WeeklySummary _calculateWeeklySummary(
    List<WeightLog> weights,
    List<DailyCheckin> checkins,
    List<DoseRecord> doseRecords,
    onboarding_dosage_plan.DosagePlan activePlan,
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

    // 지난 7일간 증상 개수 (체크인의 symptomDetails에서 추출)
    final recentCheckins = checkins
        .where((c) => c.checkinDate.isAfter(sevenDaysAgo))
        .toList();

    int symptomCount = 0;
    for (final checkin in recentCheckins) {
      if (checkin.symptomDetails != null) {
        symptomCount += checkin.symptomDetails!.length;
      }
    }

    // 지난 7일간 투여 기록 개수
    final recentDoseRecords = doseRecords
        .where((d) => d.administeredAt.isAfter(sevenDaysAgo))
        .toList();

    // 순응도 계산
    // 주간 예상 투여 횟수 = 7일 / 투여 주기
    // 예: cycleDays=7 → 주 1회, cycleDays=3 → 주 2-3회
    final daysInWeek = 7;
    final expectedDosesPerWeek = activePlan.cycleDays > 0
        ? (daysInWeek / activePlan.cycleDays).ceil()
        : 1;

    // 실제 투여 횟수
    final actualDoses = recentDoseRecords.length;

    // 순응도 = (실제 투여 횟수 / 예상 투여 횟수) * 100
    // 0-100% 범위로 클램핑
    final adherencePercentage = expectedDosesPerWeek > 0
        ? (actualDoses / expectedDosesPerWeek * 100).clamp(0.0, 100.0)
        : 0.0;

    return WeeklySummary(
      doseCompletedCount: recentDoseRecords.length,
      weightChangeKg: weightChange,
      symptomRecordCount: symptomCount,
      adherencePercentage: adherencePercentage,
    );
  }

  List<TimelineEvent> _buildTimeline({
    required onboarding_dosage_plan.DosagePlan activePlan,
    required UserProfile profile,
    required List<WeightLog> weights,
    required List<DoseRecord> doseRecords,
    required List<DailyCheckin> checkins,
    required List<UserBadge> badges,
  }) {
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

    // 2. 용량 증량 이벤트 (escalationPlan이 있을 경우 - 미래 예정 제외)
    if (activePlan.escalationPlan != null &&
        activePlan.escalationPlan!.isNotEmpty) {
      final now = DateTime.now();
      for (final step in activePlan.escalationPlan!) {
        final escalationDate = activePlan.startDate
            .add(Duration(days: step.weeksFromStart * 7));
        // 과거 이벤트만 표시
        if (escalationDate.isBefore(now)) {
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
    }

    // 3. 체중 마일스톤 이벤트 (25%, 50%, 75%, 100%)
    if (weights.isNotEmpty) {
      final startWeight = weights
          .reduce((a, b) => a.logDate.isBefore(b.logDate) ? a : b)
          .weightKg;
      final targetWeight = profile.targetWeight.value;
      final totalLossNeeded = startWeight - targetWeight;

      if (totalLossNeeded > 0) {
        for (final milestonePercent in WeightConstants.weightProgressMilestones) {
          final milestone = milestonePercent / 100.0;
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
                id: 'milestone_$milestonePercent',
                dateTime: firstLogBelowMilestone.logDate,
                eventType: TimelineEventType.weightMilestone,
                titleMessageType: DashboardMessageType.timelineWeightMilestone,
                milestonePercent: milestonePercent,
                weightKg: firstLogBelowMilestone.weightKg.toStringAsFixed(1),
              ),
            );
          }
        }
      }
    }

    // 4. 첫 체중 기록 이벤트
    if (weights.isNotEmpty) {
      final firstWeight = weights.reduce(
        (a, b) => a.logDate.isBefore(b.logDate) ? a : b,
      );
      events.add(
        TimelineEvent(
          id: 'first_weight',
          dateTime: firstWeight.logDate,
          eventType: TimelineEventType.firstWeightLog,
          titleMessageType: DashboardMessageType.timelineFirstWeightLog,
          weightKg: firstWeight.weightKg.toStringAsFixed(1),
        ),
      );
    }

    // 5. 첫 투여 기록 이벤트
    if (doseRecords.isNotEmpty) {
      final firstDose = doseRecords.reduce(
        (a, b) => a.administeredAt.isBefore(b.administeredAt) ? a : b,
      );
      events.add(
        TimelineEvent(
          id: 'first_dose',
          dateTime: firstDose.administeredAt,
          eventType: TimelineEventType.firstDose,
          titleMessageType: DashboardMessageType.timelineFirstDose,
          doseMg: firstDose.actualDoseMg.toStringAsFixed(2),
        ),
      );
    }

    // 6. 용량 변경 이벤트 (새로운 용량 첫 투여)
    if (doseRecords.isNotEmpty) {
      // 용량별로 첫 투여 날짜 찾기
      final doseFirstDates = <double, DoseRecord>{};
      for (final record in doseRecords) {
        final dose = record.actualDoseMg;
        if (!doseFirstDates.containsKey(dose) ||
            record.administeredAt.isBefore(doseFirstDates[dose]!.administeredAt)) {
          doseFirstDates[dose] = record;
        }
      }

      // 초기 용량(첫 투여)을 제외한 새로운 용량들만 이벤트로 추가
      final sortedDoses = doseFirstDates.keys.toList()..sort();
      if (sortedDoses.length > 1) {
        // 첫 번째 용량 제외 (이미 firstDose로 표시됨)
        for (var i = 1; i < sortedDoses.length; i++) {
          final dose = sortedDoses[i];
          final record = doseFirstDates[dose]!;
          events.add(
            TimelineEvent(
              id: 'dose_change_${dose.toStringAsFixed(2)}',
              dateTime: record.administeredAt,
              eventType: TimelineEventType.doseChange,
              titleMessageType: DashboardMessageType.timelineDoseChange,
              doseMg: dose.toStringAsFixed(2),
            ),
          );
        }
      }
    }

    // 7. 첫 체크인 이벤트
    if (checkins.isNotEmpty) {
      final firstCheckin = checkins.reduce(
        (a, b) => a.checkinDate.isBefore(b.checkinDate) ? a : b,
      );
      events.add(
        TimelineEvent(
          id: 'first_checkin',
          dateTime: firstCheckin.checkinDate,
          eventType: TimelineEventType.firstCheckin,
          titleMessageType: DashboardMessageType.timelineFirstCheckin,
        ),
      );
    }

    // 8. 연속 체크인 마일스톤 이벤트 (3, 7, 14, 21, 30, 60, 90일)
    _addCheckinMilestones(events, checkins);

    // 9. 뱃지 달성 이벤트
    for (final badge in badges) {
      if (badge.status == BadgeStatus.achieved && badge.achievedAt != null) {
        events.add(
          TimelineEvent(
            id: 'badge_${badge.badgeId}',
            dateTime: badge.achievedAt!,
            eventType: TimelineEventType.badgeAchievement,
            titleMessageType: DashboardMessageType.timelineBadgeAchievement,
            badgeId: badge.badgeId,
            badgeName: badge.badgeId, // TODO: 실제 뱃지 이름 조회 필요
          ),
        );
      }
    }

    // 10. 정렬 (최신순 - 최근 이벤트가 상단에 표시)
    events.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return events;
  }

  /// 연속 체크인 마일스톤 이벤트 추가
  /// 마일스톤: 3, 7, 14, 21, 30, 60, 90일
  void _addCheckinMilestones(
    List<TimelineEvent> events,
    List<DailyCheckin> checkins,
  ) {
    if (checkins.isEmpty) return;

    // 날짜순 정렬 (오래된 순)
    final sortedCheckins = List<DailyCheckin>.from(checkins)
      ..sort((a, b) => a.checkinDate.compareTo(b.checkinDate));

    final milestones = MilestoneConstants.streakDays;
    final achievedMilestones = <int, DateTime>{};

    int consecutiveDays = 0;
    DateTime? prevDate;

    for (final checkin in sortedCheckins) {
      final currentDate = DateTime(
        checkin.checkinDate.year,
        checkin.checkinDate.month,
        checkin.checkinDate.day,
      );

      if (prevDate == null) {
        consecutiveDays = 1;
      } else {
        final diff = currentDate.difference(prevDate).inDays;
        if (diff == 1) {
          consecutiveDays++;
        } else if (diff > 1) {
          consecutiveDays = 1; // 연속 끊김, 리셋
        }
        // diff == 0인 경우 (같은 날) 무시
      }

      // 마일스톤 달성 체크
      for (final milestone in milestones) {
        if (consecutiveDays >= milestone &&
            !achievedMilestones.containsKey(milestone)) {
          achievedMilestones[milestone] = currentDate;
        }
      }

      if (currentDate != prevDate) {
        prevDate = currentDate;
      }
    }

    // 달성한 마일스톤들을 이벤트로 추가
    for (final entry in achievedMilestones.entries) {
      events.add(
        TimelineEvent(
          id: 'checkin_milestone_${entry.key}',
          dateTime: entry.value,
          eventType: TimelineEventType.checkinMilestone,
          titleMessageType: DashboardMessageType.timelineCheckinMilestone,
          checkinDays: entry.key,
        ),
      );
    }
  }

  InsightMessageData? _generateInsightMessageData(
    int continuousRecordDays,
    double weightProgressPercentage,
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

    // 우선순위 2: 목표 체중 진행률
    if (weightProgressPercentage >= 100) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeightGoalReached,
      );
    }

    if (weightProgressPercentage >= 75) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeight75Percent,
      );
    }

    if (weightProgressPercentage >= 50) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeight50Percent,
      );
    }

    if (weightProgressPercentage >= 25) {
      return InsightMessageData(
        type: DashboardMessageType.insightWeight25Percent,
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

  /// 뱃지 상태 변경 시 DB에 동기화
  Future<void> _syncBadgesToDatabase(
    List<UserBadge> oldBadges,
    List<UserBadge> newBadges,
  ) async {
    for (final newBadge in newBadges) {
      final oldBadge = oldBadges.firstWhere(
        (b) => b.badgeId == newBadge.badgeId,
        orElse: () => newBadge,
      );

      // 상태나 진행률이 변경된 경우에만 업데이트
      if (oldBadge.status != newBadge.status ||
          oldBadge.progressPercentage != newBadge.progressPercentage) {
        await _badgeRepository.updateBadgeProgress(newBadge);
      }
    }
  }
}

/// Alias for backwards compatibility
const dashboardNotifierProvider = dashboardProvider;

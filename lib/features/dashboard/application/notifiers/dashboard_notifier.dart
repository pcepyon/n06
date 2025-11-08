import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/next_schedule.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_summary.dart';
import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_adherence_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_continuous_record_days_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_current_week_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_weight_goal_estimate_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_weekly_progress_usecase.dart';
import 'package:n06/features/dashboard/domain/usecases/verify_badge_conditions_usecase.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_notifier.g.dart';

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  late ProfileRepository _profileRepository;
  late TrackingRepository _trackingRepository;
  late MedicationRepository _medicationRepository;
  late BadgeRepository _badgeRepository;

  final _calculateContinuousRecordDays = CalculateContinuousRecordDaysUseCase();
  final _calculateCurrentWeek = CalculateCurrentWeekUseCase();
  final _calculateWeeklyProgress = CalculateWeeklyProgressUseCase();
  final _calculateAdherence = CalculateAdherenceUseCase();
  final _calculateWeightGoalEstimate = CalculateWeightGoalEstimateUseCase();
  final _verifyBadgeConditions = VerifyBadgeConditionsUseCase();

  @override
  Future<DashboardData> build() async {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _trackingRepository = ref.watch(trackingRepositoryProvider);
    _medicationRepository = ref.watch(medicationRepositoryProvider);
    _badgeRepository = ref.watch(badgeRepositoryProvider);

    return _loadDashboardData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboardData());
  }

  Future<DashboardData> _loadDashboardData() async {
    // 프로필 조회
    final profile = await _profileRepository.getUserProfile();
    if (profile == null) {
      throw Exception('User profile not found');
    }

    // 투여 기록, 체중 기록, 부작용 기록 조회
    final doseRecords = await _medicationRepository.getDoseRecords(null);
    final schedules = await _medicationRepository.getDoseSchedules(null);
    final weights = await _trackingRepository.getWeightLogs();
    final symptoms = await _trackingRepository.getSymptomLogs();

    // 활성 투여 계획 조회
    final activePlan = await _medicationRepository.getActiveDosagePlan();
    if (activePlan == null) {
      throw Exception('Active dosage plan not found');
    }

    // 연속 기록일 계산
    final continuousRecordDays = _calculateContinuousRecordDays.execute(weights, symptoms);

    // 현재 주차 계산
    final currentWeek = _calculateCurrentWeek.execute(activePlan.startDate);

    // 주간 목표 진행도 계산
    final weeklyProgress = _calculateWeeklyProgress.execute(
      doseRecords: doseRecords,
      weightLogs: weights,
      symptomLogs: symptoms,
      doseTargetCount: schedules.where((s) => s.scheduledDate.isAfter(DateTime.now().subtract(Duration(days: 7)))).length,
      weightTargetCount: profile.weeklyWeightRecordGoal,
      symptomTargetCount: profile.weeklySymptomRecordGoal,
    );

    // 다음 투여 일정
    final nextSchedule = _calculateNextSchedule(schedules, weights);

    // 주간 요약
    final weeklySummary = _calculateWeeklySummary(doseRecords, weights, symptoms, schedules);

    // 뱃지 조회 및 검증
    final userBadges = await _badgeRepository.getUserBadges(profile.userId);
    final currentWeightKg = weights.isNotEmpty
        ? weights.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b).weightKg
        : profile.targetWeightKg + 5; // 기본값
    final startWeightKg = weights.isNotEmpty
        ? weights.reduce((a, b) => a.logDate.isBefore(b.logDate) ? a : b).weightKg
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
    final timeline = _buildTimeline(doseRecords, schedules, weights);

    return DashboardData(
      userName: profile.userId,
      continuousRecordDays: continuousRecordDays,
      currentWeek: currentWeek,
      weeklyProgress: weeklyProgress,
      nextSchedule: nextSchedule,
      weeklySummary: weeklySummary,
      badges: updatedBadges,
      timeline: timeline,
      insightMessage: _generateInsightMessage(
        continuousRecordDays,
        weightLossPercentage,
        weeklyProgress,
      ),
    );
  }

  NextSchedule _calculateNextSchedule(
    List<dynamic> schedules,
    List<dynamic> weights,
  ) {
    // 다음 투여 일정 계산 (임시)
    final now = DateTime.now();
    final nextDoseDate = now.add(Duration(days: 1));
    final nextDoseMg = 0.5;
    final nextEscalationDate = now.add(Duration(days: 14));

    final currentWeightKg = weights.isNotEmpty
        ? (weights as List).reduce((a, b) {
            final aDate = (a as dynamic).logDate as DateTime;
            final bDate = (b as dynamic).logDate as DateTime;
            return aDate.isAfter(bDate) ? a : b;
          }).weightKg as double
        : 70.0;
    const targetWeightKg = 65.0;
    final goalEstimateDate = now.add(Duration(days: 60));

    return NextSchedule(
      nextDoseDate: nextDoseDate,
      nextDoseMg: nextDoseMg,
      nextEscalationDate: nextEscalationDate,
      goalEstimateDate: goalEstimateDate,
    );
  }

  WeeklySummary _calculateWeeklySummary(
    List<dynamic> doseRecords,
    List<dynamic> weights,
    List<dynamic> symptoms,
    List<dynamic> schedules,
  ) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));

    final doseCount = (doseRecords as List)
        .where((r) {
          final date = (r as dynamic).administeredAt as DateTime;
          return date.isAfter(sevenDaysAgo);
        })
        .length;

    final weightLogs = weights as List;
    final weightChange = weightLogs.length >= 2
        ? ((weightLogs[0] as dynamic).weightKg as double) -
            ((weightLogs[weightLogs.length - 1] as dynamic).weightKg as double)
        : 0.0;

    final symptomCount = (symptoms as List)
        .where((s) {
          final date = (s as dynamic).logDate as DateTime;
          return date.isAfter(sevenDaysAgo);
        })
        .length;

    return WeeklySummary(
      doseCompletedCount: doseCount,
      weightChangeKg: weightChange,
      symptomRecordCount: symptomCount,
      adherencePercentage: 85.0,
    );
  }

  List<TimelineEvent> _buildTimeline(
    List<dynamic> doseRecords,
    List<dynamic> schedules,
    List<dynamic> weights,
  ) {
    // 타임라인 생성 (임시)
    return [];
  }

  String? _generateInsightMessage(
    int continuousRecordDays,
    double weightLossPercentage,
    dynamic weeklyProgress,
  ) {
    if (continuousRecordDays >= 7) {
      return '축하합니다! 연속 $continuousRecordDays일 기록을 달성했어요';
    }
    if (weightLossPercentage >= 1.0) {
      return '현재 추세라면 2개월 내 목표 달성 가능해요';
    }
    return '오늘도 함께 목표를 향해 나아가요!';
  }
}

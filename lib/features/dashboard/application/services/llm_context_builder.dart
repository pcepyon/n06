import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/dashboard/domain/entities/ai_generated_message.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:n06/features/dashboard/domain/entities/llm_context.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

/// Service for building LLM context from various data sources.
///
/// This service aggregates data from dashboard, medication records,
/// trends, and recent messages to construct the complete context
/// needed for AI message generation.
///
/// Location: Application Layer (orchestrates domain entities and repositories)
class LLMContextBuilder {
  final MedicationRepository _medicationRepository;
  final TrackingRepository _trackingRepository;
  final DailyCheckinRepository _dailyCheckinRepository;

  LLMContextBuilder({
    required MedicationRepository medicationRepository,
    required TrackingRepository trackingRepository,
    required DailyCheckinRepository dailyCheckinRepository,
  })  : _medicationRepository = medicationRepository,
        _trackingRepository = trackingRepository,
        _dailyCheckinRepository = dailyCheckinRepository;

  /// Builds complete LLM context from dashboard data and related sources.
  ///
  /// Parameters:
  /// - [dashboardData]: Current dashboard state with user info and progress
  /// - [dosagePlan]: Active dosage plan for the user
  /// - [trendInsight]: Health trends and condition analysis (nullable)
  /// - [recentMessages]: Recent AI-generated messages for tone consistency
  /// - [triggerType]: What triggered this message generation
  /// - [recentCheckinSummary]: Summary of today's check-in (only for post-checkin)
  Future<LLMContext> buildContext({
    required DashboardData dashboardData,
    required DosagePlan dosagePlan,
    required TrendInsight? trendInsight,
    required List<AIGeneratedMessage> recentMessages,
    required MessageTriggerType triggerType,
    String? recentCheckinSummary,
  }) async {
    // Build user context
    final userContext = await _buildUserContext(
      dashboardData: dashboardData,
      dosagePlan: dosagePlan,
    );

    // Get latest checkin for Red Flag and days since last checkin
    final latestCheckin = await _dailyCheckinRepository.getLatest(dosagePlan.userId);

    // Build health data
    final healthData = _buildHealthData(
      dashboardData: dashboardData,
      trendInsight: trendInsight,
      recentCheckinSummary: recentCheckinSummary,
      latestCheckin: latestCheckin,
    );

    // Extract message texts only
    final messageTexts = recentMessages.map((m) => m.message).toList();

    return LLMContext(
      userContext: userContext,
      healthData: healthData,
      recentMessages: messageTexts,
      triggerType: triggerType,
    );
  }

  /// Builds user context from dashboard data and dosage plan.
  Future<UserContext> _buildUserContext({
    required DashboardData dashboardData,
    required DosagePlan dosagePlan,
  }) async {
    // Get dose records to find last dose
    final doseRecords = await _medicationRepository.getDoseRecords(dosagePlan.id);

    // Sort by administered date (newest first)
    final sortedRecords = List<DoseRecord>.from(doseRecords)
      ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));

    // Calculate days since last dose
    final daysSinceLastDose = sortedRecords.isNotEmpty
        ? sortedRecords.first.daysSinceAdministration()
        : 0;

    // Calculate days until next dose (from nextSchedule)
    final daysUntilNextDose = _calculateDaysUntil(
      dashboardData.nextSchedule.nextDoseDate,
    );

    // Get latest escalation date
    final latestEscalationDate = await _trackingRepository.getLatestDoseEscalationDate(
      dosagePlan.userId,
    );

    // Calculate days since escalation (날짜만 비교, 시간 제외)
    final daysSinceEscalation = latestEscalationDate != null
        ? (() {
            final now = DateTime.now();
            final nowDate = DateTime(now.year, now.month, now.day);
            final escalationDate = DateTime(
              latestEscalationDate.year,
              latestEscalationDate.month,
              latestEscalationDate.day,
            );
            return nowDate.difference(escalationDate).inDays;
          })()
        : null;

    // Calculate days until next escalation
    final nextEscalationInDays = dashboardData.nextSchedule.nextEscalationDate != null
        ? _calculateDaysUntil(dashboardData.nextSchedule.nextEscalationDate!)
        : null;

    // 치료 시작일 기준 여정 일수 계산 (startDate가 0일째)
    final journeyDay = _calculateJourneyDay(dosagePlan.startDate);

    return UserContext(
      name: dashboardData.userName,
      journeyDay: journeyDay,
      currentWeek: dashboardData.currentWeek,
      currentDoseMg: dashboardData.nextSchedule.nextDoseMg,
      daysSinceLastDose: daysSinceLastDose,
      daysUntilNextDose: daysUntilNextDose,
      daysSinceEscalation: daysSinceEscalation,
      nextEscalationInDays: nextEscalationInDays,
    );
  }

  /// Builds health data from dashboard data and trend insight.
  HealthData _buildHealthData({
    required DashboardData dashboardData,
    required TrendInsight? trendInsight,
    String? recentCheckinSummary,
    DailyCheckin? latestCheckin,
  }) {
    // Calculate weight change this week
    // Using weeklySummary's weight change if available
    final weightChangeThisWeekKg = dashboardData.weeklySummary.weightChangeKg;

    // Map TrendDirection to string for weight trend
    final weightTrend = trendInsight != null
        ? _mapTrendDirectionToString(trendInsight.overallDirection)
        : 'stable';

    // Map TrendDirection to string for overall condition
    final overallCondition = trendInsight != null
        ? _mapTrendDirectionToString(trendInsight.overallDirection)
        : 'stable';

    // Calculate completion rate from TrendInsight or WeeklyProgress
    final completionRate = trendInsight?.completionRate ??
        _calculateCompletionRateFromProgress(dashboardData.weeklyProgress);

    // Determine top concern from trend insight
    final topConcern = trendInsight?.patternInsight.topConcernArea?.name;

    // Red Flag detection from latest checkin
    final hasRedFlag = latestCheckin?.redFlagDetected != null;
    final redFlagType = latestCheckin?.redFlagDetected?.type.name;

    // Calculate days since last checkin (for "return after break" detection)
    final daysSinceLastCheckin = latestCheckin != null
        ? _calculateDaysSince(latestCheckin.checkinDate)
        : 0;

    return HealthData(
      weightChangeThisWeekKg: weightChangeThisWeekKg,
      weightTrend: weightTrend,
      overallCondition: overallCondition,
      completionRate: completionRate,
      topConcern: topConcern,
      recentCheckinSummary: recentCheckinSummary,
      hasRedFlag: hasRedFlag,
      redFlagType: redFlagType,
      daysSinceLastCheckin: daysSinceLastCheckin,
    );
  }

  /// Calculates days since a past date.
  int _calculateDaysSince(DateTime pastDate) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final past = DateTime(pastDate.year, pastDate.month, pastDate.day);
    return todayDate.difference(past).inDays;
  }

  /// Maps TrendDirection enum to string format expected by LLM.
  String _mapTrendDirectionToString(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return 'improving';
      case TrendDirection.stable:
        return 'stable';
      case TrendDirection.worsening:
        return 'worsening';
    }
  }

  /// Calculates completion rate from weekly progress.
  double _calculateCompletionRateFromProgress(dynamic weeklyProgress) {
    // Average of all three rates (dose, weight, symptom)
    final totalRate = (weeklyProgress.doseRate +
                      weeklyProgress.weightRate +
                      weeklyProgress.symptomRate) / 3;
    return totalRate;
  }

  /// Calculates days until a target date from today.
  ///
  /// Returns positive number for future dates, negative for past dates.
  int _calculateDaysUntil(DateTime targetDate) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(todayDate).inDays;
  }

  /// Calculates journey day from treatment start date.
  ///
  /// Day 0 = start date, Day 1 = next day, etc.
  /// This represents "치료 시작 N일째" as per llm-message-spec.md.
  int _calculateJourneyDay(DateTime startDate) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return todayDate.difference(start).inDays;
  }
}

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

  LLMContextBuilder({
    required MedicationRepository medicationRepository,
    required TrackingRepository trackingRepository,
  })  : _medicationRepository = medicationRepository,
        _trackingRepository = trackingRepository;

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

    // Build health data
    final healthData = _buildHealthData(
      dashboardData: dashboardData,
      trendInsight: trendInsight,
      recentCheckinSummary: recentCheckinSummary,
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

    // Calculate days since escalation
    final daysSinceEscalation = latestEscalationDate != null
        ? DateTime.now().difference(latestEscalationDate).inDays
        : null;

    // Calculate days until next escalation
    final nextEscalationInDays = dashboardData.nextSchedule.nextEscalationDate != null
        ? _calculateDaysUntil(dashboardData.nextSchedule.nextEscalationDate!)
        : null;

    return UserContext(
      name: dashboardData.userName,
      journeyDay: dashboardData.continuousRecordDays,
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

    return HealthData(
      weightChangeThisWeekKg: weightChangeThisWeekKg,
      weightTrend: weightTrend,
      overallCondition: overallCondition,
      completionRate: completionRate,
      topConcern: topConcern,
      recentCheckinSummary: recentCheckinSummary,
    );
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
}

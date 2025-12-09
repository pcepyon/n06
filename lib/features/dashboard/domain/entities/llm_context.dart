import 'package:equatable/equatable.dart';
import 'package:n06/features/dashboard/domain/entities/ai_generated_message.dart';

/// Extension for JSON serialization of MessageTriggerType
extension MessageTriggerTypeExtension on MessageTriggerType {
  String toJson() {
    switch (this) {
      case MessageTriggerType.dailyFirstOpen:
        return 'daily_first_open';
      case MessageTriggerType.postCheckin:
        return 'post_checkin';
    }
  }

  static MessageTriggerType fromJson(String value) {
    switch (value) {
      case 'daily_first_open':
        return MessageTriggerType.dailyFirstOpen;
      case 'post_checkin':
        return MessageTriggerType.postCheckin;
      default:
        throw ArgumentError('Invalid trigger type: $value');
    }
  }
}

/// User context for LLM message generation.
///
/// Contains user journey and dosage information that helps LLM
/// understand where the user is in their GLP-1 treatment journey.
class UserContext extends Equatable {
  /// User's display name
  final String name;

  /// Number of days since starting the journey
  final int journeyDay;

  /// Current week in the treatment plan
  final int currentWeek;

  /// Current dosage in milligrams
  final double currentDoseMg;

  /// Days elapsed since last dose administration
  final int daysSinceLastDose;

  /// Days remaining until next dose
  final int daysUntilNextDose;

  /// Days elapsed since last escalation (null if never escalated)
  final int? daysSinceEscalation;

  /// Days until next escalation (null if no escalation planned)
  final int? nextEscalationInDays;

  const UserContext({
    required this.name,
    required this.journeyDay,
    required this.currentWeek,
    required this.currentDoseMg,
    required this.daysSinceLastDose,
    required this.daysUntilNextDose,
    this.daysSinceEscalation,
    this.nextEscalationInDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'journey_day': journeyDay,
      'current_week': currentWeek,
      'current_dose_mg': currentDoseMg,
      'days_since_last_dose': daysSinceLastDose,
      'days_until_next_dose': daysUntilNextDose,
      'days_since_escalation': daysSinceEscalation,
      'next_escalation_in_days': nextEscalationInDays,
    };
  }

  @override
  List<Object?> get props => [
        name,
        journeyDay,
        currentWeek,
        currentDoseMg,
        daysSinceLastDose,
        daysUntilNextDose,
        daysSinceEscalation,
        nextEscalationInDays,
      ];
}

/// Health data for LLM message generation.
///
/// Contains recent health trends and check-in information that helps LLM
/// provide contextually relevant empathetic messages.
class HealthData extends Equatable {
  /// Weight change in kg during current week (can be negative)
  final double weightChangeThisWeekKg;

  /// Overall weight trend: 'increasing', 'stable', or 'decreasing'
  final String weightTrend;

  /// Overall condition trend: 'improving', 'stable', or 'worsening'
  final String overallCondition;

  /// Completion rate for check-ins (0.0 to 1.0)
  final double completionRate;

  /// Top concern area (nullable, e.g., 'meal', 'giComfort')
  final String? topConcern;

  /// Summary of today's check-in (nullable, only for post-checkin trigger)
  final String? recentCheckinSummary;

  /// Whether today's check-in detected a Red Flag (urgent medical attention)
  final bool hasRedFlag;

  /// Red Flag type if detected (e.g., 'pancreatitis', 'severeDehydration')
  final String? redFlagType;

  /// Days since last check-in (for "return after break" detection)
  final int daysSinceLastCheckin;

  const HealthData({
    required this.weightChangeThisWeekKg,
    required this.weightTrend,
    required this.overallCondition,
    required this.completionRate,
    this.topConcern,
    this.recentCheckinSummary,
    this.hasRedFlag = false,
    this.redFlagType,
    this.daysSinceLastCheckin = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight_change_this_week_kg': weightChangeThisWeekKg,
      'weight_trend': weightTrend,
      'overall_condition': overallCondition,
      'completion_rate': completionRate,
      'top_concern': topConcern,
      'recent_checkin_summary': recentCheckinSummary,
      'has_red_flag': hasRedFlag,
      'red_flag_type': redFlagType,
      'days_since_last_checkin': daysSinceLastCheckin,
    };
  }

  @override
  List<Object?> get props => [
        weightChangeThisWeekKg,
        weightTrend,
        overallCondition,
        completionRate,
        topConcern,
        recentCheckinSummary,
        hasRedFlag,
        redFlagType,
        daysSinceLastCheckin,
      ];
}

/// Complete context for LLM message generation.
///
/// Bundles user context, health data, recent messages, and trigger type
/// into a single JSON-serializable structure that can be sent to the
/// Edge Function for LLM processing.
class LLMContext extends Equatable {
  /// User journey and dosage context
  final UserContext userContext;

  /// Health trends and check-in data
  final HealthData healthData;

  /// Recent message texts for tone consistency (up to 7 messages)
  final List<String> recentMessages;

  /// What triggered this message generation
  final MessageTriggerType triggerType;

  const LLMContext({
    required this.userContext,
    required this.healthData,
    required this.recentMessages,
    required this.triggerType,
  });

  /// Converts to JSON format expected by Edge Function
  Map<String, dynamic> toJson() {
    return {
      'user_context': userContext.toJson(),
      'health_data': healthData.toJson(),
      'recent_messages': recentMessages,
      'trigger_type': triggerType.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        userContext,
        healthData,
        recentMessages,
        triggerType,
      ];
}

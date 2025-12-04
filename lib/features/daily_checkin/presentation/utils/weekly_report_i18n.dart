import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/domain/entities/report_section_type.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';

/// Weekly report i18n mapping utilities
///
/// Converts data-only enums and values from Application layer to localized strings.
class WeeklyReportI18n {
  /// Symptom type to localized string
  static String symptomTypeName(BuildContext context, SymptomType type) {
    return switch (type) {
      SymptomType.nausea => context.l10n.report_symptom_nausea,
      SymptomType.vomiting => context.l10n.report_symptom_vomiting,
      SymptomType.lowAppetite => context.l10n.report_symptom_lowAppetite,
      SymptomType.earlySatiety => context.l10n.report_symptom_earlySatiety,
      SymptomType.heartburn => context.l10n.report_symptom_heartburn,
      SymptomType.abdominalPain => context.l10n.report_symptom_abdominalPain,
      SymptomType.bloating => context.l10n.report_symptom_bloating,
      SymptomType.constipation => context.l10n.report_symptom_constipation,
      SymptomType.diarrhea => context.l10n.report_symptom_diarrhea,
      SymptomType.fatigue => context.l10n.report_symptom_fatigue,
      SymptomType.dizziness => context.l10n.report_symptom_dizziness,
      SymptomType.coldSweat => context.l10n.report_symptom_coldSweat,
      SymptomType.swelling => context.l10n.report_symptom_swelling,
    };
  }

  /// Red flag type to localized string
  static String redFlagTypeName(BuildContext context, RedFlagType type) {
    return switch (type) {
      RedFlagType.pancreatitis => context.l10n.report_redFlag_pancreatitis,
      RedFlagType.cholecystitis => context.l10n.report_redFlag_cholecystitis,
      RedFlagType.severeDehydration => context.l10n.report_redFlag_severeDehydration,
      RedFlagType.bowelObstruction => context.l10n.report_redFlag_bowelObstruction,
      RedFlagType.hypoglycemia => context.l10n.report_redFlag_hypoglycemia,
      RedFlagType.renalImpairment => context.l10n.report_redFlag_renalImpairment,
    };
  }

  /// Appetite stability to localized string
  static String appetiteStabilityName(BuildContext context, AppetiteStability stability) {
    return switch (stability) {
      AppetiteStability.stable => context.l10n.report_appetiteStability_stable,
      AppetiteStability.improving => context.l10n.report_appetiteStability_improving,
      AppetiteStability.declining => context.l10n.report_appetiteStability_declining,
    };
  }

  /// Weight change direction to localized string with value
  static String weightChange(BuildContext context, WeightChangeDirection direction, double change) {
    return switch (direction) {
      WeightChangeDirection.increased => context.l10n.report_weightChange_increased(change.abs()),
      WeightChangeDirection.decreased => context.l10n.report_weightChange_decreased(change.abs()),
      WeightChangeDirection.maintained => context.l10n.report_weightChange_maintained,
    };
  }

  /// Mood to emoji
  static String moodToEmoji(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.good => '😊',
      MoodLevel.neutral => '😐',
      MoodLevel.low => '😔',
    };
  }

  /// Day of week to localized string
  static String dayOfWeek(BuildContext context, DateTime date) {
    return switch (date.weekday) {
      1 => context.l10n.report_dayOfWeek_monday,
      2 => context.l10n.report_dayOfWeek_tuesday,
      3 => context.l10n.report_dayOfWeek_wednesday,
      4 => context.l10n.report_dayOfWeek_thursday,
      5 => context.l10n.report_dayOfWeek_friday,
      6 => context.l10n.report_dayOfWeek_saturday,
      7 => context.l10n.report_dayOfWeek_sunday,
      _ => '',
    };
  }

  /// Short day of week (for compact display)
  static String dayOfWeekShort(BuildContext context, DateTime date) {
    return switch (date.weekday) {
      1 => context.l10n.report_dayOfWeek_mondayShort,
      2 => context.l10n.report_dayOfWeek_tuesdayShort,
      3 => context.l10n.report_dayOfWeek_wednesdayShort,
      4 => context.l10n.report_dayOfWeek_thursdayShort,
      5 => context.l10n.report_dayOfWeek_fridayShort,
      6 => context.l10n.report_dayOfWeek_saturdayShort,
      7 => context.l10n.report_dayOfWeek_sundayShort,
      _ => '',
    };
  }

  /// Severity summary for symptom occurrence
  static String severitySummary(BuildContext context, Map<String, int> counts) {
    final parts = <String>[];

    if (counts['mild'] != null && counts['mild']! > 0) {
      parts.add(context.l10n.report_severity_mildCount(counts['mild']!));
    }
    if (counts['moderate'] != null && counts['moderate']! > 0) {
      parts.add(context.l10n.report_severity_moderateCount(counts['moderate']!));
    }
    if (counts['severe'] != null && counts['severe']! > 0) {
      parts.add(context.l10n.report_severity_severeCount(counts['severe']!));
    }

    return parts.isEmpty ? '' : '(${parts.join(', ')})';
  }
}

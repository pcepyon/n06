import 'dart:convert';

import '../../domain/entities/checkin_context.dart';
import '../../domain/entities/daily_checkin.dart';
import '../../domain/entities/red_flag_detection.dart';
import '../../domain/entities/symptom_detail.dart';

/// Supabase DTO for DailyCheckin entity.
///
/// Handles conversion between Supabase database JSON and domain entities.
/// Includes JSONB field parsing for symptom_details, context, and red_flag_detected.
class DailyCheckinDto {
  final String id;
  final String userId;
  final DateTime checkinDate;
  final String mealCondition;
  final String hydrationLevel;
  final String giComfort;
  final String bowelCondition;
  final String energyLevel;
  final String mood;
  final int? appetiteScore;
  final String? symptomDetails; // JSONB as String
  final String? context; // JSONB as String
  final String? redFlagDetected; // JSONB as String
  final DateTime createdAt;

  const DailyCheckinDto({
    required this.id,
    required this.userId,
    required this.checkinDate,
    required this.mealCondition,
    required this.hydrationLevel,
    required this.giComfort,
    required this.bowelCondition,
    required this.energyLevel,
    required this.mood,
    this.appetiteScore,
    this.symptomDetails,
    this.context,
    this.redFlagDetected,
    required this.createdAt,
  });

  /// Creates DTO from Supabase JSON.
  factory DailyCheckinDto.fromJson(Map<String, dynamic> json) {
    return DailyCheckinDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkinDate: DateTime.parse(json['checkin_date'] as String).toLocal(),
      mealCondition: json['meal_condition'] as String,
      hydrationLevel: json['hydration_level'] as String,
      giComfort: json['gi_comfort'] as String,
      bowelCondition: json['bowel_condition'] as String,
      energyLevel: json['energy_level'] as String,
      mood: json['mood'] as String,
      appetiteScore: json['appetite_score'] as int?,
      symptomDetails: json['symptom_details'] != null
          ? jsonEncode(json['symptom_details'])
          : null,
      context: json['context'] != null ? jsonEncode(json['context']) : null,
      redFlagDetected: json['red_flag_detected'] != null
          ? jsonEncode(json['red_flag_detected'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'checkin_date': checkinDate.toIso8601String().split('T')[0],
      'meal_condition': mealCondition,
      'hydration_level': hydrationLevel,
      'gi_comfort': giComfort,
      'bowel_condition': bowelCondition,
      'energy_level': energyLevel,
      'mood': mood,
      'appetite_score': appetiteScore,
      'symptom_details':
          symptomDetails != null ? jsonDecode(symptomDetails!) : null,
      'context': context != null ? jsonDecode(context!) : null,
      'red_flag_detected':
          redFlagDetected != null ? jsonDecode(redFlagDetected!) : null,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  DailyCheckin toEntity() {
    return DailyCheckin(
      id: id,
      userId: userId,
      checkinDate: checkinDate,
      mealCondition: _parseConditionLevel(mealCondition),
      hydrationLevel: _parseHydrationLevel(hydrationLevel),
      giComfort: _parseGiComfortLevel(giComfort),
      bowelCondition: _parseBowelCondition(bowelCondition),
      energyLevel: _parseEnergyLevel(energyLevel),
      mood: _parseMoodLevel(mood),
      appetiteScore: appetiteScore,
      symptomDetails: symptomDetails != null
          ? _parseSymptomDetails(jsonDecode(symptomDetails!))
          : null,
      context: context != null ? _parseContext(jsonDecode(context!)) : null,
      redFlagDetected: redFlagDetected != null
          ? _parseRedFlagDetection(jsonDecode(redFlagDetected!))
          : null,
      createdAt: createdAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory DailyCheckinDto.fromEntity(DailyCheckin entity) {
    return DailyCheckinDto(
      id: entity.id,
      userId: entity.userId,
      checkinDate: entity.checkinDate,
      mealCondition: _conditionLevelToString(entity.mealCondition),
      hydrationLevel: _hydrationLevelToString(entity.hydrationLevel),
      giComfort: _giComfortLevelToString(entity.giComfort),
      bowelCondition: _bowelConditionToString(entity.bowelCondition),
      energyLevel: _energyLevelToString(entity.energyLevel),
      mood: _moodLevelToString(entity.mood),
      appetiteScore: entity.appetiteScore,
      symptomDetails: entity.symptomDetails != null
          ? jsonEncode(_symptomDetailsToJson(entity.symptomDetails!))
          : null,
      context: entity.context != null
          ? jsonEncode(_contextToJson(entity.context!))
          : null,
      redFlagDetected: entity.redFlagDetected != null
          ? jsonEncode(_redFlagDetectionToJson(entity.redFlagDetected!))
          : null,
      createdAt: entity.createdAt,
    );
  }

  // ============================================
  // Enum Conversion Methods
  // ============================================

  static ConditionLevel _parseConditionLevel(String value) {
    switch (value) {
      case 'good':
        return ConditionLevel.good;
      case 'moderate':
        return ConditionLevel.moderate;
      case 'difficult':
        return ConditionLevel.difficult;
      default:
        // 방어 로직: 알 수 없는 값은 기본값 반환 (BUG-20251202-ENUMDEFENSE)
        return ConditionLevel.good;
    }
  }

  static String _conditionLevelToString(ConditionLevel level) {
    switch (level) {
      case ConditionLevel.good:
        return 'good';
      case ConditionLevel.moderate:
        return 'moderate';
      case ConditionLevel.difficult:
        return 'difficult';
    }
  }

  static HydrationLevel _parseHydrationLevel(String value) {
    switch (value) {
      case 'good':
        return HydrationLevel.good;
      case 'moderate':
        return HydrationLevel.moderate;
      case 'poor':
        return HydrationLevel.poor;
      default:
        return HydrationLevel.good;
    }
  }

  static String _hydrationLevelToString(HydrationLevel level) {
    switch (level) {
      case HydrationLevel.good:
        return 'good';
      case HydrationLevel.moderate:
        return 'moderate';
      case HydrationLevel.poor:
        return 'poor';
    }
  }

  static GiComfortLevel _parseGiComfortLevel(String value) {
    switch (value) {
      case 'good':
        return GiComfortLevel.good;
      case 'uncomfortable':
        return GiComfortLevel.uncomfortable;
      case 'very_uncomfortable':
        return GiComfortLevel.veryUncomfortable;
      default:
        return GiComfortLevel.good;
    }
  }

  static String _giComfortLevelToString(GiComfortLevel level) {
    switch (level) {
      case GiComfortLevel.good:
        return 'good';
      case GiComfortLevel.uncomfortable:
        return 'uncomfortable';
      case GiComfortLevel.veryUncomfortable:
        return 'very_uncomfortable';
    }
  }

  static BowelCondition _parseBowelCondition(String value) {
    switch (value) {
      case 'normal':
        return BowelCondition.normal;
      case 'irregular':
        return BowelCondition.irregular;
      case 'difficult':
        return BowelCondition.difficult;
      default:
        return BowelCondition.normal;
    }
  }

  static String _bowelConditionToString(BowelCondition condition) {
    switch (condition) {
      case BowelCondition.normal:
        return 'normal';
      case BowelCondition.irregular:
        return 'irregular';
      case BowelCondition.difficult:
        return 'difficult';
    }
  }

  static EnergyLevel _parseEnergyLevel(String value) {
    switch (value) {
      case 'good':
        return EnergyLevel.good;
      case 'normal':
        return EnergyLevel.normal;
      case 'tired':
        return EnergyLevel.tired;
      default:
        return EnergyLevel.good;
    }
  }

  static String _energyLevelToString(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.good:
        return 'good';
      case EnergyLevel.normal:
        return 'normal';
      case EnergyLevel.tired:
        return 'tired';
    }
  }

  static MoodLevel _parseMoodLevel(String value) {
    switch (value) {
      case 'good':
        return MoodLevel.good;
      case 'neutral':
        return MoodLevel.neutral;
      case 'low':
        return MoodLevel.low;
      default:
        return MoodLevel.good;
    }
  }

  static String _moodLevelToString(MoodLevel level) {
    switch (level) {
      case MoodLevel.good:
        return 'good';
      case MoodLevel.neutral:
        return 'neutral';
      case MoodLevel.low:
        return 'low';
    }
  }

  // ============================================
  // JSONB Parsing Methods
  // ============================================

  /// Parse symptom_details JSONB field
  static List<SymptomDetail> _parseSymptomDetails(dynamic json) {
    if (json is! List) return [];

    return json.map((item) {
      if (item is! Map<String, dynamic>) return null;

      final typeStr = item['type'] as String?;
      if (typeStr == null) return null;

      final severity = item['severity'] as int?;
      if (severity == null || severity < 1 || severity > 3) return null;

      return SymptomDetail(
        type: _parseSymptomType(typeStr),
        severity: severity,
        details: item['details'] as Map<String, dynamic>?,
      );
    }).whereType<SymptomDetail>().toList();
  }

  static List<Map<String, dynamic>> _symptomDetailsToJson(
    List<SymptomDetail> details,
  ) {
    return details
        .map((detail) => {
              'type': _symptomTypeToString(detail.type),
              'severity': detail.severity,
              if (detail.details != null) 'details': detail.details,
            })
        .toList();
  }

  static SymptomType _parseSymptomType(String value) {
    switch (value) {
      case 'nausea':
        return SymptomType.nausea;
      case 'vomiting':
        return SymptomType.vomiting;
      case 'low_appetite':
        return SymptomType.lowAppetite;
      case 'early_satiety':
        return SymptomType.earlySatiety;
      case 'heartburn':
        return SymptomType.heartburn;
      case 'abdominal_pain':
        return SymptomType.abdominalPain;
      case 'bloating':
        return SymptomType.bloating;
      case 'constipation':
        return SymptomType.constipation;
      case 'diarrhea':
        return SymptomType.diarrhea;
      case 'fatigue':
        return SymptomType.fatigue;
      case 'dizziness':
        return SymptomType.dizziness;
      case 'cold_sweat':
        return SymptomType.coldSweat;
      case 'swelling':
        return SymptomType.swelling;
      default:
        return SymptomType.nausea; // 기본값
    }
  }

  static String _symptomTypeToString(SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return 'nausea';
      case SymptomType.vomiting:
        return 'vomiting';
      case SymptomType.lowAppetite:
        return 'low_appetite';
      case SymptomType.earlySatiety:
        return 'early_satiety';
      case SymptomType.heartburn:
        return 'heartburn';
      case SymptomType.abdominalPain:
        return 'abdominal_pain';
      case SymptomType.bloating:
        return 'bloating';
      case SymptomType.constipation:
        return 'constipation';
      case SymptomType.diarrhea:
        return 'diarrhea';
      case SymptomType.fatigue:
        return 'fatigue';
      case SymptomType.dizziness:
        return 'dizziness';
      case SymptomType.coldSweat:
        return 'cold_sweat';
      case SymptomType.swelling:
        return 'swelling';
    }
  }

  /// Parse context JSONB field
  static CheckinContext _parseContext(Map<String, dynamic> json) {
    return CheckinContext(
      isPostInjection: json['is_post_injection'] as bool? ?? false,
      daysSinceLastCheckin: json['days_since_last_checkin'] as int? ?? 0,
      consecutiveDays: json['consecutive_days'] as int? ?? 0,
      greetingType: json['greeting_type'] as String?,
      weightSkipped: json['weight_skipped'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _contextToJson(CheckinContext context) {
    return {
      'is_post_injection': context.isPostInjection,
      'days_since_last_checkin': context.daysSinceLastCheckin,
      'consecutive_days': context.consecutiveDays,
      if (context.greetingType != null) 'greeting_type': context.greetingType,
      'weight_skipped': context.weightSkipped,
    };
  }

  /// Parse red_flag_detected JSONB field
  static RedFlagDetection _parseRedFlagDetection(Map<String, dynamic> json) {
    return RedFlagDetection(
      type: _parseRedFlagType(json['type'] as String),
      severity: _parseRedFlagSeverity(json['severity'] as String),
      symptoms: (json['symptoms'] as List?)?.cast<String>() ?? [],
      notifiedAt: json['notified_at'] != null
          ? DateTime.parse(json['notified_at'] as String).toLocal()
          : null,
      userAction: json['user_action'] as String?,
    );
  }

  static Map<String, dynamic> _redFlagDetectionToJson(
    RedFlagDetection detection,
  ) {
    return {
      'type': _redFlagTypeToString(detection.type),
      'severity': _redFlagSeverityToString(detection.severity),
      'symptoms': detection.symptoms,
      if (detection.notifiedAt != null)
        'notified_at': detection.notifiedAt!.toUtc().toIso8601String(),
      if (detection.userAction != null) 'user_action': detection.userAction,
    };
  }

  static RedFlagType _parseRedFlagType(String value) {
    switch (value) {
      case 'pancreatitis':
        return RedFlagType.pancreatitis;
      case 'cholecystitis':
        return RedFlagType.cholecystitis;
      case 'severe_dehydration':
        return RedFlagType.severeDehydration;
      case 'bowel_obstruction':
        return RedFlagType.bowelObstruction;
      case 'hypoglycemia':
        return RedFlagType.hypoglycemia;
      case 'renal_impairment':
        return RedFlagType.renalImpairment;
      default:
        return RedFlagType.pancreatitis; // 기본값 (안전한 side)
    }
  }

  static String _redFlagTypeToString(RedFlagType type) {
    switch (type) {
      case RedFlagType.pancreatitis:
        return 'pancreatitis';
      case RedFlagType.cholecystitis:
        return 'cholecystitis';
      case RedFlagType.severeDehydration:
        return 'severe_dehydration';
      case RedFlagType.bowelObstruction:
        return 'bowel_obstruction';
      case RedFlagType.hypoglycemia:
        return 'hypoglycemia';
      case RedFlagType.renalImpairment:
        return 'renal_impairment';
    }
  }

  static RedFlagSeverity _parseRedFlagSeverity(String value) {
    switch (value) {
      case 'warning':
        return RedFlagSeverity.warning;
      case 'urgent':
        return RedFlagSeverity.urgent;
      default:
        return RedFlagSeverity.warning; // 기본값
    }
  }

  static String _redFlagSeverityToString(RedFlagSeverity severity) {
    switch (severity) {
      case RedFlagSeverity.warning:
        return 'warning';
      case RedFlagSeverity.urgent:
        return 'urgent';
    }
  }

  @override
  String toString() => 'DailyCheckinDto('
      'id: $id, '
      'userId: $userId, '
      'checkinDate: $checkinDate, '
      'mealCondition: $mealCondition, '
      'hydrationLevel: $hydrationLevel, '
      'giComfort: $giComfort, '
      'bowelCondition: $bowelCondition, '
      'energyLevel: $energyLevel, '
      'mood: $mood, '
      'appetiteScore: $appetiteScore, '
      'createdAt: $createdAt'
      ')';
}

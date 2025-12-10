import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/core/encryption/domain/encryption_service.dart';

import '../../domain/entities/checkin_context.dart';
import '../../domain/entities/daily_checkin.dart';
import '../../domain/entities/red_flag_detection.dart';
import '../../domain/entities/symptom_detail.dart';
import '../../domain/repositories/daily_checkin_repository.dart';
import '../dtos/daily_checkin_dto.dart';

/// Repository 에러 타입
class DailyCheckinRepositoryException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;

  DailyCheckinRepositoryException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'DailyCheckinRepositoryException: $message';
}

/// Supabase implementation of DailyCheckinRepository
///
/// Manages daily check-in records in the daily_checkins table.
/// Implements consecutive days calculation logic as per spec 7.2.
/// Encrypts sensitive fields: symptom_details (JSONB→TEXT), appetite_score (INT→TEXT)
class SupabaseDailyCheckinRepository implements DailyCheckinRepository {
  final SupabaseClient _supabase;
  final EncryptionService _encryptionService;

  SupabaseDailyCheckinRepository(this._supabase, this._encryptionService);

  @override
  Future<DailyCheckin> save(DailyCheckin checkin) async {
    try {
      // 암호화 서비스 초기화
      await _encryptionService.initialize(checkin.userId);

      final dto = DailyCheckinDto.fromEntity(checkin);
      final json = dto.toJson();

      // 암호화: symptom_details, appetite_score
      if (checkin.symptomDetails != null) {
        final symptomJson = checkin.symptomDetails!.map((detail) => {
          'type': _symptomTypeToString(detail.type),
          'severity': detail.severity,
          if (detail.details != null) 'details': detail.details,
        }).toList();
        json['symptom_details'] = _encryptionService.encryptJsonList(symptomJson);
      } else {
        json['symptom_details'] = null;
      }
      json['appetite_score'] = _encryptionService.encryptInt(checkin.appetiteScore);

      // UPSERT: If checkin exists for the same date, update it
      // UNIQUE(user_id, checkin_date) constraint ensures this works correctly
      final response = await _supabase
          .from('daily_checkins')
          .upsert(
            json,
            onConflict: 'user_id,checkin_date',
          )
          .select()
          .single();

      return _decryptDailyCheckinFromJson(response);
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 저장 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 저장 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<DailyCheckin?> getByDate(String userId, DateTime date) async {
    try {
      // 암호화 서비스 초기화
      await _encryptionService.initialize(userId);

      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('daily_checkins')
          .select()
          .eq('user_id', userId)
          .eq('checkin_date', dateStr)
          .maybeSingle();

      if (response == null) return null;
      return _decryptDailyCheckinFromJson(response);
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<List<DailyCheckin>> getByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // 암호화 서비스 초기화
      await _encryptionService.initialize(userId);

      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('daily_checkins')
          .select()
          .eq('user_id', userId)
          .gte('checkin_date', startStr)
          .lte('checkin_date', endStr)
          .order('checkin_date', ascending: false);

      return (response as List)
          .map((json) => _decryptDailyCheckinFromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 목록 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 목록 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<DailyCheckin?> getLatest(String userId) async {
    try {
      // 암호화 서비스 초기화
      await _encryptionService.initialize(userId);

      final response = await _supabase
          .from('daily_checkins')
          .select()
          .eq('user_id', userId)
          .order('checkin_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return _decryptDailyCheckinFromJson(response);
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '최근 체크인 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '최근 체크인 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getConsecutiveDays(String userId) async {
    try {
      // Fetch all checkins for the user, ordered by date descending
      final response = await _supabase
          .from('daily_checkins')
          .select('checkin_date')
          .eq('user_id', userId)
          .order('checkin_date', ascending: false);

      if (response.isEmpty) return 0;

      // Extract unique dates
      final checkinDates = (response as List)
          .map((item) => DateTime.parse(item['checkin_date'] as String))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending (most recent first)

      // Calculate consecutive days from today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int consecutiveDays = 0;
      for (var i = 0; i < checkinDates.length; i++) {
        final expectedDate = today.subtract(Duration(days: i));
        final checkinDate = DateTime(
          checkinDates[i].year,
          checkinDates[i].month,
          checkinDates[i].day,
        );

        if (checkinDate == expectedDate) {
          consecutiveDays++;
        } else {
          // Gap found, stop counting
          break;
        }
      }

      return consecutiveDays;
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '연속 일수 조회 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '연속 일수 조회 중 오류 발생',
        originalError: e,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from('daily_checkins').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 삭제 실패',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DailyCheckinRepositoryException(
        '체크인 삭제 중 오류 발생',
        originalError: e,
      );
    }
  }

  /// JSON 응답에서 암호화된 필드 복호화 후 DailyCheckin 엔티티 생성
  DailyCheckin _decryptDailyCheckinFromJson(Map<String, dynamic> json) {
    // symptom_details 복호화
    List<SymptomDetail>? symptomDetails;
    final encryptedSymptoms = json['symptom_details'] as String?;
    if (encryptedSymptoms != null) {
      final decryptedList = _encryptionService.decryptJsonList(encryptedSymptoms);
      if (decryptedList != null) {
        symptomDetails = decryptedList.map((item) {
          final map = item as Map<String, dynamic>;
          return SymptomDetail(
            type: _parseSymptomType(map['type'] as String),
            severity: map['severity'] as int,
            details: map['details'] as Map<String, dynamic>?,
          );
        }).toList();
      }
    }

    // appetite_score 복호화
    final encryptedAppetite = json['appetite_score'] as String?;
    final appetiteScore = _encryptionService.decryptInt(encryptedAppetite);

    // context는 암호화 대상이 아님 (JSONB 유지)
    CheckinContext? context;
    if (json['context'] != null) {
      final contextData = json['context'] is String
          ? jsonDecode(json['context'] as String)
          : json['context'];
      context = _parseContext(contextData as Map<String, dynamic>);
    }

    // red_flag_detected도 암호화 대상이 아님 (JSONB 유지)
    RedFlagDetection? redFlagDetected;
    if (json['red_flag_detected'] != null) {
      final redFlagData = json['red_flag_detected'] is String
          ? jsonDecode(json['red_flag_detected'] as String)
          : json['red_flag_detected'];
      redFlagDetected = _parseRedFlagDetection(redFlagData as Map<String, dynamic>);
    }

    return DailyCheckin(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkinDate: DateTime.parse(json['checkin_date'] as String).toLocal(),
      mealCondition: _parseConditionLevel(json['meal_condition'] as String),
      hydrationLevel: _parseHydrationLevel(json['hydration_level'] as String),
      giComfort: _parseGiComfortLevel(json['gi_comfort'] as String),
      bowelCondition: _parseBowelCondition(json['bowel_condition'] as String),
      energyLevel: _parseEnergyLevel(json['energy_level'] as String),
      mood: _parseMoodLevel(json['mood'] as String),
      appetiteScore: appetiteScore,
      symptomDetails: symptomDetails,
      context: context,
      redFlagDetected: redFlagDetected,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // ============================================
  // Helper Methods for Enum Parsing
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
        return ConditionLevel.good;
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
        return SymptomType.nausea;
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

  static CheckinContext _parseContext(Map<String, dynamic> json) {
    return CheckinContext(
      isPostInjection: json['is_post_injection'] as bool? ?? false,
      daysSinceLastCheckin: json['days_since_last_checkin'] as int? ?? 0,
      consecutiveDays: json['consecutive_days'] as int? ?? 0,
      greetingType: json['greeting_type'] as String?,
      weightSkipped: json['weight_skipped'] as bool? ?? false,
    );
  }

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
        return RedFlagType.pancreatitis;
    }
  }

  static RedFlagSeverity _parseRedFlagSeverity(String value) {
    switch (value) {
      case 'warning':
        return RedFlagSeverity.warning;
      case 'urgent':
        return RedFlagSeverity.urgent;
      default:
        return RedFlagSeverity.warning;
    }
  }
}

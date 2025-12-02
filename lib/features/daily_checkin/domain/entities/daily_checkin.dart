import 'package:equatable/equatable.dart';

import 'checkin_context.dart';
import 'red_flag_detection.dart';
import 'symptom_detail.dart';

/// 식사 컨디션 수준
enum ConditionLevel {
  good, // 잘 먹었어요
  moderate, // 적당히 먹었어요
  difficult; // 좀 힘들었어요
}

/// 수분 섭취 수준
enum HydrationLevel {
  good, // 충분히 마셨어요
  moderate, // 좀 적게 마신 것 같아요
  poor; // 거의 못 마셨어요
}

/// 소화기 편안함 수준
enum GiComfortLevel {
  good, // 네, 괜찮았어요
  uncomfortable, // 좀 불편했어요
  veryUncomfortable; // 많이 불편했어요
}

/// 배변 상태
enum BowelCondition {
  normal, // 네, 잘 봤어요
  irregular, // 좀 불규칙했어요
  difficult; // 힘들었어요
}

/// 에너지 수준
enum EnergyLevel {
  good, // 활기 있었어요
  normal, // 평소와 비슷했어요
  tired; // 많이 피곤했어요
}

/// 기분 상태
enum MoodLevel {
  good, // 좋았어요
  neutral, // 그저 그랬어요
  low; // 좀 우울했어요
}

/// 데일리 체크인 엔티티
///
/// 이 엔티티는 database.md의 daily_checkins 테이블을 나타냅니다.
/// 사용자가 매일 작성하는 6개의 일상적 질문 응답과
/// 필요시 입력하는 증상 상세 정보를 포함합니다.
///
/// 체크인 완료 시 체중 입력은 선택적이며,
/// 체크인 자체의 완료 여부는 6개 질문 응답으로 판정합니다.
///
class DailyCheckin extends Equatable {
  final String id;
  final String userId;
  final DateTime checkinDate;

  // 6개 일상 질문 응답
  final ConditionLevel mealCondition;
  final HydrationLevel hydrationLevel;
  final GiComfortLevel giComfort;
  final BowelCondition bowelCondition;
  final EnergyLevel energyLevel;
  final MoodLevel mood;

  // 식욕 점수 (1-5)
  // - mealCondition이 'good'이면 4-5
  // - mealCondition이 'moderate'이면 3-4
  // - mealCondition이 'difficult'이면 파생 질문에서 결정 (1-3)
  final int? appetiteScore;

  // 파생 정보 (선택적)
  final List<SymptomDetail>? symptomDetails;
  final CheckinContext? context;
  final RedFlagDetection? redFlagDetected;

  final DateTime createdAt;

  const DailyCheckin({
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

  DailyCheckin copyWith({
    String? id,
    String? userId,
    DateTime? checkinDate,
    ConditionLevel? mealCondition,
    HydrationLevel? hydrationLevel,
    GiComfortLevel? giComfort,
    BowelCondition? bowelCondition,
    EnergyLevel? energyLevel,
    MoodLevel? mood,
    int? appetiteScore,
    List<SymptomDetail>? symptomDetails,
    CheckinContext? context,
    RedFlagDetection? redFlagDetected,
    DateTime? createdAt,
  }) {
    return DailyCheckin(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkinDate: checkinDate ?? this.checkinDate,
      mealCondition: mealCondition ?? this.mealCondition,
      hydrationLevel: hydrationLevel ?? this.hydrationLevel,
      giComfort: giComfort ?? this.giComfort,
      bowelCondition: bowelCondition ?? this.bowelCondition,
      energyLevel: energyLevel ?? this.energyLevel,
      mood: mood ?? this.mood,
      appetiteScore: appetiteScore ?? this.appetiteScore,
      symptomDetails: symptomDetails ?? this.symptomDetails,
      context: context ?? this.context,
      redFlagDetected: redFlagDetected ?? this.redFlagDetected,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        checkinDate,
        mealCondition,
        hydrationLevel,
        giComfort,
        bowelCondition,
        energyLevel,
        mood,
        appetiteScore,
        symptomDetails,
        context,
        redFlagDetected,
        createdAt,
      ];

  @override
  String toString() => 'DailyCheckin('
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
      'symptomDetails: $symptomDetails, '
      'context: $context, '
      'redFlagDetected: $redFlagDetected, '
      'createdAt: $createdAt'
      ')';
}

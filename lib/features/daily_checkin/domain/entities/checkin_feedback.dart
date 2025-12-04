import 'package:equatable/equatable.dart';
import 'feedback_type.dart';

/// 피드백 톤
///
/// 사용자의 응답에 따라 적절한 감정적 톤을 선택하여
/// 긍정적이거나 지지적인 메시지를 전달합니다.
enum FeedbackTone {
  positive, // 💚 긍정 (잘한 경우)
  supportive, // 💛 지지 (힘든 경우)
  cautious, // 🧡 주의 (Red Flag 감지)
}

/// 체크인 피드백 (타입 기반)
///
/// Application Layer에서 문자열 대신 타입 정보를 반환하고,
/// Presentation Layer에서 l10n으로 변환하여 표시합니다.
///
/// 세 가지 피드백 유형:
/// 1. 긍정 피드백: PositiveFeedbackType
/// 2. 지지 피드백: SupportiveFeedbackType (또는 CopingGuide 데이터)
/// 3. 완료 피드백: List<CompletionFeedbackElement> + consecutiveDays
/// 4. Red Flag 안내: RedFlagGuidanceType
///
/// 피드백 예시:
///
/// 긍정 피드백:
/// - type: PositiveFeedbackType.goodMeal
/// - tone: FeedbackTone.positive
/// → Presentation에서: "좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚"
///
/// 지지 피드백 (CopingGuide 사용):
/// - copingGuideMessage: "몸이 약에 적응하는 자연스러운 반응이에요"
/// - copingGuideStat: "85%가 2주 내 개선을 경험해요"
/// - copingGuideAction: "시원한 물 한 모금 마시기"
/// - tone: FeedbackTone.supportive
///
/// 지지 피드백 (기본 메시지):
/// - type: SupportiveFeedbackType.nausea
/// - tone: FeedbackTone.supportive
/// → Presentation에서: "메스꺼움은 흔한 증상이에요. 조금씩 나아질 거예요"
///
class CheckinFeedback extends Equatable {
  /// 긍정 피드백 타입 (PositiveFeedbackType인 경우)
  final PositiveFeedbackType? positiveFeedbackType;

  /// 지지 피드백 타입 (SupportiveFeedbackType인 경우)
  final SupportiveFeedbackType? supportiveFeedbackType;

  /// 완료 피드백 요소들 (CompletionFeedback인 경우)
  final List<CompletionFeedbackElement>? completionElements;

  /// 연속 기록 일수 (완료 피드백에서 사용)
  final int? consecutiveDays;

  /// Red Flag 안내 타입 (RedFlagGuidanceType인 경우)
  final RedFlagGuidanceType? redFlagGuidanceType;

  /// CopingGuide 메시지 (있을 경우 우선 사용)
  final String? copingGuideMessage;

  /// CopingGuide 통계 정보 (선택적)
  final String? copingGuideStat;

  /// CopingGuide 즉각 행동 제안 (선택적)
  final String? copingGuideAction;

  /// 피드백 톤
  final FeedbackTone tone;

  const CheckinFeedback({
    this.positiveFeedbackType,
    this.supportiveFeedbackType,
    this.completionElements,
    this.consecutiveDays,
    this.redFlagGuidanceType,
    this.copingGuideMessage,
    this.copingGuideStat,
    this.copingGuideAction,
    required this.tone,
  });

  /// 긍정 피드백 생성
  const CheckinFeedback.positive(PositiveFeedbackType type)
      : positiveFeedbackType = type,
        supportiveFeedbackType = null,
        completionElements = null,
        consecutiveDays = null,
        redFlagGuidanceType = null,
        copingGuideMessage = null,
        copingGuideStat = null,
        copingGuideAction = null,
        tone = FeedbackTone.positive;

  /// 지지 피드백 생성 (기본 메시지)
  const CheckinFeedback.supportive(SupportiveFeedbackType type)
      : positiveFeedbackType = null,
        supportiveFeedbackType = type,
        completionElements = null,
        consecutiveDays = null,
        redFlagGuidanceType = null,
        copingGuideMessage = null,
        copingGuideStat = null,
        copingGuideAction = null,
        tone = FeedbackTone.supportive;

  /// 지지 피드백 생성 (CopingGuide 사용)
  const CheckinFeedback.copingGuide({
    required String message,
    String? stat,
    String? action,
  })  : positiveFeedbackType = null,
        supportiveFeedbackType = null,
        completionElements = null,
        consecutiveDays = null,
        redFlagGuidanceType = null,
        copingGuideMessage = message,
        copingGuideStat = stat,
        copingGuideAction = action,
        tone = FeedbackTone.supportive;

  /// 완료 피드백 생성
  const CheckinFeedback.completion({
    required List<CompletionFeedbackElement> elements,
    int? consecutiveDays,
  })  : positiveFeedbackType = null,
        supportiveFeedbackType = null,
        completionElements = elements,
        consecutiveDays = consecutiveDays,
        redFlagGuidanceType = null,
        copingGuideMessage = null,
        copingGuideStat = null,
        copingGuideAction = null,
        tone = FeedbackTone.positive;

  /// Red Flag 안내 생성
  const CheckinFeedback.redFlag(RedFlagGuidanceType type)
      : positiveFeedbackType = null,
        supportiveFeedbackType = null,
        completionElements = null,
        consecutiveDays = null,
        redFlagGuidanceType = type,
        copingGuideMessage = null,
        copingGuideStat = null,
        copingGuideAction = null,
        tone = FeedbackTone.cautious;

  @override
  List<Object?> get props => [
        positiveFeedbackType,
        supportiveFeedbackType,
        completionElements,
        consecutiveDays,
        redFlagGuidanceType,
        copingGuideMessage,
        copingGuideStat,
        copingGuideAction,
        tone,
      ];

  @override
  String toString() => 'CheckinFeedback('
      'positiveFeedbackType: $positiveFeedbackType, '
      'supportiveFeedbackType: $supportiveFeedbackType, '
      'completionElements: $completionElements, '
      'consecutiveDays: $consecutiveDays, '
      'redFlagGuidanceType: $redFlagGuidanceType, '
      'copingGuideMessage: $copingGuideMessage, '
      'copingGuideStat: $copingGuideStat, '
      'copingGuideAction: $copingGuideAction, '
      'tone: $tone'
      ')';
}

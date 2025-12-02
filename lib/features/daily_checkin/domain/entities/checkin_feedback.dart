import 'package:equatable/equatable.dart';

/// 피드백 톤
///
/// 사용자의 응답에 따라 적절한 감정적 톤을 선택하여
/// 긍정적이거나 지지적인 메시지를 전달합니다.
enum FeedbackTone {
  positive, // 💚 긍정 (잘한 경우)
  supportive, // 💛 지지 (힘든 경우)
  cautious, // 🧡 주의 (Red Flag 감지)
}

/// 체크인 피드백
///
/// 매 질문 응답 후 또는 체크인 완료 시 표시되는 피드백입니다.
/// 기존 CopingGuide 데이터를 활용하여 부작용에 대한 안심 메시지를 제공하고,
/// 긍정적인 응답에는 격려 메시지를 제공합니다.
///
/// 피드백 예시:
///
/// 긍정 (positive):
/// - message: "좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚"
/// - stat: null
/// - action: null
///
/// 지지 (supportive):
/// - message: "몸이 약에 적응하는 자연스러운 반응이에요"
/// - stat: "85%가 2주 내 개선을 경험해요"
/// - action: "시원한 물 한 모금 마시기"
///
/// 주의 (cautious):
/// - message: "오늘 기록해주신 증상이 조금 확인이 필요해 보여요"
/// - stat: null
/// - action: "가까운 병원에 확인받아 보시는 게 안심이 될 것 같아요"
///
class CheckinFeedback extends Equatable {
  /// 메인 메시지
  final String message;

  /// 통계 정보 (선택적)
  /// 예: "85%가 2주 내 개선을 경험해요"
  final String? stat;

  /// 즉각 행동 제안 (선택적)
  /// 예: "시원한 물 한 모금 마시기"
  final String? action;

  /// 피드백 톤
  final FeedbackTone tone;

  const CheckinFeedback({
    required this.message,
    this.stat,
    this.action,
    required this.tone,
  });

  CheckinFeedback copyWith({
    String? message,
    String? stat,
    String? action,
    FeedbackTone? tone,
  }) {
    return CheckinFeedback(
      message: message ?? this.message,
      stat: stat ?? this.stat,
      action: action ?? this.action,
      tone: tone ?? this.tone,
    );
  }

  @override
  List<Object?> get props => [message, stat, action, tone];

  @override
  String toString() => 'CheckinFeedback('
      'message: $message, '
      'stat: $stat, '
      'action: $action, '
      'tone: $tone'
      ')';
}

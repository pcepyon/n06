import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_feedback.dart';
import 'package:n06/features/daily_checkin/presentation/utils/feedback_l10n_mapper.dart';

/// 피드백 카드 위젯
///
/// 매 답변마다 표시되는 격려/안심 메시지 카드입니다.
///
/// Features:
/// - 슬라이드인 애니메이션
/// - 톤별 색상 (positive, supportive, cautious)
/// - l10n 메시지 매핑 자동 처리
///
/// 사용법:
/// 1. CheckinFeedback 객체로 사용 (권장, CheckinFeedbackNotifier 사용 시):
///    `FeedbackCard(feedback: feedback)`
/// 2. 직접 문자열 사용 (하위 호환, 인라인 피드백용):
///    `FeedbackCard.direct(message: "메시지", tone: FeedbackTone.positive)`
class FeedbackCard extends StatefulWidget {
  final CheckinFeedback? feedback;
  final String? directMessage;
  final FeedbackTone? directTone;

  const FeedbackCard({
    super.key,
    required this.feedback,
  })  : directMessage = null,
        directTone = null;

  const FeedbackCard.direct({
    super.key,
    required String message,
    FeedbackTone tone = FeedbackTone.positive,
  })  : feedback = null,
        directMessage = message,
        directTone = tone;

  @override
  State<FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<FeedbackCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 메시지, 통계, 액션 결정 (feedback 또는 direct 모드)
    final String message;
    final String? stat;
    final String? action;

    if (widget.feedback != null) {
      // CheckinFeedback 객체 사용 (l10n 매핑)
      message = FeedbackL10nMapper.getFeedbackMessage(context, widget.feedback!);
      stat = FeedbackL10nMapper.getFeedbackStat(widget.feedback!);
      action = FeedbackL10nMapper.getFeedbackAction(widget.feedback!);
    } else {
      // 직접 문자열 사용 (하위 호환)
      message = widget.directMessage!;
      stat = null;
      action = null;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이모지
                  Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  // 메시지
                  Expanded(
                    child: Text(
                      message,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.neutral800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              // 통계 정보 (선택적)
              if (stat != null) ...[
                const SizedBox(height: 8),
                Text(
                  stat,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              // 즉각 행동 제안 (선택적)
              if (action != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActionBackgroundColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    action,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  FeedbackTone get _tone => widget.feedback?.tone ?? widget.directTone!;

  Color _getBackgroundColor() {
    switch (_tone) {
      case FeedbackTone.positive:
        return const Color(0xFFF0FDF4); // Green-50
      case FeedbackTone.supportive:
        return const Color(0xFFFFFBEB); // Yellow-50
      case FeedbackTone.cautious:
        return const Color(0xFFFFF7ED); // Orange-50
    }
  }

  Color _getBorderColor() {
    switch (_tone) {
      case FeedbackTone.positive:
        return const Color(0xFFBBF7D0); // Green-200
      case FeedbackTone.supportive:
        return const Color(0xFFFDE68A); // Yellow-200
      case FeedbackTone.cautious:
        return const Color(0xFFFED7AA); // Orange-200
    }
  }

  Color _getActionBackgroundColor() {
    switch (_tone) {
      case FeedbackTone.positive:
        return const Color(0xFFDCFCE7); // Green-100
      case FeedbackTone.supportive:
        return const Color(0xFFFEF3C7); // Yellow-100
      case FeedbackTone.cautious:
        return const Color(0xFFFFEDD5); // Orange-100
    }
  }

  String _getEmoji() {
    switch (_tone) {
      case FeedbackTone.positive:
        return '💚';
      case FeedbackTone.supportive:
        return '💛';
      case FeedbackTone.cautious:
        return '🧡';
    }
  }
}

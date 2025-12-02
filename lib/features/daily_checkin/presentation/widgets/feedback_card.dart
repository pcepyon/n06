import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/application/notifiers/checkin_feedback_notifier.dart' show FeedbackTone;

/// 피드백 카드 위젯
///
/// 매 답변마다 표시되는 격려/안심 메시지 카드입니다.
///
/// Features:
/// - 슬라이드인 애니메이션
/// - 톤별 색상 (positive, supportive, cautious)
/// - 간결한 메시지
class FeedbackCard extends StatefulWidget {
  final String message;
  final FeedbackTone tone;

  const FeedbackCard({
    super.key,
    required this.message,
    this.tone = FeedbackTone.positive,
  });

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
          child: Row(
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
                  widget.message,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.neutral800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.tone) {
      case FeedbackTone.positive:
        return const Color(0xFFF0FDF4); // Green-50
      case FeedbackTone.supportive:
        return const Color(0xFFFFFBEB); // Yellow-50
      case FeedbackTone.cautious:
        return const Color(0xFFFFF7ED); // Orange-50
    }
  }

  Color _getBorderColor() {
    switch (widget.tone) {
      case FeedbackTone.positive:
        return const Color(0xFFBBF7D0); // Green-200
      case FeedbackTone.supportive:
        return const Color(0xFFFDE68A); // Yellow-200
      case FeedbackTone.cautious:
        return const Color(0xFFFED7AA); // Orange-200
    }
  }

  String _getEmoji() {
    switch (widget.tone) {
      case FeedbackTone.positive:
        return '💚';
      case FeedbackTone.supportive:
        return '💛';
      case FeedbackTone.cautious:
        return '🧡';
    }
  }
}

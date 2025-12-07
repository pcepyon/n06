import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// AIMessageSection - AI 생성 메시지 섹션
///
/// Features:
/// - Skeleton UI with loading indicator during message generation
/// - Fade-in animation when message appears (300ms)
/// - Fallback to default message on error
/// - Independent loading state from other dashboard sections
class AIMessageSection extends StatefulWidget {
  final bool isLoading;
  final String? message;

  const AIMessageSection({
    super.key,
    this.isLoading = false,
    this.message,
  });

  @override
  State<AIMessageSection> createState() => _AIMessageSectionState();
}

class _AIMessageSectionState extends State<AIMessageSection> {
  bool _showMessage = false;

  @override
  void didUpdateWidget(AIMessageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger fade-in animation when transitioning from loading to message
    if (oldWidget.isLoading && !widget.isLoading) {
      setState(() {
        _showMessage = false;
      });
      // Delay to create smooth transition
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _showMessage = true;
          });
        }
      });
    } else if (!widget.isLoading) {
      _showMessage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 메시지',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 메시지 또는 로딩 상태
          if (widget.isLoading)
            _buildSkeleton()
          else
            _buildMessage(context),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '메시지 준비 중...',
              style: AppTypography.caption.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context) {
    final displayMessage = widget.message ?? '오늘도 함께해요.';

    // Fade-in animation with 300ms duration
    return AnimatedOpacity(
      opacity: _showMessage ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.welcomeBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          displayMessage,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

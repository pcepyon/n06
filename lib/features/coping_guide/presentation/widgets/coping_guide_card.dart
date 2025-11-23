import 'package:flutter/material.dart';

import '../../../../features/authentication/presentation/widgets/gabium_button.dart';
import '../../../../features/onboarding/presentation/widgets/validation_alert.dart';
import '../../domain/entities/coping_guide.dart';
import '../../domain/entities/coping_guide_state.dart';
import 'feedback_widget.dart';

/// 부작용 대처 가이드 카드
class CopingGuideCard extends StatelessWidget {
  final CopingGuide? guide;
  final CopingGuideState? state;
  final VoidCallback? onDetailTap;
  final VoidCallback? onCheckSymptom;
  final Function(bool)? onFeedback;

  const CopingGuideCard({
    this.guide,
    this.state,
    this.onDetailTap,
    this.onCheckSymptom,
    this.onFeedback,
    super.key,
  }) : assert(guide != null || state != null);

  @override
  Widget build(BuildContext context) {
    final currentGuide = state?.guide ?? guide!;
    final showWarning = state?.showSeverityWarning ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFF4ADE80), width: 3),
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showWarning && onCheckSymptom != null) ...[
            ValidationAlert(
              type: ValidationAlertType.error,
              message: '증상이 심각하거나 지속됩니다. 증상을 체크해주세요.',
              icon: Icons.warning_rounded,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            '${currentGuide.symptomName} 대처 가이드',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentGuide.shortGuide,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Color(0xFFE2E8F0),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          GabiumButton(
            text: '더 자세한 가이드 보기',
            onPressed: onDetailTap,
            variant: GabiumButtonVariant.primary,
            size: GabiumButtonSize.medium,
          ),
          const SizedBox(height: 16),
          if (onFeedback != null) FeedbackWidget(onFeedback: onFeedback!),
        ],
          ),
        ),
      ),
    );
  }
}

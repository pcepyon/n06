import 'package:flutter/material.dart';

import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
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
          decoration: BoxDecoration(
            color: AppColors.educationBackground,
            border: const Border(
              top: BorderSide(color: AppColors.education, width: 3),
              bottom: BorderSide(color: AppColors.border, width: 1),
              left: BorderSide(color: AppColors.border, width: 1),
              right: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showWarning && onCheckSymptom != null) ...[
            ValidationAlert(
              type: ValidationAlertType.error,
              message: context.l10n.coping_card_warningMessage,
              icon: Icons.warning_rounded,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            context.l10n.coping_card_guideTitle(currentGuide.symptomName),
            style: AppTypography.heading3.copyWith(height: 1.44),
          ),
          const SizedBox(height: 16),
          Text(
            currentGuide.shortGuide,
            style: AppTypography.bodyMedium.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: AppColors.border,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          GabiumButton(
            text: context.l10n.coping_card_detailButton,
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

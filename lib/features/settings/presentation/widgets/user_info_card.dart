import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

class UserInfoCard extends StatelessWidget {
  final String userName;
  final double targetWeight;

  const UserInfoCard({
    required this.userName,
    required this.targetWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = '${context.l10n.settings_userInfo_title}. '
        '${context.l10n.settings_userInfo_name} $userName. '
        '${context.l10n.settings_userInfo_targetWeight} ${targetWeight.toStringAsFixed(1)}kg';

    return Semantics(
      label: semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0), // md (12px)
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.06),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0), // md (16px)
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Text(
                context.l10n.settings_userInfo_title,
                style: AppTypography.heading2,
              ),
              const SizedBox(height: 8.0), // sm spacing after title

              // Data item 1: Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settings_userInfo_name,
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    userName,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0), // sm spacing between items

              // Data item 2: Target weight
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settings_userInfo_targetWeight,
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${targetWeight.toStringAsFixed(1)}kg',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

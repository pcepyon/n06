import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/settings/application/notifiers/locale_notifier.dart';

/// Language selection dialog
///
/// Allows users to choose between system default, Korean, and English
class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              context.l10n.settings_language_dialogTitle,
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 24.0),

            // System default option
            _LanguageOption(
              label: context.l10n.settings_language_system,
              isSelected: currentLocale == null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(null);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 8.0),

            // Korean option
            _LanguageOption(
              label: context.l10n.settings_language_korean,
              isSelected: currentLocale?.languageCode == 'ko',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('ko'));
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 8.0),

            // English option
            _LanguageOption(
              label: context.l10n.settings_language_english,
              isSelected: currentLocale?.languageCode == 'en',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 16.0),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(context.l10n.common_button_cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual language option widget
class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2.0)
              : Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }
}

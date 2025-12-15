import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

enum GabiumButtonVariant {
  primary,
  secondary,
  tertiary,
  ghost,
  danger,
}

enum GabiumButtonSize {
  small,
  medium,
  large,
}

/// Gabium Button component
/// Primary, Secondary, Tertiary, Ghost variants
/// Small, Medium, Large sizes
/// Loading state support
class GabiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GabiumButtonVariant variant;
  final GabiumButtonSize size;
  final bool isLoading;
  final String? semanticsLabel;

  const GabiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = GabiumButtonVariant.primary,
    this.size = GabiumButtonSize.medium,
    this.isLoading = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final height = _getHeight();
    final isEnabled = !isLoading && onPressed != null;
    final label = semanticsLabel ?? text;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isLoading ? '${context.l10n.auth_button_loading}, $label' : label,
      child: SizedBox(
        height: height,
        width: variant == GabiumButtonVariant.ghost ? null : double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8.0), // 스피너-텍스트 간격
                    Text(
                      context.l10n.auth_button_loading,
                      style: textStyle,
                    ),
                  ],
                )
              : Text(text, style: textStyle),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case GabiumButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          elevation: 0,
          shadowColor: AppColors.neutral900.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == GabiumButtonSize.large ? 32 : 24,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primaryHover;
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.primaryPressed;
              }
              return null;
            },
          ),
        );

      case GabiumButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == GabiumButtonSize.large ? 32 : 16,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primary.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.primary.withValues(alpha: 0.12);
              }
              return null;
            },
          ),
        );

      case GabiumButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primary.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.primary.withValues(alpha: 0.12);
              }
              return null;
            },
          ),
        );

      case GabiumButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
          elevation: 0,
          shadowColor: AppColors.neutral900.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == GabiumButtonSize.large ? 32 : 24,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFDC2626);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFB91C1C);
              }
              return null;
            },
          ),
        );

      default:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        );
    }
  }

  TextStyle _getTextStyle() {
    final color = _getTextColor();
    switch (size) {
      case GabiumButtonSize.large:
        return AppTypography.heading3.copyWith(color: color);
      case GabiumButtonSize.medium:
        return AppTypography.labelLarge.copyWith(color: color);
      case GabiumButtonSize.small:
        return AppTypography.labelMedium.copyWith(color: color);
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case GabiumButtonVariant.primary:
      case GabiumButtonVariant.danger:
        return Colors.white;
      case GabiumButtonVariant.secondary:
      case GabiumButtonVariant.tertiary:
      case GabiumButtonVariant.ghost:
        return AppColors.primary;
    }
  }

  double _getHeight() {
    switch (size) {
      case GabiumButtonSize.large:
        return 52;
      case GabiumButtonSize.medium:
        return 44;
      case GabiumButtonSize.small:
        return 36;
    }
  }
}

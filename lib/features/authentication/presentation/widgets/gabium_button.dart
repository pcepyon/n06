import 'package:flutter/material.dart';

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

  const GabiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = GabiumButtonVariant.primary,
    this.size = GabiumButtonSize.medium,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final height = _getHeight();

    return SizedBox(
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
                    '저장 중...',
                    style: textStyle,
                  ),
                ],
              )
            : Text(text, style: textStyle),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case GabiumButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ADE80), // Primary
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: const Color(0xFF4ADE80).withValues(alpha: 0.4),
          elevation: 0,
          shadowColor: const Color(0x0F0F172A).withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // sm
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == GabiumButtonSize.large ? 32 : 24,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFF22C55E); // Hover
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF16A34A); // Active
              }
              return null;
            },
          ),
        );

      case GabiumButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF4ADE80), // Primary
          elevation: 0,
          shadowColor: Colors.transparent,
          side: const BorderSide(
            color: Color(0xFF4ADE80),
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
                return const Color(0xFF4ADE80).withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF4ADE80).withValues(alpha: 0.12);
              }
              return null;
            },
          ),
        );

      case GabiumButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF4ADE80), // Primary
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
                return const Color(0xFF4ADE80).withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF4ADE80).withValues(alpha: 0.12);
              }
              return null;
            },
          ),
        );

      case GabiumButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444), // Error
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.4),
          elevation: 0,
          shadowColor: const Color(0x0F0F172A).withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // sm
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == GabiumButtonSize.large ? 32 : 24,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFDC2626); // Error darker (Red-600)
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFB91C1C); // Error darkest (Red-700)
              }
              return null;
            },
          ),
        );

      default:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ADE80),
          foregroundColor: const Color(0xFFFFFFFF),
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case GabiumButtonSize.large:
        return const TextStyle(
          fontSize: 18, // lg
          fontWeight: FontWeight.w600, // Semibold
        );
      case GabiumButtonSize.medium:
        return const TextStyle(
          fontSize: 16, // base
          fontWeight: FontWeight.w500, // Medium
        );
      case GabiumButtonSize.small:
        return const TextStyle(
          fontSize: 14, // sm
          fontWeight: FontWeight.w500, // Medium
        );
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

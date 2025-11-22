import 'package:flutter/material.dart';

enum GabiumButtonVariant {
  primary,
  secondary,
  tertiary,
  ghost,
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
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
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
          disabledBackgroundColor: const Color(0xFF4ADE80).withOpacity(0.4),
          elevation: 0,
          shadowColor: const Color(0x0F0F172A).withOpacity(0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // sm
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == GabiumButtonSize.large ? 32 : 24,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF22C55E); // Hover
              }
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xFF16A34A); // Active
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
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF4ADE80).withOpacity(0.08);
              }
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xFF4ADE80).withOpacity(0.12);
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

import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// Gabium branded text input
/// Handles default, focus, error states
/// Includes label, helper text, error message
class GabiumTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? semanticsLabel;
  final AutovalidateMode? autovalidateMode;

  const GabiumTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.semanticsLabel,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticsLabel ?? label;
    final hasError = errorText != null && errorText!.isNotEmpty;

    // Build semantics label with error if present
    String buildSemanticsLabel() {
      if (hasError) {
        return '$effectiveLabel, 오류: $errorText';
      }
      return effectiveLabel;
    }

    return Semantics(
      label: buildSemanticsLabel(),
      hint: hint,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.neutral700,
              ),
            ),
          ),

          // Input field (48px 고정 높이)
          SizedBox(
            height: 48.0,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              onChanged: onChanged,
              autovalidateMode: autovalidateMode,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
                helperText: helperText,
                errorText: errorText,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                // Default border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.neutral300,
                    width: 2,
                  ),
                ),
                // Focus border
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                // Error border
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                // Focused error border
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                // Error style
                errorStyle: AppTypography.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
                // Helper text style
                helperStyle: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

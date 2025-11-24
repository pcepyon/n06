import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14, // sm
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
        ),

        // Input field (48px 고정 높이)
        SizedBox(
          height: 48.0, // 고정 높이
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16, // base
              fontWeight: FontWeight.w400, // Regular
              color: Color(0xFF1E293B), // Neutral-800
            ),
            decoration: InputDecoration(
              hintText: hint,
              helperText: helperText,
              errorText: errorText,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: const Color(0xFFFFFFFF), // White background
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12, // md
                horizontal: 16, // md
              ),
              // Default border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // sm
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1), // Neutral-300
                  width: 2,
                ),
              ),
              // Focus border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // sm
                borderSide: const BorderSide(
                  color: Color(0xFF4ADE80), // Primary
                  width: 2,
                ),
              ),
              // Error border
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // sm
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444), // Error
                  width: 2,
                ),
              ),
              // Focused error border
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // sm
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444), // Error
                  width: 2,
                ),
              ),
              // Error style
              errorStyle: const TextStyle(
                fontSize: 12, // xs
                fontWeight: FontWeight.w500, // Medium
                color: Color(0xFFEF4444), // Error
              ),
              // Helper text style
              helperStyle: const TextStyle(
                fontSize: 12, // xs
                fontWeight: FontWeight.w400, // Regular
                color: Color(0xFF64748B), // Neutral-500
              ),
            ),
          ),
        ),
      ],
    );
  }
}

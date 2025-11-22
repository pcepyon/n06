import 'package:flutter/material.dart';

/// Consent Checkbox component
/// Styled checkbox with required/optional badge
class ConsentCheckbox extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const ConsentCheckbox({
    super.key,
    required this.label,
    required this.isRequired,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Custom checkbox
            SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? const Color(0xFF4ADE80) : Colors.transparent,
                    border: Border.all(
                      color: value
                          ? const Color(0xFF4ADE80) // Primary
                          : const Color(0xFF94A3B8), // Neutral-400
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: value
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Label
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14, // sm
                    fontWeight: FontWeight.w400, // Regular
                    color: Color(0xFF334155), // Neutral-700
                  ),
                  children: [
                    TextSpan(text: label),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: isRequired ? '(필수)' : '(선택)',
                      style: TextStyle(
                        fontSize: 12, // xs
                        fontWeight: FontWeight.w500, // Medium
                        color: isRequired
                            ? const Color(0xFFEF4444) // Error
                            : const Color(0xFF64748B), // Neutral-500
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

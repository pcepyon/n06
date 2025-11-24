import 'package:flutter/material.dart';

/// EmptyStateWidget
/// 빈 상태를 표시하는 위젯
/// Gabium Design System의 Empty State 패턴 사용
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onButtonPressed;
  final String? buttonText;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onButtonPressed,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, // md spacing
          vertical: 32, // xl spacing
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon (120x120px)
            Icon(
              icon,
              size: 120,
              color: const Color(0xFFCBD5E1), // Neutral-300
            ),
            const SizedBox(height: 24), // lg spacing

            // Title (lg, Semibold)
            Text(
              title,
              style: const TextStyle(
                fontSize: 18, // lg
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF334155), // Neutral-700
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24), // lg spacing

            // Description (base, Regular)
            Text(
              description,
              style: const TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.w400, // Regular
                color: Color(0xFF64748B), // Neutral-500
                height: 1.5, // 24px line height
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Optional CTA Button
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24), // lg spacing
              SizedBox(
                width: double.infinity,
                height: 44, // Medium button height
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ADE80), // Primary
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // sm radius
                    ),
                    elevation: 2, // sm shadow
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 16, // base
                      fontWeight: FontWeight.w600, // Semibold
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

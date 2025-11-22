import 'package:flutter/material.dart';

/// Auth Hero Section component
/// Welcoming hero with title, subtitle, optional icon
/// Reusable for all auth screens (sign in, signup, password reset)
class AuthHeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const AuthHeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 32, // xl
        bottom: 16, // md
        left: 16, // md
        right: 16, // md
      ),
      color: const Color(0xFFF8FAFC), // Neutral-50 (seamless with background)
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: const Color(0xFF4ADE80), // Primary
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28, // 3xl
              fontWeight: FontWeight.w700, // Bold
              color: Color(0xFF1E293B), // Neutral-800
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16, // base
              fontWeight: FontWeight.w400, // Regular
              color: Color(0xFF475569), // Neutral-600
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

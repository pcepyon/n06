import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF00C73C); // Toss Green
  static const Color primaryLight = Color(0xFFE5F9EB); // Light Green Tint

  // Status Colors
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color success = Color(0xFF00C73C);

  // Grayscale (Text & Backgrounds)
  static const Color black = Color(0xFF191F28); // Heading
  static const Color darkGray = Color(0xFF333D4B); // Body
  static const Color gray = Color(0xFF4E5968); // Subtext
  static const Color lightGray = Color(0xFF8B95A1); // Hint / Disabled
  static const Color extraLightGray = Color(0xFFE5E8EB); // Border / Divider
  
  // Backgrounds
  static const Color background = Color(0xFFF2F4F6); // Grouped Background
  static const Color surface = Color(0xFFFFFFFF); // Card / Modal Background
  static const Color inputBackground = Color(0xFFF9FAFB); // TextField Background

  // Shadows
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
  
  static final BoxShadow floatingShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}

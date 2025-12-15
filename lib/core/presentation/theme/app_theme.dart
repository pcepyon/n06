import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// 가비움 앱 테마
/// Design System v1.0 기반
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,

      // ============================================
      // Color Scheme
      // ============================================
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary.withValues(alpha: 0.1),
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.neutral100,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
      ),

      // ============================================
      // Scaffold
      // ============================================
      scaffoldBackgroundColor: AppColors.background,

      // ============================================
      // AppBar
      // ============================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.heading2,
        iconTheme: const IconThemeData(
          color: AppColors.neutral700,
          size: 24,
        ),
      ),

      // ============================================
      // Card
      // ============================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ============================================
      // Buttons
      // ============================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ============================================
      // Input Decoration
      // ============================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
        labelStyle: AppTypography.labelMedium,
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
      ),

      // ============================================
      // Divider
      // ============================================
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ============================================
      // Bottom Navigation Bar
      // ============================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTypography.caption,
      ),

      // ============================================
      // Checkbox
      // ============================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.neutral400, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ============================================
      // Switch
      // ============================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.neutral300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ============================================
      // Progress Indicator
      // ============================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),

      // ============================================
      // Floating Action Button
      // ============================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ============================================
      // Snackbar
      // ============================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ============================================
      // Dialog
      // ============================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.heading2,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ============================================
      // Bottom Sheet
      // ============================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        dragHandleColor: AppColors.neutral300,
        dragHandleSize: Size(32, 4),
        showDragHandle: true,
      ),

      // ============================================
      // List Tile
      // ============================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTypography.bodyLarge,
        subtitleTextStyle: AppTypography.bodySmall,
        iconColor: AppColors.neutral600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ============================================
      // Icon
      // ============================================
      iconTheme: const IconThemeData(
        color: AppColors.neutral600,
        size: 24,
      ),

      // ============================================
      // Text Theme
      // ============================================
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.heading1,
        displaySmall: AppTypography.heading2,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        headlineSmall: AppTypography.heading3,
        titleLarge: AppTypography.heading2,
        titleMedium: AppTypography.heading3,
        titleSmall: AppTypography.labelLarge,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,

      // ============================================
      // Color Scheme
      // ============================================
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.neutral900,
        primaryContainer: AppColors.primaryDark.withValues(alpha: 0.2),
        secondary: AppColors.secondary,
        onSecondary: AppColors.neutral900,
        error: AppColors.errorDark,
        onError: AppColors.neutral900,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.neutral700,
        outline: AppColors.borderDarkMode,
        outlineVariant: AppColors.borderLightDarkMode,
      ),

      // ============================================
      // Scaffold
      // ============================================
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // ============================================
      // AppBar
      // ============================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: IconThemeData(
          color: AppColors.neutral400,
          size: 24,
        ),
      ),

      // ============================================
      // Card
      // ============================================
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderDarkMode),
        ),
        margin: EdgeInsets.zero,
      ),

      // ============================================
      // Buttons
      // ============================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.neutral900,
          disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.neutral900.withValues(alpha: 0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: BorderSide(color: AppColors.primaryDark, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ============================================
      // Input Decoration
      // ============================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral600, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.errorDark, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.errorDark, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textDisabledDark,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.errorDark,
        ),
      ),

      // ============================================
      // Divider
      // ============================================
      dividerTheme: DividerThemeData(
        color: AppColors.borderDarkMode,
        thickness: 1,
        space: 1,
      ),

      // ============================================
      // Bottom Navigation Bar
      // ============================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTypography.caption,
      ),

      // ============================================
      // Checkbox
      // ============================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.neutral900),
        side: BorderSide(color: AppColors.neutral500, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ============================================
      // Switch
      // ============================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.neutral600;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ============================================
      // Progress Indicator
      // ============================================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryDark,
        linearTrackColor: AppColors.neutral700,
        circularTrackColor: AppColors.neutral700,
      ),

      // ============================================
      // Floating Action Button
      // ============================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.neutral900,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ============================================
      // Snackbar
      // ============================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral700,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ============================================
      // Dialog
      // ============================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      // ============================================
      // Bottom Sheet
      // ============================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        dragHandleColor: AppColors.neutral600,
        dragHandleSize: const Size(32, 4),
        showDragHandle: true,
      ),

      // ============================================
      // List Tile
      // ============================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        iconColor: AppColors.neutral400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ============================================
      // Icon
      // ============================================
      iconTheme: IconThemeData(
        color: AppColors.neutral400,
        size: 24,
      ),

      // ============================================
      // Text Theme
      // ============================================
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTypography.heading1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: AppTypography.heading1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: AppTypography.heading3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: AppTypography.heading3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: AppTypography.labelLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiaryDark,
        ),
      ),
    );
  }
}

/// 디자인 시스템 커스텀 토큰용 ThemeExtension
/// `Theme.of(context).extension<AppThemeExtension>()`로 접근
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color success;
  final Color warning;
  final Color info;
  final Color gold;
  final Color silver;
  final Color bronze;

  const AppThemeExtension({
    required this.success,
    required this.warning,
    required this.info,
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  /// Light theme extension
  static const light = AppThemeExtension(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    gold: AppColors.gold,
    silver: AppColors.silver,
    bronze: AppColors.bronze,
  );

  /// Dark theme extension
  static const dark = AppThemeExtension(
    success: Color(0xFF10B981), // Same as light (already bright)
    warning: Color(0xFFFBBF24), // Amber-400 for better contrast
    info: Color(0xFF60A5FA), // Blue-400 for better contrast
    gold: Color(0xFFFBBF24), // Amber-400
    silver: Color(0xFFCBD5E1), // Neutral-300
    bronze: Color(0xFFFB923C), // Orange-400
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? gold,
    Color? silver,
    Color? bronze,
  }) {
    return AppThemeExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      bronze: bronze ?? this.bronze,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      bronze: Color.lerp(bronze, other.bronze, t)!,
    );
  }
}

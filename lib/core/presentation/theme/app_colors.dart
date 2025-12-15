import 'package:flutter/material.dart';

/// 가비움 앱 색상 시스템
/// Design System v1.0 기반
abstract final class AppColors {
  // ============================================
  // Brand Colors
  // ============================================

  /// Primary: 신뢰의 밝은 녹색 (#4ADE80)
  static const Color primary = Color(0xFF4ADE80);
  static const Color primaryHover = Color(0xFF22C55E);
  static const Color primaryPressed = Color(0xFF16A34A);

  /// Secondary: 따뜻한 보조 색상 (#F59E0B)
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryHover = Color(0xFFD97706);
  static const Color secondaryPressed = Color(0xFFB45309);

  // ============================================
  // Semantic Colors
  // ============================================

  /// Success: 성공, 목표 달성, 완료
  static const Color success = Color(0xFF10B981);

  /// Error: 에러, 위험 증상, 삭제 경고
  static const Color error = Color(0xFFEF4444);

  /// Warning: 주의 필요, 미완료 작업
  static const Color warning = Color(0xFFF59E0B);

  /// Info: 일반 정보, 도움말, 팁
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // Achievement Colors (동기부여)
  // ============================================

  static const Color gold = Color(0xFFF59E0B);
  static const Color silver = Color(0xFF94A3B8);
  static const Color bronze = Color(0xFFEA580C);

  // ============================================
  // Neutral Scale (Slate 계열)
  // ============================================

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ============================================
  // Semantic Aliases
  // ============================================

  /// Background: 전체 앱 배경
  static const Color background = neutral50;

  /// Surface: 카드, 모달 등 표면
  static const Color surface = Colors.white;

  /// Surface Variant: 비활성 영역, 섹션 배경
  static const Color surfaceVariant = neutral100;

  // ============================================
  // Text Colors
  // ============================================

  /// 제목, 헤더, 중요 텍스트
  static const Color textPrimary = neutral800;

  /// 본문 텍스트
  static const Color textSecondary = neutral600;

  /// 보조 텍스트, 캡션
  static const Color textTertiary = neutral500;

  /// 비활성, Placeholder
  static const Color textDisabled = neutral400;

  // ============================================
  // Border Colors
  // ============================================

  static const Color border = neutral200;
  static const Color borderLight = neutral100;
  static const Color borderDark = neutral300;

  // ============================================
  // Chart Colors (데이터 시각화)
  // ============================================

  static const List<Color> chartColors = [
    primary, // 주요 데이터
    info, // 보조 데이터
    secondary, // 경고/주의
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    success, // 성공/목표
  ];

  // ============================================
  // Feature Colors (감정적 UX 매핑)
  // PRD 감정 목표에 따른 기능별 색상
  // ============================================

  /// 성취/마일스톤: 뱃지, 축하, 연속 기록 - 성취감, 자부심
  static const Color achievement = gold;

  /// 따뜻한 환영: 복귀 메시지, 격려 - 수용, 따뜻함
  static const Color warmWelcome = Color(0xFFF97316); // Orange-500

  /// 교육/안내: 대처 가이드, 팁 - 안심, 신뢰
  static const Color education = info;

  /// 기록/회고: 타임라인, 히스토리 - 연결감
  static const Color history = Color(0xFF8B5CF6); // Purple-500

  // ============================================
  // Feature Background Colors (연한 배경)
  // ============================================

  /// 성취 관련 배경 (연속 기록, 뱃지 배경)
  static const Color achievementBackground = Color(0xFFFEF3C7); // Amber-100

  /// 환영 메시지 배경
  static const Color welcomeBackground = Color(0xFFFFF7ED); // Orange-50

  /// 교육/안내 콘텐츠 배경
  static const Color educationBackground = Color(0xFFEFF6FF); // Blue-50

  /// 히스토리/타임라인 배경
  static const Color historyBackground = Color(0xFFF5F3FF); // Purple-50

  /// Success 배경
  static const Color successBackground = Color(0xFFECFDF5); // Emerald-50

  /// Error 배경
  static const Color errorBackground = Color(0xFFFEF2F2); // Red-50

  /// Warning 배경
  static const Color warningBackground = Color(0xFFFFFBEB); // Amber-50

  /// Info 배경
  static const Color infoBackground = Color(0xFFEFF6FF); // Blue-50

  // ============================================
  // Dark Mode Specific Colors
  // ============================================

  /// Dark mode background
  static const Color backgroundDark = neutral900;

  /// Dark mode surface (card, dialog)
  static const Color surfaceDark = neutral800;

  /// Dark mode surface variant
  static const Color surfaceVariantDark = neutral700;

  /// Dark mode primary text
  static const Color textPrimaryDark = neutral50;

  /// Dark mode secondary text
  static const Color textSecondaryDark = neutral400;

  /// Dark mode tertiary text
  static const Color textTertiaryDark = neutral500;

  /// Dark mode disabled text
  static const Color textDisabledDark = neutral600;

  /// Dark mode border
  static const Color borderDarkMode = neutral700;

  /// Dark mode border light
  static const Color borderLightDarkMode = neutral800;

  /// Dark mode primary (lighter for better visibility)
  static const Color primaryDark = Color(0xFF4ADE80); // Same as light mode (already bright)

  /// Dark mode error (lighter for better visibility)
  static const Color errorDark = Color(0xFFFCA5A5); // Red-300 for better contrast
}

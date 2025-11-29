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
    primary,    // 주요 데이터
    info,       // 보조 데이터
    secondary,  // 경고/주의
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    success,    // 성공/목표
  ];
}

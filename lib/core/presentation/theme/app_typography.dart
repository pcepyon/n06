import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 가비움 앱 타이포그래피 시스템
/// Design System v1.0 기반 + Letter Spacing 최적화
abstract final class AppTypography {
  static const String fontFamily = 'Pretendard';

  // ============================================
  // Display & Headings
  // ============================================

  /// Display (3xl): 28px, Bold
  /// 페이지 주 제목, 환영 메시지
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29, // 36px
    letterSpacing: -0.56, // -0.02em
    color: AppColors.textPrimary,
  );

  /// Heading 1 (2xl): 24px, Bold
  /// 섹션 제목, 모달 제목
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33, // 32px
    letterSpacing: -0.24, // -0.01em
    color: AppColors.textPrimary,
  );

  /// Heading 2 (xl): 20px, Semibold
  /// 하위 섹션 제목, 카드 제목
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4, // 28px
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Heading 3 (lg): 18px, Semibold
  /// 강조 텍스트, 리스트 헤더
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.44, // 26px
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================
  // Body Text
  // ============================================

  /// Body Large: 16px, Regular, Primary color
  /// 주요 본문 텍스트
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // 24px
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Medium: 16px, Regular, Secondary color
  /// 보조 본문 텍스트
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // 24px
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// Body Small (sm): 14px, Regular
  /// 보조 텍스트, 라벨, 설명
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43, // 20px
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ============================================
  // Caption & Meta
  // ============================================

  /// Caption (xs): 12px, Regular
  /// 캡션, 메타데이터, 타임스탬프
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33, // 16px
    letterSpacing: 0.12, // 0.01em
    color: AppColors.textTertiary,
  );

  // ============================================
  // Labels (버튼, UI 요소)
  // ============================================

  /// Label Large: 16px, Semibold
  /// 주요 버튼 텍스트
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24px
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Label Medium: 14px, Medium
  /// 보조 버튼, 탭 라벨
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43, // 20px
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Label Small: 12px, Medium
  /// 작은 라벨, 뱃지
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33, // 16px
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ============================================
  // Numeric (숫자 전용)
  // ============================================

  /// 큰 숫자 표시 (통계, 대시보드)
  static const TextStyle numericLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.64, // -0.02em
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 중간 숫자 표시
  static const TextStyle numericMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.24, // -0.01em
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 작은 숫자 표시 (인라인)
  static const TextStyle numericSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

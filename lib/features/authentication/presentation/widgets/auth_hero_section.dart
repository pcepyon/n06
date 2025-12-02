import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 인증 화면의 헤로 섹션 (로고, 제목, 부제목)
///
/// 로그인, 회원가입 등 인증 관련 화면에서 상단에 표시되는
/// 브랜드 로고와 환영 메시지를 포함한 섹션입니다.
///
/// 사용 예시:
/// ```dart
/// AuthHeroSection(
///   title: '가비움',
///   subtitle: 'GLP-1 치료를 체계적으로 관리하세요',
/// )
/// ```
class AuthHeroSection extends StatelessWidget {
  /// 주 제목 텍스트
  final String title;

  /// 부제목 텍스트 (Primary 색상으로 강조)
  final String subtitle;

  /// 로고 이미지 경로 (기본값: Gabium 로고)
  final String logoAssetPath;

  /// 로고 크기 (기본값: 192x192px)
  final double logoSize;

  const AuthHeroSection({
    super.key,
    this.title = '가비움',
    this.subtitle = '체계적으로 관리하세요',
    this.logoAssetPath = 'assets/logos/gabium-logo-192.png',
    this.logoSize = 192,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            logoAssetPath,
            width: logoSize,
            height: logoSize,
            cacheHeight: logoSize.toInt(),
            cacheWidth: logoSize.toInt(),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display,
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.heading3.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

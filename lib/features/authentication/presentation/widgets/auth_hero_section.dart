import 'package:flutter/material.dart';

/// 인증 화면의 헤로 섹션 (로고, 제목, 부제목)
///
/// 로그인, 회원가입 등 인증 관련 화면에서 상단에 표시되는
/// 브랜드 로고와 환영 메시지를 포함한 섹션입니다.
///
/// 사용 예시:
/// ```dart
/// AuthHeroSection(
///   title: 'GLP-1 치료 관리',
///   subtitle: '체계적으로 관리하세요',
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
    Key? key,
    this.title = 'GLP-1 치료 관리',
    this.subtitle = '체계적으로 관리하세요',
    this.logoAssetPath = 'assets/logos/gabium-logo-192.png',
    this.logoSize = 192,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Neutral-50
        borderRadius: BorderRadius.circular(12), // Border Radius md
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F172A).withOpacity(0.05), // Shadow xs
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
          const SizedBox(height: 24), // Spacing lg
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28, // Typography 3xl
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B), // Neutral-800
              height: 36 / 28,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18, // Typography lg
              fontWeight: FontWeight.w600,
              color: Color(0xFF4ADE80), // Primary
              height: 26 / 18,
            ),
          ),
        ],
      ),
    );
  }
}

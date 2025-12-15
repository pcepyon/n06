import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 소셜 로그인 버튼 컴포넌트
///
/// Kakao/Naver 소셜 로그인 버튼 (44px 높이, 브랜드 색상 유지)
///
/// 사용 예시:
/// ```dart
/// SocialLoginButton(
///   label: '카카오 로그인',
///   icon: Icons.chat_bubble,
///   backgroundColor: Color(0xFFFEE500),
///   foregroundColor: Colors.black87,
///   onPressed: _handleKakaoLogin,
/// )
/// ```
class SocialLoginButton extends StatelessWidget {
  /// 버튼 레이블 텍스트
  final String label;

  /// 버튼 아이콘
  final IconData icon;

  /// 배경색 (소셜 브랜드 색)
  final Color backgroundColor;

  /// 텍스트 및 아이콘 색
  final Color foregroundColor;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 클릭 콜백
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: !isLoading && onPressed != null,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.4),
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Icon(icon, size: 24),
        label: Text(
          label,
          style: AppTypography.labelLarge.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}

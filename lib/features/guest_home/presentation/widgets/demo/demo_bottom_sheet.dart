import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 데모 바텀시트를 표시하는 함수
///
/// 80% 높이의 바텀시트에 데모 콘텐츠를 표시하고,
/// 하단에 "내 기록 시작하기" CTA 배너를 고정합니다.
///
/// Parameters:
/// - [context]: BuildContext
/// - [child]: 바텀시트 내부에 표시할 위젯
/// - [title]: 바텀시트 상단 타이틀
/// - [onCtaTap]: "내 기록 시작하기" 버튼 클릭 시 콜백 (로그인/회원가입 화면으로 이동)
///
/// Returns:
/// - Future that completes when the bottom sheet is closed
///
/// Example:
/// ```dart
/// await showDemoBottomSheet(
///   context: context,
///   title: '데일리 체크인 체험하기',
///   child: DailyCheckinDemo(
///     onComplete: () => Navigator.pop(context),
///   ),
///   onCtaTap: () {
///     Navigator.pop(context);
///     context.go('/signin');
///   },
/// );
/// ```
Future<void> showDemoBottomSheet({
  required BuildContext context,
  required Widget child,
  required String title,
  VoidCallback? onCtaTap,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DemoBottomSheetContent(
      title: title,
      onCtaTap: onCtaTap,
      child: child,
    ),
  );
}

/// 데모 바텀시트 콘텐츠 위젯
///
/// 구조:
/// - 드래그 핸들 (상단 중앙)
/// - 헤더 (타이틀 + X 버튼)
/// - 스크롤 가능한 콘텐츠 영역
/// - 하단 고정 CTA 배너 (항상 표시)
class DemoBottomSheetContent extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onCtaTap;

  const DemoBottomSheetContent({
    super.key,
    required this.title,
    required this.child,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // 80% 높이
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          _buildDragHandle(),
          // 헤더 (제목 + X 버튼)
          _buildHeader(context),
          // 콘텐츠 영역 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: child,
            ),
          ),
          // 하단 고정 CTA 배너
          _buildCtaBanner(context),
        ],
      ),
    );
  }

  /// 드래그 핸들 (상단 중앙 바)
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 헤더 (타이틀 + X 버튼)
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // 타이틀
          Expanded(
            child: Text(
              title,
              style: AppTypography.heading2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          // X 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: AppColors.neutral600,
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 고정 CTA 배너
  ///
  /// 스타일:
  /// - 배경: Primary color 10% tint
  /// - 아이콘 + 텍스트: "내 기록으로 직접 시작해보세요"
  /// - 버튼: "내 기록 시작하기" (FilledButton)
  /// - SafeArea 적용 (하단)
  Widget _buildCtaBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1), // Primary 10% tint
        border: const Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 + 안내 텍스트
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '내 기록으로 직접 시작해보세요',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // CTA 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onCtaTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '내 기록 시작하기',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

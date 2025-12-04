import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/daily_checkin/presentation/utils/red_flag_localizations.dart';

/// Red Flag 안내 바텀시트
///
/// Red Flag 감지 시 사용자에게 부드럽게 안내하는 바텀시트입니다.
/// UX 원칙: 두려움 최소화, 금지 용어("경고", "위험", "응급실") 사용 안 함
class RedFlagGuidanceSheet extends StatelessWidget {
  final RedFlagDetection redFlag;
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onFindHospital;

  const RedFlagGuidanceSheet({
    super.key,
    required this.redFlag,
    required this.message,
    this.onDismiss,
    this.onFindHospital,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // 이모지 + 제목
              Text(
                '💛',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),

              Text(
                _getTitle(context),
                textAlign: TextAlign.center,
                style: AppTypography.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 16),

              // 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.neutral800,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  // 나중에 확인할게요 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        onDismiss?.call();
                        Navigator.of(context).pop('dismissed');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neutral700,
                        side: BorderSide(color: AppColors.neutral300),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.checkin_redFlag_checkLaterButton,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 병원 찾기 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        onFindHospital?.call();
                        await _openHospitalSearch(context);
                        if (context.mounted) {
                          Navigator.of(context).pop('hospital_search');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.checkin_redFlag_findHospitalButton,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(BuildContext context) {
    return redFlag.severity.getTitle(context);
  }

  /// 병원 검색 열기 (네이버 지도 또는 카카오맵)
  Future<void> _openHospitalSearch(BuildContext context) async {
    // 내과 검색 쿼리
    final query = context.l10n.checkin_redFlag_hospitalSearchQuery;

    // 네이버 지도 앱 우선
    final naverMapUri = Uri.parse(
      'nmap://search?query=$query&appname=com.glp1.app',
    );

    // 카카오맵 앱
    final kakaoMapUri = Uri.parse(
      'kakaomap://search?q=$query',
    );

    // 웹 폴백 (네이버 지도 웹)
    final webUri = Uri.parse(
      'https://map.naver.com/v5/search/$query',
    );

    try {
      if (await canLaunchUrl(naverMapUri)) {
        await launchUrl(naverMapUri);
      } else if (await canLaunchUrl(kakaoMapUri)) {
        await launchUrl(kakaoMapUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 실패 시 웹으로 폴백
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Red Flag 안내 바텀시트 표시 헬퍼 함수
///
/// 반환값: 'dismissed' | 'hospital_search' | null
Future<String?> showRedFlagGuidanceSheet({
  required BuildContext context,
  required RedFlagDetection redFlag,
  required String message,
  VoidCallback? onDismiss,
  VoidCallback? onFindHospital,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: true,
    builder: (context) => RedFlagGuidanceSheet(
      redFlag: redFlag,
      message: message,
      onDismiss: onDismiss,
      onFindHospital: onFindHospital,
    ),
  );
}

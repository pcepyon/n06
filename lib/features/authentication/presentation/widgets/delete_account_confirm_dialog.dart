import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 계정 삭제 확인 다이얼로그
///
/// UX 요구사항:
/// - 2단계 확인: 경고 표시 + 체크박스로 동의 확인
/// - 삭제되는 데이터 목록 명시
/// - 복구 불가 안내
class DeleteAccountConfirmDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DeleteAccountConfirmDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  State<DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends State<DeleteAccountConfirmDialog> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    // Dialog + Row + Expanded 패턴 사용 (BUG-20251130-152000)
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '계정 삭제',
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 경고 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '계정을 삭제하면 복구할 수 없습니다.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 삭제되는 데이터 목록
            Text(
              '다음 데이터가 영구적으로 삭제됩니다:',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildDataList(),
            const SizedBox(height: 16),

            // 동의 체크박스
            InkWell(
              onTap: () {
                setState(() {
                  _isConfirmed = !_isConfirmed;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isConfirmed,
                      onChanged: (value) {
                        setState(() {
                          _isConfirmed = value ?? false;
                        });
                      },
                      activeColor: AppColors.error,
                    ),
                    Expanded(
                      child: Text(
                        '위 내용을 확인했으며, 계정 삭제에 동의합니다.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 버튼 Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onCancel?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.neutral400),
                    ),
                    child: Text(
                      '취소',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConfirmed
                        ? () {
                            Navigator.pop(context);
                            widget.onConfirm();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      disabledBackgroundColor:
                          AppColors.error.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '삭제',
                      style: AppTypography.labelLarge.copyWith(
                        color: _isConfirmed
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList() {
    final dataItems = [
      '프로필 및 목표 정보',
      '체중 기록',
      '투여 기록 및 계획',
      '데일리 체크인 기록',
      '획득한 뱃지',
      '알림 설정',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dataItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Icon(
                Icons.remove,
                size: 16,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                item,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

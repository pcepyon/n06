import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 2주 이상 투여 공백 시 스케줄 재시작 안내 다이얼로그
class RestartScheduleDialog extends ConsumerStatefulWidget {
  final DoseRecord? lastRecord;
  final List<DoseSchedule> skippedSchedules;

  const RestartScheduleDialog({
    required this.lastRecord,
    required this.skippedSchedules,
    super.key,
  });

  @override
  ConsumerState<RestartScheduleDialog> createState() =>
      _RestartScheduleDialogState();
}

class _RestartScheduleDialogState extends ConsumerState<RestartScheduleDialog> {
  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  int get _daysSinceLastDose {
    if (widget.lastRecord == null) return 0;
    final today = DateTime.now();
    return today.difference(widget.lastRecord!.administeredAt).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final lastRecord = widget.lastRecord;
    final skippedCount = widget.skippedSchedules.length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 경고 아이콘과 제목
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 24,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '투여가 오랫동안 중단되었습니다',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 마지막 투여 정보
              if (lastRecord != null) ...[
                _buildInfoRow(
                  icon: Icons.medication,
                  label: '마지막 투여',
                  value:
                      '${lastRecord.administeredAt.month}/${lastRecord.administeredAt.day} (${_getWeekday(lastRecord.administeredAt)}) - $_daysSinceLastDose일 전',
                ),
                const SizedBox(height: 12),
              ],

              // 건너뛴 스케줄 수
              _buildInfoRow(
                icon: Icons.event_busy,
                label: '건너뛴 스케줄',
                value: '$skippedCount건',
              ),
              const SizedBox(height: 16),

              // 건너뛴 스케줄 목록 (최대 5개)
              if (widget.skippedSchedules.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...widget.skippedSchedules.take(5).map((schedule) {
                        final date = schedule.scheduledDate;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${date.month}/${date.day} (${_getWeekday(date)}) - ${schedule.scheduledDoseMg}mg',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (skippedCount > 5) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '외 ${skippedCount - 5}건...',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 의료진 상담 권장 안내
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '오랜 중단 후 재시작 시\n의료진과 상담하여 용량을 확인하세요',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 액션 버튼
              SizedBox(
                width: double.infinity,
                child: GabiumButton(
                  text: '스케줄 재설정하기',
                  onPressed: _handleRestart,
                  variant: GabiumButtonVariant.primary,
                  size: GabiumButtonSize.medium,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GabiumButton(
                  text: '나중에 하기',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: GabiumButtonVariant.secondary,
                  size: GabiumButtonSize.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRestart() {
    // 다이얼로그 닫기
    Navigator.of(context).pop();
    // 투여 계획 재설정 화면으로 이동 (재시작 모드)
    context.push('/dose-plan/edit?restart=true');
  }
}

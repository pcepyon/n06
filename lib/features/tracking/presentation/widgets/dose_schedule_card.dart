import 'package:flutter/material.dart';
import 'package:n06/core/presentation/widgets/status_badge.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// DoseScheduleCard 위젯
/// 투여 스케줄 정보를 표시하는 카드 컴포넌트
/// Gabium Design System의 Card 스타일과 토큰 값 사용
class DoseScheduleCard extends StatefulWidget {
  final String doseAmount;
  final String scheduledDate;
  final StatusBadgeType statusType;
  final String statusText;
  final IconData statusIcon;
  final VoidCallback onActionPressed;
  final bool isLoading;

  const DoseScheduleCard({
    super.key,
    required this.doseAmount,
    required this.scheduledDate,
    required this.statusType,
    required this.statusText,
    required this.statusIcon,
    required this.onActionPressed,
    this.isLoading = false,
  });

  @override
  State<DoseScheduleCard> createState() => _DoseScheduleCardState();
}

class _DoseScheduleCardState extends State<DoseScheduleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200), // Base transition
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _hoverController.forward();
      },
      onExit: (_) {
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onActionPressed,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -2 * _hoverController.value), // 2px lift on hover
              child: Container(
                margin: const EdgeInsets.only(bottom: 16), // md spacing (카드 간 여백)
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.06 + 0.02 * _hoverController.value,
                      ),
                      blurRadius: 4 + 4 * _hoverController.value,
                      offset: Offset(0, 2 + 2 * _hoverController.value),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dose Amount (xl, Semibold) - 투여량
                    Text(
                      widget.doseAmount,
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Scheduled Date (base, Regular) - 예정 날짜
                    Text(
                      widget.scheduledDate,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8), // sm spacing

                    // Status Badge - 상태 배지
                    StatusBadge(
                      type: widget.statusType,
                      text: widget.statusText,
                      icon: widget.statusIcon,
                    ),
                    const SizedBox(height: 16), // md spacing

                    // Action Button (Primary) - 액션 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 44, // Medium button height
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : widget.onActionPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.4),
                          disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: widget.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                '기록',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

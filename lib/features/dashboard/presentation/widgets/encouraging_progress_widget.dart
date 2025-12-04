import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/dashboard/domain/entities/weekly_progress.dart';

/// 진행률을 긍정적 언어로 표현하고, 높은 달성률에 시각적 축하를 제공하는 위젯
///
/// Design Intent:
/// - "부작용 기록" -> "몸의 신호 체크" (정상화)
/// - 80%+ 달성 시 sparkle 효과로 성취감
/// - 그라데이션 진행률 바로 시각적 만족감
class EncouragingProgressWidget extends StatelessWidget {
  final WeeklyProgress weeklyProgress;

  const EncouragingProgressWidget({
    super.key,
    required this.weeklyProgress,
  });

  /// 부정적 라벨을 긍정적/정상화된 라벨로 변환
  ///
  /// 심리학적 근거:
  /// - "부작용" -> "몸의 신호" : 부작용을 문제가 아닌 피드백으로 재해석
  /// - "기록" -> "체크" : 부담을 줄이고 간단한 행동으로 인식
  static String getEncouragingLabel(BuildContext context, String originalLabel) {
    final l10n = context.l10n;
    // Compare against localized keys to support all languages
    if (originalLabel == l10n.dashboard_progress_dose) {
      return l10n.dashboard_progress_doseEncouraging;
    } else if (originalLabel == l10n.dashboard_progress_weight) {
      return l10n.dashboard_progress_weightEncouraging;
    } else if (originalLabel == l10n.dashboard_progress_symptom) {
      return l10n.dashboard_progress_symptomEncouraging;
    }
    return originalLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          context.l10n.dashboard_progress_title,
          style: AppTypography.heading2,
        ),
        const SizedBox(height: 16), // md spacing

        // Progress Items
        Column(
          children: [
            _EncouragingProgressItem(
              label: context.l10n.dashboard_progress_dose,
              current: weeklyProgress.doseCompletedCount,
              total: weeklyProgress.doseTargetCount,
            ),
            const SizedBox(height: 16),
            _EncouragingProgressItem(
              label: context.l10n.dashboard_progress_weight,
              current: weeklyProgress.weightRecordCount,
              total: weeklyProgress.weightTargetCount,
            ),
            const SizedBox(height: 16),
            _EncouragingProgressItem(
              label: context.l10n.dashboard_progress_symptom,
              current: weeklyProgress.symptomRecordCount,
              total: weeklyProgress.symptomTargetCount,
            ),
          ],
        ),
      ],
    );
  }
}

class _EncouragingProgressItem extends StatefulWidget {
  final String label;
  final int current;
  final int total;

  const _EncouragingProgressItem({
    required this.label,
    required this.current,
    required this.total,
  });

  @override
  State<_EncouragingProgressItem> createState() =>
      _EncouragingProgressItemState();
}

class _EncouragingProgressItemState extends State<_EncouragingProgressItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // 80% 이상일 때 축하 애니메이션 시작
    final progress = widget.total > 0 ? widget.current / widget.total : 0.0;
    if (progress >= 0.8) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_EncouragingProgressItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final progress = widget.total > 0 ? widget.current / widget.total : 0.0;
    final oldProgress =
        oldWidget.total > 0 ? oldWidget.current / oldWidget.total : 0.0;

    if (progress >= 0.8 && oldProgress < 0.8) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.total > 0 ? widget.current / widget.total : 0.0;
    final isComplete = progress >= 1.0;
    final isHighAchievement = progress >= 0.8;
    final percentage = (progress * 100).toInt();

    // 라벨 리프레이밍 적용
    final encouragingLabel =
        EncouragingProgressWidget.getEncouragingLabel(context, widget.label);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Encouraging Label and Fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                encouragingLabel,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
              Text(
                '${widget.current}/${widget.total}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Gradient Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    height: 8,
                    color: AppColors.neutral200,
                  ),
                  // Fill with gradient (or solid success for 100%)
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isComplete
                            ? null
                            : LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.6),
                                  AppColors.primary,
                                ],
                              ),
                        color: isComplete ? AppColors.success : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Footer Row: Percentage with Celebration
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Sparkle animation for 80%+
              if (isHighAchievement)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
                ),
              // Percentage text
              Text(
                '$percentage%',
                style: AppTypography.labelMedium.copyWith(
                  color: isComplete ? AppColors.success : AppColors.primary,
                ),
              ),
              // "완료!" text for 100%
              if (isComplete)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    context.l10n.dashboard_progress_completed,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

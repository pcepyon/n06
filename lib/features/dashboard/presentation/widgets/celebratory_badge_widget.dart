import 'package:flutter/material.dart';
import 'package:n06/core/constants/badge_constants.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import '../utils/badge_l10n.dart';
import '../../domain/entities/user_badge.dart';

/// Helper class to get badge metadata from badgeId
class _BadgeMetadata {
  final String name;
  final IconData icon;
  final String description;

  const _BadgeMetadata({
    required this.name,
    required this.icon,
    required this.description,
  });

  // Badge ID constants from SSOT
  static final _streak7 =
      BadgeConstants.streakBadgeId(BadgeConstants.streakBadgeDays[0]);
  static final _streak30 =
      BadgeConstants.streakBadgeId(BadgeConstants.streakBadgeDays[1]);
  static final _weight25 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[0]);
  static final _weight50 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[1]);
  static final _weight75 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[2]);
  static final _weight100 =
      BadgeConstants.weightProgressBadgeId(BadgeConstants.weightProgressBadgePercents[3]);

  static _BadgeMetadata fromBadgeId(BuildContext context, String badgeId) {
    IconData icon;
    if (badgeId == _streak7) {
      icon = Icons.local_fire_department;
    } else if (badgeId == _streak30) {
      icon = Icons.whatshot;
    } else if (badgeId == _weight25) {
      icon = Icons.trending_down;
    } else if (badgeId == _weight50) {
      icon = Icons.show_chart;
    } else if (badgeId == _weight75) {
      icon = Icons.trending_down;
    } else if (badgeId == _weight100) {
      icon = Icons.scale;
    } else if (badgeId == BadgeConstants.firstDoseBadgeId) {
      icon = Icons.check_circle;
    } else {
      icon = Icons.emoji_events;
    }

    return _BadgeMetadata(
      name: context.getBadgeName(badgeId),
      icon: icon,
      description: context.getBadgeDescription(badgeId),
    );
  }
}

/// 다음 획득 가능 뱃지 찾기 (가장 진행률 높은)
/// Fitbit 스타일 - 가장 가까운 목표를 하이라이트
UserBadge? getNextUpBadge(List<UserBadge> badges) {
  final inProgress = badges.where((b) => b.status == BadgeStatus.inProgress);
  if (inProgress.isEmpty) return null;
  return inProgress.reduce(
    (a, b) => a.progressPercentage > b.progressPercentage ? a : b,
  );
}

/// CelebratoryBadgeWidget - 축하 애니메이션과 함께하는 뱃지 위젯
///
/// Duolingo 스타일 즉각적 보상:
/// - 다음 획득 가능 뱃지 하이라이트 (dashed Primary border)
/// - 탭 피드백 애니메이션
/// - 격려적인 빈 상태 메시지
class CelebratoryBadgeWidget extends StatelessWidget {
  final List<UserBadge> badges;

  const CelebratoryBadgeWidget({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          context.l10n.dashboard_badge_title,
          style: AppTypography.heading2,
        ),

        const SizedBox(height: 16), // md spacing

        // Badge Grid or Empty State
        if (badges.isEmpty)
          const _EmptyState()
        else
          _BadgeGrid(
            badges: badges,
            nextUpBadge: getNextUpBadge(badges),
          ),
      ],
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final List<UserBadge> badges;
  final UserBadge? nextUpBadge;

  const _BadgeGrid({
    required this.badges,
    required this.nextUpBadge,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16, // md gap
        mainAxisSpacing: 16, // md gap
        childAspectRatio: 0.8, // Adjust for label below circle
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isNextUp = nextUpBadge != null && badge.id == nextUpBadge!.id;
        return _BadgeItem(
          badge: badge,
          isNextUp: isNextUp,
        );
      },
    );
  }
}

class _BadgeItem extends StatefulWidget {
  final UserBadge badge;
  final bool isNextUp;

  const _BadgeItem({
    required this.badge,
    required this.isNextUp,
  });

  @override
  State<_BadgeItem> createState() => _BadgeItemState();
}

class _BadgeItemState extends State<_BadgeItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final progress = widget.badge.progressPercentage / 100.0;
    final isAchieved = widget.badge.status == BadgeStatus.achieved;
    final isLocked = widget.badge.status == BadgeStatus.locked;
    final metadata = _BadgeMetadata.fromBadgeId(context, widget.badge.badgeId);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showBadgeDetail(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Circle
            _buildBadgeCircle(
              isAchieved: isAchieved,
              isLocked: isLocked,
              isNextUp: widget.isNextUp,
              metadata: metadata,
            ),

            const SizedBox(height: 8),

            // Badge Label
            Text(
              metadata.name,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress Text (only for In Progress)
            if (!isAchieved && !isLocked) ...[
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCircle({
    required bool isAchieved,
    required bool isLocked,
    required bool isNextUp,
    required _BadgeMetadata metadata,
  }) {
    // Next-Up State (closest to achievement) - dashed Primary border
    if (isNextUp && !isAchieved && !isLocked) {
      return CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.primary,
          strokeWidth: 2,
          dashWidth: 5,
          dashSpace: 3,
        ),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
          child: Center(
            child: Icon(
              metadata.icon,
              size: 32,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    Color backgroundColor;
    Color? borderColor;
    double borderWidth;
    Color iconColor;
    List<BoxShadow>? boxShadow;
    Gradient? gradient;

    if (isAchieved) {
      // Achieved state
      backgroundColor = AppColors.gold;
      borderColor = AppColors.gold;
      borderWidth = 3;
      iconColor = AppColors.surface;
      boxShadow = [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
      gradient = const LinearGradient(
        colors: [AppColors.gold, Color(0xFFFCD34D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isLocked) {
      // Locked state
      backgroundColor = AppColors.neutral200;
      borderColor = null;
      borderWidth = 0;
      iconColor = AppColors.borderDark;
      boxShadow = null;
      gradient = null;
    } else {
      // In Progress state (not next-up)
      backgroundColor = AppColors.surfaceVariant;
      borderColor = AppColors.borderDark;
      borderWidth = 2;
      iconColor = AppColors.neutral400;
      boxShadow = null;
      gradient = null;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        border: borderColor != null
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: boxShadow,
      ),
      child: Center(
        child: Icon(
          metadata.icon,
          size: 32,
          color: iconColor,
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    final metadata = _BadgeMetadata.fromBadgeId(context, widget.badge.badgeId);
    final progress = widget.badge.progressPercentage / 100.0;

    // Show modal bottom sheet with badge details
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(metadata.icon, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                metadata.name,
                style: AppTypography.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                metadata.description,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.badge.status != BadgeStatus.achieved)
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Dashed border painter for Next-Up badge state
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Calculate the circumference
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    // Draw dashed circle
    for (int i = 0; i < dashCount; i++) {
      final startAngle =
          (i * (dashWidth + dashSpace) / radius) - (3.141592653589793 / 2);
      final sweepAngle = dashWidth / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Empty state with encouraging message (Headspace style)
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(32),
      child: Builder(
        builder: (context) => Column(
          children: [
            // celebration icon - more warm and encouraging than emoji_events
            const Icon(
              Icons.celebration,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.dashboard_badge_empty_title,
              style: AppTypography.heading2.copyWith(
                color: AppColors.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.dashboard_badge_empty_message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to achievements screen or show goal list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.l10n.dashboard_badge_empty_button),
            ),
          ],
        ),
      ),
    );
  }
}

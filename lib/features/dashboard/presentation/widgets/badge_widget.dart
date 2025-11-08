import 'package:flutter/material.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';

class BadgeWidget extends StatelessWidget {
  final List<UserBadge> badges;

  const BadgeWidget({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '아직 뱃지가 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성취 뱃지',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map((badge) => _BadgeItem(badge: badge)).toList(),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final UserBadge badge;

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isAchieved = badge.status == BadgeStatus.achieved;
    final isInProgress = badge.status == BadgeStatus.inProgress;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAchieved
                ? Colors.amber[100]
                : isInProgress
                    ? Colors.grey[200]
                    : Colors.grey[100],
            border: isAchieved ? Border.all(color: Colors.amber, width: 2) : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForBadge(badge.badgeId),
                  color: isAchieved ? Colors.amber : Colors.grey,
                  size: 32,
                ),
                if (isInProgress) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${badge.progressPercentage}%',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            _getLabelForBadge(badge.badgeId),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getIconForBadge(String badgeId) {
    switch (badgeId) {
      case 'streak_7':
        return Icons.local_fire_department;
      case 'streak_30':
        return Icons.whatshot;
      case 'weight_5percent':
        return Icons.trending_down;
      case 'weight_10percent':
        return Icons.scale;
      case 'first_dose':
        return Icons.check_circle;
      default:
        return Icons.emoji_events;
    }
  }

  String _getLabelForBadge(String badgeId) {
    switch (badgeId) {
      case 'streak_7':
        return '7일 연속';
      case 'streak_30':
        return '30일 연속';
      case 'weight_5percent':
        return '5% 감량';
      case 'weight_10percent':
        return '10% 감량';
      case 'first_dose':
        return '첫 투여';
      default:
        return '뱃지';
    }
  }
}

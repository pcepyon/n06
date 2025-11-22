import 'package:flutter/material.dart';
import '../../domain/entities/user_badge.dart';

// Helper class to get badge metadata from badgeId
class _BadgeMetadata {
  final String name;
  final IconData icon;
  final String description;

  const _BadgeMetadata({
    required this.name,
    required this.icon,
    required this.description,
  });

  static _BadgeMetadata fromBadgeId(String badgeId) {
    switch (badgeId) {
      case 'streak_7':
        return const _BadgeMetadata(
          name: '7일 연속',
          icon: Icons.local_fire_department,
          description: '7일 연속으로 투여를 완료했습니다!',
        );
      case 'streak_30':
        return const _BadgeMetadata(
          name: '30일 연속',
          icon: Icons.whatshot,
          description: '30일 연속으로 투여를 완료했습니다!',
        );
      case 'weight_5percent':
        return const _BadgeMetadata(
          name: '5% 감량',
          icon: Icons.trending_down,
          description: '체중 5% 감량을 달성했습니다!',
        );
      case 'weight_10percent':
        return const _BadgeMetadata(
          name: '10% 감량',
          icon: Icons.scale,
          description: '체중 10% 감량을 달성했습니다!',
        );
      case 'first_dose':
        return const _BadgeMetadata(
          name: '첫 투여',
          icon: Icons.check_circle,
          description: '첫 투여를 완료했습니다!',
        );
      default:
        return const _BadgeMetadata(
          name: '뱃지',
          icon: Icons.emoji_events,
          description: '특별한 성취를 달성했습니다!',
        );
    }
  }
}

class BadgeWidget extends StatelessWidget {
  final List<UserBadge> badges;

  const BadgeWidget({
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
          '성취 뱃지',
          style: TextStyle(
            fontSize: 18, // lg
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
            height: 1.3,
          ),
        ),

        SizedBox(height: 16), // md spacing

        // Badge Grid or Empty State
        if (badges.isEmpty)
          _EmptyState()
        else
          _BadgeGrid(badges: badges),
      ],
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final List<UserBadge> badges;

  const _BadgeGrid({required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16, // md gap
        mainAxisSpacing: 16, // md gap
        childAspectRatio: 0.8, // Adjust for label below circle
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return _BadgeItem(badge: badges[index]);
      },
    );
  }
}

class _BadgeItem extends StatefulWidget {
  final UserBadge badge;

  const _BadgeItem({required this.badge});

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
    final metadata = _BadgeMetadata.fromBadgeId(widget.badge.badgeId);

    Color backgroundColor;
    Color? borderColor;
    double borderWidth;
    Color iconColor;
    List<BoxShadow>? boxShadow;

    if (isAchieved) {
      // Achieved state
      backgroundColor = Color(0xFFF59E0B); // Gold (gradient not supported in Container, use decoration gradient)
      borderColor = Color(0xFFF59E0B);
      borderWidth = 3;
      iconColor = Colors.white;
      boxShadow = [
        BoxShadow(
          color: Color(0x33F59E0B), // 0.2 opacity
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ];
    } else if (isLocked) {
      // Locked state
      backgroundColor = Color(0xFFE2E8F0); // Neutral-200
      borderColor = null;
      borderWidth = 0;
      iconColor = Color(0xFFCBD5E1); // Neutral-300
      boxShadow = null;
    } else {
      // In Progress state
      backgroundColor = Color(0xFFF1F5F9); // Neutral-100
      borderColor = Color(0xFFCBD5E1); // Neutral-300
      borderWidth = 2;
      iconColor = Color(0xFF94A3B8); // Neutral-400
      boxShadow = null;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showBadgeDetail(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                border: borderColor != null
                    ? Border.all(color: borderColor, width: borderWidth)
                    : null,
                boxShadow: boxShadow,
                gradient: isAchieved
                    ? LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: Center(
                child: Icon(
                  metadata.icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
            ),

            SizedBox(height: 8),

            // Badge Label
            Text(
              metadata.name,
              style: TextStyle(
                fontSize: 12, // xs
                fontWeight: FontWeight.w500, // Medium
                color: Color(0xFF334155), // Neutral-700
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress Text (only for In Progress)
            if (!isAchieved && !isLocked) ...[
              SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12, // xs
                  fontWeight: FontWeight.w400, // Regular
                  color: Color(0xFF64748B), // Neutral-500
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    final metadata = _BadgeMetadata.fromBadgeId(widget.badge.badgeId);
    final progress = widget.badge.progressPercentage / 100.0;

    // Show modal bottom sheet with badge details
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(metadata.icon, size: 80, color: Color(0xFF4ADE80)),
              SizedBox(height: 16),
              Text(
                metadata.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                metadata.description,
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              if (widget.badge.status != BadgeStatus.achieved)
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation(Color(0xFF4ADE80)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC), // Neutral-50
        border: Border.all(
          color: Color(0xFFE2E8F0), // Neutral-200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // md
      ),
      padding: EdgeInsets.all(32), // xl padding
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48, // xl
            color: Color(0xFF4ADE80), // Primary
          ),
          SizedBox(height: 16),
          Text(
            '첫 뱃지를 획득해보세요!',
            style: TextStyle(
              fontSize: 18, // lg
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '목표를 달성하고 성취 뱃지를 모아보세요.',
            style: TextStyle(
              fontSize: 16, // base
              fontWeight: FontWeight.w400, // Regular
              color: Color(0xFF475569), // Neutral-600
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to achievements screen or show goal list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4ADE80), // Primary
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('목표 확인하기'),
          ),
        ],
      ),
    );
  }
}

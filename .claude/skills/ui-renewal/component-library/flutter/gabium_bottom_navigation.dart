import 'package:flutter/material.dart';

/// Bottom navigation item data model
class GabiumBottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const GabiumBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Gabium Design System compliant Bottom Navigation Bar
///
/// A bottom navigation component that follows Gabium Design System v1.0 specifications.
/// Features 5 tabs with scale animation on tap and semantic color states.
///
/// Example usage:
/// ```dart
/// GabiumBottomNavigation(
///   items: [
///     GabiumBottomNavItem(
///       label: '홈',
///       icon: Icons.home_outlined,
///       activeIcon: Icons.home,
///       route: '/home',
///     ),
///     // ... other items
///   ],
///   currentIndex: 0,
///   onTap: (index) => context.go(items[index].route),
/// )
/// ```
///
/// Design System Tokens:
/// - Background: White (#FFFFFF)
/// - Border Top: Neutral-200 (#E2E8F0), 1px
/// - Shadow: Reverse md (0 -4px 8px rgba(15, 23, 42, 0.08))
/// - Height: 56px + SafeArea bottom inset
/// - Active Color: Primary (#4ADE80)
/// - Inactive Color: Neutral-500 (#64748B)
/// - Icon Size: 24px
/// - Label Font: 12px (xs), Medium (500)
///
/// Interactions:
/// - Tap: Scale 0.95 animation (150ms ease-out), then restore
/// - Icon + Label color change on active state
///
/// Accessibility:
/// - Min touch target: 56px × 56px per item
/// - Semantic labels for each tab
/// - Current index announced to screen readers
class GabiumBottomNavigation extends StatelessWidget {
  final List<GabiumBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GabiumBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0), // Neutral-200
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0F172A).withOpacity(0.08), // rgba(15, 23, 42, 0.08)
            blurRadius: 8,
            offset: Offset(0, -4), // Reverse shadow for elevation above content
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return _BottomNavItem(
                label: item.label,
                icon: item.icon,
                activeIcon: item.activeIcon,
                isActive: isActive,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? Color(0xFF4ADE80) // Primary (active state)
        : Color(0xFF64748B); // Neutral-500 (inactive state)

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          constraints: BoxConstraints(minWidth: 56, minHeight: 56),
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isActive ? widget.activeIcon : widget.icon,
                size: 24,
                color: color,
              ),
              SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12, // xs
                  fontWeight: FontWeight.w500, // Medium
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

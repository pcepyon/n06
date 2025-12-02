import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/widgets/gabium_bottom_navigation.dart';

/// Scaffold wrapper that includes Gabium Bottom Navigation Bar
///
/// Used with GoRouter ShellRoute to provide persistent bottom navigation
/// across main app screens.
///
/// Example usage in GoRouter:
/// ```dart
/// ShellRoute(
///   builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
///   routes: [
///     GoRoute(path: '/home', ...),
///     GoRoute(path: '/tracking/weight', ...),
///     // ... other routes
///   ],
/// )
/// ```
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({
    super.key,
    required this.child,
  });

  /// Bottom navigation items configuration
  static final List<GabiumBottomNavItem> _navItems = [
    GabiumBottomNavItem(
      label: '홈',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/home',
    ),
    GabiumBottomNavItem(
      label: '체크인',
      icon: Icons.check_circle_outline,
      activeIcon: Icons.check_circle,
      route: '/daily-checkin',
    ),
    GabiumBottomNavItem(
      label: '일정',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      route: '/dose-schedule',
    ),
    GabiumBottomNavItem(
      label: '가이드',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      route: '/coping-guide',
    ),
    GabiumBottomNavItem(
      label: '설정',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      route: '/settings',
    ),
  ];

  /// Calculate current tab index based on current route
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    // Check exact match first
    for (int i = 0; i < _navItems.length; i++) {
      if (location == _navItems[i].route) {
        return i;
      }
    }

    // Check if route starts with any nav item route (for sub-routes)
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].route)) {
        return i;
      }
    }

    // Default to home if no match
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index != _calculateSelectedIndex(context)) {
      context.go(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: GabiumBottomNavigation(
        items: _navItems,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

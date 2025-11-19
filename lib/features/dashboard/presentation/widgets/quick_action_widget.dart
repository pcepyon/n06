import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionWidget extends StatelessWidget {
  const QuickActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '빠른 액션',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.scale,
              label: '체중 기록',
              color: Colors.blue,
              onTap: () => context.push('/tracking/weight'),
            ),
            _QuickActionButton(
              icon: Icons.favorite,
              label: '부작용 기록',
              color: Colors.pink,
              onTap: () => context.push('/tracking/symptom'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.check_circle,
              label: '투여 기록',
              color: Colors.green,
              onTap: () => context.push('/dose-schedule'),
            ),
            _QuickActionButton(
              icon: Icons.menu_book,
              label: '대처 가이드',
              color: Colors.purple,
              onTap: () => context.push('/coping-guide'),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final String userName;
  final double targetWeight;

  const UserInfoCard({
    required this.userName,
    required this.targetWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // White
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0), // md (12px)
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06), // sm shadow
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0), // md (16px)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            '사용자 정보',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1E293B), // Neutral-800
              fontSize: 20.0, // xl
              fontWeight: FontWeight.w600, // Semibold
            ),
          ),
          const SizedBox(height: 8.0), // sm spacing after title

          // Data item 1: Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이름',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF334155), // Neutral-700
                  fontSize: 14.0, // sm
                  fontWeight: FontWeight.w500, // Medium
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569), // Neutral-600
                  fontSize: 16.0, // base
                  fontWeight: FontWeight.w400, // Regular
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0), // sm spacing between items

          // Data item 2: Target weight
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '목표 체중',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF334155), // Neutral-700
                  fontSize: 14.0, // sm
                  fontWeight: FontWeight.w500, // Medium
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${targetWeight.toStringAsFixed(1)}kg',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569), // Neutral-600
                  fontSize: 16.0, // base
                  fontWeight: FontWeight.w400, // Regular
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

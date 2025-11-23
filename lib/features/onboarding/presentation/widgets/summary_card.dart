import 'package:flutter/material.dart';

/// Summary card component for displaying grouped data
/// Reusable for summary screens across the app
class SummaryCard extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const SummaryCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // md
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // White
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // md
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A), // Neutral-900 at 6%
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18, // lg
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF1E293B), // Neutral-800
              ),
            ),
          ),

          // Card Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final (label, value) = entry.value;
            final isLast = index == items.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12), // sm spacing
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14, // sm
                      fontWeight: FontWeight.w500, // Medium
                      color: Color(0xFF334155), // Neutral-700
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16, // base
                        fontWeight: FontWeight.w400, // Regular
                        color: Color(0xFF475569), // Neutral-600
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

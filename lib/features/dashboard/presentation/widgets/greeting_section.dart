import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';

/// GreetingSection - 시간대별 인사 + 사용자 이름 + 연속 기록일
///
/// Phase 1 요구사항:
/// - 시간대별 인사 (오전: "좋은 아침이에요", 오후: "안녕하세요", 저녁: "편안한 저녁이에요")
/// - 사용자 이름 표시
/// - 연속 기록일 표시 (예: "14일째 함께하고 있어요")
/// - LLM 없이 앱 로직으로만 구현
class GreetingSection extends StatelessWidget {
  final DashboardData dashboardData;

  const GreetingSection({
    super.key,
    required this.dashboardData,
  });

  /// 시간대별 인사 메시지 생성
  String _getTimeBasedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요';
    } else if (hour < 18) {
      return '안녕하세요';
    } else {
      return '편안한 저녁이에요';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getTimeBasedGreeting(context);
    final userName = dashboardData.userName;
    final continuousDays = dashboardData.continuousRecordDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간대별 인사 + 사용자 이름
          Text(
            '$greeting, $userName님',
            style: AppTypography.display,
          ),
          const SizedBox(height: 8),
          // 연속 기록일
          Text(
            '$continuousDays일째 함께하고 있어요',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

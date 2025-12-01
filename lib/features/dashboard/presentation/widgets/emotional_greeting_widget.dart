import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/dashboard/domain/entities/dashboard_data.dart';

/// EmotionalGreetingWidget - 감정적으로 지지하고 동기를 부여하는 따뜻한 인사 위젯
///
/// Headspace/Noom 스타일의 따뜻한 UX를 제공합니다:
/// - 시간대별 맞춤 인사
/// - 연속 기록일을 "성장의 증거"로 프레이밍
/// - 격려 메시지를 따뜻한 컨테이너로 표시
class EmotionalGreetingWidget extends StatelessWidget {
  final DashboardData dashboardData;

  const EmotionalGreetingWidget({
    super.key,
    required this.dashboardData,
  });

  /// 시간대별 따뜻한 인사 메시지 생성 (Headspace 스타일)
  String _getTimeBasedGreeting(String userName) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요, $userName님!';
    } else if (hour < 18) {
      return '좋은 오후예요, $userName님!';
    } else {
      return '좋은 저녁이에요, $userName님!';
    }
  }

  /// 연속 기록일에 의미를 부여하는 텍스트 생성
  String _getContinuousRecordLabel(int days) {
    if (days >= 30) {
      return '한 달간 꾸준히!';
    } else if (days >= 14) {
      return '2주째 건강한 습관!';
    } else if (days >= 7) {
      return '일주일 연속 달성!';
    }
    return '연속으로 기록 중';
  }

  /// 연속 기록일에 따른 격려 메시지 생성
  String? _getEncouragementMessage(int days, String? insightMessage) {
    // 마일스톤 달성 시 특별 메시지
    if (days >= 30) {
      return '한 달간 꾸준히 기록하고 있어요. 대단해요!';
    } else if (days >= 14) {
      return '2주 연속으로 건강한 습관을 만들어가고 있어요!';
    } else if (days >= 7) {
      return '일주일 연속으로 기록 중이에요! 멋져요!';
    }
    // 마일스톤이 아니면 insightMessage 그대로 사용
    return insightMessage;
  }

  @override
  Widget build(BuildContext context) {
    final encouragementMessage = _getEncouragementMessage(
      dashboardData.continuousRecordDays,
      dashboardData.insightMessage,
    );

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
          // 시간대별 따뜻한 인사
          Text(
            _getTimeBasedGreeting(dashboardData.userName),
            style: AppTypography.display,
          ),
          const SizedBox(height: 16),
          // 통계 Row (2 columns)
          Row(
            children: [
              Expanded(
                child: _EmotionalStatColumn(
                  label: _getContinuousRecordLabel(
                    dashboardData.continuousRecordDays,
                  ),
                  value: '${dashboardData.continuousRecordDays}일째',
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EmotionalStatColumn(
                  label: '치료 여정',
                  value: '${dashboardData.currentWeek}주차',
                  valueColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // 격려 메시지 컨테이너 (존재할 경우)
          if (encouragementMessage != null) ...[
            const SizedBox(height: 16),
            _EncouragementContainer(message: encouragementMessage),
          ],
        ],
      ),
    );
  }
}

/// 감정적 의미가 담긴 통계 컬럼
class _EmotionalStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _EmotionalStatColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨: 12px Regular, textTertiary
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        // 값: 20px Semibold
        Text(
          value,
          style: AppTypography.heading2.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// 격려 메시지를 따뜻하게 감싸는 컨테이너 (Noom 스타일)
class _EncouragementContainer extends StatelessWidget {
  final String message;

  const _EncouragementContainer({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 스파클 아이콘으로 특별함 강조
          Icon(
            Icons.auto_awesome,
            size: 20,
            color: AppColors.success,
            semanticLabel: '격려 메시지',
          ),
          const SizedBox(width: 8),
          // 격려 메시지: 14px Medium, Success
          Expanded(
            child: Text(
              message,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

enum MissedDoseGuidanceType {
  completed,
  today,
  upcoming,
  missedWithin5Days,
  missedOver5Days,
}

/// Domain-only value object for missed dose guidance
/// UI concerns (colors, icons) are handled in Presentation layer
class MissedDoseGuidance {
  final int daysOverdue;
  final bool canAdminister;
  final String title;
  final String description;
  final MissedDoseGuidanceType type;

  const MissedDoseGuidance({
    required this.daysOverdue,
    required this.canAdminister,
    required this.title,
    required this.description,
    required this.type,
  });

  factory MissedDoseGuidance.fromSchedule({
    required DoseSchedule schedule,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return const MissedDoseGuidance(
        daysOverdue: 0,
        canAdminister: false,
        title: '완료됨',
        description: '',
        type: MissedDoseGuidanceType.completed,
      );
    }

    final daysOverdue = -schedule.daysUntil();

    if (daysOverdue <= 0) {
      // 예정일 또는 미래
      if (daysOverdue == 0) {
        return const MissedDoseGuidance(
          daysOverdue: 0,
          canAdminister: true,
          title: '오늘',
          description: '오늘 투여 예정입니다',
          type: MissedDoseGuidanceType.today,
        );
      } else {
        return MissedDoseGuidance(
          daysOverdue: 0,
          canAdminister: true,
          title: '예정',
          description: '${-daysOverdue}일 후 예정',
          type: MissedDoseGuidanceType.upcoming,
        );
      }
    } else if (daysOverdue <= 5) {
      // 1-5일 연체: 즉시 투여 권장
      return MissedDoseGuidance(
        daysOverdue: daysOverdue,
        canAdminister: true,
        title: '$daysOverdue일 연체',
        description: '⚠️ 즉시 투여를 권장합니다',
        type: MissedDoseGuidanceType.missedWithin5Days,
      );
    } else {
      // 6일 이상 연체: 대기 안내
      return MissedDoseGuidance(
        daysOverdue: daysOverdue,
        canAdminister: false,
        title: '$daysOverdue일 연체',
        description: '🚫 다음 예정일을 기다려주세요\n(5일 이상 경과 시 투여 보류)',
        type: MissedDoseGuidanceType.missedOver5Days,
      );
    }
  }
}

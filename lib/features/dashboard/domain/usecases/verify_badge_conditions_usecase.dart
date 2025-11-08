import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';

class VerifyBadgeConditionsUseCase {
  /// 각 뱃지의 획득 조건을 검증하고 진행도를 계산합니다.
  List<UserBadge> execute({
    required List<UserBadge> currentBadges,
    required int continuousRecordDays,
    required double weightLossPercentage,
    required bool hasFirstDose,
    required List<DoseRecord> allDoseRecords,
  }) {
    final now = DateTime.now();
    final updatedBadges = <UserBadge>[];

    for (final badge in currentBadges) {
      var updatedBadge = badge;

      // 연속 7일 기록
      if (badge.badgeId == 'streak_7') {
        final progress = ((continuousRecordDays / 7) * 100).toInt().clamp(0, 100);
        updatedBadge = badge.copyWith(
          progressPercentage: progress,
          status: continuousRecordDays >= 7 ? BadgeStatus.achieved : BadgeStatus.inProgress,
          achievedAt: continuousRecordDays >= 7 && badge.achievedAt == null ? now : badge.achievedAt,
          updatedAt: now,
        );
      }

      // 연속 30일 기록
      if (badge.badgeId == 'streak_30') {
        final progress = ((continuousRecordDays / 30) * 100).toInt().clamp(0, 100);
        updatedBadge = badge.copyWith(
          progressPercentage: progress,
          status: continuousRecordDays >= 30 ? BadgeStatus.achieved : BadgeStatus.inProgress,
          achievedAt: continuousRecordDays >= 30 && badge.achievedAt == null ? now : badge.achievedAt,
          updatedAt: now,
        );
      }

      // 체중 5% 감량
      if (badge.badgeId == 'weight_5percent') {
        final progress = ((weightLossPercentage / 5) * 100).toInt().clamp(0, 100);
        updatedBadge = badge.copyWith(
          progressPercentage: progress,
          status: weightLossPercentage >= 5.0 ? BadgeStatus.achieved : BadgeStatus.inProgress,
          achievedAt: weightLossPercentage >= 5.0 && badge.achievedAt == null ? now : badge.achievedAt,
          updatedAt: now,
        );
      }

      // 체중 10% 감량
      if (badge.badgeId == 'weight_10percent') {
        final progress = ((weightLossPercentage / 10) * 100).toInt().clamp(0, 100);
        updatedBadge = badge.copyWith(
          progressPercentage: progress,
          status: weightLossPercentage >= 10.0 ? BadgeStatus.achieved : BadgeStatus.inProgress,
          achievedAt: weightLossPercentage >= 10.0 && badge.achievedAt == null ? now : badge.achievedAt,
          updatedAt: now,
        );
      }

      // 첫 투여 완료
      if (badge.badgeId == 'first_dose') {
        updatedBadge = badge.copyWith(
          progressPercentage: hasFirstDose ? 100 : 0,
          status: hasFirstDose ? BadgeStatus.achieved : BadgeStatus.locked,
          achievedAt: hasFirstDose && badge.achievedAt == null ? now : badge.achievedAt,
          updatedAt: now,
        );
      }

      updatedBadges.add(updatedBadge);
    }

    return updatedBadges;
  }
}

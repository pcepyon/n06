import 'package:n06/core/constants/badge_constants.dart';
import 'package:n06/core/constants/weight_constants.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';

class VerifyBadgeConditionsUseCase {
  /// 각 뱃지의 획득 조건을 검증하고 진행도를 계산합니다.
  ///
  /// SSOT: BadgeConstants, WeightConstants 사용
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

      // 연속 기록 뱃지 (7일, 30일)
      for (final targetDays in BadgeConstants.streakBadgeDays) {
        if (badge.badgeId == BadgeConstants.streakBadgeId(targetDays)) {
          final progress = BadgeConstants.calculateStreakProgress(
              continuousRecordDays, targetDays);
          final isAchieved = BadgeConstants.isStreakBadgeConditionMet(
              continuousRecordDays, targetDays);
          updatedBadge = badge.copyWith(
            progressPercentage: progress,
            status: isAchieved ? BadgeStatus.achieved : BadgeStatus.inProgress,
            achievedAt:
                isAchieved && badge.achievedAt == null ? now : badge.achievedAt,
            updatedAt: now,
          );
        }
      }

      // 체중 감량 뱃지 (5%, 10%)
      for (final targetPercent in WeightConstants.weightLossMilestonePercents) {
        if (badge.badgeId == BadgeConstants.weightLossBadgeId(targetPercent)) {
          final progress = BadgeConstants.calculateWeightLossProgress(
              weightLossPercentage, targetPercent);
          final isAchieved = BadgeConstants.isWeightLossBadgeConditionMet(
              weightLossPercentage, targetPercent);
          updatedBadge = badge.copyWith(
            progressPercentage: progress,
            status: isAchieved ? BadgeStatus.achieved : BadgeStatus.inProgress,
            achievedAt:
                isAchieved && badge.achievedAt == null ? now : badge.achievedAt,
            updatedAt: now,
          );
        }
      }

      // 첫 투여 완료
      if (badge.badgeId == 'first_dose') {
        updatedBadge = badge.copyWith(
          progressPercentage: hasFirstDose ? 100 : 0,
          status: hasFirstDose ? BadgeStatus.achieved : BadgeStatus.locked,
          achievedAt:
              hasFirstDose && badge.achievedAt == null ? now : badge.achievedAt,
          updatedAt: now,
        );
      }

      updatedBadges.add(updatedBadge);
    }

    return updatedBadges;
  }
}

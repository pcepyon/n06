import 'package:n06/core/constants/badge_constants.dart';
import 'package:n06/features/dashboard/domain/entities/user_badge.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';

class VerifyBadgeConditionsUseCase {
  /// 각 뱃지의 획득 조건을 검증하고 진행도를 계산합니다.
  ///
  /// SSOT: BadgeConstants 사용
  ///
  /// weightProgressPercentage: (시작체중 - 현재체중) / (시작체중 - 목표체중) * 100
  List<UserBadge> execute({
    required List<UserBadge> currentBadges,
    required int continuousRecordDays,
    required double weightProgressPercentage,
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

      // 목표 체중 진행률 뱃지 (25%, 50%, 75%, 100%)
      for (final targetPercent in BadgeConstants.weightProgressBadgePercents) {
        if (badge.badgeId == BadgeConstants.weightProgressBadgeId(targetPercent)) {
          final progress = BadgeConstants.calculateWeightProgressProgress(
              weightProgressPercentage, targetPercent);
          final isAchieved = BadgeConstants.isWeightProgressBadgeConditionMet(
              weightProgressPercentage, targetPercent);
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
      if (badge.badgeId == BadgeConstants.firstDoseBadgeId) {
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

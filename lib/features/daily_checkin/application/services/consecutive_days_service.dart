import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/daily_checkin/domain/entities/milestone_type.dart';
import 'package:n06/features/daily_checkin/domain/entities/encouragement_message_type.dart';

/// Milestone information
class MilestoneInfo {
  /// Consecutive days count
  final int days;

  /// Milestone type
  final MilestoneType type;

  /// Milestone level (3, 7, 14, 21, 30, 60, 90)
  final int milestone;

  /// Whether this is a special milestone (30+ days)
  final bool isSpecial;

  const MilestoneInfo({
    required this.days,
    required this.type,
    required this.milestone,
    required this.isSpecial,
  });
}

/// Encouragement message information
class EncouragementMessage {
  /// Message type
  final EncouragementMessageType type;

  /// Consecutive days count
  final int days;

  /// Next milestone (if almostMilestone type)
  final int? nextMilestone;

  /// Days remaining until next milestone (if almostMilestone type)
  final int? daysRemaining;

  const EncouragementMessage({
    required this.type,
    required this.days,
    this.nextMilestone,
    this.daysRemaining,
  });
}

/// 연속 체크인 서비스
///
/// 연속 체크인 일수를 계산하고 마일스톤 달성 시 축하 메시지를 생성합니다.
/// 마일스톤: 3, 7, 14, 21, 30, 60, 90일
class ConsecutiveDaysService {
  final DailyCheckinRepository _repository;

  ConsecutiveDaysService({
    required DailyCheckinRepository repository,
  }) : _repository = repository;

  /// 연속 체크인 일수 조회
  Future<int> getConsecutiveDays(String userId) async {
    return await _repository.getConsecutiveDays(userId);
  }

  /// 마일스톤 달성 여부 확인 및 정보 반환
  ///
  /// 마일스톤에 도달한 경우 MilestoneInfo 반환, 아니면 null
  Future<MilestoneInfo?> checkMilestone(String userId) async {
    final days = await getConsecutiveDays(userId);
    return getMilestoneInfo(days);
  }

  /// Get milestone information for specific day count
  ///
  /// Returns MilestoneInfo if the day count is a milestone, otherwise null
  MilestoneInfo? getMilestoneInfo(int days) {
    final milestoneType = days.toMilestoneType();
    if (milestoneType == null) {
      return null;
    }

    final isSpecial = days >= 30;

    return MilestoneInfo(
      days: days,
      type: milestoneType,
      milestone: days,
      isSpecial: isSpecial,
    );
  }

  /// 다음 마일스톤까지 남은 일수
  int getDaysUntilNextMilestone(int currentDays) {
    for (final milestone in _milestones) {
      if (milestone > currentDays) {
        return milestone - currentDays;
      }
    }
    return 0; // 모든 마일스톤 달성
  }

  /// 다음 마일스톤 일수
  int? getNextMilestone(int currentDays) {
    for (final milestone in _milestones) {
      if (milestone > currentDays) {
        return milestone;
      }
    }
    return null; // 모든 마일스톤 달성
  }

  /// Generate encouragement message for consecutive check-ins
  ///
  /// Returns encouragement message type even for non-milestone days
  EncouragementMessage getEncouragementMessage(int days) {
    if (days == 1) {
      return EncouragementMessage(
        type: EncouragementMessageType.firstDay,
        days: days,
      );
    }
    if (days == 2) {
      return EncouragementMessage(
        type: EncouragementMessageType.secondDay,
        days: days,
      );
    }

    final nextMilestone = getNextMilestone(days);
    if (nextMilestone != null) {
      final remaining = nextMilestone - days;
      if (remaining <= 2) {
        return EncouragementMessage(
          type: EncouragementMessageType.almostMilestone,
          days: days,
          nextMilestone: nextMilestone,
          daysRemaining: remaining,
        );
      }
    }

    return EncouragementMessage(
      type: EncouragementMessageType.generic,
      days: days,
    );
  }

  // Milestone list (sorted)
  static const List<int> _milestones = [3, 7, 14, 21, 30, 60, 90];
}

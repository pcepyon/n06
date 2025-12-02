import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';

/// 마일스톤 정보
class MilestoneInfo {
  /// 연속 일수
  final int days;

  /// 축하 메시지
  final String message;

  /// 마일스톤 레벨 (3, 7, 14, 21, 30, 60, 90)
  final int milestone;

  /// 특별 마일스톤 여부 (30일 이상)
  final bool isSpecial;

  const MilestoneInfo({
    required this.days,
    required this.message,
    required this.milestone,
    required this.isSpecial,
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

  /// 특정 일수에 대한 마일스톤 정보 반환
  ///
  /// 해당 일수가 마일스톤에 해당하면 정보 반환, 아니면 null
  MilestoneInfo? getMilestoneInfo(int days) {
    if (!_milestones.contains(days)) {
      return null;
    }

    final message = _milestoneMessages[days] ?? '축하해요! $days일째 함께하고 있어요!';
    final isSpecial = days >= 30;

    return MilestoneInfo(
      days: days,
      message: message,
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

  /// 연속 기록 격려 메시지 생성
  ///
  /// 마일스톤이 아니더라도 연속 기록에 대한 격려 메시지 제공
  String getEncouragementMessage(int days) {
    if (days == 1) {
      return '첫 체크인이에요! 앞으로도 함께해요 💚';
    }
    if (days == 2) {
      return '이틀째 함께하고 있어요! 내일도 만나요';
    }

    final nextMilestone = getNextMilestone(days);
    if (nextMilestone != null) {
      final remaining = nextMilestone - days;
      if (remaining <= 2) {
        return '$days일째 기록 중! $nextMilestone일 달성까지 $remaining일 남았어요';
      }
    }

    return '$days일째 함께하고 있어요!';
  }

  // 마일스톤 목록 (정렬됨)
  static const List<int> _milestones = [3, 7, 14, 21, 30, 60, 90];

  // 마일스톤별 축하 메시지
  static const Map<int, String> _milestoneMessages = {
    3: '벌써 3일째 함께하고 있어요! ⭐',
    7: '일주일 완주! 대단해요 🎉',
    14: '2주 동안 꾸준히 기록하셨네요! 👏',
    21: '3주! 이제 습관이 되셨을 거예요 ✨',
    30: '한 달 완주! 정말 대단해요 🏆',
    60: '두 달 완주! 놀라운 끈기예요 🌟',
    90: '3개월 완주! 당신은 정말 대단해요 🎖️',
  };
}

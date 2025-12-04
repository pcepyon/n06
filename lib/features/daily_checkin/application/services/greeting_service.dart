import 'package:n06/features/daily_checkin/domain/entities/greeting_message_type.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';

/// 컨텍스트 인사 정보
class GreetingContext {
  /// 인사말 메시지 타입
  final GreetingMessageType messageType;

  /// 인사 타입
  final GreetingType type;

  /// 주사 다음날 여부
  final bool isPostInjection;

  /// 마지막 체크인 이후 일수
  final int daysSinceLastCheckin;

  const GreetingContext({
    required this.messageType,
    required this.type,
    required this.isPostInjection,
    required this.daysSinceLastCheckin,
  });
}

/// 인사 타입
enum GreetingType {
  /// 시간대별 기본 인사
  timeOfDay,

  /// 주사 다음날 인사
  postInjection,

  /// 복귀 사용자 인사 (3일+ 공백)
  returning,
}

/// 컨텍스트 인사 서비스
///
/// 체크인 시작 시 사용자 컨텍스트에 맞는 인사말을 생성합니다.
/// 우선순위: 복귀 > 주사 다음날 > 시간대
class GreetingService {
  final DailyCheckinRepository _checkinRepository;
  final MedicationRepository _medicationRepository;

  GreetingService({
    required DailyCheckinRepository checkinRepository,
    required MedicationRepository medicationRepository,
  })  : _checkinRepository = checkinRepository,
        _medicationRepository = medicationRepository;

  /// 컨텍스트 인사 정보 생성
  Future<GreetingContext> getGreeting(String userId) async {
    // 1. 마지막 체크인 이후 일수 확인
    final daysSinceLastCheckin = await _getDaysSinceLastCheckin(userId);

    // 2. 복귀 사용자 확인 (3일+ 공백)
    if (daysSinceLastCheckin >= 3) {
      return GreetingContext(
        messageType: _getReturningMessageType(daysSinceLastCheckin),
        type: GreetingType.returning,
        isPostInjection: false,
        daysSinceLastCheckin: daysSinceLastCheckin,
      );
    }

    // 3. 주사 다음날 확인
    final isPostInjection = await _isPostInjectionDay(userId);
    if (isPostInjection) {
      return GreetingContext(
        messageType: GreetingMessageType.postInjection,
        type: GreetingType.postInjection,
        isPostInjection: true,
        daysSinceLastCheckin: daysSinceLastCheckin,
      );
    }

    // 4. 시간대별 인사
    final timeOfDayMessageType = _getTimeOfDayMessageType();
    return GreetingContext(
      messageType: timeOfDayMessageType,
      type: GreetingType.timeOfDay,
      isPostInjection: false,
      daysSinceLastCheckin: daysSinceLastCheckin,
    );
  }

  /// 마지막 체크인 이후 일수 계산
  Future<int> _getDaysSinceLastCheckin(String userId) async {
    final latestCheckin = await _checkinRepository.getLatest(userId);

    if (latestCheckin == null) {
      return 999; // 첫 체크인
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkinDate = DateTime(
      latestCheckin.checkinDate.year,
      latestCheckin.checkinDate.month,
      latestCheckin.checkinDate.day,
    );

    return todayDate.difference(checkinDate).inDays;
  }

  /// 주사 다음날 여부 확인
  Future<bool> _isPostInjectionDay(String userId) async {
    try {
      final plan = await _medicationRepository.getActiveDosagePlan(userId);
      if (plan == null) return false;

      final records = await _medicationRepository.getDoseRecords(plan.id);
      if (records.isEmpty) return false;

      // 가장 최근 투여 기록 확인
      final latestRecord = records.reduce(
        (a, b) => a.administeredAt.isAfter(b.administeredAt) ? a : b,
      );

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterday = todayDate.subtract(const Duration(days: 1));

      final doseDate = DateTime(
        latestRecord.administeredAt.year,
        latestRecord.administeredAt.month,
        latestRecord.administeredAt.day,
      );

      return doseDate == yesterday;
    } catch (e) {
      return false;
    }
  }

  /// 복귀 사용자 인사말 타입
  GreetingMessageType _getReturningMessageType(int daysSinceLastCheckin) {
    if (daysSinceLastCheckin >= 7) {
      return GreetingMessageType.returningLongGap;
    }
    return GreetingMessageType.returningShortGap;
  }

  /// 시간대별 인사말 타입
  GreetingMessageType _getTimeOfDayMessageType() {
    final hour = DateTime.now().hour;
    final randomIndex = DateTime.now().millisecond % 3;

    if (hour >= 5 && hour < 11) {
      return _morningMessageTypes[randomIndex];
    }
    if (hour >= 11 && hour < 17) {
      return _afternoonMessageTypes[randomIndex];
    }
    if (hour >= 17 && hour < 21) {
      return _eveningMessageTypes[randomIndex];
    }
    return _nightMessageTypes[randomIndex];
  }

  /// 시간대별 그리팅 타입 반환 (외부 접근용)
  static String getTimeOfDayType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  // 시간대별 인사말 타입 풀
  static const List<GreetingMessageType> _morningMessageTypes = [
    GreetingMessageType.morningOne,
    GreetingMessageType.morningTwo,
    GreetingMessageType.morningThree,
  ];

  static const List<GreetingMessageType> _afternoonMessageTypes = [
    GreetingMessageType.afternoonOne,
    GreetingMessageType.afternoonTwo,
    GreetingMessageType.afternoonThree,
  ];

  static const List<GreetingMessageType> _eveningMessageTypes = [
    GreetingMessageType.eveningOne,
    GreetingMessageType.eveningTwo,
    GreetingMessageType.eveningThree,
  ];

  static const List<GreetingMessageType> _nightMessageTypes = [
    GreetingMessageType.nightOne,
    GreetingMessageType.nightTwo,
    GreetingMessageType.nightThree,
  ];
}

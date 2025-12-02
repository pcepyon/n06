import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';

/// 컨텍스트 인사 정보
class GreetingContext {
  /// 인사말 메시지
  final String message;

  /// 인사 타입
  final GreetingType type;

  /// 주사 다음날 여부
  final bool isPostInjection;

  /// 마지막 체크인 이후 일수
  final int daysSinceLastCheckin;

  const GreetingContext({
    required this.message,
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
        message: _getReturningMessage(daysSinceLastCheckin),
        type: GreetingType.returning,
        isPostInjection: false,
        daysSinceLastCheckin: daysSinceLastCheckin,
      );
    }

    // 3. 주사 다음날 확인
    final isPostInjection = await _isPostInjectionDay(userId);
    if (isPostInjection) {
      return GreetingContext(
        message: _postInjectionMessage,
        type: GreetingType.postInjection,
        isPostInjection: true,
        daysSinceLastCheckin: daysSinceLastCheckin,
      );
    }

    // 4. 시간대별 인사
    final timeOfDayMessage = _getTimeOfDayMessage();
    return GreetingContext(
      message: timeOfDayMessage,
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

  /// 복귀 사용자 인사말
  String _getReturningMessage(int daysSinceLastCheckin) {
    if (daysSinceLastCheckin >= 7) {
      return '다시 만나서 반가워요 😊\n'
          '쉬어가는 것도 여정의 일부예요.\n'
          '오늘부터 다시 함께해요!';
    }
    return '다시 만나서 반가워요 😊\n'
        '오늘부터 다시 함께해요!';
  }

  /// 주사 다음날 인사말
  static const String _postInjectionMessage =
      '어제 주사 맞으셨죠?\n오늘 컨디션은 어떠세요? 💉';

  /// 시간대별 인사말
  String _getTimeOfDayMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return _morningMessages[DateTime.now().millisecond % _morningMessages.length];
    }
    if (hour >= 11 && hour < 17) {
      return _afternoonMessages[DateTime.now().millisecond % _afternoonMessages.length];
    }
    if (hour >= 17 && hour < 21) {
      return _eveningMessages[DateTime.now().millisecond % _eveningMessages.length];
    }
    return _nightMessages[DateTime.now().millisecond % _nightMessages.length];
  }

  /// 시간대별 그리팅 타입 반환 (외부 접근용)
  static String getTimeOfDayType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  // 시간대별 인사말 풀
  static const List<String> _morningMessages = [
    '좋은 아침이에요 ☀️',
    '오늘 하루도 화이팅! ☀️',
    '좋은 아침이에요! 오늘도 함께해요 ☀️',
  ];

  static const List<String> _afternoonMessages = [
    '오늘 하루 어떠세요?',
    '오후에도 잘 보내고 계신가요?',
    '점심은 드셨나요?',
  ];

  static const List<String> _eveningMessages = [
    '오늘 하루 수고하셨어요 🌙',
    '저녁이에요! 오늘 하루는 어떠셨어요?',
    '하루를 마무리하며 체크인해요 🌙',
  ];

  static const List<String> _nightMessages = [
    '늦은 시간까지 수고 많으셨어요',
    '오늘도 수고하셨어요 🌃',
    '하루를 마무리하고 계시군요',
  ];
}

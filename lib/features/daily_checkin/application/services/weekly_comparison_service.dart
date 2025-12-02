import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

/// 주간 비교 결과
class WeeklyComparison {
  /// 이번 주 체크인 수
  final int thisWeekCheckins;

  /// 지난주 체크인 수
  final int lastWeekCheckins;

  /// 메스꺼움 감소 여부
  final bool nauseaDecreased;

  /// 식욕 개선 여부
  final bool appetiteImproved;

  /// 에너지 개선 여부
  final bool energyImproved;

  /// 체중 변화 (kg, 음수면 감소)
  final double? weightChange;

  /// 개선된 항목 목록
  final List<ImprovementFeedback> improvements;

  const WeeklyComparison({
    required this.thisWeekCheckins,
    required this.lastWeekCheckins,
    required this.nauseaDecreased,
    required this.appetiteImproved,
    required this.energyImproved,
    this.weightChange,
    required this.improvements,
  });

  /// 개선된 항목이 있는지
  bool get hasImprovements => improvements.isNotEmpty;
}

/// 개선 피드백
class ImprovementFeedback {
  /// 개선 항목 타입
  final ImprovementType type;

  /// 피드백 메시지
  final String message;

  const ImprovementFeedback({
    required this.type,
    required this.message,
  });
}

/// 개선 항목 타입
enum ImprovementType {
  nauseaDecreased,
  appetiteImproved,
  energyImproved,
  weightProgress,
  checkinStreak,
}

/// 주간 비교 서비스
///
/// 이번 주와 지난주 데이터를 비교하여 개선된 항목을 감지하고
/// 긍정 피드백을 생성합니다.
class WeeklyComparisonService {
  final DailyCheckinRepository _checkinRepository;
  final TrackingRepository _trackingRepository;

  WeeklyComparisonService({
    required DailyCheckinRepository checkinRepository,
    required TrackingRepository trackingRepository,
  })  : _checkinRepository = checkinRepository,
        _trackingRepository = trackingRepository;

  /// 주간 비교 수행
  Future<WeeklyComparison> compare(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 이번 주 범위 (오늘 기준 최근 7일)
    final thisWeekStart = today.subtract(const Duration(days: 6));
    final thisWeekEnd = today;

    // 지난주 범위
    final lastWeekStart = today.subtract(const Duration(days: 13));
    final lastWeekEnd = today.subtract(const Duration(days: 7));

    // 체크인 데이터 조회
    final thisWeekCheckins = await _checkinRepository.getByDateRange(
      userId,
      thisWeekStart,
      thisWeekEnd,
    );

    final lastWeekCheckins = await _checkinRepository.getByDateRange(
      userId,
      lastWeekStart,
      lastWeekEnd,
    );

    // 비교 분석
    final nauseaDecreased = _checkNauseaDecreased(
      thisWeekCheckins,
      lastWeekCheckins,
    );
    final appetiteImproved = _checkAppetiteImproved(
      thisWeekCheckins,
      lastWeekCheckins,
    );
    final energyImproved = _checkEnergyImproved(
      thisWeekCheckins,
      lastWeekCheckins,
    );

    // 체중 변화 확인
    final weightChange = await _getWeightChange(
      userId,
      thisWeekStart,
      thisWeekEnd,
    );

    // 개선 피드백 수집
    final improvements = <ImprovementFeedback>[];

    if (nauseaDecreased) {
      improvements.add(const ImprovementFeedback(
        type: ImprovementType.nauseaDecreased,
        message: '지난주보다 메스꺼움이 줄었어요! 몸이 적응하고 있네요 💚',
      ));
    }

    if (appetiteImproved) {
      improvements.add(const ImprovementFeedback(
        type: ImprovementType.appetiteImproved,
        message: '식욕 조절이 잘 되고 있어요. 약이 잘 작용하는 신호예요 💚',
      ));
    }

    if (energyImproved) {
      improvements.add(const ImprovementFeedback(
        type: ImprovementType.energyImproved,
        message: '에너지가 돌아오고 있네요! ⚡',
      ));
    }

    if (weightChange != null && weightChange < 0) {
      improvements.add(ImprovementFeedback(
        type: ImprovementType.weightProgress,
        message: '꾸준히 변화하고 있어요! (${weightChange.abs().toStringAsFixed(1)}kg)',
      ));
    }

    if (thisWeekCheckins.length > lastWeekCheckins.length) {
      improvements.add(const ImprovementFeedback(
        type: ImprovementType.checkinStreak,
        message: '지난주보다 더 자주 기록하고 계시네요! 👏',
      ));
    }

    return WeeklyComparison(
      thisWeekCheckins: thisWeekCheckins.length,
      lastWeekCheckins: lastWeekCheckins.length,
      nauseaDecreased: nauseaDecreased,
      appetiteImproved: appetiteImproved,
      energyImproved: energyImproved,
      weightChange: weightChange,
      improvements: improvements,
    );
  }

  /// 메스꺼움 감소 확인
  bool _checkNauseaDecreased(
    List<DailyCheckin> thisWeek,
    List<DailyCheckin> lastWeek,
  ) {
    if (lastWeek.isEmpty) return false;

    final thisWeekNauseaCount = _countNauseaSymptoms(thisWeek);
    final lastWeekNauseaCount = _countNauseaSymptoms(lastWeek);

    // 지난주에 증상이 있었고, 이번 주에 감소했을 때
    return lastWeekNauseaCount > 0 && thisWeekNauseaCount < lastWeekNauseaCount;
  }

  /// 메스꺼움 증상 횟수 카운트
  int _countNauseaSymptoms(List<DailyCheckin> checkins) {
    return checkins.where((c) {
      if (c.symptomDetails == null) return false;
      return c.symptomDetails!.any(
        (s) => s.type == SymptomType.nausea || s.type == SymptomType.vomiting,
      );
    }).length;
  }

  /// 식욕 개선 확인
  bool _checkAppetiteImproved(
    List<DailyCheckin> thisWeek,
    List<DailyCheckin> lastWeek,
  ) {
    if (lastWeek.isEmpty || thisWeek.isEmpty) return false;

    final thisWeekAvg = _calculateAverageAppetite(thisWeek);
    final lastWeekAvg = _calculateAverageAppetite(lastWeek);

    // 평균 식욕 점수가 0.5점 이상 개선되었을 때
    return thisWeekAvg - lastWeekAvg >= 0.5;
  }

  /// 평균 식욕 점수 계산
  double _calculateAverageAppetite(List<DailyCheckin> checkins) {
    final scoresWithValue = checkins
        .where((c) => c.appetiteScore != null)
        .map((c) => c.appetiteScore!)
        .toList();

    if (scoresWithValue.isEmpty) return 3.0; // 기본값

    return scoresWithValue.reduce((a, b) => a + b) / scoresWithValue.length;
  }

  /// 에너지 개선 확인
  bool _checkEnergyImproved(
    List<DailyCheckin> thisWeek,
    List<DailyCheckin> lastWeek,
  ) {
    if (lastWeek.isEmpty || thisWeek.isEmpty) return false;

    final thisWeekGoodEnergy = thisWeek.where(
      (c) => c.energyLevel == EnergyLevel.good,
    ).length;

    final lastWeekGoodEnergy = lastWeek.where(
      (c) => c.energyLevel == EnergyLevel.good,
    ).length;

    // 이번 주 "활기 있었어요" 비율이 높아졌을 때
    final thisWeekRatio = thisWeekGoodEnergy / thisWeek.length;
    final lastWeekRatio = lastWeekGoodEnergy / lastWeek.length;

    return thisWeekRatio > lastWeekRatio && thisWeekGoodEnergy > 0;
  }

  /// 체중 변화 확인
  Future<double?> _getWeightChange(
    String userId,
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    try {
      final weightLogs = await _trackingRepository.getWeightLogs(
        userId,
        startDate: weekStart,
        endDate: weekEnd.add(const Duration(days: 1)),
      );

      if (weightLogs.length < 2) return null;

      // 가장 오래된 기록과 최신 기록 비교
      weightLogs.sort((a, b) => a.logDate.compareTo(b.logDate));
      final oldest = weightLogs.first;
      final newest = weightLogs.last;

      return newest.weightKg - oldest.weightKg;
    } catch (e) {
      return null;
    }
  }

  /// 종합 피드백 메시지 생성
  String generateFeedbackMessage(WeeklyComparison comparison) {
    if (!comparison.hasImprovements) {
      return '꾸준히 기록하고 계시네요! 💚';
    }

    // 가장 중요한 개선 사항 1-2개만 보여줌
    final topImprovements = comparison.improvements.take(2).toList();
    return topImprovements.map((i) => i.message).join('\n');
  }
}

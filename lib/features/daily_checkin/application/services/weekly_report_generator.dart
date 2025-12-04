import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/weekly_report.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/report_section_type.dart';
import 'package:n06/features/daily_checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';

/// 주간 리포트 생성 서비스
///
/// 의료진과 공유할 수 있는 구조화된 주간 리포트를 생성합니다.
class WeeklyReportGenerator {
  final DailyCheckinRepository _checkinRepository;
  final TrackingRepository _trackingRepository;
  final MedicationRepository _medicationRepository;

  WeeklyReportGenerator({
    required DailyCheckinRepository checkinRepository,
    required TrackingRepository trackingRepository,
    required MedicationRepository medicationRepository,
  })  : _checkinRepository = checkinRepository,
        _trackingRepository = trackingRepository,
        _medicationRepository = medicationRepository;

  /// 주간 리포트 생성
  ///
  /// [userId] 사용자 ID
  /// [weekOffset] 몇 주 전 (0: 이번 주, 1: 지난주, ...)
  /// [user] 사용자 정보 (이름 표시용)
  Future<WeeklyReport> generate({
    required String userId,
    int weekOffset = 0,
    User? user,
  }) async {
    // 기간 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 주간 범위 계산 (월요일 ~ 일요일)
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final periodStart = currentWeekStart.subtract(Duration(days: 7 * weekOffset));
    final periodEnd = periodStart.add(const Duration(days: 6));

    // 데이터 조회
    final checkins = await _checkinRepository.getByDateRange(
      userId,
      periodStart,
      periodEnd,
    );

    final weightLogs = await _trackingRepository.getWeightLogs(
      userId,
      startDate: periodStart,
      endDate: periodEnd.add(const Duration(days: 1)),
    );

    // 약제 정보 조회
    String? medicationName;
    try {
      final plan = await _medicationRepository.getActiveDosagePlan(userId);
      if (plan != null) {
        final currentDose = plan.getCurrentDose(weeksElapsed: plan.getWeeksElapsed());
        medicationName = '${plan.medicationName} ${currentDose}mg';
      }
    } catch (e) {
      // 약제 정보 없어도 계속 진행
    }

    // 각 항목 계산
    final weightSummary = _calculateWeightSummary(weightLogs);
    final appetiteSummary = _calculateAppetiteSummary(checkins);
    final checkinAchievement = _calculateCheckinAchievement(
      checkins,
      periodStart,
      periodEnd,
    );
    final symptomOccurrences = _calculateSymptomOccurrences(checkins);
    final redFlagRecords = _extractRedFlagRecords(checkins);
    final dailyConditions = _generateDailyConditions(
      checkins,
      periodStart,
      periodEnd,
    );

    return WeeklyReport(
      userId: userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      userName: user?.name,
      medicationName: medicationName,
      weightSummary: weightSummary,
      appetiteSummary: appetiteSummary,
      checkinAchievement: checkinAchievement,
      symptomOccurrences: symptomOccurrences,
      redFlagRecords: redFlagRecords,
      dailyConditions: dailyConditions,
      generatedAt: DateTime.now(),
    );
  }

  /// 체중 요약 계산
  WeightSummary? _calculateWeightSummary(List<WeightLog> weightLogs) {
    if (weightLogs.length < 2) return null;

    // 날짜순 정렬
    final sortedLogs = List<WeightLog>.from(weightLogs)
      ..sort((a, b) => a.logDate.compareTo(b.logDate));

    final startWeight = sortedLogs.first.weightKg;
    final endWeight = sortedLogs.last.weightKg;
    final change = endWeight - startWeight;

    return WeightSummary(
      startWeight: startWeight,
      endWeight: endWeight,
      change: change,
    );
  }

  /// 식욕 요약 계산
  AppetiteSummary _calculateAppetiteSummary(List<DailyCheckin> checkins) {
    final scores = checkins
        .where((c) => c.appetiteScore != null)
        .map((c) => c.appetiteScore!)
        .toList();

    if (scores.isEmpty) {
      return const AppetiteSummary(
        averageScore: 3.0,
        stability: AppetiteStability.stable,
      );
    }

    final average = scores.reduce((a, b) => a + b) / scores.length;

    // 안정도 계산 (표준편차 기반)
    AppetiteStability stability;
    if (scores.length < 3) {
      stability = AppetiteStability.stable;
    } else {
      final firstHalf = scores.take(scores.length ~/ 2).toList();
      final secondHalf = scores.skip(scores.length ~/ 2).toList();

      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg - firstAvg > 0.5) {
        stability = AppetiteStability.improving;
      } else if (firstAvg - secondAvg > 0.5) {
        stability = AppetiteStability.declining;
      } else {
        stability = AppetiteStability.stable;
      }
    }

    return AppetiteSummary(
      averageScore: double.parse(average.toStringAsFixed(1)),
      stability: stability,
    );
  }

  /// 체크인 달성률 계산
  CheckinAchievement _calculateCheckinAchievement(
    List<DailyCheckin> checkins,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    // 기간 내 일수 계산 (오늘까지만)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime effectiveEnd = periodEnd;
    if (periodEnd.isAfter(today)) {
      effectiveEnd = today;
    }

    final totalDays = effectiveEnd.difference(periodStart).inDays + 1;
    final checkinDays = checkins.length;
    final percentage = totalDays > 0
        ? ((checkinDays / totalDays) * 100).round()
        : 0;

    return CheckinAchievement(
      checkinDays: checkinDays,
      totalDays: totalDays,
      percentage: percentage,
    );
  }

  /// 증상 발생 현황 계산
  List<SymptomOccurrence> _calculateSymptomOccurrences(
    List<DailyCheckin> checkins,
  ) {
    final symptomMap = <SymptomType, Map<String, int>>{};

    for (final checkin in checkins) {
      if (checkin.symptomDetails == null) continue;

      for (final symptom in checkin.symptomDetails!) {
        symptomMap.putIfAbsent(symptom.type, () => {
          'count': 0,
          'mild': 0,
          'moderate': 0,
          'severe': 0,
        });

        symptomMap[symptom.type]!['count'] =
            (symptomMap[symptom.type]!['count'] ?? 0) + 1;

        final severityKey = symptom.severity == 1
            ? 'mild'
            : symptom.severity == 2
                ? 'moderate'
                : 'severe';
        symptomMap[symptom.type]![severityKey] =
            (symptomMap[symptom.type]![severityKey] ?? 0) + 1;
      }
    }

    return symptomMap.entries.map((entry) {
      return SymptomOccurrence(
        type: entry.key, // Use enum directly
        daysOccurred: entry.value['count'] ?? 0,
        severityCounts: {
          'mild': entry.value['mild'] ?? 0,
          'moderate': entry.value['moderate'] ?? 0,
          'severe': entry.value['severe'] ?? 0,
        },
      );
    }).toList()
      ..sort((a, b) => b.daysOccurred.compareTo(a.daysOccurred));
  }

  /// Red Flag 기록 추출
  List<RedFlagRecord> _extractRedFlagRecords(List<DailyCheckin> checkins) {
    return checkins
        .where((c) => c.redFlagDetected != null)
        .map((c) {
          return RedFlagRecord(
            date: c.checkinDate,
            type: c.redFlagDetected!.type, // Use enum directly
            symptoms: c.redFlagDetected!.symptoms, // Use data directly
            userAction: c.redFlagDetected!.userAction,
          );
        })
        .toList();
  }

  /// 일별 컨디션 생성
  List<DailyCondition> _generateDailyConditions(
    List<DailyCheckin> checkins,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final checkinMap = <String, DailyCheckin>{};
    for (final checkin in checkins) {
      final key = '${checkin.checkinDate.year}-${checkin.checkinDate.month}-${checkin.checkinDate.day}';
      checkinMap[key] = checkin;
    }

    final conditions = <DailyCondition>[];

    var current = periodStart;
    while (!current.isAfter(periodEnd)) {
      final key = '${current.year}-${current.month}-${current.day}';
      final checkin = checkinMap[key];

      conditions.add(DailyCondition(
        date: current,
        mood: checkin?.mood, // Use enum directly, null if no checkin
        hasCheckin: checkin != null,
      ));

      current = current.add(const Duration(days: 1));
    }

    return conditions;
  }

  /// 텍스트 형식 리포트 생성
  ///
  /// DEPRECATED: 이 메서드는 Presentation Layer로 이동될 예정입니다.
  /// 하드코딩된 문자열이 포함되어 있어 i18n을 지원하지 않습니다.
  /// TODO: Presentation layer에 i18n 지원 버전 생성 후 제거
  @Deprecated('Use presentation layer text report formatter with i18n')
  String generateTextReport(WeeklyReport report) {
    throw UnimplementedError(
      'generateTextReport is deprecated. '
      'Use presentation layer formatter with i18n support instead.',
    );
  }
}

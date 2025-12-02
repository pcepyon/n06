import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/weekly_report.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
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
        stability: 'stable',
      );
    }

    final average = scores.reduce((a, b) => a + b) / scores.length;

    // 안정도 계산 (표준편차 기반)
    String stability;
    if (scores.length < 3) {
      stability = 'stable';
    } else {
      final firstHalf = scores.take(scores.length ~/ 2).toList();
      final secondHalf = scores.skip(scores.length ~/ 2).toList();

      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg - firstAvg > 0.5) {
        stability = 'improving';
      } else if (firstAvg - secondAvg > 0.5) {
        stability = 'declining';
      } else {
        stability = 'stable';
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
        symptomName: _symptomTypeToKorean(entry.key),
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
            type: _redFlagTypeToKorean(c.redFlagDetected!.type),
            summary: _summarizeRedFlag(c.redFlagDetected!),
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
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];

    var current = periodStart;
    while (!current.isAfter(periodEnd)) {
      final key = '${current.year}-${current.month}-${current.day}';
      final checkin = checkinMap[key];

      String emoji;
      if (checkin == null) {
        emoji = '--';
      } else {
        emoji = _moodToEmoji(checkin.mood);
      }

      conditions.add(DailyCondition(
        date: current,
        dayOfWeek: dayNames[current.weekday - 1],
        emoji: emoji,
        hasCheckin: checkin != null,
      ));

      current = current.add(const Duration(days: 1));
    }

    return conditions;
  }

  /// 텍스트 형식 리포트 생성
  String generateTextReport(WeeklyReport report) {
    final buffer = StringBuffer();

    // 헤더
    buffer.writeln('╔════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                   GLP-1 치료 주간 리포트                      ║');

    // 환자 정보 라인
    final patientInfo = [
      if (report.userName != null) '환자: ${report.userName}',
      if (report.medicationName != null) '약제: ${report.medicationName}',
      '기간: ${_formatDate(report.periodStart)}-${_formatDate(report.periodEnd)}',
    ].join(' | ');
    buffer.writeln('║  $patientInfo');

    buffer.writeln('╠════════════════════════════════════════════════════════════╣');

    // 주요 지표
    buffer.writeln('║  ▶ 주요 지표                                                ║');

    if (report.weightSummary != null) {
      final ws = report.weightSummary!;
      buffer.writeln('║    체중: ${ws.startWeight.toStringAsFixed(1)} → ${ws.endWeight.toStringAsFixed(1)}kg (${ws.changeString})');
    }

    buffer.writeln('║    식욕: 평균 ${report.appetiteSummary.averageScore}/5, ${report.appetiteSummary.stabilityKorean}');
    buffer.writeln('║    체크인: ${report.checkinAchievement.checkinDays}/${report.checkinAchievement.totalDays}일 (${report.checkinAchievement.percentage}%)');

    // 증상 발생 현황
    if (report.symptomOccurrences.isNotEmpty) {
      buffer.writeln('╠════════════════════════════════════════════════════════════╣');
      buffer.writeln('║  ▶ 증상 발생 현황                                           ║');

      for (final symptom in report.symptomOccurrences.take(5)) {
        buffer.writeln('║    ${symptom.symptomName} ${symptom.daysOccurred}일 ${symptom.severitySummary}');
      }
    }

    // Red Flag 기록
    if (report.redFlagRecords.isNotEmpty) {
      buffer.writeln('╠════════════════════════════════════════════════════════════╣');
      buffer.writeln('║  ▶ 주의 필요 기록                                           ║');

      for (final flag in report.redFlagRecords) {
        buffer.writeln('║    ${_formatDate(flag.date)}: ${flag.summary}');
      }
    }

    // 컨디션 추이
    buffer.writeln('╠════════════════════════════════════════════════════════════╣');
    buffer.writeln('║  ▶ 컨디션 추이                                              ║');

    final emojis = report.dailyConditions.map((c) => c.emoji).join('');
    buffer.writeln('║    $emojis');

    final days = report.dailyConditions.map((c) => c.dayOfWeek).join(' ');
    buffer.writeln('║    $days');

    buffer.writeln('╚════════════════════════════════════════════════════════════╝');

    return buffer.toString();
  }

  // === Helper Methods ===

  String _formatDate(DateTime date) {
    return '${date.month}.${date.day}';
  }

  String _symptomTypeToKorean(SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return '메스꺼움';
      case SymptomType.vomiting:
        return '구토';
      case SymptomType.lowAppetite:
        return '식욕 감소';
      case SymptomType.earlySatiety:
        return '조기 포만감';
      case SymptomType.heartburn:
        return '속쓰림';
      case SymptomType.abdominalPain:
        return '복통';
      case SymptomType.bloating:
        return '복부 팽만';
      case SymptomType.constipation:
        return '변비';
      case SymptomType.diarrhea:
        return '설사';
      case SymptomType.fatigue:
        return '피로';
      case SymptomType.dizziness:
        return '어지러움';
      case SymptomType.coldSweat:
        return '식은땀';
      case SymptomType.swelling:
        return '부종';
    }
  }

  String _redFlagTypeToKorean(RedFlagType type) {
    switch (type) {
      case RedFlagType.pancreatitis:
        return '췌장 확인 필요';
      case RedFlagType.cholecystitis:
        return '담낭 확인 필요';
      case RedFlagType.severeDehydration:
        return '탈수 주의';
      case RedFlagType.bowelObstruction:
        return '장 기능 확인 필요';
      case RedFlagType.hypoglycemia:
        return '저혈당 의심';
      case RedFlagType.renalImpairment:
        return '신장 기능 확인 필요';
    }
  }

  String _summarizeRedFlag(RedFlagDetection detection) {
    final symptoms = detection.symptoms.take(2).join(', ');
    return '${_redFlagTypeToKorean(detection.type)} - $symptoms';
  }

  String _moodToEmoji(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.good:
        return '😊';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.low:
        return '😔';
    }
  }
}

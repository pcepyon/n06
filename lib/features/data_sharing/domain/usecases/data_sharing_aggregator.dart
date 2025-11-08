import 'package:n06/features/data_sharing/domain/entities/shared_data_report.dart';

class DataSharingAggregator {
  /// Calculate weight change trend from report
  WeightTrend calculateWeightTrend(SharedDataReport report) {
    final sortedWeights = report.getWeightLogsSorted();

    if (sortedWeights.isEmpty) {
      return WeightTrend(
        startWeight: null,
        endWeight: null,
        change: 0,
        changePercentage: 0,
      );
    }

    final startWeight = sortedWeights.first.weightKg;
    final endWeight = sortedWeights.last.weightKg;
    final change = endWeight - startWeight;
    final changePercentage = (startWeight > 0 ? (change / startWeight) * 100 : 0).toDouble();

    return WeightTrend(
      startWeight: startWeight,
      endWeight: endWeight,
      change: change,
      changePercentage: changePercentage,
    );
  }

  /// Calculate average symptom severity from report
  double calculateAverageSeverity(SharedDataReport report) {
    if (report.symptomLogs.isEmpty) {
      return 0;
    }

    final totalSeverity = report.symptomLogs.fold<double>(
      0,
      (sum, log) => sum + log.severity,
    );

    return totalSeverity / report.symptomLogs.length;
  }

  /// Group symptoms by context tags
  Map<String, int> groupSymptomsByTag(SharedDataReport report) {
    final tagMap = <String, int>{};

    for (final log in report.symptomLogs) {
      for (final tag in log.tags) {
        tagMap[tag] = (tagMap[tag] ?? 0) + 1;
      }
    }

    return tagMap;
  }

  /// Identify dose escalation points from schedules
  List<DateTime> identifyEscalationPoints(SharedDataReport report) {
    final sortedSchedules = report.doseSchedules.toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    final escalationPoints = <DateTime>[];
    double? previousDose;

    for (final schedule in sortedSchedules) {
      if (previousDose != null && schedule.scheduledDoseMg > previousDose) {
        escalationPoints.add(schedule.scheduledDate);
      }
      previousDose = schedule.scheduledDoseMg;
    }

    return escalationPoints;
  }
}

class WeightTrend {
  final double? startWeight;
  final double? endWeight;
  final double change;
  final double changePercentage;

  WeightTrend({
    required this.startWeight,
    required this.endWeight,
    required this.change,
    required this.changePercentage,
  });

  bool get isPositive => change > 0;
  bool get isNegative => change < 0;
  bool get isNoChange => change == 0;
}

import 'package:equatable/equatable.dart';

class WeeklySummary extends Equatable {
  final int doseCompletedCount;
  final double weightChangeKg;
  final int symptomRecordCount;
  final double adherencePercentage;

  const WeeklySummary({
    required this.doseCompletedCount,
    required this.weightChangeKg,
    required this.symptomRecordCount,
    required this.adherencePercentage,
  });

  WeeklySummary copyWith({
    int? doseCompletedCount,
    double? weightChangeKg,
    int? symptomRecordCount,
    double? adherencePercentage,
  }) {
    return WeeklySummary(
      doseCompletedCount: doseCompletedCount ?? this.doseCompletedCount,
      weightChangeKg: weightChangeKg ?? this.weightChangeKg,
      symptomRecordCount: symptomRecordCount ?? this.symptomRecordCount,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
    );
  }

  @override
  List<Object?> get props => [
        doseCompletedCount,
        weightChangeKg,
        symptomRecordCount,
        adherencePercentage,
      ];

  @override
  String toString() =>
      'WeeklySummary(doseCount: $doseCompletedCount, weightChange: $weightChangeKg, symptomCount: $symptomRecordCount)';
}

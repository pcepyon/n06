import 'package:equatable/equatable.dart';

class WeeklyProgress extends Equatable {
  final int doseCompletedCount;
  final int doseTargetCount;
  final double doseRate;
  final int weightRecordCount;
  final int weightTargetCount;
  final double weightRate;
  final int symptomRecordCount;
  final int symptomTargetCount;
  final double symptomRate;

  const WeeklyProgress({
    required this.doseCompletedCount,
    required this.doseTargetCount,
    required this.doseRate,
    required this.weightRecordCount,
    required this.weightTargetCount,
    required this.weightRate,
    required this.symptomRecordCount,
    required this.symptomTargetCount,
    required this.symptomRate,
  });

  WeeklyProgress copyWith({
    int? doseCompletedCount,
    int? doseTargetCount,
    double? doseRate,
    int? weightRecordCount,
    int? weightTargetCount,
    double? weightRate,
    int? symptomRecordCount,
    int? symptomTargetCount,
    double? symptomRate,
  }) {
    return WeeklyProgress(
      doseCompletedCount: doseCompletedCount ?? this.doseCompletedCount,
      doseTargetCount: doseTargetCount ?? this.doseTargetCount,
      doseRate: doseRate ?? this.doseRate,
      weightRecordCount: weightRecordCount ?? this.weightRecordCount,
      weightTargetCount: weightTargetCount ?? this.weightTargetCount,
      weightRate: weightRate ?? this.weightRate,
      symptomRecordCount: symptomRecordCount ?? this.symptomRecordCount,
      symptomTargetCount: symptomTargetCount ?? this.symptomTargetCount,
      symptomRate: symptomRate ?? this.symptomRate,
    );
  }

  @override
  List<Object?> get props => [
        doseCompletedCount,
        doseTargetCount,
        doseRate,
        weightRecordCount,
        weightTargetCount,
        weightRate,
        symptomRecordCount,
        symptomTargetCount,
        symptomRate,
      ];

  @override
  String toString() =>
      'WeeklyProgress(doseRate: $doseRate, weightRate: $weightRate, symptomRate: $symptomRate)';
}

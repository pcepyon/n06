import 'package:equatable/equatable.dart';

class NextSchedule extends Equatable {
  final DateTime nextDoseDate;
  final double nextDoseMg;
  final DateTime? nextEscalationDate;
  final DateTime? goalEstimateDate;

  const NextSchedule({
    required this.nextDoseDate,
    required this.nextDoseMg,
    this.nextEscalationDate,
    this.goalEstimateDate,
  });

  NextSchedule copyWith({
    DateTime? nextDoseDate,
    double? nextDoseMg,
    DateTime? nextEscalationDate,
    DateTime? goalEstimateDate,
  }) {
    return NextSchedule(
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      nextDoseMg: nextDoseMg ?? this.nextDoseMg,
      nextEscalationDate: nextEscalationDate ?? this.nextEscalationDate,
      goalEstimateDate: goalEstimateDate ?? this.goalEstimateDate,
    );
  }

  @override
  List<Object?> get props =>
      [nextDoseDate, nextDoseMg, nextEscalationDate, goalEstimateDate];

  @override
  String toString() =>
      'NextSchedule(nextDoseDate: $nextDoseDate, nextDoseMg: $nextDoseMg)';
}

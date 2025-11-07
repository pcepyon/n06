import 'package:equatable/equatable.dart';

const double maxDoseMg = 2.4;

class EscalationStep extends Equatable {
  final int weeksFromStart;
  final double doseMg;

  const EscalationStep({
    required this.weeksFromStart,
    required this.doseMg,
  });

  @override
  List<Object?> get props => [weeksFromStart, doseMg];
}

class DosagePlan extends Equatable {
  final String id;
  final String userId;
  final String medicationName;
  final DateTime startDate;
  final int cycleDays;
  final double initialDoseMg;
  final List<EscalationStep>? escalationPlan;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DosagePlan({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.startDate,
    required this.cycleDays,
    required this.initialDoseMg,
    this.escalationPlan,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    _validate();
  }

  void _validate() {
    // Validate start date is not in the future
    if (startDate.isAfter(DateTime.now())) {
      throw ArgumentError('Start date cannot be in the future');
    }

    // Validate cycle days
    if (cycleDays < 1) {
      throw ArgumentError('Cycle days must be at least 1');
    }

    // Validate initial dose
    if (initialDoseMg < 0) {
      throw ArgumentError('Initial dose cannot be negative');
    }

    // Validate escalation plan
    if (escalationPlan != null && escalationPlan!.isNotEmpty) {
      _validateEscalationPlan();
    }
  }

  void _validateEscalationPlan() {
    final steps = escalationPlan!;

    // Check monotonic increase
    double previousDose = initialDoseMg;
    int previousWeeks = 0;

    for (final step in steps) {
      // Check dose is monotonic increasing
      if (step.doseMg <= previousDose) {
        throw ArgumentError('Escalation plan must have monotonic increasing doses');
      }

      // Check dose doesn't exceed max
      if (step.doseMg > maxDoseMg) {
        throw ArgumentError('Escalation dose cannot exceed ${maxDoseMg}mg');
      }

      // Check weeks are in increasing order
      if (step.weeksFromStart <= previousWeeks) {
        throw ArgumentError('Escalation steps must be in chronological order');
      }

      previousDose = step.doseMg;
      previousWeeks = step.weeksFromStart;
    }
  }

  /// Calculate current dose based on weeks elapsed since start date
  double getCurrentDose({required int weeksElapsed}) {
    if (escalationPlan == null || escalationPlan!.isEmpty) {
      return initialDoseMg;
    }

    double currentDose = initialDoseMg;

    for (final step in escalationPlan!) {
      if (weeksElapsed >= step.weeksFromStart) {
        currentDose = step.doseMg;
      } else {
        break;
      }
    }

    return currentDose;
  }

  /// Calculate weeks elapsed since plan start
  int getWeeksElapsed() {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    return (difference.inDays / 7).ceil();
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    medicationName,
    startDate,
    cycleDays,
    initialDoseMg,
    escalationPlan,
    isActive,
    createdAt,
    updatedAt,
  ];

  DosagePlan copyWith({
    String? id,
    String? userId,
    String? medicationName,
    DateTime? startDate,
    int? cycleDays,
    double? initialDoseMg,
    List<EscalationStep>? escalationPlan,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DosagePlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationName: medicationName ?? this.medicationName,
      startDate: startDate ?? this.startDate,
      cycleDays: cycleDays ?? this.cycleDays,
      initialDoseMg: initialDoseMg ?? this.initialDoseMg,
      escalationPlan: escalationPlan ?? this.escalationPlan,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

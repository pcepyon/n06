import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

/// Data class representing the impact of a plan change
class PlanChangeImpact {
  final int affectedScheduleCount;
  final DateTime? firstAffectedDate;
  final List<String> changedFields;
  final bool hasEscalationChange;
  final int currentWeekElapsed;
  final String? warningMessage;

  const PlanChangeImpact({
    required this.affectedScheduleCount,
    required this.changedFields,
    required this.hasEscalationChange,
    required this.currentWeekElapsed,
    this.firstAffectedDate,
    this.warningMessage,
  });

  /// Check if there are any changes
  bool get hasChanges => changedFields.isNotEmpty;
}

/// UseCase to analyze the impact of plan changes
class AnalyzePlanChangeImpactUseCase {
  /// Analyze impact of changing from oldPlan to newPlan
  PlanChangeImpact execute({
    required DosagePlan oldPlan,
    required DosagePlan newPlan,
    required DateTime? fromDate,
  }) {
    final currentDate = fromDate ?? DateTime.now();
    final changedFields = _identifyChangedFields(oldPlan, newPlan);

    if (changedFields.isEmpty) {
      return PlanChangeImpact(
        affectedScheduleCount: 0,
        changedFields: [],
        hasEscalationChange: false,
        currentWeekElapsed: _calculateWeeksElapsed(newPlan.startDate, currentDate),
      );
    }

    // Count affected schedules (future schedules only)
    final affectedCount = _countAffectedSchedules(newPlan, currentDate);

    // Determine if escalation plan changed
    final hasEscalationChange = _hasEscalationChanged(oldPlan, newPlan);

    // Calculate current week
    final currentWeek = _calculateWeeksElapsed(newPlan.startDate, currentDate);

    // Generate warning message if needed
    String? warningMessage;
    if (changedFields.contains('escalationPlan') && currentWeek > 0) {
      warningMessage = '현재 ${currentWeek}주차 진행 중입니다. '
          '변경 시 이후 증량 일정이 조정됩니다.';
    }

    if (changedFields.contains('initialDoseMg') &&
        _isDoseChangeSignificant(oldPlan.initialDoseMg, newPlan.initialDoseMg)) {
      warningMessage = warningMessage ?? '';
      warningMessage += '용량 변경이 큽니다. 의료진과 상담 후 진행하세요.';
    }

    return PlanChangeImpact(
      affectedScheduleCount: affectedCount,
      firstAffectedDate: _calculateFirstAffectedDate(newPlan, currentDate),
      changedFields: changedFields,
      hasEscalationChange: hasEscalationChange,
      currentWeekElapsed: currentWeek,
      warningMessage: warningMessage?.isEmpty == true ? null : warningMessage,
    );
  }

  /// Identify which fields have changed
  List<String> _identifyChangedFields(DosagePlan oldPlan, DosagePlan newPlan) {
    final changedFields = <String>[];

    if (oldPlan.medicationName != newPlan.medicationName) {
      changedFields.add('medicationName');
    }
    if (oldPlan.startDate != newPlan.startDate) {
      changedFields.add('startDate');
    }
    if (oldPlan.cycleDays != newPlan.cycleDays) {
      changedFields.add('cycleDays');
    }
    if (oldPlan.initialDoseMg != newPlan.initialDoseMg) {
      changedFields.add('initialDoseMg');
    }
    if (!_escalationPlansEqual(oldPlan.escalationPlan, newPlan.escalationPlan)) {
      changedFields.add('escalationPlan');
    }

    return changedFields;
  }

  /// Count schedules that will be affected by the change
  int _countAffectedSchedules(DosagePlan plan, DateTime fromDate) {
    // Estimate based on 1 year worth of schedules
    final daysTillEndOfYear = DateTime(fromDate.year + 1).difference(fromDate).inDays;
    return (daysTillEndOfYear / plan.cycleDays).ceil();
  }

  /// Calculate the first date affected by changes
  DateTime _calculateFirstAffectedDate(DosagePlan plan, DateTime fromDate) {
    // First affected date is the next dose date after fromDate
    final today = DateTime(fromDate.year, fromDate.month, fromDate.day);
    DateTime nextDate = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);

    while (nextDate.isBefore(today)) {
      nextDate = nextDate.add(Duration(days: plan.cycleDays));
    }

    return nextDate;
  }

  /// Check if escalation plan has changed
  bool _hasEscalationChanged(DosagePlan oldPlan, DosagePlan newPlan) {
    return !_escalationPlansEqual(oldPlan.escalationPlan, newPlan.escalationPlan);
  }

  /// Compare two escalation plans
  bool _escalationPlansEqual(
    List<EscalationStep>? plan1,
    List<EscalationStep>? plan2,
  ) {
    if (plan1 == null && plan2 == null) return true;
    if (plan1 == null || plan2 == null) return false;
    if (plan1.length != plan2.length) return false;

    for (int i = 0; i < plan1.length; i++) {
      if (plan1[i].weeksFromStart != plan2[i].weeksFromStart ||
          plan1[i].doseMg != plan2[i].doseMg) {
        return false;
      }
    }

    return true;
  }

  /// Check if dose change is significant (>20% change)
  bool _isDoseChangeSignificant(double oldDose, double newDose) {
    final percentageChange = ((newDose - oldDose).abs() / oldDose * 100);
    return percentageChange > 20;
  }

  /// Calculate weeks elapsed since plan start
  int _calculateWeeksElapsed(DateTime startDate, DateTime currentDate) {
    final difference = currentDate.difference(startDate);
    return (difference.inDays / 7).floor();
  }
}

import 'package:equatable/equatable.dart';

class PlanChangeHistory extends Equatable {
  final String id;
  final String dosagePlanId;
  final DateTime changedAt;
  final Map<String, dynamic> oldPlan;
  final Map<String, dynamic> newPlan;

  const PlanChangeHistory({
    required this.id,
    required this.dosagePlanId,
    required this.changedAt,
    required this.oldPlan,
    required this.newPlan,
  });

  @override
  List<Object?> get props => [
    id,
    dosagePlanId,
    changedAt,
    oldPlan,
    newPlan,
  ];

  PlanChangeHistory copyWith({
    String? id,
    String? dosagePlanId,
    DateTime? changedAt,
    Map<String, dynamic>? oldPlan,
    Map<String, dynamic>? newPlan,
  }) {
    return PlanChangeHistory(
      id: id ?? this.id,
      dosagePlanId: dosagePlanId ?? this.dosagePlanId,
      changedAt: changedAt ?? this.changedAt,
      oldPlan: oldPlan ?? this.oldPlan,
      newPlan: newPlan ?? this.newPlan,
    );
  }
}

import 'package:equatable/equatable.dart';

class EmergencySymptomCheck extends Equatable {
  final String id;
  final String userId;
  final DateTime checkedAt;
  final List<String> checkedSymptoms;

  const EmergencySymptomCheck({
    required this.id,
    required this.userId,
    required this.checkedAt,
    required this.checkedSymptoms,
  });

  EmergencySymptomCheck copyWith({
    String? id,
    String? userId,
    DateTime? checkedAt,
    List<String>? checkedSymptoms,
  }) {
    return EmergencySymptomCheck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkedAt: checkedAt ?? this.checkedAt,
      checkedSymptoms: checkedSymptoms ?? this.checkedSymptoms,
    );
  }

  @override
  List<Object?> get props => [id, userId, checkedAt, checkedSymptoms];

  @override
  String toString() =>
      'EmergencySymptomCheck(id: $id, userId: $userId, checkedAt: $checkedAt, checkedSymptoms: $checkedSymptoms)';
}

import 'package:equatable/equatable.dart';

class AuditLog extends Equatable {
  final String id;
  final String userId;
  final String recordId;
  final String recordType; // 'weight', 'symptom', 'dose'
  final String changeType; // 'create', 'update', 'delete'
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.recordId,
    required this.recordType,
    required this.changeType,
    this.oldValue,
    this.newValue,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    recordId,
    recordType,
    changeType,
    oldValue,
    newValue,
    timestamp,
  ];
}

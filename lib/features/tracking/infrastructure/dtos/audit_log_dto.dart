import 'package:n06/features/tracking/domain/entities/audit_log.dart';

/// Supabase DTO for AuditLog entity.
///
/// Stores audit log information in Supabase database.
class AuditLogDto {
  final String id;
  final String userId;
  final String recordId;
  final String recordType;
  final String changeType;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime timestamp;

  const AuditLogDto({
    required this.id,
    required this.userId,
    required this.recordId,
    required this.recordType,
    required this.changeType,
    this.oldValue,
    this.newValue,
    required this.timestamp,
  });

  /// Creates DTO from Supabase JSON.
  factory AuditLogDto.fromJson(Map<String, dynamic> json) {
    return AuditLogDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recordId: json['record_id'] as String,
      recordType: json['record_type'] as String,
      changeType: json['change_type'] as String,
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'record_id': recordId,
      'record_type': recordType,
      'change_type': changeType,
      'old_value': oldValue,
      'new_value': newValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  AuditLog toEntity() {
    return AuditLog(
      id: id,
      userId: userId,
      recordId: recordId,
      recordType: recordType,
      changeType: changeType,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: timestamp,
    );
  }

  /// Creates DTO from Domain Entity.
  factory AuditLogDto.fromEntity(AuditLog entity) {
    return AuditLogDto(
      id: entity.id,
      userId: entity.userId,
      recordId: entity.recordId,
      recordType: entity.recordType,
      changeType: entity.changeType,
      oldValue: entity.oldValue,
      newValue: entity.newValue,
      timestamp: entity.timestamp,
    );
  }
}

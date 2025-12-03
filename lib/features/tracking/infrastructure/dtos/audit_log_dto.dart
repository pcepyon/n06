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
  /// Maps DB column names to DTO field names:
  /// - entity_id -> recordId
  /// - entity_type -> recordType
  /// - action -> changeType
  /// - old_data -> oldValue
  /// - new_data -> newValue
  /// - created_at -> timestamp
  factory AuditLogDto.fromJson(Map<String, dynamic> json) {
    return AuditLogDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recordId: json['entity_id'] as String,
      recordType: json['entity_type'] as String,
      changeType: json['action'] as String,
      oldValue: json['old_data'] as Map<String, dynamic>?,
      newValue: json['new_data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  /// Maps DTO field names to DB column names.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'entity_id': recordId,
      'entity_type': recordType,
      'action': changeType,
      'old_data': oldValue,
      'new_data': newValue,
      // created_at uses DEFAULT now() in DB, no need to send
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

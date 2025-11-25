import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

/// Supabase DTO for SymptomLog entity.
///
/// Stores symptom log information in Supabase database.
class SymptomLogDto {
  final String id;
  final String userId;
  final DateTime logDate;
  final String symptomName;
  final int severity;
  final int? daysSinceEscalation;
  final bool? isPersistent24h;
  final String? note;
  final DateTime? createdAt;

  const SymptomLogDto({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.symptomName,
    required this.severity,
    this.daysSinceEscalation,
    this.isPersistent24h,
    this.note,
    this.createdAt,
  });

  /// Creates DTO from Supabase JSON.
  factory SymptomLogDto.fromJson(Map<String, dynamic> json) {
    return SymptomLogDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String).toLocal(),
      symptomName: json['symptom_name'] as String,
      severity: json['severity'] as int,
      daysSinceEscalation: json['days_since_escalation'] as int?,
      isPersistent24h: json['is_persistent_24h'] as bool?,
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'symptom_name': symptomName,
      'severity': severity,
      'days_since_escalation': daysSinceEscalation,
      'is_persistent_24h': isPersistent24h,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  SymptomLog toEntity({required List<String> tags}) {
    return SymptomLog(
      id: id,
      userId: userId,
      logDate: logDate,
      symptomName: symptomName,
      severity: severity,
      daysSinceEscalation: daysSinceEscalation,
      isPersistent24h: isPersistent24h,
      note: note,
      tags: tags,
      createdAt: createdAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory SymptomLogDto.fromEntity(SymptomLog entity) {
    return SymptomLogDto(
      id: entity.id,
      userId: entity.userId,
      logDate: entity.logDate,
      symptomName: entity.symptomName,
      severity: entity.severity,
      daysSinceEscalation: entity.daysSinceEscalation,
      isPersistent24h: entity.isPersistent24h,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  @override
  String toString() =>
      'SymptomLogDto(id: $id, userId: $userId, logDate: $logDate, symptomName: $symptomName, severity: $severity, daysSinceEscalation: $daysSinceEscalation, isPersistent24h: $isPersistent24h, note: $note, createdAt: $createdAt)';
}

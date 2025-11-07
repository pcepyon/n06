import 'package:equatable/equatable.dart';

class SymptomLog extends Equatable {
  final String id;
  final String userId;
  final DateTime logDate;
  final String symptomName;
  final int severity; // 1-10
  final int? daysSinceEscalation;
  final bool? isPersistent24h;
  final String? note;
  final List<String> tags;
  final DateTime? createdAt;

  const SymptomLog({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.symptomName,
    required this.severity,
    this.daysSinceEscalation,
    this.isPersistent24h,
    this.note,
    this.tags = const [],
    this.createdAt,
  }) : assert(severity >= 1 && severity <= 10, 'Severity must be between 1 and 10');

  SymptomLog copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    String? symptomName,
    int? severity,
    int? daysSinceEscalation,
    bool? isPersistent24h,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      symptomName: symptomName ?? this.symptomName,
      severity: severity ?? this.severity,
      daysSinceEscalation: daysSinceEscalation ?? this.daysSinceEscalation,
      isPersistent24h: isPersistent24h ?? this.isPersistent24h,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        logDate,
        symptomName,
        severity,
        daysSinceEscalation,
        isPersistent24h,
        note,
        tags,
        createdAt,
      ];

  @override
  String toString() =>
      'SymptomLog(id: $id, userId: $userId, logDate: $logDate, symptomName: $symptomName, severity: $severity, daysSinceEscalation: $daysSinceEscalation, isPersistent24h: $isPersistent24h, tags: $tags, note: $note, createdAt: $createdAt)';
}

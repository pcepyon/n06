import 'package:n06/features/tracking/domain/entities/weight_log.dart';

/// Supabase DTO for WeightLog entity.
///
/// Stores weight log information in Supabase database.
class WeightLogDto {
  final String id;
  final String userId;
  final DateTime logDate;
  final double weightKg;
  final DateTime createdAt;

  const WeightLogDto({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.weightKg,
    required this.createdAt,
  });

  /// Creates DTO from Supabase JSON.
  factory WeightLogDto.fromJson(Map<String, dynamic> json) {
    return WeightLogDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'weight_kg': weightKg,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  WeightLog toEntity() {
    return WeightLog(
      id: id,
      userId: userId,
      logDate: logDate,
      weightKg: weightKg,
      createdAt: createdAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory WeightLogDto.fromEntity(WeightLog entity) {
    return WeightLogDto(
      id: entity.id,
      userId: entity.userId,
      logDate: entity.logDate,
      weightKg: entity.weightKg,
      createdAt: entity.createdAt,
    );
  }

  @override
  String toString() =>
      'WeightLogDto(id: $id, userId: $userId, logDate: $logDate, weightKg: $weightKg, createdAt: $createdAt)';
}

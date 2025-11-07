import 'package:equatable/equatable.dart';

class WeightLog extends Equatable {
  final String id;
  final String userId;
  final DateTime logDate;
  final double weightKg;
  final DateTime createdAt;

  const WeightLog({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.weightKg,
    required this.createdAt,
  });

  WeightLog copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    double? weightKg,
    DateTime? createdAt,
  }) {
    return WeightLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, logDate, weightKg, createdAt];

  @override
  String toString() =>
      'WeightLog(id: $id, userId: $userId, logDate: $logDate, weightKg: $weightKg, createdAt: $createdAt)';
}

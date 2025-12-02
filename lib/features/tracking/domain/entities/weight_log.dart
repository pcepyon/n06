import 'package:equatable/equatable.dart';

/// 체중 기록 엔티티
///
/// 이 엔티티는 database.md의 weight_logs 테이블을 나타냅니다.
/// weight_logs는 독립적인 공통 테이블로, 여러 기능에서 사용됩니다:
/// - onboarding: 초기 체중 기록 생성
/// - tracking: 일상 체중 기록 관리
/// - dashboard: 체중 데이터 조회 및 통계 계산
///
/// 구현은 tracking 기능에 위치하지만, 논리적으로는 공통 도메인입니다.
/// Supabase PostgreSQL 기반 cloud-first architecture를 사용합니다.
///
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

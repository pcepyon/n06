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
/// Phase 0에서는 Isar 로컬 DB를 사용하며,
/// Phase 1에서 Supabase PostgreSQL로 마이그레이션됩니다.
///
/// [appetiteScore]는 식욕 조절 점수(1-5)로, GLP-1 약물의 핵심 임상 지표입니다.
/// - 5: 식욕 폭발 (Severe hunger)
/// - 4: 보통 (Normal)
/// - 3: 약간 감소 (Slight decrease)
/// - 2: 매우 감소 (Significant decrease)
/// - 1: 아예 없음 (No appetite)
/// - null: 기록 안 함 (기존 데이터 호환)
class WeightLog extends Equatable {
  final String id;
  final String userId;
  final DateTime logDate;
  final double weightKg;
  final int? appetiteScore;
  final DateTime createdAt;

  const WeightLog({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.weightKg,
    this.appetiteScore,
    required this.createdAt,
  });

  WeightLog copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    double? weightKg,
    int? appetiteScore,
    DateTime? createdAt,
  }) {
    return WeightLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      weightKg: weightKg ?? this.weightKg,
      appetiteScore: appetiteScore ?? this.appetiteScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, logDate, weightKg, appetiteScore, createdAt];

  @override
  String toString() =>
      'WeightLog(id: $id, userId: $userId, logDate: $logDate, weightKg: $weightKg, appetiteScore: $appetiteScore, createdAt: $createdAt)';
}

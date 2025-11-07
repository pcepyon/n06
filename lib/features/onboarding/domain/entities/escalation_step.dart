/// 증량 계획의 한 단계를 나타내는 Value Object
class EscalationStep {
  final int weeks;
  final double doseMg;

  /// EscalationStep을 생성한다.
  /// weeks와 doseMg는 모두 양수여야 한다.
  EscalationStep({
    required this.weeks,
    required this.doseMg,
  }) {
    if (weeks <= 0) {
      throw ArgumentError('주(weeks)는 양수여야 합니다.');
    }
    if (doseMg <= 0) {
      throw ArgumentError('용량(doseMg)은 양수여야 합니다.');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EscalationStep &&
        other.weeks == weeks &&
        other.doseMg == doseMg;
  }

  @override
  int get hashCode => weeks.hashCode ^ doseMg.hashCode;

  @override
  String toString() => 'EscalationStep(weeks: $weeks, doseMg: $doseMg)';
}

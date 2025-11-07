import 'package:n06/core/errors/domain_exception.dart';

/// 체중을 나타내는 Value Object
/// 20kg ~ 300kg 범위의 검증을 수행한다.
class Weight {
  final double value;

  const Weight._(this.value);

  /// 주어진 킬로그램 값으로 Weight를 생성한다.
  /// 20kg 미만이거나 300kg을 초과하면 DomainException을 던진다.
  factory Weight.create(double kg) {
    if (kg < 20 || kg > 300) {
      throw DomainException(
        message: '체중은 20kg 이상 300kg 이하여야 합니다.',
        code: 'INVALID_WEIGHT',
      );
    }
    return Weight._(kg);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Weight && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Weight($value kg)';
}

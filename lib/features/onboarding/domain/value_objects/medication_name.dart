import 'package:n06/core/errors/domain_exception.dart';

/// 약물명을 나타내는 Value Object
/// 빈 문자열이나 공백만으로 이루어진 문자열을 허용하지 않는다.
class MedicationName {
  final String value;

  const MedicationName._(this.value);

  /// 주어진 약물명으로 MedicationName을 생성한다.
  /// 빈 문자열이거나 공백만 있으면 DomainException을 던진다.
  factory MedicationName.create(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw DomainException(
        message: '약물명은 비워둘 수 없습니다.',
        code: 'INVALID_MEDICATION_NAME',
      );
    }
    return MedicationName._(trimmed);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MedicationName && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MedicationName($value)';
}

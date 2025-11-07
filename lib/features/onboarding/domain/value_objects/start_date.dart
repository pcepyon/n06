import 'package:n06/core/errors/domain_exception.dart';

/// 투여 시작일을 나타내는 Value Object
/// 30일 이상 과거 날짜는 허용하지 않으며,
/// 7일 이상 과거 날짜는 경고 플래그를 설정한다.
class StartDate {
  final DateTime value;
  final bool hasWarning;

  const StartDate._(this.value, this.hasWarning);

  /// 주어진 날짜로 StartDate를 생성한다.
  /// - 30일 이상 과거: DomainException 발생
  /// - 7~29일 과거: 경고 플래그 설정 (hasWarning = true)
  /// - 현재 이후: 정상 (hasWarning = false)
  factory StartDate.create(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference >= 30) {
      throw DomainException(
        message: '시작일은 30일 이상 과거일 수 없습니다.',
        code: 'INVALID_START_DATE',
      );
    }

    final hasWarning = difference >= 7;

    return StartDate._(date, hasWarning);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StartDate &&
        other.value.year == value.year &&
        other.value.month == value.month &&
        other.value.day == value.day;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'StartDate(${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}, hasWarning: $hasWarning)';
}

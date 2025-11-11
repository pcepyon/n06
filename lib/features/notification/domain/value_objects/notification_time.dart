/// 순수 Dart 시간 Value Object (Flutter 의존성 제거)
/// Domain Layer에서 사용하며, TimeOfDay 변환은 Presentation Layer에서만 수행
class NotificationTime {
  final int hour; // 0-23
  final int minute; // 0-59

  const NotificationTime({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour < 24, 'Hour must be 0-23'),
        assert(minute >= 0 && minute < 60, 'Minute must be 0-59');

  /// DateTime으로 변환 (오늘 날짜 기준)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 특정 날짜의 시간으로 변환
  DateTime toDateTimeOn(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

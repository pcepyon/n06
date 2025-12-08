/// 주차 계산 SSOT (Single Source of Truth)
///
/// 투여 시작일로부터 경과 주차를 계산합니다.
/// 비즈니스 룰: 첫날 = 1주차, ceil() 기반
abstract final class WeekCalculator {
  /// 투여 시작일로부터 현재 주차 계산
  ///
  /// 기존 로직 유지: (days / 7).ceil()
  /// - 0일차 (시작일) = ceil(0/7) = 0 → 실제로는 1주차로 취급
  /// - 1-6일차 = ceil(1~6/7) = 1
  /// - 7-13일차 = ceil(7~13/7) = 1~2
  ///
  /// 주의: 기존 코드와 동일한 결과를 보장하기 위해 ceil() 사용
  ///
  /// [startDate] 투여 시작일
  /// [currentDate] 계산 기준일 (기본값: DateTime.now())
  ///
  /// Returns: 경과 주차 (ceil 기반)
  static int weeksElapsed(DateTime startDate, [DateTime? currentDate]) {
    final target = currentDate ?? DateTime.now();
    final difference = target.difference(startDate);
    return (difference.inDays / 7).ceil();
  }
}

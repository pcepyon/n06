class CalculateCurrentWeekUseCase {
  /// 투여 시작일 기준으로 현재 주차를 계산합니다.
  /// 1주 = 7일 기준으로 계산합니다. (날짜만 비교, 시간 제외)
  int execute(DateTime startDate) {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final difference = nowDate.difference(startDateOnly).inDays;
    return (difference / 7).floor() + 1;
  }
}

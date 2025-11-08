class CalculateCurrentWeekUseCase {
  /// 투여 시작일 기준으로 현재 주차를 계산합니다.
  /// 1주 = 7일 기준으로 계산합니다.
  int execute(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    return (difference / 7).floor() + 1;
  }
}

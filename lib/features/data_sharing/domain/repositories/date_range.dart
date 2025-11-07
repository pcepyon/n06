enum DateRange {
  lastMonth('최근 1개월', 30),
  lastThreeMonths('최근 3개월', 90),
  allTime('전체 기간', null);

  final String label;
  final int? days;

  const DateRange(this.label, this.days);

  /// Calculate start date based on the range
  DateTime getStartDate(DateTime endDate) {
    if (days == null) {
      // For allTime, return a very old date (epoch)
      return DateTime(1970, 1, 1);
    }
    return endDate.subtract(Duration(days: days!));
  }
}

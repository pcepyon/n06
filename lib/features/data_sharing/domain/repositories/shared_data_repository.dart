import '../entities/shared_data_report.dart';
import 'date_range.dart';

abstract class SharedDataRepository {
  /// Get shared data report for given date range
  /// Returns SharedDataReport containing all records within the specified range
  Future<SharedDataReport> getReportData(
    String userId,
    DateRange dateRange,
  );
}

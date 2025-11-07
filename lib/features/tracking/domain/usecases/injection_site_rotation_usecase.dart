import 'package:n06/features/tracking/domain/entities/dose_record.dart';

class RotationCheckResult {
  final bool needsWarning;
  final String message;
  final int daysSinceLastUse;

  RotationCheckResult({
    required this.needsWarning,
    required this.message,
    required this.daysSinceLastUse,
  });
}

class InjectionSiteRotationUseCase {
  static const int minimumDaysInterval = 7;
  static const int historyDays = 30;

  /// Check if new injection site needs warning based on recent records
  RotationCheckResult checkRotation(
    String newSite,
    List<DoseRecord> recentRecords,
  ) {
    // Find most recent record with same site
    DoseRecord? lastSameSiteRecord;
    for (final record in recentRecords) {
      if (record.injectionSite == newSite) {
        if (lastSameSiteRecord == null ||
            record.administeredAt.isAfter(lastSameSiteRecord.administeredAt)) {
          lastSameSiteRecord = record;
        }
      }
    }

    if (lastSameSiteRecord == null) {
      return RotationCheckResult(
        needsWarning: false,
        message: '',
        daysSinceLastUse: 0,
      );
    }

    final now = DateTime.now();
    final daysSince = now.difference(lastSameSiteRecord.administeredAt).inDays;

    if (daysSince < minimumDaysInterval) {
      return RotationCheckResult(
        needsWarning: true,
        message:
            '동일 부위를 $daysSince일 전에 사용했습니다. 최소 7일 간격을 권장합니다.',
        daysSinceLastUse: daysSince,
      );
    }

    return RotationCheckResult(
      needsWarning: false,
      message: '',
      daysSinceLastUse: daysSince,
    );
  }

  /// Get site usage history for visualization (last 30 days)
  List<Map<String, dynamic>> getSiteHistory(List<DoseRecord> records) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: historyDays));

    final recentRecords = records
        .where((r) => r.administeredAt.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));

    final history = <Map<String, dynamic>>[];

    for (final record in recentRecords) {
      history.add({
        'site': record.injectionSite,
        'date': record.administeredAt,
        'daysAgo': now.difference(record.administeredAt).inDays,
      });
    }

    return history;
  }

  /// Get list of unique sites used in last 30 days
  List<String> getSiteHistoryList(List<DoseRecord> records) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: historyDays));

    final recentRecords = records.where((r) =>
        r.administeredAt.isAfter(thirtyDaysAgo) &&
        r.injectionSite != null);

    final sites = <String>{};
    for (final record in recentRecords) {
      if (record.injectionSite != null) {
        sites.add(record.injectionSite!);
      }
    }

    return sites.toList();
  }
}

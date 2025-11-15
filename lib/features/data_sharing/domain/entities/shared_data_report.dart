import 'package:equatable/equatable.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';

class SharedDataReport extends Equatable {
  final DateTime dateRangeStart;
  final DateTime dateRangeEnd;
  final List<DoseRecord> doseRecords;
  final List<WeightLog> weightLogs;
  final List<SymptomLog> symptomLogs;
  final List<EmergencySymptomCheck> emergencyChecks;
  final List<DoseSchedule> doseSchedules;

  const SharedDataReport({
    required this.dateRangeStart,
    required this.dateRangeEnd,
    required this.doseRecords,
    required this.weightLogs,
    required this.symptomLogs,
    required this.emergencyChecks,
    required this.doseSchedules,
  });

  /// Calculate adherence rate as percentage (0-100)
  /// Formula: (completed doses / scheduled doses) * 100
  double calculateAdherenceRate() {
    if (doseSchedules.isEmpty) {
      return 0.0;
    }

    // Filter schedules within date range (inclusive)
    final schedulesInRange = doseSchedules.where((schedule) {
      final scheduleDate = schedule.scheduledDate;
      return !scheduleDate.isBefore(dateRangeStart) &&
          !scheduleDate.isAfter(dateRangeEnd);
    }).toList();

    if (schedulesInRange.isEmpty) {
      return 0.0;
    }

    // Count records that match scheduled dates
    int completedCount = 0;
    for (final schedule in schedulesInRange) {
      final hasRecord = doseRecords.any((record) {
        final recordDate = DateTime(
          record.administeredAt.year,
          record.administeredAt.month,
          record.administeredAt.day,
        );
        return recordDate == schedule.scheduledDate;
      });
      if (hasRecord) {
        completedCount++;
      }
    }

    return (completedCount / schedulesInRange.length) * 100;
  }

  /// Get injection site history as a map of site -> count
  Map<String, int> getInjectionSiteHistory() {
    final siteHistory = <String, int>{};

    for (final record in doseRecords) {
      if (record.injectionSite != null) {
        siteHistory[record.injectionSite!] = (siteHistory[record.injectionSite!] ?? 0) + 1;
      }
    }

    return siteHistory;
  }

  /// Get weight logs sorted by date
  List<WeightLog> getWeightLogsSorted() {
    final sorted = List<WeightLog>.from(weightLogs);
    sorted.sort((a, b) => a.logDate.compareTo(b.logDate));
    return sorted;
  }

  /// Get dose records sorted by date
  List<DoseRecord> getDoseRecordsSorted() {
    final sorted = List<DoseRecord>.from(doseRecords);
    sorted.sort((a, b) => a.administeredAt.compareTo(b.administeredAt));
    return sorted;
  }

  /// Get symptom logs sorted by date
  List<SymptomLog> getSymptomLogsSorted() {
    final sorted = List<SymptomLog>.from(symptomLogs);
    sorted.sort((a, b) => a.logDate.compareTo(b.logDate));
    return sorted;
  }

  /// Get emergency checks sorted by date
  List<EmergencySymptomCheck> getEmergencyChecksSorted() {
    final sorted = List<EmergencySymptomCheck>.from(emergencyChecks);
    sorted.sort((a, b) => a.checkedAt.compareTo(b.checkedAt));
    return sorted;
  }

  /// Check if report has any data
  bool hasData() {
    return doseRecords.isNotEmpty ||
        weightLogs.isNotEmpty ||
        symptomLogs.isNotEmpty ||
        emergencyChecks.isNotEmpty;
  }

  SharedDataReport copyWith({
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    List<DoseRecord>? doseRecords,
    List<WeightLog>? weightLogs,
    List<SymptomLog>? symptomLogs,
    List<EmergencySymptomCheck>? emergencyChecks,
    List<DoseSchedule>? doseSchedules,
  }) {
    return SharedDataReport(
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
      doseRecords: doseRecords ?? this.doseRecords,
      weightLogs: weightLogs ?? this.weightLogs,
      symptomLogs: symptomLogs ?? this.symptomLogs,
      emergencyChecks: emergencyChecks ?? this.emergencyChecks,
      doseSchedules: doseSchedules ?? this.doseSchedules,
    );
  }

  @override
  List<Object?> get props => [
    dateRangeStart,
    dateRangeEnd,
    doseRecords,
    weightLogs,
    symptomLogs,
    emergencyChecks,
    doseSchedules,
  ];

  @override
  String toString() =>
      'SharedDataReport(dateRangeStart: $dateRangeStart, dateRangeEnd: $dateRangeEnd, doseRecords: ${doseRecords.length}, weightLogs: ${weightLogs.length}, symptomLogs: ${symptomLogs.length}, emergencyChecks: ${emergencyChecks.length}, doseSchedules: ${doseSchedules.length})';
}

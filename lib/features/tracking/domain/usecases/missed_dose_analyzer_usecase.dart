import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';

enum GuidanceType {
  immediateAdministration, // 5일 이내
  waitForNext, // 5-7일
  expertConsultation, // 7일 이상
}

class MissedDose {
  final DoseSchedule schedule;
  final int daysElapsed;
  final String message;

  MissedDose({
    required this.schedule,
    required this.daysElapsed,
    required this.message,
  });
}

class MissedDoseAnalysisResult {
  final List<MissedDose> missedDoses;
  final GuidanceType guidanceType;
  final bool requiresExpertConsultation;
  final String guidanceMessage;

  MissedDoseAnalysisResult({
    required this.missedDoses,
    required this.guidanceType,
    required this.requiresExpertConsultation,
    required this.guidanceMessage,
  });
}

class MissedDoseAnalyzerUseCase {
  /// Analyze missed doses from schedules and records
  MissedDoseAnalysisResult analyzeMissedDoses(
    List<DoseSchedule> schedules,
    List<DoseRecord> records,
  ) {
    final completedScheduleIds = _getCompletedScheduleIds(records);
    final now = DateTime.now();
    final missedDoses = <MissedDose>[];
    bool hasLongMissed = false;
    int maxDaysElapsed = 0;

    for (final schedule in schedules) {
      // Only check past schedules
      if (schedule.scheduledDate.isAfter(now)) {
        continue;
      }

      // Check if this schedule has a corresponding record
      if (!completedScheduleIds.contains(schedule.id)) {
        final daysElapsed = now.difference(schedule.scheduledDate).inDays;
        final message = _generateMissedDoseMessage(daysElapsed);

        missedDoses.add(MissedDose(
          schedule: schedule,
          daysElapsed: daysElapsed,
          message: message,
        ));

        if (daysElapsed >= 7) {
          hasLongMissed = true;
        }
        maxDaysElapsed = daysElapsed > maxDaysElapsed ? daysElapsed : maxDaysElapsed;
      }
    }

    // Sort by days elapsed (most recent first)
    missedDoses.sort((a, b) => b.daysElapsed.compareTo(a.daysElapsed));

    // Determine guidance type
    GuidanceType guidanceType;
    String guidanceMessage;

    if (missedDoses.isEmpty) {
      guidanceType = GuidanceType.waitForNext;
      guidanceMessage = '';
    } else if (maxDaysElapsed >= 7) {
      guidanceType = GuidanceType.expertConsultation;
      guidanceMessage = '의료진과 상담이 필요합니다.';
    } else if (maxDaysElapsed >= 5) {
      guidanceType = GuidanceType.waitForNext;
      guidanceMessage = '다음 예정일까지 대기하세요.';
    } else {
      guidanceType = GuidanceType.immediateAdministration;
      guidanceMessage = '즉시 투여하세요.';
    }

    return MissedDoseAnalysisResult(
      missedDoses: missedDoses,
      guidanceType: guidanceType,
      requiresExpertConsultation: hasLongMissed,
      guidanceMessage: guidanceMessage,
    );
  }

  /// Get set of completed schedule IDs
  Set<String> _getCompletedScheduleIds(List<DoseRecord> records) {
    final ids = <String>{};
    for (final record in records) {
      if (record.doseScheduleId != null && record.isCompleted) {
        ids.add(record.doseScheduleId!);
      }
    }
    return ids;
  }

  /// Generate message for missed dose
  String _generateMissedDoseMessage(int daysElapsed) {
    if (daysElapsed < 1) {
      return '오늘 투여 예정입니다.';
    } else if (daysElapsed < 5) {
      return '$daysElapsed일 경과 - 즉시 투여하세요.';
    } else if (daysElapsed < 7) {
      return '$daysElapsed일 경과 - 다음 예정일까지 대기하세요.';
    } else {
      return '$daysElapsed일 경과 - 의료진 상담 필요.';
    }
  }
}

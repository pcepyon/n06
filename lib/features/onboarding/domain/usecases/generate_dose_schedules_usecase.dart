import 'package:n06/features/onboarding/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/domain/entities/dose_schedule.dart';
import 'package:uuid/uuid.dart';

/// DosagePlan 기반 투여 스케줄을 생성하는 UseCase
class GenerateDoseSchedulesUseCase {
  static const Uuid _uuid = Uuid();

  /// 투여 스케줄을 생성한다.
  ///
  /// [daysToGenerate]: 생성할 날짜 범위 (기본값: 90일)
  List<DoseSchedule> execute(
    DosagePlan dosagePlan, {
    int daysToGenerate = 90,
  }) {
    if (daysToGenerate <= 0) {
      return [];
    }

    final schedules = <DoseSchedule>[];
    var currentDate = dosagePlan.startDate.value;
    var currentDoseMg = dosagePlan.initialDoseMg;
    final endDate = currentDate.add(Duration(days: daysToGenerate));
    var escalationIndex = 0;

    while (currentDate.isBefore(endDate)) {
      // 현재 날짜에서의 용량 결정
      if (dosagePlan.escalationPlan != null && escalationIndex < dosagePlan.escalationPlan!.length) {
        final nextEscalation = dosagePlan.escalationPlan![escalationIndex];
        final escalationDate = dosagePlan.startDate.value
            .add(Duration(days: nextEscalation.weeks * 7));

        if (currentDate.isAtSameMomentAs(escalationDate) || currentDate.isAfter(escalationDate)) {
          currentDoseMg = nextEscalation.doseMg;
          escalationIndex++;
        }
      }

      // 현재 날짜로 스케줄 생성
      schedules.add(
        DoseSchedule(
          id: _uuid.v4(),
          userId: dosagePlan.userId,
          dosagePlanId: dosagePlan.id,
          scheduledDate: currentDate,
          scheduledDoseMg: currentDoseMg,
        ),
      );

      // 다음 투여 날짜로 이동
      currentDate = currentDate.add(Duration(days: dosagePlan.cycleDays));
    }

    return schedules;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';

part 'medication_notifier.g.dart';

class MedicationState {
  final DosagePlan? activePlan;
  final List<DoseSchedule> schedules;
  final List<DoseRecord> records;

  const MedicationState({
    this.activePlan,
    required this.schedules,
    required this.records,
  });

  MedicationState copyWith({
    DosagePlan? activePlan,
    List<DoseSchedule>? schedules,
    List<DoseRecord>? records,
  }) {
    return MedicationState(
      activePlan: activePlan ?? this.activePlan,
      schedules: schedules ?? this.schedules,
      records: records ?? this.records,
    );
  }
}

@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  MedicationRepository get _repository => ref.read(medicationRepositoryProvider);
  ScheduleGeneratorUseCase get _scheduleGeneratorUseCase => ref.read(scheduleGeneratorUseCaseProvider);
  InjectionSiteRotationUseCase get _injectionSiteRotationUseCase => ref.read(injectionSiteRotationUseCaseProvider);
  MissedDoseAnalyzerUseCase get _missedDoseAnalyzerUseCase => ref.read(missedDoseAnalyzerUseCaseProvider);

  @override
  Future<MedicationState> build() async {
    final userId = ref.watch(authNotifierProvider).value?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await _loadMedicationData(userId);
  }

  /// Load medication data
  Future<MedicationState> _loadMedicationData(String userId) async {
    final plan = await _repository.getActiveDosagePlan(userId);
    final schedules = plan != null
        ? await _repository.getDoseSchedules(plan.id)
        : <DoseSchedule>[];
    final records =
        plan != null ? await _repository.getDoseRecords(plan.id) : <DoseRecord>[];

    return MedicationState(
      activePlan: plan,
      schedules: schedules,
      records: records,
    );
  }

  /// Record dose with injection site rotation check
  Future<RotationCheckResult?> recordDose(DoseRecord record) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    // Get current userId
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Check if duplicate
      if (await _repository.isDuplicateDoseRecord(
        record.dosagePlanId,
        record.administeredAt,
      )) {
        throw Exception('이미 같은 날짜의 투여 기록이 존재합니다.');
      }

      // Check injection site rotation if site is specified
      RotationCheckResult? rotationResult;
      if (record.injectionSite != null) {
        final recentRecords = await _repository.getRecentDoseRecords(
          record.dosagePlanId,
          30,
        );
        rotationResult = _injectionSiteRotationUseCase.checkRotation(
          record.injectionSite!,
          recentRecords,
        );
      }

      // Save record
      await _repository.saveDoseRecord(record);

      // ✅ async gap 후 mounted 체크
      if (!ref.mounted) {
        return rotationResult;
      }

      // Reload state
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return await _loadMedicationData(userId);
      });

      return rotationResult;
    } finally {
      link.close();
    }
  }

  /// Update dosage plan and recalculate schedules
  Future<void> updateDosagePlan(DosagePlan newPlan) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    final currentState = state.asData?.value;
    if (currentState == null) throw Exception('State not loaded');

    final currentPlan = currentState.activePlan;
    if (currentPlan == null) {
      throw Exception('활성 투여 계획이 없습니다.');
    }

    try {
      // Save plan change history
      await _repository.savePlanChangeHistory(
        newPlan.id,
        _planToMap(currentPlan),
        _planToMap(newPlan),
      );

      // Update plan
      await _repository.updateDosagePlan(newPlan);

      // Recalculate schedules from change date
      final existingSchedules = currentState.schedules;
      final newSchedules = _scheduleGeneratorUseCase.recalculateSchedulesFrom(
        newPlan,
        DateTime.now(),
        DateTime.now().add(Duration(days: 365)),
        existingSchedules,
      );

      // Delete old schedules from change date and save new ones
      await _repository.deleteDoseSchedulesFrom(newPlan.id, DateTime.now());
      await _repository.saveDoseSchedules(newSchedules);

      // ✅ async gap 후 mounted 체크
      if (!ref.mounted) {
        return;
      }

      // Reload data
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return await _loadMedicationData(userId);
      });
    } finally {
      link.close();
    }
  }

  /// Get missed dose analysis
  MissedDoseAnalysisResult? getMissedDoseAnalysis() {
    final currentState = state.asData?.value;
    if (currentState == null) return null;

    final schedules = currentState.schedules;
    final records = currentState.records;

    return _missedDoseAnalyzerUseCase.analyzeMissedDoses(schedules, records);
  }

  /// Delete dose record
  Future<void> deleteDoseRecord(String recordId) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _repository.deleteDoseRecord(recordId);

      // ✅ async gap 후 mounted 체크
      if (!ref.mounted) {
        return;
      }

      // Reload state
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return await _loadMedicationData(userId);
      });
    } finally {
      link.close();
    }
  }

  /// Delete dose schedule (only unrecorded schedules)
  Future<void> deleteDoseSchedule(String scheduleId) async {
    // ✅ 작업 완료 보장을 위한 keepAlive
    final link = ref.keepAlive();

    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    final currentState = state.asData?.value;
    if (currentState == null) throw Exception('State not loaded');

    // Check if schedule has associated record
    final hasRecord = currentState.records.any((r) => r.doseScheduleId == scheduleId);
    if (hasRecord) {
      throw Exception('투여 기록이 있는 일정은 삭제할 수 없습니다.');
    }

    try {
      await _repository.deleteDoseSchedule(scheduleId);

      // ✅ async gap 후 mounted 체크
      if (!ref.mounted) {
        return;
      }

      // Reload state
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return await _loadMedicationData(userId);
      });
    } finally {
      link.close();
    }
  }

  /// Get plan change history
  Future<List<dynamic>> getPlanHistory() async {
    final currentState = state.asData?.value;
    if (currentState == null) return [];

    final plan = currentState.activePlan;
    if (plan == null) {
      return [];
    }

    return await _repository.getPlanChangeHistory(plan.id);
  }

  /// Get injection site rotation check
  Future<RotationCheckResult> checkInjectionSiteRotation(
    String newSite,
  ) async {
    final currentState = state.asData?.value;
    if (currentState == null) throw Exception('State not loaded');

    final plan = currentState.activePlan;
    if (plan == null) {
      throw Exception('활성 투여 계획이 없습니다.');
    }

    final recentRecords = await _repository.getRecentDoseRecords(
      plan.id,
      30,
    );

    return _injectionSiteRotationUseCase.checkRotation(newSite, recentRecords);
  }

  /// Convert plan to map for history
  Map<String, dynamic> _planToMap(DosagePlan plan) {
    return {
      'id': plan.id,
      'medicationName': plan.medicationName,
      'startDate': plan.startDate.toIso8601String(),
      'cycleDays': plan.cycleDays,
      'initialDoseMg': plan.initialDoseMg,
      'escalationPlan': plan.escalationPlan
          ?.map((step) => {
                'weeksFromStart': step.weeksFromStart,
                'doseMg': step.doseMg,
              })
          .toList(),
    };
  }
}


// Backwards compatibility alias
const medicationNotifierProvider = medicationProvider;

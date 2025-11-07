import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart';
import 'package:n06/features/tracking/domain/usecases/schedule_generator_usecase.dart';
import 'package:n06/features/tracking/infrastructure/services/notification_service.dart';

class MedicationState {
  final AsyncValue<DosagePlan?> activePlan;
  final AsyncValue<List<DoseSchedule>> schedules;
  final AsyncValue<List<DoseRecord>> records;

  const MedicationState({
    required this.activePlan,
    required this.schedules,
    required this.records,
  });

  bool get isLoading =>
      activePlan is AsyncLoading ||
      schedules is AsyncLoading ||
      records is AsyncLoading;

  bool get hasError =>
      activePlan is AsyncError || schedules is AsyncError || records is AsyncError;
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  final MedicationRepository _repository;
  final ScheduleGeneratorUseCase _scheduleGeneratorUseCase;
  final InjectionSiteRotationUseCase _injectionSiteRotationUseCase;
  final MissedDoseAnalyzerUseCase _missedDoseAnalyzerUseCase;
  final NotificationService notificationService;

  late String _userId;

  MedicationNotifier({
    required MedicationRepository repository,
    required ScheduleGeneratorUseCase scheduleGeneratorUseCase,
    required InjectionSiteRotationUseCase injectionSiteRotationUseCase,
    required MissedDoseAnalyzerUseCase missedDoseAnalyzerUseCase,
    required this.notificationService,
  })  : _repository = repository,
        _scheduleGeneratorUseCase = scheduleGeneratorUseCase,
        _injectionSiteRotationUseCase = injectionSiteRotationUseCase,
        _missedDoseAnalyzerUseCase = missedDoseAnalyzerUseCase,
        super(
          const MedicationState(
            activePlan: AsyncValue.loading(),
            schedules: AsyncValue.loading(),
            records: AsyncValue.loading(),
          ),
        );

  /// Initialize notifier with userId
  Future<void> initialize(String userId) async {
    _userId = userId;
    await _loadMedicationData();
  }

  /// Load medication data
  Future<void> _loadMedicationData() async {
    try {
      final plan = await _repository.getActiveDosagePlan(_userId);
      final schedules = plan != null
          ? await _repository.getDoseSchedules(plan.id)
          : <DoseSchedule>[];
      final records =
          plan != null ? await _repository.getDoseRecords(plan.id) : <DoseRecord>[];

      state = MedicationState(
        activePlan: AsyncValue.data(plan),
        schedules: AsyncValue.data(schedules),
        records: AsyncValue.data(records),
      );
    } catch (e, stackTrace) {
      state = MedicationState(
        activePlan: AsyncValue.error(e, stackTrace),
        schedules: AsyncValue.error(e, stackTrace),
        records: AsyncValue.error(e, stackTrace),
      );
    }
  }

  /// Record dose with injection site rotation check
  Future<RotationCheckResult?> recordDose(DoseRecord record) async {
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

      // Reload records
      await _loadMedicationData();

      return rotationResult;
    } catch (e) {
      rethrow;
    }
  }

  /// Update dosage plan and recalculate schedules
  Future<void> updateDosagePlan(DosagePlan newPlan) async {
    try {
      final currentPlan = state.activePlan.valueOrNull;
      if (currentPlan == null) {
        throw Exception('활성 투여 계획이 없습니다.');
      }

      // Save plan change history
      await _repository.savePlanChangeHistory(
        newPlan.id,
        _planToMap(currentPlan),
        _planToMap(newPlan),
      );

      // Update plan
      await _repository.updateDosagePlan(newPlan);

      // Recalculate schedules from change date
      final existingSchedules = state.schedules.valueOrNull ?? [];
      final newSchedules = _scheduleGeneratorUseCase.recalculateSchedulesFrom(
        newPlan,
        DateTime.now(),
        DateTime.now().add(Duration(days: 365)),
        existingSchedules,
      );

      // Delete old schedules from change date and save new ones
      await _repository.deleteDoseSchedulesFrom(newPlan.id, DateTime.now());
      await _repository.saveDoseSchedules(newSchedules);

      // Reload data
      await _loadMedicationData();
    } catch (e) {
      rethrow;
    }
  }

  /// Get missed dose analysis
  MissedDoseAnalysisResult? getMissedDoseAnalysis() {
    final schedules = state.schedules.valueOrNull;
    final records = state.records.valueOrNull;

    if (schedules == null || records == null) {
      return null;
    }

    return _missedDoseAnalyzerUseCase.analyzeMissedDoses(schedules, records);
  }

  /// Delete dose record
  Future<void> deleteDoseRecord(String recordId) async {
    try {
      await _repository.deleteDoseRecord(recordId);
      await _loadMedicationData();
    } catch (e) {
      rethrow;
    }
  }

  /// Get plan change history
  Future<List<dynamic>> getPlanHistory() async {
    try {
      final plan = state.activePlan.valueOrNull;
      if (plan == null) {
        return [];
      }

      return await _repository.getPlanChangeHistory(plan.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get injection site rotation check
  Future<RotationCheckResult> checkInjectionSiteRotation(
    String newSite,
  ) async {
    try {
      final plan = state.activePlan.valueOrNull;
      if (plan == null) {
        throw Exception('활성 투여 계획이 없습니다.');
      }

      final recentRecords = await _repository.getRecentDoseRecords(
        plan.id,
        30,
      );

      return _injectionSiteRotationUseCase.checkRotation(newSite, recentRecords);
    } catch (e) {
      rethrow;
    }
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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/onboarding/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/onboarding/domain/value_objects/medication_name.dart';
import 'package:n06/features/onboarding/domain/value_objects/start_date.dart';
import 'package:n06/features/onboarding/domain/entities/escalation_step.dart';
import 'package:n06/features/onboarding/domain/usecases/calculate_weekly_goal_usecase.dart';
import 'package:n06/features/onboarding/domain/usecases/validate_dosage_plan_usecase.dart';
import 'package:n06/features/onboarding/domain/usecases/generate_dose_schedules_usecase.dart';
import 'package:n06/features/onboarding/application/providers.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;

part 'onboarding_notifier.g.dart';

/// 온보딩 상태 저장 및 데이터 저장 Notifier
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<void> build() async {}

  /// 온보딩 데이터를 저장한다.
  Future<void> saveOnboardingData({
    required String userId,
    required String name,
    required double currentWeight,
    required double targetWeight,
    int? targetPeriodWeeks,
    required String medicationName,
    required DateTime startDate,
    required int cycleDays,
    required double initialDose,
    List<EscalationStep>? escalationPlan,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userRepo = ref.read(userRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      final medicationRepo = ref.read(medicationRepositoryProvider);
      final trackingRepo = ref.read(tracking_providers.trackingRepositoryProvider);
      final scheduleRepo = ref.read(scheduleRepositoryProvider);
      final txnService = ref.read(transactionServiceProvider);

      // UseCase 인스턴스 생성
      final calculateGoalUseCase = CalculateWeeklyGoalUseCase();
      final validatePlanUseCase = ValidateDosagePlanUseCase();
      final generateSchedulesUseCase = GenerateDoseSchedulesUseCase();

      await txnService.executeInTransaction(() async {
        // 1. 검증
        final currentWeightObj = Weight.create(currentWeight);
        final targetWeightObj = Weight.create(targetWeight);
        final medicationNameObj = MedicationName.create(medicationName);
        final startDateObj = StartDate.create(startDate);

        // 증량 계획 검증
        if (escalationPlan != null) {
          final validation = validatePlanUseCase.execute(escalationPlan);
          if (!validation['isValid']) {
            throw Exception(validation['errors'].join(', '));
          }
        }

        // 2. 투여 계획 생성
        final dosagePlan = DosagePlan(
          id: const Uuid().v4(),
          userId: userId,
          medicationName: medicationNameObj,
          startDate: startDateObj,
          cycleDays: cycleDays,
          initialDoseMg: initialDose,
          escalationPlan: escalationPlan,
          isActive: true,
        );

        // 3. 사용자 프로필 생성 (주간 감량 목표 계산)
        final weeklyGoalResult = calculateGoalUseCase.execute(
          currentWeight: currentWeightObj,
          targetWeight: targetWeightObj,
          periodWeeks: targetPeriodWeeks,
        );

        final userProfile = UserProfile(
          userId: userId,
          targetWeight: targetWeightObj,
          currentWeight: currentWeightObj,
          targetPeriodWeeks: targetPeriodWeeks,
          weeklyLossGoalKg: weeklyGoalResult['weeklyGoal'] as double?,
        );

        // 4. 초기 체중 기록 생성
        final weightLog = WeightLog(
          id: const Uuid().v4(),
          userId: userId,
          logDate: DateTime.now(),
          weightKg: currentWeight,  // double 값 직접 사용 (tracking의 WeightLog 사용)
          createdAt: DateTime.now(),
        );

        // 5. 모든 데이터 저장
        await userRepo.updateUserName(userId, name);
        await profileRepo.saveUserProfile(userProfile);
        await medicationRepo.saveDosagePlan(dosagePlan);
        await trackingRepo.saveWeightLog(weightLog);

        // 6. 투여 스케줄 생성 및 저장
        final schedules = generateSchedulesUseCase.execute(dosagePlan);
        await scheduleRepo.saveAll(schedules);
      });
    });
  }

  /// 저장을 재시도한다.
  Future<void> retrySave({
    required String userId,
    required String name,
    required double currentWeight,
    required double targetWeight,
    int? targetPeriodWeeks,
    required String medicationName,
    required DateTime startDate,
    required int cycleDays,
    required double initialDose,
    List<EscalationStep>? escalationPlan,
  }) async {
    await saveOnboardingData(
      userId: userId,
      name: name,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      targetPeriodWeeks: targetPeriodWeeks,
      medicationName: medicationName,
      startDate: startDate,
      cycleDays: cycleDays,
      initialDose: initialDose,
      escalationPlan: escalationPlan,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/onboarding/domain/usecases/calculate_weekly_goal_usecase.dart';
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
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (kDebugMode) {
        debugPrint('🎯 [1/4] Onboarding: Start');
      }

      final userRepo = ref.read(userRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      final medicationRepo = ref.read(medicationRepositoryProvider);
      final trackingRepo = ref.read(tracking_providers.trackingRepositoryProvider);
      final scheduleRepo = ref.read(scheduleRepositoryProvider);

      // UseCase 인스턴스 생성
      final calculateGoalUseCase = CalculateWeeklyGoalUseCase();
      final generateSchedulesUseCase = GenerateDoseSchedulesUseCase();

      // Note: Supabase handles transactions at the database level.
      // Each repository operation is atomic. For multi-step operations,
      // we rely on proper error handling and potential rollback logic.
      try {
        // 1. 검증
        final currentWeightObj = Weight.create(currentWeight);
        final targetWeightObj = Weight.create(targetWeight);

        // 2. 투여 계획 생성 (escalationPlan은 null - 용량은 처방을 통해 수동 변경)
        final dosagePlan = DosagePlan(
          id: const Uuid().v4(),
          userId: userId,
          medicationName: medicationName,
          startDate: startDate,
          cycleDays: cycleDays,
          initialDoseMg: initialDose,
          escalationPlan: null,
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
          userName: name,
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

        if (kDebugMode) {
          debugPrint('🎯 [2/4] Onboarding: DosagePlan & Profile created');
        }

        // 6. 투여 스케줄 생성 및 저장
        final schedules = generateSchedulesUseCase.execute(dosagePlan);
        if (kDebugMode) {
          debugPrint('🎯 [3/4] Onboarding: ${schedules.length} schedules generated');
        }

        try {
          await scheduleRepo.saveAll(schedules);
          if (kDebugMode) {
            debugPrint('🎯 [4/4] Onboarding: Complete ✅');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ [ERROR] Schedule save failed at step 4/4');
            debugPrint('📊 Debug Info:');
            debugPrint('  - Total schedules: ${schedules.length}');
            for (int i = 0; i < (schedules.length > 2 ? 2 : schedules.length); i++) {
              final s = schedules[i];
              debugPrint('  Schedule[$i]: date=${s.scheduledDate}, dose=${s.scheduledDoseMg}mg, notification=${s.notificationTime}');
            }
          }
          rethrow;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [ERROR] Onboarding save failed: $e');
        }
        rethrow;
      }
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
    );
  }
}


// Backwards compatibility alias
const onboardingNotifierProvider = onboardingProvider;

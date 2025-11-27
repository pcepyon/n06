import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/dashboard/application/notifiers/dashboard_notifier.dart';
import 'package:n06/features/dashboard/application/providers.dart';
import 'package:n06/features/dashboard/domain/repositories/badge_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart'
    as onboarding_medication_repo;
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart'
    as tracking_medication_repo;
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/onboarding/application/providers.dart'
    as onboarding_providers;
import 'package:n06/features/tracking/application/providers.dart'
    as tracking_providers;

// Mock classes
class MockProfileRepository extends Mock implements ProfileRepository {}

class MockOnboardingMedicationRepository extends Mock
    implements onboarding_medication_repo.MedicationRepository {}

class MockTrackingMedicationRepository extends Mock
    implements tracking_medication_repo.MedicationRepository {}

class MockTrackingRepository extends Mock implements TrackingRepository {}

class MockBadgeRepository extends Mock implements BadgeRepository {}

// Fake AuthNotifier for testing
class FakeAuthNotifier extends AuthNotifier {
  final User? _user;
  FakeAuthNotifier(this._user);

  @override
  Future<User?> build() async => _user;
}

void main() {
  group('DashboardNotifier - DoseRecord 조회 테스트', () {
    late MockProfileRepository mockProfileRepository;
    late MockOnboardingMedicationRepository mockOnboardingMedicationRepository;
    late MockTrackingMedicationRepository mockTrackingMedicationRepository;
    late MockTrackingRepository mockTrackingRepository;
    late MockBadgeRepository mockBadgeRepository;
    late ProviderContainer container;

    final testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      name: 'Test User',
      oauthProvider: 'test',
      oauthUserId: 'test-oauth-id',
      lastLoginAt: DateTime.now(),
    );

    final testProfile = UserProfile(
      userId: 'test-user-id',
      userName: 'Test User',
      targetWeight: Weight.create(70.0),
      currentWeight: Weight.create(85.0),
      weeklyWeightRecordGoal: 2,
      weeklySymptomRecordGoal: 3,
    );

    final testDosagePlan = DosagePlan(
      id: 'test-plan-id',
      userId: 'test-user-id',
      medicationName: 'Test Medication',
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      cycleDays: 7,
      initialDoseMg: 0.25,
    );

    final testDoseRecords = [
      DoseRecord(
        id: 'record-1',
        dosagePlanId: 'test-plan-id',
        administeredAt: DateTime.now().subtract(const Duration(days: 2)),
        actualDoseMg: 0.25,
        isCompleted: true,
      ),
      DoseRecord(
        id: 'record-2',
        dosagePlanId: 'test-plan-id',
        administeredAt: DateTime.now().subtract(const Duration(days: 5)),
        actualDoseMg: 0.25,
        isCompleted: true,
      ),
    ];

    setUp(() {
      mockProfileRepository = MockProfileRepository();
      mockOnboardingMedicationRepository = MockOnboardingMedicationRepository();
      mockTrackingMedicationRepository = MockTrackingMedicationRepository();
      mockTrackingRepository = MockTrackingRepository();
      mockBadgeRepository = MockBadgeRepository();

      // Default mock setup
      when(() => mockProfileRepository.getUserProfile(any()))
          .thenAnswer((_) async => testProfile);
      when(() => mockOnboardingMedicationRepository.getActiveDosagePlan(any()))
          .thenAnswer((_) async => testDosagePlan);
      when(() => mockTrackingMedicationRepository.getDoseRecords(any()))
          .thenAnswer((_) async => testDoseRecords);
      when(() => mockTrackingRepository.getWeightLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockTrackingRepository.getSymptomLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockBadgeRepository.getUserBadges(any()))
          .thenAnswer((_) async => []);

      container = ProviderContainer(
        overrides: [
          onboarding_providers.profileRepositoryProvider
              .overrideWithValue(mockProfileRepository),
          onboarding_providers.medicationRepositoryProvider
              .overrideWithValue(mockOnboardingMedicationRepository),
          tracking_providers.medicationRepositoryProvider
              .overrideWithValue(mockTrackingMedicationRepository),
          tracking_providers.trackingRepositoryProvider
              .overrideWithValue(mockTrackingRepository),
          badgeRepositoryProvider.overrideWithValue(mockBadgeRepository),
          authNotifierProvider.overrideWith(() => FakeAuthNotifier(testUser)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    // RED TEST 1: DoseRecord가 조회되어야 함 (수정 후 통과해야 함)
    test('대시보드 로딩 시 tracking.MedicationRepository.getDoseRecords()를 호출해야 함', () async {
      // When: Dashboard 로드 (listen을 사용하여 provider가 dispose되지 않도록)
      final listener = container.listen(dashboardProvider, (previous, next) {});

      await Future.delayed(const Duration(milliseconds: 100));

      // Then: tracking.MedicationRepository.getDoseRecords가 호출되어야 함
      verify(() => mockTrackingMedicationRepository
          .getDoseRecords(testDosagePlan.id)).called(1);

      listener.close();
    });

    // RED TEST 2: doseCompletedCount가 실제 값을 반영해야 함 (수정 후 통과해야 함)
    test('주간 요약의 doseCompletedCount가 실제 DoseRecord 개수를 반영해야 함', () async {
      // When: Dashboard 로드
      final listener = container.listen(dashboardProvider, (previous, next) {});

      await Future.delayed(const Duration(milliseconds: 100));
      final state = container.read(dashboardProvider);

      // Then: weeklySummary.doseCompletedCount가 최근 7일 이내 기록 개수여야 함
      // testDoseRecords: record-1 (2일 전), record-2 (5일 전) → 2개 모두 최근 7일 이내
      state.whenData((dashboardData) {
        expect(dashboardData.weeklySummary.doseCompletedCount, greaterThan(0),
            reason: '최근 7일 이내 DoseRecord가 존재하므로 0보다 커야 함');
      });

      listener.close();
    });
  });
}

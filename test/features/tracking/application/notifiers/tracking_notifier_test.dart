import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/providers.dart';

// Mock classes
class MockTrackingRepository extends Mock implements TrackingRepository {}

class MockGoRouter extends Mock implements GoRouter {}

// Fake AuthNotifier for testing
class FakeAuthNotifier extends AuthNotifier {
  final User? _user;
  FakeAuthNotifier(this._user);

  @override
  Future<User?> build() async => _user;
}

void main() {
  // Mocktail fallback values
  setUpAll(() {
    registerFallbackValue(
      WeightLog(
        id: 'fallback',
        userId: 'fallback',
        logDate: DateTime.now(),
        weightKg: 0,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      SymptomLog(
        id: 'fallback',
        userId: 'fallback',
        logDate: DateTime.now(),
        symptomName: 'fallback',
        severity: 1,
        createdAt: DateTime.now(),
      ),
    );
  });

  group('TrackingNotifier - saveDailyLog', () {
    late MockTrackingRepository mockRepository;
    late MockGoRouter mockRouter;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockTrackingRepository();
      mockRouter = MockGoRouter();

      // Default mock setup
      when(() => mockRepository.saveWeightLog(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveSymptomLog(any()))
          .thenAnswer((_) async {});
      when(() => mockRepository.getWeightLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getSymptomLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockRouter.go(any())).thenReturn(null);

      final user = User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
        oauthProvider: 'test',
        oauthUserId: 'test-oauth-id',
        lastLoginAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          trackingRepositoryProvider.overrideWithValue(mockRepository),
          goRouterProvider.overrideWithValue(mockRouter),
          authProvider.overrideWith(() => FakeAuthNotifier(user)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    // RED TEST 1: saveDailyLog should NOT navigate to dashboard
    test('saveDailyLog should NOT navigate to dashboard', () async {
      // Given: weightLog + symptomLogs
      final weightLog = WeightLog(
        id: 'test-weight-id',
        userId: 'test-user-id',
        logDate: DateTime.now(),
        weightKg: 75.5,
        appetiteScore: 4,
        createdAt: DateTime.now(),
      );

      final symptomLogs = [
        SymptomLog(
          id: 'test-symptom-id',
          userId: 'test-user-id',
          logDate: DateTime.now(),
          symptomName: '메스꺼움',
          severity: 7,
          isPersistent24h: true,
          createdAt: DateTime.now(),
        ),
      ];

      // When: saveDailyLog 호출
      await container.read(trackingProvider.notifier).saveDailyLog(
            weightLog: weightLog,
            symptomLogs: symptomLogs,
          );

      // Then: goRouterProvider 사용하지 않아야 함 (네비게이션 없음)
      verifyNever(() => mockRouter.go(any()));
    });

    // RED TEST 2: saveDailyLog should save weight and symptoms successfully
    test('saveDailyLog should save weight and symptoms successfully',
        () async {
      // Given: weightLog + symptomLogs
      final weightLog = WeightLog(
        id: 'test-weight-id',
        userId: 'test-user-id',
        logDate: DateTime.now(),
        weightKg: 75.5,
        appetiteScore: 4,
        createdAt: DateTime.now(),
      );

      final symptomLogs = [
        SymptomLog(
          id: 'test-symptom-1',
          userId: 'test-user-id',
          logDate: DateTime.now(),
          symptomName: '메스꺼움',
          severity: 7,
          isPersistent24h: true,
          createdAt: DateTime.now(),
        ),
        SymptomLog(
          id: 'test-symptom-2',
          userId: 'test-user-id',
          logDate: DateTime.now(),
          symptomName: '두통',
          severity: 5,
          createdAt: DateTime.now(),
        ),
      ];

      // When: saveDailyLog 호출
      await container.read(trackingProvider.notifier).saveDailyLog(
            weightLog: weightLog,
            symptomLogs: symptomLogs,
          );

      // Then: repository.saveWeightLog 호출됨
      verify(() => mockRepository.saveWeightLog(any(
            that: predicate<WeightLog>(
              (log) => log.id == 'test-weight-id' && log.weightKg == 75.5,
            ),
          ))).called(1);

      // And: repository.saveSymptomLog이 각 증상마다 호출됨
      verify(() => mockRepository.saveSymptomLog(any())).called(2);

      // And: state가 AsyncValue.data로 업데이트됨
      final state = container.read(trackingProvider);
      expect(state.hasValue, isTrue);
    });
  });
}

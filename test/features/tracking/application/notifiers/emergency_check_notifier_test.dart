import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/domain/repositories/emergency_check_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

class MockEmergencyCheckRepository extends Mock
    implements EmergencyCheckRepository {}

class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  group('EmergencyCheckNotifier', () {
    late MockEmergencyCheckRepository mockEmergencyCheckRepository;
    late MockTrackingRepository mockTrackingRepository;
    late ProviderContainer container;

    setUp(() {
      mockEmergencyCheckRepository = MockEmergencyCheckRepository();
      mockTrackingRepository = MockTrackingRepository();
    });

    test('초기 상태는 loading', () async {
      // Arrange
      when(() => mockEmergencyCheckRepository.getEmergencyChecks(any()))
          .thenAnswer((_) async => []);

      container = ProviderContainer(
        overrides: [
          emergencyCheckRepositoryProvider
              .overrideWithValue(mockEmergencyCheckRepository),
        ],
      );

      // Act
      final state = container.read(emergencyCheckNotifierProvider);

      // Assert
      expect(state, isA<AsyncLoading>());
    });

    test('증상 체크 저장 성공 시, 상태 갱신', () async {
      // Arrange
      final check = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: ['증상1'],
      );

      when(() => mockEmergencyCheckRepository.saveEmergencyCheck(check))
          .thenAnswer((_) async => {});
      when(() => mockTrackingRepository.saveSymptomLog(any()))
          .thenAnswer((_) async => {});
      when(() => mockEmergencyCheckRepository.getEmergencyChecks('user-123'))
          .thenAnswer((_) async => [check]);

      container = ProviderContainer(
        overrides: [
          emergencyCheckRepositoryProvider
              .overrideWithValue(mockEmergencyCheckRepository),
          trackingRepositoryProvider.overrideWithValue(mockTrackingRepository),
        ],
      );

      // Act
      final notifier = container.read(emergencyCheckNotifierProvider.notifier);
      await notifier.saveEmergencyCheck('user-123', check);

      // Assert
      verify(() => mockEmergencyCheckRepository.saveEmergencyCheck(check))
          .called(1);
    });
  });
}

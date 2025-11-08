import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/domain/repositories/emergency_check_repository.dart';

class MockEmergencyCheckRepository extends Mock
    implements EmergencyCheckRepository {}

void main() {
  group('EmergencyCheckRepository Interface', () {
    late MockEmergencyCheckRepository mockRepository;

    setUp(() {
      mockRepository = MockEmergencyCheckRepository();
    });

    test('saveEmergencyCheck 호출 시, Future<void> 반환', () async {
      // Arrange
      final check = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: ['증상1'],
      );
      when(() => mockRepository.saveEmergencyCheck(check))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.saveEmergencyCheck(check);

      // Assert
      verify(() => mockRepository.saveEmergencyCheck(check)).called(1);
    });

    test('getEmergencyChecks 호출 시, List<EmergencySymptomCheck> 반환', () async {
      // Arrange
      final checks = [
        EmergencySymptomCheck(
          id: '1',
          userId: 'user-123',
          checkedAt: DateTime.now(),
          checkedSymptoms: ['증상1'],
        ),
      ];
      when(() => mockRepository.getEmergencyChecks('user-123'))
          .thenAnswer((_) async => checks);

      // Act
      final result = await mockRepository.getEmergencyChecks('user-123');

      // Assert
      expect(result, checks);
      verify(() => mockRepository.getEmergencyChecks('user-123')).called(1);
    });

    test('deleteEmergencyCheck 호출 시, Future<void> 반환', () async {
      // Arrange
      when(() => mockRepository.deleteEmergencyCheck('test-id'))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.deleteEmergencyCheck('test-id');

      // Assert
      verify(() => mockRepository.deleteEmergencyCheck('test-id')).called(1);
    });

    test('updateEmergencyCheck 호출 시, Future<void> 반환', () async {
      // Arrange
      final check = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: ['증상1'],
      );
      when(() => mockRepository.updateEmergencyCheck(check))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.updateEmergencyCheck(check);

      // Assert
      verify(() => mockRepository.updateEmergencyCheck(check)).called(1);
    });
  });
}

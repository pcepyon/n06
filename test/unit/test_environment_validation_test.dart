import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../fakes/fake_medication_repository.dart';
import '../helpers/test_async_utils.dart';
import '../helpers/test_data_builders.dart';

/// Test environment validation
///
/// This test suite validates that the test environment is properly set up:
/// - mocktail for mocking
/// - fake_async for time-based testing
/// - fake repositories for in-memory testing
/// - test data builders for easy test data creation

void main() {
  group('Test Environment Validation', () {
    group('mocktail', () {
      test('should create and use mocks', () {
        // Arrange
        final mock = MockTestInterface();
        when(() => mock.getValue()).thenReturn('mocked value');

        // Act
        final result = mock.getValue();

        // Assert
        expect(result, 'mocked value');
        verify(() => mock.getValue()).called(1);
      });

      test('should verify mock interactions', () {
        // Arrange
        final mock = MockTestInterface();
        when(() => mock.asyncOperation()).thenAnswer((_) async => 42);

        // Act
        mock.asyncOperation();

        // Assert
        verify(() => mock.asyncOperation()).called(1);
        verifyNoMoreInteractions(mock);
      });
    });

    group('fake_async', () {
      test('should control time with fake async', () {
        fakeAsync((async) {
          // Arrange
          var completed = false;
          Future.delayed(const Duration(seconds: 1), () {
            completed = true;
          });

          // Act - no time has passed
          expect(completed, false);

          // Act - elapse 1 second
          async.elapse(const Duration(seconds: 1));

          // Assert
          expect(completed, true);
        });
      });

      test('should test periodic operations', () {
        fakeAsync((async) {
          // Arrange
          var counter = 0;
          Timer.periodic(const Duration(seconds: 1), (timer) {
            counter++;
            if (counter >= 3) timer.cancel();
          });

          // Act & Assert
          expect(counter, 0);

          async.elapse(const Duration(seconds: 1));
          expect(counter, 1);

          async.elapse(const Duration(seconds: 1));
          expect(counter, 2);

          async.elapse(const Duration(seconds: 1));
          expect(counter, 3);
        });
      });
    });

    group('Fake Repository', () {
      late FakeMedicationRepository repository;

      setUp(() {
        repository = FakeMedicationRepository();
      });

      tearDown(() {
        repository.dispose();
      });

      test('should save and retrieve data', () async {
        // Arrange
        final dose = DoseBuilder()
            .withId(1)
            .withDoseMg(0.25)
            .withAdministeredAt(DateTime(2024, 1, 1))
            .build();

        // Act
        await repository.saveDose(dose);
        final doses = await repository.getDoses();

        // Assert
        expect(doses, hasLength(1));
        expect(doses.first['doseMg'], 0.25);
      });

      test('should emit stream updates', () async {
        // Arrange
        final dose1 = DoseBuilder().withId(1).withDoseMg(0.25).build();

        // Act
        await repository.saveDose(dose1);

        // Assert - verify data was saved
        final doses = await repository.getDoses();
        expect(doses, hasLength(1));
        expect(doses.first['doseMg'], 0.25);

        // Note: Stream testing will be validated with actual domain entities
        // when the domain layer is implemented
      }, skip: 'Stream functionality will be tested with actual domain layer');

      test('should simulate errors', () async {
        // Arrange
        repository.throwOnNextOperation(Exception('Test error'));
        final dose = DoseBuilder().build();

        // Act & Assert
        expect(
          () => repository.saveDose(dose),
          throwsA(isA<Exception>()),
        );
      });

      test('should support operation delays', () async {
        // Arrange
        repository.enableDelays(delay: const Duration(milliseconds: 100));
        final dose = DoseBuilder().build();

        // Act
        final startTime = DateTime.now();
        await repository.saveDose(dose);
        final endTime = DateTime.now();

        // Assert
        final elapsed = endTime.difference(startTime);
        expect(elapsed.inMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('Test Data Builders', () {
      test('should build user data', () {
        // Arrange & Act
        final user = UserBuilder()
            .withId('user123')
            .withName('Test User')
            .withEmail('test@example.com')
            .build();

        // Assert
        expect(user['id'], 'user123');
        expect(user['name'], 'Test User');
        expect(user['email'], 'test@example.com');
      });

      test('should build dose data', () {
        // Arrange & Act
        final dose = DoseBuilder()
            .withDoseMg(0.5)
            .withInjectionSite('복부')
            .withNote('아침 투여')
            .build();

        // Assert
        expect(dose['doseMg'], 0.5);
        expect(dose['injectionSite'], '복부');
        expect(dose['note'], '아침 투여');
      });

      test('should build weight log data', () {
        // Arrange & Act
        final weightLog = WeightLogBuilder()
            .withWeightKg(72.5)
            .withLogDate(DateTime(2024, 1, 15))
            .build();

        // Assert
        expect(weightLog['weightKg'], 72.5);
        expect(weightLog['logDate'], DateTime(2024, 1, 15).toIso8601String());
      });

      test('should build symptom log data', () {
        // Arrange & Act
        final symptomLog = SymptomLogBuilder()
            .withSymptomName('메스꺼움')
            .withSeverity(7)
            .withContextTags(['기름진음식', '공복'])
            .build();

        // Assert
        expect(symptomLog['symptomName'], '메스꺼움');
        expect(symptomLog['severity'], 7);
        expect(symptomLog['contextTags'], ['기름진음식', '공복']);
      });

      test('should build dosage plan data', () {
        // Arrange & Act
        final plan = DosagePlanBuilder()
            .withMedicationName('Ozempic')
            .withInitialDoseMg(0.25)
            .withCycleDays(7)
            .withEscalationPlan([
              {'weeks': 4, 'doseMg': 0.5},
              {'weeks': 8, 'doseMg': 1.0},
            ])
            .build();

        // Assert
        expect(plan['medicationName'], 'Ozempic');
        expect(plan['initialDoseMg'], 0.25);
        expect(plan['cycleDays'], 7);
        expect(plan['escalationPlan'], hasLength(2));
      });
    });

    group('Test Async Utils', () {
      test('should wait for stream value', () async {
        // Arrange
        final controller = StreamController<int>();
        final stream = controller.stream;

        // Act
        Future.delayed(const Duration(milliseconds: 100), () {
          controller.add(42);
        });

        final result = await waitForStreamValue(
          stream,
          condition: (value) => value == 42,
        );

        // Assert
        expect(result, 42);
        await controller.close();
      });

      test('should retry with backoff', () async {
        // Arrange
        var attempts = 0;

        Future<int> operation() async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Retry');
          }
          return 42;
        }

        // Act
        final result = await retryWithBackoff(
          operation,
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
        );

        // Assert
        expect(result, 42);
        expect(attempts, 3);
      });
    });
  });
}

// Mock classes for testing
class MockTestInterface extends Mock implements TestInterface {}

abstract class TestInterface {
  String getValue();
  Future<int> asyncOperation();
}

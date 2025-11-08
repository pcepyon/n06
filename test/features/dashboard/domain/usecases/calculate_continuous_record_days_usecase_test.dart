import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/dashboard/domain/usecases/calculate_continuous_record_days_usecase.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

void main() {
  group('CalculateContinuousRecordDaysUseCase', () {
    late CalculateContinuousRecordDaysUseCase useCase;

    setUp(() {
      useCase = CalculateContinuousRecordDaysUseCase();
    });

    test('should return 0 when no records exist', () {
      final result = useCase.execute([], []);
      expect(result, 0);
    });

    test('should return 1 when only today has record', () {
      final today = DateTime.now();
      final weights = [
        WeightLog(
          id: '1',
          userId: 'user1',
          logDate: today,
          weightKg: 70.0,
          createdAt: today,
        ),
      ];

      final result = useCase.execute(weights, []);
      expect(result, 1);
    });

    test('should return 7 when continuous 7 days record exist', () {
      final today = DateTime.now();
      final weights = List.generate(
        7,
        (i) => WeightLog(
          id: '$i',
          userId: 'user1',
          logDate: today.subtract(Duration(days: i)),
          weightKg: 70.0 - i,
          createdAt: today,
        ),
      );

      final result = useCase.execute(weights, []);
      expect(result, 7);
    });

    test('should reset to 0 when gap exists in records', () {
      final today = DateTime.now();
      final weights = [
        WeightLog(
          id: '1',
          userId: 'user1',
          logDate: today,
          weightKg: 70.0,
          createdAt: today,
        ),
        WeightLog(
          id: '2',
          userId: 'user1',
          logDate: today.subtract(Duration(days: 2)),
          weightKg: 71.0,
          createdAt: today,
        ),
      ];

      final result = useCase.execute(weights, []);
      expect(result, 1);
    });

    test('should handle mixed weight and symptom logs', () {
      final today = DateTime.now();
      final weights = [
        WeightLog(
          id: '1',
          userId: 'user1',
          logDate: today,
          weightKg: 70.0,
          createdAt: today,
        ),
        WeightLog(
          id: '2',
          userId: 'user1',
          logDate: today.subtract(Duration(days: 2)),
          weightKg: 71.0,
          createdAt: today,
        ),
      ];

      final symptoms = [
        SymptomLog(
          id: '3',
          userId: 'user1',
          logDate: today.subtract(Duration(days: 1)),
          symptomName: '메스꺼움',
          severity: 5,
        ),
      ];

      final result = useCase.execute(weights, symptoms);
      // Should have: today (weight), yesterday (symptom), day-2 (weight) = 3 consecutive days
      expect(result, 3);
    });

    test('should handle duplicate logs on same date', () {
      final today = DateTime.now();
      final weights = [
        WeightLog(
          id: '1',
          userId: 'user1',
          logDate: today,
          weightKg: 70.0,
          createdAt: today,
        ),
        WeightLog(
          id: '2',
          userId: 'user1',
          logDate: today,
          weightKg: 71.0,
          createdAt: today,
        ),
      ];

      final result = useCase.execute(weights, []);
      expect(result, 1);
    });
  });
}

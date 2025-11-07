import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';

void main() {
  group('WeightLog Entity', () {
    // TC-WL-01: 정상 생성
    test('should create WeightLog with valid data', () {
      // Arrange
      final id = 'wl-001';
      final userId = 'user-001';
      final logDate = DateTime(2025, 11, 7);
      final weightKg = 75.5;
      final createdAt = DateTime.now();

      // Act
      final weightLog = WeightLog(
        id: id,
        userId: userId,
        logDate: logDate,
        weightKg: weightKg,
        createdAt: createdAt,
      );

      // Assert
      expect(weightLog.id, id);
      expect(weightLog.userId, userId);
      expect(weightLog.logDate, logDate);
      expect(weightLog.weightKg, weightKg);
      expect(weightLog.createdAt, createdAt);
    });

    // TC-WL-02: copyWith 정상 동작
    test('should copy WeightLog with updated weightKg', () {
      // Arrange
      final original = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );

      // Act
      final updated = original.copyWith(weightKg: 74.8);

      // Assert
      expect(updated.weightKg, 74.8);
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
      expect(updated.logDate, original.logDate);
      expect(updated.createdAt, original.createdAt);
    });

    // TC-WL-03: Equality 비교
    test('should compare two WeightLog entities correctly', () {
      // Arrange
      final now = DateTime.now();
      final log1 = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: now,
      );
      final log2 = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: now,
      );

      // Act & Assert
      expect(log1 == log2, isTrue);
    });

    // TC-WL-04: toString 메서드 존재
    test('should have toString method', () {
      // Arrange
      final log = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );

      // Act
      final str = log.toString();

      // Assert
      expect(str, isNotEmpty);
      expect(str, contains('WeightLog'));
    });
  });
}

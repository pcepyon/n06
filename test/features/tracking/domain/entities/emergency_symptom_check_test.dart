import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';

void main() {
  group('EmergencySymptomCheck Entity', () {
    test('주어진 필수 필드로 생성 시, 올바른 인스턴스 반환', () {
      // Arrange
      final id = 'test-id';
      final userId = 'user-123';
      final checkedAt = DateTime(2025, 1, 1, 10, 0);
      final symptoms = ['24시간 이상 계속 구토'];

      // Act
      final entity = EmergencySymptomCheck(
        id: id,
        userId: userId,
        checkedAt: checkedAt,
        checkedSymptoms: symptoms,
      );

      // Assert
      expect(entity.id, id);
      expect(entity.userId, userId);
      expect(entity.checkedAt, checkedAt);
      expect(entity.checkedSymptoms, symptoms);
    });

    test('여러 증상 선택 시, 모든 증상 포함', () {
      // Arrange
      final symptoms = [
        '24시간 이상 계속 구토',
        '물이나 음식을 전혀 삼킬 수 없어요'
      ];

      // Act
      final entity = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: symptoms,
      );

      // Assert
      expect(entity.checkedSymptoms.length, 2);
      expect(entity.checkedSymptoms, containsAll(symptoms));
    });

    test('빈 증상 리스트로 생성 시, 예외 발생하지 않음', () {
      // Arrange & Act
      final entity = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: [],
      );

      // Assert
      expect(entity.checkedSymptoms, isEmpty);
    });

    test('동일한 필드로 생성된 두 인스턴스는 동등', () {
      // Arrange
      final id = 'test-id';
      final userId = 'user-123';
      final checkedAt = DateTime(2025, 1, 1);
      final symptoms = ['24시간 이상 계속 구토'];

      // Act
      final entity1 = EmergencySymptomCheck(
        id: id,
        userId: userId,
        checkedAt: checkedAt,
        checkedSymptoms: symptoms,
      );
      final entity2 = EmergencySymptomCheck(
        id: id,
        userId: userId,
        checkedAt: checkedAt,
        checkedSymptoms: symptoms,
      );

      // Assert
      expect(entity1, equals(entity2));
      expect(entity1.hashCode, equals(entity2.hashCode));
    });

    test('copyWith 메서드로 필드 수정 시, 새로운 인스턴스 생성', () {
      // Arrange
      final original = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1),
        checkedSymptoms: ['증상1'],
      );

      // Act
      final updated = original.copyWith(
        checkedSymptoms: ['증상1', '증상2'],
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
      expect(updated.checkedAt, original.checkedAt);
      expect(updated.checkedSymptoms.length, 2);
      expect(original.checkedSymptoms.length, 1);
    });
  });
}

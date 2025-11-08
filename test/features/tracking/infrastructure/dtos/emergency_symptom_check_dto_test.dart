import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/infrastructure/dtos/emergency_symptom_check_dto.dart';

void main() {
  group('EmergencySymptomCheckDto', () {
    test('Entity를 DTO로 변환 시, 모든 필드 매핑', () {
      // Arrange
      final entity = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1, 10, 0),
        checkedSymptoms: ['증상1', '증상2'],
      );

      // Act
      final dto = EmergencySymptomCheckDto.fromEntity(entity);

      // Assert
      expect(dto.userId, entity.userId);
      expect(dto.checkedAt, entity.checkedAt);
      expect(dto.checkedSymptoms, entity.checkedSymptoms);
    });

    test('DTO를 Entity로 변환 시, 모든 필드 매핑', () {
      // Arrange
      final dto = EmergencySymptomCheckDto()
        ..id = 1
        ..userId = 'user-123'
        ..checkedAt = DateTime(2025, 1, 1, 10, 0)
        ..checkedSymptoms = ['증상1'];

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.id, dto.id.toString());
      expect(entity.userId, dto.userId);
      expect(entity.checkedAt, dto.checkedAt);
      expect(entity.checkedSymptoms, dto.checkedSymptoms);
    });

    test('빈 증상 리스트 변환 시, 빈 리스트 유지', () {
      // Arrange
      final entity = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: [],
      );

      // Act
      final dto = EmergencySymptomCheckDto.fromEntity(entity);
      final convertedEntity = dto.toEntity();

      // Assert
      expect(convertedEntity.checkedSymptoms, isEmpty);
    });

    test('여러 증상 변환 시, 순서 유지', () {
      // Arrange
      final symptoms = ['증상1', '증상2', '증상3'];
      final entity = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: symptoms,
      );

      // Act
      final dto = EmergencySymptomCheckDto.fromEntity(entity);
      final convertedEntity = dto.toEntity();

      // Assert
      expect(convertedEntity.checkedSymptoms, orderedEquals(symptoms));
    });
  });
}

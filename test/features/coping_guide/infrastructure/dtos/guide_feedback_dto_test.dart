import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/domain/entities/guide_feedback.dart';
import 'package:n06/features/coping_guide/infrastructure/dtos/guide_feedback_dto.dart';

void main() {
  group('GuideFeedbackDto', () {
    test('Entity에서 DTO로 변환', () {
      // Arrange
      final entity = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: DateTime(2025, 1, 1),
      );

      // Act
      final dto = GuideFeedbackDto.fromEntity(entity);

      // Assert
      expect(dto.symptomName, entity.symptomName);
      expect(dto.helpful, entity.helpful);
      expect(dto.timestamp, entity.timestamp);
    });

    test('DTO에서 Entity로 변환', () {
      // Arrange
      final timestamp = DateTime(2025, 1, 1);
      final dto = GuideFeedbackDto()
        ..symptomName = '메스꺼움'
        ..helpful = true
        ..timestamp = timestamp;

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.symptomName, dto.symptomName);
      expect(entity.helpful, dto.helpful);
      expect(entity.timestamp, dto.timestamp);
    });

    test('양방향 변환 후 원래 값 유지', () {
      // Arrange
      final originalEntity = GuideFeedback(
        symptomName: '구토',
        helpful: false,
        timestamp: DateTime(2025, 1, 2),
      );

      // Act
      final dto = GuideFeedbackDto.fromEntity(originalEntity);
      final reconstructedEntity = dto.toEntity();

      // Assert
      expect(reconstructedEntity.symptomName, originalEntity.symptomName);
      expect(reconstructedEntity.helpful, originalEntity.helpful);
      expect(reconstructedEntity.timestamp, originalEntity.timestamp);
    });
  });
}

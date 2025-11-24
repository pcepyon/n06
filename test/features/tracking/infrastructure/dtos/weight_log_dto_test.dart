import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';

void main() {
  group('WeightLogDto', () {
    // TC-WLD-01: JSON to DTO conversion (with appetiteScore)
    test('should convert from JSON with appetiteScore', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'log_date': '2025-01-01',
        'weight_kg': 75.5,
        'appetite_score': 3,
        'created_at': '2025-01-01T10:00:00Z',
      };

      // Act
      final dto = WeightLogDto.fromJson(json);

      // Assert
      expect(dto.id, 'test-id');
      expect(dto.userId, 'user-1');
      expect(dto.weightKg, 75.5);
      expect(dto.appetiteScore, 3);
    });

    // TC-WLD-02: JSON to DTO conversion (without appetiteScore)
    test('should convert from JSON with null appetiteScore', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'log_date': '2025-01-01',
        'weight_kg': 75.5,
        'appetite_score': null,
        'created_at': '2025-01-01T10:00:00Z',
      };

      // Act
      final dto = WeightLogDto.fromJson(json);

      // Assert
      expect(dto.appetiteScore, isNull);
    });

    // TC-WLD-03: DTO to JSON conversion (with appetiteScore)
    test('should convert to JSON with appetiteScore', () {
      // Arrange
      final dto = WeightLogDto(
        id: 'test-id',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        weightKg: 75.5,
        appetiteScore: 4,
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      );

      // Act
      final json = dto.toJson();

      // Assert
      expect(json['appetite_score'], 4);
      expect(json['weight_kg'], 75.5);
    });

    // TC-WLD-04: DTO to JSON conversion (without appetiteScore)
    test('should convert to JSON with null appetiteScore', () {
      // Arrange
      final dto = WeightLogDto(
        id: 'test-id',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        weightKg: 75.5,
        appetiteScore: null,
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      );

      // Act
      final json = dto.toJson();

      // Assert
      expect(json['appetite_score'], isNull);
    });

    // TC-WLD-05: DTO to Entity conversion (with appetiteScore)
    test('should convert DTO to Entity with appetiteScore', () {
      // Arrange
      final dto = WeightLogDto(
        id: 'test-id',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        weightKg: 75.5,
        appetiteScore: 5,
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      );

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity, isA<WeightLog>());
      expect(entity.appetiteScore, 5);
      expect(entity.weightKg, 75.5);
    });

    // TC-WLD-06: Entity to DTO conversion (with appetiteScore)
    test('should convert Entity to DTO with appetiteScore', () {
      // Arrange
      final entity = WeightLog(
        id: 'test-id',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        weightKg: 75.5,
        appetiteScore: 2,
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      );

      // Act
      final dto = WeightLogDto.fromEntity(entity);

      // Assert
      expect(dto.appetiteScore, 2);
      expect(dto.weightKg, 75.5);
    });

    // TC-WLD-07: Entity to DTO conversion (null appetiteScore)
    test('should convert Entity to DTO with null appetiteScore', () {
      // Arrange
      final entity = WeightLog(
        id: 'test-id',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        weightKg: 75.5,
        appetiteScore: null,
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      );

      // Act
      final dto = WeightLogDto.fromEntity(entity);

      // Assert
      expect(dto.appetiteScore, isNull);
    });

    // TC-WLD-08: Round-trip conversion (JSON → DTO → Entity → DTO → JSON)
    test('should maintain data integrity through round-trip conversion', () {
      // Arrange
      final originalJson = {
        'id': 'test-id',
        'user_id': 'user-1',
        'log_date': '2025-01-01',
        'weight_kg': 75.5,
        'appetite_score': 3,
        'created_at': '2025-01-01T10:00:00Z',
      };

      // Act
      final dto1 = WeightLogDto.fromJson(originalJson);
      final entity = dto1.toEntity();
      final dto2 = WeightLogDto.fromEntity(entity);
      final finalJson = dto2.toJson();

      // Assert
      expect(finalJson['appetite_score'], originalJson['appetite_score']);
      expect(finalJson['weight_kg'], originalJson['weight_kg']);
    });
  });
}

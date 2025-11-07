import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';

void main() {
  group('WeightLogDto', () {
    // TC-WL-DTO-01: Entity → DTO 변환
    test('should convert WeightLog entity to WeightLogDto', () {
      // Arrange
      final now = DateTime.now();
      final entity = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: now,
      );

      // Act
      final dto = WeightLogDto.fromEntity(entity);

      // Assert
      expect(dto.userId, entity.userId);
      expect(dto.logDate, entity.logDate);
      expect(dto.weightKg, entity.weightKg);
      expect(dto.createdAt, entity.createdAt);
    });

    // TC-WL-DTO-02: DTO → Entity 변환
    test('should convert WeightLogDto to WeightLog entity', () {
      // Arrange
      final now = DateTime.now();
      final dto = WeightLogDto()
        ..userId = 'user-001'
        ..logDate = DateTime(2025, 11, 7)
        ..weightKg = 75.5
        ..createdAt = now;

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.userId, dto.userId);
      expect(entity.logDate, dto.logDate);
      expect(entity.weightKg, dto.weightKg);
      expect(entity.createdAt, dto.createdAt);
    });

    // TC-WL-DTO-03: Round-trip 변환 (데이터 손실 없음)
    test('should preserve data in round-trip conversion', () {
      // Arrange
      final now = DateTime.now();
      final original = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: now,
      );

      // Act
      final dto = WeightLogDto.fromEntity(original);
      final converted = dto.toEntity();

      // Assert
      expect(converted.userId, original.userId);
      expect(converted.logDate, original.logDate);
      expect(converted.weightKg, original.weightKg);
      expect(converted.createdAt, original.createdAt);
    });
  });
}

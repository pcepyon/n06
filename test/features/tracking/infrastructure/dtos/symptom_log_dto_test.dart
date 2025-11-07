import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_log_dto.dart';

void main() {
  group('SymptomLogDto', () {
    // TC-SL-DTO-01: Entity → DTO 변환
    test('should convert SymptomLog entity to SymptomLogDto', () {
      // Arrange
      final entity = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
        tags: const ['기름진음식', '과식'],
      );

      // Act
      final dto = SymptomLogDto.fromEntity(entity);

      // Assert
      expect(dto.symptomName, entity.symptomName);
      expect(dto.severity, entity.severity);
      expect(dto.userId, entity.userId);
      expect(dto.logDate, entity.logDate);
      expect(dto.daysSinceEscalation, entity.daysSinceEscalation);
      expect(dto.isPersistent24h, entity.isPersistent24h);
    });

    // TC-SL-DTO-02: DTO → Entity 변환
    test('should convert SymptomLogDto to entity', () {
      // Arrange
      final now = DateTime.now();
      final dto = SymptomLogDto()
        ..userId = 'user-001'
        ..logDate = DateTime(2025, 11, 7)
        ..symptomName = '메스꺼움'
        ..severity = 4
        ..daysSinceEscalation = 3
        ..createdAt = now;

      // Act
      final entity = dto.toEntity(tags: const []);

      // Assert
      expect(entity.userId, dto.userId);
      expect(entity.logDate, dto.logDate);
      expect(entity.symptomName, dto.symptomName);
      expect(entity.severity, dto.severity);
      expect(entity.daysSinceEscalation, dto.daysSinceEscalation);
    });

    // TC-SL-DTO-03: isPersistent24h 필드 변환
    test('should preserve isPersistent24h in DTO conversion', () {
      // Arrange
      final entity = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '구토',
        severity: 9,
        isPersistent24h: true,
      );

      // Act
      final dto = SymptomLogDto.fromEntity(entity);
      final converted = dto.toEntity(tags: const []);

      // Assert
      expect(converted.isPersistent24h, isTrue);
    });

    // TC-SL-DTO-04: Round-trip 변환
    test('should preserve data in round-trip conversion', () {
      // Arrange
      final now = DateTime.now();
      final original = SymptomLog(
        id: 'sl-004',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '복통',
        severity: 3,
        daysSinceEscalation: 2,
        isPersistent24h: false,
        note: 'test note',
        tags: const ['스트레스'],
        createdAt: now,
      );

      // Act
      final dto = SymptomLogDto.fromEntity(original);
      final converted = dto.toEntity(tags: original.tags);

      // Assert
      expect(converted.userId, original.userId);
      expect(converted.logDate, original.logDate);
      expect(converted.symptomName, original.symptomName);
      expect(converted.severity, original.severity);
      expect(converted.daysSinceEscalation, original.daysSinceEscalation);
      expect(converted.isPersistent24h, original.isPersistent24h);
      expect(converted.note, original.note);
      expect(converted.tags, original.tags);
    });
  });
}

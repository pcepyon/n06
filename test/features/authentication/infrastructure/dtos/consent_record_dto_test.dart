import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/domain/entities/consent_record.dart';
import 'package:n06/features/authentication/infrastructure/dtos/consent_record_dto.dart';

void main() {
  group('ConsentRecordDto', () {
    group('toEntity', () {
      test('should convert ConsentRecordDto to ConsentRecord entity', () {
        // Arrange
        final dto = ConsentRecordDto()
          ..id = 123
          ..userId = 'user123'
          ..termsOfService = true
          ..privacyPolicy = true
          ..agreedAt = DateTime(2025, 1, 1);

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.id, '123');
        expect(entity.userId, 'user123');
        expect(entity.termsOfService, true);
        expect(entity.privacyPolicy, true);
        expect(entity.agreedAt, DateTime(2025, 1, 1));
      });

      test('should allow partial consent (false flags)', () {
        // Arrange
        final dto = ConsentRecordDto()
          ..id = 456
          ..userId = 'user123'
          ..termsOfService = true
          ..privacyPolicy = false
          ..agreedAt = DateTime(2025, 1, 1);

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.termsOfService, true);
        expect(entity.privacyPolicy, false);
      });
    });

    group('fromEntity', () {
      test('should convert ConsentRecord entity to ConsentRecordDto', () {
        // Arrange
        final entity = ConsentRecord(
          id: '789',
          userId: 'user123',
          termsOfService: true,
          privacyPolicy: true,
          agreedAt: DateTime(2025, 1, 1),
        );

        // Act
        final dto = ConsentRecordDto.fromEntity(entity);

        // Assert
        expect(dto.id, 789);
        expect(dto.userId, 'user123');
        expect(dto.termsOfService, true);
        expect(dto.privacyPolicy, true);
        expect(dto.agreedAt, DateTime(2025, 1, 1));
      });

      test('should allow partial consent (false flags)', () {
        // Arrange
        final entity = ConsentRecord(
          id: '999',
          userId: 'user123',
          termsOfService: true,
          privacyPolicy: false,
          agreedAt: DateTime(2025, 1, 1),
        );

        // Act
        final dto = ConsentRecordDto.fromEntity(entity);

        // Assert
        expect(dto.id, 999);
        expect(dto.termsOfService, true);
        expect(dto.privacyPolicy, false);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/domain/entities/consent_record.dart';

void main() {
  group('ConsentRecord Entity', () {
    final testDate = DateTime(2025, 1, 1);

    test('should create ConsentRecord with agreement flags', () {
      // Arrange & Act
      final consent = ConsentRecord(
        id: 'consent123',
        userId: 'user123',
        termsOfService: true,
        privacyPolicy: true,
        agreedAt: testDate,
      );

      // Assert
      expect(consent.id, 'consent123');
      expect(consent.userId, 'user123');
      expect(consent.termsOfService, true);
      expect(consent.privacyPolicy, true);
      expect(consent.agreedAt, testDate);
    });

    test('should allow partial consent (false flags)', () {
      // Arrange & Act
      final consent = ConsentRecord(
        id: 'consent124',
        userId: 'user124',
        termsOfService: true,
        privacyPolicy: false,
        agreedAt: testDate,
      );

      // Assert
      expect(consent.termsOfService, true);
      expect(consent.privacyPolicy, false);
    });

    test('should record agreedAt timestamp', () {
      // Arrange
      final agreedTime = DateTime.now();

      // Act
      final consent = ConsentRecord(
        id: 'consent125',
        userId: 'user125',
        termsOfService: true,
        privacyPolicy: true,
        agreedAt: agreedTime,
      );

      // Assert
      expect(consent.agreedAt, agreedTime);
    });

    test('should support copyWith for immutability', () {
      // Arrange
      final consent = ConsentRecord(
        id: 'consent126',
        userId: 'user126',
        termsOfService: false,
        privacyPolicy: false,
        agreedAt: testDate,
      );

      // Act
      final updated = consent.copyWith(
        termsOfService: true,
        privacyPolicy: true,
      );

      // Assert
      expect(updated.id, 'consent126');
      expect(updated.userId, 'user126');
      expect(updated.termsOfService, true);
      expect(updated.privacyPolicy, true);
    });

    test('should support equality comparison', () {
      // Arrange
      final consent1 = ConsentRecord(
        id: 'consent127',
        userId: 'user127',
        termsOfService: true,
        privacyPolicy: true,
        agreedAt: testDate,
      );

      final consent2 = ConsentRecord(
        id: 'consent127',
        userId: 'user127',
        termsOfService: true,
        privacyPolicy: true,
        agreedAt: testDate,
      );

      final consent3 = ConsentRecord(
        id: 'consent128',
        userId: 'user128',
        termsOfService: false,
        privacyPolicy: false,
        agreedAt: testDate,
      );

      // Assert
      expect(consent1, equals(consent2));
      expect(consent1, isNot(equals(consent3)));
    });
  });
}

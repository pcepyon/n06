import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/domain/value_objects/start_date.dart';
import 'package:n06/core/errors/domain_exception.dart';

void main() {
  group('StartDate Value Object', () {
    test('should create StartDate with current date', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final startDate = StartDate.create(now);

      // Assert
      expect(startDate.value.year, now.year);
      expect(startDate.value.month, now.month);
      expect(startDate.value.day, now.day);
    });

    test('should create StartDate with future date', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 10));

      // Act
      final startDate = StartDate.create(futureDate);

      // Assert
      expect(startDate.value, futureDate);
    });

    test('should allow date between 7 days in the past with warning flag', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 10));

      // Act
      final startDate = StartDate.create(pastDate);

      // Assert
      expect(startDate.value, pastDate);
      expect(startDate.hasWarning, true);
    });

    test('should throw DomainException when date is 30 or more days in past', () {
      // Arrange
      final oldDate = DateTime.now().subtract(const Duration(days: 30));

      // Act & Assert
      expect(
        () => StartDate.create(oldDate),
        throwsA(isA<DomainException>()),
      );
    });

    test('should not have warning flag for recent dates', () {
      // Arrange
      final recentDate = DateTime.now().subtract(const Duration(days: 2));

      // Act
      final startDate = StartDate.create(recentDate);

      // Assert
      expect(startDate.hasWarning, false);
    });

    test('should support equality', () {
      // Arrange
      final date = DateTime.now();

      // Act
      final startDate1 = StartDate.create(date);
      final startDate2 = StartDate.create(date);

      // Assert
      expect(startDate1, startDate2);
    });

    test('should have meaningful toString', () {
      // Arrange
      final date = DateTime.now();

      // Act
      final startDate = StartDate.create(date);

      // Assert
      expect(startDate.toString(), isNotEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';
import 'package:n06/core/errors/domain_exception.dart';

void main() {
  group('Weight Value Object', () {
    test('should create Weight with valid kg value', () {
      // Arrange
      const validKg = 70.5;

      // Act
      final weight = Weight.create(validKg);

      // Assert
      expect(weight.value, validKg);
    });

    test('should throw ValidationError when kg < 20', () {
      // Arrange
      const invalidKg = 19.9;

      // Act & Assert
      expect(
        () => Weight.create(invalidKg),
        throwsA(isA<DomainException>()),
      );
    });

    test('should throw ValidationError when kg > 300', () {
      // Arrange
      const invalidKg = 300.1;

      // Act & Assert
      expect(
        () => Weight.create(invalidKg),
        throwsA(isA<DomainException>()),
      );
    });

    test('should allow boundary value 20kg', () {
      // Arrange
      const boundaryKg = 20.0;

      // Act
      final weight = Weight.create(boundaryKg);

      // Assert
      expect(weight.value, boundaryKg);
    });

    test('should allow boundary value 300kg', () {
      // Arrange
      const boundaryKg = 300.0;

      // Act
      final weight = Weight.create(boundaryKg);

      // Assert
      expect(weight.value, boundaryKg);
    });

    test('should support equality', () {
      // Arrange
      const kg = 75.0;

      // Act
      final weight1 = Weight.create(kg);
      final weight2 = Weight.create(kg);

      // Assert
      expect(weight1, weight2);
    });

    test('should have meaningful toString', () {
      // Arrange
      const kg = 70.5;

      // Act
      final weight = Weight.create(kg);

      // Assert
      expect(weight.toString(), contains('70.5'));
    });
  });
}

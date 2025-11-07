import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/onboarding/domain/value_objects/medication_name.dart';
import 'package:n06/core/errors/domain_exception.dart';

void main() {
  group('MedicationName Value Object', () {
    test('should create MedicationName with valid name', () {
      // Arrange
      const validName = 'Ozempic';

      // Act
      final name = MedicationName.create(validName);

      // Assert
      expect(name.value, validName);
    });

    test('should throw ValidationError when name is empty', () {
      // Arrange
      const emptyName = '';

      // Act & Assert
      expect(
        () => MedicationName.create(emptyName),
        throwsA(isA<DomainException>()),
      );
    });

    test('should throw ValidationError when name is only whitespace', () {
      // Arrange
      const whitespaceName = '   ';

      // Act & Assert
      expect(
        () => MedicationName.create(whitespaceName),
        throwsA(isA<DomainException>()),
      );
    });

    test('should support equality', () {
      // Arrange
      const name = 'Saxenda';

      // Act
      final name1 = MedicationName.create(name);
      final name2 = MedicationName.create(name);

      // Assert
      expect(name1, name2);
    });

    test('should trim whitespace', () {
      // Arrange
      const nameWithWhitespace = '  Mounjaro  ';

      // Act
      final name = MedicationName.create(nameWithWhitespace);

      // Assert
      expect(name.value, 'Mounjaro');
    });

    test('should have meaningful toString', () {
      // Arrange
      const medicationName = 'Ozempic';

      // Act
      final name = MedicationName.create(medicationName);

      // Assert
      expect(name.toString(), contains('Ozempic'));
    });
  });
}

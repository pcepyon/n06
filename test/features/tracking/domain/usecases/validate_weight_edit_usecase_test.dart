import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/usecases/validate_weight_edit_usecase.dart';

void main() {
  late ValidateWeightEditUseCase useCase;

  setUp(() {
    useCase = ValidateWeightEditUseCase();
  });

  group('ValidateWeightEditUseCase', () {
    test('should return success for valid weight in range 20-300kg', () {
      // Arrange
      final weight = 70.5;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.error, isNull);
    });

    test('should return error for weight below 20kg', () {
      // Arrange
      final weight = 19.9;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
      expect(result.error, contains('20'));
    });

    test('should return error for weight above 300kg', () {
      // Arrange
      final weight = 300.1;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
      expect(result.error, contains('300'));
    });

    test('should return error for negative weight', () {
      // Arrange
      final weight = -5.0;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
    });

    test('should return error for zero weight', () {
      // Arrange
      final weight = 0.0;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
    });

    test('should return success with warning for weight < 30kg but >= 20kg', () {
      // Arrange
      final weight = 25.0;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, true);
      expect(result.warning, isNotNull);
      expect(result.isFailure, false);
    });

    test('should return success with warning for weight > 200kg but <= 300kg', () {
      // Arrange
      final weight = 250.0;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, true);
      expect(result.warning, isNotNull);
      expect(result.isFailure, false);
    });

    test('should accept boundary value 20kg', () {
      // Arrange
      final weight = 20.0;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, true);
    });

    test('should accept boundary value 300kg', () {
      // Arrange
      final weight = 300.0;

      // Act
      final result = useCase.execute(weight);

      // Assert
      expect(result.isSuccess, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/usecases/validate_symptom_edit_usecase.dart';

void main() {
  late ValidateSymptomEditUseCase useCase;

  setUp(() {
    useCase = ValidateSymptomEditUseCase();
  });

  group('ValidateSymptomEditUseCase', () {
    test('should return success for severity in range 1-10', () {
      // Arrange & Act
      final result = useCase.execute(severity: 5, symptomName: '메스꺼움');

      // Assert
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
    });

    test('should return error for severity below 1', () {
      // Arrange & Act
      final result = useCase.execute(severity: 0, symptomName: '메스꺼움');

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
    });

    test('should return error for severity above 10', () {
      // Arrange & Act
      final result = useCase.execute(severity: 11, symptomName: '메스꺼움');

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
    });

    test('should return error for empty symptom name', () {
      // Arrange & Act
      final result = useCase.execute(severity: 5, symptomName: '');

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, isNotNull);
    });

    test('should validate symptom name from predefined list', () {
      // Arrange
      final validSymptoms = ['메스꺼움', '구토', '변비', '설사', '복통', '두통', '피로'];

      // Act & Assert
      for (var symptom in validSymptoms) {
        final result = useCase.execute(severity: 5, symptomName: symptom);
        expect(result.isSuccess, true);
      }
    });

    test('should allow custom symptom names (not in predefined list)', () {
      // Arrange & Act
      final result = useCase.execute(severity: 5, symptomName: '커스텀증상');

      // Assert
      expect(result.isSuccess, true);
    });

    test('should accept boundary value 1 for severity', () {
      // Arrange & Act
      final result = useCase.execute(severity: 1, symptomName: '메스꺼움');

      // Assert
      expect(result.isSuccess, true);
    });

    test('should accept boundary value 10 for severity', () {
      // Arrange & Act
      final result = useCase.execute(severity: 10, symptomName: '메스꺼움');

      // Assert
      expect(result.isSuccess, true);
    });
  });
}

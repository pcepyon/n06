import 'package:n06/features/tracking/domain/entities/validation_result.dart';

class ValidateWeightEditUseCase {
  static const double minWeight = 20.0;
  static const double maxWeight = 300.0;
  static const double warningLowThreshold = 30.0;
  static const double warningHighThreshold = 200.0;

  ValidationResult execute(double weight) {
    // Check if weight is negative or zero
    if (weight <= 0) {
      return ValidationResult.error('체중은 0보다 커야 합니다');
    }

    // Check if weight is below minimum
    if (weight < minWeight) {
      return ValidationResult.error('체중은 ${minWeight}kg 이상이어야 합니다');
    }

    // Check if weight is above maximum
    if (weight > maxWeight) {
      return ValidationResult.error('체중은 ${maxWeight}kg 이하여야 합니다');
    }

    // Check for warning - too low
    if (weight < warningLowThreshold) {
      return ValidationResult.success(warning: '비정상적으로 낮은 체중입니다. 입력값을 다시 확인해주세요.');
    }

    // Check for warning - too high
    if (weight > warningHighThreshold) {
      return ValidationResult.success(warning: '비정상적으로 높은 체중입니다. 입력값을 다시 확인해주세요.');
    }

    return ValidationResult.success();
  }
}

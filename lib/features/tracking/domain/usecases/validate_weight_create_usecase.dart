import 'package:n06/features/tracking/domain/entities/validation_result.dart';

/// 체중 생성 시 유효성 검증 UseCase
///
/// F002 일상 체중 기록 기능에서 사용됩니다.
/// ValidateWeightEditUseCase와 동일한 검증 로직을 공유합니다.
class ValidateWeightCreateUseCase {
  static const double minWeight = 20.0;
  static const double maxWeight = 300.0;
  static const double warningLowThreshold = 30.0;
  static const double warningHighThreshold = 200.0;

  /// 주어진 체중 값의 유효성을 검증합니다.
  ///
  /// - 0 이하: 에러
  /// - 20kg 미만: 에러
  /// - 300kg 초과: 에러
  /// - 30kg 미만: 경고 (입력값 재확인)
  /// - 200kg 초과: 경고 (입력값 재확인)
  /// - 그 외: 성공
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

import 'package:n06/features/tracking/domain/entities/validation_result.dart';

class ValidateSymptomEditUseCase {
  static const List<String> validSymptoms = [
    '메스꺼움',
    '구토',
    '변비',
    '설사',
    '복통',
    '두통',
    '피로'
  ];

  ValidationResult execute({required int severity, required String symptomName}) {
    // Check if symptom name is empty
    if (symptomName.isEmpty) {
      return ValidationResult.error('증상명을 입력해주세요');
    }

    // Check if severity is within valid range
    if (severity < 1 || severity > 10) {
      return ValidationResult.error('심각도는 1-10 사이의 값이어야 합니다');
    }

    return ValidationResult.success();
  }
}

# Unit Tests

Domain Layer 위주의 Unit 테스트를 작성합니다.

## 테스트 대상 (70% 비중)

- **Domain Entities**: 비즈니스 로직과 검증 규칙
- **Value Objects**: 값 객체의 불변성과 동등성
- **Use Cases**: 비즈니스 로직의 정확성

## 특징

- Pure Dart 코드만 테스트
- Mocking 불필요
- 빠른 실행 속도
- 높은 커버리지 목표

## 예시

```dart
test('should calculate weekly weight loss goal correctly', () {
  // Arrange
  final targetWeightKg = 70.0;
  final currentWeightKg = 80.0;
  final targetPeriodWeeks = 10;

  // Act
  final weeklyGoal = (currentWeightKg - targetWeightKg) / targetPeriodWeeks;

  // Assert
  expect(weeklyGoal, 1.0);
});
```

## 실행

```bash
# 모든 unit 테스트 실행
flutter test test/unit/

# 특정 파일 실행
flutter test test/unit/dose_entity_test.dart
```

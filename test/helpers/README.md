# Test Helpers

테스트 작성을 위한 유틸리티 함수와 데이터 빌더입니다.

## 포함 내용

### 1. Fake Async Utilities
- `fake_async` 패키지를 사용한 비동기 테스트 헬퍼
- `Future.delayed`, 재시도 로직 등의 안정적인 테스트

### 2. Test Data Builders
- Entity 생성을 위한 빌더 패턴
- 테스트 데이터 준비 간소화

### 3. Riverpod Test Utilities
- Provider 오버라이드 헬퍼
- Container 생성 유틸리티

## 사용 예시

### Fake Async

```dart
import 'package:fake_async/fake_async.dart';

test('should retry 3 times with fake timers', () {
  fakeAsync((async) {
    var attemptCount = 0;

    Future<void> retryLogic() async {
      for (var i = 0; i < 3; i++) {
        attemptCount++;
        await Future.delayed(Duration(seconds: 1));
      }
    }

    retryLogic();

    async.elapse(Duration(seconds: 3));
    expect(attemptCount, 3);
  });
});
```

### Test Data Builder

```dart
class DoseBuilder {
  int id = 1;
  double doseMg = 0.25;
  DateTime administeredAt = DateTime(2024, 1, 1);

  DoseBuilder withDoseMg(double mg) {
    doseMg = mg;
    return this;
  }

  DoseBuilder withAdministeredAt(DateTime date) {
    administeredAt = date;
    return this;
  }

  Dose build() {
    return Dose(
      id: id,
      doseMg: doseMg,
      administeredAt: administeredAt,
    );
  }
}

// Usage
final dose = DoseBuilder()
  .withDoseMg(0.5)
  .withAdministeredAt(DateTime.now())
  .build();
```

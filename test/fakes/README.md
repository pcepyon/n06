# Fake Repositories

Fake Repository 패턴을 사용한 메모리 기반 구현체입니다.

## 목적

- TDD 사이클 신속성 극대화
- `build_runner` 없이 빠른 테스트 실행
- 여러 Repository를 조합한 통합 테스트의 복잡성 제거

## 사용 방법

### 1. Fake Repository 구현

```dart
class FakeMedicationRepository implements MedicationRepository {
  final List<Dose> _doses = [];
  final _controller = StreamController<List<Dose>>.broadcast();

  @override
  Stream<List<Dose>> watchDoses() {
    return _controller.stream.startWith(_doses);
  }

  @override
  Future<void> saveDose(Dose dose) async {
    _doses.add(dose);
    _controller.add(_doses);
  }

  void dispose() {
    _controller.close();
  }
}
```

### 2. 테스트에서 사용

```dart
test('should save dose and emit updated list', () async {
  // Arrange
  final fakeRepo = FakeMedicationRepository();
  final dose = Dose(id: 1, doseMg: 0.25, administeredAt: DateTime.now());

  // Act
  await fakeRepo.saveDose(dose);

  // Assert
  expect(await fakeRepo.watchDoses().first, contains(dose));

  fakeRepo.dispose();
});
```

## 주의사항

- Mocktail의 `when` 구문 대신 메모리 데이터 구조 조작 선호
- 각 테스트 후 `dispose()` 호출로 리소스 정리
- Stream은 `StreamController.broadcast()` 사용

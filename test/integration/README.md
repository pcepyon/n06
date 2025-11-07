# Integration Tests

Application Layer와 Infrastructure Layer의 통합 테스트입니다.

## 테스트 대상 (30% 비중)

- **Application Layer (20%)**: Notifier 상태 전환, UseCase 오케스트레이션
- **Infrastructure Layer (10%)**: Repository 구현체, DB 트랜잭션

## Application Layer 테스트

### Notifier 테스트

```dart
test('should load doses and update state', () async {
  // Arrange
  final container = createContainer(
    overrides: [
      medicationRepositoryProvider.overrideWithValue(
        FakeMedicationRepository(),
      ),
    ],
  );

  // Act
  final state = container.read(doseListNotifierProvider);

  // Assert
  expect(state, isA<AsyncLoading>());

  await container.read(doseListNotifierProvider.future);
  expect(container.read(doseListNotifierProvider).value, isNotEmpty);
});
```

## Infrastructure Layer 테스트

### Repository 테스트

```dart
test('should save dose to Isar database', () async {
  // Arrange - 임시 디렉토리 사용
  final dir = await getTemporaryDirectory();
  final isar = await Isar.open([DoseRecordDtoSchema], directory: dir.path);
  final repository = IsarMedicationRepository(isar);

  final dose = Dose(id: 1, doseMg: 0.25, administeredAt: DateTime.now());

  // Act
  await repository.saveDose(dose);

  // Assert
  final doses = await repository.getDoses();
  expect(doses, hasLength(1));

  await isar.close();
  await dir.delete(recursive: true);
});
```

## Critical Scenarios

test-plan.md의 필수 시나리오:
- **IT-002**: 투여 계획 수정 실패 시 롤백 (isar + fake_async)
- **IT-004**: 대시보드 실시간 업데이트 (notifier)

## 실행

```bash
# 모든 integration 테스트 실행
flutter test test/integration/

# 특정 파일 실행
flutter test test/integration/medication_notifier_test.dart
```

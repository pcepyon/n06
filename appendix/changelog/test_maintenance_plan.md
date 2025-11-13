# 테스트 유지보수 계획

## 현재 상태

- **통과**: 432 테스트 (74.2%)
- **스킵**: 1 테스트
- **실패**: 151 테스트 (25.8%)

## 문제 분석

### 1. IsarDB 네이티브 라이브러리 문제 (95개 실패)

**증상**: `Failed to load dynamic library libisar.dylib`

**원인**:
- `flutter test`는 Dart VM에서 실행
- IsarDB 네이티브 바이너리를 로드할 수 없음
- `isar_flutter_libs`는 앱 실행 시에만 작동

**영향받는 테스트**:
- `test/features/*/infrastructure/repositories/isar_*_repository_test.dart`
- `test/features/data_sharing/infrastructure/repositories/isar_shared_data_repository_test.dart`

### 2. Flutter Binding 초기화 문제 (30개 실패)

**증상**: `Binding has not yet been initialized`

**원인**:
- `path_provider`, `SharedPreferences` 등 Flutter 플러그인 사용
- `TestWidgetsFlutterBinding.ensureInitialized()` 누락

**영향받는 테스트**:
- Widget 테스트
- `path_provider` 사용하는 Repository 테스트

### 3. Provider Mock 설정 문제 (26개 실패)

**증상**: `LateInitializationError: Local 'isar' has not been initialized`

**원인**:
- ProviderContainer에 필요한 Provider override 누락
- `isarProvider` override 없이 Repository 사용

**영향받는 테스트**:
- `test/features/*/application/notifiers/*_notifier_test.dart`

---

## 수정 계획

### Phase 1: 긴급 수정 (기능 영향도 높음)

#### Task 1.1: Fake Repository 패턴 도입

**디렉토리 구조**:
```
test/helpers/repositories/
├── fake_medication_repository.dart
├── fake_tracking_repository.dart
├── fake_profile_repository.dart
└── fake_notification_repository.dart
```

**구현 예시**:
```dart
// test/helpers/repositories/fake_medication_repository.dart
import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';

class FakeMedicationRepository implements MedicationRepository {
  final Map<String, DoseRecord> _records = {};

  @override
  Future<void> saveDoseRecord(DoseRecord record) async {
    _records[record.id] = record;
  }

  @override
  Future<DoseRecord?> getDoseRecord(String id) async {
    return _records[id];
  }

  @override
  Future<List<DoseRecord>> getAllDoseRecords(String userId) async {
    return _records.values
        .where((r) => r.userId == userId)
        .toList();
  }

  @override
  Future<void> deleteDoseRecord(String id) async {
    _records.remove(id);
  }

  void reset() {
    _records.clear();
  }
}
```

**기존 테스트 변경**:
```dart
// Before
void main() {
  late Isar isar;
  late IsarMedicationRepository repository;

  setUp(() async {
    final dir = await getTemporaryDirectory();
    isar = await Isar.open([...], directory: dir.path);  // ❌ 실패
    repository = IsarMedicationRepository(isar);
  });
}

// After
void main() {
  late FakeMedicationRepository repository;

  setUp(() {
    repository = FakeMedicationRepository();
  });

  tearDown(() {
    repository.reset();
  });
}
```

**수정 대상 파일** (95개):
- `test/features/tracking/infrastructure/repositories/isar_dosage_plan_repository_test.dart`
- `test/features/tracking/infrastructure/repositories/isar_dose_schedule_repository_test.dart`
- `test/features/tracking/infrastructure/repositories/isar_tracking_repository_test.dart`
- `test/features/tracking/infrastructure/repositories/isar_emergency_check_repository_test.dart`
- `test/features/profile/infrastructure/repositories/isar_profile_repository_update_weekly_goals_test.dart`
- `test/features/notification/infrastructure/repositories/isar_notification_repository_test.dart`
- `test/features/data_sharing/infrastructure/repositories/isar_shared_data_repository_test.dart`
- `test/features/coping_guide/infrastructure/repositories/isar_feedback_repository_test.dart`

#### Task 1.2: Integration Test로 일부 전환

**Critical Path 테스트만 Integration Test로**:
```
integration_test/
├── infrastructure/
│   ├── isar_tracking_repository_integration_test.dart
│   └── isar_medication_repository_integration_test.dart
└── e2e/
    └── dose_recording_flow_test.dart
```

**실행**:
```bash
# Integration Test 실행
flutter test integration_test/
```

---

### Phase 2: 중요 수정 (테스트 안정성)

#### Task 2.1: Test Helper 생성

**파일**: `test/helpers/test_setup.dart`
```dart
import 'package:flutter_test/flutter_test.dart';

/// Flutter Widget/Plugin 테스트를 위한 기본 설정
void setupFlutterTest() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Riverpod 테스트를 위한 기본 설정
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: [
      // 공통 Provider Override
      isarProvider.overrideWithValue(FakeIsar()),
      ...overrides,
    ],
  );
}
```

#### Task 2.2: Widget 테스트 수정

**수정 패턴**:
```dart
// Before
void main() {
  testWidgets('should render correctly', (tester) async {
    // ❌ Binding 초기화 없음
    await tester.pumpWidget(MyWidget());
  });
}

// After
void main() {
  setUpAll(setupFlutterTest);  // ✅ 추가

  testWidgets('should render correctly', (tester) async {
    await tester.pumpWidget(MyWidget());
  });
}
```

**수정 대상 파일** (30개):
- `test/features/tracking/presentation/widgets/input_validation_widget_test.dart`
- `test/features/tracking/presentation/screens/symptom_record_screen_test.dart`
- `test/features/tracking/presentation/dialogs/*_dialog_test.dart`
- `test/features/notification/presentation/screens/notification_settings_screen_test.dart`
- 기타 모든 Widget 테스트

---

### Phase 3: 개선 작업 (코드 품질)

#### Task 3.1: Notifier 테스트 Mock 개선

**수정 패턴**:
```dart
// Before
test('should load settings', () async {
  final container = ProviderContainer(
    overrides: [
      notificationRepositoryProvider.overrideWithValue(mockRepository),
      // ❌ isarProvider, authNotifierProvider override 누락
    ],
  );
});

// After
test('should load settings', () async {
  final container = createTestContainer(  // ✅ Helper 사용
    overrides: [
      notificationRepositoryProvider.overrideWithValue(mockRepository),
      authNotifierProvider.overrideWith((ref) =>
        AsyncValue.data(User(id: 'user123'))),
    ],
  );
});
```

**수정 대상 파일** (26개):
- `test/features/notification/application/notifiers/notification_notifier_test.dart`
- `test/features/profile/application/notifiers/profile_notifier_test.dart`
- `test/features/tracking/application/notifiers/tracking_notifier_test.dart`

---

## 예상 효과

| Phase | 수정 대상 | 실패율 개선 |
|-------|----------|------------|
| 현재 | - | 25.8% (151/585) |
| Phase 1 완료 | 95개 | 10% 이하 |
| Phase 2 완료 | 30개 | 5% 이하 |
| Phase 3 완료 | 26개 | 0% (목표) |

---

## 장기 전략

### 1. Test Pyramid 재구성

```
       /\
      /E2E\         ← Integration Test (소수, 핵심 플로우)
     /------\
    /Widget \       ← Widget Test (중간, UI 컴포넌트)
   /----------\
  /   Unit     \    ← Unit Test (다수, 로직 검증)
 /--------------\
```

**현재 문제**: Infrastructure Test가 너무 많음 (IsarDB 직접 테스트)

**개선 방향**:
- Unit Test: Domain/Application 로직 + Fake Repository
- Widget Test: Presentation 레이어
- Integration Test: 실제 IsarDB + 핵심 플로우만

### 2. CI/CD 파이프라인 구성

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test --exclude-tags=integration

  integration-test:
    runs-on: macos-latest  # IsarDB 네이티브 라이브러리 필요
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test integration_test/
```

### 3. Test Coverage 목표

- **Unit Test**: 80% 이상
- **Widget Test**: 60% 이상
- **Integration Test**: 핵심 플로우 커버리지

---

## 실행 순서

1. **즉시 시작**: Phase 1 (Fake Repository 도입)
   - 가장 큰 영향 (95개 테스트)
   - 다른 Phase의 선행 조건

2. **병행 진행**: Phase 2 (Binding 초기화)
   - Phase 1과 독립적
   - 빠른 수정 가능

3. **최종 마무리**: Phase 3 (Mock 개선)
   - Phase 1 완료 후 진행
   - Test Helper 활용

---

## 참고 자료

- [Flutter Testing Best Practices](https://flutter.dev/docs/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing)
- [Fake vs Mock vs Stub](https://martinfowler.com/articles/mocksArentStubs.html)

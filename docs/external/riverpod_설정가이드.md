# Riverpod Setup Guide for GLP-1 Treatment Management App

## Context
- **Goal:** 4-Layer Architecture에서 Riverpod을 사용한 상태 관리 및 의존성 주입 구현
- **Library:** Riverpod 3.x with Code Generation
- **Use Case:** Repository Pattern 기반의 Feature-based Flutter 앱
- **Last Updated:** 2025-11-09
- **Library Version:** flutter_riverpod ^3.0.3, riverpod_generator ^3.0.3

---

## Why Riverpod for This Project

Riverpod은 이 프로젝트에 최적화된 선택입니다:

**4-Layer Architecture 지원**: Domain Layer의 Repository Interface를 Infrastructure Layer의 구현체로 쉽게 교체할 수 있습니다. Phase 0에서 IsarMedicationRepository를 사용하다가 Phase 1에서 SupabaseMedicationRepository로 전환 시 Provider DI 코드 1줄만 수정하면 됩니다.

**컴파일 타임 안전성**: 전역 Provider 선언으로 ProviderNotFoundException을 원천적으로 차단하고, Code Generation을 통해 타입 안전성을 보장합니다. 의료 데이터를 다루는 앱에서 런타임 에러는 치명적이므로 이는 중요한 장점입니다.

**자동 메모리 관리**: autoDispose 기능으로 사용하지 않는 Provider 상태를 자동으로 정리합니다. 투여 기록, 증상 기록 등 많은 데이터를 다루는 앱에서 메모리 효율성은 필수적입니다.

---

## Installation

### 1. pubspec.yaml에 패키지 추가

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.3
  riverpod_annotation: ^3.0.3

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^3.0.3
  riverpod_lint: ^3.0.3
  custom_lint: ^0.7.0
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. analysis_options.yaml 설정

프로젝트 루트에 `analysis_options.yaml` 파일을 생성하고 다음 내용 추가:

```yaml
analyzer:
  plugins:
    - custom_lint
```

---

## Basic Setup

### 1. main.dart 설정

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // 전체 앱을 ProviderScope로 감싸기 (필수)
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLP-1 Treatment Manager',
      home: const HomeScreen(),
    );
  }
}
```

### 2. Code Generation 설정

**자동 생성 파일 명명 규칙:**
- 원본 파일: `medication_repository.dart`
- 생성 파일: `medication_repository.g.dart`

**part 선언 추가:**
```dart
// lib/features/tracking/infrastructure/repositories/medication_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'medication_repository.g.dart';  // 필수!
```

### 3. Build Runner 실행

**개발 중 자동 감지 모드 (권장):**
```bash
dart run build_runner watch -d
```

**일회성 생성:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4-Layer Architecture에서의 Provider 배치

### Layer별 Provider 역할

```
Presentation Layer
└── ConsumerWidget/ConsumerStatefulWidget으로 Provider 구독

Application Layer  
└── providers.dart (모든 Provider 정의)
    ├── Repository Providers (Infrastructure 구현체 주입)
    ├── UseCase Providers (선택사항)
    └── Notifier Providers (상태 관리)

Domain Layer
└── Repository Interface만 정의 (Riverpod 의존성 없음)

Infrastructure Layer
└── Repository 구현체 (Riverpod 의존성 없음)
```

---

## Core Usage Patterns

### Pattern 1: Repository Provider (Infrastructure 주입)

**Infrastructure Layer - Repository 구현체:**
```dart
// lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart
import 'package:isar/isar.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/entities/dose.dart';

class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  @override
  Stream<List<Dose>> watchDoses() {
    return isar.doseRecordDtos
      .watchLazy()
      .asyncMap((_) => _loadDoses());
  }

  @override
  Future<void> saveDose(Dose dose) async {
    final dto = DoseRecordDto.fromEntity(dose);
    await isar.writeTxn(() => isar.doseRecordDtos.put(dto));
  }

  Future<List<Dose>> _loadDoses() async {
    final dtos = await isar.doseRecordDtos.where().findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
```

**Application Layer - Provider 정의:**
```dart
// lib/features/tracking/application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/medication_repository.dart';
import '../infrastructure/repositories/isar_medication_repository.dart';
import '../../../core/database/isar_provider.dart';

part 'providers.g.dart';

// Repository Provider 정의
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarMedicationRepository(isar);
}

// Phase 1 전환 시 이 부분만 수정:
// @riverpod
// MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
//   final supabase = ref.watch(supabaseProvider);
//   return SupabaseMedicationRepository(supabase);
// }
```

**핵심 포인트:**
- Repository 구현체는 Riverpod을 모름 (순수 Dart 클래스)
- Provider는 Application Layer에서만 정의
- Phase 전환 시 Provider 정의만 수정하면 됨

### Pattern 2: Notifier Provider (동기 상태 관리)

**Application Layer - Notifier 정의:**
```dart
// lib/features/tracking/application/notifiers/dose_scheduler_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/dose_schedule.dart';
import '../../domain/repositories/medication_repository.dart';
import '../providers.dart';

part 'dose_scheduler_notifier.g.dart';

@riverpod
class DoseScheduler extends _$DoseScheduler {
  @override
  List<DoseSchedule> build() {
    // 초기 상태 반환
    return [];
  }

  // 상태 변경 메서드
  Future<void> loadSchedules(String userId) async {
    final repository = ref.read(medicationRepositoryProvider);
    final schedules = await repository.getSchedules(userId);
    state = schedules;
  }

  void addSchedule(DoseSchedule schedule) {
    state = [...state, schedule];
  }

  void removeSchedule(String scheduleId) {
    state = state.where((s) => s.id != scheduleId).toList();
  }
}
```

**Presentation Layer - Notifier 사용:**
```dart
// lib/features/tracking/presentation/screens/dose_scheduler_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/notifiers/dose_scheduler_notifier.dart';

class DoseSchedulerScreen extends ConsumerWidget {
  const DoseSchedulerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider 구독 (상태 변경 시 자동 리빌드)
    final schedules = ref.watch(doseSchedulerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('투여 스케줄')),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return ListTile(
            title: Text('${schedule.doseMg}mg'),
            subtitle: Text(schedule.scheduledAt.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Notifier 메서드 호출
                ref.read(doseSchedulerProvider.notifier)
                   .removeSchedule(schedule.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Notifier 메서드 호출
          await ref.read(doseSchedulerProvider.notifier)
                   .loadSchedules('user123');
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### Pattern 3: AsyncNotifier Provider (비동기 상태 관리)

**Application Layer - AsyncNotifier 정의:**
```dart
// lib/features/tracking/application/notifiers/weight_records_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/weight_record.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../providers.dart';

part 'weight_records_notifier.g.dart';

@riverpod
class WeightRecords extends _$WeightRecords {
  @override
  Future<List<WeightRecord>> build() async {
    // 초기 데이터 비동기 로딩
    final repository = ref.read(trackingRepositoryProvider);
    return await repository.getWeightRecords();
  }

  // 비동기 상태 변경
  Future<void> addRecord(WeightRecord record) async {
    // 로딩 상태로 전환
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      await repository.saveWeightRecord(record);
      
      // 최신 데이터 다시 로드
      return await repository.getWeightRecords();
    });
  }

  // 에러 복구
  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      return await repository.getWeightRecords();
    });
  }
}
```

**Presentation Layer - AsyncValue 처리:**
```dart
// lib/features/tracking/presentation/screens/weight_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/notifiers/weight_records_notifier.dart';

class WeightTrackingScreen extends ConsumerWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightRecordsAsync = ref.watch(weightRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('체중 기록')),
      body: weightRecordsAsync.when(
        // 로딩 중
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // 에러 발생
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('에러: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.read(weightRecordsProvider.notifier).retry();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        
        // 데이터 로드 성공
        data: (records) => ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return ListTile(
              title: Text('${record.weightKg} kg'),
              subtitle: Text(record.recordedAt.toString()),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRecord = WeightRecord(
            id: DateTime.now().toString(),
            weightKg: 70.5,
            recordedAt: DateTime.now(),
          );
          
          await ref.read(weightRecordsProvider.notifier)
                   .addRecord(newRecord);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Pattern 4: Simple Provider (의존성 주입)

**Core Layer - Database Provider:**
```dart
// lib/core/database/isar_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)  // autoDispose 비활성화
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  return await Isar.open(
    [
      DoseRecordDtoSchema,
      WeightRecordDtoSchema,
      SymptomRecordDtoSchema,
    ],
    directory: dir.path,
  );
}
```

---

## Complete Feature Example

### 완전한 투여 기록 기능 구현

**1. Domain Layer - Repository Interface:**
```dart
// lib/features/tracking/domain/repositories/medication_repository.dart
import '../entities/dose.dart';

abstract class MedicationRepository {
  Stream<List<Dose>> watchDoses();
  Future<void> saveDose(Dose dose);
  Future<List<Dose>> getDoses();
}
```

**2. Infrastructure Layer - Repository 구현:**
```dart
// lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart
import 'package:isar/isar.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/entities/dose.dart';
import '../dtos/dose_record_dto.dart';

class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  @override
  Stream<List<Dose>> watchDoses() {
    return isar.doseRecordDtos.watchLazy().asyncMap((_) => getDoses());
  }

  @override
  Future<void> saveDose(Dose dose) async {
    final dto = DoseRecordDto.fromEntity(dose);
    await isar.writeTxn(() => isar.doseRecordDtos.put(dto));
  }

  @override
  Future<List<Dose>> getDoses() async {
    final dtos = await isar.doseRecordDtos
        .where()
        .sortByAdministeredAtDesc()
        .findAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
```

**3. Application Layer - Providers:**
```dart
// lib/features/tracking/application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/medication_repository.dart';
import '../infrastructure/repositories/isar_medication_repository.dart';
import '../../../core/database/isar_provider.dart';

part 'providers.g.dart';

@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarMedicationRepository(isar);
}
```

**4. Application Layer - Notifier:**
```dart
// lib/features/tracking/application/notifiers/dose_list_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/dose.dart';
import '../providers.dart';

part 'dose_list_notifier.g.dart';

@riverpod
class DoseList extends _$DoseList {
  @override
  Stream<List<Dose>> build() {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.watchDoses();
  }

  Future<void> addDose(double doseMg, DateTime administeredAt) async {
    final repository = ref.read(medicationRepositoryProvider);
    final dose = Dose(
      id: DateTime.now().millisecondsSinceEpoch,
      doseMg: doseMg,
      administeredAt: administeredAt,
    );
    await repository.saveDose(dose);
  }
}
```

**5. Presentation Layer - Screen:**
```dart
// lib/features/tracking/presentation/screens/dose_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/notifiers/dose_list_notifier.dart';

class DoseListScreen extends ConsumerWidget {
  const DoseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doseListAsync = ref.watch(doseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('투여 기록')),
      body: doseListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('에러: $error')),
        data: (doses) {
          if (doses.isEmpty) {
            return const Center(child: Text('투여 기록이 없습니다'));
          }

          return ListView.builder(
            itemCount: doses.length,
            itemBuilder: (context, index) {
              final dose = doses[index];
              return ListTile(
                leading: const Icon(Icons.medication),
                title: Text('${dose.doseMg} mg'),
                subtitle: Text(
                  '${dose.administeredAt.year}-${dose.administeredAt.month}-${dose.administeredAt.day} '
                  '${dose.administeredAt.hour}:${dose.administeredAt.minute}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDoseDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDoseDialog(BuildContext context, WidgetRef ref) {
    double doseMg = 0.25;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('투여 기록 추가'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('용량: ${doseMg} mg'),
              Slider(
                value: doseMg,
                min: 0.25,
                max: 2.4,
                divisions: 8,
                onChanged: (value) {
                  setState(() => doseMg = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(doseListProvider.notifier)
                       .addDose(doseMg, DateTime.now());
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
```

---

## Provider Usage in Widgets

### ref.watch vs ref.read vs ref.listen

```dart
class ExampleWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ref.watch: 상태 구독, 변경 시 위젯 리빌드
    final doses = ref.watch(doseListProvider);
    
    // 2. ref.read: 일회성 읽기, 리빌드 안 됨 (이벤트 핸들러에서 사용)
    final addDose = () {
      ref.read(doseListProvider.notifier).addDose(0.5, DateTime.now());
    };
    
    // 3. ref.listen: 상태 변경 감지하여 side-effect 실행
    ref.listen(doseListProvider, (previous, next) {
      next.whenData((doses) {
        if (doses.length > previous?.valueOrNull?.length ?? 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('투여 기록이 추가되었습니다')),
          );
        }
      });
    });

    return doses.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (data) => Text('Total: ${data.length}'),
    );
  }
}
```

### ConsumerWidget vs ConsumerStatefulWidget

```dart
// Stateless + Consumer
class SimpleScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(someProvider);
    return Text(state);
  }
}

// Stateful + Consumer
class ComplexScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ComplexScreen> createState() => _ComplexScreenState();
}

class _ComplexScreenState extends ConsumerState<ComplexScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref는 State 클래스에서 직접 사용 가능
    final state = ref.watch(someProvider);
    
    return TextField(
      controller: _controller,
      onSubmitted: (value) {
        ref.read(someProvider.notifier).update(value);
      },
    );
  }
}
```

---

## Advanced Features

### Family Modifier (매개변수가 있는 Provider)

Code generation을 사용하면 family 수식어 없이 함수 매개변수로 처리:

```dart
// lib/features/tracking/application/providers.dart
@riverpod
Future<List<Dose>> dosesByDate(
  DosesByDateRef ref, {
  required DateTime date,
}) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return await repository.getDosesByDate(date);
}

// 사용 (Widget)
final doses = ref.watch(dosesByDateProvider(date: DateTime.now()));
```

### Provider Override (테스트용)

```dart
// test/features/tracking/dose_list_test.dart
void main() {
  testWidgets('투여 기록 리스트 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Mock Repository로 교체
          medicationRepositoryProvider.overrideWith(
            (ref) => MockMedicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: DoseListScreen(),
        ),
      ),
    );

    expect(find.text('0.5 mg'), findsOneWidget);
  });
}
```

### keepAlive 설정

```dart
// autoDispose 비활성화 (메모리에 계속 유지)
@Riverpod(keepAlive: true)
String appVersion(AppVersionRef ref) {
  return '1.0.0';
}

// autoDispose 활성화 (기본값)
@riverpod
String tempData(TempDataRef ref) {
  return 'temporary';
}
```

---

## Testing & Validation

### Provider 테스트 체크리스트

- [ ] Provider가 올바른 초기값을 반환하는가?
- [ ] Notifier의 메서드가 상태를 정확히 업데이트하는가?
- [ ] AsyncNotifier가 로딩/에러/데이터 상태를 올바르게 처리하는가?
- [ ] Repository Provider가 올바른 구현체를 반환하는가?
- [ ] Provider Override가 정상 작동하는가?

### Debug Tips

**Provider 상태 로깅:**
```dart
void main() {
  runApp(
    ProviderScope(
      observers: [
        ProviderLogger(),  // 모든 Provider 변경 로깅
      ],
      child: const MyApp(),
    ),
  );
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[${provider.name ?? provider.runtimeType}] $newValue');
  }
}
```

**Riverpod Devtools:**
```bash
# Flutter DevTools에서 Provider 상태 실시간 모니터링
flutter run --observatory-port=8888
```

---

## Common Issues & Solutions

### Issue 1: "part 파일을 찾을 수 없습니다"
**Symptom:** `part 'providers.g.dart'` 선언 후 빨간 줄 표시

**Solution:** 
```bash
# Build runner 실행하여 .g.dart 파일 생성
dart run build_runner build --delete-conflicting-outputs
```

**예방:**
```bash
# 개발 중에는 watch 모드 사용
dart run build_runner watch -d
```

### Issue 2: "ProviderException: Provider was disposed"
**Symptom:** autoDispose Provider 접근 시 disposed 에러

**Solution:**
```dart
// keepAlive 사용하거나
@Riverpod(keepAlive: true)
String persistentData(PersistentDataRef ref) => 'data';

// 또는 ref.keepAlive() 사용
@riverpod
String conditionalData(ConditionalDataRef ref) {
  ref.keepAlive();  // 수동으로 유지
  return 'data';
}
```

### Issue 3: "ref.watch는 build 메서드 밖에서 사용 불가"
**Symptom:** 이벤트 핸들러에서 ref.watch 사용 시 에러

**Solution:**
```dart
// ❌ 잘못된 사용
onPressed: () {
  final value = ref.watch(someProvider);  // 에러!
}

// ✅ 올바른 사용
onPressed: () {
  final value = ref.read(someProvider);  // OK
  // 또는
  ref.read(someProvider.notifier).update();
}
```

### Issue 4: "AsyncValue를 직접 수정하면 안 됨"
**Symptom:** AsyncNotifier에서 state를 직접 할당하면 타입 에러

**Solution:**
```dart
// ❌ 잘못된 방법
Future<void> loadData() async {
  state = await repository.getData();  // 타입 에러!
}

// ✅ 올바른 방법
Future<void> loadData() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    return await repository.getData();
  });
}
```

---

## Best Practices

1. **Provider는 Application Layer에만 정의**: Domain과 Infrastructure Layer는 Riverpod에 의존하지 않아야 합니다. 이렇게 하면 비즈니스 로직을 순수하게 유지하고 테스트하기 쉬워집니다.

2. **ref.watch는 build 메서드에서만 사용**: 이벤트 핸들러나 콜백에서는 ref.read를 사용하세요. ref.watch를 잘못된 위치에서 사용하면 불필요한 리빌드가 발생합니다.

3. **Code Generation 사용 권장**: 수동 Provider 선언보다 @riverpod 어노테이션이 타입 안전성과 유지보수성이 높습니다. 특히 family modifier가 필요한 경우 코드가 훨씬 간결해집니다.

4. **AsyncNotifier는 AsyncValue.guard 사용**: 에러 처리를 자동으로 해주므로 try-catch 블록을 직접 작성할 필요가 없습니다.

5. **Repository는 Interface로 추상화**: Phase 전환 시 Provider DI만 수정하면 되므로, 반드시 Repository Interface를 만들고 Provider에서 구현체를 주입하세요.

6. **keepAlive는 신중하게 사용**: 대부분의 경우 autoDispose(기본값)가 적절합니다. keepAlive는 앱 전체에서 사용하는 설정값이나 서비스에만 사용하세요.

---

## References

- [Riverpod Official Documentation](https://riverpod.dev)
- [Riverpod Generator Package](https://pub.dev/packages/riverpod_generator)
- [Code Generation Guide](https://riverpod.dev/docs/concepts/about_code_generation)
- [Riverpod Lint Rules](https://pub.dev/packages/riverpod_lint)

---

## Integration with Flutter Architecture

### Feature-based 폴더 구조에서의 Provider 관리

```
features/tracking/
├── application/
│   ├── providers.dart                    # Repository Providers
│   ├── providers.g.dart                  # 생성 파일
│   └── notifiers/
│       ├── dose_list_notifier.dart       # Notifier
│       ├── dose_list_notifier.g.dart     # 생성 파일
│       ├── weight_records_notifier.dart
│       └── weight_records_notifier.g.dart
├── domain/
│   ├── entities/                         # Riverpod 의존성 없음
│   └── repositories/                     # Interface만
└── infrastructure/
    ├── repositories/                     # Riverpod 의존성 없음
    └── datasources/
```

### Provider 네이밍 컨벤션

Code generation은 자동으로 Provider 이름을 생성합니다:

```dart
// Function → functionNameProvider
@riverpod
String userName(UserNameRef ref) => 'John';
// 생성: userNameProvider

// Class → ClassNameProvider  
@riverpod
class Counter extends _$Counter { }
// 생성: counterProvider
```

**커스텀 네이밍이 필요한 경우:**
```yaml
# build.yaml
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          provider_name_suffix: "Pod"  # counterPod
```

---

## Phase 0 → Phase 1 전환 예시

**Phase 0 (Isar):**
```dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarMedicationRepository(isar);
}
```

**Phase 1 (Supabase):**
```dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationRepository(supabase);
}
```

**변경 사항:**
- Application Layer의 providers.dart 1개 파일만 수정
- Domain, Infrastructure, Presentation Layer는 수정 불필요
- 이것이 Repository Pattern + Riverpod의 핵심 장점입니다

---

## Gotchas

- **Code generation은 선택사항**: 없이도 사용 가능하지만, 이 프로젝트에서는 권장합니다.
- **부분 import 필요**: `part` 지시문을 빼먹으면 생성된 코드를 찾을 수 없습니다.
- **Build runner 실행 필수**: .g.dart 파일은 자동 생성되지 않으므로 명시적으로 실행해야 합니다.
- **autoDispose는 기본값**: keepAlive를 명시적으로 설정하지 않으면 자동 dispose됩니다.
- **AsyncValue는 immutable**: 직접 수정 불가하며 AsyncValue.guard()로 감싸야 합니다.
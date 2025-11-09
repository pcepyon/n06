# Isar Database Setup Guide for GLP-1 Treatment Management App

## Context
- **Goal:** 4-Layer Architecture에서 Infrastructure Layer의 로컬 데이터 저장소 구현
- **Database:** Isar 3.1.0 (NoSQL Embedded Database)
- **Use Case:** Phase 0에서 완전 오프라인 동작, DTO Pattern 기반 Repository 구현
- **Last Updated:** 2025-11-09
- **Database Version:** isar ^3.1.0, isar_flutter_libs ^3.1.0

---

## Why Isar for This Project

Isar는 Phase 0 (오프라인 MVP)에 최적화된 로컬 데이터베이스입니다:

**완전 오프라인 동작**: 네트워크 연결 없이 모든 데이터를 로컬에 저장하고 관리합니다. 의료 데이터를 다루는 Phase 0에서 안정적인 오프라인 기능은 필수적입니다.

**빠른 성능**: NoSQL 기반으로 읽기/쓰기 작업이 매우 빠르며, 인덱스를 통한 최적화된 쿼리를 지원합니다. 투여 기록, 체중 기록, 증상 기록 등 시계열 데이터를 빠르게 조회할 수 있습니다.

**Reactive API**: watchLazy()와 watch() 메서드로 데이터 변경을 자동으로 감지하여 UI를 업데이트합니다. Riverpod의 Stream Provider와 완벽하게 통합됩니다.

**타입 안전성**: Code generation을 통해 컴파일 타임에 타입 체크가 이루어져 런타임 에러를 방지합니다. 의료 데이터의 정확성이 중요한 앱에서 필수적입니다.

**쉬운 Phase 전환**: Phase 1에서 Supabase로 전환 시 Repository Interface는 그대로 유지하고 구현체만 교체하면 됩니다.

---

## Installation

### 1. pubspec.yaml에 패키지 추가

```yaml
dependencies:
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0  # Isar Core 바이너리 포함
  path_provider: ^2.1.0      # 앱 디렉토리 경로

dev_dependencies:
  isar_generator: ^3.1.0     # Code generation
  build_runner: ^2.4.0
```

### 2. 패키지 설치

```bash
flutter pub get
```

---

## Basic Setup

### 1. Isar Provider 설정 (Core Layer)

**전역 Isar 인스턴스 Provider 생성:**

```dart
// lib/core/database/isar_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// DTO Schemas import
import '../../features/tracking/infrastructure/dtos/dose_record_dto.dart';
import '../../features/tracking/infrastructure/dtos/weight_record_dto.dart';
import '../../features/tracking/infrastructure/dtos/symptom_record_dto.dart';
import '../../features/onboarding/infrastructure/dtos/user_profile_dto.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)  // 앱 전체에서 단일 인스턴스 유지
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  return await Isar.open(
    [
      // 모든 Collection Schema 등록
      DoseRecordDtoSchema,
      WeightRecordDtoSchema,
      SymptomRecordDtoSchema,
      UserProfileDtoSchema,
    ],
    directory: dir.path,
    name: 'glp1_database',  // 데이터베이스 이름
  );
}
```

### 2. DTO 정의 규칙

**Infrastructure Layer에서만 DTO 정의:**

```dart
// lib/features/tracking/infrastructure/dtos/dose_record_dto.dart
import 'package:isar/isar.dart';
import '../../domain/entities/dose.dart';

part 'dose_record_dto.g.dart';

@collection
class DoseRecordDto {
  Id id = Isar.autoIncrement;  // 자동 증가 ID
  
  late double doseMg;
  late DateTime administeredAt;
  String? injectionSite;
  String? notes;
  
  // Entity → DTO
  factory DoseRecordDto.fromEntity(Dose entity) {
    return DoseRecordDto()
      ..id = entity.id
      ..doseMg = entity.doseMg
      ..administeredAt = entity.administeredAt
      ..injectionSite = entity.injectionSite
      ..notes = entity.notes;
  }
  
  // DTO → Entity
  Dose toEntity() {
    return Dose(
      id: id,
      doseMg: doseMg,
      administeredAt: administeredAt,
      injectionSite: injectionSite,
      notes: notes,
    );
  }
}
```

### 3. Build Runner 실행

**자동 감지 모드 (권장):**
```bash
dart run build_runner watch -d
```

**일회성 생성:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

이 명령으로 `dose_record_dto.g.dart` 등의 Schema 파일이 자동 생성됩니다.

---

## Core Usage Patterns

### Pattern 1: Basic CRUD Operations

**Repository 구현체에서 Isar 사용:**

```dart
// lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart
import 'package:isar/isar.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/entities/dose.dart';
import '../dtos/dose_record_dto.dart';

class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  // CREATE
  @override
  Future<void> saveDose(Dose dose) async {
    final dto = DoseRecordDto.fromEntity(dose);
    
    await isar.writeTxn(() async {
      await isar.doseRecordDtos.put(dto);
    });
  }

  // READ (단일)
  @override
  Future<Dose?> getDoseById(int id) async {
    final dto = await isar.doseRecordDtos.get(id);
    return dto?.toEntity();
  }

  // READ (전체)
  @override
  Future<List<Dose>> getAllDoses() async {
    final dtos = await isar.doseRecordDtos
        .where()
        .sortByAdministeredAtDesc()
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  // UPDATE
  @override
  Future<void> updateDose(Dose dose) async {
    final dto = DoseRecordDto.fromEntity(dose);
    
    await isar.writeTxn(() async {
      await isar.doseRecordDtos.put(dto);  // put은 update도 처리
    });
  }

  // DELETE
  @override
  Future<void> deleteDose(int id) async {
    await isar.writeTxn(() async {
      await isar.doseRecordDtos.delete(id);
    });
  }
}
```

**핵심 포인트:**
- 모든 쓰기 작업은 `writeTxn()` 안에서 실행
- DTO ↔ Entity 변환은 Repository에서만 처리
- Domain Layer는 Isar을 전혀 모름

### Pattern 2: Reactive Queries (watchLazy)

**실시간 데이터 변경 감지:**

```dart
// lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart
class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  // Reactive Stream 반환
  @override
  Stream<List<Dose>> watchDoses() {
    // watchLazy: 변경 감지만, 데이터는 수동으로 로드
    return isar.doseRecordDtos
        .watchLazy()
        .asyncMap((_) async => await getAllDoses());
  }

  // 또는 watch 사용 (자동으로 데이터 로드)
  Stream<List<Dose>> watchDosesAlternative() {
    return isar.doseRecordDtos
        .where()
        .sortByAdministeredAtDesc()
        .watch(fireImmediately: true)  // 즉시 현재 데이터 emit
        .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
  }
}
```

**Riverpod에서 사용:**

```dart
// lib/features/tracking/application/notifiers/dose_list_notifier.dart
@riverpod
class DoseList extends _$DoseList {
  @override
  Stream<List<Dose>> build() {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.watchDoses();  // Isar의 reactive stream
  }
}

// Widget에서 자동으로 업데이트
class DoseListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(doseListProvider);
    
    return dosesAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (doses) => ListView.builder(...),  // 데이터 변경 시 자동 리빌드
    );
  }
}
```

### Pattern 3: Complex Queries with Filters

**조건부 쿼리:**

```dart
class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  // 날짜 범위로 필터링
  @override
  Future<List<Dose>> getDosesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dtos = await isar.doseRecordDtos
        .filter()
        .administeredAtBetween(startDate, endDate)
        .sortByAdministeredAtDesc()
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  // 특정 부위로 필터링
  @override
  Future<List<Dose>> getDosesBySite(String site) async {
    final dtos = await isar.doseRecordDtos
        .filter()
        .injectionSiteEqualTo(site)
        .sortByAdministeredAtDesc()
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  // 복합 조건
  @override
  Future<List<Dose>> getRecentHighDoses() async {
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    
    final dtos = await isar.doseRecordDtos
        .filter()
        .administeredAtGreaterThan(oneWeekAgo)
        .and()
        .doseMgGreaterThan(1.0)
        .sortByAdministeredAtDesc()
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  // 개수 제한
  @override
  Future<List<Dose>> getLatestDoses(int limit) async {
    final dtos = await isar.doseRecordDtos
        .where()
        .sortByAdministeredAtDesc()
        .limit(limit)
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
```

### Pattern 4: Embedded Objects

**중첩된 데이터 구조:**

```dart
// lib/features/tracking/infrastructure/dtos/symptom_record_dto.dart
import 'package:isar/isar.dart';

part 'symptom_record_dto.g.dart';

@collection
class SymptomRecordDto {
  Id id = Isar.autoIncrement;
  
  late DateTime recordedAt;
  late List<SymptomDetailDto> symptoms;  // Embedded 리스트
  String? notes;
}

// Embedded Object (별도 Collection이 아님)
@embedded
class SymptomDetailDto {
  late String symptomType;  // 'nausea', 'vomiting', 'diarrhea', etc.
  late int severityLevel;   // 1-5
  String? description;
}
```

**사용 예시:**

```dart
class IsarTrackingRepository implements TrackingRepository {
  final Isar isar;

  IsarTrackingRepository(this.isar);

  @override
  Future<void> saveSymptomRecord(SymptomRecord record) async {
    final dto = SymptomRecordDto()
      ..recordedAt = record.recordedAt
      ..symptoms = record.symptoms.map((s) => SymptomDetailDto()
        ..symptomType = s.symptomType
        ..severityLevel = s.severityLevel
        ..description = s.description
      ).toList()
      ..notes = record.notes;

    await isar.writeTxn(() async {
      await isar.symptomRecordDtos.put(dto);
    });
  }

  // Embedded 필드로 쿼리
  @override
  Future<List<SymptomRecord>> getHighSeveritySymptoms() async {
    final dtos = await isar.symptomRecordDtos
        .filter()
        .symptoms((q) => q.severityLevelGreaterThan(3))
        .findAll();
    
    return dtos.map((dto) => _toEntity(dto)).toList();
  }
}
```

---

## Complete Feature Example: Weight Tracking

### 1. Domain Entity

```dart
// lib/features/tracking/domain/entities/weight_record.dart
class WeightRecord {
  final int id;
  final double weightKg;
  final DateTime recordedAt;
  final String? notes;

  WeightRecord({
    required this.id,
    required this.weightKg,
    required this.recordedAt,
    this.notes,
  });
}
```

### 2. Infrastructure DTO

```dart
// lib/features/tracking/infrastructure/dtos/weight_record_dto.dart
import 'package:isar/isar.dart';
import '../../domain/entities/weight_record.dart';

part 'weight_record_dto.g.dart';

@collection
class WeightRecordDto {
  Id id = Isar.autoIncrement;
  
  @Index()  // 인덱스 추가로 쿼리 최적화
  late DateTime recordedAt;
  
  late double weightKg;
  String? notes;

  factory WeightRecordDto.fromEntity(WeightRecord entity) {
    return WeightRecordDto()
      ..id = entity.id
      ..weightKg = entity.weightKg
      ..recordedAt = entity.recordedAt
      ..notes = entity.notes;
  }

  WeightRecord toEntity() {
    return WeightRecord(
      id: id,
      weightKg: weightKg,
      recordedAt: recordedAt,
      notes: notes,
    );
  }
}
```

### 3. Repository 구현

```dart
// lib/features/tracking/infrastructure/repositories/isar_tracking_repository.dart
import 'package:isar/isar.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../../domain/entities/weight_record.dart';
import '../dtos/weight_record_dto.dart';

class IsarTrackingRepository implements TrackingRepository {
  final Isar isar;

  IsarTrackingRepository(this.isar);

  @override
  Stream<List<WeightRecord>> watchWeightRecords() {
    return isar.weightRecordDtos
        .where()
        .sortByRecordedAtDesc()
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
  }

  @override
  Future<void> saveWeightRecord(WeightRecord record) async {
    final dto = WeightRecordDto.fromEntity(record);
    
    await isar.writeTxn(() async {
      await isar.weightRecordDtos.put(dto);
    });
  }

  @override
  Future<List<WeightRecord>> getWeightRecords() async {
    final dtos = await isar.weightRecordDtos
        .where()
        .sortByRecordedAtDesc()
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<WeightRecord?> getLatestWeight() async {
    final dto = await isar.weightRecordDtos
        .where()
        .sortByRecordedAtDesc()
        .findFirst();
    
    return dto?.toEntity();
  }

  @override
  Future<List<WeightRecord>> getWeightHistory(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final dtos = await isar.weightRecordDtos
        .filter()
        .recordedAtGreaterThan(startDate)
        .sortByRecordedAt()
        .findAll();
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> deleteWeightRecord(int id) async {
    await isar.writeTxn(() async {
      await isar.weightRecordDtos.delete(id);
    });
  }
}
```

### 4. Application Provider

```dart
// lib/features/tracking/application/providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/tracking_repository.dart';
import '../infrastructure/repositories/isar_tracking_repository.dart';
import '../../../core/database/isar_provider.dart';

part 'providers.g.dart';

@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarTrackingRepository(isar);
}
```

### 5. Presentation Layer

```dart
// lib/features/tracking/presentation/screens/weight_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/notifiers/weight_records_notifier.dart';

class WeightTrackingScreen extends ConsumerWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightsAsync = ref.watch(weightRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('체중 기록')),
      body: weightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('에러: $error')),
        data: (weights) {
          if (weights.isEmpty) {
            return const Center(child: Text('체중 기록이 없습니다'));
          }

          return ListView.builder(
            itemCount: weights.length,
            itemBuilder: (context, index) {
              final weight = weights[index];
              return ListTile(
                leading: const Icon(Icons.monitor_weight),
                title: Text('${weight.weightKg} kg'),
                subtitle: Text(_formatDate(weight.recordedAt)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await ref.read(weightRecordsProvider.notifier)
                             .deleteRecord(weight.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddWeightDialog(BuildContext context, WidgetRef ref) {
    // ... Dialog 구현
  }
}
```

---

## Advanced Features

### 1. Indexes for Performance

**쿼리 성능 최적화:**

```dart
@collection
class DoseRecordDto {
  Id id = Isar.autoIncrement;
  
  @Index()  // 단일 필드 인덱스
  late DateTime administeredAt;
  
  @Index(type: IndexType.value)  // 정렬 최적화
  late double doseMg;
  
  String? injectionSite;
}

// 복합 인덱스
@collection
class SymptomRecordDto {
  Id id = Isar.autoIncrement;
  
  @Index(composite: [CompositeIndex('severityLevel')])
  late DateTime recordedAt;
  
  late int severityLevel;
}
```

### 2. Batch Operations

**여러 작업을 한 번에:**

```dart
class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  IsarMedicationRepository(this.isar);

  // 여러 투여 기록 한 번에 저장
  @override
  Future<void> saveDoseBatch(List<Dose> doses) async {
    final dtos = doses.map((d) => DoseRecordDto.fromEntity(d)).toList();
    
    await isar.writeTxn(() async {
      await isar.doseRecordDtos.putAll(dtos);
    });
  }

  // 여러 기록 한 번에 삭제
  @override
  Future<void> deleteDoseBatch(List<int> ids) async {
    await isar.writeTxn(() async {
      await isar.doseRecordDtos.deleteAll(ids);
    });
  }

  // 모든 데이터 삭제
  @override
  Future<void> clearAllDoses() async {
    await isar.writeTxn(() async {
      await isar.doseRecordDtos.clear();
    });
  }
}
```

### 3. Aggregation Queries

**통계 및 집계:**

```dart
class IsarTrackingRepository implements TrackingRepository {
  final Isar isar;

  IsarTrackingRepository(this.isar);

  // 평균 체중 계산
  @override
  Future<double?> getAverageWeight(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final records = await isar.weightRecordDtos
        .filter()
        .recordedAtGreaterThan(startDate)
        .findAll();
    
    if (records.isEmpty) return null;
    
    final sum = records.fold<double>(
      0.0, 
      (sum, record) => sum + record.weightKg,
    );
    
    return sum / records.length;
  }

  // 체중 변화량
  @override
  Future<double?> getWeightChange() async {
    final records = await isar.weightRecordDtos
        .where()
        .sortByRecordedAt()
        .findAll();
    
    if (records.length < 2) return null;
    
    final firstWeight = records.first.weightKg;
    final lastWeight = records.last.weightKg;
    
    return lastWeight - firstWeight;
  }

  // 투여 횟수 카운트
  @override
  Future<int> getDoseCount(DateTime startDate, DateTime endDate) async {
    return await isar.doseRecordDtos
        .filter()
        .administeredAtBetween(startDate, endDate)
        .count();
  }
}
```

### 4. Full-Text Search (Optional)

**텍스트 검색이 필요한 경우:**

```dart
@collection
class SymptomRecordDto {
  Id id = Isar.autoIncrement;
  
  late DateTime recordedAt;
  
  @Index(type: IndexType.value, caseSensitive: false)
  String? notes;  // 노트에 대한 검색
}

// 검색 구현
Future<List<SymptomRecord>> searchSymptomsByNotes(String query) async {
  final dtos = await isar.symptomRecordDtos
      .filter()
      .notesContains(query, caseSensitive: false)
      .findAll();
  
  return dtos.map((dto) => dto.toEntity()).toList();
}
```

---

## Testing & Validation

### Isar 테스트 체크리스트

- [ ] DTO ↔ Entity 변환이 정확한가?
- [ ] 모든 Collection Schema가 Isar.open()에 등록되었는가?
- [ ] 쓰기 작업이 모두 writeTxn() 안에 있는가?
- [ ] watchLazy()가 데이터 변경을 정확히 감지하는가?
- [ ] 복합 쿼리가 예상대로 동작하는가?
- [ ] 인덱스가 필요한 필드에 @Index()가 있는가?

### Debug with Isar Inspector

**실시간 데이터베이스 검사:**

1. 앱을 디버그 모드로 실행:
   ```bash
   flutter run
   ```

2. 콘솔에 표시되는 Inspector 링크 클릭:
   ```
   Isar Inspector: http://localhost:12345
   ```

3. Inspector에서 가능한 작업:
   - Collection 데이터 실시간 확인
   - 쿼리 직접 실행
   - 데이터 추가/수정/삭제
   - 인덱스 사용 여부 확인

### Testing with Mock Data

```dart
// test/features/tracking/isar_medication_repository_test.dart
void main() {
  late Isar isar;
  late IsarMedicationRepository repository;

  setUp(() async {
    // 테스트용 메모리 데이터베이스
    isar = await Isar.open(
      [DoseRecordDtoSchema],
      directory: Directory.systemTemp.path,
      name: 'test_db_${DateTime.now().millisecondsSinceEpoch}',
    );
    repository = IsarMedicationRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  test('투여 기록 저장 및 조회', () async {
    final dose = Dose(
      id: 1,
      doseMg: 0.5,
      administeredAt: DateTime.now(),
    );

    await repository.saveDose(dose);
    final retrieved = await repository.getDoseById(1);

    expect(retrieved, isNotNull);
    expect(retrieved!.doseMg, 0.5);
  });

  test('날짜 범위 쿼리', () async {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    
    // 어제 투여
    await repository.saveDose(Dose(
      id: 1,
      doseMg: 0.5,
      administeredAt: yesterday,
    ));
    
    // 오늘 투여
    await repository.saveDose(Dose(
      id: 2,
      doseMg: 0.75,
      administeredAt: now,
    ));

    final todayDoses = await repository.getDosesByDateRange(
      now.subtract(Duration(hours: 1)),
      now.add(Duration(hours: 1)),
    );

    expect(todayDoses.length, 1);
    expect(todayDoses.first.doseMg, 0.75);
  });
}
```

---

## Common Issues & Solutions

### Issue 1: "No Isar instance found"
**Symptom:** Isar 인스턴스를 찾을 수 없다는 에러

**Solution:**
```dart
// ❌ 잘못된 방법
final isar = Isar.getInstance();  // 에러!

// ✅ 올바른 방법
final isar = await Isar.open([...]);  // 먼저 open

// 또는 Riverpod 사용
final isar = ref.watch(isarProvider).requireValue;
```

### Issue 2: "Bad state: Cannot write, transaction already open"
**Symptom:** 이미 열린 트랜잭션 안에서 또 writeTxn() 호출

**Solution:**
```dart
// ❌ 중첩된 트랜잭션
await isar.writeTxn(() async {
  await isar.writeTxn(() async {  // 에러!
    await isar.doseRecordDtos.put(dto);
  });
});

// ✅ 단일 트랜잭션
await isar.writeTxn(() async {
  await isar.doseRecordDtos.put(dto1);
  await isar.doseRecordDtos.put(dto2);  // 같은 트랜잭션 안에서
});
```

### Issue 3: ".g.dart 파일을 찾을 수 없습니다"
**Symptom:** part 지시문에서 .g.dart 파일 에러

**Solution:**
```bash
# Build runner 실행
dart run build_runner build --delete-conflicting-outputs

# 또는 watch 모드
dart run build_runner watch -d
```

**확인 사항:**
- `part 'filename.g.dart';` 선언이 있는가?
- @collection 어노테이션이 있는가?
- isar_generator가 dev_dependencies에 있는가?

### Issue 4: "Type 'List<Embedded>' is not supported"
**Symptom:** List<CustomClass>를 사용하려고 할 때 에러

**Solution:**
```dart
// ❌ 일반 클래스 리스트
@collection
class RecordDto {
  late List<CustomClass> items;  // 에러!
}

// ✅ @embedded 클래스 리스트
@collection
class RecordDto {
  late List<EmbeddedClass> items;  // OK
}

@embedded
class EmbeddedClass {
  String? field;
}
```

### Issue 5: "watchLazy가 변경을 감지하지 않음"
**Symptom:** 데이터 변경 후 Stream이 emit되지 않음

**Solution:**
```dart
// ❌ 트랜잭션 없이 쓰기
isar.doseRecordDtos.put(dto);  // watcher에 알림 안 됨

// ✅ 트랜잭션 안에서 쓰기
await isar.writeTxn(() async {
  await isar.doseRecordDtos.put(dto);  // watcher에 알림됨
});
```

---

## Best Practices

1. **DTO는 Infrastructure Layer에만**: Domain Entity와 Isar DTO를 명확히 분리하세요. Entity는 Isar을 모르고, DTO는 비즈니스 로직을 모릅니다.

2. **writeTxn은 필수**: 모든 쓰기 작업(put, delete, clear)은 반드시 writeTxn() 안에서 실행하세요. 그래야 ACID 보장과 watcher 알림이 작동합니다.

3. **인덱스는 신중하게**: 자주 쿼리하는 필드에만 @Index()를 추가하세요. 인덱스가 많으면 쓰기 성능이 저하됩니다.

4. **watchLazy vs watch**: 대부분은 watchLazy()를 사용하고 수동으로 데이터를 로드하세요. watch()는 자동 로드하지만 불필요한 쿼리가 실행될 수 있습니다.

5. **Batch 작업 활용**: 여러 개의 레코드를 저장/삭제할 때는 putAll(), deleteAll()을 사용하여 트랜잭션 오버헤드를 줄이세요.

6. **keepAlive Provider**: Isar Provider는 @Riverpod(keepAlive: true)로 설정하여 앱 전체에서 단일 인스턴스를 유지하세요.

---

## References

- [Isar Official Documentation](https://isar.dev)
- [Isar Package on pub.dev](https://pub.dev/packages/isar)
- [Isar GitHub Repository](https://github.com/isar/isar)
- [Schema Documentation](https://isar.dev/schema.html)
- [Queries Documentation](https://isar.dev/queries.html)
- [Watchers Documentation](https://isar.dev/watchers.html)

---

## Integration with 4-Layer Architecture

### Layer별 Isar 사용 규칙

```
Presentation Layer
└── Isar 직접 사용 금지

Application Layer  
└── Isar 직접 사용 금지
    └── Repository Provider만 사용

Domain Layer
└── Isar 의존성 완전 제거
    └── Repository Interface만 정의

Infrastructure Layer
└── Isar 사용 허용
    ├── DTO 정의 (@collection)
    ├── Repository 구현체
    └── Isar 직접 접근
```

### 폴더 구조

```
features/tracking/
├── domain/
│   ├── entities/
│   │   └── dose.dart              # Pure Dart, Isar 모름
│   └── repositories/
│       └── medication_repository.dart  # Interface
├── infrastructure/
│   ├── dtos/
│   │   ├── dose_record_dto.dart   # @collection
│   │   └── dose_record_dto.g.dart # 생성 파일
│   └── repositories/
│       └── isar_medication_repository.dart  # Isar 사용
└── application/
    └── providers.dart              # Repository DI
```

---

## Phase 0 → Phase 1 Migration Path

**Phase 0 (현재):**
```dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarMedicationRepository(isar);  // Isar 구현체
}
```

**Phase 1 (Supabase 추가):**
```dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationRepository(supabase);  // Supabase 구현체
}

// Isar는 로컬 캐시로 유지 가능
@riverpod
MedicationRepository medicationLocalCache(MedicationLocalCacheRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarMedicationRepository(isar);
}
```

**마이그레이션 전략:**
1. Supabase Repository 구현체 추가
2. Provider DI만 변경 (1줄)
3. Domain/Application/Presentation Layer는 수정 불필요
4. 필요시 Isar를 로컬 캐시로 병행 사용

---

## Data Migration Example

**버전 업데이트 시 스키마 마이그레이션:**

```dart
// lib/core/database/isar_provider.dart
@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  return await Isar.open(
    [
      DoseRecordDtoSchema,
      WeightRecordDtoSchema,
    ],
    directory: dir.path,
    name: 'glp1_database',
    // 마이그레이션 로직
    inspector: true,  // 디버그 모드에서 Inspector 활성화
  );
}

// 스키마 변경 시 처리 예시
// 1. 새 필드 추가: 자동으로 null로 초기화
// 2. 필드 이름 변경: 데이터 마이그레이션 필요
// 3. 필드 타입 변경: 데이터 마이그레이션 필요

// 마이그레이션 헬퍼 함수
Future<void> migrateOldData(Isar isar) async {
  // 예: 모든 레코드의 새 필드 초기화
  await isar.writeTxn(() async {
    final records = await isar.doseRecordDtos.where().findAll();
    
    for (final record in records) {
      // 새 필드 설정
      record.injectionSite ??= 'unknown';
      await isar.doseRecordDtos.put(record);
    }
  });
}
```

---

## Gotchas

- **Code generation 필수**: @collection 사용 시 build_runner 실행 필수
- **Auto-increment ID**: `Id id = Isar.autoIncrement` 사용 권장
- **Transaction 범위**: writeTxn은 중첩 불가능, 하나의 트랜잭션 안에서 여러 작업 수행
- **watchLazy는 lazy**: 변경 알림만 받고 데이터는 수동으로 로드해야 함
- **Embedded 제약**: @embedded 클래스는 Id를 가질 수 없음
- **String ID 불가**: Isar는 int ID만 지원, String ID가 필요하면 별도 필드로 관리
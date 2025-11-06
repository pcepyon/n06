# Code Structure

## Feature → Requirements 매핑

| 기능 ID | 기능명 | 위치 |
|---------|--------|------|
| F-001 | 소셜 로그인 | `features/authentication/` |
| F000 | 온보딩 | `features/onboarding/` |
| F001 | 투여 스케줄러 | `features/tracking/` |
| F002 | 증상/체중 기록 | `features/tracking/` |
| F003 | 데이터 공유 모드 | `features/data_sharing/` |
| F004 | 대처 가이드 | `features/tracking/` |
| F005 | 증상 체크 | `features/tracking/` |
| F006 | 홈 대시보드 | `features/dashboard/` |

---

## 폴더 구조

### Top Level

```
lib/
├── features/          # 기능별 모듈
│   ├── authentication/
│   ├── onboarding/
│   ├── tracking/      # F001, F002, F004, F005
│   ├── data_sharing/  # F003
│   └── dashboard/     # F006
│
├── core/              # 전역 공통
│   ├── constants/
│   ├── errors/
│   ├── routing/
│   ├── analytics/
│   └── utils/
│
└── main.dart
```

### Core 상세

```
core/
├── constants/
│   ├── app_constants.dart
│   └── ui_constants.dart
├── errors/
│   ├── domain_exception.dart
│   └── repository_exception.dart
├── routing/
│   └── app_router.dart
├── analytics/
│   ├── analytics_service.dart
│   ├── analytics_events.dart
│   └── crashlytics_service.dart
└── utils/
    ├── date_utils.dart
    ├── validators.dart
    └── formatters.dart
```

### Feature 상세 (4-Layer)

```
features/tracking/
├── presentation/      # UI
│   ├── screens/
│   └── widgets/
├── application/       # 상태 관리
│   ├── notifiers/
│   └── providers.dart
├── domain/            # 비즈니스 로직
│   ├── entities/
│   ├── usecases/
│   └── repositories/  # Interface만
└── infrastructure/    # 데이터 접근
    ├── repositories/  # 구현체
    ├── datasources/
    └── dtos/
```

---

## 4-Layer Architecture

**의존성 방향**: Presentation → Application → Domain ← Infrastructure

### Layer 책임

| Layer | 기술 | 책임 |
|-------|------|------|
| **Presentation** | Flutter Widgets | UI 렌더링, 사용자 입력 |
| **Application** | Riverpod Notifier | 상태 관리, UseCase 호출 |
| **Domain** | Pure Dart | 비즈니스 로직, Entity |
| **Infrastructure** | Isar/Supabase | Repository 구현, DB 접근 |

---

## 핵심 패턴

### 1. Repository Pattern

**Interface (Domain Layer)**
```dart
// domain/repositories/medication_repository.dart
abstract class MedicationRepository {
  Stream<List<Dose>> watchDoses();
  Future<void> saveDose(Dose dose);
}
```

**구현체 (Infrastructure Layer)**
```dart
// infrastructure/repositories/isar_medication_repository.dart
class IsarMedicationRepository implements MedicationRepository {
  final Isar isar;

  @override
  Stream<List<Dose>> watchDoses() {
    return isar.doseRecordDtos
      .watchLazy()
      .map((_) => _loadDoses());
  }

  @override
  Future<void> saveDose(Dose dose) async {
    final dto = DoseRecordDto.fromEntity(dose);
    await isar.writeTxn(() => isar.doseRecordDtos.put(dto));
  }
}
```

**DI (Application Layer)**
```dart
// application/providers.dart
@riverpod
MedicationRepository medicationRepository(ref) {
  return IsarMedicationRepository(ref.watch(isarProvider));
}
```

### 2. DTO ↔ Entity

**DTO (Infrastructure)**
```dart
@collection
class DoseRecordDto {
  Id id = Isar.autoIncrement;
  late double doseMg;
  late DateTime administeredAt;

  Dose toEntity() => Dose(
    id: id,
    doseMg: doseMg,
    administeredAt: administeredAt,
  );
}
```

**Entity (Domain)**
```dart
class Dose {
  final int id;
  final double doseMg;
  final DateTime administeredAt;

  Dose({
    required this.id,
    required this.doseMg,
    required this.administeredAt,
  });
}
```

### 3. UseCase (Optional)

```dart
// domain/usecases/recalculate_dose_schedule_usecase.dart
class RecalculateDoseScheduleUseCase {
  final MedicationRepository repository;

  Future<List<DoseSchedule>> execute(DosagePlan plan) async {
    // 비즈니스 로직
    final schedules = _calculate(plan);
    await repository.saveDoseSchedules(schedules);
    return schedules;
  }
}
```

---

## Phase 전환

### Phase 0
```
infrastructure/repositories/
├── medication_repository.dart      # Interface
└── isar_medication_repository.dart # 구현체
```

### Phase 1 추가
```
infrastructure/repositories/
├── medication_repository.dart          # Interface (동일)
├── isar_medication_repository.dart     # 구현체 (유지)
└── supabase_medication_repository.dart # 구현체 (추가)
```

**변경**: Provider DI 1줄만 수정

```dart
// Phase 0 → Phase 1
return IsarMedicationRepository(...)
     ↓
return SupabaseMedicationRepository(...)
```

---

## 규칙

### DO ✅
- Repository Interface를 통한 데이터 접근
- DTO는 Infrastructure, Entity는 Domain
- 비즈니스 로직은 Domain Layer에만
- 여러 Repository 조합은 Application Layer

### DON'T ❌
- Application에서 Isar 직접 접근
- Presentation에서 Repository 직접 호출
- Domain Layer에 Flutter/Isar 의존성
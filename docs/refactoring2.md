# GLP-1 MVP 코드베이스 개선 계획 (Refactoring Phase 2)

## 문서 정보
- **작성일**: 2025-11-11
- **기준 문서**:
  - `docs/external/riverpod_설정가이드.md`
  - `docs/external/IsarDB_설정가이드.md`
- **목적**: 4-Layer 아키텍처 및 Riverpod 3.x 가이드라인 준수
- **예상 소요 시간**: 3-4시간
- **작업 개수**: 34개 세부 작업

---

## 발견된 오류 및 문제점

제시된 가이드라인은 4-Layer 아키텍처와 Riverpod Code Generation을 중심으로 명확하게 정의되어 있으나, 실제 코드베이스에서 몇 가지 중요한 원칙 위반과 구현 오류가 발견되었습니다.

| ID | 파일 경로 | 오류/문제점 | 가이드라인 위반 / 문제 유형 |
| :--- | :--- | :--- | :--- |
| **F1** | `lib/features/notification/domain/value_objects/notification_time.dart` | **Domain Layer의 Flutter 의존성 (Critical)**: Value Object인 `NotificationTime`이 `package:flutter/material.dart`의 `TimeOfDay`를 직접 import하고 사용하고 있습니다. | **CRITICAL DEVIATION**: Domain Layer는 순수 Dart 클래스로 구성되어야 하며, Flutter 프레임워크에 의존해서는 안 됩니다. 이는 **4-Layer 아키텍처의 핵심 원칙** (Domain Layer의 순수성)을 위반하며, 테스트 용이성과 계층 간 분리를 심각하게 저해합니다. |
| **F2** | `lib/features/tracking/application/providers.dart` | **Provider 종속성 미완료 (Major)**: `trackingNotifierProvider`의 주석에는 `userId`를 `AuthNotifier`에서 가져와야 한다고 명시되어 있으나, 실제 코드에서는 `userId: null`로 하드코딩되어 있습니다. | **MAJOR ERROR**: Notifier가 필수적인 사용자 ID를 받지 못해 제대로 초기화되지 않거나, `trackingRepository.getWeightLogs(null)` 호출 시 잠재적인 런타임 오류 및 데이터 무결성 문제를 유발할 수 있습니다. |
| **F3** | `lib/features/tracking/application/notifiers/medication_notifier.dart` | **레거시 StateNotifier 사용 (Minor)**: 가이드라인에서 권장하는 `AsyncNotifier` 대신 `StateNotifier`가 사용되었습니다. 이로 인해 `AsyncValue` 관리를 위해 `MedicationState` 클래스를 수동으로 정의하고, 상태 로딩을 위한 `initialize(String userId)` 메서드를 외부에서 호출해야 합니다. | **MINOR DEVIATION**: "Code Generation 사용 권장" 원칙 위반 및 보일러플레이트 증가. `AsyncNotifier`의 `build` 메서드를 활용하는 Riverpod의 현대적인 패턴을 따르지 못하고 있습니다. |
| **F4** | `lib/features/tracking/infrastructure/dtos/dose_schedule_dto.dart` | **DTO 데이터 타입 불일치 (Minor)**: `DoseScheduleDto`는 엔티티의 `notificationTime` 필드(`Object?` 타입)를 `String? notificationTimeStr`로 변환하여 저장합니다. 이 과정에서 `NotificationTime` 객체가 `toString()`으로 저장되는데, 이로 인해 DTO와 엔티티 간의 타입 변환 로직이 명확하지 않고 수동 직렬화/역직렬화에 의존하게 됩니다. | **MINOR ISSUE**: 데이터 모델링의 명확성 부족. `NotificationTime` 객체 자체를 `Embedded` 객체로 저장하거나, 명확한 타입으로 관리해야 합니다. |
| **F5** | `lib/features/tracking/infrastructure/repositories/isar_tracking_repository.dart` | **Isar 트랜잭션 내 Upsert 구현 (Best Practice Adherence)**: `saveWeightLog`에서 기존 기록 조회 및 삭제 (`findAll` 및 `deleteAll`) 후 새 기록 저장 (`put`) 작업을 하나의 `writeTxn` 내부에서 수행하고 있습니다. | **BEST PRACTICE ADHERENCE**: 이는 **"모든 쓰기 작업은 writeTxn() 안에서 실행"**이라는 Isar 가이드라인을 *매우 잘 준수한* 구현입니다. 동시성 및 데이터 무결성을 보장합니다. |

---

## 수정 계획

위에서 발견된 주요 오류 (F1, F2) 및 개선 사항 (F3, F4)에 대한 수정 계획은 다음과 같습니다.

### **P1: Domain Layer Flutter 의존성 제거 (F1 수정)**

**목표**: Domain Layer의 순수성 확보 - Flutter 프레임워크 의존성 완전 제거

1. **`NotificationTime` 리팩토링:**
   - `lib/features/notification/domain/value_objects/notification_time.dart` 파일에서 `import 'package:flutter/material.dart';`를 제거합니다.
   - `fromTimeOfDay(TimeOfDay)` 및 `toTimeOfDay()` 메서드를 삭제합니다.
   - **Flutter 의존성 주입**: `lib/features/notification/presentation/screens/notification_settings_screen.dart`에서 `TimePickerButton`과의 통신 시 `TimeOfDay` ↔ `NotificationTime` 변환을 수행하도록 로직을 수정합니다.

2. **`NotificationSettings` 확인:**
   - `lib/features/notification/domain/entities/notification_settings.dart`에서 `TimeOfDay` 관련 코드가 사용되지 않도록 확인합니다. (현재 이미 `NotificationTime`만 사용 중)

**파일 구조:**
```
lib/features/notification/domain/value_objects/notification_time.dart  [수정]
└─> lib/features/notification/presentation/screens/notification_settings_screen.dart  [수정]
    └─> test/features/notification/domain/value_objects/notification_time_test.dart  [수정 필요시]
```

---

### **P2: Provider 종속성 미완료 수정 (F2 수정)**

**목표**: `trackingNotifierProvider`에 올바른 userId 주입

1. **`AuthNotifier` 구독:**
   - `lib/features/tracking/application/providers.dart` 파일 내 `trackingNotifierProvider`의 `StateNotifierProvider` 로직을 수정하여 `authNotifierProvider`를 `ref.watch`로 구독하고 사용자 ID를 추출하도록 변경합니다.

**수정 코드:**
```dart
// lib/features/tracking/application/providers.dart
final trackingNotifierProvider =
    StateNotifierProvider.autoDispose<TrackingNotifier, AsyncValue<TrackingState>>(
  (ref) {
    final repository = ref.watch(trackingRepositoryProvider);
    // [수정] AuthNotifier에서 userId를 가져와서 주입
    final userId = ref.watch(authNotifierProvider).value?.id;

    return TrackingNotifier(
      repository: repository,
      userId: userId, // <-- 수정: userId 주입
    );
  },
);
```

**영향 파일:**
```
lib/features/tracking/application/providers.dart  [수정]
├─> lib/features/authentication/application/notifiers/auth_notifier.dart  [참조]
└─> test/features/tracking/application/notifiers/tracking_notifier_test.dart  [테스트 수정 필요]
```

---

### **P3: Medication Notifier 현대화 (F3 개선)**

**목표**: StateNotifier에서 AsyncNotifier로 전환하여 Riverpod 3.x 현대적 패턴 적용

1. **`MedicationNotifier` 변환 (AsyncNotifier):**
   - `lib/features/tracking/application/notifiers/medication_notifier.dart`를 `AsyncNotifier`로 전환하여 `build` 메서드 내에서 `authNotifierProvider`를 `ref.watch`하고 비동기 데이터 로딩을 수행하도록 변경합니다.
   - 이를 통해 외부에서 `initialize`를 호출할 필요 없이, Riverpod이 자동으로 상태를 관리하게 됩니다.

**변경 전후 비교:**
```dart
// Before: StateNotifier with initialize()
class MedicationNotifier extends StateNotifier<MedicationState> {
  late String _userId;

  MedicationNotifier({ ... }) : super(...);

  Future<void> initialize(String userId) async {
    _userId = userId;
    await _loadMedicationData();
  }
}

// After: AsyncNotifier with build()
@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  @override
  Future<MedicationState> build() async {
    final userId = ref.watch(authNotifierProvider).value?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Auto-load data
    final plan = await _repository.getActiveDosagePlan(userId);
    // ...
    return MedicationState(...);
  }

  // initialize() 메서드 제거
  // _userId 필드 제거
}
```

**Provider 정의 변경:**
```dart
// Before: StateNotifierProvider
final medicationNotifierProvider = StateNotifierProvider.autoDispose<
    MedicationNotifier,
    MedicationState>((ref) {
  return MedicationNotifier(...);
});

// After: AsyncNotifierProvider
@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  // ... 위 코드
}
// 자동 생성: medicationNotifierProvider
```

**영향 파일:**
```
lib/features/tracking/application/notifiers/medication_notifier.dart  [대규모 수정]
├─> lib/features/tracking/application/providers.dart  [Provider 정의 변경]
├─> lib/features/authentication/application/notifiers/auth_notifier.dart  [참조]
└─> test/features/tracking/application/notifiers/medication_notifier_test.dart  [테스트 수정 필요]
```

---

### **P4: DoseSchedule DTO 타입 명확화 (F4 개선)**

**목표**: `Object?` 타입을 명확한 `NotificationTime?`으로 변경하고 DTO 변환 로직 개선

1. **`NotificationTime` Isar Embedded로 전환:**
   - `lib/features/notification/domain/value_objects/notification_time.dart`를 순수 Dart 클래스로 만든 후 (P1 완료 필요), Infrastructure Layer에서 DTO로 변환할 때 primitive 타입(hour/minute)으로 저장하도록 리팩토링합니다.
   - `DoseScheduleDto`의 `notificationTimeStr` 필드를 삭제하고, `notificationHour`, `notificationMinute` 필드를 추가합니다.
   - `DoseSchedule` 엔티티의 `notificationTime` 필드 타입을 `Object?` 대신 `NotificationTime?`로 변경하여 명확성을 높입니다.

**Domain Entity 수정:**
```dart
// lib/features/tracking/domain/entities/dose_schedule.dart
class DoseSchedule extends Equatable {
  final String id;
  final String dosagePlanId;
  final DateTime scheduledDate;
  final double scheduledDoseMg;
  final NotificationTime? notificationTime;  // Object? → NotificationTime?
  final DateTime createdAt;

  // copyWith 파라미터도 수정
  DoseSchedule copyWith({
    String? id,
    String? dosagePlanId,
    DateTime? scheduledDate,
    double? scheduledDoseMg,
    NotificationTime? notificationTime,  // DateTime? → NotificationTime?
    DateTime? createdAt,
  }) { ... }
}
```

**DTO 수정:**
```dart
// lib/features/tracking/infrastructure/dtos/dose_schedule_dto.dart
@collection
class DoseScheduleDto {
  Id? id = Isar.autoIncrement;
  late String scheduleId;
  late String dosagePlanId;
  late DateTime scheduledDate;
  late double scheduledDoseMg;

  // 변경: String? notificationTimeStr 제거
  int? notificationHour;    // 0-23 or null
  int? notificationMinute;  // 0-59 or null

  late DateTime createdAt;

  DoseScheduleDto.fromEntity(DoseSchedule entity) {
    scheduleId = entity.id;
    dosagePlanId = entity.dosagePlanId;
    scheduledDate = entity.scheduledDate;
    scheduledDoseMg = entity.scheduledDoseMg;

    // NotificationTime → hour/minute
    if (entity.notificationTime != null) {
      notificationHour = entity.notificationTime!.hour;
      notificationMinute = entity.notificationTime!.minute;
    } else {
      notificationHour = null;
      notificationMinute = null;
    }

    createdAt = entity.createdAt;
  }

  DoseSchedule toEntity() {
    // hour/minute → NotificationTime
    NotificationTime? notificationTime;
    if (notificationHour != null && notificationMinute != null) {
      notificationTime = NotificationTime(
        hour: notificationHour!,
        minute: notificationMinute!,
      );
    }

    return DoseSchedule(
      id: scheduleId,
      dosagePlanId: dosagePlanId,
      scheduledDate: scheduledDate,
      scheduledDoseMg: scheduledDoseMg,
      notificationTime: notificationTime,
      createdAt: createdAt,
    );
  }
}
```

**영향 파일:**
```
lib/features/tracking/domain/entities/dose_schedule.dart  [타입 수정]
├─> lib/features/tracking/infrastructure/dtos/dose_schedule_dto.dart  [구조 변경]
├─> lib/features/tracking/domain/usecases/dose_notification_usecase.dart  [로직 확인]
├─> lib/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart  [영향 확인]
├─> test/features/tracking/domain/entities/dose_schedule_test.dart  [테스트 수정]
└─> test/features/tracking/infrastructure/repositories/isar_dose_schedule_repository_test.dart  [테스트 수정]
```

**참고**: `NotificationSettingsDto`는 이미 이 패턴을 사용 중입니다:
```dart
// lib/features/notification/infrastructure/dtos/notification_settings_dto.dart
@collection
class NotificationSettingsDto {
  late int notificationHour;    // ✅ 이미 hour/minute 분리
  late int notificationMinute;

  NotificationSettings toEntity() {
    return NotificationSettings(
      notificationTime: NotificationTime(
        hour: notificationHour,
        minute: notificationMinute,
      ),
      ...
    );
  }
}
```

---

## 주요 발견 사항

### ✅ **좋은 점: 이미 준수 중인 부분**

1. **NotificationSettingsDto**: 이미 `NotificationTime`을 `hour`/`minute`으로 분리하여 저장 중 (P4 패턴 선행 적용)
2. **TrackingNotifier**: `userId`가 `null`인 경우를 `_init()` 메서드에서 이미 안전하게 처리 중
3. **IsarTrackingRepository**: `writeTxn` 내에서 upsert 작업을 원자적으로 수행하여 Isar 가이드라인 준수

### ⚠️ **추가 영향 범위**

제시된 계획 외에 다음 파일들도 영향을 받습니다:

| 파일 경로 | 영향 이유 |
|---------|----------|
| `lib/features/notification/application/notifiers/notification_notifier.dart` | P1: `NotificationTime` 사용 (하지만 순수 Dart로만 사용하므로 수정 불필요) |
| `lib/features/tracking/domain/usecases/dose_notification_usecase.dart` | P4: `schedule.notificationTime.toString()` 호출 (NotificationTime 타입 변경 시 영향) |
| `test/features/tracking/application/notifiers/tracking_notifier_test.dart` | P2: Provider 변경 시 Mock 설정 수정 필요 |
| `test/features/tracking/domain/entities/dose_schedule_test.dart` | P4: `notificationTime` 타입 변경에 따른 테스트 수정 |

---

## TODO 리스트 (34개 작업)

### **Phase 1: P1 - NotificationTime Flutter 의존성 제거 (6개 작업)**

- [ ] P1.1: `notification_time.dart`에서 `'package:flutter/material.dart'` import 제거
- [ ] P1.2: `NotificationTime.fromTimeOfDay()` 메서드 삭제
- [ ] P1.3: `NotificationTime.toTimeOfDay()` 메서드 삭제
- [ ] P1.4: `notification_settings_screen.dart`에 `TimeOfDay` ↔ `NotificationTime` 변환 헬퍼 메서드 추가
- [ ] P1.5: `notification_settings_screen.dart`에서 `toTimeOfDay()`/`fromTimeOfDay()` 호출을 로컬 헬퍼로 교체
- [ ] P1.6: NotificationTime 관련 테스트 파일 확인 및 수정 (있는 경우)

### **Phase 2: P2 - trackingNotifierProvider userId 주입 (4개 작업)**

- [ ] P2.1: `tracking/application/providers.dart`의 `trackingNotifierProvider` 수정
- [ ] P2.2: `authNotifierProvider` 구독하여 userId 추출하는 코드 작성
- [ ] P2.3: userId가 null인 경우 처리 로직 확인 (TrackingNotifier._init()에서 이미 처리 중)
- [ ] P2.4: 관련 테스트 파일 수정 (`tracking_notifier_test.dart` 등)

### **Phase 3: P3 - MedicationNotifier AsyncNotifier 전환 (8개 작업)**

- [ ] P3.1: `medication_notifier.dart`를 AsyncNotifier 기반으로 변환
- [ ] P3.2: `StateNotifier<MedicationState>`를 `AsyncNotifier<MedicationState>`로 변경
- [ ] P3.3: `build()` 메서드 추가하여 authNotifierProvider 구독 및 초기 데이터 로딩
- [ ] P3.4: `initialize(String userId)` 메서드 및 `_userId` 필드 제거
- [ ] P3.5: `tracking/application/providers.dart`의 `medicationNotifierProvider`를 `@riverpod` 어노테이션으로 변경
- [ ] P3.6: MedicationNotifier를 사용하는 화면에서 `initialize()` 호출 검색 및 제거 (있는 경우)
- [ ] P3.7: `MedicationState` 클래스 유지 필요성 재검토 및 리팩토링
- [ ] P3.8: 관련 테스트 파일 수정 (MedicationNotifier 테스트 등)

### **Phase 4: P4 - DoseSchedule DTO 타입 명확화 (9개 작업)**

- [ ] P4.1: `dose_schedule.dart`의 `notificationTime` 타입을 `Object?`에서 `NotificationTime?`로 변경
- [ ] P4.2: `dose_schedule.dart`의 `copyWith` 메서드에서 `notificationTime` 파라미터 타입 수정 (`DateTime?` → `NotificationTime?`)
- [ ] P4.3: `dose_schedule_dto.dart`에서 `notificationTimeStr` 필드를 `notificationHour`, `notificationMinute`로 분리
- [ ] P4.4: `dose_schedule_dto.dart`의 `fromEntity()`에서 `NotificationTime` → `hour`/`minute` 변환 로직 작성
- [ ] P4.5: `dose_schedule_dto.dart`의 `toEntity()`에서 `hour`/`minute` → `NotificationTime` 변환 로직 작성
- [ ] P4.6: `build_runner` 실행하여 `dose_schedule_dto.g.dart` 재생성
- [ ] P4.7: `dose_notification_usecase.dart`의 `getNotificationTimeString()` 메서드 로직 확인 및 수정
- [ ] P4.8: DoseSchedule을 사용하는 모든 UseCase/Repository에서 `notificationTime` 타입 오류 수정
- [ ] P4.9: 관련 테스트 파일 수정 (`dose_schedule_test.dart`, `isar_dose_schedule_repository_test.dart` 등)

### **Phase 5: 최종 검증 (4개 작업)**

- [ ] 최종 검증: `dart run build_runner build --delete-conflicting-outputs` 실행
- [ ] 최종 검증: `flutter analyze`로 경고/에러 확인
- [ ] 최종 검증: `flutter test`로 모든 테스트 실행
- [ ] 최종 검증: 4-Layer 아키텍처 원칙 준수 확인 (Domain Layer의 Flutter 의존성 제거 완료)

---

## 작업 순서 권장사항

각 Phase는 **독립적으로 진행 가능**하지만, 다음 순서를 권장합니다:

### 권장 순서

1. **P1 먼저 완료** → Domain Layer 순수성 확보 (Critical)
2. **P2 완료** → Provider 종속성 해결 (Major)
3. **P4 완료** → 타입 안전성 강화 (P1 완료 후 가능)
4. **P3 완료** → 현대적 패턴 적용 (독립적, 가장 큰 리팩토링)

### 이유

- **P1은 아키텍처 원칙 위반**이므로 최우선 수정이 필요
- **P4는 P1의 NotificationTime 순수화**가 완료되어야 안전하게 진행 가능
- **P3는 독립적**이지만 가장 큰 변경이므로 다른 작업 완료 후 진행

---

## 예상 소요 시간

| Phase | 작업 수 | 예상 시간 | 위험도 |
|-------|--------|----------|--------|
| P1 | 6 | 30-45분 | 낮음 (로직 변경 최소) |
| P2 | 4 | 15-20분 | 낮음 (단순 Provider 수정) |
| P3 | 8 | 60-90분 | 중간 (State 관리 로직 변경) |
| P4 | 9 | 45-60분 | 중간 (DTO/Entity 타입 변경) |
| 검증 | 4 | 20-30분 | - |
| **합계** | **31** | **3-4시간** | - |

---

## 참고 자료

### 가이드라인 문서
- `docs/external/riverpod_설정가이드.md`
  - Pattern 1: Repository Provider (Infrastructure 주입)
  - Pattern 2: Notifier Provider (동기 상태 관리)
  - Pattern 3: AsyncNotifier Provider (비동기 상태 관리)
  - Best Practice: "Provider는 Application Layer에만 정의"

- `docs/external/IsarDB_설정가이드.md`
  - DTO 정의 규칙 (Infrastructure Layer에서만)
  - Best Practice: "DTO는 Infrastructure Layer에만"
  - Best Practice: "writeTxn은 필수"

### 아키텍처 원칙
- `CLAUDE.md`
  - Layer Dependency: `Presentation → Application → Domain ← Infrastructure`
  - Repository Pattern 엄격 준수
  - Domain Layer는 순수 Dart (Flutter 의존성 금지)

---

## 체크리스트

### Before Committing
- [ ] 테스트 통과 (`flutter test`)
- [ ] 경고 없음 (`flutter analyze`)
- [ ] Repository Pattern 유지
- [ ] Layer 위반 없음 (imports 확인)
- [ ] Domain Layer Flutter 의존성 제거 완료

### Architecture Compliance
- [ ] Domain Layer: Flutter/Riverpod 의존성 없음
- [ ] Application Layer: Provider 정의만 존재
- [ ] Infrastructure Layer: Isar DTO 및 구현체만 존재
- [ ] Presentation Layer: UI 및 Flutter 의존성만 존재

---

## 변경 이력

| 날짜 | 작업자 | 변경 내용 |
|------|--------|----------|
| 2025-11-11 | Claude | 초기 분석 및 리팩토링 계획 수립 |

# Code Structure

> **현재 상태**: Phase 1 완료 - Supabase PostgreSQL 기반 Infrastructure Layer


## Feature → Requirements 매핑

| 기능 ID | 기능명 | 위치 | 공유 데이터 제공 |
|---------|--------|------|-----------------|
| F-001 | 소셜 로그인 | `features/authentication/` | - |
| F000 | 온보딩 | `features/onboarding/` | `user_profiles` |
| F001 | 투여 스케줄러 | `features/tracking/` | `dosage_plans`, `dose_schedules` |
| F002 | 증상/체중 기록 | `features/tracking/` | `weight_logs`, `symptom_logs` |
| F003 | 데이터 공유 모드 | `features/data_sharing/` | - |
| F004 | 대처 가이드 | `features/tracking/` | - |
| F005 | 증상 체크 | `features/tracking/` | - |
| F006 | 홈 대시보드 | `features/dashboard/` | `badge_definitions`, `user_badges` |

**공유 데이터 제공**: 다른 기능에서 import하여 사용할 수 있는 공통 데이터 소스

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
| **Infrastructure** | **Supabase** | Repository 구현, DB 접근 |

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
// infrastructure/repositories/supabase_medication_repository.dart
class SupabaseMedicationRepository implements MedicationRepository {
  final SupabaseClient supabase;

  @override
  Stream<List<Dose>> watchDoses() {
    return supabase
      .from('dose_records')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((json) => Dose.fromJson(json)).toList());
  }

  @override
  Future<void> saveDose(Dose dose) async {
    await supabase
      .from('dose_records')
      .insert(dose.toJson());
  }
}
```

**DI (Application Layer)**
```dart
// application/providers.dart
@riverpod
MedicationRepository medicationRepository(ref) {
  return SupabaseMedicationRepository(ref.watch(supabaseProvider));
}
```

### 2. DTO ↔ Entity

**Supabase와 JSON 직렬화**

Supabase는 JSON 직렬화를 사용하므로 별도 DTO 클래스 불필요. Entity에 직접 JSON 변환 메서드 추가:

```dart
// domain/entities/dose.dart
class Dose {
  final String id;
  final double doseMg;
  final DateTime administeredAt;

  Dose({
    required this.id,
    required this.doseMg,
    required this.administeredAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'dose_mg': doseMg,
    'administered_at': administeredAt.toIso8601String(),
  };

  factory Dose.fromJson(Map<String, dynamic> json) => Dose(
    id: json['id'] as String,
    doseMg: (json['dose_mg'] as num).toDouble(),
    administeredAt: DateTime.parse(json['administered_at'] as String),
  );
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

## 규칙

### DO ✅
- Repository Interface를 통한 데이터 접근
- Entity에 JSON 직렬화 추가
- 비즈니스 로직은 Domain Layer에만
- 여러 Repository 조합은 Application Layer

### DON'T ❌
- Application에서 Supabase 직접 접근
- Presentation에서 Repository 직접 호출
- Domain Layer에 Flutter/Supabase 의존성

---

## 공통 데이터 소유권 및 공유 패턴

여러 기능에서 사용하는 공통 데이터(테이블)는 **한 곳에서만 구현**하고, 다른 기능은 import하여 사용합니다.

### weight_logs (체중 기록)

**구현 소유**: `features/tracking/`

**구현 파일:**
```
features/tracking/
├── domain/
│   ├── entities/weight_log.dart
│   └── repositories/tracking_repository.dart (interface)
└── infrastructure/
    └── repositories/supabase_tracking_repository.dart (implementation)
```

**사용 기능:**
```dart
// onboarding: 초기 체중 기록 생성
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;
final repo = ref.read(tracking_providers.trackingRepositoryProvider);
await repo.saveWeightLog(weightLog);

// dashboard: 체중 데이터 조회 및 통계
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;
final repo = ref.watch(tracking_providers.trackingRepositoryProvider);
final weights = await repo.getWeightLogs(userId);
```

**중복 정의 금지:**
- ❌ `features/onboarding/domain/entities/weight_log.dart`
- ❌ `features/dashboard/domain/entities/weight_log.dart`

### symptom_logs (부작용 기록)

**구현 소유**: `features/tracking/`

**사용 기능**: tracking (부작용 기록 CRUD), dashboard (부작용 데이터 조회)

### user_profiles (사용자 프로필)

**구현 소유**: `features/onboarding/`

**구현 파일:**
```
features/onboarding/
├── domain/
│   ├── entities/user_profile.dart
│   └── repositories/profile_repository.dart
└── infrastructure/
    └── repositories/supabase_profile_repository.dart
```

**사용 기능**: onboarding (프로필 생성), dashboard (목표 체중 조회), profile (프로필 수정)

### dosage_plans, dose_schedules (투여 계획 및 스케줄)

**구현 소유**: `features/tracking/`

**사용 기능**: onboarding (초기 투여 계획 생성), tracking (투여 기록 관리)

---

## 기능 간 의존성 규칙

### 허용되는 의존성

```
┌─────────────┐
│ onboarding  │
└──────┬──────┘
       │ (uses)
       ├──→ tracking (weight_logs, dosage_plans)
       │
       v
┌─────────────┐
│  tracking   │ ← 가장 기본적인 데이터 제공
└──────┬──────┘
       │
       │ (uses)
       v
┌─────────────┐
│  dashboard  │
└──────┬──────┘
       │ (uses)
       ├──→ tracking (weight_logs, symptom_logs)
       └──→ onboarding (user_profiles)
```

**의존성 리스트:**
- onboarding → tracking ✅ (weight_logs, dosage_plans 사용)
- dashboard → tracking ✅ (weight_logs, symptom_logs 사용)
- dashboard → onboarding ✅ (user_profiles 사용)

### 금지되는 의존성

- tracking → onboarding ❌
- tracking → dashboard ❌
- onboarding → dashboard ❌

**이유:**
- 순환 의존성 방지: A → B → A 패턴 금지
- 계층 구조 유지: 하위 레벨이 상위 레벨에 의존하면 안 됨
- 단일 방향 데이터 흐름: 데이터 제공자는 소비자를 알 수 없음

### 의존성 해결 패턴

**케이스 1: tracking이 onboarding의 데이터를 사용해야 할 때**

```dart
// ❌ 잘못된 방법 (순환 의존성 발생)
// features/tracking/some_file.dart
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';

// ✅ 올바른 방법 (Application Layer에서 조합)
class SomeNotifier {
  SomeNotifier({
    required this.trackingRepo,
    required this.profileRepo,  // 외부에서 주입
  });
}

@riverpod
SomeNotifier someNotifier(SomeNotifierRef ref) {
  return SomeNotifier(
    trackingRepo: ref.watch(trackingRepositoryProvider),
    profileRepo: ref.watch(profileRepositoryProvider),
  );
}
```

**케이스 2: 여러 기능의 데이터를 조합해야 할 때**

```dart
// ✅ Dashboard UseCase 패턴
class CalculateDashboardDataUseCase {
  Future<DashboardData> execute({
    required List<WeightLog> weights,      // tracking 제공
    required List<SymptomLog> symptoms,    // tracking 제공
    required UserProfile profile,          // onboarding 제공
  }) {
    // 데이터 조합 및 계산
  }
}

// Dashboard Notifier
Future<DashboardData> _loadDashboardData(String userId) async {
  final weights = await _trackingRepository.getWeightLogs(userId);
  final symptoms = await _trackingRepository.getSymptomLogs(userId);
  final profile = await _profileRepository.getUserProfile(userId);

  return _calculateUseCase.execute(
    weights: weights,
    symptoms: symptoms,
    profile: profile,
  );
}
```

---

## 공통 데이터 구현 체크리스트

새로운 공통 데이터(테이블)를 추가할 때 따라야 할 가이드:

### 1. 구현 위치 결정

- 어느 기능이 이 데이터를 가장 직접적으로 사용하는가?
- 해당 기능의 `domain/` 디렉토리에 엔티티 생성
- 해당 기능의 `domain/repositories/` 디렉토리에 인터페이스 생성
- 해당 기능의 `infrastructure/` 디렉토리에 DTO 및 구현 생성

### 2. 문서 업데이트

- `docs/database.md`의 "공통 테이블의 소유권 정의" 테이블에 추가
- `docs/code_structure.md`의 "Feature → Requirements 매핑" 테이블 업데이트
- `docs/code_structure.md`의 "공통 데이터 소유권 및 공유 패턴" 섹션에 추가

### 3. 중복 방지 확인

```bash
# 동일한 엔티티명 검색
grep -r "class YourEntity" lib/features/

# 동일한 DTO명 검색
grep -r "class YourEntityDto" lib/features/

# 동일한 Repository명 검색
grep -r "abstract class YourRepository" lib/features/

# 중복이 발견되면 즉시 제거하고 단일 구현 사용
```

### 4. 확장성 고려

- Repository Pattern으로 구현되었는가?
- Infrastructure Layer만 변경하면 다른 데이터 소스로 전환 가능한가?
- Domain/Application Layer는 데이터 소스에 독립적인가?

---

## 실전 예제

**시나리오**: medication_history 테이블을 추가해야 함 (투여 약물 변경 이력)

### Step 1: 구현 위치 결정
- 질문: 어느 기능이 medication_history를 가장 직접적으로 사용하는가?
- 답변: tracking (투여 관리)

### Step 2: 파일 생성
```
features/tracking/
├── domain/
│   ├── entities/medication_history.dart (생성)
│   └── repositories/medication_repository.dart (메서드 추가)
└── infrastructure/
    └── repositories/supabase_medication_repository.dart (구현 추가)
```

### Step 3: 문서 업데이트
- `database.md`: `| medication_history | features/tracking/ | tracking, dashboard | MedicationRepository 제공 |`
- `code_structure.md`: "공통 데이터 소유권 및 공유 패턴" 섹션에 추가

### Step 4: 다른 기능에서 사용
```dart
// features/dashboard/application/notifiers/dashboard_notifier.dart
import 'package:n06/features/tracking/domain/entities/medication_history.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;

final repo = ref.watch(tracking_providers.medicationRepositoryProvider);
final history = await repo.getMedicationHistory(userId);
```

### Step 5: 중복 확인
```bash
grep -r "class MedicationHistory" lib/features/
# 결과: features/tracking/domain/entities/medication_history.dart 단 하나만 출력되어야 함
```

---

## DO / DON'T 요약

### ✅ DO

```dart
// 공통 데이터는 소유 기능의 구현을 import
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;
final repo = ref.read(tracking_providers.trackingRepositoryProvider);

// Repository Pattern으로 추상화
abstract class TrackingRepository {
  Future<void> saveWeightLog(WeightLog log);
}

// 구현체
class SupabaseTrackingRepository implements TrackingRepository { }

// Application Layer에서 여러 Repository 조합
class DashboardNotifier {
  DashboardNotifier({
    required this.trackingRepo,
    required this.profileRepo,
  });
}
```

### ❌ DON'T

```dart
// 같은 엔티티를 여러 곳에 정의
// features/onboarding/domain/entities/weight_log.dart
class WeightLog { }  // ❌
// features/tracking/domain/entities/weight_log.dart
class WeightLog { }  // ❌
// 하나만 있어야 함!

// 순환 의존성
// features/tracking/some_file.dart
import 'package:n06/features/onboarding/.../profile_repository.dart';  // ❌
// features/onboarding/some_file.dart
import 'package:n06/features/tracking/.../tracking_repository.dart';   // ❌

// Domain Layer에서 구체 구현 참조
// features/dashboard/domain/usecases/some_usecase.dart
import 'package:n06/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart';  // ❌
// 인터페이스를 사용해야 함:
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';  // ✅
```
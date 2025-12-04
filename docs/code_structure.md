---
id: code-structure
keywords: [layer, architecture, clean, presentation, application, domain, infrastructure, folder, import]
read_when: 레이어 구조, 파일 위치, import 규칙, 폴더 구조 질문 시
related: [state-management, techstack]
---

# Code Structure

> **현재 상태**: Phase 1 완료 - Supabase PostgreSQL 기반 Infrastructure Layer


## Feature → Requirements 매핑

| 기능 ID | 기능명 | 위치 | 4-Layer 상태 |
|---------|--------|------|--------------|
| F-001 | 소셜 로그인 | `features/authentication/` | ✅ 완전 |
| F000 | 온보딩 | `features/onboarding/` | ✅ 완전 |
| F001 | 투여 스케줄러 | `features/tracking/` | ✅ 완전 |
| F002 | 체중 기록 | `features/tracking/` | ✅ 완전 |
| F004 | 대처 가이드 | `features/coping_guide/` | ✅ 완전 |
| F005 | 증상 체크 | `features/daily_checkin/` | ✅ 완전 |
| F006 | 홈 대시보드 | `features/dashboard/` | ✅ 완전 |
| NEW | 알림 | `features/notification/` | ✅ 완전 |
| NEW | 프로필 | `features/profile/` | ⚠️ 3-Layer (infra 없음) |
| NEW | 설정 | `features/settings/` | ⚠️ 2-Layer (pres+app) |
| NEW | 기록 관리 | `features/record_management/` | ⚠️ 1-Layer (pres만) |

**공유 데이터 제공**:
- `tracking/`: `dosage_plans`, `dose_schedules`, `dose_records`, `weight_logs`
- `onboarding/`: `user_profiles`
- `dashboard/`: `badge_definitions`, `user_badges`
- `daily_checkin/`: `daily_checkins`, `symptom_details`

---

## 폴더 구조

### Top Level

```
lib/
├── l10n/              # 다국어 지원
│   └── generated/     # arb → dart 생성 파일
├── features/          # 기능별 모듈
│   ├── authentication/
│   ├── coping_guide/
│   ├── daily_checkin/
│   ├── dashboard/
│   ├── notification/
│   ├── onboarding/
│   ├── profile/
│   ├── record_management/
│   ├── settings/
│   └── tracking/
├── core/              # 전역 공통
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── presentation/
│   ├── providers/
│   ├── routing/
│   └── utils/
└── main.dart
```

### Core 상세

```
core/
├── constants/
│   └── legal_urls.dart          # 법적 문서 URL
├── errors/
│   └── domain_exception.dart    # 도메인 예외 정의
├── extensions/                  # Dart 확장 메서드
│   ├── coping_guide_extension.dart
│   ├── dashboard_message_extension.dart
│   ├── date_format_extension.dart
│   ├── greeting_message_extension.dart
│   ├── l10n_extension.dart
│   ├── symptom_severity_extension.dart
│   └── timeline_event_extension.dart
├── presentation/                # 공유 UI 컴포넌트
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_typography.dart
│   └── widgets/
│       ├── empty_state_widget.dart
│       ├── gabium_bottom_navigation.dart
│       ├── impact_analysis_dialog.dart
│       ├── record_type_icon.dart
│       ├── scaffold_with_bottom_nav.dart
│       └── status_badge.dart
├── providers/
│   ├── providers.dart           # Supabase, SharedPreferences 등
│   └── shared_preferences_provider.dart
├── routing/
│   └── app_router.dart          # GoRouter 설정
└── utils/
    └── validators.dart          # 입력 검증
```

### Feature 상세 (4-Layer)

```
features/{feature}/
├── presentation/           # UI Layer
│   ├── screens/
│   ├── widgets/
│   ├── dialogs/           # (선택) 다이얼로그
│   ├── sheets/            # (선택) 바텀시트
│   ├── utils/             # (선택) UI 유틸리티
│   └── extensions/        # (선택) UI 확장
├── application/           # 상태 관리 Layer
│   ├── notifiers/
│   └── providers.dart
├── domain/                # 비즈니스 로직 Layer
│   ├── entities/
│   ├── usecases/
│   ├── repositories/      # Interface만
│   ├── services/          # (선택) 도메인 서비스
│   └── value_objects/     # (선택) 값 객체
└── infrastructure/        # 데이터 접근 Layer
    ├── repositories/      # 구현체
    ├── dtos/
    └── services/          # (선택) 외부 서비스
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

### DO
- Repository Interface를 통한 데이터 접근
- Entity에 JSON 직렬화 추가
- 비즈니스 로직은 Domain Layer에만
- 여러 Repository 조합은 Application Layer

### DON'T
- Application에서 Supabase 직접 접근
- Presentation에서 Repository 직접 호출
- Domain Layer에 Flutter/Supabase 의존성

---

## 공유 데이터 소유권 및 공유 패턴

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
    ├── dtos/weight_log_dto.dart
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

### daily_checkins, symptom_details (일일 체크인)

**구현 소유**: `features/daily_checkin/`

**사용 기능**: daily_checkin (체크인 CRUD), dashboard (체크인 데이터 조회)

### user_profiles (사용자 프로필)

**구현 소유**: `features/onboarding/`

**구현 파일:**
```
features/onboarding/
├── domain/
│   ├── entities/user_profile.dart
│   └── repositories/profile_repository.dart
└── infrastructure/
    ├── dtos/user_profile_dto.dart
    └── repositories/supabase_profile_repository.dart
```

**사용 기능**: onboarding (프로필 생성), dashboard (목표 체중 조회), profile (프로필 수정)

### dosage_plans, dose_schedules (투여 계획 및 스케줄)

**구현 소유**: `features/tracking/`

**사용 기능**: onboarding (초기 투여 계획 생성), tracking (투여 기록 관리)

### badge_definitions, user_badges (배지)

**구현 소유**: `features/dashboard/`

**사용 기능**: dashboard (배지 표시 및 획득 관리)

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
       ├──→ tracking (weight_logs, dose_records)
       ├──→ onboarding (user_profiles)
       └──→ daily_checkin (daily_checkins)
```

**의존성 리스트:**
- onboarding → tracking (weight_logs, dosage_plans 사용)
- dashboard → tracking (weight_logs, dose_records 사용)
- dashboard → onboarding (user_profiles 사용)
- dashboard → daily_checkin (daily_checkins 사용)

### 금지되는 의존성

- tracking → onboarding
- tracking → dashboard
- onboarding → dashboard
- daily_checkin → dashboard

**이유:**
- 순환 의존성 방지: A → B → A 패턴 금지
- 계층 구조 유지: 하위 레벨이 상위 레벨에 의존하면 안 됨
- 단일 방향 데이터 흐름: 데이터 제공자는 소비자를 알 수 없음

### 의존성 해결 패턴

**케이스 1: tracking이 onboarding의 데이터를 사용해야 할 때**

```dart
// ❌ 잘못된 방법 (순환 의존성 발생)
// features/tracking/some_file.dart
import 'package:n06/features/onboarding/.../profile_repository.dart';

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
    required List<DailyCheckin> checkins,  // daily_checkin 제공
    required UserProfile profile,          // onboarding 제공
  }) {
    // 데이터 조합 및 계산
  }
}

// Dashboard Notifier
Future<DashboardData> _loadDashboardData(String userId) async {
  final weights = await _trackingRepository.getWeightLogs(userId);
  final checkins = await _checkinRepository.getCheckins(userId);
  final profile = await _profileRepository.getUserProfile(userId);

  return _calculateUseCase.execute(
    weights: weights,
    checkins: checkins,
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
- `docs/code_structure.md`의 "공유 데이터 소유권 및 공유 패턴" 섹션에 추가

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

## DO / DON'T 요약

### DO

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

### DON'T

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

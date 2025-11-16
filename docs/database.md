# Database Schema Design (Supabase PostgreSQL)

> **현재 상태**: Phase 1 완료 - Supabase PostgreSQL 사용 중
>
> Phase 0에서는 Isar 로컬 DB를 사용했으나, Phase 1 전환으로 모든 데이터가 Supabase PostgreSQL로 마이그레이션되었습니다.

## Data Flow

### 1. Authentication & Onboarding
```
users → oauth_tokens
users → consent_records
users → user_profiles
```

### 2. Dosage Management
```
dosage_plans → dose_schedules → dose_records
dosage_plans → plan_change_history
```

### 3. Symptom & Weight Tracking
```
symptom_logs → symptom_context_tags
weight_logs
```

### 4. Emergency Checks
```
emergency_symptom_checks
```

### 5. Achievement & Badges
```
badge_definitions (static)
user_badges ← computed from user activity
```

### 6. Dashboard Aggregation (Read)
```
dose_records + weight_logs + symptom_logs + user_badges
→ weekly statistics, insights, badges, timeline
```

---

## Tables

### users
사용자 계정 정보

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | 내부 고유 식별자 |
| auth_type | varchar(20) | NOT NULL | 'social' 또는 'email' |
| oauth_provider | varchar(20) | NULL | naver/kakao (social인 경우만) |
| oauth_user_id | varchar(255) | NULL | 소셜 제공자 사용자 ID (social인 경우만) |
| email | varchar(255) | NOT NULL, UNIQUE | 이메일 |
| password_hash | text | NULL | 비밀번호 해시 (email 인증인 경우만) |
| email_verified | boolean | NOT NULL, DEFAULT false | 이메일 인증 여부 |
| name | varchar(100) | NOT NULL | 사용자 이름 |
| profile_image_url | text | NULL | 프로필 이미지 URL |
| login_attempts | integer | NOT NULL, DEFAULT 0 | 로그인 시도 횟수 |
| locked_until | timestamptz | NULL | 계정 잠금 해제 시간 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 가입일시 |
| last_login_at | timestamptz | NOT NULL, DEFAULT now() | 마지막 로그인 일시 |

**Indexes**
- UNIQUE: email
- UNIQUE: (oauth_provider, oauth_user_id) WHERE oauth_provider IS NOT NULL
- INDEX: (email, auth_type)

**Constraints**
- CHECK: auth_type IN ('social', 'email')
- CHECK: (auth_type = 'social' AND oauth_provider IS NOT NULL) OR (auth_type = 'email' AND password_hash IS NOT NULL)

---

### oauth_tokens
~~인증 토큰 (Phase 0에서 사용, Phase 1에서 제거됨)~~

**Phase 1에서는 Supabase Auth가 토큰 관리를 자동으로 처리하므로 이 테이블은 사용하지 않습니다.**

Phase 0 참고용 스키마:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| access_token | text | NOT NULL | Access Token |
| refresh_token | text | NOT NULL | Refresh Token |
| expires_at | timestamptz | NOT NULL | 토큰 만료 시간 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

---

### consent_records
이용약관 동의 정보

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| terms_of_service | boolean | NOT NULL | 이용약관 동의 |
| privacy_policy | boolean | NOT NULL | 개인정보처리방침 동의 |
| agreed_at | timestamptz | NOT NULL, DEFAULT now() | 동의 일시 |

---

### user_profiles
사용자 프로필 및 목표

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), UNIQUE, NOT NULL | |
| target_weight_kg | numeric(5,2) | NOT NULL | 목표 체중 |
| target_period_weeks | integer | NULL | 목표 기간 (주) |
| weekly_loss_goal_kg | numeric(4,2) | NULL | 주간 감량 목표 (자동 계산) |
| weekly_weight_record_goal | integer | NOT NULL, DEFAULT 7 | 주간 체중 기록 목표 |
| weekly_symptom_record_goal | integer | NOT NULL, DEFAULT 7 | 주간 부작용 기록 목표 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | |

**Note**: 현재 체중은 weight_logs 테이블에서 최신 기록으로 조회

---

### dosage_plans
투여 계획

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| medication_name | varchar(100) | NOT NULL | 약물명 |
| start_date | date | NOT NULL | 시작일 |
| cycle_days | integer | NOT NULL | 투여 주기 (일) |
| initial_dose_mg | numeric(6,2) | NOT NULL | 초기 용량 (mg) |
| escalation_plan | jsonb | NULL | 증량 계획 [{weeks: 4, dose_mg: 0.5}] |
| is_active | boolean | NOT NULL, DEFAULT true | 활성 여부 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (user_id, is_active)

---

### plan_change_history
투여 계획 변경 이력

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| dosage_plan_id | uuid | FK(dosage_plans.id), NOT NULL | |
| changed_at | timestamptz | NOT NULL, DEFAULT now() | 변경일시 |
| old_plan | jsonb | NOT NULL | 변경 전 계획 |
| new_plan | jsonb | NOT NULL | 변경 후 계획 |

---

### dose_schedules
투여 스케줄 (자동 생성)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| dosage_plan_id | uuid | FK(dosage_plans.id), NOT NULL | |
| scheduled_date | date | NOT NULL | 투여 예정일 |
| scheduled_dose_mg | numeric(6,2) | NOT NULL | 예정 용량 (mg) |
| notification_time | time | NULL | 알림 시간 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (dosage_plan_id, scheduled_date)

---

### dose_records
투여 기록

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| dose_schedule_id | uuid | FK(dose_schedules.id), NULL | 연관 스케줄 (수동 기록 시 NULL) |
| dosage_plan_id | uuid | FK(dosage_plans.id), NOT NULL | |
| administered_at | timestamptz | NOT NULL | 투여일시 |
| actual_dose_mg | numeric(6,2) | NOT NULL | 실제 용량 (mg) |
| injection_site | varchar(20) | NULL | 복부/허벅지/상완 |
| is_completed | boolean | NOT NULL, DEFAULT true | 완료 여부 |
| note | text | NULL | 메모 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (dosage_plan_id, administered_at)
- INDEX: (injection_site, administered_at DESC)

**Note**: 주사 부위 순환 관리는 injection_site 컬럼과 administered_at을 통해 구현

---

### weight_logs
체중 기록

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| log_date | date | NOT NULL | 기록 날짜 |
| weight_kg | numeric(5,2) | NOT NULL | 체중 (kg) |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 기록 시간 |

**Indexes**
- UNIQUE: (user_id, log_date)
- INDEX: (user_id, log_date DESC)

---

### symptom_logs
부작용 기록

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| log_date | date | NOT NULL | 기록 날짜 |
| symptom_name | varchar(50) | NOT NULL | 메스꺼움/구토/변비/설사/복통/두통/피로 |
| severity | integer | NOT NULL, CHECK (severity >= 1 AND severity <= 10) | 심각도 (1-10) |
| days_since_escalation | integer | NULL | 용량 증량 후 경과일 |
| is_persistent_24h | boolean | NULL | 24시간 이상 지속 여부 |
| note | text | NULL | 메모 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 기록 시간 |

**Indexes**
- INDEX: (user_id, log_date DESC)

---

### symptom_context_tags
부작용 컨텍스트 태그

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| symptom_log_id | uuid | FK(symptom_logs.id), NOT NULL | |
| tag_name | varchar(50) | NOT NULL | 기름진음식/과식/음주/공복/스트레스/수면부족 등 |

**Indexes**
- INDEX: (symptom_log_id)
- INDEX: (tag_name)

---

### emergency_symptom_checks
증상 체크 기록

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| checked_at | timestamptz | NOT NULL, DEFAULT now() | 체크 날짜시간 |
| checked_symptoms | jsonb | NOT NULL | 선택한 증상 목록 |

**Indexes**
- INDEX: (user_id, checked_at DESC)

---

### badge_definitions
뱃지 정의 (정적 데이터)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | varchar(50) | PK | 뱃지 ID (예: 'streak_7', 'weight_5percent') |
| name | varchar(100) | NOT NULL | 뱃지 이름 |
| description | text | NOT NULL | 뱃지 설명 |
| category | varchar(20) | NOT NULL | 카테고리 (streak/weight/dose/record) |
| achievement_condition | jsonb | NOT NULL | 획득 조건 (JSON 형식) |
| icon_url | text | NULL | 아이콘 이미지 URL |
| display_order | integer | NOT NULL | 표시 순서 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (category, display_order)

---

### user_badges
사용자별 뱃지 획득 상태

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| badge_id | varchar(50) | FK(badge_definitions.id), NOT NULL | |
| status | varchar(20) | NOT NULL | 미획득(locked)/진행중(in_progress)/획득(achieved) |
| progress_percentage | integer | NOT NULL, DEFAULT 0 | 진행도 (0-100) |
| achieved_at | timestamptz | NULL | 획득 일시 (획득 시에만) |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- UNIQUE: (user_id, badge_id)
- INDEX: (user_id, status)
- INDEX: (user_id, achieved_at DESC)

**Constraints**
- CHECK: status IN ('locked', 'in_progress', 'achieved')
- CHECK: progress_percentage >= 0 AND progress_percentage <= 100

---

### password_reset_tokens
비밀번호 재설정 토큰

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| user_id | uuid | FK(users.id), NOT NULL | |
| token | varchar(255) | NOT NULL, UNIQUE | 재설정 토큰 (UUID) |
| expires_at | timestamptz | NOT NULL | 토큰 만료 시간 (24시간) |
| used | boolean | NOT NULL, DEFAULT false | 사용 여부 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (token, used, expires_at)
- INDEX: (user_id, created_at DESC)

**Constraints**
- CHECK: expires_at > created_at

---

## RLS (Row Level Security) Policies

**Phase 1 완료 - 적용됨 ✅**

모든 테이블에 RLS가 활성화되어 있으며, 다음 정책이 적용되었습니다:

**일반 테이블 정책 (user_id 기반):**
```sql
ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own data"
ON {table_name}
FOR ALL
USING (user_id = auth.uid());
```

**users 테이블 정책:**
```sql
CREATE POLICY "Users can only access their own profile"
ON users
FOR ALL
USING (id = auth.uid());
```

**적용 완료된 테이블:**
- users
- user_profiles
- dosage_plans
- dose_schedules
- dose_records
- weight_logs
- symptom_logs
- symptom_context_tags
- emergency_symptom_checks
- user_badges
- password_reset_tokens (user_id 기반)

---

## Indexes Summary

성능 최적화를 위한 주요 인덱스:

1. **users**: email UNIQUE, (oauth_provider, oauth_user_id) UNIQUE WHERE oauth_provider IS NOT NULL, (email, auth_type)
2. **dosage_plans**: (user_id, is_active)
3. **dose_schedules**: (dosage_plan_id, scheduled_date)
4. **dose_records**: (dosage_plan_id, administered_at), (injection_site, administered_at DESC)
5. **weight_logs**: (user_id, log_date) UNIQUE, (user_id, log_date DESC)
6. **symptom_logs**: (user_id, log_date DESC)
7. **symptom_context_tags**: (symptom_log_id), (tag_name)
8. **emergency_symptom_checks**: (user_id, checked_at DESC)
9. **badge_definitions**: (category, display_order)
10. **user_badges**: (user_id, badge_id) UNIQUE, (user_id, status), (user_id, achieved_at DESC)
11. **password_reset_tokens**: (token, used, expires_at), (user_id, created_at DESC)

---

## Data Retention

MVP는 무제한 보관.
Phase 2 이후 GDPR 준수를 위해 데이터 보관 정책 수립 필요.

---

## Notes

- 모든 timestamp는 timestamptz 사용 (timezone 고려)
- JSON 필드는 jsonb 사용 (쿼리 성능 최적화)
- **Phase 1 완료**: Supabase PostgreSQL 사용 중 ✅
- Repository Pattern으로 Phase 0 → Phase 1 전환 완료
- 모든 데이터는 Supabase PostgreSQL에 저장됨
- RLS(Row Level Security)로 데이터 접근 제어 적용됨

### 설계 결정 사항

#### 1. 온보딩 시 weight_logs 자동 생성
온보딩에서 입력받은 현재 체중을 weight_logs에 첫 기록으로 자동 생성 필요

**구현 방법:**
- `OnboardingNotifier`에서 `TrackingRepository.saveWeightLog()` 호출
- 온보딩 완료 시 `log_date = 온보딩 완료일`, `weight_kg = 입력받은 체중`으로 기록 생성

#### 2. weight_logs 구현 위치 및 공유 패턴

**핵심 원칙**: weight_logs는 독립 테이블이지만, **구현은 단일화**

**구현 위치:**
```
features/tracking/
├── domain/
│   ├── entities/weight_log.dart           # WeightLog 엔티티 (공통 사용)
│   └── repositories/tracking_repository.dart  # TrackingRepository 인터페이스
└── infrastructure/
    ├── dtos/weight_log_dto.dart           # Isar DTO
    └── repositories/
        └── isar_tracking_repository.dart  # Repository 구현체
```

**사용 패턴:**
```dart
// onboarding 기능
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;
final repo = ref.read(tracking_providers.trackingRepositoryProvider);

// dashboard 기능
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart' as tracking_providers;
final repo = ref.watch(tracking_providers.trackingRepositoryProvider);
```

**중복 정의 금지:**
- ❌ `features/onboarding/domain/entities/weight_log.dart` 생성 금지
- ❌ `features/onboarding/infrastructure/dtos/weight_log_dto.dart` 생성 금지
- ❌ `features/*/domain/repositories/tracking_repository.dart` 중복 생성 금지
- ✅ tracking의 구현을 import하여 사용

**이유:**
1. **Isar schema 충돌 방지**: 동일한 collection 이름으로 2개 이상의 DTO 생성 시 충돌
2. **Repository Pattern 준수**: 하나의 데이터 소스(weight_logs)는 하나의 Repository
3. **Phase 1 전환 용이**: tracking의 Repository만 변경하면 모든 기능에 자동 반영
4. **타입 안정성**: 단일 WeightLog 엔티티로 타입 불일치 방지

#### 3. 공통 테이블의 소유권 정의

| 테이블 | 구현 위치 | 사용 기능 | 비고 |
|--------|----------|----------|------|
| weight_logs | `features/tracking/` | onboarding, tracking, dashboard | TrackingRepository 제공 |
| symptom_logs | `features/tracking/` | tracking, dashboard | TrackingRepository 제공 |
| user_profiles | `features/onboarding/` | onboarding, dashboard, profile | ProfileRepository 제공 |
| dosage_plans | `features/tracking/` | onboarding, tracking | MedicationRepository 제공 |
| dose_schedules | `features/tracking/` | onboarding, tracking | ScheduleRepository 제공 |
| badge_definitions | `features/dashboard/` | dashboard | BadgeRepository 제공 |
| user_badges | `features/dashboard/` | dashboard | BadgeRepository 제공 |

**원칙:**
- 각 테이블은 **가장 직접적으로 사용하는 기능**이 구현을 소유
- 다른 기능은 소유 기능의 Repository를 import하여 사용
- 중복 구현 절대 금지

#### 4. Phase 1 전환 완료 (Isar → Supabase) ✅

**변경 범위:** Infrastructure Layer만 수정 완료

**예시 - TrackingRepository 전환:**
```dart
// Phase 0 (과거)
@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarTrackingRepository(isar);  // ← Isar 구현
}

// Phase 1 (현재) ✅
@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTrackingRepository(supabase);  // ← Supabase 구현 (1줄 변경)
}
```

**실제 영향 범위:**
- ✅ tracking의 providers.dart: 1줄 변경 완료
- ✅ tracking의 infrastructure/ 디렉토리: Supabase 구현 추가 완료
- ✅ onboarding, dashboard: 코드 변경 불필요 (Repository Pattern 효과)
- ✅ domain, application, presentation: 코드 변경 불필요

**전환 완료된 Repository:**
- MedicationRepository → SupabaseMedicationRepository
- TrackingRepository → SupabaseTrackingRepository
- ProfileRepository → SupabaseProfileRepository
- AuthRepository → SupabaseAuthRepository
- BadgeRepository → SupabaseBadgeRepository

#### 5. 데이터 무결성 제약

**Phase 0 (Isar) 구현 참고:**

Isar는 PostgreSQL의 UNIQUE 제약을 네이티브로 지원하지 않았으므로, Repository 구현에서 수동 처리했습니다:

```dart
// Phase 0: weight_logs의 UNIQUE (user_id, log_date) 수동 구현
Future<void> saveWeightLog(WeightLog log) async {
  await _isar.writeTxn(() async {
    // 같은 날짜의 기존 기록 삭제
    final existing = await _isar.weightLogDtos
        .filter()
        .userIdEqualTo(log.userId)
        .logDateEqualTo(log.logDate)
        .findAll();

    if (existing.isNotEmpty) {
      await _isar.weightLogDtos.deleteAll(existing.map((e) => e.id).toList());
    }

    await _isar.weightLogDtos.put(WeightLogDto.fromEntity(log));
  });
}
```

**Phase 1 (Supabase PostgreSQL) 현재 상태 ✅:**

PostgreSQL의 UNIQUE 제약이 DB 레벨에서 자동 적용되므로 수동 처리가 불필요합니다:

```sql
-- weight_logs 테이블
CREATE UNIQUE INDEX unique_weight_log_per_user_per_date
ON weight_logs(user_id, log_date);
```

Repository 구현이 단순해졌습니다:
```dart
// Phase 1: 단순한 INSERT (UNIQUE 제약은 DB가 자동 처리)
Future<void> saveWeightLog(WeightLog log) async {
  await _supabase
      .from('weight_logs')
      .upsert(log.toJson());  // DB가 중복 처리
}
```

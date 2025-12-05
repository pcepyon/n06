---
id: database
keywords: [schema, table, column, relation, supabase, postgresql, rls, migration]
read_when: 테이블 구조, 컬럼, 관계, RLS 정책, 데이터 모델 질문 시
related: [techstack, code-structure]
---

# Database Schema Design (Supabase PostgreSQL)

> **현재 상태**: Supabase PostgreSQL 사용 중

## Data Flow

### 1. Authentication & Onboarding
```
users → consent_records
users → user_profiles
```

### 2. Dosage Management
```
dosage_plans → dose_schedules → dose_records
dosage_plans → plan_change_history
```

### 3. Weight Tracking & Daily Check-in
```
weight_logs
daily_checkins
```

### 5. Achievement & Badges
```
badge_definitions (static)
user_badges ← computed from user activity
```

### 6. Notification
```
notification_settings
```

### 7. Audit
```
audit_logs
```

### 8. Dashboard Aggregation (Read)
```
dose_records + weight_logs + daily_checkins + user_badges
→ weekly statistics, insights, badges, timeline
```

### 9. Master Tables (Static Reference)
```
medications (약물 마스터)
symptom_types (증상 유형 마스터)
```

### 10. Analytics Views
```
v_weekly_weight_summary
v_weekly_checkin_summary
v_monthly_dose_adherence
```

---

## Tables

### users
사용자 계정 정보 (Supabase Auth 연동)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PK | 내부 고유 식별자 (Supabase Auth UUID) |
| oauth_provider | varchar(20) | NOT NULL | kakao/naver/email |
| oauth_user_id | varchar(255) | NOT NULL | OAuth 제공자 사용자 ID |
| name | varchar(100) | NOT NULL | 사용자 이름 |
| email | varchar(255) | NULL | 이메일 (선택) |
| profile_image_url | text | NULL | 프로필 이미지 URL |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 가입일시 |
| last_login_at | timestamptz | NOT NULL, DEFAULT now() | 마지막 로그인 일시 |

**Note**: 비밀번호는 Supabase Auth (auth.users)에서 관리. public.users에 저장하지 않음.

---

### consent_records
이용약관 동의 정보

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
| terms_of_service | boolean | NOT NULL | 이용약관 동의 |
| privacy_policy | boolean | NOT NULL | 개인정보처리방침 동의 |
| agreed_at | timestamptz | NOT NULL, DEFAULT now() | 동의 일시 |

---

### user_profiles
사용자 프로필 및 목표

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), UNIQUE, NOT NULL | |
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
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
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
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| dosage_plan_id | uuid | FK(dosage_plans.id), NOT NULL | |
| changed_at | timestamptz | NOT NULL, DEFAULT now() | 변경일시 |
| old_plan | jsonb | NOT NULL | 변경 전 계획 |
| new_plan | jsonb | NOT NULL | 변경 후 계획 |

---

### dose_schedules
투여 스케줄 (자동 생성)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
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
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
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
체중 기록 (순수 체중 수치만 저장)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
| log_date | date | NOT NULL | 기록 날짜 |
| weight_kg | numeric(5,2) | NOT NULL | 체중 (kg) |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 기록 시간 |

**Note**: `appetite_score`는 `daily_checkins` 테이블로 이동됨 (데이터 정합성 개선)

**Indexes**
- UNIQUE: (user_id, log_date)
- INDEX: (user_id, log_date DESC)

---

### daily_checkins
데일리 체크인 (6개 일상 질문 + 식욕 점수 + 파생 증상)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
| checkin_date | date | NOT NULL | 체크인 날짜 |
| meal_condition | varchar(20) | NOT NULL | good/moderate/difficult |
| hydration_level | varchar(20) | NOT NULL | good/moderate/poor |
| gi_comfort | varchar(20) | NOT NULL | good/uncomfortable/very_uncomfortable |
| bowel_condition | varchar(20) | NOT NULL | normal/irregular/difficult |
| energy_level | varchar(20) | NOT NULL | good/normal/tired |
| mood | varchar(20) | NOT NULL | good/neutral/low |
| appetite_score | integer | NULL, CHECK (1-5) | GLP-1 식욕 조절 점수 (weight_logs에서 이동) |
| symptom_details | jsonb | NULL | 파생 증상 상세 |
| context | jsonb | NULL | 컨텍스트 정보 (주사 다음날, 연속일수, 체중 스킵 여부 등) |
| red_flag_detected | jsonb | NULL | Red Flag 감지 결과 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 기록 시간 |

**Indexes**
- UNIQUE: (user_id, checkin_date)
- INDEX: (user_id, checkin_date DESC)
- PARTIAL INDEX: (user_id) WHERE red_flag_detected IS NOT NULL
- GIN INDEX: (symptom_details jsonb_path_ops) - JSONB 쿼리 최적화

**JSONB 구조 정의**

```json
// symptom_details - 스키마 정의
[
  {
    "type": "nausea",           // enum: nausea, vomiting, abdominal_pain, ...
    "severity": 2,              // int: 1(mild), 2(moderate), 3(severe)
    "details": {                // nullable, 증상별 추가 필드
      "duration_hours": 4
    }
  },
  {
    "type": "abdominal_pain",
    "severity": 2,
    "details": {
      "location": "upper",      // upper, right_upper, lower, around_navel
      "radiates_to_back": false // 췌장염 지표
    }
  }
]

// context
{
  "is_post_injection": true,
  "days_since_last_checkin": 1,
  "consecutive_days": 5,
  "greeting_type": "morning",
  "weight_skipped": false       // 체중 입력 건너뛰기 여부
}

// red_flag_detected
{
  "type": "pancreatitis",
  "severity": "warning",
  "symptoms": ["severe_abdominal_pain", "radiates_to_back"],
  "notified_at": "2025-12-02T10:30:00Z",
  "user_action": "dismissed"    // dismissed, hospital_search, null
}
```

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
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
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

### notification_settings
알림 설정

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), UNIQUE, NOT NULL | |
| notification_hour | integer | NOT NULL, CHECK (0-23) | 알림 시간 |
| notification_minute | integer | NOT NULL, CHECK (0-59) | 알림 분 |
| notification_enabled | boolean | NOT NULL, DEFAULT true | 알림 활성화 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | |

---

### audit_logs
기록 수정 이력

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
| entity_type | varchar(50) | NOT NULL | 엔티티 타입 |
| entity_id | uuid | NOT NULL | 엔티티 ID |
| action | varchar(20) | NOT NULL | 액션 (create/update/delete) |
| old_data | jsonb | NULL | 변경 전 데이터 |
| new_data | jsonb | NULL | 변경 후 데이터 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (user_id, created_at DESC)
- INDEX: (entity_type, entity_id)

---

### guide_feedback (미사용)
대처 가이드 피드백 (마이그레이션에 정의됨, 코드에서 미사용)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | |
| user_id | TEXT | FK(users.id), NOT NULL | |
| symptom_name | varchar(50) | NOT NULL | 증상명 |
| helpful | boolean | NOT NULL | 도움 여부 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (user_id, created_at DESC)

---

### medications
GLP-1 약물 마스터 테이블 (앱 배포 없이 새 약물 추가 가능)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | varchar(50) | PK | 약물 ID (예: 'wegovy', 'ozempic') |
| name_ko | varchar(100) | NOT NULL | 한글명 |
| name_en | varchar(100) | NOT NULL | 영문명 |
| generic_name | varchar(100) | NULL | 성분명 (예: 세마글루타이드) |
| manufacturer | varchar(100) | NULL | 제조사 |
| available_doses | jsonb | NOT NULL | 가용 용량 목록 [0.25, 0.5, ...] |
| recommended_start_dose | numeric(6,2) | NULL | 권장 시작 용량 |
| dose_unit | varchar(10) | NOT NULL, DEFAULT 'mg' | 용량 단위 |
| cycle_days | integer | NOT NULL, DEFAULT 7 | 투여 주기 (일) |
| is_active | boolean | NOT NULL, DEFAULT true | 활성 여부 |
| display_order | integer | NOT NULL | 표시 순서 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (is_active, display_order)

**초기 데이터**
- wegovy (위고비) - Semaglutide, 주 1회
- ozempic (오젬픽) - Semaglutide, 주 1회
- mounjaro (마운자로) - Tirzepatide, 주 1회
- zepbound (젭바운드) - Tirzepatide, 주 1회
- saxenda (삭센다) - Liraglutide, 일 1회

**사용 시점**
- 온보딩/투여 계획에서 약물 드롭다운 표시
- 새 약물 출시 시 DB에만 추가하면 앱에 즉시 반영

**향후 확장**
- dosage_plans.medication_id FK 연결 (MVP 후)
- 약물별 증량 가이드 추가

---

### symptom_types
증상 유형 마스터 테이블

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | varchar(50) | PK | 증상 ID (예: 'nausea', 'vomiting') |
| name_ko | varchar(100) | NOT NULL | 한글명 |
| name_en | varchar(100) | NOT NULL | 영문명 |
| category | varchar(20) | NOT NULL | 카테고리 (digestive/systemic/red_flag) |
| is_red_flag | boolean | NOT NULL, DEFAULT false | Red Flag 여부 |
| display_order | integer | NOT NULL | 표시 순서 |
| is_active | boolean | NOT NULL, DEFAULT true | 활성 여부 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |

**Indexes**
- INDEX: (is_active, category, display_order)

**카테고리**
- digestive: 소화기 증상 (메스꺼움, 구토, 변비 등)
- systemic: 전신 증상 (피로, 어지러움 등)
- red_flag: 위험 증상 (췌장염, 담낭염 등)

**초기 데이터**
- 기본 증상 13종 + Red Flag 6종

**Note**: daily_checkins.symptom_details JSONB는 그대로 유지 (마이그레이션 하지 않음)

---

## Analytics Views

### v_weekly_weight_summary
주간 체중 요약 뷰

| Column | Type | Description |
|--------|------|-------------|
| user_id | TEXT | 사용자 ID |
| week_start | timestamptz | 주 시작일 |
| record_count | bigint | 기록 수 |
| avg_weight | numeric | 평균 체중 |
| min_weight | numeric | 최소 체중 |
| max_weight | numeric | 최대 체중 |
| weight_range | numeric | 체중 범위 |
| weekly_change | numeric | 주간 변화량 |

---

### v_weekly_checkin_summary
주간 체크인 요약 뷰

| Column | Type | Description |
|--------|------|-------------|
| user_id | TEXT | 사용자 ID |
| week_start | timestamptz | 주 시작일 |
| checkin_count | bigint | 체크인 수 |
| avg_appetite_score | numeric | 평균 식욕 점수 |
| red_flag_count | bigint | Red Flag 감지 수 |
| good_meal_count | bigint | 식사 양호 횟수 |
| good_energy_count | bigint | 에너지 양호 횟수 |
| good_mood_count | bigint | 기분 양호 횟수 |

---

### v_monthly_dose_adherence
월별 투여 순응도 뷰

| Column | Type | Description |
|--------|------|-------------|
| user_id | TEXT | 사용자 ID |
| month_start | timestamptz | 월 시작일 |
| medication_name | varchar | 약물명 |
| scheduled_count | bigint | 예정 투여 수 |
| completed_count | bigint | 완료 투여 수 |
| adherence_rate | numeric | 순응도 (%) |

**Note**: 뷰는 기본 테이블의 RLS를 자동 상속

---

## RLS (Row Level Security) Policies

모든 테이블에 RLS가 활성화되어 있으며, 다음 정책이 적용되었습니다:

**일반 테이블 정책 (user_id 기반):**
```sql
ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own data"
ON {table_name}
FOR ALL
USING (auth.uid()::TEXT = user_id);
```

**users 테이블 정책:**
```sql
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid()::TEXT = id);

CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid()::TEXT = id);

CREATE POLICY "Users can insert own profile on signup"
ON users FOR INSERT
WITH CHECK (auth.uid()::TEXT = id);
```

**Parent 소유권 기반 정책 (dose_schedules, dose_records, plan_change_history, symptom_context_tags):**
```sql
CREATE POLICY "Users can access own dose schedules"
ON dose_schedules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()::TEXT
  )
);
```

**badge_definitions 정책 (모든 인증된 사용자 읽기 가능):**
```sql
CREATE POLICY "Badge definitions are readable by all authenticated users"
ON badge_definitions FOR SELECT
USING (auth.role() = 'authenticated');
```

**medications / symptom_types 정책 (모든 인증된 사용자 읽기 가능):**
```sql
CREATE POLICY "Medications readable by authenticated users"
ON medications FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Symptom types readable by authenticated users"
ON symptom_types FOR SELECT
USING (auth.role() = 'authenticated');
```

**RLS 적용 테이블:**
- users
- consent_records
- user_profiles
- dosage_plans
- plan_change_history
- dose_schedules
- dose_records
- weight_logs
- daily_checkins
- badge_definitions
- user_badges
- notification_settings
- guide_feedback
- audit_logs
- medications (읽기 전용)
- symptom_types (읽기 전용)

---

## Indexes Summary

성능 최적화를 위한 주요 인덱스:

1. **dosage_plans**: (user_id, is_active)
2. **dose_schedules**: (dosage_plan_id, scheduled_date)
3. **dose_records**: (dosage_plan_id, administered_at), (injection_site, administered_at DESC)
4. **weight_logs**: (user_id, log_date) UNIQUE, (user_id, log_date DESC)
5. **daily_checkins**: (user_id, checkin_date) UNIQUE, (user_id, checkin_date DESC), PARTIAL (user_id) WHERE red_flag_detected IS NOT NULL, GIN (symptom_details)
6. **badge_definitions**: (category, display_order)
7. **user_badges**: (user_id, badge_id) UNIQUE, (user_id, status), (user_id, achieved_at DESC)
8. **audit_logs**: (user_id, created_at DESC), (entity_type, entity_id)
9. **guide_feedback**: (user_id, created_at DESC)

---

## Trigger Functions

### handle_new_user
신규 사용자 등록 시 public.users 자동 생성

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.users (
    id, oauth_provider, oauth_user_id, name, email,
    profile_image_url, created_at, last_login_at
  ) VALUES (
    NEW.id::TEXT,
    COALESCE(NEW.raw_app_meta_data->>'provider', 'email'),
    NEW.id::TEXT,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Unknown'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

---

## Account Deletion (계정 삭제)

Apple App Store / Google Play Store 정책 준수를 위해 계정 삭제 기능 구현.

### 중요: public.users와 auth.users 관계

```
auth.users (Supabase Auth)
    ↓ (FK 없음 - 같은 ID 값만 사용)
public.users
    ↓ (FK + ON DELETE CASCADE)
모든 관련 테이블
```

**주의**: `public.users`와 `auth.users` 사이에는 FK 제약조건이 없음.
따라서 `auth.users` 삭제 시 `public.users`에 CASCADE가 동작하지 않음.

### 삭제 순서 (필수)

```
1. public.users 삭제 (CASCADE로 모든 관련 데이터 삭제)
   └─ consent_records
   └─ user_profiles
   └─ dosage_plans
       └─ dose_schedules
       └─ dose_records
       └─ plan_change_history
   └─ weight_logs
   └─ daily_checkins
   └─ symptom_logs
   └─ emergency_symptom_checks
   └─ notification_settings
   └─ user_badges
   └─ audit_logs
   └─ guide_feedback

2. auth.users 삭제 (Supabase Auth)
```

### 구현 방식

Edge Function (`supabase/functions/delete-account/index.ts`):
```typescript
// 1. public.users 먼저 삭제 (CASCADE 동작)
await supabaseAdmin.from("users").delete().eq("id", userId);

// 2. auth.users 삭제
await supabaseAdmin.auth.admin.deleteUser(userId, false);
```

### 클라이언트 호출

```dart
// Flutter에서 Edge Function 호출
await _supabase.functions.invoke(
  'delete-account',
  headers: {'Authorization': 'Bearer ${session.accessToken}'},
);
```

---

## Data Retention

MVP는 무제한 보관.
Phase 2 이후 GDPR 준수를 위해 데이터 보관 정책 수립 필요.

---

## Notes

- 모든 timestamp는 timestamptz 사용 (timezone 고려)
- JSON 필드는 jsonb 사용 (쿼리 성능 최적화)
- Supabase PostgreSQL 사용 중
- Repository Pattern으로 Infrastructure Layer 구현
- RLS(Row Level Security)로 데이터 접근 제어 적용
- **users.id는 TEXT 타입** (Supabase Auth UUID를 TEXT로 저장)
- **모든 user_id FK는 TEXT 타입**

### 인증 방식

| Provider | 방식 |
|----------|------|
| Kakao | Native SDK + Supabase Auth (signInWithIdToken) |
| Naver | Native SDK + Edge Function + Supabase Auth |
| Email | Supabase Auth (signUp/signInWithPassword) |

- 비밀번호 저장: Supabase Auth (auth.users) - public.users에 저장 안함
- 비밀번호 재설정: Supabase Auth의 `resetPasswordForEmail()` 사용

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
    └── repositories/
        └── supabase_tracking_repository.dart  # Repository 구현체
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
- ❌ `features/*/domain/repositories/tracking_repository.dart` 중복 생성 금지
- ✅ tracking의 구현을 import하여 사용

**이유:**
1. **Repository Pattern 준수**: 하나의 데이터 소스(weight_logs)는 하나의 Repository
2. **확장성**: tracking의 Repository만 변경하면 모든 기능에 자동 반영
3. **타입 안정성**: 단일 WeightLog 엔티티로 타입 불일치 방지

#### 3. 공통 테이블의 소유권 정의

| 테이블 | 구현 위치 | 사용 기능 | 비고 |
|--------|----------|----------|------|
| weight_logs | `features/tracking/` | onboarding, tracking, dashboard | TrackingRepository 제공 |
| daily_checkins | `features/daily_checkin/` | daily_checkin, dashboard | DailyCheckinRepository 제공 |
| user_profiles | `features/onboarding/` | onboarding, dashboard, profile | ProfileRepository 제공 |
| dosage_plans | `features/tracking/` | onboarding, tracking | MedicationRepository 제공 |
| dose_schedules | `features/tracking/` | onboarding, tracking | ScheduleRepository 제공 |
| badge_definitions | `features/dashboard/` | dashboard | BadgeRepository 제공 |
| user_badges | `features/dashboard/` | dashboard | BadgeRepository 제공 |
| medications | `features/tracking/` | onboarding, tracking | MedicationMasterRepository 제공 |

**원칙:**
- 각 테이블은 **가장 직접적으로 사용하는 기능**이 구현을 소유
- 다른 기능은 소유 기능의 Repository를 import하여 사용
- 중복 구현 절대 금지

#### 4. 데이터 무결성 제약

PostgreSQL의 UNIQUE 제약이 DB 레벨에서 자동 적용됩니다:

```sql
-- weight_logs 테이블 UNIQUE 제약
CREATE UNIQUE INDEX unique_weight_log_per_user_per_date
ON weight_logs(user_id, log_date);
```

Repository 구현:
```dart
Future<void> saveWeightLog(WeightLog log) async {
  await _supabase
      .from('weight_logs')
      .upsert(log.toJson());  // DB가 중복 처리
}
```

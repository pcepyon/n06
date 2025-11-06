# Database Schema Design

## Data Flow

### 1. Authentication & Onboarding
```
users → oauth_tokens
users → consent_records
users → user_profiles → treatment_goals
```

### 2. Dosage Management
```
dosage_plans → dose_schedules → dose_records
dose_records → injection_sites
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
| oauth_provider | varchar(20) | NOT NULL | naver/kakao |
| oauth_user_id | varchar(255) | NOT NULL | 소셜 제공자 사용자 ID |
| name | varchar(100) | NOT NULL | 사용자 이름 |
| email | varchar(255) | NOT NULL | 이메일 |
| profile_image_url | text | NULL | 프로필 이미지 URL |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 가입일시 |
| last_login_at | timestamptz | NOT NULL, DEFAULT now() | 마지막 로그인 일시 |

**Indexes**
- UNIQUE: (oauth_provider, oauth_user_id)

---

### oauth_tokens
인증 토큰 (Supabase Auth 사용 시 불필요, 참고용)

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
| current_weight_kg | numeric(5,2) | NOT NULL | 현재 체중 |
| target_period_weeks | integer | NULL | 목표 기간 (주) |
| weekly_loss_goal_kg | numeric(4,2) | NULL | 주간 감량 목표 (자동 계산) |
| weekly_weight_record_goal | integer | NOT NULL, DEFAULT 7 | 주간 체중 기록 목표 |
| weekly_symptom_record_goal | integer | NOT NULL, DEFAULT 7 | 주간 부작용 기록 목표 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | |

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

---

### injection_sites
주사 부위 이력 (부위 순환 관리)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| dose_record_id | uuid | FK(dose_records.id), UNIQUE, NOT NULL | |
| site_name | varchar(20) | NOT NULL | 복부/허벅지/상완 |
| used_at | timestamptz | NOT NULL | 사용 일시 |

**Indexes**
- INDEX: (site_name, used_at)

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

## RLS (Row Level Security) Policies

**Phase 1 적용**

모든 테이블에 다음 정책 적용:
```sql
ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own data"
ON {table_name}
FOR ALL
USING (user_id = auth.uid());
```

users 테이블:
```sql
CREATE POLICY "Users can only access their own profile"
ON users
FOR ALL
USING (id = auth.uid());
```

---

## Indexes Summary

성능 최적화를 위한 주요 인덱스:

1. **users**: (oauth_provider, oauth_user_id) UNIQUE
2. **dosage_plans**: (user_id, is_active)
3. **dose_schedules**: (dosage_plan_id, scheduled_date)
4. **dose_records**: (dosage_plan_id, administered_at)
5. **injection_sites**: (site_name, used_at)
6. **weight_logs**: (user_id, log_date) UNIQUE, (user_id, log_date DESC)
7. **symptom_logs**: (user_id, log_date DESC)
8. **symptom_context_tags**: (symptom_log_id), (tag_name)
9. **emergency_symptom_checks**: (user_id, checked_at DESC)
10. **badge_definitions**: (category, display_order)
11. **user_badges**: (user_id, badge_id) UNIQUE, (user_id, status), (user_id, achieved_at DESC)

---

## Data Retention

MVP는 무제한 보관.
Phase 2 이후 GDPR 준수를 위해 데이터 보관 정책 수립 필요.

---

## Notes

- 모든 timestamp는 timestamptz 사용 (timezone 고려)
- JSON 필드는 jsonb 사용 (쿼리 성능 최적화)
- Phase 0에서는 Isar 로컬 DB만 사용
- Phase 1에서 Supabase PostgreSQL로 마이그레이션
- Repository Pattern으로 데이터 소스 전환 대비

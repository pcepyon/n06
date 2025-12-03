# Database Extension Design - GLP-1 MVP

> **문서 목적**: Soft Delete, Medications 마스터 테이블, Materialized Views, 다국어 지원을 위한 데이터베이스 확장 설계
> **작성일**: 2025-12-03
> **상태**: 설계 완료 (검증 완료)
> **검증일**: 2025-12-03

---

## 검증 결과 요약

### 발견된 이슈 및 수정 사항

| # | 이슈 | 심각도 | 수정 내용 |
|---|------|--------|----------|
| 1 | Materialized Views는 RLS 미지원 | **Critical** | 보안 wrapper view 추가 또는 API 접근 차단 |
| 2 | 삭제된 테이블 포함 | High | symptom_logs, emergency_symptom_checks 제거 |
| 3 | SECURITY DEFINER search_path | High | `pg_temp` 추가 |
| 4 | RLS 정책 캐스팅 불일치 | Medium | `auth.uid()::TEXT` 일관성 확보 |
| 5 | pg_cron 제한사항 누락 | Medium | 제한사항 문서화 |
| 6 | auth.users 하드삭제 누락 | Medium | 별도 Edge Function 추가 |
| 7 | MedicationTemplate 중복 | Low | 클라이언트 템플릿 제거 권장 |

---

## 목차

1. [Soft Delete 패턴](#1-soft-delete-패턴)
2. [Medications 마스터 테이블](#2-medications-마스터-테이블)
3. [집계 최적화 (Materialized Views)](#3-집계-최적화-materialized-views)
4. [다국어(i18n) 지원](#4-다국어i18n-지원)
5. [Flutter 코드 변경](#5-flutter-코드-변경)
6. [구현 순서](#6-구현-순서)
7. [테스트 전략](#7-테스트-전략)
8. [에러 처리](#8-에러-처리)

---

## 1. Soft Delete 패턴

### 1.1 설계 개요

**원칙:**
- 모든 사용자 데이터 테이블에 `deleted_at timestamptz` 컬럼 추가
- RLS 정책에 `deleted_at IS NULL` 조건 자동 포함
- 계정 탈퇴 시 30일 유예 기간 후 물리적 삭제

**대상 테이블 (현재 존재하는 테이블만):**
| 테이블 | 우선순위 | FK 의존성 | 비고 |
|--------|----------|-----------|------|
| users | 1 (최상위) | - | |
| consent_records | 2 | users | |
| user_profiles | 2 | users | |
| dosage_plans | 2 | users, medications | |
| dose_schedules | 3 | dosage_plans | |
| dose_records | 3 | dosage_plans, dose_schedules | |
| plan_change_history | 3 | dosage_plans | |
| weight_logs | 2 | users | |
| daily_checkins | 2 | users | symptom_logs 통합됨 |
| user_badges | 2 | users, badge_definitions | |
| notification_settings | 2 | users | |
| audit_logs | 2 | users | |
| guide_feedback | 2 | users | |

> **Note**: `symptom_logs`, `symptom_context_tags`, `emergency_symptom_checks` 테이블은
> `06.daily_checkins.sql` 마이그레이션에서 DROP되어 `daily_checkins`로 통합됨.

### 1.2 스키마 변경

```sql
-- ============================================
-- 1. Soft Delete 컬럼 추가
-- ============================================

-- users 테이블
ALTER TABLE users ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- consent_records 테이블
ALTER TABLE consent_records ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_consent_records_deleted_at ON consent_records(deleted_at) WHERE deleted_at IS NOT NULL;

-- user_profiles 테이블
ALTER TABLE user_profiles ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_user_profiles_deleted_at ON user_profiles(deleted_at) WHERE deleted_at IS NOT NULL;

-- dosage_plans 테이블
ALTER TABLE dosage_plans ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_dosage_plans_deleted_at ON dosage_plans(deleted_at) WHERE deleted_at IS NOT NULL;

-- dose_schedules 테이블
ALTER TABLE dose_schedules ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_dose_schedules_deleted_at ON dose_schedules(deleted_at) WHERE deleted_at IS NOT NULL;

-- dose_records 테이블
ALTER TABLE dose_records ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_dose_records_deleted_at ON dose_records(deleted_at) WHERE deleted_at IS NOT NULL;

-- plan_change_history 테이블
ALTER TABLE plan_change_history ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_plan_change_history_deleted_at ON plan_change_history(deleted_at) WHERE deleted_at IS NOT NULL;

-- weight_logs 테이블
ALTER TABLE weight_logs ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_weight_logs_deleted_at ON weight_logs(deleted_at) WHERE deleted_at IS NOT NULL;

-- daily_checkins 테이블
ALTER TABLE daily_checkins ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_daily_checkins_deleted_at ON daily_checkins(deleted_at) WHERE deleted_at IS NOT NULL;

-- user_badges 테이블
ALTER TABLE user_badges ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_user_badges_deleted_at ON user_badges(deleted_at) WHERE deleted_at IS NOT NULL;

-- notification_settings 테이블
ALTER TABLE notification_settings ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_notification_settings_deleted_at ON notification_settings(deleted_at) WHERE deleted_at IS NOT NULL;

-- audit_logs 테이블
ALTER TABLE audit_logs ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_audit_logs_deleted_at ON audit_logs(deleted_at) WHERE deleted_at IS NOT NULL;

-- guide_feedback 테이블
ALTER TABLE guide_feedback ADD COLUMN deleted_at timestamptz NULL;
CREATE INDEX idx_guide_feedback_deleted_at ON guide_feedback(deleted_at) WHERE deleted_at IS NOT NULL;
```

### 1.3 RLS 정책 업데이트

> **중요**: 기존 RLS 정책과의 일관성을 위해 `auth.uid()` 사용 방식 확인 필요.
> - `users.id`는 TEXT 타입
> - `auth.uid()`는 UUID 타입 반환
> - 비교 시 암시적 캐스팅 발생하나, 명시적 캐스팅 권장

```sql
-- ============================================
-- 2. RLS 정책 업데이트 (Soft Delete 조건 추가)
-- ============================================

-- users 테이블
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;

CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid()::TEXT = id AND deleted_at IS NULL);

CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid()::TEXT = id AND deleted_at IS NULL);

-- users INSERT 정책은 유지 (삭제된 계정 복구용)
-- 새 계정 생성 시에는 deleted_at이 NULL이므로 문제없음

-- consent_records 테이블
DROP POLICY IF EXISTS "Users can access own consent records" ON consent_records;

CREATE POLICY "Users can access own consent records"
ON consent_records FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- user_profiles 테이블
DROP POLICY IF EXISTS "Users can access own profile" ON user_profiles;

CREATE POLICY "Users can access own profile"
ON user_profiles FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- dosage_plans 테이블
DROP POLICY IF EXISTS "Users can access own dosage plans" ON dosage_plans;

CREATE POLICY "Users can access own dosage plans"
ON dosage_plans FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- dose_schedules 테이블
DROP POLICY IF EXISTS "Users can access own dose schedules" ON dose_schedules;

CREATE POLICY "Users can access own dose schedules"
ON dose_schedules FOR ALL
USING (
  deleted_at IS NULL AND
  EXISTS (
    SELECT 1 FROM dosage_plans
    WHERE id = dose_schedules.dosage_plan_id
    AND user_id = auth.uid()::TEXT
    AND deleted_at IS NULL
  )
);

-- dose_records 테이블
DROP POLICY IF EXISTS "Users can access own dose records" ON dose_records;

CREATE POLICY "Users can access own dose records"
ON dose_records FOR ALL
USING (
  deleted_at IS NULL AND
  EXISTS (
    SELECT 1 FROM dosage_plans
    WHERE id = dose_records.dosage_plan_id
    AND user_id = auth.uid()::TEXT
    AND deleted_at IS NULL
  )
);

-- plan_change_history 테이블
DROP POLICY IF EXISTS "Users can access own plan history" ON plan_change_history;

CREATE POLICY "Users can access own plan history"
ON plan_change_history FOR ALL
USING (
  deleted_at IS NULL AND
  EXISTS (
    SELECT 1 FROM dosage_plans
    WHERE id = plan_change_history.dosage_plan_id
    AND user_id = auth.uid()::TEXT
    AND deleted_at IS NULL
  )
);

-- weight_logs 테이블
DROP POLICY IF EXISTS "Users can access own weight logs" ON weight_logs;

CREATE POLICY "Users can access own weight logs"
ON weight_logs FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- daily_checkins 테이블
DROP POLICY IF EXISTS "Users can only access their own checkins" ON daily_checkins;

CREATE POLICY "Users can access own daily checkins"
ON daily_checkins FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- user_badges 테이블
DROP POLICY IF EXISTS "Users can access own badges" ON user_badges;

CREATE POLICY "Users can access own badges"
ON user_badges FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- notification_settings 테이블
DROP POLICY IF EXISTS "Users can access own notification settings" ON notification_settings;

CREATE POLICY "Users can access own notification settings"
ON notification_settings FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- audit_logs 테이블
DROP POLICY IF EXISTS "Users can access own audit logs" ON audit_logs;

CREATE POLICY "Users can access own audit logs"
ON audit_logs FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);

-- guide_feedback 테이블
DROP POLICY IF EXISTS "Users can access own guide feedback" ON guide_feedback;

CREATE POLICY "Users can access own guide feedback"
ON guide_feedback FOR ALL
USING (auth.uid()::TEXT = user_id AND deleted_at IS NULL);
```

### 1.4 Soft Delete 함수

> **보안 강화**: `SET search_path = public, pg_temp` 사용 (pg_temp 필수)
>
> 참조: [PostgreSQL SECURITY DEFINER 보안](https://www.cybertec-postgresql.com/en/abusing-security-definer-functions/)

```sql
-- ============================================
-- 3. Soft Delete 유틸리티 함수
-- ============================================

-- 계정 Soft Delete 함수 (30일 유예 시작)
CREATE OR REPLACE FUNCTION soft_delete_user_account(target_user_id TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp  -- pg_temp 추가 (보안)
AS $$
DECLARE
  current_time timestamptz := NOW();
BEGIN
  -- 모든 관련 데이터 soft delete (FK 의존성 순서 준수)
  -- Level 3: 자식 테이블
  UPDATE dose_schedules SET deleted_at = current_time
  WHERE dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = target_user_id);

  UPDATE dose_records SET deleted_at = current_time
  WHERE dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = target_user_id);

  UPDATE plan_change_history SET deleted_at = current_time
  WHERE dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = target_user_id);

  -- Level 2: user_id 직접 참조 테이블
  UPDATE consent_records SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE user_profiles SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE dosage_plans SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE weight_logs SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE daily_checkins SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE user_badges SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE notification_settings SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE audit_logs SET deleted_at = current_time WHERE user_id = target_user_id;
  UPDATE guide_feedback SET deleted_at = current_time WHERE user_id = target_user_id;

  -- Level 1: users 테이블
  UPDATE users SET deleted_at = current_time WHERE id = target_user_id;
END;
$$;

-- 계정 복구 함수 (30일 이내)
CREATE OR REPLACE FUNCTION restore_user_account(target_user_id TEXT)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  user_deleted_at timestamptz;
BEGIN
  -- 삭제된 유저 확인
  SELECT deleted_at INTO user_deleted_at
  FROM users WHERE id = target_user_id AND deleted_at IS NOT NULL;

  IF user_deleted_at IS NULL THEN
    RETURN false; -- 이미 활성 상태이거나 존재하지 않음
  END IF;

  -- 30일 경과 확인
  IF user_deleted_at < NOW() - INTERVAL '30 days' THEN
    RETURN false; -- 복구 기간 만료
  END IF;

  -- 모든 관련 데이터 복구 (역순)
  UPDATE users SET deleted_at = NULL WHERE id = target_user_id;
  UPDATE consent_records SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE user_profiles SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE dosage_plans SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE weight_logs SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE daily_checkins SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE user_badges SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE notification_settings SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE audit_logs SET deleted_at = NULL WHERE user_id = target_user_id;
  UPDATE guide_feedback SET deleted_at = NULL WHERE user_id = target_user_id;

  -- 자식 테이블 복구
  UPDATE dose_schedules SET deleted_at = NULL
  WHERE dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = target_user_id);

  UPDATE dose_records SET deleted_at = NULL
  WHERE dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = target_user_id);

  UPDATE plan_change_history SET deleted_at = NULL
  WHERE dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = target_user_id);

  RETURN true;
END;
$$;
```

### 1.5 하드 삭제 구현 (권장안: pg_cron)

**선택 이유:**
- Supabase에서 pg_cron 확장 기본 제공
- Edge Function 대비 DB 레벨에서 직접 실행 → 네트워크 오버헤드 없음
- 트랜잭션 내 원자적 삭제 가능

> **pg_cron 제한사항** (Supabase):
> - 동시 실행 Job 수: **최대 8개**
> - Job 실행 시간: **최대 10분**
> - Job은 `cron.job` 테이블에 저장
> - 실행 기록은 `cron.job_run_details`에 기록

```sql
-- ============================================
-- 4. pg_cron 설정 및 하드 삭제 Job
-- ============================================

-- pg_cron 확장 활성화 (Supabase Dashboard > Database > Extensions)
-- 또는 SQL로 활성화:
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- cron 스키마 권한 부여 (필요시)
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;

-- 30일 경과 데이터 하드 삭제 함수
CREATE OR REPLACE FUNCTION hard_delete_expired_accounts()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  expired_threshold timestamptz := NOW() - INTERVAL '30 days';
  expired_user_ids TEXT[];
BEGIN
  -- 만료된 user_id 목록 조회
  SELECT ARRAY_AGG(id) INTO expired_user_ids
  FROM users
  WHERE deleted_at IS NOT NULL
  AND deleted_at < expired_threshold;

  -- 삭제할 사용자가 없으면 종료
  IF expired_user_ids IS NULL OR array_length(expired_user_ids, 1) IS NULL THEN
    RETURN;
  END IF;

  -- FK 의존성 역순으로 삭제 (자식 → 부모)

  -- Level 3: 손자 테이블
  DELETE FROM dose_schedules
  WHERE dosage_plan_id IN (
    SELECT id FROM dosage_plans WHERE user_id = ANY(expired_user_ids)
  );

  DELETE FROM dose_records
  WHERE dosage_plan_id IN (
    SELECT id FROM dosage_plans WHERE user_id = ANY(expired_user_ids)
  );

  DELETE FROM plan_change_history
  WHERE dosage_plan_id IN (
    SELECT id FROM dosage_plans WHERE user_id = ANY(expired_user_ids)
  );

  -- Level 2: 자식 테이블
  DELETE FROM consent_records WHERE user_id = ANY(expired_user_ids);
  DELETE FROM user_profiles WHERE user_id = ANY(expired_user_ids);
  DELETE FROM dosage_plans WHERE user_id = ANY(expired_user_ids);
  DELETE FROM weight_logs WHERE user_id = ANY(expired_user_ids);
  DELETE FROM daily_checkins WHERE user_id = ANY(expired_user_ids);
  DELETE FROM user_badges WHERE user_id = ANY(expired_user_ids);
  DELETE FROM notification_settings WHERE user_id = ANY(expired_user_ids);
  DELETE FROM audit_logs WHERE user_id = ANY(expired_user_ids);
  DELETE FROM guide_feedback WHERE user_id = ANY(expired_user_ids);

  -- Level 1: 부모 테이블 (마지막)
  DELETE FROM users WHERE id = ANY(expired_user_ids);

  -- 로깅
  RAISE NOTICE 'Hard deleted % expired user accounts', array_length(expired_user_ids, 1);
END;
$$;

-- 매일 UTC 15:00 (KST 00:00)에 실행하는 Cron Job 생성
SELECT cron.schedule(
  'hard-delete-expired-accounts',
  '0 15 * * *',  -- UTC 15:00 = KST 00:00
  $$SELECT hard_delete_expired_accounts()$$
);

-- Cron Job 확인
-- SELECT * FROM cron.job;

-- Cron Job 실행 이력 확인
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- Cron Job 삭제 (필요시)
-- SELECT cron.unschedule('hard-delete-expired-accounts');
```

### 1.6 auth.users 하드 삭제 처리

> **중요**: `public.users`와 `auth.users` 사이에는 FK 제약조건이 없음.
> 30일 경과 후 `public.users` 삭제 시 `auth.users`도 별도로 삭제해야 함.

**방법 1: Edge Function으로 처리 (권장)**

```typescript
// supabase/functions/cleanup-expired-auth-users/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * 30일 경과된 계정의 auth.users 삭제
 * Cron으로 매일 실행 (hard_delete_expired_accounts 직후)
 */
serve(async (req) => {
  try {
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      { auth: { persistSession: false } }
    );

    // public.users에서 삭제되었지만 auth.users에 남아있는 사용자 조회
    // (public.users에 없는 auth.users 찾기)
    const { data: authUsers, error: listError } =
      await supabaseAdmin.auth.admin.listUsers();

    if (listError) throw listError;

    const { data: publicUsers } = await supabaseAdmin
      .from("users")
      .select("id");

    const publicUserIds = new Set(publicUsers?.map(u => u.id) ?? []);

    // public.users에 없는 auth.users 삭제
    const orphanedAuthUsers = authUsers.users.filter(
      u => !publicUserIds.has(u.id)
    );

    let deletedCount = 0;
    for (const user of orphanedAuthUsers) {
      const { error } = await supabaseAdmin.auth.admin.deleteUser(user.id);
      if (!error) deletedCount++;
    }

    return new Response(JSON.stringify({
      success: true,
      deleted_count: deletedCount
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});
```

### 1.7 Edge Function 업데이트 (delete-account)

기존 하드 삭제에서 Soft Delete로 변경:

```typescript
// supabase/functions/delete-account/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization")!;
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // JWT에서 user_id 추출
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } =
      await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Soft Delete 함수 호출 (30일 유예 시작)
    const { error: deleteError } = await supabaseAdmin.rpc(
      "soft_delete_user_account",
      { target_user_id: user.id }
    );

    if (deleteError) {
      console.error("Soft delete error:", deleteError);
      return new Response(JSON.stringify({ error: "Failed to delete account" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // auth.users는 즉시 삭제하지 않음 (복구 가능하도록)
    // 30일 후 cleanup-expired-auth-users Edge Function에서 처리

    const recoverableUntil = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    return new Response(JSON.stringify({
      success: true,
      message: "Account scheduled for deletion. You have 30 days to recover.",
      recoverable_until: recoverableUntil.toISOString()
    }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: error instanceof Error ? error.message : String(error)
    }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
```

---

## 2. Medications 마스터 테이블

### 2.1 테이블 정의

```sql
-- ============================================
-- 5. Medications 마스터 테이블
-- ============================================

CREATE TABLE medications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name varchar(100) NOT NULL UNIQUE,
  generic_name varchar(100) NOT NULL,
  manufacturer varchar(100) NULL,
  standard_doses numeric[] NOT NULL,
  max_dose_mg numeric(6,2) NOT NULL,
  default_cycle_days integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_medications_name ON medications(name);
CREATE INDEX idx_medications_generic_name ON medications(generic_name);
CREATE INDEX idx_medications_is_active ON medications(is_active) WHERE is_active = true;

-- RLS 활성화
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 모든 인증 사용자 읽기 가능
CREATE POLICY "Medications are readable by authenticated users"
ON medications FOR SELECT
USING (auth.role() = 'authenticated');

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_medications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER medications_updated_at
  BEFORE UPDATE ON medications
  FOR EACH ROW
  EXECUTE FUNCTION update_medications_updated_at();
```

### 2.2 시드 데이터

```sql
-- ============================================
-- 6. Medications 시드 데이터
-- ============================================

INSERT INTO medications (name, generic_name, manufacturer, standard_doses, max_dose_mg, default_cycle_days)
VALUES
  ('위고비', 'semaglutide', 'Novo Nordisk', ARRAY[0.25, 0.5, 1.0, 1.7, 2.4], 2.4, 7),
  ('삭센다', 'liraglutide', 'Novo Nordisk', ARRAY[0.6, 1.2, 1.8, 2.4, 3.0], 3.0, 1),
  ('마운자로', 'tirzepatide', 'Eli Lilly', ARRAY[2.5, 5.0, 7.5, 10.0, 12.5, 15.0], 15.0, 7),
  ('젭바운드', 'tirzepatide', 'Eli Lilly', ARRAY[2.5, 5.0, 7.5, 10.0, 12.5, 15.0], 15.0, 7)
ON CONFLICT (name) DO NOTHING;
```

### 2.3 dosage_plans 테이블 수정

> **중요**: 기존 `medication_name` 데이터를 `medication_id`로 마이그레이션 필요

```sql
-- ============================================
-- 7. dosage_plans FK 마이그레이션
-- ============================================

-- medication_id 컬럼 추가 (처음에는 NULL 허용)
ALTER TABLE dosage_plans
ADD COLUMN medication_id uuid NULL REFERENCES medications(id);

-- 기존 medication_name을 medication_id로 마이그레이션
-- 한글 약물명 매칭
UPDATE dosage_plans dp
SET medication_id = m.id
FROM medications m
WHERE dp.medication_name = m.name
AND dp.medication_id IS NULL;

-- 영문명/기타 형식 매칭 시도
UPDATE dosage_plans dp
SET medication_id = m.id
FROM medications m
WHERE LOWER(dp.medication_name) LIKE '%wegovy%' OR LOWER(dp.medication_name) LIKE '%semaglutide%'
AND m.name = '위고비'
AND dp.medication_id IS NULL;

UPDATE dosage_plans dp
SET medication_id = m.id
FROM medications m
WHERE LOWER(dp.medication_name) LIKE '%mounjaro%' OR LOWER(dp.medication_name) LIKE '%tirzepatide%'
AND m.name = '마운자로'
AND dp.medication_id IS NULL;

-- 여전히 매칭되지 않는 레코드는 기본값(위고비)으로 설정
UPDATE dosage_plans dp
SET medication_id = (SELECT id FROM medications WHERE name = '위고비' LIMIT 1)
WHERE dp.medication_id IS NULL;

-- medication_id NOT NULL 제약 추가
ALTER TABLE dosage_plans
ALTER COLUMN medication_id SET NOT NULL;

-- medication_name 컬럼 삭제
ALTER TABLE dosage_plans
DROP COLUMN medication_name;

-- 인덱스 추가
CREATE INDEX idx_dosage_plans_medication_id ON dosage_plans(medication_id);
```

---

## 3. 집계 최적화 (Materialized Views)

### 3.1 보안 주의사항

> **Critical**: PostgreSQL은 Materialized Views에 RLS를 지원하지 않음!
>
> Supabase API를 통해 직접 접근 시 모든 사용자의 데이터가 노출될 수 있음.
>
> 참조: [Materialized Views and RLS](https://stackoverflow.com/questions/77198207/using-materialized-views-for-rls-in-supabase-best-practices-and-ui-limitations)

**해결 방안:**

| 방안 | 설명 | 권장 |
|------|------|------|
| A. API 접근 차단 | Supabase API에서 MV 접근 차단 | **권장** |
| B. Security Invoker View | MV를 감싸는 RLS 적용 view 생성 | 대안 |
| C. 서버 전용 | MV는 pg_cron/Edge Function에서만 사용 | 대안 |

**방안 A 구현: PostgREST에서 MV 숨기기**

```sql
-- Materialized View를 별도 스키마로 이동
CREATE SCHEMA IF NOT EXISTS analytics;

-- MV를 analytics 스키마에 생성 (public이 아닌)
-- PostgREST는 기본적으로 public 스키마만 노출
```

**방안 B 구현: Security Invoker View**

```sql
-- MV를 감싸는 보안 뷰 생성 (PostgreSQL 15+)
CREATE OR REPLACE VIEW public.user_weekly_summary_secure
WITH (security_invoker = true)
AS
SELECT uws.*
FROM analytics.user_weekly_summary uws
JOIN users u ON uws.user_id = u.id
WHERE u.deleted_at IS NULL;

-- RLS는 users 테이블의 정책을 통해 적용됨
```

### 3.2 pg_cron 확장 활성화

```sql
-- Supabase Dashboard > Database > Extensions에서 pg_cron 활성화
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### 3.3 주간 체중 요약 뷰

```sql
-- ============================================
-- 8. Materialized Views (analytics 스키마)
-- ============================================

CREATE SCHEMA IF NOT EXISTS analytics;

-- 주간 체중 요약
CREATE MATERIALIZED VIEW analytics.user_weekly_summary AS
SELECT
  user_id,
  DATE_TRUNC('week', log_date)::date AS week_start,
  MIN(weight_kg) AS min_weight,
  MAX(weight_kg) AS max_weight,
  AVG(weight_kg)::numeric(5,2) AS avg_weight,
  COUNT(*) AS record_count,
  MAX(weight_kg) - MIN(weight_kg) AS weight_range
FROM weight_logs
WHERE deleted_at IS NULL
GROUP BY user_id, DATE_TRUNC('week', log_date)
ORDER BY user_id, week_start DESC;

-- UNIQUE INDEX for CONCURRENTLY refresh
CREATE UNIQUE INDEX idx_user_weekly_summary_pk
ON analytics.user_weekly_summary(user_id, week_start);

-- 쿼리 성능 인덱스
CREATE INDEX idx_user_weekly_summary_user_week
ON analytics.user_weekly_summary(user_id, week_start DESC);
```

### 3.4 월간 요약 뷰

```sql
-- 월간 체중 변화 및 목표 달성률
CREATE MATERIALIZED VIEW analytics.user_monthly_summary AS
WITH monthly_weights AS (
  SELECT
    user_id,
    DATE_TRUNC('month', log_date)::date AS month_start,
    MIN(weight_kg) AS min_weight,
    MAX(weight_kg) AS max_weight,
    AVG(weight_kg)::numeric(5,2) AS avg_weight,
    COUNT(*) AS record_count,
    (ARRAY_AGG(weight_kg ORDER BY log_date ASC))[1] AS first_weight,
    (ARRAY_AGG(weight_kg ORDER BY log_date DESC))[1] AS last_weight
  FROM weight_logs
  WHERE deleted_at IS NULL
  GROUP BY user_id, DATE_TRUNC('month', log_date)
)
SELECT
  mw.user_id,
  mw.month_start,
  mw.min_weight,
  mw.max_weight,
  mw.avg_weight,
  mw.record_count,
  mw.first_weight,
  mw.last_weight,
  CASE
    WHEN mw.first_weight > 0 THEN
      ((mw.first_weight - mw.last_weight) / mw.first_weight * 100)::numeric(5,2)
    ELSE 0
  END AS weight_change_percent,
  up.target_weight_kg,
  CASE
    WHEN mw.last_weight <= COALESCE(up.target_weight_kg, 0) THEN 100
    WHEN mw.first_weight <= COALESCE(up.target_weight_kg, 0) THEN 100
    WHEN COALESCE(up.target_weight_kg, 0) > 0 AND mw.first_weight > up.target_weight_kg THEN
      LEAST(100, GREATEST(0,
        ((mw.first_weight - mw.last_weight) /
         NULLIF(mw.first_weight - up.target_weight_kg, 0) * 100
        )::numeric(5,2)
      ))
    ELSE 0
  END AS goal_progress_percent
FROM monthly_weights mw
LEFT JOIN user_profiles up ON mw.user_id = up.user_id AND up.deleted_at IS NULL;

CREATE UNIQUE INDEX idx_user_monthly_summary_pk
ON analytics.user_monthly_summary(user_id, month_start);
```

### 3.5 연속 기록 통계 뷰

```sql
-- 연속 기록 일수 및 뱃지 진행도
CREATE MATERIALIZED VIEW analytics.user_streak_stats AS
WITH daily_activity AS (
  -- 모든 기록 활동 통합 (체중, 체크인, 투여)
  SELECT user_id, log_date::date AS activity_date
  FROM weight_logs WHERE deleted_at IS NULL
  UNION
  SELECT user_id, checkin_date::date AS activity_date
  FROM daily_checkins WHERE deleted_at IS NULL
  UNION
  SELECT
    dp.user_id,
    dr.administered_at::date AS activity_date
  FROM dose_records dr
  JOIN dosage_plans dp ON dr.dosage_plan_id = dp.id
  WHERE dr.deleted_at IS NULL AND dp.deleted_at IS NULL
),
distinct_activity AS (
  SELECT DISTINCT user_id, activity_date FROM daily_activity
),
streak_groups AS (
  SELECT
    user_id,
    activity_date,
    activity_date - (ROW_NUMBER() OVER (
      PARTITION BY user_id ORDER BY activity_date
    ))::integer AS streak_group
  FROM distinct_activity
),
streaks AS (
  SELECT
    user_id,
    streak_group,
    MIN(activity_date) AS streak_start,
    MAX(activity_date) AS streak_end,
    COUNT(*) AS streak_days
  FROM streak_groups
  GROUP BY user_id, streak_group
),
user_stats AS (
  SELECT DISTINCT user_id FROM daily_activity
)
SELECT
  us.user_id,
  -- 현재 연속 기록 일수 (오늘 또는 어제까지)
  COALESCE(
    (SELECT s.streak_days FROM streaks s
     WHERE s.user_id = us.user_id
     AND s.streak_end >= CURRENT_DATE - 1
     ORDER BY s.streak_end DESC LIMIT 1),
    0
  ) AS current_streak,
  -- 최대 연속 기록 일수
  COALESCE((SELECT MAX(s.streak_days) FROM streaks s WHERE s.user_id = us.user_id), 0) AS max_streak,
  -- 총 기록 일수
  (SELECT COUNT(*) FROM distinct_activity da WHERE da.user_id = us.user_id) AS total_record_days
FROM user_stats us;

CREATE UNIQUE INDEX idx_user_streak_stats_pk
ON analytics.user_streak_stats(user_id);
```

### 3.6 보안 Wrapper Views (public 스키마)

```sql
-- ============================================
-- 9. 보안 Wrapper Views (RLS 적용)
-- ============================================

-- 주간 요약 보안 뷰
CREATE OR REPLACE VIEW public.my_weekly_summary AS
SELECT uws.*
FROM analytics.user_weekly_summary uws
WHERE uws.user_id = auth.uid()::TEXT;

-- 월간 요약 보안 뷰
CREATE OR REPLACE VIEW public.my_monthly_summary AS
SELECT ums.*
FROM analytics.user_monthly_summary ums
WHERE ums.user_id = auth.uid()::TEXT;

-- 연속 기록 보안 뷰
CREATE OR REPLACE VIEW public.my_streak_stats AS
SELECT uss.*
FROM analytics.user_streak_stats uss
WHERE uss.user_id = auth.uid()::TEXT;

-- 뷰에 대한 SELECT 권한 부여
GRANT SELECT ON public.my_weekly_summary TO authenticated;
GRANT SELECT ON public.my_monthly_summary TO authenticated;
GRANT SELECT ON public.my_streak_stats TO authenticated;
```

### 3.7 Materialized View 갱신 스케줄

```sql
-- ============================================
-- 10. Materialized View 갱신 Cron Jobs
-- ============================================

-- 뷰 갱신 함수
CREATE OR REPLACE FUNCTION analytics.refresh_all_materialized_views()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = analytics, public, pg_temp
AS $$
BEGIN
  -- CONCURRENTLY: 읽기 잠금 없이 갱신 (UNIQUE INDEX 필요)
  REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.user_weekly_summary;
  REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.user_monthly_summary;
  REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.user_streak_stats;

  RAISE NOTICE 'All materialized views refreshed at %', NOW();
EXCEPTION WHEN OTHERS THEN
  -- 에러 로깅
  INSERT INTO public.system_alerts (alert_type, message, details)
  VALUES ('MV_REFRESH_FAILED', 'Materialized view refresh failed',
          jsonb_build_object('error', SQLERRM, 'time', NOW()));
  RAISE;
END;
$$;

-- 매일 UTC 15:00 (KST 00:00)에 갱신
SELECT cron.schedule(
  'refresh-materialized-views',
  '0 15 * * *',
  $$SELECT analytics.refresh_all_materialized_views()$$
);
```

### 3.8 성능 최적화 인덱스

```sql
-- ============================================
-- 11. 추가 성능 인덱스
-- ============================================

-- weight_logs: 주간 통계 쿼리 최적화
CREATE INDEX idx_weight_logs_user_week
ON weight_logs(user_id, DATE_TRUNC('week', log_date))
WHERE deleted_at IS NULL;

-- daily_checkins: 월간 통계 쿼리 최적화
CREATE INDEX idx_daily_checkins_user_month
ON daily_checkins(user_id, DATE_TRUNC('month', checkin_date))
WHERE deleted_at IS NULL;

-- dose_records: 연속 기록 쿼리 최적화
CREATE INDEX idx_dose_records_plan_date
ON dose_records(dosage_plan_id, administered_at::date)
WHERE deleted_at IS NULL;
```

---

## 4. 다국어(i18n) 지원

### 4.1 설계 방식

**클라이언트 처리 방식 채택:**
- DB 스키마 변경 없음
- badge_definitions.id를 키로 클라이언트에서 번역
- Enum 값(증상명, 주사 부위, 상태값)은 클라이언트 매핑

### 4.2 지원 언어

| 코드 | 언어 | 기본값 |
|------|------|--------|
| ko | 한국어 | O |
| en | English | - |
| ja | 日本語 | - |

### 4.3 Flutter ARB 파일 구조

```
lib/
└── l10n/
    ├── app_ko.arb          # 한국어 (기본)
    ├── app_en.arb          # 영어
    ├── app_ja.arb          # 일본어
    └── l10n.yaml           # 설정
```

**l10n.yaml:**
```yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

### 4.4 ARB 키 네이밍 규칙

```
{category}_{subCategory}_{identifier}

예시:
- badge_streak_7_name: "7일 연속 기록"
- badge_streak_7_description: "7일 연속 기록을 달성했습니다"
- symptom_nausea: "메스꺼움"
- injection_site_abdomen: "복부"
- checkin_mood_good: "좋음"
```

### 4.5 한국어 ARB 예시 (app_ko.arb)

```json
{
  "@@locale": "ko",

  "__BADGES__": "뱃지 관련",
  "badge_streak_3_name": "3일 연속",
  "badge_streak_3_description": "3일 연속 기록을 달성했습니다",
  "badge_streak_7_name": "7일 연속",
  "badge_streak_7_description": "일주일 동안 매일 기록했습니다",

  "__SYMPTOMS__": "증상명",
  "symptom_nausea": "메스꺼움",
  "symptom_vomiting": "구토",
  "symptom_diarrhea": "설사",

  "__INJECTION_SITES__": "주사 부위",
  "injection_site_abdomen": "복부",
  "injection_site_thigh": "허벅지",
  "injection_site_arm": "상완",

  "__CHECKIN_STATUS__": "체크인 상태값",
  "checkin_meal_good": "좋음",
  "checkin_meal_moderate": "보통",
  "checkin_meal_difficult": "힘듦"
}
```

### 4.6 Flutter Enum 매핑 유틸리티

```dart
// lib/core/l10n/enum_localizations.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Badge ID → 로컬라이즈된 텍스트 매핑
extension BadgeLocalization on String {
  String localizedBadgeName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      'streak_3' => l10n.badge_streak_3_name,
      'streak_7' => l10n.badge_streak_7_name,
      // ... 추가 매핑
      _ => this, // fallback
    };
  }
}

/// 주사 부위 Enum
enum InjectionSite {
  abdomen,
  thigh,
  arm;

  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      InjectionSite.abdomen => l10n.injection_site_abdomen,
      InjectionSite.thigh => l10n.injection_site_thigh,
      InjectionSite.arm => l10n.injection_site_arm,
    };
  }

  static InjectionSite fromString(String value) {
    return switch (value) {
      'abdomen' => InjectionSite.abdomen,
      'thigh' => InjectionSite.thigh,
      'arm' => InjectionSite.arm,
      _ => throw ArgumentError('Unknown injection site: $value'),
    };
  }

  String toDbValue() => name;
}
```

---

## 5. Flutter 코드 변경

### 5.1 신규/수정 Entity 목록

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `features/tracking/domain/entities/medication.dart` | 신규 | Medication 마스터 데이터 엔티티 |
| `features/tracking/domain/entities/dosage_plan.dart` | 수정 | medication_name → medication_id, medication 참조 추가 |
| `features/tracking/domain/entities/medication_template.dart` | **삭제 권장** | DB medications 테이블로 대체 |
| `core/l10n/enum_localizations.dart` | 신규 | 다국어 Enum 매핑 |

### 5.2 MedicationTemplate 제거 권장

> 현재 `MedicationTemplate` 클래스가 클라이언트에 하드코딩되어 있음.
> DB `medications` 테이블과 중복 관리 문제 발생 가능.

**마이그레이션 방안:**
1. `medications` 테이블에서 데이터 조회
2. `MedicationTemplate` 참조를 `Medication` 엔티티로 교체
3. 기존 `MedicationTemplate` 클래스 deprecated 처리 후 제거

### 5.3 Repository 인터페이스 변경

```dart
// features/tracking/domain/repositories/medication_repository.dart

abstract class MedicationRepository {
  // 기존 메서드들...

  /// 신규: 모든 약물 마스터 데이터 조회
  Future<List<Medication>> getAllMedications();

  /// 신규: ID로 약물 조회
  Future<Medication?> getMedicationById(String id);

  /// 신규: 이름으로 약물 조회
  Future<Medication?> getMedicationByName(String name);
}
```

### 5.4 Provider/Notifier 변경

```dart
// features/tracking/application/providers.dart

/// 약물 마스터 데이터 Provider (캐시됨)
@Riverpod(keepAlive: true)
Future<List<Medication>> medications(MedicationsRef ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getAllMedications();
}
```

### 5.5 새 Entity 구현

```dart
// features/tracking/domain/entities/medication.dart

import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String name;
  final String genericName;
  final String? manufacturer;
  final List<double> standardDoses;
  final double maxDoseMg;
  final int defaultCycleDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    required this.id,
    required this.name,
    required this.genericName,
    this.manufacturer,
    required this.standardDoses,
    required this.maxDoseMg,
    required this.defaultCycleDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['generic_name'] as String,
      manufacturer: json['manufacturer'] as String?,
      standardDoses: (json['standard_doses'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      maxDoseMg: (json['max_dose_mg'] as num).toDouble(),
      defaultCycleDays: json['default_cycle_days'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'generic_name': genericName,
    'manufacturer': manufacturer,
    'standard_doses': standardDoses,
    'max_dose_mg': maxDoseMg,
    'default_cycle_days': defaultCycleDays,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, genericName, manufacturer,
    standardDoses, maxDoseMg, defaultCycleDays, isActive, createdAt, updatedAt];
}
```

---

## 6. 구현 순서

### 6.1 마이그레이션 파일 네이밍

```
supabase/migrations/
├── 20251203000001_add_soft_delete_columns.sql
├── 20251203000002_update_rls_policies_soft_delete.sql
├── 20251203000003_create_soft_delete_functions.sql
├── 20251203000004_create_medications_table.sql
├── 20251203000005_migrate_dosage_plans_fk.sql
├── 20251203000006_create_analytics_schema.sql
├── 20251203000007_create_materialized_views.sql
├── 20251203000008_create_secure_wrapper_views.sql
├── 20251203000009_setup_pg_cron_jobs.sql
└── 20251203000010_add_performance_indexes.sql
```

### 6.2 의존성 고려 실행 순서

```
Phase 0: 사전 준비
  - Supabase Dashboard에서 pg_cron 확장 활성화

Phase 1: Soft Delete (순서 중요)
  1. 20251203000001: Soft Delete 컬럼 추가
  2. 20251203000002: RLS 정책 업데이트
  3. 20251203000003: Soft Delete 함수 생성

Phase 2: Medications 테이블 (순서 중요)
  4. 20251203000004: medications 테이블 생성 + 시드
  5. 20251203000005: dosage_plans FK 마이그레이션

Phase 3: 집계 뷰 (순서 중요)
  6. 20251203000006: analytics 스키마 생성
  7. 20251203000007: Materialized Views 생성
  8. 20251203000008: 보안 Wrapper Views 생성

Phase 4: 스케줄러 및 최적화 (마지막)
  9. 20251203000009: pg_cron Jobs 설정
  10. 20251203000010: 성능 인덱스 추가
```

### 6.3 Flutter 코드 변경 순서

```
1. Entity 변경
   - Medication 엔티티 생성
   - DosagePlan 엔티티 수정 (medicationId 추가)

2. Repository 변경
   - MedicationRepository 인터페이스 업데이트
   - SupabaseMedicationRepository 구현 업데이트

3. Provider 변경
   - medications Provider 추가
   - 온보딩 로직에서 medication_id 사용

4. 기존 코드 정리
   - MedicationTemplate 사용처를 Medication으로 교체
   - MedicationTemplate 클래스 deprecated 후 제거

5. 다국어 지원
   - ARB 파일 생성
   - enum_localizations.dart 구현
   - UI에서 로컬라이즈 적용
```

---

## 7. 테스트 전략

### 7.1 RLS 정책 테스트 쿼리

```sql
-- ============================================
-- RLS 테스트: 다른 사용자 데이터 접근 불가 확인
-- ============================================

-- Supabase SQL Editor에서 실행 (로그인 필요)

-- 1. 현재 사용자 확인
SELECT auth.uid() AS current_user_id;

-- 2. 자신의 데이터만 반환되는지 확인
SELECT COUNT(*) FROM weight_logs;  -- 자신의 레코드만 카운트

-- 3. Soft Delete된 데이터는 보이지 않아야 함
-- (테스트 데이터로 확인)
```

### 7.2 Materialized View 보안 테스트

```sql
-- ============================================
-- MV 보안 테스트
-- ============================================

-- 1. analytics 스키마 직접 접근 시도 (실패해야 함)
SELECT * FROM analytics.user_weekly_summary;
-- 예상: permission denied (public API에서)

-- 2. 보안 Wrapper View 접근 (성공해야 함, 자신의 데이터만)
SELECT * FROM my_weekly_summary;
-- 예상: 현재 사용자의 데이터만 반환
```

### 7.3 Soft Delete 동작 검증

```sql
-- ============================================
-- Soft Delete 동작 검증 (Service Role로 실행)
-- ============================================

-- 1. Soft Delete 함수 테스트
SELECT soft_delete_user_account('test-user-id');

-- 2. 검증: 모든 테이블에 deleted_at이 설정되었는지 확인
SELECT
  'users' AS table_name,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE deleted_at IS NOT NULL) AS soft_deleted
FROM users WHERE id = 'test-user-id'
UNION ALL
SELECT 'weight_logs', COUNT(*), COUNT(*) FILTER (WHERE deleted_at IS NOT NULL)
FROM weight_logs WHERE user_id = 'test-user-id';

-- 3. 계정 복구 테스트
SELECT restore_user_account('test-user-id');
-- 예상: true (30일 이내)
```

### 7.4 성능 테스트

```sql
-- ============================================
-- 성능 테스트 (< 100ms 목표)
-- ============================================

EXPLAIN ANALYZE
SELECT * FROM my_weekly_summary
ORDER BY week_start DESC
LIMIT 4;

-- 예상: Index Scan, Execution Time < 10ms
```

---

## 8. 에러 처리

### 8.1 시스템 알림 테이블

```sql
-- 시스템 알림 및 에러 로깅용 테이블
CREATE TABLE IF NOT EXISTS system_alerts (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_type varchar(50) NOT NULL,
  message text NOT NULL,
  details jsonb NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz NULL
);

-- 관리자 전용 (RLS 미적용 또는 별도 정책)
ALTER TABLE system_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "System alerts are admin only"
ON system_alerts FOR ALL
USING (auth.jwt() ->> 'role' = 'service_role');
```

### 8.2 Flutter 에러 처리

```dart
// Soft Deleted 레코드 접근 시 (RLS가 자동 필터링)
class SupabaseTrackingRepository implements TrackingRepository {
  @override
  Future<WeightLog?> getWeightLog(String userId, DateTime date) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', date.toIso8601String().split('T')[0])
        .maybeSingle();

    // RLS가 자동으로 deleted_at IS NULL 필터링
    if (response == null) return null;

    return WeightLog.fromJson(response);
  }
}

// 존재하지 않는 medication_id 처리
class OnboardingNotifier extends _$OnboardingNotifier {
  Future<void> selectMedication(String medicationId) async {
    final medications = await ref.read(medicationsProvider.future);

    final medication = medications.firstWhereOrNull(
      (m) => m.id == medicationId,
    );

    if (medication == null) {
      throw DomainException(
        code: 'INVALID_MEDICATION',
        message: '선택한 약물을 찾을 수 없습니다.',
      );
    }

    state = state.copyWith(selectedMedicationId: medicationId);
  }
}
```

---

## 참고 문서

- [Supabase pg_cron 가이드](https://supabase.com/docs/guides/cron)
- [PostgreSQL Materialized Views](https://www.postgresql.org/docs/current/sql-creatematerializedview.html)
- [Materialized Views RLS 제한사항](https://stackoverflow.com/questions/77198207/using-materialized-views-for-rls-in-supabase-best-practices-and-ui-limitations)
- [SECURITY DEFINER 보안](https://www.cybertec-postgresql.com/en/abusing-security-definer-functions/)
- [Flutter Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- 현재 스키마: `docs/database.md`
- 코드 구조: `docs/code_structure.md`
- 상태 관리: `docs/state-management.md`

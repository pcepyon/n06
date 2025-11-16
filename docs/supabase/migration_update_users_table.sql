-- ============================================
-- Migration: Update users table schema
-- ============================================
-- 이 마이그레이션은 기존 users 테이블을 업데이트합니다.
-- 변경 사항:
-- 1. oauth_provider, oauth_user_id, email 컬럼 추가
-- 2. id를 UUID에서 TEXT로 변경 (Naver 로그인 지원)
-- 3. 모든 관련 테이블의 user_id도 TEXT로 변경

-- ⚠️ 주의: 기존 데이터가 있다면 백업하세요!
-- 실행 전 확인: 현재 users 테이블에 데이터가 있나요?

BEGIN;

-- ===========================================
-- Step 0: 모든 RLS 정책 제거 (id 컬럼 타입 변경 전)
-- ===========================================
-- rls_policies.sql에 정의된 모든 정책을 정확히 제거합니다

-- Users table
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;

-- User-owned tables
DROP POLICY IF EXISTS "Users can access own consent records" ON public.consent_records;
DROP POLICY IF EXISTS "Users can access own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can access own dosage plans" ON public.dosage_plans;
DROP POLICY IF EXISTS "Users can access own weight logs" ON public.weight_logs;
DROP POLICY IF EXISTS "Users can access own symptom logs" ON public.symptom_logs;
DROP POLICY IF EXISTS "Users can access own emergency checks" ON public.emergency_symptom_checks;
DROP POLICY IF EXISTS "Users can access own badges" ON public.user_badges;
DROP POLICY IF EXISTS "Users can access own notification settings" ON public.notification_settings;
DROP POLICY IF EXISTS "Users can access own guide feedback" ON public.guide_feedback;
DROP POLICY IF EXISTS "Users can access own audit logs" ON public.audit_logs;

-- Related tables (parent 소유권 기반)
DROP POLICY IF EXISTS "Users can access own plan history" ON public.plan_change_history;
DROP POLICY IF EXISTS "Users can access own dose schedules" ON public.dose_schedules;
DROP POLICY IF EXISTS "Users can access own dose records" ON public.dose_records;
DROP POLICY IF EXISTS "Users can access own symptom tags" ON public.symptom_context_tags;

-- Badge definitions
DROP POLICY IF EXISTS "Badge definitions are readable by all authenticated users" ON public.badge_definitions;

-- ===========================================
-- Step 1: users 테이블의 auth.users FK 제약조건 제거
-- ===========================================
-- users.id가 auth.users(id)를 참조하는 FK를 먼저 제거해야 합니다
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_id_fkey;

-- ===========================================
-- Step 2: 기존 FK 제약조건 제거
-- ===========================================
ALTER TABLE public.consent_records DROP CONSTRAINT IF EXISTS consent_records_user_id_fkey;
ALTER TABLE public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_id_fkey;
ALTER TABLE public.dosage_plans DROP CONSTRAINT IF EXISTS dosage_plans_user_id_fkey;
ALTER TABLE public.weight_logs DROP CONSTRAINT IF EXISTS weight_logs_user_id_fkey;
ALTER TABLE public.symptom_logs DROP CONSTRAINT IF EXISTS symptom_logs_user_id_fkey;
ALTER TABLE public.emergency_symptom_checks DROP CONSTRAINT IF EXISTS emergency_symptom_checks_user_id_fkey;
ALTER TABLE public.user_badges DROP CONSTRAINT IF EXISTS user_badges_user_id_fkey;
ALTER TABLE public.notification_settings DROP CONSTRAINT IF EXISTS notification_settings_user_id_fkey;
ALTER TABLE public.guide_feedback DROP CONSTRAINT IF EXISTS guide_feedback_user_id_fkey;
ALTER TABLE public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_user_id_fkey;

-- ===========================================
-- Step 3: users 테이블에 새 컬럼 추가
-- ===========================================
-- oauth_provider 추가 (기본값 'kakao')
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS oauth_provider VARCHAR(20) NOT NULL DEFAULT 'kakao';

-- oauth_user_id 추가 (기존 id를 기본값으로 사용)
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS oauth_user_id VARCHAR(255);

-- 기존 데이터에 대해 oauth_user_id를 id로 설정
UPDATE public.users
SET oauth_user_id = id::TEXT
WHERE oauth_user_id IS NULL;

-- oauth_user_id를 NOT NULL로 변경
ALTER TABLE public.users
ALTER COLUMN oauth_user_id SET NOT NULL;

-- email 추가 (nullable)
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- ===========================================
-- Step 4: id 컬럼을 UUID에서 TEXT로 변경
-- ===========================================
-- 4-1. users 테이블의 id를 TEXT로 변경
ALTER TABLE public.users
ALTER COLUMN id TYPE TEXT USING id::TEXT;

-- 4-2. 모든 관련 테이블의 user_id를 TEXT로 변경
ALTER TABLE public.consent_records
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.user_profiles
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.dosage_plans
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.weight_logs
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.symptom_logs
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.emergency_symptom_checks
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.user_badges
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.notification_settings
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.guide_feedback
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

ALTER TABLE public.audit_logs
ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

-- ===========================================
-- Step 5: FK 제약조건 재생성
-- ===========================================
ALTER TABLE public.consent_records
ADD CONSTRAINT consent_records_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.user_profiles
ADD CONSTRAINT user_profiles_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.dosage_plans
ADD CONSTRAINT dosage_plans_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.weight_logs
ADD CONSTRAINT weight_logs_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.symptom_logs
ADD CONSTRAINT symptom_logs_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.emergency_symptom_checks
ADD CONSTRAINT emergency_symptom_checks_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.user_badges
ADD CONSTRAINT user_badges_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.notification_settings
ADD CONSTRAINT notification_settings_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.guide_feedback
ADD CONSTRAINT guide_feedback_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.audit_logs
ADD CONSTRAINT audit_logs_user_id_fkey
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

-- ===========================================
-- Step 6: RLS 정책 재생성 (auth.uid()를 TEXT로 캐스팅)
-- ===========================================
-- rls_policies.sql과 동일하지만 auth.uid()::TEXT로 캐스팅

-- ============================================
-- Users: 자신의 프로필만 접근
-- ============================================
CREATE POLICY "Users can view own profile"
ON public.users FOR SELECT
USING (auth.uid()::TEXT = id);

CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid()::TEXT = id);

-- ============================================
-- User-owned tables: 자신의 데이터만 접근
-- ============================================
CREATE POLICY "Users can access own consent records"
ON public.consent_records FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own profile"
ON public.user_profiles FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own dosage plans"
ON public.dosage_plans FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own weight logs"
ON public.weight_logs FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own symptom logs"
ON public.symptom_logs FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own emergency checks"
ON public.emergency_symptom_checks FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own badges"
ON public.user_badges FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own notification settings"
ON public.notification_settings FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own guide feedback"
ON public.guide_feedback FOR ALL
USING (auth.uid()::TEXT = user_id);

CREATE POLICY "Users can access own audit logs"
ON public.audit_logs FOR ALL
USING (auth.uid()::TEXT = user_id);

-- ============================================
-- Related tables: parent 소유권 기반
-- ============================================
CREATE POLICY "Users can access own plan history"
ON public.plan_change_history FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()::TEXT
  )
);

CREATE POLICY "Users can access own dose schedules"
ON public.dose_schedules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()::TEXT
  )
);

CREATE POLICY "Users can access own dose records"
ON public.dose_records FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()::TEXT
  )
);

CREATE POLICY "Users can access own symptom tags"
ON public.symptom_context_tags FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.symptom_logs
    WHERE id = symptom_log_id AND user_id = auth.uid()::TEXT
  )
);

-- ============================================
-- Badge Definitions: 모든 사용자 읽기 가능
-- ============================================
CREATE POLICY "Badge definitions are readable by all authenticated users"
ON public.badge_definitions FOR SELECT
USING (auth.role() = 'authenticated');

COMMIT;

-- 완료 메시지
SELECT
  'Migration completed successfully!' as status,
  'Users table now supports both Kakao (UUID) and Naver (naver_xxx) IDs' as note;

-- ============================================
-- F021-2: dose_schedules, plan_change_history 암호화
-- ============================================
-- 암호화 대상:
-- 1. dose_schedules.scheduled_dose_mg (NUMERIC → TEXT)
-- 2. plan_change_history.old_plan, new_plan (JSONB → TEXT)
--
-- 주의: 앱 출시 전이므로 기존 데이터 마이그레이션은 불필요합니다.

-- ============================================
-- 1. 의존 객체 삭제
-- ============================================

-- 1.1 v_monthly_dose_adherence 뷰 삭제 (암호화된 scheduled_dose_mg 집계 불가)
DROP VIEW IF EXISTS public.v_monthly_dose_adherence CASCADE;

-- ============================================
-- 2. dose_schedules 테이블
-- ============================================
-- scheduled_dose_mg: NUMERIC → TEXT
ALTER TABLE public.dose_schedules
  ALTER COLUMN scheduled_dose_mg TYPE TEXT USING scheduled_dose_mg::TEXT;

-- ============================================
-- 3. plan_change_history 테이블
-- ============================================
-- old_plan: JSONB → TEXT
ALTER TABLE public.plan_change_history
  ALTER COLUMN old_plan TYPE TEXT USING old_plan::TEXT;

-- new_plan: JSONB → TEXT
ALTER TABLE public.plan_change_history
  ALTER COLUMN new_plan TYPE TEXT USING new_plan::TEXT;

-- ============================================
-- 변경 요약
-- ============================================
-- | 테이블               | 컬럼              | 변경 전  | 변경 후 |
-- |---------------------|------------------|---------|--------|
-- | dose_schedules      | scheduled_dose_mg | NUMERIC | TEXT   |
-- | plan_change_history | old_plan          | JSONB   | TEXT   |
-- | plan_change_history | new_plan          | JSONB   | TEXT   |
--
-- 삭제된 객체:
-- - v_monthly_dose_adherence (뷰) - 암호화된 데이터로 집계 불가

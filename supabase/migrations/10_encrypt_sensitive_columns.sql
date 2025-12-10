-- ============================================
-- F021: 민감 정보 암호화를 위한 컬럼 타입 변경
-- ============================================
-- 암호화된 데이터는 Base64(IV + Ciphertext + AuthTag) 형식으로 저장되므로
-- NUMERIC/JSONB/INT 컬럼을 TEXT로 변경합니다.
--
-- 주의: 앱 출시 전이므로 기존 데이터 마이그레이션은 불필요합니다.

-- ============================================
-- 1. 의존 객체 삭제 (뷰, 인덱스)
-- ============================================

-- 1.1 뷰 삭제 (암호화된 컬럼에서 AVG, MIN, MAX 등 집계 연산 불가)
DROP VIEW IF EXISTS public.v_weekly_weight_summary CASCADE;
DROP VIEW IF EXISTS public.v_weekly_checkin_summary CASCADE;
DROP VIEW IF EXISTS public.v_monthly_dose_adherence CASCADE;

-- 1.2 JSONB GIN 인덱스 삭제 (TEXT 타입은 jsonb_path_ops 불가)
DROP INDEX IF EXISTS public.idx_daily_checkins_symptom_gin;

-- ============================================
-- 2. weight_logs 테이블
-- ============================================
ALTER TABLE public.weight_logs
  ALTER COLUMN weight_kg TYPE TEXT USING weight_kg::TEXT;

-- ============================================
-- 3. daily_checkins 테이블
-- ============================================
-- 3.1 appetite_score: DROP COLUMN → ADD COLUMN 방식 사용
-- CHECK 제약조건이 있는 컬럼은 타입 변경 시 "text >= integer" 오류 발생
-- 앱 출시 전이므로 데이터 손실 위험 없음
ALTER TABLE public.daily_checkins DROP COLUMN IF EXISTS appetite_score;
ALTER TABLE public.daily_checkins ADD COLUMN appetite_score TEXT;

-- 3.2 symptom_details: JSONB → TEXT
ALTER TABLE public.daily_checkins
  ALTER COLUMN symptom_details TYPE TEXT USING symptom_details::TEXT;

-- ============================================
-- 4. dose_records 테이블
-- ============================================
-- actual_dose_mg: NUMERIC → TEXT
ALTER TABLE public.dose_records
  ALTER COLUMN actual_dose_mg TYPE TEXT USING actual_dose_mg::TEXT;

-- injection_site: VARCHAR → TEXT
ALTER TABLE public.dose_records
  ALTER COLUMN injection_site TYPE TEXT USING injection_site::TEXT;

-- note: 이미 TEXT이므로 변경 불필요

-- ============================================
-- 5. dosage_plans 테이블
-- ============================================
-- medication_name: VARCHAR → TEXT
ALTER TABLE public.dosage_plans
  ALTER COLUMN medication_name TYPE TEXT USING medication_name::TEXT;

-- initial_dose_mg: NUMERIC → TEXT
ALTER TABLE public.dosage_plans
  ALTER COLUMN initial_dose_mg TYPE TEXT USING initial_dose_mg::TEXT;

-- escalation_plan: JSONB → TEXT
ALTER TABLE public.dosage_plans
  ALTER COLUMN escalation_plan TYPE TEXT USING escalation_plan::TEXT;

-- ============================================
-- 6. user_profiles 테이블
-- ============================================
-- target_weight_kg: NUMERIC → TEXT
ALTER TABLE public.user_profiles
  ALTER COLUMN target_weight_kg TYPE TEXT USING target_weight_kg::TEXT;

-- ============================================
-- 변경 요약
-- ============================================
-- | 테이블           | 컬럼              | 변경 전      | 변경 후 |
-- |-----------------|------------------|-------------|--------|
-- | weight_logs     | weight_kg        | NUMERIC     | TEXT   |
-- | daily_checkins  | symptom_details  | JSONB       | TEXT   |
-- | daily_checkins  | appetite_score   | INT+CHECK   | TEXT   |
-- | dose_records    | actual_dose_mg   | NUMERIC     | TEXT   |
-- | dose_records    | injection_site   | VARCHAR     | TEXT   |
-- | dosage_plans    | medication_name  | VARCHAR     | TEXT   |
-- | dosage_plans    | initial_dose_mg  | NUMERIC     | TEXT   |
-- | dosage_plans    | escalation_plan  | JSONB       | TEXT   |
-- | user_profiles   | target_weight_kg | NUMERIC     | TEXT   |
--
-- 삭제된 객체:
-- - v_weekly_weight_summary, v_weekly_checkin_summary, v_monthly_dose_adherence (뷰)
-- - idx_daily_checkins_symptom_gin (인덱스)
-- - appetite_score CHECK 제약조건 (컬럼 삭제 후 재생성으로 제거)

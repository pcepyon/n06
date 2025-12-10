-- ============================================
-- F021: 민감 정보 암호화를 위한 컬럼 타입 변경
-- ============================================
-- 암호화된 데이터는 Base64(IV + Ciphertext + AuthTag) 형식으로 저장되므로
-- NUMERIC/JSONB/INT 컬럼을 TEXT로 변경합니다.
--
-- 주의: 앱 출시 전이므로 기존 데이터 마이그레이션은 불필요합니다.
-- 기존 데이터가 있는 경우 USING 절로 형변환 처리합니다.

-- ============================================
-- weight_logs 테이블
-- ============================================
ALTER TABLE public.weight_logs
  ALTER COLUMN weight_kg TYPE TEXT USING weight_kg::TEXT;

-- ============================================
-- daily_checkins 테이블
-- ============================================
-- symptom_details: JSONB → TEXT
ALTER TABLE public.daily_checkins
  ALTER COLUMN symptom_details TYPE TEXT USING symptom_details::TEXT;

-- appetite_score: INT → TEXT
ALTER TABLE public.daily_checkins
  ALTER COLUMN appetite_score TYPE TEXT USING appetite_score::TEXT;

-- ============================================
-- dose_records 테이블
-- ============================================
-- actual_dose_mg: NUMERIC → TEXT
ALTER TABLE public.dose_records
  ALTER COLUMN actual_dose_mg TYPE TEXT USING actual_dose_mg::TEXT;

-- injection_site: VARCHAR → TEXT (이미 TEXT 계열이지만 명시적으로 변환)
ALTER TABLE public.dose_records
  ALTER COLUMN injection_site TYPE TEXT USING injection_site::TEXT;

-- note: TEXT (유지, 이미 TEXT이므로 변경 불필요)
-- ALTER TABLE public.dose_records
--   ALTER COLUMN note TYPE TEXT USING note::TEXT;

-- ============================================
-- dosage_plans 테이블
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
-- user_profiles 테이블
-- ============================================
-- target_weight_kg: NUMERIC → TEXT
ALTER TABLE public.user_profiles
  ALTER COLUMN target_weight_kg TYPE TEXT USING target_weight_kg::TEXT;

-- ============================================
-- 주석: 암호화 대상 컬럼 요약
-- ============================================
-- | 테이블           | 컬럼              | 변경 전      | 변경 후 |
-- |-----------------|------------------|-------------|--------|
-- | weight_logs     | weight_kg        | NUMERIC     | TEXT   |
-- | daily_checkins  | symptom_details  | JSONB       | TEXT   |
-- | daily_checkins  | appetite_score   | INT         | TEXT   |
-- | dose_records    | actual_dose_mg   | NUMERIC     | TEXT   |
-- | dose_records    | injection_site   | VARCHAR     | TEXT   |
-- | dose_records    | note             | TEXT        | TEXT   |
-- | dosage_plans    | medication_name  | VARCHAR     | TEXT   |
-- | dosage_plans    | initial_dose_mg  | NUMERIC     | TEXT   |
-- | dosage_plans    | escalation_plan  | JSONB       | TEXT   |
-- | user_profiles   | target_weight_kg | NUMERIC     | TEXT   |

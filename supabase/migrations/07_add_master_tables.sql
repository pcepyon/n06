-- ============================================
-- Master Tables & Analytics Views Migration
-- 2025-12-05
-- ============================================

-- ============================================
-- 1. medications 마스터 테이블
-- GLP-1 약물 정보 (앱 배포 없이 새 약물 추가 가능)
-- ============================================
CREATE TABLE IF NOT EXISTS public.medications (
  id VARCHAR(50) PRIMARY KEY,
  name_ko VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  generic_name VARCHAR(100),
  manufacturer VARCHAR(100),
  available_doses JSONB NOT NULL,
  recommended_start_dose NUMERIC(6,2),
  dose_unit VARCHAR(10) NOT NULL DEFAULT 'mg',
  cycle_days INTEGER NOT NULL DEFAULT 7,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for active medications lookup
CREATE INDEX IF NOT EXISTS idx_medications_active_order
ON public.medications(is_active, display_order);

-- RLS: 인증된 사용자 읽기 가능
ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Medications readable by authenticated users"
ON public.medications FOR SELECT
USING (auth.role() = 'authenticated');

-- 초기 데이터: GLP-1 약물 5종
INSERT INTO public.medications (id, name_ko, name_en, generic_name, manufacturer, available_doses, recommended_start_dose, dose_unit, cycle_days, is_active, display_order)
VALUES
  ('wegovy', '위고비', 'Wegovy', '세마글루타이드', 'Novo Nordisk', '[0.25, 0.5, 1.0, 1.7, 2.4]'::jsonb, 0.25, 'mg', 7, true, 1),
  ('ozempic', '오젬픽', 'Ozempic', '세마글루타이드', 'Novo Nordisk', '[0.25, 0.5, 1.0]'::jsonb, 0.25, 'mg', 7, true, 2),
  ('mounjaro', '마운자로', 'Mounjaro', '티르제파타이드', 'Eli Lilly', '[2.5, 5.0, 7.5, 10.0, 12.5, 15.0]'::jsonb, 2.5, 'mg', 7, true, 3),
  ('zepbound', '젭바운드', 'Zepbound', '티르제파타이드', 'Eli Lilly', '[2.5, 5.0, 7.5, 10.0, 12.5, 15.0]'::jsonb, 2.5, 'mg', 7, true, 4),
  ('saxenda', '삭센다', 'Saxenda', '리라글루타이드', 'Novo Nordisk', '[0.6, 1.2, 1.8, 2.4, 3.0]'::jsonb, 0.6, 'mg', 1, true, 5)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. symptom_types 마스터 테이블
-- 증상 종류 정의 (앱 배포 없이 새 증상 추가 가능)
-- ============================================
CREATE TABLE IF NOT EXISTS public.symptom_types (
  id VARCHAR(50) PRIMARY KEY,
  name_ko VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  category VARCHAR(20) NOT NULL,          -- digestive, systemic, metabolic, red_flag
  is_red_flag BOOLEAN NOT NULL DEFAULT false,
  display_order INTEGER NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for active symptom types
CREATE INDEX IF NOT EXISTS idx_symptom_types_active_category
ON public.symptom_types(is_active, category, display_order);

-- RLS: 인증된 사용자 읽기 가능
ALTER TABLE public.symptom_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Symptom types readable by authenticated users"
ON public.symptom_types FOR SELECT
USING (auth.role() = 'authenticated');

-- 초기 데이터: 기본 증상 13종
INSERT INTO public.symptom_types (id, name_ko, name_en, category, is_red_flag, display_order)
VALUES
  -- 소화기 증상 (digestive)
  ('nausea', '메스꺼움', 'Nausea', 'digestive', false, 1),
  ('vomiting', '구토', 'Vomiting', 'digestive', false, 2),
  ('low_appetite', '입맛 없음', 'Low Appetite', 'digestive', false, 3),
  ('early_satiety', '조기 포만감', 'Early Satiety', 'digestive', false, 4),
  ('heartburn', '속쓰림', 'Heartburn', 'digestive', false, 5),
  ('abdominal_pain', '복통', 'Abdominal Pain', 'digestive', false, 6),
  ('bloating', '복부 팽만', 'Bloating', 'digestive', false, 7),
  ('constipation', '변비', 'Constipation', 'digestive', false, 8),
  ('diarrhea', '설사', 'Diarrhea', 'digestive', false, 9),
  -- 전신 증상 (systemic)
  ('fatigue', '피로', 'Fatigue', 'systemic', false, 10),
  ('dizziness', '어지러움', 'Dizziness', 'systemic', false, 11),
  ('cold_sweat', '식은땀', 'Cold Sweat', 'systemic', false, 12),
  ('swelling', '부종', 'Swelling', 'systemic', false, 13),
  -- Red Flag 증상 (red_flag)
  ('pancreatitis', '급성 췌장염', 'Acute Pancreatitis', 'red_flag', true, 101),
  ('cholecystitis', '담낭염', 'Cholecystitis', 'red_flag', true, 102),
  ('severe_dehydration', '심한 탈수', 'Severe Dehydration', 'red_flag', true, 103),
  ('bowel_obstruction', '장폐색', 'Bowel Obstruction', 'red_flag', true, 104),
  ('hypoglycemia', '저혈당', 'Hypoglycemia', 'red_flag', true, 105),
  ('renal_impairment', '신부전', 'Renal Impairment', 'red_flag', true, 106)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. 분석 뷰 (Analytics Views)
-- ============================================

-- 3.1 주간 체중 요약 뷰
CREATE OR REPLACE VIEW public.v_weekly_weight_summary AS
SELECT
  user_id,
  DATE_TRUNC('week', log_date) AS week_start,
  COUNT(*) AS record_count,
  ROUND(AVG(weight_kg)::numeric, 2) AS avg_weight,
  MIN(weight_kg) AS min_weight,
  MAX(weight_kg) AS max_weight,
  MAX(weight_kg) - MIN(weight_kg) AS weight_range,
  -- 주간 변화량 (첫 기록 - 마지막 기록)
  (
    SELECT w2.weight_kg
    FROM weight_logs w2
    WHERE w2.user_id = weight_logs.user_id
      AND DATE_TRUNC('week', w2.log_date) = DATE_TRUNC('week', weight_logs.log_date)
    ORDER BY w2.log_date DESC LIMIT 1
  ) - (
    SELECT w3.weight_kg
    FROM weight_logs w3
    WHERE w3.user_id = weight_logs.user_id
      AND DATE_TRUNC('week', w3.log_date) = DATE_TRUNC('week', weight_logs.log_date)
    ORDER BY w3.log_date ASC LIMIT 1
  ) AS weekly_change
FROM weight_logs
GROUP BY user_id, DATE_TRUNC('week', log_date)
ORDER BY user_id, week_start DESC;

-- 3.2 주간 체크인 요약 뷰
CREATE OR REPLACE VIEW public.v_weekly_checkin_summary AS
SELECT
  user_id,
  DATE_TRUNC('week', checkin_date) AS week_start,
  COUNT(*) AS checkin_count,
  ROUND(AVG(appetite_score)::numeric, 2) AS avg_appetite_score,
  COUNT(*) FILTER (WHERE red_flag_detected IS NOT NULL) AS red_flag_count,
  -- 각 상태별 카운트
  COUNT(*) FILTER (WHERE meal_condition = 'good') AS good_meal_count,
  COUNT(*) FILTER (WHERE energy_level = 'good') AS good_energy_count,
  COUNT(*) FILTER (WHERE mood = 'good') AS good_mood_count
FROM daily_checkins
GROUP BY user_id, DATE_TRUNC('week', checkin_date)
ORDER BY user_id, week_start DESC;

-- 3.3 월별 투여 순응도 뷰
CREATE OR REPLACE VIEW public.v_monthly_dose_adherence AS
SELECT
  dp.user_id,
  DATE_TRUNC('month', ds.scheduled_date) AS month_start,
  dp.medication_name,
  COUNT(ds.id) AS scheduled_count,
  COUNT(dr.id) AS completed_count,
  CASE
    WHEN COUNT(ds.id) > 0
    THEN ROUND((COUNT(dr.id)::numeric / COUNT(ds.id)::numeric) * 100, 1)
    ELSE 0
  END AS adherence_rate
FROM dosage_plans dp
JOIN dose_schedules ds ON ds.dosage_plan_id = dp.id
LEFT JOIN dose_records dr ON dr.dose_schedule_id = ds.id AND dr.is_completed = true
WHERE dp.is_active = true
  AND ds.scheduled_date <= CURRENT_DATE  -- 과거 및 오늘까지만
GROUP BY dp.user_id, DATE_TRUNC('month', ds.scheduled_date), dp.medication_name
ORDER BY dp.user_id, month_start DESC;

-- ============================================
-- 완료
-- ============================================

-- ============================================
-- GLP-1 MVP Database Schema (Supabase)
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. Users Table (Supabase Auth 연동)
-- ============================================
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  profile_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 2. Consent Records
-- ============================================
CREATE TABLE public.consent_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  terms_of_service BOOLEAN NOT NULL,
  privacy_policy BOOLEAN NOT NULL,
  agreed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 3. User Profiles
-- ============================================
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  target_weight_kg NUMERIC(5,2) NOT NULL,
  target_period_weeks INTEGER,
  weekly_loss_goal_kg NUMERIC(4,2),
  weekly_weight_record_goal INTEGER NOT NULL DEFAULT 7,
  weekly_symptom_record_goal INTEGER NOT NULL DEFAULT 7,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. Dosage Plans
-- ============================================
CREATE TABLE public.dosage_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  medication_name VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  cycle_days INTEGER NOT NULL,
  initial_dose_mg NUMERIC(6,2) NOT NULL,
  escalation_plan JSONB,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dosage_plans_user_active ON public.dosage_plans(user_id, is_active);

-- ============================================
-- 5. Plan Change History
-- ============================================
CREATE TABLE public.plan_change_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dosage_plan_id UUID NOT NULL REFERENCES public.dosage_plans(id) ON DELETE CASCADE,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  old_plan JSONB NOT NULL,
  new_plan JSONB NOT NULL
);

-- ============================================
-- 6. Dose Schedules
-- ============================================
CREATE TABLE public.dose_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dosage_plan_id UUID NOT NULL REFERENCES public.dosage_plans(id) ON DELETE CASCADE,
  scheduled_date DATE NOT NULL,
  scheduled_dose_mg NUMERIC(6,2) NOT NULL,
  notification_time TIME,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dose_schedules_plan_date ON public.dose_schedules(dosage_plan_id, scheduled_date);

-- ============================================
-- 7. Dose Records
-- ============================================
CREATE TABLE public.dose_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dose_schedule_id UUID REFERENCES public.dose_schedules(id) ON DELETE SET NULL,
  dosage_plan_id UUID NOT NULL REFERENCES public.dosage_plans(id) ON DELETE CASCADE,
  administered_at TIMESTAMPTZ NOT NULL,
  actual_dose_mg NUMERIC(6,2) NOT NULL,
  injection_site VARCHAR(20),
  is_completed BOOLEAN NOT NULL DEFAULT TRUE,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dose_records_plan_administered ON public.dose_records(dosage_plan_id, administered_at);
CREATE INDEX idx_dose_records_injection_site ON public.dose_records(injection_site, administered_at DESC);

-- ============================================
-- 8. Weight Logs
-- ============================================
CREATE TABLE public.weight_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  weight_kg NUMERIC(5,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, log_date)
);

CREATE INDEX idx_weight_logs_user_date ON public.weight_logs(user_id, log_date DESC);

-- ============================================
-- 9. Symptom Logs
-- ============================================
CREATE TABLE public.symptom_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  symptom_name VARCHAR(50) NOT NULL,
  severity INTEGER NOT NULL CHECK (severity >= 1 AND severity <= 10),
  days_since_escalation INTEGER,
  is_persistent_24h BOOLEAN,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_symptom_logs_user_date ON public.symptom_logs(user_id, log_date DESC);

-- ============================================
-- 10. Symptom Context Tags
-- ============================================
CREATE TABLE public.symptom_context_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symptom_log_id UUID NOT NULL REFERENCES public.symptom_logs(id) ON DELETE CASCADE,
  tag_name VARCHAR(50) NOT NULL
);

CREATE INDEX idx_symptom_context_tags_log ON public.symptom_context_tags(symptom_log_id);
CREATE INDEX idx_symptom_context_tags_name ON public.symptom_context_tags(tag_name);

-- ============================================
-- 11. Emergency Symptom Checks
-- ============================================
CREATE TABLE public.emergency_symptom_checks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  checked_symptoms JSONB NOT NULL
);

CREATE INDEX idx_emergency_checks_user_checked ON public.emergency_symptom_checks(user_id, checked_at DESC);

-- ============================================
-- 12. Badge Definitions (정적 데이터)
-- ============================================
CREATE TABLE public.badge_definitions (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(20) NOT NULL,
  achievement_condition JSONB NOT NULL,
  icon_url TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_badge_definitions_category ON public.badge_definitions(category, display_order);

-- ============================================
-- 13. User Badges
-- ============================================
CREATE TABLE public.user_badges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  badge_id VARCHAR(50) NOT NULL REFERENCES public.badge_definitions(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL CHECK (status IN ('locked', 'in_progress', 'achieved')),
  progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  achieved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

CREATE INDEX idx_user_badges_user_status ON public.user_badges(user_id, status);
CREATE INDEX idx_user_badges_user_achieved ON public.user_badges(user_id, achieved_at DESC);

-- ============================================
-- 14. Notification Settings
-- ============================================
CREATE TABLE public.notification_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  notification_hour INTEGER NOT NULL CHECK (notification_hour >= 0 AND notification_hour <= 23),
  notification_minute INTEGER NOT NULL CHECK (notification_minute >= 0 AND notification_minute <= 59),
  notification_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 15. Guide Feedback (선택적)
-- ============================================
CREATE TABLE public.guide_feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  symptom_name VARCHAR(50) NOT NULL,
  helpful BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_guide_feedback_user ON public.guide_feedback(user_id, created_at DESC);

-- ============================================
-- 16. Audit Logs (기록 수정 이력)
-- ============================================
CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entity_type VARCHAR(50) NOT NULL,
  entity_id UUID NOT NULL,
  action VARCHAR(20) NOT NULL,
  old_data JSONB,
  new_data JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_created ON public.audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);

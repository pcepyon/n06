-- Initial Schema for GLP-1 Treatment Management MVP
-- Phase 0: Isar local DB structure
-- Phase 1: Supabase PostgreSQL migration

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. Authentication & User Management
-- ============================================

-- users table
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    oauth_provider varchar(20) NOT NULL,
    oauth_user_id varchar(255) NOT NULL,
    name varchar(100) NOT NULL,
    email varchar(255) NOT NULL,
    profile_image_url text,
    created_at timestamptz NOT NULL DEFAULT now(),
    last_login_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT unique_oauth_user UNIQUE (oauth_provider, oauth_user_id)
);

CREATE INDEX idx_users_oauth ON users(oauth_provider, oauth_user_id);

-- consent_records table
CREATE TABLE consent_records (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    terms_of_service boolean NOT NULL,
    privacy_policy boolean NOT NULL,
    agreed_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_consent_user ON consent_records(user_id);

-- ============================================
-- 2. User Profile & Goals
-- ============================================

-- user_profiles table
CREATE TABLE user_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_weight_kg numeric(5,2) NOT NULL,
    target_period_weeks integer,
    weekly_loss_goal_kg numeric(4,2),
    weekly_weight_record_goal integer NOT NULL DEFAULT 7,
    weekly_symptom_record_goal integer NOT NULL DEFAULT 7,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT unique_user_profile UNIQUE (user_id),
    CONSTRAINT check_target_weight CHECK (target_weight_kg > 0 AND target_weight_kg < 500),
    CONSTRAINT check_weekly_goals CHECK (weekly_weight_record_goal >= 0 AND weekly_weight_record_goal <= 7 AND weekly_symptom_record_goal >= 0 AND weekly_symptom_record_goal <= 7)
);

CREATE INDEX idx_user_profiles_user ON user_profiles(user_id);

-- ============================================
-- 3. Dosage Management
-- ============================================

-- dosage_plans table
CREATE TABLE dosage_plans (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    medication_name varchar(100) NOT NULL,
    start_date date NOT NULL,
    cycle_days integer NOT NULL,
    initial_dose_mg numeric(6,2) NOT NULL,
    escalation_plan jsonb,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT check_cycle_days CHECK (cycle_days > 0),
    CONSTRAINT check_initial_dose CHECK (initial_dose_mg > 0)
);

CREATE INDEX idx_dosage_plans_user ON dosage_plans(user_id, is_active);

-- plan_change_history table
CREATE TABLE plan_change_history (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dosage_plan_id uuid NOT NULL REFERENCES dosage_plans(id) ON DELETE CASCADE,
    changed_at timestamptz NOT NULL DEFAULT now(),
    old_plan jsonb NOT NULL,
    new_plan jsonb NOT NULL
);

CREATE INDEX idx_plan_history_plan ON plan_change_history(dosage_plan_id, changed_at DESC);

-- dose_schedules table
CREATE TABLE dose_schedules (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dosage_plan_id uuid NOT NULL REFERENCES dosage_plans(id) ON DELETE CASCADE,
    scheduled_date date NOT NULL,
    scheduled_dose_mg numeric(6,2) NOT NULL,
    notification_time time,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT check_scheduled_dose CHECK (scheduled_dose_mg > 0)
);

CREATE INDEX idx_dose_schedules_plan_date ON dose_schedules(dosage_plan_id, scheduled_date);

-- dose_records table
CREATE TABLE dose_records (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dose_schedule_id uuid REFERENCES dose_schedules(id) ON DELETE SET NULL,
    dosage_plan_id uuid NOT NULL REFERENCES dosage_plans(id) ON DELETE CASCADE,
    administered_at timestamptz NOT NULL,
    actual_dose_mg numeric(6,2) NOT NULL,
    injection_site varchar(20),
    is_completed boolean NOT NULL DEFAULT true,
    note text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT check_actual_dose CHECK (actual_dose_mg > 0),
    CONSTRAINT check_injection_site CHECK (injection_site IN ('복부', '허벅지', '상완') OR injection_site IS NULL)
);

CREATE INDEX idx_dose_records_plan_date ON dose_records(dosage_plan_id, administered_at DESC);
CREATE INDEX idx_dose_records_injection_site ON dose_records(injection_site, administered_at DESC);

-- ============================================
-- 4. Weight & Symptom Tracking
-- ============================================

-- weight_logs table
CREATE TABLE weight_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    log_date date NOT NULL,
    weight_kg numeric(5,2) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT unique_weight_log UNIQUE (user_id, log_date),
    CONSTRAINT check_weight CHECK (weight_kg > 0 AND weight_kg < 500)
);

CREATE INDEX idx_weight_logs_user_date ON weight_logs(user_id, log_date DESC);

-- symptom_logs table
CREATE TABLE symptom_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    log_date date NOT NULL,
    symptom_name varchar(50) NOT NULL,
    severity integer NOT NULL,
    days_since_escalation integer,
    is_persistent_24h boolean,
    note text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT check_severity CHECK (severity >= 1 AND severity <= 10),
    CONSTRAINT check_symptom_name CHECK (symptom_name IN ('메스꺼움', '구토', '변비', '설사', '복통', '두통', '피로'))
);

CREATE INDEX idx_symptom_logs_user_date ON symptom_logs(user_id, log_date DESC);
CREATE INDEX idx_symptom_logs_symptom ON symptom_logs(symptom_name);

-- symptom_context_tags table
CREATE TABLE symptom_context_tags (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    symptom_log_id uuid NOT NULL REFERENCES symptom_logs(id) ON DELETE CASCADE,
    tag_name varchar(50) NOT NULL
);

CREATE INDEX idx_symptom_tags_log ON symptom_context_tags(symptom_log_id);
CREATE INDEX idx_symptom_tags_name ON symptom_context_tags(tag_name);

-- ============================================
-- 5. Emergency Symptom Checks
-- ============================================

-- emergency_symptom_checks table
CREATE TABLE emergency_symptom_checks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    checked_at timestamptz NOT NULL DEFAULT now(),
    checked_symptoms jsonb NOT NULL
);

CREATE INDEX idx_emergency_checks_user_date ON emergency_symptom_checks(user_id, checked_at DESC);

-- ============================================
-- 6. Achievement & Badges
-- ============================================

-- badge_definitions table (static data)
CREATE TABLE badge_definitions (
    id varchar(50) PRIMARY KEY,
    name varchar(100) NOT NULL,
    description text NOT NULL,
    category varchar(20) NOT NULL,
    achievement_condition jsonb NOT NULL,
    icon_url text,
    display_order integer NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT check_badge_category CHECK (category IN ('streak', 'weight', 'dose', 'record'))
);

CREATE INDEX idx_badge_definitions_category ON badge_definitions(category, display_order);

-- user_badges table
CREATE TABLE user_badges (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id varchar(50) NOT NULL REFERENCES badge_definitions(id) ON DELETE CASCADE,
    status varchar(20) NOT NULL,
    progress_percentage integer NOT NULL DEFAULT 0,
    achieved_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT unique_user_badge UNIQUE (user_id, badge_id),
    CONSTRAINT check_badge_status CHECK (status IN ('locked', 'in_progress', 'achieved')),
    CONSTRAINT check_progress CHECK (progress_percentage >= 0 AND progress_percentage <= 100)
);

CREATE INDEX idx_user_badges_user_status ON user_badges(user_id, status);
CREATE INDEX idx_user_badges_user_achieved ON user_badges(user_id, achieved_at DESC);

-- ============================================
-- 7. Updated At Trigger
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to user_profiles
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to dosage_plans
CREATE TRIGGER update_dosage_plans_updated_at BEFORE UPDATE ON dosage_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to user_badges
CREATE TRIGGER update_user_badges_updated_at BEFORE UPDATE ON user_badges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. Comments
-- ============================================

COMMENT ON TABLE users IS 'User account information from OAuth providers';
COMMENT ON TABLE consent_records IS 'User consent records for terms and privacy policy';
COMMENT ON TABLE user_profiles IS 'User profiles including treatment goals';
COMMENT ON TABLE dosage_plans IS 'Medication dosage plans with escalation schedule';
COMMENT ON TABLE plan_change_history IS 'History of changes to dosage plans';
COMMENT ON TABLE dose_schedules IS 'Auto-generated dosage schedule';
COMMENT ON TABLE dose_records IS 'Actual dose administration records';
COMMENT ON TABLE weight_logs IS 'Daily weight tracking records';
COMMENT ON TABLE symptom_logs IS 'Side effect and symptom logs';
COMMENT ON TABLE symptom_context_tags IS 'Context tags for symptoms (e.g., oily food, stress)';
COMMENT ON TABLE emergency_symptom_checks IS 'Emergency symptom checklist records';
COMMENT ON TABLE badge_definitions IS 'Badge definitions for achievement system (static data)';
COMMENT ON TABLE user_badges IS 'User badge achievement status and progress';

-- ============================================
-- 9. RLS Policies (Phase 1)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE dosage_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_change_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE dose_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE dose_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptom_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptom_context_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_symptom_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE badge_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own profile
CREATE POLICY users_policy ON users
    FOR ALL
    USING (id = auth.uid());

-- RLS Policy: Users can only access their own consent records
CREATE POLICY consent_records_policy ON consent_records
    FOR ALL
    USING (user_id = auth.uid());

-- RLS Policy: Users can only access their own profile
CREATE POLICY user_profiles_policy ON user_profiles
    FOR ALL
    USING (user_id = auth.uid());

-- RLS Policy: Users can only access their own dosage plans
CREATE POLICY dosage_plans_policy ON dosage_plans
    FOR ALL
    USING (user_id = auth.uid());

-- RLS Policy: Users can only access their own plan history
CREATE POLICY plan_change_history_policy ON plan_change_history
    FOR ALL
    USING (dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = auth.uid()));

-- RLS Policy: Users can only access their own dose schedules
CREATE POLICY dose_schedules_policy ON dose_schedules
    FOR ALL
    USING (dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = auth.uid()));

-- RLS Policy: Users can only access their own dose records
CREATE POLICY dose_records_policy ON dose_records
    FOR ALL
    USING (dosage_plan_id IN (SELECT id FROM dosage_plans WHERE user_id = auth.uid()));

-- RLS Policy: Users can only access their own weight logs
CREATE POLICY weight_logs_policy ON weight_logs
    FOR ALL
    USING (user_id = auth.uid());

-- RLS Policy: Users can only access their own symptom logs
CREATE POLICY symptom_logs_policy ON symptom_logs
    FOR ALL
    USING (user_id = auth.uid());

-- RLS Policy: Users can only access their own symptom tags
CREATE POLICY symptom_context_tags_policy ON symptom_context_tags
    FOR ALL
    USING (symptom_log_id IN (SELECT id FROM symptom_logs WHERE user_id = auth.uid()));

-- RLS Policy: Users can only access their own emergency checks
CREATE POLICY emergency_symptom_checks_policy ON emergency_symptom_checks
    FOR ALL
    USING (user_id = auth.uid());

-- RLS Policy: Badge definitions are readable by all authenticated users
CREATE POLICY badge_definitions_policy ON badge_definitions
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policy: Users can only access their own badges
CREATE POLICY user_badges_policy ON user_badges
    FOR ALL
    USING (user_id = auth.uid());

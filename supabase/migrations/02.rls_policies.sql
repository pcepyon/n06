-- ============================================
-- Row Level Security Policies
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dosage_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plan_change_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dose_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dose_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_context_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_symptom_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Users: 자신의 프로필만 접근
-- ============================================
CREATE POLICY "Users can view own profile"
ON public.users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- ============================================
-- User-owned tables: 자신의 데이터만 접근
-- ============================================
CREATE POLICY "Users can access own consent records"
ON public.consent_records FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own profile"
ON public.user_profiles FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own dosage plans"
ON public.dosage_plans FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own weight logs"
ON public.weight_logs FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own symptom logs"
ON public.symptom_logs FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own emergency checks"
ON public.emergency_symptom_checks FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own badges"
ON public.user_badges FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own notification settings"
ON public.notification_settings FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own guide feedback"
ON public.guide_feedback FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own audit logs"
ON public.audit_logs FOR ALL
USING (auth.uid() = user_id);

-- ============================================
-- Related tables: parent 소유권 기반
-- ============================================
CREATE POLICY "Users can access own plan history"
ON public.plan_change_history FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can access own dose schedules"
ON public.dose_schedules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can access own dose records"
ON public.dose_records FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can access own symptom tags"
ON public.symptom_context_tags FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.symptom_logs
    WHERE id = symptom_log_id AND user_id = auth.uid()
  )
);

-- ============================================
-- Badge Definitions: 모든 사용자 읽기 가능
-- ============================================
CREATE POLICY "Badge definitions are readable by all authenticated users"
ON public.badge_definitions FOR SELECT
USING (auth.role() = 'authenticated');

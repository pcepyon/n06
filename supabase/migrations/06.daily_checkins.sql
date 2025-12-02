-- ============================================
-- Migration 06: Daily Checkins Table & Legacy Cleanup
-- ============================================
-- Date: 2025-12-02
-- Description: 데일리 체크인 리뉴얼 - daily_checkins 테이블 생성 및 레거시 삭제
-- Reference: docs/daily-checkin-final-spec.md Section XII

-- ============================================
-- PART 1: 레거시 테이블 삭제 (FK 의존성 순서 준수)
-- ============================================

-- 1.1 자식 테이블 먼저 삭제 (symptom_context_tags)
DROP TABLE IF EXISTS public.symptom_context_tags CASCADE;

-- 1.2 부모 테이블 삭제 (symptom_logs)
DROP TABLE IF EXISTS public.symptom_logs CASCADE;

-- 1.3 emergency_symptom_checks 테이블 삭제 (daily_checkins로 통합)
DROP TABLE IF EXISTS public.emergency_symptom_checks CASCADE;

-- ============================================
-- PART 2: weight_logs 테이블에서 appetite_score 컬럼 제거
-- ============================================

ALTER TABLE public.weight_logs
DROP COLUMN IF EXISTS appetite_score;

-- ============================================
-- PART 3: daily_checkins 테이블 생성
-- ============================================

CREATE TABLE public.daily_checkins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  checkin_date DATE NOT NULL,

  -- 6개 일상 질문 응답
  meal_condition VARCHAR(20) NOT NULL,        -- good / moderate / difficult
  hydration_level VARCHAR(20) NOT NULL,       -- good / moderate / poor
  gi_comfort VARCHAR(20) NOT NULL,            -- good / uncomfortable / very_uncomfortable
  bowel_condition VARCHAR(20) NOT NULL,       -- normal / irregular / difficult
  energy_level VARCHAR(20) NOT NULL,          -- good / normal / tired
  mood VARCHAR(20) NOT NULL,                  -- good / neutral / low

  -- 식욕 점수 (weight_logs에서 이동)
  appetite_score INTEGER CHECK (appetite_score >= 1 AND appetite_score <= 5),
  -- 1: 아예 없음, 2: 매우 감소, 3: 약간 감소, 4: 보통, 5: 폭발
  -- meal_condition이 'difficult'면 파생 질문에서 정확한 점수 결정
  -- meal_condition이 'good'면 4-5, 'moderate'면 3-4

  -- 파생 증상 상세 (JSONB) - "힘들었어요" 선택 시 추가 정보
  symptom_details JSONB,
  -- 스키마: [{"type": string, "severity": 1-3, "details": {...}}]
  -- type: nausea, vomiting, lowAppetite, earlySatiety, heartburn, abdominalPain,
  --       bloating, constipation, diarrhea, fatigue, dizziness, coldSweat, swelling
  -- severity: 1(mild), 2(moderate), 3(severe)
  -- details: 증상별 추가 필드 (vomit_count, duration_hours, location, radiates_to_back 등)

  -- 컨텍스트 정보 (JSONB)
  context JSONB,
  -- 예: {
  --   "is_post_injection": true,
  --   "days_since_last_checkin": 1,
  --   "consecutive_days": 5,
  --   "greeting_type": "morning",
  --   "weight_skipped": true
  -- }

  -- Red Flag 감지 결과 (JSONB) - 시스템 자동 감지
  red_flag_detected JSONB,
  -- 예: {
  --   "type": "pancreatitis",
  --   "severity": "warning",
  --   "symptoms": ["severe_abdominal_pain", "radiates_to_back"],
  --   "notified_at": "2025-12-02T10:30:00Z",
  --   "user_action": "dismissed"
  -- }

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, checkin_date)
);

-- ============================================
-- PART 4: 인덱스 생성
-- ============================================

-- 사용자별 최신 체크인 조회 (가장 빈번한 쿼리)
CREATE INDEX idx_daily_checkins_user_date ON public.daily_checkins(user_id, checkin_date DESC);

-- Red Flag 감지 이력 조회 (필터링 인덱스)
CREATE INDEX idx_daily_checkins_red_flag ON public.daily_checkins(user_id)
  WHERE red_flag_detected IS NOT NULL;

-- 증상 상세 JSONB 검색 (GIN 인덱스)
CREATE INDEX idx_daily_checkins_symptom_gin ON public.daily_checkins
  USING GIN (symptom_details jsonb_path_ops);

-- ============================================
-- PART 5: RLS 정책 설정
-- ============================================

ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 체크인만 접근 가능
CREATE POLICY "Users can only access their own checkins"
ON public.daily_checkins FOR ALL
USING (auth.uid()::TEXT = user_id);

-- ============================================
-- PART 6: 컬럼 코멘트 추가
-- ============================================

COMMENT ON TABLE public.daily_checkins IS '데일리 체크인 기록 - 6개 일상 질문 + 파생 증상 상세 + Red Flag 감지';

COMMENT ON COLUMN public.daily_checkins.meal_condition IS '식사 컨디션: good(잘 먹었어요), moderate(적당히), difficult(힘들었어요)';
COMMENT ON COLUMN public.daily_checkins.hydration_level IS '수분 섭취: good(충분히), moderate(적당히), poor(부족)';
COMMENT ON COLUMN public.daily_checkins.gi_comfort IS 'GI 편안함: good(편안함), uncomfortable(불편함), very_uncomfortable(매우 불편함)';
COMMENT ON COLUMN public.daily_checkins.bowel_condition IS '배변 상태: normal(정상), irregular(불규칙), difficult(힘듦)';
COMMENT ON COLUMN public.daily_checkins.energy_level IS '에너지: good(활기참), normal(보통), tired(피곤함)';
COMMENT ON COLUMN public.daily_checkins.mood IS '기분: good(좋음), neutral(그저 그럼), low(우울함)';

COMMENT ON COLUMN public.daily_checkins.appetite_score IS '식욕 점수: 1=아예없음, 2=매우감소, 3=약간감소, 4=보통, 5=폭발 (meal_condition과 연동)';
COMMENT ON COLUMN public.daily_checkins.symptom_details IS '파생 증상 상세 JSONB: [{"type": "nausea", "severity": 2, "details": {...}}]';
COMMENT ON COLUMN public.daily_checkins.context IS '체크인 컨텍스트 JSONB: 주사 다음날, 연속 일수, 인사 타입 등';
COMMENT ON COLUMN public.daily_checkins.red_flag_detected IS 'Red Flag 감지 결과 JSONB: 췌장염, 담낭염, 탈수 등 위험 신호 자동 감지';

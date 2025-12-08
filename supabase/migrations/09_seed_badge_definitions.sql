-- ============================================
-- Badge Definitions Seed Data
-- ============================================
-- 뱃지 정의 테이블에 초기 뱃지 데이터를 추가합니다.
--
-- 뱃지 카테고리:
-- - streak: 연속 기록 관련 뱃지
-- - weight: 체중 목표 진행률 관련 뱃지
-- - dose: 투여 관련 뱃지

INSERT INTO public.badge_definitions (id, name, description, category, achievement_condition, display_order) VALUES
  -- 연속 기록 뱃지
  ('streak_7', '7일 연속 기록', '7일 연속으로 기록을 남겼어요', 'streak', '{"type": "streak", "days": 7}', 1),
  ('streak_30', '30일 연속 기록', '30일 연속으로 기록을 남겼어요', 'streak', '{"type": "streak", "days": 30}', 2),

  -- 체중 목표 진행률 뱃지 (시작 체중 -> 목표 체중)
  ('weight_25percent', '25% 목표 달성', '목표 체중까지 25% 달성했어요', 'weight', '{"type": "weight_progress", "percent": 25}', 3),
  ('weight_50percent', '50% 목표 달성', '목표 체중까지 50% 달성했어요', 'weight', '{"type": "weight_progress", "percent": 50}', 4),
  ('weight_75percent', '75% 목표 달성', '목표 체중까지 75% 달성했어요', 'weight', '{"type": "weight_progress", "percent": 75}', 5),
  ('weight_100percent', '목표 달성!', '목표 체중을 달성했어요!', 'weight', '{"type": "weight_progress", "percent": 100}', 6),

  -- 투여 관련 뱃지
  ('first_dose', '첫 투여 완료', '첫 번째 투여를 완료했어요', 'dose', '{"type": "first_dose"}', 7)

ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Trigger: 새 사용자 등록 시 public.users 자동 생성
-- ============================================
-- 이 trigger는 auth.users에 새 사용자가 생성될 때
-- 자동으로 public.users 테이블에 프로필을 생성합니다.
--
-- SECURITY DEFINER:
-- - Trigger가 RLS 정책을 우회하도록 함수 소유자(postgres) 권한으로 실행
-- - 신규 가입 시점에는 auth.uid()가 세션에 아직 없을 수 있으므로 필수
--
-- 참고: https://github.com/orgs/supabase/discussions/306

-- ============================================
-- Step 1: Trigger 함수 생성 (SECURITY DEFINER)
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER  -- 🔑 핵심: 함수 소유자(postgres) 권한으로 실행하여 RLS 우회
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- auth.users의 새 레코드를 public.users에 복사
  INSERT INTO public.users (
    id,
    oauth_provider,
    oauth_user_id,
    name,
    email,
    profile_image_url,
    created_at,
    last_login_at
  ) VALUES (
    NEW.id::TEXT,  -- auth.users.id (UUID)를 TEXT로 변환
    'kakao',       -- 기본값: Kakao OAuth (Supabase Auth 사용)
    NEW.id::TEXT,  -- oauth_user_id도 동일한 id 사용
    COALESCE(NEW.raw_user_meta_data->>'name', 'Unknown'),  -- 카카오에서 받은 이름
    NEW.email,     -- 카카오에서 받은 이메일
    NEW.raw_user_meta_data->>'avatar_url',  -- 프로필 이미지 URL (선택)
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$;

-- ============================================
-- Step 2: Trigger 생성 (auth.users INSERT 후 실행)
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- Step 3: RLS 정책에 INSERT 권한 추가
-- ============================================
-- 기존 정책은 SELECT/UPDATE만 허용하므로 INSERT 정책 추가 필요
-- Trigger가 SECURITY DEFINER로 실행되므로 이론상 불필요하지만,
-- 앱 코드에서 consent_records 등을 INSERT할 때 필요할 수 있음

-- Users 테이블: 신규 사용자 자신이 INSERT 가능 (초기 프로필 설정)
CREATE POLICY "Users can insert own profile on signup"
ON public.users FOR INSERT
WITH CHECK (auth.uid()::TEXT = id);

-- 완료 메시지
SELECT
  'Trigger created successfully!' as status,
  'New users will automatically get a profile in public.users' as note;

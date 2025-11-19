-- ============================================
-- Email Authentication Support (F-016)
-- ============================================
-- 이메일 회원가입/로그인 기능을 위한 Database 설정
-- Supabase Auth (auth.users)와 public.users 테이블 동기화

-- ============================================
-- 1. Trigger Function: auth.users → public.users 동기화
-- ============================================
-- 목적: Supabase Auth로 가입한 사용자(Kakao, 이메일)를
--       public.users 테이블에 자동으로 동기화
--
-- 주의사항:
-- - security definer: 권한 상승 실행 (RLS 우회)
-- - set search_path = '': SQL Injection 방지
-- - Trigger 실패 시 회원가입 차단되므로 철저한 테스트 필요

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  -- auth.users에 신규 사용자 생성 시 public.users에 자동 삽입
  INSERT INTO public.users (
    id,
    oauth_provider,
    oauth_user_id,
    name,
    email,
    profile_image_url,
    last_login_at
  )
  VALUES (
    NEW.id,
    -- provider: 'kakao', 'email' 등 (app_metadata에서 추출)
    COALESCE(NEW.app_metadata->>'provider', 'email'),
    -- oauth_user_id: 소셜 로그인 시 provider의 user id, 이메일 로그인 시 auth.users.id
    COALESCE(NEW.raw_user_meta_data->>'sub', NEW.id),
    -- name: raw_user_meta_data에서 추출, 없으면 빈 문자열 (온보딩에서 입력)
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    -- email: auth.users.email 사용
    NEW.email,
    -- profile_image_url: 소셜 로그인 시 프로필 이미지
    NEW.raw_user_meta_data->>'avatar_url',
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    last_login_at = NOW();

  RETURN NEW;
END;
$$;

-- ============================================
-- 2. Trigger 설정: auth.users INSERT 시 자동 실행
-- ============================================
-- 기존 Trigger가 있으면 삭제 후 재생성
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 3. 주석 추가 (문서화)
-- ============================================
COMMENT ON FUNCTION public.handle_new_user() IS
  'Supabase Auth (auth.users)에 신규 사용자 생성 시 public.users에 자동 동기화. 이메일/소셜 로그인 모두 지원.';

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS
  'auth.users INSERT 이벤트 발생 시 public.handle_new_user() 함수 호출';

-- ============================================
-- 4. 테스트 쿼리 (선택사항)
-- ============================================
-- 주의: 실제 배포 시에는 아래 테스트 쿼리 제거 필요
--
-- 테스트 방법:
-- 1. Flutter에서 signUp() 호출
-- 2. 아래 쿼리로 public.users에 데이터 생성 확인
--
-- SELECT * FROM public.users WHERE oauth_provider = 'email';
-- SELECT * FROM auth.users WHERE email = 'test@example.com';

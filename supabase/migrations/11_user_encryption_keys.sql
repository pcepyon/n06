-- ============================================
-- F021: Option A - 암호화 키 서버 저장 방식
-- ============================================
-- 암호화 키를 Supabase에 저장하여 다중 기기에서 접근 가능하게 합니다.
--
-- 보안 고려사항:
-- - RLS 정책으로 사용자 본인만 키 접근 가능
-- - 키는 Base64 인코딩된 256비트 랜덤 키
-- - 통신 구간은 HTTPS로 암호화됨

-- ============================================
-- user_encryption_keys 테이블 생성
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_encryption_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  encryption_key TEXT NOT NULL,  -- Base64(256-bit key)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- 사용자당 하나의 키만 허용
  CONSTRAINT unique_user_encryption_key UNIQUE (user_id)
);

-- ============================================
-- 인덱스
-- ============================================
CREATE INDEX idx_user_encryption_keys_user_id
ON public.user_encryption_keys(user_id);

-- ============================================
-- RLS 정책 활성화
-- ============================================
ALTER TABLE public.user_encryption_keys ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS 정책: 사용자는 본인의 키만 접근 가능
-- ============================================
CREATE POLICY "Users can access own encryption key"
ON public.user_encryption_keys FOR ALL
USING (auth.uid() = user_id);

-- ============================================
-- updated_at 자동 갱신 트리거
-- ============================================
CREATE TRIGGER update_user_encryption_keys_updated_at
  BEFORE UPDATE ON public.user_encryption_keys
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 주석
-- ============================================
COMMENT ON TABLE public.user_encryption_keys IS '사용자별 AES-256 암호화 키 저장소 (다중 기기 지원)';
COMMENT ON COLUMN public.user_encryption_keys.encryption_key IS 'Base64 인코딩된 256비트 AES 키';

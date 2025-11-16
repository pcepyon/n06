# Supabase 설정 가이드

## 1. Supabase 프로젝트 생성

1. https://supabase.com/dashboard 접속
2. "New Project" 클릭
3. 프로젝트 설정:
   - Project Name: `glp1-mvp-production`
   - Database Password: 안전하게 보관
   - Region: **Northeast Asia (Seoul)** - ap-northeast-2
4. 프로젝트 생성 완료 대기 (약 2분)

## 2. 환경 변수 설정

1. Supabase Dashboard → Settings → API
2. 다음 정보 복사:
   - Project URL
   - anon/public key (절대 service_role key는 사용하지 마세요!)
3. 프로젝트 루트의 `.env` 파일 수정:
   ```bash
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

## 3. 마이그레이션 실행

**중요**: 마이그레이션은 반드시 순서대로 실행해야 합니다.

### 방법 1: Supabase CLI (권장)

```bash
# Supabase CLI 설치 (처음 한 번만)
brew install supabase/tap/supabase

# Supabase 프로젝트와 연결
supabase link --project-ref [YOUR_PROJECT_REF]

# 마이그레이션 실행
supabase db push
```

### 방법 2: SQL Editor (수동)

1. **스키마 생성**
   - SQL Editor → New Query
   - `supabase/migrations/01.schema.sql` 복사 & 실행

2. **RLS 정책 생성**
   - SQL Editor → New Query
   - `supabase/migrations/02.rls_policies.sql` 복사 & 실행

3. **Users 테이블 업데이트** (Kakao + Naver 지원)
   - SQL Editor → New Query
   - `supabase/migrations/03.migration_update_users_table.sql` 복사 & 실행

4. **새 사용자 자동 등록 Trigger 생성** ⭐
   - SQL Editor → New Query
   - `supabase/migrations/04.handle_new_user_trigger.sql` 복사 & 실행

### 생성된 테이블 (16개)

Database → Tables 메뉴에서 확인:
- users
- consent_records
- user_profiles
- dosage_plans
- plan_change_history
- dose_schedules
- dose_records
- weight_logs
- symptom_logs
- symptom_context_tags
- emergency_symptom_checks
- badge_definitions
- user_badges
- notification_settings
- guide_feedback
- audit_logs

## 5. OAuth 설정

### Kakao
`signInWithIdToken()` API를 사용하기 위해 Supabase에서 Kakao Provider를 활성화해야 합니다.

1. **Kakao Developers Console** (https://developers.kakao.com)
   - 내 애플리케이션 → 앱 선택
   - 앱 키 섹션에서 다음 정보 복사:
     - REST API 키 (Client ID로 사용)
     - 앱 시크릿 키 생성 (없으면 생성) → Client Secret으로 사용

2. **Supabase Dashboard** → Authentication → Providers
   - "Kakao" 클릭
   - 설정:
     - Enable Kakao: **ON**
     - Client ID (REST API Key): `복사한 REST API 키 입력`
     - Client Secret Code: `복사한 앱 시크릿 키 입력`
     - Authorized Redirect URLs: Supabase에서 자동 생성됨
   - Save

3. **Kakao Developers Console에서 Redirect URI 추가**
   - 내 애플리케이션 → 카카오 로그인 → Redirect URI
   - Supabase에서 제공한 Redirect URL 추가
   - 형식: `https://[PROJECT_REF].supabase.co/auth/v1/callback`

**참고**: 현재 Native App Key (`32dfc3999b53af153dbcefa7014093bc`)는 모바일 앱용이며, REST API Key는 서버 간 토큰 검증용으로 별도로 필요합니다.

### Naver
Naver는 Supabase Auth의 OAuth Provider를 사용하지 않습니다.
- Native SDK로 로그인 후 직접 users 테이블에 저장
- Supabase Dashboard 설정 불필요

## 6. 검증

```bash
cd /Users/pro16/Desktop/project/n06
flutter pub get
flutter run
```

앱이 정상적으로 실행되면 설정 완료!

## 트러블슈팅

### 문제: "Invalid JWT" 에러
- `.env` 파일의 SUPABASE_ANON_KEY 확인
- anon key인지 확인 (service_role key 아님)

### 문제: 테이블 생성 실패
- UUID extension 활성화 확인
- 테이블 순서대로 실행 (FK 의존성)

### 문제: RLS 정책 적용 안됨
- `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` 실행 확인
- 로그인 상태에서 테스트

### 문제: "must be owner of relation users" 에러
**원인**: 마이그레이션 파일을 일반 사용자 권한으로 실행
**해결방법**: Supabase Dashboard의 SQL Editor를 사용하면 자동으로 postgres 권한으로 실행됩니다.

### 문제: "new row violates row-level security policy for table users"
**원인**: Trigger 함수가 RLS 정책에 막힘
**해결방법**: `04.handle_new_user_trigger.sql`의 `SECURITY DEFINER` 키워드가 필수입니다.

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER  -- 🔑 이 부분이 핵심!
...
```

**SECURITY DEFINER의 역할**:
- Trigger 함수가 함수 소유자(postgres)의 권한으로 실행됨
- RLS 정책을 우회하여 public.users에 INSERT 가능
- 신규 가입 시점에는 auth.uid()가 세션에 아직 없을 수 있으므로 필수

**참고**: https://github.com/orgs/supabase/discussions/306

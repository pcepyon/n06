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

## 3. 데이터베이스 스키마 생성

1. Supabase Dashboard → SQL Editor
2. "New Query" 클릭
3. `docs/supabase/schema.sql` 파일 내용 전체 복사
4. 붙여넣기 후 "Run" 버튼 클릭
5. 성공 메시지 확인
6. Database → Tables 메뉴에서 17개 테이블 생성 확인:
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

## 4. RLS 정책 설정

1. SQL Editor에서 "New Query" 클릭
2. `docs/supabase/rls_policies.sql` 파일 내용 전체 복사
3. 붙여넣기 후 "Run" 버튼 클릭
4. 성공 메시지 확인
5. Database → Tables → 각 테이블 → Policies 탭에서 정책 확인

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

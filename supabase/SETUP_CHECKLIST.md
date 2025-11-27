# Supabase 설정 체크리스트

이 문서는 Supabase 설정 완료 여부를 확인하기 위한 체크리스트입니다.

## 환경 변수 설정

- [x] `.env` 파일에 SUPABASE_URL 설정
- [x] `.env` 파일에 SUPABASE_ANON_KEY 설정
- [x] `.gitignore`에 `.env` 파일 제외 확인
- [x] `.env.example` 템플릿 파일 생성

## Kakao OAuth 설정

### Kakao Developers Console
- [ ] REST API 키 복사
- [ ] 앱 시크릿 코드 생성 및 복사
- [ ] Redirect URI 추가: `https://wbxaiwbotzrdvhfopykh.supabase.co/auth/v1/callback`

### Supabase Dashboard
- [x] Authentication → Providers → Kakao 활성화
- [x] Client ID (REST API Key) 입력
- [x] Client Secret Code 입력
- [x] "Allow users without an email" 활성화

## 데이터베이스 설정

### 마이그레이션 실행 (순서대로!)

**방법 1: Supabase CLI (권장)**
```bash
supabase link --project-ref [YOUR_PROJECT_REF]
supabase db push
```

**방법 2: SQL Editor (수동)**

- [ ] **1단계: 스키마 생성**
  - [ ] Supabase Dashboard → SQL Editor
  - [ ] `supabase/migrations/01.schema.sql` 복사 & 실행

- [ ] **2단계: RLS 정책 생성**
  - [ ] SQL Editor → New Query
  - [ ] `supabase/migrations/02.rls_policies.sql` 복사 & 실행

- [ ] **3단계: Users 테이블 업데이트** (Kakao + Naver 지원)
  - [ ] SQL Editor → New Query
  - [ ] `supabase/migrations/03.migration_update_users_table.sql` 복사 & 실행
  - [ ] 성공 메시지 확인: "Migration completed successfully!"

- [ ] **4단계: Trigger 생성** ⭐ **중요!**
  - [ ] SQL Editor → New Query
  - [ ] `supabase/migrations/04.handle_new_user_trigger.sql` 복사 & 실행
  - [ ] 성공 메시지 확인: "Trigger created successfully!"

**테이블 생성 확인:**
- [ ] Database → Tables에서 16개 테이블 생성 확인:
  - [ ] users
  - [ ] consent_records
  - [ ] user_profiles
  - [ ] dosage_plans
  - [ ] plan_change_history
  - [ ] dose_schedules
  - [ ] dose_records
  - [ ] weight_logs
  - [ ] symptom_logs
  - [ ] symptom_context_tags
  - [ ] emergency_symptom_checks
  - [ ] badge_definitions
  - [ ] user_badges
  - [ ] notification_settings
  - [ ] guide_feedback
  - [ ] audit_logs

**Trigger 확인:**
- [ ] Database → Functions에서 `handle_new_user` 함수 확인
- [ ] Function 상세 정보에서 `SECURITY DEFINER` 설정 확인

## Supabase Authentication 추가 설정

### Email Settings (선택사항)
- [ ] Authentication → Email Templates 확인
- [ ] SMTP 설정 (프로덕션 환경에서 필요)

### URL Configuration
- [ ] Authentication → URL Configuration
- [ ] Site URL 설정 (필요시)
- [ ] Redirect URLs 추가 (필요시)

## 앱 빌드 및 테스트

### 1. 빌드
```bash
cd /Users/pro16/Desktop/project/n06
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. 실행
```bash
flutter run
```

### 3. 테스트 항목
- [ ] 앱이 정상적으로 시작됨
- [ ] Supabase 초기화 성공 로그 확인: `***** Supabase init completed *****`
- [ ] Kakao 로그인 테스트 (실제 디바이스 권장)
  - [ ] 카카오톡 앱 로그인 시도
  - [ ] 웹 로그인 폴백 동작
  - [ ] users 테이블에 사용자 정보 저장 확인
  - [ ] consent_records 테이블에 동의 기록 저장 확인
- [ ] Naver 로그인 테스트
  - [ ] 네이버 앱 로그인 시도
  - [ ] Edge Function 정상 호출 확인
  - [ ] auth.users 테이블에 사용자 생성 확인
  - [ ] public.users 테이블에 사용자 정보 저장 확인
  - [ ] RLS 정책 정상 작동 확인 (auth.uid() = user_id)

## Naver OAuth 설정 (Edge Function 방식)

네이버는 OIDC를 지원하지 않아 Edge Function을 통한 인증이 필요합니다.

### Naver Developers Console
- [ ] 애플리케이션 등록 (https://developers.naver.com)
- [ ] 사용 API: `네이버 로그인` 선택
- [ ] 필수 권한 설정: 이메일 주소, 별명, 프로필 사진
- [ ] iOS Bundle ID 등록
- [ ] Android 패키지명 + 서명 키 해시 등록
- [ ] Client ID / Client Secret 획득

### Flutter 앱 설정
- [ ] Android: `android/app/src/main/res/values/strings.xml`에 설정
  ```xml
  <string name="naver_client_id">YOUR_CLIENT_ID</string>
  <string name="naver_client_secret">YOUR_CLIENT_SECRET</string>
  <string name="naver_client_name">YOUR_APP_NAME</string>
  ```
- [ ] iOS: `Info.plist`에 URL Scheme 등록

### Edge Function 배포
```bash
cd supabase
supabase functions deploy naver-auth
```

- [ ] Edge Function 배포 확인: `supabase functions list`
- [ ] 환경 변수 자동 설정 확인:
  - `SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY`
  - `SUPABASE_ANON_KEY`

## 트러블슈팅

### "Invalid JWT" 에러
- [ ] `.env` 파일의 SUPABASE_ANON_KEY 확인
- [ ] service_role key가 아닌 anon key인지 확인
- [ ] 앱 재빌드 및 재시작

### 테이블 생성 실패
- [ ] UUID extension 활성화 확인: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`
- [ ] 테이블 순서대로 실행 (FK 의존성)
- [ ] 에러 메시지 확인 및 해결

### RLS 정책 적용 안됨
- [ ] `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` 실행 확인
- [ ] 로그인 상태에서 테스트
- [ ] auth.uid() 함수가 올바른 사용자 ID 반환하는지 확인

### "must be owner of relation users" 에러
- [ ] Supabase Dashboard의 SQL Editor를 사용 (자동으로 postgres 권한)
- [ ] 로컬 Supabase CLI 사용 시 `supabase db push` 실행

### "new row violates row-level security policy for table users" 에러
- [ ] `04.handle_new_user_trigger.sql` 마이그레이션 실행 확인
- [ ] Trigger 함수에 `SECURITY DEFINER` 키워드 포함 확인
- [ ] Database → Functions에서 `handle_new_user` 함수 존재 확인

### Kakao 로그인 실패
- [ ] Kakao Developers Console에서 앱 상태 확인
- [ ] REST API 키와 Client Secret 재확인
- [ ] Redirect URI 정확히 설정되었는지 확인
- [ ] Supabase Dashboard → Authentication → Logs 확인
- [ ] `handle_new_user` trigger가 정상 동작하는지 확인

### Naver 로그인 실패

#### "Edge Function error" 메시지
- [ ] Edge Function 배포 확인: `supabase functions list`
- [ ] Edge Function 로그 확인: `supabase functions logs naver-auth`
- [ ] Naver access token이 유효한지 확인

#### "Invalid Naver access token" 에러
- [ ] Naver 앱에서 로그아웃 후 다시 로그인
- [ ] Naver Developers Console에서 앱 상태 확인
- [ ] 네이버 API 권한 설정 확인

#### "Failed to generate magic link" 에러
- [ ] Supabase Service Role Key 환경 변수 확인
- [ ] Supabase Dashboard → Functions → naver-auth → Secrets 확인

#### "Failed to set Supabase session" 에러
- [ ] Edge Function이 올바른 refresh_token을 반환하는지 확인
- [ ] Supabase Dashboard → Authentication → Logs 확인

#### RLS 정책 미적용 (네이버 로그인 후 데이터 접근 불가)
- [ ] auth.users 테이블에 사용자가 생성되었는지 확인
- [ ] public.users 테이블의 id가 auth.users의 id와 동일한지 확인
- [ ] 이전 방식(naver_xxx ID)으로 생성된 사용자 데이터 마이그레이션 필요

## 다음 단계

설정이 완료되면:
1. 실제 사용자 데이터로 테스트
2. 배지 정의 데이터 초기화 (`badge_definitions` 테이블)
3. 프로덕션 환경 설정 검토
4. 모니터링 및 로깅 설정

## 참고 문서
- [Supabase 설정 가이드](./README.md)
- [데이터베이스 스키마](./schema.sql)
- [RLS 정책](./rls_policies.sql)
- [프로젝트 요구사항](/docs/requirements.md)

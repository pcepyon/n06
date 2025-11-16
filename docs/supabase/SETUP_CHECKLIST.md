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

### 1. 스키마 생성

**이미 기존 schema.sql로 마이그레이션을 실행한 경우:**

#### 옵션 A: 마이그레이션으로 수정 (권장)
- [ ] Supabase Dashboard → SQL Editor 접속
- [ ] `docs/supabase/migration_update_users_table.sql` 파일 내용 복사
- [ ] SQL Editor에 붙여넣고 "Run" 실행
- [ ] 성공 메시지 확인: "Migration completed successfully!"

#### 옵션 B: 테이블 삭제 후 재생성 (개발 환경, 데이터 없을 때만)
- [ ] `docs/supabase/drop_all_tables.sql` 실행 (모든 테이블 삭제)
- [ ] `docs/supabase/schema.sql` 실행 (새 스키마로 재생성)

**처음 설정하는 경우:**
- [ ] Supabase Dashboard → SQL Editor 접속
- [ ] `docs/supabase/schema.sql` 파일 내용 복사
- [ ] SQL Editor에 붙여넣고 "Run" 실행
- [ ] 성공 메시지 확인

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

### 2. RLS 정책 설정
- [ ] SQL Editor에서 "New Query" 클릭
- [ ] `docs/supabase/rls_policies.sql` 파일 내용 복사
- [ ] 붙여넣고 "Run" 실행
- [ ] 성공 메시지 확인
- [ ] Database → Tables → 각 테이블 → Policies 탭에서 정책 확인

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
- [ ] Naver 로그인 테스트 (Phase 1.3 이후)

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

### Kakao 로그인 실패
- [ ] Kakao Developers Console에서 앱 상태 확인
- [ ] REST API 키와 Client Secret 재확인
- [ ] Redirect URI 정확히 설정되었는지 확인
- [ ] Supabase Dashboard → Authentication → Logs 확인

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

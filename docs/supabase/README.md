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
1. Supabase Dashboard → Authentication → Providers
2. "Kakao" 클릭
3. 설정:
   - Enable Kakao: **ON**
   - Client ID: (비워둠 - 네이티브 SDK 사용)
   - Client Secret: (비워둠 - 네이티브 SDK 사용)
4. Save

### Naver
- 현재 단계에서는 설정 불필요
- Phase 1.3에서 네이티브 SDK로 처리

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

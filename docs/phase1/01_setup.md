# Phase 1.1: 사전 준비

**목표**: Supabase 프로젝트 설정, 데이터베이스 스키마 생성, RLS 정책 설정

**소요 기간**: 1주

**담당**: DevOps 엔지니어

---

## 1. Supabase 프로젝트 생성

### 1.1 작업 순서

1. **Supabase Dashboard 접속**
   - URL: https://supabase.com/dashboard
   - 계정 생성 또는 로그인

2. **새 프로젝트 생성**
   - "New Project" 클릭
   - 프로젝트명: `glp1-mvp-production`
   - 리전: `Northeast Asia (Seoul)` - ap-northeast-2
   - Database Password 생성 및 **안전하게 보관** (1Password/Bitwarden 등)

3. **프로젝트 정보 저장**
   ```
   Project URL: https://[project-ref].supabase.co
   Anon Key: [anon-key]
   Service Role Key: [service-role-key] (절대 클라이언트에 노출 금지)
   ```

### 1.2 체크리스트

- [ ] Supabase 계정 생성 완료
- [ ] 프로젝트 생성 완료
- [ ] Database Password 안전하게 보관
- [ ] Project URL, Anon Key, Service Role Key 저장

---

## 2. 환경 변수 설정

### 2.1 `.env` 파일 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/.env`

```bash
# Supabase Configuration
SUPABASE_URL=https://[project-ref].supabase.co
SUPABASE_ANON_KEY=[your-anon-key]

# 절대 Git에 커밋하지 마세요!
```

### 2.2 `.gitignore` 수정

**파일 위치**: `/Users/pro16/Desktop/project/n06/.gitignore`

```bash
# 기존 내용 유지 +

# Environment Variables
.env
.env.local
.env.production
```

### 2.3 `pubspec.yaml` 의존성 추가

**파일 위치**: `/Users/pro16/Desktop/project/n06/pubspec.yaml`

**수정 내용**:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # 기존 의존성...

  # Supabase (신규 추가)
  supabase_flutter: ^2.0.0

  # 제거 예정 (Phase 1 완료 후)
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

dev_dependencies:
  # 기존 의존성...

  # 제거 예정 (Phase 1 완료 후)
  isar_generator: ^3.1.0+1
```

**명령어 실행**:
```bash
cd /Users/pro16/Desktop/project/n06
flutter pub get
```

### 2.4 Supabase 초기화 코드

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/main.dart`

**수정 내용**:
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 추가 필요

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  await dotenv.load(fileName: ".env");

  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}
```

**flutter_dotenv 추가**:
```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

# .env 파일을 assets로 등록
flutter:
  assets:
    - .env
```

### 2.5 Supabase Provider 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/core/providers.dart`

**수정 내용**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isar/isar.dart';

part 'providers.g.dart';

// Supabase Provider (신규 추가)
@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

// Isar Provider (기존 유지 - Phase 1 완료 후 제거)
@Riverpod(keepAlive: true)
Isar isar(IsarRef ref) {
  throw UnimplementedError('Override in main.dart');
}
```

### 2.6 체크리스트

- [ ] `.env` 파일 생성 및 Supabase 정보 입력
- [ ] `.gitignore`에 `.env` 추가
- [ ] `pubspec.yaml`에 `supabase_flutter` 추가
- [ ] `flutter pub get` 실행 성공
- [ ] `main.dart`에 Supabase 초기화 코드 추가
- [ ] `core/providers.dart`에 `supabaseProvider` 추가
- [ ] 빌드 성공 확인

---

## 3. 데이터베이스 스키마 생성

### 3.1 SQL 파일 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/docs/supabase/schema.sql`

디렉토리 생성:
```bash
mkdir -p /Users/pro16/Desktop/project/n06/docs/supabase
```

**파일 내용**: [schema.sql 전체 내용은 별도 파일 참조]

```sql
-- ============================================
-- GLP-1 MVP Database Schema (Supabase)
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. Users Table (Supabase Auth 연동)
-- ============================================
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  profile_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 2. Consent Records
-- ============================================
CREATE TABLE public.consent_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  terms_of_service BOOLEAN NOT NULL,
  privacy_policy BOOLEAN NOT NULL,
  agreed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 3. User Profiles
-- ============================================
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  target_weight_kg NUMERIC(5,2) NOT NULL,
  target_period_weeks INTEGER,
  weekly_loss_goal_kg NUMERIC(4,2),
  weekly_weight_record_goal INTEGER NOT NULL DEFAULT 7,
  weekly_symptom_record_goal INTEGER NOT NULL DEFAULT 7,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. Dosage Plans
-- ============================================
CREATE TABLE public.dosage_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  medication_name VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  cycle_days INTEGER NOT NULL,
  initial_dose_mg NUMERIC(6,2) NOT NULL,
  escalation_plan JSONB,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dosage_plans_user_active ON public.dosage_plans(user_id, is_active);

-- ============================================
-- 5. Plan Change History
-- ============================================
CREATE TABLE public.plan_change_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dosage_plan_id UUID NOT NULL REFERENCES public.dosage_plans(id) ON DELETE CASCADE,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  old_plan JSONB NOT NULL,
  new_plan JSONB NOT NULL
);

-- ============================================
-- 6. Dose Schedules
-- ============================================
CREATE TABLE public.dose_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dosage_plan_id UUID NOT NULL REFERENCES public.dosage_plans(id) ON DELETE CASCADE,
  scheduled_date DATE NOT NULL,
  scheduled_dose_mg NUMERIC(6,2) NOT NULL,
  notification_time TIME,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dose_schedules_plan_date ON public.dose_schedules(dosage_plan_id, scheduled_date);

-- ============================================
-- 7. Dose Records
-- ============================================
CREATE TABLE public.dose_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dose_schedule_id UUID REFERENCES public.dose_schedules(id) ON DELETE SET NULL,
  dosage_plan_id UUID NOT NULL REFERENCES public.dosage_plans(id) ON DELETE CASCADE,
  administered_at TIMESTAMPTZ NOT NULL,
  actual_dose_mg NUMERIC(6,2) NOT NULL,
  injection_site VARCHAR(20),
  is_completed BOOLEAN NOT NULL DEFAULT TRUE,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dose_records_plan_administered ON public.dose_records(dosage_plan_id, administered_at);
CREATE INDEX idx_dose_records_injection_site ON public.dose_records(injection_site, administered_at DESC);

-- ============================================
-- 8. Weight Logs
-- ============================================
CREATE TABLE public.weight_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  weight_kg NUMERIC(5,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, log_date)
);

CREATE INDEX idx_weight_logs_user_date ON public.weight_logs(user_id, log_date DESC);

-- ============================================
-- 9. Symptom Logs
-- ============================================
CREATE TABLE public.symptom_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  symptom_name VARCHAR(50) NOT NULL,
  severity INTEGER NOT NULL CHECK (severity >= 1 AND severity <= 10),
  days_since_escalation INTEGER,
  is_persistent_24h BOOLEAN,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_symptom_logs_user_date ON public.symptom_logs(user_id, log_date DESC);

-- ============================================
-- 10. Symptom Context Tags
-- ============================================
CREATE TABLE public.symptom_context_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symptom_log_id UUID NOT NULL REFERENCES public.symptom_logs(id) ON DELETE CASCADE,
  tag_name VARCHAR(50) NOT NULL
);

CREATE INDEX idx_symptom_context_tags_log ON public.symptom_context_tags(symptom_log_id);
CREATE INDEX idx_symptom_context_tags_name ON public.symptom_context_tags(tag_name);

-- ============================================
-- 11. Emergency Symptom Checks
-- ============================================
CREATE TABLE public.emergency_symptom_checks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  checked_symptoms JSONB NOT NULL
);

CREATE INDEX idx_emergency_checks_user_checked ON public.emergency_symptom_checks(user_id, checked_at DESC);

-- ============================================
-- 12. Badge Definitions (정적 데이터)
-- ============================================
CREATE TABLE public.badge_definitions (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(20) NOT NULL,
  achievement_condition JSONB NOT NULL,
  icon_url TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_badge_definitions_category ON public.badge_definitions(category, display_order);

-- ============================================
-- 13. User Badges
-- ============================================
CREATE TABLE public.user_badges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  badge_id VARCHAR(50) NOT NULL REFERENCES public.badge_definitions(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL CHECK (status IN ('locked', 'in_progress', 'achieved')),
  progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  achieved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

CREATE INDEX idx_user_badges_user_status ON public.user_badges(user_id, status);
CREATE INDEX idx_user_badges_user_achieved ON public.user_badges(user_id, achieved_at DESC);

-- ============================================
-- 14. Notification Settings
-- ============================================
CREATE TABLE public.notification_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  notification_hour INTEGER NOT NULL CHECK (notification_hour >= 0 AND notification_hour <= 23),
  notification_minute INTEGER NOT NULL CHECK (notification_minute >= 0 AND notification_minute <= 59),
  notification_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 15. Guide Feedback (선택적)
-- ============================================
CREATE TABLE public.guide_feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  symptom_name VARCHAR(50) NOT NULL,
  helpful BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_guide_feedback_user ON public.guide_feedback(user_id, created_at DESC);

-- ============================================
-- 16. Audit Logs (기록 수정 이력)
-- ============================================
CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entity_type VARCHAR(50) NOT NULL,
  entity_id UUID NOT NULL,
  action VARCHAR(20) NOT NULL,
  old_data JSONB,
  new_data JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_created ON public.audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
```

### 3.2 스키마 실행

**Supabase Dashboard에서 실행**:
1. Supabase Dashboard 접속
2. 좌측 메뉴에서 "SQL Editor" 클릭
3. "New Query" 클릭
4. `schema.sql` 파일 내용 복사 & 붙여넣기
5. "Run" 버튼 클릭
6. 실행 성공 확인

**또는 CLI 사용**:
```bash
# Supabase CLI 설치
npm install -g supabase

# 로그인
supabase login

# 프로젝트 연결
supabase link --project-ref [your-project-ref]

# 스키마 실행
supabase db push --file docs/supabase/schema.sql
```

### 3.3 검증

**Supabase Dashboard에서 확인**:
1. "Database" > "Tables" 메뉴
2. 17개 테이블 생성 확인:
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

### 3.4 체크리스트

- [ ] `docs/supabase/schema.sql` 파일 생성
- [ ] Supabase Dashboard에서 SQL 실행
- [ ] 17개 테이블 생성 확인
- [ ] 인덱스 생성 확인

---

## 4. RLS (Row Level Security) 정책 설정

### 4.1 SQL 파일 생성

**파일 위치**: `/Users/pro16/Desktop/project/n06/docs/supabase/rls_policies.sql`

**파일 내용**: [전체 내용은 별도 파일 참조]

```sql
-- ============================================
-- Row Level Security Policies
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dosage_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plan_change_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dose_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dose_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_context_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_symptom_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Users: 자신의 프로필만 접근
-- ============================================
CREATE POLICY "Users can view own profile"
ON public.users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- ============================================
-- User-owned tables: 자신의 데이터만 접근
-- ============================================
CREATE POLICY "Users can access own consent records"
ON public.consent_records FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own profile"
ON public.user_profiles FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own dosage plans"
ON public.dosage_plans FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own weight logs"
ON public.weight_logs FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own symptom logs"
ON public.symptom_logs FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own emergency checks"
ON public.emergency_symptom_checks FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own badges"
ON public.user_badges FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own notification settings"
ON public.notification_settings FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own guide feedback"
ON public.guide_feedback FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can access own audit logs"
ON public.audit_logs FOR ALL
USING (auth.uid() = user_id);

-- ============================================
-- Related tables: parent 소유권 기반
-- ============================================
CREATE POLICY "Users can access own plan history"
ON public.plan_change_history FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can access own dose schedules"
ON public.dose_schedules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can access own dose records"
ON public.dose_records FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.dosage_plans
    WHERE id = dosage_plan_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can access own symptom tags"
ON public.symptom_context_tags FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.symptom_logs
    WHERE id = symptom_log_id AND user_id = auth.uid()
  )
);

-- ============================================
-- Badge Definitions: 모든 사용자 읽기 가능
-- ============================================
CREATE POLICY "Badge definitions are readable by all authenticated users"
ON public.badge_definitions FOR SELECT
USING (auth.role() = 'authenticated');
```

### 4.2 RLS 정책 실행

**Supabase Dashboard에서 실행**:
1. "SQL Editor" 클릭
2. "New Query" 클릭
3. `rls_policies.sql` 파일 내용 복사 & 붙여넣기
4. "Run" 버튼 클릭
5. 실행 성공 확인

### 4.3 검증

**Supabase Dashboard에서 확인**:
1. "Database" > "Tables" 메뉴
2. 각 테이블 클릭
3. "RLS" 탭에서 정책 확인

### 4.4 체크리스트

- [ ] `docs/supabase/rls_policies.sql` 파일 생성
- [ ] Supabase Dashboard에서 SQL 실행
- [ ] 모든 테이블에 RLS 활성화 확인
- [ ] 정책 생성 확인 (총 13개 정책)

---

## 5. OAuth 설정

> **중요**: OAuth 설정, 특히 네이티브 플랫폼(Android/iOS) 설정은 **`docs/external/flutter_kakao_gorouter_guide.md`** 문서를 반드시 참조하여 정확하게 진행해야 합니다. 아래는 Supabase 연동에 필요한 핵심 사항 요약입니다.

### 5.1 Kakao OAuth 설정

**Kakao Developers Console**:
1.  **플랫폼 등록**:
    *   **Android**: `android/app/src/main/AndroidManifest.xml`의 패키지 이름과 키 해시를 등록합니다.
    *   **iOS**: `ios/Runner/Info.plist`의 번들 ID를 등록합니다.
    *   *상세한 키 해시 생성 방법 등은 LTS 가이드를 참조하세요.*
2.  **카카오 로그인 활성화**:
    *   "제품 설정" > "카카오 로그인"을 활성화합니다.
    *   **Redirect URI는 설정할 필요가 없습니다.** 네이티브 SDK는 앱의 커스텀 스킴(`kakao{NATIVE_APP_KEY}://oauth`)을 사용하며, 이는 `Info.plist`와 `AndroidManifest.xml`에 설정됩니다.

**Supabase Dashboard**:
1. "Authentication" > "Providers" 메뉴로 이동합니다.
2. "Kakao"를 클릭하고 "Enabled"를 체크합니다.
3. **"Client ID"**에 Kakao 앱의 **네이티브 앱 키**를 입력합니다.
4. **"Client Secret"**은 비워둡니다. (네이티브 로그인에서는 사용되지 않음)
5. "Save"를 클릭합니다.

### 5.2 Naver OAuth 설정 (Edge Function 사용)

**Naver Developers Console**:
1. https://developers.naver.com 접속
2. 내 애플리케이션 선택
3. "API 설정" > "서비스 URL" 추가
4. "Callback URL" 추가
   ```
   # Edge Function에서 사용할 콜백 URL
   https://[project-ref].supabase.co/functions/v1/naver-auth
   ```
5. Client ID, Client Secret 복사 후 Supabase Edge Function의 Secret으로 저장합니다. (상세 내용은 `03_authentication.md` 참조)

### 5.3 체크리스트

- [ ] **(필수)** `flutter_kakao_gorouter_guide.md`에 따라 Android/iOS 네이티브 설정 완료
- [ ] Supabase Dashboard에서 Kakao Provider 활성화 및 네이티브 앱 키 설정 완료
- [ ] Naver Developers Console에서 Callback URL 추가
- [ ] Naver Client ID, Client Secret 저장

---

## 6. 최종 검증

### 6.1 환경 설정 확인

```bash
# 1. .env 파일 존재 확인
cat /Users/pro16/Desktop/project/n06/.env

# 2. Supabase 연결 테스트 (Flutter 앱 실행)
cd /Users/pro16/Desktop/project/n06
flutter run
```

### 6.2 Supabase 연결 테스트 코드

**임시 테스트 화면** (Phase 1.2에서 제거):
```dart
// lib/test_supabase_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/providers.dart';

class TestSupabaseScreen extends ConsumerWidget {
  const TestSupabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Supabase 연결 테스트')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Supabase URL: ${supabase.supabaseUrl}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // 테이블 조회 테스트 (RLS 비활성화 상태에서만 가능)
                  final response = await supabase
                      .from('badge_definitions')
                      .select()
                      .limit(1);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Supabase 연결 성공!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('에러: $e')),
                  );
                }
              },
              child: const Text('연결 테스트'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.3 최종 체크리스트

- [ ] `.env` 파일 정상 로드 확인
- [ ] Supabase 초기화 성공 확인
- [ ] 테이블 조회 테스트 성공
- [ ] OAuth Provider 설정 완료

---

## 7. 다음 단계

✅ Phase 1.1 완료 후:
- **[Phase 1.2: Repository 구현](./02_repository.md)** 문서로 이동하세요.

---

## 트러블슈팅

### 문제 1: Supabase 초기화 실패
**증상**: `Supabase.initialize()` 에러
**해결**:
1. `.env` 파일 존재 확인
2. SUPABASE_URL, SUPABASE_ANON_KEY 정확한지 확인
3. `flutter clean && flutter pub get` 실행

### 문제 2: 테이블 생성 실패
**증상**: SQL 실행 시 에러
**해결**:
1. UUID extension 활성화 확인: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`
2. 테이블 순서대로 실행 (FK 의존성)
3. 기존 테이블 있으면 `DROP TABLE IF EXISTS` 추가

### 문제 3: RLS 정책 적용 안됨
**증상**: 데이터 조회 불가
**해결**:
1. `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` 확인
2. 정책 생성 확인
3. `auth.uid()` 함수 동작 확인 (로그인 상태에서만 동작)

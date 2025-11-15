# Phase 1.6: 배포 및 모니터링

**목표**: 단계적 배포, 모니터링 설정, 롤백 계획

**소요 기간**: 1주

**담당**: DevOps 엔지니어

---

## 1. 배포 전략

### 1.1 단계적 롤아웃

| 단계 | 대상 | 인원 | 기간 | 목표 |
|------|------|------|------|------|
| **알파** | 내부 팀 | 5-10명 | 2일 | 기본 동작 확인 |
| **베타 1** | 얼리어답터 | 50명 | 3일 | 실사용 피드백 |
| **베타 2** | 확대 베타 | 500명 | 5일 | 부하 테스트 |
| **정식 10%** | 전체의 10% | 1,000명 | 3일 | 점진적 확대 |
| **정식 50%** | 전체의 50% | 5,000명 | 3일 | 안정성 확인 |
| **정식 100%** | 전체 | 10,000명 | - | 완전 배포 |

### 1.2 Feature Flag

**목적**: 런타임에 Isar ↔ Supabase 전환 가능

**구현**:
```dart
// lib/core/config/feature_flags.dart

class FeatureFlags {
  static const bool _useSupabaseDefault = true;

  static bool get useSupabase {
    // Firebase Remote Config 또는 환경 변수로 제어
    return _remoteConfig?.getBool('use_supabase') ?? _useSupabaseDefault;
  }

  static RemoteConfig? _remoteConfig;

  static Future<void> initialize() async {
    _remoteConfig = RemoteConfig.instance;
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _remoteConfig!.setDefaults({
      'use_supabase': _useSupabaseDefault,
    });

    await _remoteConfig!.fetchAndActivate();
  }
}

// Provider DI에서 사용
@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  if (FeatureFlags.useSupabase) {
    return SupabaseTrackingRepository(ref.watch(supabaseProvider));
  } else {
    return IsarTrackingRepository(ref.watch(isarProvider)); // 롤백용
  }
}
```

---

## 2. 배포 준비

### 2.1 Firebase Remote Config 설정

**Firebase Console**:
1. Firebase Console 접속
2. "Remote Config" 메뉴
3. 파라미터 추가:
   - 키: `use_supabase`
   - 기본값: `false`
   - 조건: 없음

4. 조건 추가 (단계별 롤아웃):
   - 조건명: `alpha_users`
   - 조건: `User in audience: alpha_testers`
   - 값: `true`

   - 조건명: `beta_users`
   - 조건: `User in audience: beta_testers`
   - 값: `true`

   - 조건명: `rollout_10_percent`
   - 조건: `Percent of users: 10%`
   - 값: `true`

   - 조건명: `rollout_50_percent`
   - 조건: `Percent of users: 50%`
   - 값: `true`

   - 조건명: `rollout_100_percent`
   - 조건: `Percent of users: 100%`
   - 값: `true`

### 2.2 의존성 추가

**파일 위치**: `/Users/pro16/Desktop/project/n06/pubspec.yaml`

**수정 내용**:
```yaml
dependencies:
  # 기존 의존성...

  # Remote Config
  firebase_remote_config: ^4.3.0
```

### 2.3 main.dart 수정

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/main.dart`

**수정 내용**:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/config/feature_flags.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // Feature Flags 초기화
  await FeatureFlags.initialize();

  // Supabase 초기화
  await Supabase.initialize(...);

  runApp(const MyApp());
}
```

---

## 3. 빌드 및 배포

### 3.1 버전 관리

**파일 위치**: `/Users/pro16/Desktop/project/n06/pubspec.yaml`

**버전 업데이트**:
```yaml
version: 1.1.0+11 # Phase 1 릴리스
```

**버전 네이밍**:
- `1.0.0`: Phase 0 (Isar)
- `1.1.0`: Phase 1 (Supabase)
- Build Number: 자동 증가

### 3.2 iOS 빌드

**명령어**:
```bash
cd /Users/pro16/Desktop/project/n06

# Clean
flutter clean
flutter pub get

# Build
flutter build ios --release

# Archive (Xcode에서)
open ios/Runner.xcworkspace
# Product > Archive
# Upload to App Store Connect
```

**App Store Connect**:
1. "TestFlight" 탭
2. "Internal Testing" 그룹 생성: `Phase 1 Alpha`
3. 내부 테스터 추가 (5-10명)
4. 빌드 업로드 및 배포

### 3.3 Android 빌드

**명령어**:
```bash
cd /Users/pro16/Desktop/project/n06

# Build AAB
flutter build appbundle --release

# 또는 APK
flutter build apk --release
```

**Google Play Console**:
1. "Internal testing" 트랙 생성: `Phase 1 Alpha`
2. 테스터 그룹 생성 및 이메일 추가
3. AAB 업로드
4. 릴리스 노트 작성
5. 배포

### 3.4 릴리스 노트

**템플릿**:
```markdown
# Phase 1: 클라우드 동기화 (v1.1.0)

## 새로운 기능
- ✨ 클라우드 백업: 모든 기기에서 데이터 동기화
- ✨ 소셜 로그인: 카카오/네이버 간편 로그인
- ✨ 실시간 업데이트: 데이터 변경 시 즉시 반영

## 개선 사항
- 🚀 성능 향상: 데이터 로딩 속도 30% 개선
- 🔒 보안 강화: RLS 기반 데이터 보호

## 버그 수정
- 🐛 투여 기록 중복 저장 문제 수정
- 🐛 체중 차트 깜빡임 현상 수정

## 주의 사항
- 첫 실행 시 클라우드 백업 필요 (설정 > 클라우드 동기화)
- 기존 로컬 데이터는 자동으로 백업됨

## 알려진 이슈
- 없음

---

**피드백**: support@example.com
```

---

## 4. 모니터링 설정

### 4.1 Supabase Dashboard 모니터링

**접속**: Supabase Dashboard > Project > Metrics

**주요 지표**:
- **Database**:
  - Connection count
  - Disk usage
  - Query performance

- **API**:
  - Requests/minute
  - Error rate
  - Response time (p50, p95, p99)

- **Auth**:
  - Sign-ups/day
  - Active users
  - Session duration

- **Edge Functions** (Naver OAuth):
  - Invocations/minute
  - Error rate
  - Execution time

### 4.2 Firebase Analytics 이벤트

**추적할 이벤트**:
```dart
// lib/core/analytics/analytics_events.dart

class AnalyticsEvents {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // 마이그레이션 이벤트
  static Future<void> trackMigration({
    required String userId,
    required bool success,
    int? recordCount,
    int? durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'migration_completed',
      parameters: {
        'user_id': userId,
        'success': success,
        'record_count': recordCount,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // Repository 에러
  static Future<void> trackRepositoryError({
    required String repository,
    required String method,
    required String error,
  }) async {
    await _analytics.logEvent(
      name: 'repository_error',
      parameters: {
        'repository': repository,
        'method': method,
        'error': error,
      },
    );
  }

  // API 응답 시간
  static Future<void> trackApiPerformance({
    required String endpoint,
    required int durationMs,
  }) async {
    await _analytics.logEvent(
      name: 'api_performance',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': durationMs,
      },
    );
  }

  // Feature Flag 상태
  static Future<void> trackFeatureFlag({
    required String flag,
    required bool enabled,
  }) async {
    await _analytics.logEvent(
      name: 'feature_flag',
      parameters: {
        'flag': flag,
        'enabled': enabled,
      },
    );
  }
}
```

### 4.3 Crashlytics 설정

**에러 리포팅**:
```dart
// lib/core/error_handling/error_reporter.dart

class ErrorReporter {
  static Future<void> reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    // Crashlytics 리포팅
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: context,
    );

    // 로그 출력 (개발 모드)
    if (kDebugMode) {
      print('Error: $error');
      print('StackTrace: $stackTrace');
    }
  }

  static Future<void> setUserIdentifier(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }
}

// Repository에서 사용
try {
  await _supabase.from('weight_logs').insert(data);
} catch (e, stackTrace) {
  await ErrorReporter.reportError(
    e,
    stackTrace,
    context: 'SupabaseTrackingRepository.saveWeightLog',
  );
  rethrow;
}
```

### 4.4 Custom Metrics

**Supabase Functions (PostgreSQL)**:
```sql
-- 마이그레이션 완료율 추적
CREATE OR REPLACE FUNCTION get_migration_stats()
RETURNS TABLE(
  total_users BIGINT,
  migrated_users BIGINT,
  migration_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) AS total_users,
    COUNT(migration_completed_at) AS migrated_users,
    ROUND(COUNT(migration_completed_at)::NUMERIC / COUNT(*)::NUMERIC * 100, 2) AS migration_rate
  FROM users;
END;
$$ LANGUAGE plpgsql;

-- 일별 활성 사용자 (DAU)
CREATE OR REPLACE FUNCTION get_dau(date_param DATE)
RETURNS BIGINT AS $$
BEGIN
  RETURN (
    SELECT COUNT(DISTINCT user_id)
    FROM (
      SELECT user_id FROM weight_logs WHERE DATE(created_at) = date_param
      UNION
      SELECT user_id FROM symptom_logs WHERE DATE(created_at) = date_param
      UNION
      SELECT user_id FROM dose_records WHERE DATE(created_at) = date_param
    ) AS active_users
  );
END;
$$ LANGUAGE plpgsql;
```

---

## 5. 단계별 배포 실행

### 5.1 알파 테스트 (2일)

**대상**: 내부 팀 (5-10명)

**작업**:
1. Firebase Remote Config에서 `alpha_users` 조건 활성화
2. 내부 테스터에게 TestFlight/Internal Testing 링크 공유
3. 피드백 수집 (Slack 채널)
4. 크리티컬 버그 수정

**체크리스트**:
- [ ] 모든 기능 동작 확인
- [ ] 마이그레이션 성공률 100%
- [ ] 크래시 0건
- [ ] 성능 지표 목표 달성

### 5.2 베타 1 (3일)

**대상**: 얼리어답터 (50명)

**작업**:
1. Firebase Remote Config에서 `beta_users` 조건 활성화
2. 베타 테스터 모집 (이메일, 커뮤니티)
3. 설문조사 실시 (Google Forms)
4. 버그 수정

**체크리스트**:
- [ ] 마이그레이션 성공률 > 95%
- [ ] 크래시율 < 0.1%
- [ ] 평균 API 응답 시간 < 500ms
- [ ] 사용자 만족도 > 4.0/5.0

### 5.3 베타 2 (5일)

**대상**: 확대 베타 (500명)

**작업**:
1. 베타 테스터 확대 모집
2. 부하 테스트 (동시 접속 증가)
3. 성능 모니터링 강화
4. 버그 수정

**체크리스트**:
- [ ] 마이그레이션 성공률 > 95%
- [ ] 크래시율 < 0.1%
- [ ] Supabase 응답 시간 안정
- [ ] Database connection pool 안정

### 5.4 정식 10% (3일)

**작업**:
1. Firebase Remote Config에서 `rollout_10_percent` 활성화
2. 모니터링 집중 (24시간 On-call)
3. 에러 알림 설정 (Slack, Email)

**체크리스트**:
- [ ] 마이그레이션 성공률 > 95%
- [ ] 크래시율 < 0.1%
- [ ] 사용자 이탈률 < 5%
- [ ] Supabase 과금 예상 범위 내

### 5.5 정식 50% (3일)

**작업**:
1. Firebase Remote Config에서 `rollout_50_percent` 활성화
2. 부하 분산 확인
3. 비용 모니터링

**체크리스트**:
- [ ] 모든 지표 안정적
- [ ] 지원 요청 < 10건/일
- [ ] Supabase Pro Plan 범위 내

### 5.6 정식 100% (최종)

**작업**:
1. Firebase Remote Config에서 `rollout_100_percent` 활성화
2. 공식 릴리스 공지
3. 지속적 모니터링

---

## 6. 롤백 계획

### 6.1 롤백 트리거

다음 상황 시 즉시 롤백:
- 크래시율 > 1%
- 마이그레이션 실패율 > 10%
- API 응답 시간 > 2초 (지속적)
- Supabase 장애
- 데이터 손실 발생

### 6.2 롤백 절차

**1단계: Feature Flag 비활성화**
```
Firebase Remote Config > use_supabase = false
```

**2단계: 앱 재시작 유도**
```dart
// 앱 내 알림
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => AlertDialog(
    title: Text('업데이트 필요'),
    content: Text('앱을 재시작해주세요.'),
    actions: [
      TextButton(
        onPressed: () {
          // 앱 재시작
          Phoenix.rebirth(context);
        },
        child: Text('재시작'),
      ),
    ],
  ),
);
```

**3단계: Isar로 전환 확인**
- 모든 Repository가 `IsarXxxRepository` 사용
- 로컬 데이터 정상 동작

**4단계: 사후 분석**
- 롤백 원인 파악
- 버그 수정
- 재배포 계획

### 6.3 롤백 테스트

**주기적 롤백 훈련**:
- 월 1회 롤백 시뮬레이션
- 롤백 소요 시간 측정 (목표: 5분 이내)

---

## 7. 배포 체크리스트

### 7.1 배포 전

- [ ] 모든 테스트 통과 (Phase 1.5)
- [ ] 코드 리뷰 완료
- [ ] 릴리스 노트 작성
- [ ] Firebase Remote Config 설정
- [ ] Staging 환경 테스트
- [ ] 롤백 계획 수립

### 7.2 배포 중

- [ ] 빌드 업로드 (iOS/Android)
- [ ] TestFlight/Internal Testing 배포
- [ ] 알파 테스트 완료
- [ ] 베타 테스트 완료
- [ ] 단계적 롤아웃 진행

### 7.3 배포 후

- [ ] 모니터링 대시보드 확인
- [ ] 에러 알림 설정
- [ ] 사용자 피드백 수집
- [ ] 성능 지표 추적
- [ ] 비용 모니터링

---

## 8. 다음 단계

✅ Phase 1.6 완료 후:
- **[Phase 1.7: 안정화 기간](./07_stabilization.md)** 문서로 이동하세요.

---

## 트러블슈팅

### 문제 1: Firebase Remote Config 적용 안됨
**증상**: Feature Flag 변경 후에도 Isar 사용
**해결**:
1. Remote Config fetch 간격 확인 (최소 1시간)
2. 강제 fetch: `await _remoteConfig!.fetchAndActivate()`
3. 앱 재시작

### 문제 2: 단계적 롤아웃 정확도
**증상**: 10% 롤아웃인데 더 많은 사용자에게 적용
**해결**: Firebase Remote Config의 "Percent of users" 조건 확인

### 문제 3: Supabase 비용 초과
**증상**: 예상보다 높은 과금
**해결**:
1. Database 쿼리 최적화
2. Bandwidth 사용량 확인 (대용량 데이터 전송 제한)
3. Edge Functions 실행 횟수 확인

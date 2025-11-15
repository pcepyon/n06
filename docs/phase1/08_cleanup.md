# Phase 1.8: Isar 완전 제거

**목표**: IsarDB 관련 코드 완전 제거, 최종 배포

**소요 기간**: 1주

**담당**: Backend 엔지니어

---

## 1. 제거 전 최종 확인

### 1.1 제거 조건 확인

**필수 조건 (모두 체크)**:
- [ ] Phase 1.7 안정화 기간 완료 (4주)
- [ ] 마이그레이션 완료율 ≥ 95%
- [ ] 4주간 크래시율 < 0.1%
- [ ] 4주간 에러율 < 0.1%
- [ ] 데이터 무결성 100% 검증
- [ ] 롤백 필요 없음 확인
- [ ] Supabase 운영 안정

**경고**: 위 조건이 하나라도 미충족 시 제거 연기 필요

### 1.2 사용자 공지

**앱 내 공지 (제거 1주 전)**:
```
📢 시스템 업데이트 안내

더 안정적인 서비스 제공을 위해 시스템을 업데이트합니다.

- 일시: YYYY-MM-DD
- 영향: 없음 (정상 이용 가능)
- 변경사항: 클라우드 동기화 최적화

※ 클라우드 백업을 완료하지 않으신 분은
  업데이트 전에 꼭 백업해주세요!

[백업하러 가기]
```

---

## 2. Isar 제거 작업

### 2.1 코드 제거 순서

**순서 중요**: 역순으로 제거

```
1. Providers (DI) 수정
2. Isar Repository 구현체 삭제
3. Isar DTO 삭제
4. Isar 초기화 코드 삭제
5. Isar 의존성 제거
6. Build Runner 재실행
```

---

## 3. 단계별 제거 작업

### 3.1 Step 1: Providers 수정

**목적**: Supabase Repository만 사용하도록 변경

**수정할 파일 목록**:

#### 1. Authentication
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/authentication/application/providers.dart`

**Before**:
```dart
import '../infrastructure/repositories/isar_auth_repository.dart';
import '../infrastructure/repositories/supabase_auth_repository.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  if (FeatureFlags.useSupabase) {
    final supabase = ref.watch(supabaseProvider);
    return SupabaseAuthRepository(supabase);
  } else {
    final isar = ref.watch(isarProvider);
    return IsarAuthRepository(isar);
  }
}
```

**After**:
```dart
import '../infrastructure/repositories/supabase_auth_repository.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuthRepository(supabase);
}
```

#### 2. Onboarding
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/onboarding/application/providers.dart`

**수정 내용**: 동일하게 Isar 관련 import 및 분기 제거

#### 3. Tracking
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/application/providers.dart`

**수정 내용**: 6개 Repository 모두 Supabase만 사용

#### 4. Dashboard, Notification, Coping Guide, Data Sharing
**각 Feature의 `providers.dart`에서 동일하게 수정**

**체크리스트**:
- [ ] `lib/features/authentication/application/providers.dart` 수정
- [ ] `lib/features/onboarding/application/providers.dart` 수정
- [ ] `lib/features/tracking/application/providers.dart` 수정
- [ ] `lib/features/dashboard/application/providers.dart` 수정
- [ ] `lib/features/notification/application/providers.dart` 수정
- [ ] `lib/features/coping_guide/application/providers.dart` 수정
- [ ] `lib/features/data_sharing/application/providers.dart` 수정

---

### 3.2 Step 2: Isar Repository 구현체 삭제

**삭제할 파일 목록** (13개):

```bash
# Authentication
rm /Users/pro16/Desktop/project/n06/lib/features/authentication/infrastructure/repositories/isar_auth_repository.dart

# Onboarding
rm /Users/pro16/Desktop/project/n06/lib/features/onboarding/infrastructure/repositories/isar_profile_repository.dart
rm /Users/pro16/Desktop/project/n06/lib/features/onboarding/infrastructure/repositories/isar_user_repository.dart

# Tracking
rm /Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart
rm /Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/isar_dosage_plan_repository.dart
rm /Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart
rm /Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/isar_tracking_repository.dart
rm /Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/isar_emergency_check_repository.dart
rm /Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/isar_audit_repository.dart

# Dashboard
rm /Users/pro16/Desktop/project/n06/lib/features/dashboard/infrastructure/repositories/isar_badge_repository.dart

# Notification
rm /Users/pro16/Desktop/project/n06/lib/features/notification/infrastructure/repositories/isar_notification_repository.dart

# Coping Guide
rm /Users/pro16/Desktop/project/n06/lib/features/coping_guide/infrastructure/repositories/isar_feedback_repository.dart

# Data Sharing
rm /Users/pro16/Desktop/project/n06/lib/features/data_sharing/infrastructure/repositories/isar_shared_data_repository.dart
```

**실행**:
```bash
cd /Users/pro16/Desktop/project/n06
find lib/features/*/infrastructure/repositories -name "isar_*_repository.dart" -delete
```

**체크리스트**:
- [ ] 13개 Isar Repository 파일 삭제 완료

---

### 3.3 Step 3: Isar DTO 삭제

**중요**: DTO는 Supabase에서도 사용하므로 **Isar 어노테이션만 제거**

**수정할 파일 예시** (17개 DTO):

#### WeightLogDto
**파일**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/dtos/weight_log_dto.dart`

**Before**:
```dart
import 'package:isar/isar.dart';

part 'weight_log_dto.g.dart';

@collection
class WeightLogDto {
  Id id = Isar.autoIncrement;
  late String userId;
  // ...
}
```

**After**:
```dart
// Isar import 제거
// part 제거
// @collection 제거
// Id -> String id

class WeightLogDto {
  final String id;
  final String userId;
  // ...

  // fromJson, toJson 유지
  // toEntity, fromEntity 유지
}
```

**반복 작업**: 17개 DTO 모두 동일하게 수정

**또는 자동화 스크립트**:
```bash
# Isar 어노테이션 제거 스크립트 (주의: 백업 후 실행)
find lib/features/*/infrastructure/dtos -name "*_dto.dart" -exec sed -i '' '/import.*isar/d; /part.*\.g\.dart/d; /@collection/d; s/Id id = Isar.autoIncrement/String id/' {} \;
```

**체크리스트**:
- [ ] 17개 DTO 파일에서 Isar 어노테이션 제거
- [ ] `part '..._dto.g.dart';` 제거
- [ ] `@collection` 제거
- [ ] `Id id = Isar.autoIncrement` → `String id` 변경

---

### 3.4 Step 4: Isar 초기화 코드 삭제

**파일 1**: `/Users/pro16/Desktop/project/n06/lib/main.dart`

**Before**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Isar 초기화 (삭제)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    UserDtoSchema,
    WeightLogDtoSchema,
    // ...
  ], directory: dir.path);

  // Supabase 초기화 (유지)
  await Supabase.initialize(...);

  runApp(ProviderScope(
    overrides: [
      isarProvider.overrideWithValue(isar), // 삭제
    ],
    child: const MyApp(),
  ));
}
```

**After**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(...);

  // Feature Flags 초기화
  await FeatureFlags.initialize();

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}
```

**파일 2**: `/Users/pro16/Desktop/project/n06/lib/core/providers.dart`

**Before**:
```dart
@Riverpod(keepAlive: true)
Isar isar(IsarRef ref) {
  throw UnimplementedError('Override in main.dart');
}

@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}
```

**After**:
```dart
// isarProvider 제거

@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}
```

**체크리스트**:
- [ ] `lib/main.dart`에서 Isar 초기화 코드 삭제
- [ ] `lib/core/providers.dart`에서 `isarProvider` 삭제

---

### 3.5 Step 5: Isar 의존성 제거

**파일**: `/Users/pro16/Desktop/project/n06/pubspec.yaml`

**Before**:
```yaml
dependencies:
  # Local Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

  # Supabase
  supabase_flutter: ^2.0.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.0
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.3.0
```

**After**:
```yaml
dependencies:
  # Supabase
  supabase_flutter: ^2.0.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

**실행**:
```bash
cd /Users/pro16/Desktop/project/n06
flutter pub get
```

**체크리스트**:
- [ ] `pubspec.yaml`에서 Isar 의존성 제거 (3개)
- [ ] `flutter pub get` 실행 성공

---

### 3.6 Step 6: Build Runner 재실행

**목적**: Isar 관련 생성 파일 제거

**명령어**:
```bash
cd /Users/pro16/Desktop/project/n06

# 기존 생성 파일 삭제
flutter clean

# Pub get
flutter pub get

# Code generation (Riverpod만)
flutter pub run build_runner build --delete-conflicting-outputs
```

**삭제되는 파일**:
- `lib/features/*/infrastructure/dtos/*_dto.g.dart` (Isar 생성 파일)

**유지되는 파일**:
- `lib/features/*/application/providers.g.dart` (Riverpod 생성 파일)
- `lib/features/*/application/notifiers/*_notifier.g.dart` (Riverpod 생성 파일)

**체크리스트**:
- [ ] `flutter clean` 실행
- [ ] `build_runner` 재실행
- [ ] Isar 관련 `.g.dart` 파일 모두 삭제됨
- [ ] Riverpod `.g.dart` 파일 정상 생성됨

---

### 3.7 Step 7: Feature Flag 제거

**파일**: `/Users/pro16/Desktop/project/n06/lib/core/config/feature_flags.dart`

**Before**:
```dart
class FeatureFlags {
  static bool get useSupabase {
    return _remoteConfig?.getBool('use_supabase') ?? true;
  }
}
```

**After**:
```dart
// 파일 전체 삭제 또는
class FeatureFlags {
  // useSupabase 제거 (항상 true이므로 불필요)
}
```

**Provider에서 Feature Flag 사용 제거**:
```dart
// Before
if (FeatureFlags.useSupabase) {
  return SupabaseTrackingRepository(supabase);
} else {
  return IsarTrackingRepository(isar);
}

// After
return SupabaseTrackingRepository(supabase);
```

**Firebase Remote Config 정리**:
- `use_supabase` 파라미터 삭제 (선택적)

**체크리스트**:
- [ ] Feature Flag 관련 코드 제거
- [ ] Firebase Remote Config 정리 (선택적)

---

## 4. 테스트 및 검증

### 4.1 빌드 테스트

```bash
cd /Users/pro16/Desktop/project/n06

# Analyze
flutter analyze

# Test
flutter test

# Build iOS
flutter build ios --release

# Build Android
flutter build appbundle --release
```

**기대 결과**:
- 모든 테스트 통과
- 빌드 에러 0개
- Warning 0개 (Isar 관련 경고 사라짐)

### 4.2 기능 테스트

**테스트 시나리오**:
1. 로그인 (카카오/네이버/이메일)
2. 온보딩 (목표 설정, 투여 계획)
3. 데이터 기록 (체중, 증상, 투여)
4. 데이터 조회 (홈 대시보드, 차트)
5. 데이터 수정/삭제
6. 로그아웃/재로그인 (데이터 유지 확인)

**체크리스트**:
- [ ] 모든 기능 정상 동작
- [ ] 데이터 손실 없음
- [ ] Supabase만 사용 확인

### 4.3 성능 테스트

**벤치마크**:
```dart
final stopwatch = Stopwatch()..start();

// Weight logs 조회
await repository.getWeightLogs(userId);
final t1 = stopwatch.elapsedMilliseconds;

// Symptom logs 조회
await repository.getSymptomLogs(userId);
final t2 = stopwatch.elapsedMilliseconds - t1;

stopwatch.stop();

print('Performance: WeightLogs=${t1}ms, SymptomLogs=${t2}ms');
```

**목표**: Phase 1.7과 동일 또는 개선

---

## 5. 배포

### 5.1 버전 업데이트

**파일**: `/Users/pro16/Desktop/project/n06/pubspec.yaml`

```yaml
version: 1.2.0+12 # Isar 제거 버전
```

### 5.2 릴리스 노트

```markdown
# v1.2.0: 시스템 최적화

## 개선 사항
- 🚀 성능 최적화: 앱 크기 30% 감소, 속도 향상
- 🔧 시스템 안정화: 불필요한 라이브러리 제거

## 버그 수정
- 없음

## 주의 사항
- 없음 (기존 사용자 영향 없음)

---

**피드백**: support@example.com
```

### 5.3 배포 전략

**점진적 롤아웃** (동일):
1. Internal Testing (2일)
2. Beta Testing (3일)
3. 10% → 50% → 100% (각 2일)

**모니터링 강화**:
- 첫 주는 매일 지표 확인
- 크래시/에러 즉시 대응

---

## 6. 최종 확인

### 6.1 코드 정리 체크리스트

- [ ] Isar Repository 구현체 모두 삭제 (13개)
- [ ] Isar DTO 어노테이션 모두 제거 (17개)
- [ ] Isar 초기화 코드 삭제
- [ ] Isar Provider 삭제
- [ ] Isar 의존성 제거 (pubspec.yaml)
- [ ] Isar 생성 파일 삭제 (`.g.dart`)
- [ ] Feature Flag 정리
- [ ] 모든 Provider에서 Isar 분기 제거

### 6.2 기능 검증 체크리스트

- [ ] 로그인/로그아웃 정상
- [ ] 온보딩 정상
- [ ] 데이터 CRUD 정상
- [ ] 마이그레이션 UI 제거 (더 이상 불필요)
- [ ] 성능 저하 없음
- [ ] 데이터 손실 없음

### 6.3 배포 체크리스트

- [ ] 버전 업데이트
- [ ] 릴리스 노트 작성
- [ ] 빌드 성공 (iOS/Android)
- [ ] 테스트 통과
- [ ] Internal Testing 완료
- [ ] 정식 배포 완료

---

## 7. 완료

### 7.1 Phase 1 완료 선언

**조건**:
- [ ] Isar 완전 제거 완료
- [ ] 배포 완료 (100%)
- [ ] 1주일 안정적 운영
- [ ] 사용자 피드백 긍정적

**Phase 1 종료 공지**:
```
🎉 Phase 1: 클라우드 동기화 완료!

모든 사용자가 안전하게 클라우드 동기화를 사용하고 계십니다.
앞으로도 더 나은 서비스로 보답하겠습니다.

감사합니다!
```

### 7.2 Phase 2 준비

**Phase 2 계획**:
- 오프라인 모드 (로컬 캐싱 + 자동 동기화)
- 실시간 동기화 (Supabase Realtime)
- 다중 기기 지원
- 데이터 분석 및 인사이트
- PDF/CSV 리포트 생성

---

## 8. 문서 아카이브

### 8.1 문서 정리

**보관**:
- `docs/phase1/` 전체 디렉토리 유지
- 향후 참고용

**README 업데이트**:
```markdown
# GLP-1 MVP

## Phase History

- **Phase 0** (완료): Isar 로컬 DB
- **Phase 1** (완료): Supabase 클라우드 동기화
- **Phase 2** (진행 예정): 오프라인 모드, 실시간 동기화
```

---

## 9. 축하합니다! 🎉

**Phase 1 Supabase 마이그레이션 완료**

- ✅ IsarDB 완전 제거
- ✅ Supabase 100% 전환
- ✅ 데이터 무결성 보장
- ✅ 성능 개선
- ✅ 비용 최적화

**팀 회고**:
- 잘한 점
- 개선할 점
- 배운 점
- 다음 Phase 준비

---

**수고하셨습니다!** 🚀

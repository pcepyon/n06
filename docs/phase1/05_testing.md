# Phase 1.5: 테스트 및 검증

**목표**: Supabase 통합 테스트, 성능 검증, QA

**소요 기간**: 1주

**담당**: QA 엔지니어 × 2명

---

## 1. 테스트 전략

### 1.1 테스트 레벨

| 레벨 | 범위 | 도구 | 담당자 |
|------|------|------|--------|
| **단위 테스트** | Repository 메서드 | mocktail | 개발자 |
| **통합 테스트** | Repository + Supabase | 실제 Supabase | QA |
| **E2E 테스트** | 전체 플로우 | patrol | QA |
| **성능 테스트** | API 응답 시간, 처리량 | benchmark | QA |

### 1.2 테스트 환경

**Staging 환경**:
- Supabase Project: `glp1-mvp-staging`
- Database: 테스트 데이터
- RLS: 활성화
- Edge Functions: 배포됨

---

## 2. 단위 테스트

### 2.1 Repository 단위 테스트

**파일 위치**: `/Users/pro16/Desktop/project/n06/test/features/tracking/infrastructure/repositories/supabase_tracking_repository_test.dart`

**예시**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late MockSupabaseClient mockSupabase;
  late SupabaseTrackingRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = SupabaseTrackingRepository(mockSupabase);
  });

  group('getWeightLogs', () {
    test('should return list of weight logs', () async {
      // Arrange
      final mockBuilder = MockSupabaseQueryBuilder();
      when(() => mockSupabase.from('weight_logs')).thenReturn(mockBuilder);
      when(() => mockBuilder.select()).thenReturn(mockBuilder);
      when(() => mockBuilder.eq('user_id', any())).thenReturn(mockBuilder);
      when(() => mockBuilder.order('log_date', ascending: false))
          .thenAnswer((_) async => [
                {
                  'id': 'test-id',
                  'user_id': 'user1',
                  'log_date': '2024-01-01',
                  'weight_kg': 70.0,
                  'created_at': '2024-01-01T00:00:00Z',
                }
              ]);

      // Act
      final result = await repository.getWeightLogs('user1');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.weightKg, 70.0);
      expect(result.first.userId, 'user1');
    });

    test('should throw exception on error', () async {
      // Arrange
      when(() => mockSupabase.from('weight_logs'))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getWeightLogs('user1'),
        throwsException,
      );
    });
  });

  group('saveWeightLog', () {
    test('should call upsert with correct data', () async {
      // Arrange
      final mockBuilder = MockSupabaseQueryBuilder();
      final weightLog = WeightLog(
        id: 'test-id',
        userId: 'user1',
        logDate: DateTime(2024, 1, 1),
        weightKg: 70.0,
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockSupabase.from('weight_logs')).thenReturn(mockBuilder);
      when(() => mockBuilder.upsert(any(), onConflict: any(named: 'onConflict')))
          .thenAnswer((_) async => []);

      // Act
      await repository.saveWeightLog(weightLog);

      // Assert
      verify(() => mockBuilder.upsert(
        any(that: containsPair('user_id', 'user1')),
        onConflict: 'user_id,log_date',
      )).called(1);
    });
  });
}
```

### 2.2 단위 테스트 체크리스트

**각 Repository별로 테스트**:

#### Authentication
- [ ] `loginWithKakao()` 성공/실패
- [ ] `loginWithEmail()` 성공/실패
- [ ] `logout()` 성공
- [ ] `getCurrentUser()` null/non-null

#### Tracking
- [ ] `getWeightLogs()` 빈 리스트/데이터 존재
- [ ] `saveWeightLog()` upsert 호출 확인
- [ ] `deleteWeightLog()` delete 호출 확인
- [ ] `getSymptomLogs()` context_tags 포함
- [ ] `saveSymptomLog()` 트랜잭션 처리

#### Dashboard
- [ ] `getBadgeDefinitions()` 정적 데이터 조회
- [ ] `getUserBadges()` 진행도 계산
- [ ] `updateBadgeProgress()` 업데이트 확인

**실행**:
```bash
cd /Users/pro16/Desktop/project/n06
flutter test test/features/*/infrastructure/repositories/supabase_*_test.dart
```

---

## 3. 통합 테스트

### 3.1 Supabase 통합 테스트

**파일 위치**: `/Users/pro16/Desktop/project/n06/integration_test/supabase_integration_test.dart`

**테스트 시나리오**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n06/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseClient supabase;
  late String testUserId;

  setUpAll(() async {
    // Supabase 초기화 (Staging 환경)
    await Supabase.initialize(
      url: 'https://staging-project-ref.supabase.co',
      anonKey: 'staging-anon-key',
    );
    supabase = Supabase.instance.client;

    // 테스트 사용자 생성
    final authResponse = await supabase.auth.signUp(
      email: 'test-${DateTime.now().millisecondsSinceEpoch}@example.com',
      password: 'test1234!',
    );
    testUserId = authResponse.user!.id;
  });

  tearDownAll(() async {
    // 테스트 데이터 정리
    await supabase.from('users').delete().eq('id', testUserId);
    await supabase.auth.signOut();
  });

  group('Weight Logs Integration', () {
    testWidgets('should save and retrieve weight log', (tester) async {
      // 1. Weight log 저장
      final weightLog = {
        'user_id': testUserId,
        'log_date': '2024-01-15',
        'weight_kg': 70.5,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('weight_logs').insert(weightLog);

      // 2. 조회
      final response = await supabase
          .from('weight_logs')
          .select()
          .eq('user_id', testUserId)
          .single();

      // 3. 검증
      expect(response['weight_kg'], 70.5);
      expect(response['log_date'], '2024-01-15');
    });

    testWidgets('should enforce UNIQUE constraint', (tester) async {
      // 1. 같은 날짜 중복 저장 시도
      final weightLog = {
        'user_id': testUserId,
        'log_date': '2024-01-16',
        'weight_kg': 71.0,
      };

      await supabase.from('weight_logs').insert(weightLog);

      // 2. upsert로 업데이트
      await supabase.from('weight_logs').upsert({
        ...weightLog,
        'weight_kg': 72.0,
      }, onConflict: 'user_id,log_date');

      // 3. 검증 (업데이트됨)
      final response = await supabase
          .from('weight_logs')
          .select()
          .eq('user_id', testUserId)
          .eq('log_date', '2024-01-16')
          .single();

      expect(response['weight_kg'], 72.0);
    });
  });

  group('RLS Policies', () {
    testWidgets('should prevent access to other users data', (tester) async {
      // 1. 다른 사용자 생성
      final otherUserResponse = await supabase.auth.signUp(
        email: 'other-test-${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'test1234!',
      );
      final otherUserId = otherUserResponse.user!.id;

      // 2. 다른 사용자로 로그인
      await supabase.auth.signInWithPassword(
        email: otherUserResponse.user!.email!,
        password: 'test1234!',
      );

      // 3. 첫 번째 사용자 데이터 조회 시도
      final response = await supabase
          .from('weight_logs')
          .select()
          .eq('user_id', testUserId);

      // 4. 검증 (RLS로 인해 빈 배열 반환)
      expect(response, isEmpty);
    });
  });

  group('Symptom Logs with Tags', () {
    testWidgets('should save symptom log with context tags', (tester) async {
      // 1. Symptom log 저장
      final symptomLogResponse = await supabase.from('symptom_logs').insert({
        'user_id': testUserId,
        'log_date': '2024-01-15',
        'symptom_name': '메스꺼움',
        'severity': 7,
      }).select().single();

      final symptomLogId = symptomLogResponse['id'];

      // 2. Context tags 저장
      await supabase.from('symptom_context_tags').insert([
        {'symptom_log_id': symptomLogId, 'tag_name': '#기름진음식'},
        {'symptom_log_id': symptomLogId, 'tag_name': '#과식'},
      ]);

      // 3. 조회 (tags 포함)
      final response = await supabase
          .from('symptom_logs')
          .select('*, symptom_context_tags(*)')
          .eq('id', symptomLogId)
          .single();

      // 4. 검증
      expect(response['symptom_context_tags'], hasLength(2));
      expect(response['symptom_context_tags'][0]['tag_name'], '#기름진음식');
    });
  });
}
```

### 3.2 통합 테스트 실행

```bash
cd /Users/pro16/Desktop/project/n06
flutter test integration_test/supabase_integration_test.dart
```

### 3.3 통합 테스트 체크리스트

- [ ] Weight logs CRUD
- [ ] Symptom logs + context tags
- [ ] Dosage plans + schedules + records
- [ ] User badges 진행도 계산
- [ ] RLS 정책 동작 확인
- [ ] UNIQUE 제약 동작 확인
- [ ] FK CASCADE DELETE 동작 확인

---

## 4. E2E 테스트

### 4.1 E2E 시나리오

**파일 위치**: `/Users/pro16/Desktop/project/n06/integration_test/e2e_test.dart`

**시나리오 1: 신규 사용자 온보딩 → 데이터 기록**:
```dart
testWidgets('New user onboarding and data logging', (tester) async {
  // 1. 앱 실행
  app.main();
  await tester.pumpAndSettle();

  // 2. 카카오 로그인 (Mocked)
  await tester.tap(find.text('카카오 로그인'));
  await tester.pumpAndSettle();

  // 3. 온보딩: 목표 설정
  await tester.enterText(find.byKey(const Key('target_weight')), '65');
  await tester.enterText(find.byKey(const Key('current_weight')), '70');
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();

  // 4. 온보딩: 투여 계획
  await tester.enterText(find.byKey(const Key('medication_name')), 'Ozempic');
  await tester.enterText(find.byKey(const Key('initial_dose')), '0.25');
  await tester.tap(find.text('완료'));
  await tester.pumpAndSettle();

  // 5. 홈 화면 진입 확인
  expect(find.text('홈'), findsOneWidget);

  // 6. 체중 기록
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.tap(find.text('체중 기록'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('weight_input')), '69.5');
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // 7. Supabase에서 데이터 확인
  final response = await supabase
      .from('weight_logs')
      .select()
      .eq('user_id', testUserId)
      .single();

  expect(response['weight_kg'], 69.5);
});
```

**시나리오 2: 데이터 마이그레이션**:
```dart
testWidgets('Data migration from Isar to Supabase', (tester) async {
  // 1. Isar에 데이터 생성 (기존 사용자 시뮬레이션)
  // ... Isar에 weight_logs, symptom_logs 등 생성

  // 2. 마이그레이션 화면 진입
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  await tester.tap(find.text('클라우드 동기화'));
  await tester.pumpAndSettle();

  // 3. 마이그레이션 시작
  await tester.tap(find.text('백업 시작'));
  await tester.pumpAndSettle(const Duration(seconds: 30)); // 최대 30초 대기

  // 4. 성공 메시지 확인
  expect(find.text('백업 완료'), findsOneWidget);

  // 5. Supabase에서 데이터 검증
  // ... 레코드 수, 값 일치 확인
});
```

### 4.2 E2E 테스트 실행

```bash
cd /Users/pro16/Desktop/project/n06
flutter test integration_test/e2e_test.dart
```

### 4.3 E2E 테스트 체크리스트

- [ ] 신규 사용자 온보딩 플로우
- [ ] 로그인/로그아웃 플로우
- [ ] 데이터 기록 (체중, 증상, 투여)
- [ ] 데이터 조회 (홈 대시보드)
- [ ] 데이터 마이그레이션
- [ ] 데이터 공유 모드
- [ ] 증상 체크

---

## 5. 성능 테스트

### 5.1 API 응답 시간 테스트

**목표**: 평균 500ms 이하

**테스트 코드**:
```dart
test('getWeightLogs should complete within 500ms', () async {
  final stopwatch = Stopwatch()..start();

  await repository.getWeightLogs('test-user-id');

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
});

test('saveWeightLog should complete within 500ms', () async {
  final stopwatch = Stopwatch()..start();

  await repository.saveWeightLog(testWeightLog);

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
});
```

### 5.2 부하 테스트

**도구**: Apache JMeter 또는 k6

**시나리오**:
- 동시 사용자: 100명
- 요청 수: 1000개/분
- 테스트 기간: 10분

**실행**:
```bash
# k6 예시
k6 run --vus 100 --duration 10m load_test.js
```

**측정 지표**:
- 평균 응답 시간
- 95th percentile 응답 시간
- 에러율
- 처리량 (requests/sec)

### 5.3 성능 체크리스트

- [ ] API 응답 시간 < 500ms (평균)
- [ ] API 응답 시간 < 1000ms (95th percentile)
- [ ] 에러율 < 0.1%
- [ ] 처리량 > 100 req/sec
- [ ] Database connection pool 안정

---

## 6. QA 체크리스트

### 6.1 기능 테스트

**Authentication**:
- [ ] 카카오 로그인 성공
- [ ] 네이버 로그인 성공
- [ ] Email 회원가입/로그인 성공
- [ ] 로그아웃 성공
- [ ] 자동 로그인 동작

**Onboarding**:
- [ ] 목표 설정 저장
- [ ] 투여 계획 저장
- [ ] 온보딩 완료 후 홈 이동

**Tracking**:
- [ ] 체중 기록 저장/조회/수정/삭제
- [ ] 증상 기록 저장/조회/수정/삭제 (context tags 포함)
- [ ] 투여 기록 저장/조회/삭제
- [ ] 스케줄 자동 생성

**Dashboard**:
- [ ] 주간 목표 진행도 표시
- [ ] 체중 추이 차트
- [ ] 증상 발생 패턴
- [ ] 뱃지 획득/진행도

**Data Sharing**:
- [ ] 공유 모드 활성화
- [ ] 읽기 전용 UI
- [ ] 기간 선택
- [ ] 공유 모드 종료

**Migration**:
- [ ] 마이그레이션 성공
- [ ] 데이터 무결성 확인
- [ ] 롤백 가능

### 6.2 보안 테스트

- [ ] RLS 정책 동작 (다른 사용자 데이터 접근 차단)
- [ ] JWT 토큰 검증
- [ ] HTTPS 통신 (MITM 공격 방지)
- [ ] SQL Injection 방지
- [ ] XSS 방지

### 6.3 호환성 테스트

**iOS**:
- [ ] iOS 14, 15, 16, 17
- [ ] iPhone SE, 13, 14, 15 Pro

**Android**:
- [ ] Android 10, 11, 12, 13, 14
- [ ] Galaxy S21, S22, Pixel 6, 7

---

## 7. 버그 리포팅

### 7.1 버그 리포트 템플릿

```markdown
## 버그 제목
[간단한 한 줄 설명]

## 재현 단계
1. ...
2. ...
3. ...

## 예상 동작
[예상했던 동작]

## 실제 동작
[실제로 발생한 동작]

## 스크린샷
[스크린샷 첨부]

## 환경
- 기기: iPhone 15 Pro
- OS: iOS 17.0
- 앱 버전: 1.0.0 (Phase 1 Beta)

## 재현율
[항상 / 가끔 / 드물게]

## 심각도
[Critical / High / Medium / Low]

## 로그
[관련 로그 첨부]
```

---

## 8. 테스트 결과 리포트

### 8.1 테스트 커버리지

```bash
# Flutter 테스트 커버리지
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**목표**: 80% 이상

### 8.2 테스트 결과 요약

**템플릿**:
```markdown
# Phase 1.5 테스트 결과

## 테스트 통계
- 단위 테스트: 120개 / 120개 통과 (100%)
- 통합 테스트: 30개 / 30개 통과 (100%)
- E2E 테스트: 15개 / 15개 통과 (100%)
- 성능 테스트: 통과 (평균 350ms)

## 커버리지
- 전체: 85%
- Repository Layer: 95%
- Application Layer: 80%
- Presentation Layer: 70%

## 발견된 버그
- Critical: 0개
- High: 1개 (수정 완료)
- Medium: 3개 (수정 완료)
- Low: 5개 (추적 중)

## 성능 지표
- 평균 API 응답 시간: 350ms
- 95th percentile: 800ms
- 에러율: 0.05%
- 처리량: 150 req/sec

## 결론
Phase 1.6 배포 승인 ✅
```

---

## 9. 다음 단계

✅ Phase 1.5 완료 후:
- **[Phase 1.6: 배포 및 모니터링](./06_deployment.md)** 문서로 이동하세요.

---

## 트러블슈팅

### 문제 1: 통합 테스트 실패 (RLS)
**증상**: RLS 정책으로 인해 데이터 조회 실패
**해결**: 테스트 사용자로 로그인 후 테스트 실행

### 문제 2: E2E 테스트 타임아웃
**증상**: `pumpAndSettle()` 무한 대기
**해결**: `pumpAndSettle(const Duration(seconds: 30))` 타임아웃 설정

### 문제 3: 성능 테스트 실패
**증상**: API 응답 시간 > 500ms
**해결**:
- Supabase 리전 확인 (Seoul 사용)
- 인덱스 추가
- 쿼리 최적화 (select * 대신 필요한 컬럼만)

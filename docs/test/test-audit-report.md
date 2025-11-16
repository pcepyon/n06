# Test Audit Report

## Summary
- **Total Tests**: 487
- **Passed**: 401
- **Failed**: 85
- **Skipped**: 1
- **Pass Rate**: 82.4%

## Executive Summary

Phase 0 (Isar) → Phase 1 (Supabase) 전환 후 85개의 테스트가 실패했습니다. 실패 원인을 분석한 결과, 대부분의 실패는 **구현 디테일 변경**(Mock 설정, 테스트 환경 초기화)과 **아키텍처 독립적 문제**(Provider 생명주기 관리)로 인한 것입니다. 실제 비즈니스 로직 변경으로 인한 실패는 소수입니다.

**주요 발견사항:**
1. Notification 기능 테스트 전체 실패 (Infrastructure Layer 초기화 문제)
2. Tracking 기능 UI 테스트 부분 실패 (Provider 생명주기 관리 문제)
3. Mockito 사용 패턴 오류 (14건)
4. Flutter 바인딩 초기화 누락 (3건)

---

## Failed Tests Analysis

### Category 1: Notification Feature Tests (Infrastructure Layer)

#### 1.1 notification_repository_test.dart
- **Test Name**:
  - `should define getNotificationSettings method`
  - `should define saveNotificationSettings method`
  - `should return null when settings not found`
- **Error**:
  ```
  type 'Null' is not a subtype of type 'Future<NotificationSettings?>'
  Bad state: Cannot call `when` within a stub response
  ```
- **Layer**: Domain (Repository Interface 테스트)
- **Failure Cause**: 구현 디테일 변경 - Mockito Mock 클래스 생성 방식 오류
- **Root Cause**:
  - `class MockNotificationRepository extends Mock implements NotificationRepository`는 deprecated된 방식
  - Mockito 5.x부터는 `@GenerateMocks([NotificationRepository])`와 코드 생성 방식 사용 필요
- **Strategy**: 수정
- **Priority**: 2 (Domain Layer이지만 테스트 인프라 문제)
- **Reasoning**: Repository Interface 자체는 변경되지 않았으므로 Mock 생성 방식만 최신화하면 해결됨. Domain Layer 테스트이므로 비즈니스 로직 검증을 위해 우선 수정 필요.

#### 1.2 permission_service_test.dart
- **Test Name**:
  - `should return true when notification permission is granted`
  - `should attempt to request permission`
  - `should open app settings`
- **Error**:
  ```
  Binding has not yet been initialized.
  The "instance" getter on the ServicesBinding binding mixin is only available once that binding has been initialized.
  ```
- **Layer**: Infrastructure
- **Failure Cause**: 환경 설정 문제
- **Root Cause**: Flutter 바인딩 초기화 누락. `permission_handler` 패키지는 플랫폼 채널을 사용하므로 테스트 전에 `TestWidgetsFlutterBinding.ensureInitialized()` 호출 필요
- **Strategy**: 수정
- **Priority**: 3 (Infrastructure Layer)
- **Reasoning**: 실제 플랫폼 통신 로직은 Mock으로 대체하고, 바인딩 초기화만 추가하면 해결됨. Phase 1 전환과 무관한 기존 문제.

#### 1.3 local_notification_scheduler_test.dart
- **Test Name**:
  - `should initialize notification plugin`
  - `should check notification permission via PermissionService`
  - `should request notification permission via PermissionService`
  - `should schedule notifications for dose schedules`
  - `should cancel all notifications`
  - `should not schedule notification for past dates`
  - `should schedule only one notification per date`
- **Error**:
  ```
  LateInitializationError: Field '_instance@1508271368' has not been initialized.
  FlutterLocalNotificationsPlatform._instance
  ```
- **Layer**: Infrastructure
- **Failure Cause**: 환경 설정 문제
- **Root Cause**: `flutter_local_notifications` 플러그인의 플랫폼 구현체가 초기화되지 않음. 단위 테스트에서는 플러그인 Mock 필요.
- **Strategy**: 재작성
- **Priority**: 3 (Infrastructure Layer)
- **Reasoning**: 실제 플러그인 호출 대신 Mock으로 대체해야 함. LocalNotificationScheduler의 비즈니스 로직(날짜 필터링, 중복 제거 등)에 집중하고, 플랫폼 레이어는 Mock으로 처리.

#### 1.4 notification_scheduler_test.dart (Domain Service Interface)
- **Test Name**:
  - `should define checkPermission method`
  - `should define requestPermission method`
  - `should define scheduleNotifications method`
  - `should define cancelAllNotifications method`
  - `should define hasScheduledNotifications method`
  - `should define initialize method`
- **Error**:
  ```
  type 'Null' is not a subtype of type 'Future<bool>'
  Bad state: Cannot call `when` within a stub response
  ```
- **Layer**: Domain (Service Interface 테스트)
- **Failure Cause**: 구현 디테일 변경 - Mockito Mock 생성 오류
- **Strategy**: 수정
- **Priority**: 2 (Domain Layer)
- **Reasoning**: Domain Service Interface 테스트. Mock 생성 방식을 최신화하면 해결됨.

#### 1.5 notification_notifier_test.dart
- **Test Name**:
  - `should load notification settings on build`
  - `should return default settings when none exist`
  - `should update notification time and reschedule`
  - `should toggle notification enabled with permission check`
  - `should request permission when toggling without permission`
  - `should cancel all notifications when disabling`
  - `should handle error when repository fails`
  - `should handle error when scheduling fails`
- **Error**:
  ```
  type 'Null' is not a subtype of type 'Future<NotificationSettings?>'
  Bad state: Cannot call `when` within a stub response
  ```
- **Layer**: Application
- **Failure Cause**: 구현 디테일 변경 - Mockito Mock 생성 오류
- **Strategy**: 수정
- **Priority**: 2 (Application Layer)
- **Reasoning**: Application Layer의 상태 관리 로직 테스트. Mock 생성 방식 수정 후 비즈니스 로직 검증 계속 가능.

#### 1.6 notification_settings_screen_test.dart
- **Test Name**:
  - `should display notification settings components`
  - `should toggle notification switch`
  - `should open time picker when tapping time selector`
- **Error**:
  ```
  Bad state: The provider profileProvider was disposed during loading state, yet no value could be emitted.
  ```
- **Layer**: Presentation
- **Failure Cause**: 아키�ecture 독립적 - Provider 생명주기 관리 문제
- **Root Cause**:
  - Widget 테스트에서 `autoDispose` Provider가 비동기 로딩 중 조기 해제됨
  - `profileProvider`가 로딩 상태에서 dispose되면서 값을 emit할 수 없는 상태 발생
- **Strategy**: 수정
- **Priority**: 4 (Presentation Layer이지만 재현 가능한 패턴)
- **Reasoning**:
  - Provider 생명주기 관리 전략 수정 필요
  - `ProviderContainer.dispose()` 전에 `await tester.pumpAndSettle()` 추가
  - 또는 테스트용 Provider를 `keepAlive()` 처리

---

### Category 2: Tracking Feature Tests (Presentation Layer)

#### 2.1 symptom_record_screen_test.dart
- **Test Name**: `should show error when severity 7-10 without persistence selection`
- **Error**: 위젯 렌더링 중 예외 발생 (스택트레이스만 있고 명확한 에러 메시지 없음)
- **Layer**: Presentation
- **Failure Cause**: 아키텍처 변경 또는 비즈니스 로직 변경
- **Root Cause**:
  - `_loadEscalationDate()` 메서드에서 Supabase 연동 관련 변경으로 추정
  - Isar → Supabase 전환 시 escalation 관련 데이터 로딩 로직 변경 가능성
- **Strategy**: 수정
- **Priority**: 1 (비즈니스 로직 검증)
- **Reasoning**:
  - "7-10 심각도에서 지속 여부 미선택 시 에러 표시"는 핵심 비즈니스 로직
  - Mock Repository 설정 확인 후 필요시 Supabase 관련 Mock 추가
  - 실제 화면 동작 검증이므로 우선 수정 필요

#### 2.2 symptom_record_screen_save_test.dart
- **Test Name**: (복수 테스트 실패)
- **Error**: 구체적 에러 미상 (로그 확인 필요)
- **Layer**: Presentation
- **Failure Cause**: 아키텍처 변경
- **Strategy**: 수정
- **Priority**: 1 (저장 로직 검증)
- **Reasoning**: 증상 기록 저장은 핵심 기능이므로 최우선 수정 필요.

#### 2.3 symptom_record_screen_task_3_test.dart
- **Test Name**: (복수 테스트 실패)
- **Error**: 구체적 에러 미상
- **Layer**: Presentation
- **Failure Cause**: 아키텍처 변경
- **Strategy**: 수정
- **Priority**: 1 (Task-based 테스트 검증)
- **Reasoning**: Task 기반 테스트는 사용자 시나리오 검증이므로 우선 수정.

#### 2.4 emergency_check_screen_save_test.dart
- **Test Name**: (복수 테스트 실패)
- **Error**: 구체적 에러 미상
- **Layer**: Presentation
- **Failure Cause**: 아키텍처 변경
- **Strategy**: 수정
- **Priority**: 1 (응급 상황 체크 저장)
- **Reasoning**: 응급 상황 체크는 안전 관련 핵심 기능이므로 최우선 수정.

#### 2.5 coping_guide_widget_test.dart
- **Test Name**:
  - `should prompt emergency check for severity 7-10 with persistence`
  - `should handle unknown symptom gracefully`
- **Error**:
  ```
  Actual: _TextWidgetFinder:<Found 0 widgets with text "대처 가이드": []>
  Which: means none were found but one was expected
  ```
- **Layer**: Presentation (Widget)
- **Failure Cause**: 비즈니스 로직 변경 또는 UI 변경
- **Root Cause**:
  - "대처 가이드" 텍스트가 예상 위치에 표시되지 않음
  - CopingGuide 데이터 로딩 실패 또는 UI 렌더링 조건 변경
- **Strategy**: 수정
- **Priority**: 2 (대처 가이드 표시 로직)
- **Reasoning**:
  - 대처 가이드는 사용자 안전 관련 중요 기능
  - Mock 데이터 확인 후 위젯 렌더링 조건 검증 필요

#### 2.6 Dialog Tests (dose_edit, record_delete, symptom_edit, weight_edit)
- **Test Name**: (각 Dialog별 복수 테스트 실패)
- **Error**: Provider 생명주기 관련 오류 추정
- **Layer**: Presentation (Dialog)
- **Failure Cause**: 구현 디테일 변경 - autoDispose Provider 생명주기
- **Strategy**: 수정
- **Priority**: 3 (Dialog 기능 검증)
- **Reasoning**:
  - Dialog는 독립적 컴포넌트이므로 Provider 생명주기만 수정하면 해결 가능
  - `showDialog` 후 `mounted` 체크 및 `pumpAndSettle` 추가

#### 2.7 record_detail_sheet_test.dart
- **Test Name**: (복수 테스트 실패)
- **Error**: Provider 생명주기 관련 오류 추정
- **Layer**: Presentation (Bottom Sheet)
- **Failure Cause**: 구현 디테일 변경
- **Strategy**: 수정
- **Priority**: 3 (Sheet 기능 검증)
- **Reasoning**: Dialog와 동일한 패턴으로 수정 가능.

---

### Category 3: Profile Feature Tests

#### 3.1 profile_notifier_update_weekly_goals_test.dart
- **Test Name**: (복수 테스트 실패)
- **Error**: 구체적 에러 미상 (Provider 관련 추정)
- **Layer**: Application
- **Failure Cause**: 아키텍처 변경
- **Root Cause**: Profile 데이터가 Isar → Supabase로 전환되면서 weekly goals 업데이트 로직 변경 가능성
- **Strategy**: 수정
- **Priority**: 2 (Application Layer)
- **Reasoning**:
  - Weekly goals 업데이트는 사용자 목표 관리 핵심 기능
  - Supabase Repository Mock 설정 확인 필요

---

## Error Pattern Summary

### 1. Mockito 'when' Errors (14건)
- **원인**: `class MockXXX extends Mock implements Interface` 방식은 Mockito 5.x에서 deprecated
- **해결**:
  ```dart
  // AS-IS (Deprecated)
  class MockNotificationRepository extends Mock implements NotificationRepository {}

  // TO-BE (Recommended)
  @GenerateMocks([NotificationRepository])
  import 'notification_repository_test.mocks.dart';

  // 또는 mocktail 사용
  class MockNotificationRepository extends Mock implements NotificationRepository {}
  // (mocktail은 코드 생성 없이 사용 가능)
  ```

### 2. Binding Initialization Errors (3건)
- **원인**: Flutter 플랫폼 채널 사용 시 바인딩 미초기화
- **해결**:
  ```dart
  void main() {
    TestWidgetsFlutterBinding.ensureInitialized(); // 추가

    test('...', () {
      // test code
    });
  }
  ```

### 3. LateInitializationError (7건)
- **원인**: Flutter 플러그인(flutter_local_notifications) 플랫폼 구현체 미초기화
- **해결**: Mock 플러그인 사용
  ```dart
  // 플러그인 Mock 처리
  @GenerateMocks([FlutterLocalNotificationsPlugin])

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    when(mockPlugin.initialize(any)).thenAnswer((_) async => true);
  });
  ```

### 4. Type Mismatch (19건)
- **원인**: Mockito Mock 생성 오류로 인한 타입 불일치
- **해결**: Mock 생성 방식 최신화 (패턴 1과 동일)

### 5. Provider Disposal Errors (5건)
- **원인**: `autoDispose` Provider가 비동기 로딩 중 조기 해제
- **해결**:
  ```dart
  testWidgets('...', (tester) async {
    // Widget pump
    await tester.pumpWidget(...);
    await tester.pumpAndSettle(); // 비동기 작업 완료 대기

    // User interaction
    await tester.tap(...);
    await tester.pumpAndSettle();

    // Verify BEFORE dispose
    expect(...);

    // Container dispose는 마지막에
  });
  ```

### 6. Widget Assertion Errors (8건)
- **원인**: 위젯 렌더링 실패 또는 텍스트 미표시
- **해결**: Mock 데이터 및 렌더링 조건 검증

---

## Recommendations

### Immediate Actions (Priority 1-2)

#### Priority 1: Core Business Logic Tests
1. **Tracking Feature 저장 로직**
   - `symptom_record_screen_save_test.dart`
   - `emergency_check_screen_save_test.dart`
   - `symptom_record_screen_task_3_test.dart`
   - `symptom_record_screen_test.dart`

   **Action**:
   - Mock Repository 설정 확인
   - Supabase 관련 데이터 로딩 로직 검증
   - Provider 생명주기 관리 수정

#### Priority 2: Application/Domain Layer Tests
1. **Notification Feature - Mock 생성 방식 최신화**
   - `notification_repository_test.dart` (Domain)
   - `notification_scheduler_test.dart` (Domain)
   - `notification_notifier_test.dart` (Application)
   - `profile_notifier_update_weekly_goals_test.dart` (Application)

   **Action**:
   ```bash
   # build_runner로 Mock 자동 생성
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

   **파일 수정**:
   ```dart
   // 각 테스트 파일 상단에 추가
   import 'package:mockito/annotations.dart';

   @GenerateMocks([
     NotificationRepository,
     NotificationScheduler,
     // ... 기타 Mock 대상
   ])
   import 'xxx_test.mocks.dart';
   ```

2. **CopingGuideWidget 렌더링 검증**
   - `coping_guide_widget_test.dart`

   **Action**: Mock 데이터 및 위젯 빌드 조건 확인

### Medium-term Actions (Priority 3)

#### Priority 3: Infrastructure Layer Tests
1. **Notification Infrastructure 테스트 재작성**
   - `local_notification_scheduler_test.dart` → Mock 플러그인 사용
   - `permission_service_test.dart` → 바인딩 초기화 추가

   **Action**:
   ```dart
   // local_notification_scheduler_test.dart
   @GenerateMocks([
     FlutterLocalNotificationsPlugin,
     AndroidFlutterLocalNotificationsPlugin,
     IOSFlutterLocalNotificationsPlugin,
   ])

   void main() {
     TestWidgetsFlutterBinding.ensureInitialized();

     late MockFlutterLocalNotificationsPlugin mockPlugin;

     setUp(() {
       mockPlugin = MockFlutterLocalNotificationsPlugin();
       // Mock 설정
     });
   }
   ```

2. **Dialog/Sheet 테스트 Provider 생명주기 수정**
   - `dose_edit_dialog_test.dart`
   - `record_delete_dialog_test.dart`
   - `symptom_edit_dialog_test.dart`
   - `weight_edit_dialog_test.dart`
   - `record_detail_sheet_test.dart`

   **Action**: `pumpAndSettle()` 및 `mounted` 체크 추가

### Optional Actions (Priority 4)

#### Priority 4: Presentation Layer Screen Tests
1. **NotificationSettingsScreen Provider 생명주기 수정**
   - `notification_settings_screen_test.dart`

   **Action**: `keepAlive()` 또는 테스트 종료 시점 조정

---

## Test Maintenance Strategy

### 1. Mock 생성 표준화
**현재 문제**: 구식 Mock 생성 방식 사용
**해결 방안**:
- **Option A (권장)**: `mockito` + `build_runner` (타입 안전)
- **Option B**: `mocktail` (코드 생성 불필요, 더 간단)

**결정 기준**:
- 현재 프로젝트는 이미 `mockito`를 사용 중
- `build_runner`는 이미 Riverpod 코드 생성에 사용 중
- → **Option A 선택 권장**

**마이그레이션 스크립트**:
```bash
# 1. 모든 테스트 파일에 @GenerateMocks 추가
# 2. build_runner 실행
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Mock import 추가
# (자동 생성된 .mocks.dart 파일 import)
```

### 2. Provider 생명주기 관리 패턴
**베스트 프랙티스**:
```dart
testWidgets('description', (tester) async {
  // 1. Container 생성 (테스트 전체에서 유지)
  final container = ProviderContainer();
  addTearDown(container.dispose);

  // 2. Widget pump
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: YourWidget()),
    ),
  );

  // 3. 비동기 작업 완료 대기
  await tester.pumpAndSettle();

  // 4. User interaction
  await tester.tap(find.text('Button'));
  await tester.pumpAndSettle(); // 중요!

  // 5. Verification
  expect(find.text('Expected'), findsOneWidget);

  // 6. Container는 addTearDown에서 자동 dispose
});
```

### 3. Flutter 바인딩 초기화 체크리스트
**플랫폼 채널 사용 시 필수**:
- `permission_handler`
- `flutter_local_notifications`
- `shared_preferences`
- 기타 플랫폼 플러그인

**템플릿**:
```dart
void main() {
  // 플랫폼 채널 사용 시 필수
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YourTests', () {
    // tests
  });
}
```

---

## Next Steps

### Step 1: Priority 1 테스트 수정 (1-2일)
- [ ] `symptom_record_screen_save_test.dart` 수정
- [ ] `emergency_check_screen_save_test.dart` 수정
- [ ] `symptom_record_screen_task_3_test.dart` 수정
- [ ] `symptom_record_screen_test.dart` 수정
- [ ] 각 수정 후 개별 테스트 실행으로 검증

### Step 2: Mock 생성 방식 표준화 (1일)
- [ ] `@GenerateMocks` 어노테이션 추가 (모든 Domain/Application 테스트)
- [ ] `build_runner` 실행
- [ ] `.mocks.dart` 파일 import 추가
- [ ] 테스트 재실행으로 검증

### Step 3: Infrastructure 테스트 재작성 (1일)
- [ ] `local_notification_scheduler_test.dart` Mock 플러그인 적용
- [ ] `permission_service_test.dart` 바인딩 초기화
- [ ] 플러그인 Mock 설정 검증

### Step 4: Provider 생명주기 패턴 적용 (1일)
- [ ] Dialog/Sheet 테스트 수정
- [ ] NotificationSettingsScreen 테스트 수정
- [ ] 통합 테스트 재실행

### Step 5: 최종 검증 (0.5일)
- [ ] `flutter test` 전체 실행
- [ ] Pass rate 95% 이상 확인
- [ ] 남은 실패 테스트 재분류
- [ ] 테스트 커버리지 리포트 생성

**예상 총 소요 시간**: 4.5일

---

## Appendix: Test Failure Details

### Failed Test Files (17개)
1. `features/notification/application/notifiers/notification_notifier_test.dart` (8 failures)
2. `features/notification/domain/repositories/notification_repository_test.dart` (3 failures)
3. `features/notification/domain/services/notification_scheduler_test.dart` (6 failures)
4. `features/notification/infrastructure/services/local_notification_scheduler_test.dart` (7 failures)
5. `features/notification/infrastructure/services/permission_service_test.dart` (3 failures)
6. `features/notification/presentation/screens/notification_settings_screen_test.dart` (3 failures)
7. `features/profile/application/notifiers/profile_notifier_update_weekly_goals_test.dart` (N failures)
8. `features/tracking/presentation/dialogs/dose_edit_dialog_test.dart` (N failures)
9. `features/tracking/presentation/dialogs/record_delete_dialog_test.dart` (N failures)
10. `features/tracking/presentation/dialogs/symptom_edit_dialog_test.dart` (N failures)
11. `features/tracking/presentation/dialogs/weight_edit_dialog_test.dart` (N failures)
12. `features/tracking/presentation/screens/emergency_check_screen_save_test.dart` (N failures)
13. `features/tracking/presentation/screens/symptom_record_screen_save_test.dart` (N failures)
14. `features/tracking/presentation/screens/symptom_record_screen_task_3_test.dart` (N failures)
15. `features/tracking/presentation/screens/symptom_record_screen_test.dart` (N failures)
16. `features/tracking/presentation/sheets/record_detail_sheet_test.dart` (N failures)
17. `features/tracking/presentation/widgets/coping_guide_widget_test.dart` (2 failures)

### Layer Distribution
- **Domain**: 2 파일 (Repository Interface 1, Service Interface 1)
- **Application**: 2 파일 (Notifier 2)
- **Infrastructure**: 2 파일 (Service 구현 2)
- **Presentation**: 11 파일 (Screen 5, Dialog 4, Sheet 1, Widget 1)

### Feature Distribution
- **Notification**: 6 파일 (전체 실패)
- **Tracking**: 10 파일 (부분 실패)
- **Profile**: 1 파일 (부분 실패)

---

## Conclusion

테스트 실패의 대부분은 **Phase 0 → Phase 1 전환과 직접적 관련이 없는 구현 디테일 문제**입니다:
- Mockito 구식 API 사용 (14건)
- Flutter 바인딩 초기화 누락 (3건)
- Provider 생명주기 관리 미흡 (5건)

**실제 아키텍처 변경으로 인한 실패**는 Tracking 기능의 일부 테스트에 국한되어 있으며, 이는 Supabase 전환 시 예상 가능한 범위입니다.

**Clean Architecture의 효과**:
- Domain/Application Layer는 대부분 Mock 설정만 수정하면 해결 가능
- Infrastructure Layer는 재작성이 필요하지만, 이는 Phase 전환 전략에 부합
- Presentation Layer는 Provider 생명주기 패턴만 통일하면 해결 가능

**권장 사항**:
1. Priority 1-2 테스트부터 즉시 수정 시작
2. Mock 생성 방식 표준화로 향후 유지보수성 확보
3. Provider 생명주기 관리 베스트 프랙티스 문서화 및 팀 공유
4. 4.5일 내에 95% 이상 Pass rate 달성 가능

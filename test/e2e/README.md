# E2E Tests

End-to-End 테스트로 Critical Path를 검증합니다.

## 테스트 전략

- **Patrol** 사용: 네이티브 기능 (소셜 로그인 팝업 등) 자동화
- **Critical Path만**: MVP 핵심 기능에 집중
- **User Journey**: 실제 사용자 시나리오 재현

## Critical Scenarios

### E2E-001: 소셜 로그인

```dart
patrolTest('should login with Kakao', (PatrolIntegrationTester $) async {
  await $.pumpWidgetAndSettle(MyApp());

  // 카카오 로그인 버튼 탭
  await $(#kakaoLoginButton).tap();

  // 네이티브 팝업 처리
  await $.native.enterText(
    Selector(text: 'Email'),
    'test@example.com',
  );
  await $.native.enterText(
    Selector(text: 'Password'),
    'password123',
  );
  await $.native.tap(Selector(text: 'Login'));

  // 온보딩 화면 진입 확인
  await $('온보딩').waitUntilVisible();
});
```

### E2E-002: 투여 기록 flow

```dart
patrolTest('should complete dose recording flow', ($) async {
  // ... 로그인 후

  // 홈 대시보드에서 투여 기록 버튼 탭
  await $(#recordDoseButton).tap();

  // 투여 정보 입력
  await $(#doseMgInput).enterText('0.25');
  await $(#injectionSiteDropdown).tap();
  await $('복부').tap();

  // 저장
  await $(#saveDoseButton).tap();

  // 홈 대시보드로 복귀 및 업데이트 확인
  await $('투여 완료').waitUntilVisible();
});
```

## 환경 설정

### Android

```bash
# Patrol CLI 설치
dart pub global activate patrol_cli

# 앱 빌드 및 테스트 실행
patrol test -t test/e2e/login_test.dart
```

### iOS

```bash
# Xcode 설정 필요
patrol test -t test/e2e/login_test.dart --device-id <DEVICE_ID>
```

## 실행

```bash
# 모든 E2E 테스트
patrol test

# 특정 파일
patrol test -t test/e2e/login_test.dart

# 특정 디바이스
patrol test --device-id emulator-5554
```

## 주의사항

- E2E 테스트는 실제 기기/에뮬레이터 필요
- 네이티브 팝업 처리를 위해 Patrol 사용
- 느린 실행 속도 → Critical Path만 테스트
- CI/CD에서는 선택적으로 실행

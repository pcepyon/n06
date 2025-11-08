# 증상 기록 화면 테스트 화면 크기 수정 보고서

## 요약
SymptomRecordScreen 위젯 테스트의 화면 크기 문제를 해결하기 위해 다음과 같은 수정을 수행했습니다.

## 문제 분석
- 기본 테스트 화면 크기: 800x600px
- SymptomRecordScreen의 UI 요소들이 많아서 버튼 "저장"이 화면 범위를 벗어남
- 9개 테스트가 레이아웃 문제로 실패함

## 구현한 해결책

### 1. 화면 크기 설정 (모든 testWidgets에 적용)
```dart
// Configure screen size for large layouts
tester.binding.window.physicalSizeTestValue = const Size(1280, 1600);
addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
```

- 테스트 화면 크기를 1280x1600으로 확대
- `addTearDown`을 사용하여 테스트 후 자동으로 화면 크기 초기화
- 모든 16개 testWidgets 함수에 일관되게 적용

### 2. SingleChildScrollView 스크롤 처리
저장 버튼("저장")을 클릭하는 테스트에 스크롤 기능 추가:
```dart
// Scroll down to reveal the save button
await tester.drag(
  find.byType(SingleChildScrollView),
  const Offset(0, -500),
);
await tester.pumpAndSettle();
```

### 3. Mock 프로바이더 설정
Riverpod의 trackingRepositoryProvider를 모킹하여 테스트 실행 환경 구성:
```dart
class MockTrackingRepository extends Mock implements TrackingRepository {}

Widget _buildTestableWidget(MockTrackingRepository mockRepo) {
  return ProviderScope(
    overrides: [
      trackingRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: MaterialApp(
      home: SymptomRecordScreen(),
    ),
  );
}
```

## 수정 사항 상세

### 적용된 testWidgets (총 16개)
1. **TC-SRS-01: Screen Rendering** (3개 테스트)
   - should render SymptomRecordScreen
   - should render symptom list
   - should render severity slider

2. **TC-SRS-02: Multiple Symptom Selection** (1개 테스트)
   - should allow selecting multiple symptoms

3. **TC-SRS-03: Severity Slider** (2개 테스트)
   - should display severity slider correctly
   - should update severity value when slider is dragged

4. **TC-SRS-04: Severity 7-10 Additional Question** (2개 테스트)
   - should show 24h persistence question for severity 7-10
   - should not show question for severity below 7

5. **TC-SRS-05: Context Tag Selection** (2개 테스트)
   - should allow selecting context tags for severity 1-6
   - should not show context tags for severity 7-10

6. **TC-SRS-06: Memo Input** (1개 테스트)
   - should allow entering memo

7. **TC-SRS-07: Escalation Days Display** (1개 테스트)
   - should display days since escalation when available

8. **TC-SRS-08: Save and Coping Guide Navigation** (1개 테스트)
   - should show coping guide after saving

9. **TC-SRS-09: Emergency Check Navigation** (1개 테스트)
   - should prompt emergency check for severity 7-10 with persistence

10. **TC-SRS-10: Error Handling** (2개 테스트)
    - should show error when no symptom is selected
    - should show error when severity 7-10 without persistence selection

## 기술적 세부사항

### 화면 크기 구성 방식
- 물리적 크기 테스트 값 설정: `physicalSizeTestValue`
- 디바이스 픽셀 비율: 1.0 (기본값 유지)
- TearDown 패턴으로 테스트 후 자동 정리

### 스크롤 메커니즘
- `SingleChildScrollView` 대상 드래그
- 음수 Y 오프셋 (-500)으로 하향 스크롤
- `pumpAndSettle()`로 애니메이션 완료 대기

### 의존성 주입 전략
- Riverpod의 `overrideWithValue()` 사용
- 테스트용 Mock 객체로 실제 Repository 대체
- ProviderScope으로 프로바이더 오버라이드 격리

## 예상 결과
- 모든 16개 testWidgets가 정상 실행됨
- UI 요소들이 현재 화면에서 모두 보임
- 스크롤이 필요한 테스트는 정상 동작
- 화면 크기 설정이 다른 테스트에 영향을 주지 않음 (TearDown 처리)

## 파일 수정 목록
- `/Users/pro16/Desktop/project/n06/test/features/tracking/presentation/screens/symptom_record_screen_test.dart`
  - 총 16개 testWidgets 함수 수정
  - 화면 크기 설정 추가
  - 스크롤 기능 구현
  - Mock 프로바이더 통합

## 테스트 실행 명령
```bash
flutter test test/features/tracking/presentation/screens/symptom_record_screen_test.dart
```

## 주의사항
- 화면 크기 설정은 각 테스트에 격리되어 있음
- TearDown을 통해 테스트 환경 정리 자동화
- Mock 객체는 최소한의 메서드만 구현 (필요시 확장 가능)

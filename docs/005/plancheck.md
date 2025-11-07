# UC-F003 Plan 검토 결과

## 검토 일자
2025-11-07

## 검토 요약
spec.md의 요구사항과 plan.md의 설계를 비교한 결과, **6개의 누락 사항 및 불일치**가 발견되었습니다.

---

## 1. 누락된 기능: 증상 체크 이력

### 문제
- **spec.md 요구사항** (line 35-36):
  ```
  - 증상 체크 이력: 심각 증상 체크 기록 요약
  ```
- **plan.md 현황**:
  - SharedDataReport Entity (section 3.1)에 증상 체크 이력 필드 없음
  - IsarSharedDataRepository (section 3.3)에 증상 체크 조회 로직 없음
  - DataSharingScreen (section 3.6)에 증상 체크 이력 표시 UI 없음

### 수정 방안
**Section 3.1 SharedDataReport Entity**:
```dart
// 추가 필드
final List<SymptomCheck> symptomChecks; // 심각 증상 체크 기록
```

**Section 3.3 IsarSharedDataRepository**:
- Test Scenarios 추가:
  ```
  test('should fetch symptom checks within date range')
  ```
- Implementation Order 추가:
  ```
  7. 기간별 증상 체크 기록 조회 로직
  ```

**Section 3.6 DataSharingScreen**:
- Test Scenarios 추가:
  ```
  testWidgets('should display symptom check summary')
  ```
- Implementation Order 추가:
  ```
  7. 증상 체크 이력 섹션 렌더링
  ```

---

## 2. 누락된 데이터: 투여 계획 및 스케줄

### 문제
- **spec.md 시퀀스 다이어그램** (line 122-123):
  ```
  FE -> Database: 투여 계획 및 스케줄 조회
  Database --> FE: 투여 계획 및 스케줄 반환
  ```
- **plan.md 현황**:
  - IsarSharedDataRepository에 투여 스케줄 조회 로직 없음
  - 순응도 계산 시 "계획 대비 실제 투여 완료율" 계산 로직 불명확

### 수정 방안
**Section 3.3 IsarSharedDataRepository**:
- Test Scenarios 추가:
  ```
  test('should fetch medication schedules within date range')
  test('should calculate adherence rate using schedules and dose records')
  ```
- Implementation Order 수정:
  ```
  5. 투여 스케줄 조회 로직 (계획된 투여 횟수 산출용)
  6. 순응도 계산 로직 (실제 투여 횟수 / 계획된 투여 횟수 * 100)
  ```

**Section 3.4 DataSharingAggregator**:
- Test Scenarios 추가:
  ```
  test('should calculate adherence rate from schedules and dose records')
  test('should handle missed doses correctly')
  ```

---

## 3. 누락된 Edge Case: 화면 캡처 정책

### 문제
- **spec.md Edge Case** (line 62):
  ```
  화면 캡처 시도 시: 제한 없이 허용 (사용자 의도에 따름)
  ```
- **plan.md 현황**: 화면 캡처 관련 언급 없음

### 수정 방안
**Section 3.6 DataSharingScreen**:
- Implementation Order 추가:
  ```
  8. 화면 캡처 허용 정책 명시 (별도 제한 없음)
  ```
- 구현 가이드:
  ```dart
  // MaterialApp 레벨에서 기본 설정 유지 (제한 없음)
  // iOS: Info.plist 설정 확인 불필요
  // Android: FLAG_SECURE 미사용
  ```

---

## 4. 불완전한 구현: 백 버튼 확인 다이얼로그

### 문제
- **spec.md Business Rule BR-5** (line 93):
  ```
  백 버튼 사용 시 확인 대화상자 표시 후 종료 결정
  ```
- **plan.md 현황**:
  - Section 3.6 QA Sheet에만 언급됨
  - Implementation Order에 WillPopScope/PopScope 구현 없음

### 수정 방안
**Section 3.6 DataSharingScreen**:
- Test Scenarios 추가:
  ```
  testWidgets('should show confirmation dialog on back button press')
  testWidgets('should exit sharing mode when confirmed in dialog')
  testWidgets('should stay in sharing mode when cancelled in dialog')
  ```
- Implementation Order 추가:
  ```
  6. PopScope 위젯 통합 (백 버튼 인터셉트)
  7. 확인 다이얼로그 구현 ("공유를 종료하시겠습니까?")
  ```

---

## 5. 누락된 UI 구조: 데이터 표시 우선순위

### 문제
- **spec.md Business Rule BR-3** (line 79-83):
  ```
  1. 투여 기록 및 순응도 (치료 핵심 지표)
  2. 체중 변화 (치료 목표 지표)
  3. 부작용 기록 (안전성 지표)
  4. 증상 체크 이력 (응급 대응 지표)
  ```
- **plan.md 현황**:
  - Section 3.6 Implementation Order가 우선순위를 명시하지 않음

### 수정 방안
**Section 3.6 DataSharingScreen**:
- Implementation Order 수정:
  ```
  4. 리포트 섹션 레이아웃 (우선순위 순서):
     1) 투여 기록 타임라인 + 순응도
     2) 주사 부위 순환 이력
     3) 체중 변화 그래프
     4) 부작용 강도 추이 + 발생 패턴
     5) 증상 체크 이력
  ```

---

## 6. 누락된 기능: 차트 터치 인터랙션

### 문제
- **spec.md Main Scenario Step 4** (line 39):
  ```
  사용자가 차트 터치 시 해당 시점의 상세 데이터 표시
  ```
- **plan.md 현황**:
  - Section 3.6 QA Sheet에만 언급됨
  - Test Scenarios 및 Implementation Order에 없음

### 수정 방안
**Section 3.6 DataSharingScreen**:
- Test Scenarios 추가:
  ```
  testWidgets('should show detail popup when chart is tapped')
  testWidgets('should display correct data for tapped chart point')
  testWidgets('should dismiss detail popup when tapping outside')
  ```
- Implementation Order 추가:
  ```
  8. 차트 터치 이벤트 핸들러 구현
  9. 상세 데이터 팝업 위젯 (해당 시점의 투여/체중/부작용 정보)
  ```

---

## 7. 추가 권장사항

### 7.1 성능 요구사항 검증 부족
- **spec.md Edge Case** (line 58):
  ```
  데이터 렌더링 시간이 1초 초과 시: 로딩 인디케이터 표시
  ```
- **plan.md Section 8**: 성능 요구사항은 명시되어 있으나 테스트 시나리오 없음

**권장 수정**:
- Section 3.6 Test Scenarios 추가:
  ```
  testWidgets('should show loading indicator when data takes >1s to load')
  ```

### 7.2 대용량 데이터 처리 구체화 부족
- **spec.md Edge Case** (line 59):
  ```
  전체 기간 데이터가 6개월 이상인 경우: 페이지네이션 또는 가상 스크롤 적용
  ```
- **plan.md Section 7**: Edge Case로 언급만 되어 있고 구현 방법 불명확

**권장 수정**:
- Section 3.6 Implementation Order 추가:
  ```
  10. 가상 스크롤 구현 (ListView.builder 사용)
  11. 데이터 청킹 로직 (6개월 이상 데이터 시)
  ```

---

## 요약

### 필수 수정 항목 (6개)
1. ✅ 증상 체크 이력 데이터 조회 및 표시 로직 추가
2. ✅ 투여 계획/스케줄 조회 로직 추가
3. ✅ 화면 캡처 정책 명시
4. ✅ 백 버튼 확인 다이얼로그 구현 추가
5. ✅ 데이터 표시 우선순위에 따른 UI 구조 명시
6. ✅ 차트 터치 인터랙션 구현 추가

### 권장 개선 항목 (2개)
7. ⚠️ 로딩 인디케이터 테스트 시나리오 추가
8. ⚠️ 대용량 데이터 처리 구현 방법 구체화

---

## 다음 단계
1. plan.md 수정본 작성
2. 수정된 plan에 따라 TDD 사이클 시작
3. 각 모듈 구현 시 spec.md 요구사항 재확인

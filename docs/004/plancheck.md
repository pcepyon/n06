# UF-F002: 증상 및 체중 기록 - Plan 검증 결과

## 검증 일시
2025-11-07

## 검증 결과: 수정 필요

---

## 1. 중대한 설계 누락 사항

### 1.1. 중복 기록 확인 로직 누락 (Critical)

**명세 요구사항** (spec.md):
- Edge Cases > 중복 기록: "같은 날짜에 체중 중복 기록: 시스템이 덮어쓰기 확인 메시지를 표시한다"
- BR-F002-01: "체중은 날짜당 1개 값만 저장 가능 (중복 시 덮어쓰기)"
- Sequence Diagram: "이미 기록이 있습니다. 덮어쓰시겠어요?" 확인 메시지

**현재 Plan 문제점**:
```dart
// TC-WRS-04: 저장 버튼 클릭 (정상)
testWidgets('should save WeightLog on button tap', (tester) async {
  // ... 저장만 테스트하고 중복 확인 다이얼로그는 테스트하지 않음
});
```

**수정 필요 사항**:
1. **WeightRecordScreen에 추가 테스트 필요**:
```dart
// TC-WRS-07: 중복 날짜 기록 시 확인 다이얼로그 표시
testWidgets('should show overwrite confirmation for duplicate date', (tester) async {
  // Arrange
  final mockNotifier = MockTrackingNotifier();
  when(() => mockNotifier.getWeightLog(any(), any()))
      .thenAnswer((_) async => WeightLog(...)); // 기존 기록 존재

  await tester.pumpWidget(...);

  // Act
  await tester.enterText(find.byType(TextField), '75.5');
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('이미 기록이 있습니다. 덮어쓰시겠어요?'), findsOneWidget);
  expect(find.text('취소'), findsOneWidget);
  expect(find.text('확인'), findsOneWidget);
});

// TC-WRS-08: 덮어쓰기 확인 시 업데이트 호출
testWidgets('should update WeightLog on overwrite confirmation', (tester) async {
  // Arrange
  await tester.pumpWidget(...);
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // Act
  await tester.tap(find.text('확인')); // 덮어쓰기 확인
  await tester.pumpAndSettle();

  // Assert
  verify(() => mockNotifier.updateWeightLog(any(), any())).called(1);
});
```

2. **TrackingNotifier에 추가 메서드 필요**:
```dart
// TrackingRepository Interface에 추가
Future<WeightLog?> getWeightLog(String userId, DateTime logDate);

// TrackingNotifier에 중복 체크 로직 추가
Future<bool> hasWeightLogOnDate(String userId, DateTime date) async {
  final existing = await _repository.getWeightLog(userId, date);
  return existing != null;
}
```

---

### 1.2. 경과일 계산 위치 불일치 (Architecture Violation)

**명세 요구사항** (spec.md Sequence Diagram):
```
FE -> BE: getLatestDoseEscalationDate(userId)
BE -> FE: 증량일 반환
FE -> FE: 경과일 계산  // ← Frontend에서 계산
FE -> BE: saveSymptomLog(..., daysSinceEscalation, ...)
```

**현재 Plan**:
```dart
// TC-TN-03: TrackingNotifier에서 경과일 계산
test('should save SymptomLog with calculated daysSinceEscalation', () async {
  // ...
  await notifier.saveSymptomLog(log); // ← Notifier가 계산
  expect(capturedLog.daysSinceEscalation, 6);
});
```

**문제점**:
- 명세는 Frontend(Presentation Layer)에서 계산하도록 되어 있음
- 하지만 **Application Layer에서 계산하는 것이 올바름** (비즈니스 로직)
- 명세의 Sequence Diagram이 잘못됨

**수정 방향**:
1. **Plan은 올바르게 설계됨** (TrackingNotifier에서 계산)
2. **spec.md의 Sequence Diagram을 수정해야 함**:
```
FE -> BE: saveSymptomLog(symptomData) // daysSinceEscalation 없이 전송
BE -> BE: getLatestDoseEscalationDate(userId)
BE -> BE: 경과일 계산
BE -> Database: INSERT INTO symptom_logs (daysSinceEscalation 포함)
```

**또는 Plan에 명확한 주석 추가**:
```dart
// NOTE: spec.md의 Sequence Diagram과 달리,
// 경과일 계산은 Application Layer(TrackingNotifier)에서 수행함.
// 이유: 비즈니스 로직이므로 Presentation Layer에 두면 안 됨.
```

---

### 1.3. `isPersistent24h` 필드 처리 불명확

**명세 요구사항** (spec.md UC-F002-03):
```
6. 시스템이 추가 확인 질문을 표시한다: "이 증상이 24시간 이상 지속되고 있나요?"
7. 사용자가 "예" 또는 "아니오"를 선택한다
...
11. 시스템이 기록을 저장한다 (isPersistent24h 포함)
```

**현재 Plan**:
```dart
// TC-SL-02: 중증 생성 (심각도 7-10점, 24시간 지속)
test('should create SymptomLog with severity 7-10 and persistent flag', () {
  final symptomLog = SymptomLog(
    severity: 9,
    isPersistent24h: true, // ← 필드는 있음
  );
  expect(symptomLog.isPersistent24h, isTrue);
});
```

**문제점**:
1. DTO 변환 테스트에 `isPersistent24h` 포함 여부 확인 없음
2. IsarTrackingRepository 테스트에서 이 필드 저장/조회 검증 없음
3. SymptomRecordScreen 테스트에서 "예/아니오" 선택 후 저장 로직 불명확

**수정 필요 사항**:
```dart
// SymptomLogDto 테스트 추가
// TC-SL-DTO-03: isPersistent24h 필드 변환
test('should preserve isPersistent24h in DTO conversion', () {
  final entity = SymptomLog(severity: 9, isPersistent24h: true);
  final dto = SymptomLogDto.fromEntity(entity);
  final converted = dto.toEntity();
  expect(converted.isPersistent24h, isTrue);
});

// SymptomRecordScreen 테스트 추가
// TC-SRS-07: 24시간 지속 여부 저장
testWidgets('should save isPersistent24h based on user selection', (tester) async {
  await tester.drag(find.byType(Slider), Offset(100, 0)); // 심각도 9점
  await tester.pumpAndSettle();
  await tester.tap(find.text('예')); // 24시간 지속 선택
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  final capturedLog = verify(() => mockNotifier.saveSymptomLog(captureAny())).captured.single;
  expect(capturedLog.isPersistent24h, isTrue);
});
```

---

### 1.4. 대처 가이드 연동 (F004) 명세 부족

**명세 요구사항** (spec.md BR-F002-04):
- "부작용 기록 저장 시 자동으로 대처 가이드 표시 (F004)"
- Sequence Diagram: "FE -> FE: 해당 증상 대처 가이드 조회"

**현재 Plan**:
```dart
// TC-SRS-05: 저장 후 대처 가이드 표시
testWidgets('should show coping guide after saving', (tester) async {
  // ...
  expect(find.text('메스꺼움 대처 가이드'), findsOneWidget);
  expect(find.text('도움이 되었나요?'), findsOneWidget);
});

**Dependencies**: `TrackingNotifier`, `CopingGuideWidget` (F004)
```

**문제점**:
1. `CopingGuideWidget`의 인터페이스가 정의되지 않음
2. F004와의 데이터 계약(Contract) 명시 필요
3. 대처 가이드 조회 실패 시 처리 방법 없음

**수정 필요 사항**:
```dart
// 3.10 SymptomRecordScreen Implementation Order에 추가:

// Step 5.5: F004 Integration Contract 정의
abstract class CopingGuideService {
  Future<CopingGuide?> getCopingGuide(String symptomName);
}

// TC-SRS-08: 대처 가이드 조회 실패 시 처리
testWidgets('should handle missing coping guide gracefully', (tester) async {
  // Arrange
  final mockGuideService = MockCopingGuideService();
  when(() => mockGuideService.getCopingGuide(any()))
      .thenAnswer((_) async => null); // 가이드 없음

  // Act
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('메스꺼움 대처 가이드'), findsNothing);
  expect(find.text('홈 대시보드'), findsOneWidget); // 바로 홈으로 이동
});

// TC-SRS-09: 대처 가이드 건너뛰기
testWidgets('should allow skipping coping guide', (tester) async {
  // Arrange
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // Act
  await tester.tap(find.text('건너뛰기'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

---

### 1.5. 증상 체크 화면 연동 (F005) 완전 누락

**명세 요구사항** (spec.md UC-F002-03):
```
13. 만약 "예"를 선택했다면, 시스템이 "증상 체크" 화면으로 안내한다 (F005 연동)
14. 사용자가 필요 시 증상 체크를 진행하거나, 홈 대시보드로 복귀한다
```

**현재 Plan**: 해당 내용 없음

**수정 필요 사항**:
```dart
// SymptomRecordScreen 테스트 추가
// TC-SRS-10: 중증 + 24시간 지속 시 증상 체크 화면 안내
testWidgets('should navigate to symptom check for severe persistent symptoms', (tester) async {
  // Arrange
  await tester.drag(find.byType(Slider), Offset(100, 0)); // 심각도 9점
  await tester.tap(find.text('예')); // 24시간 지속
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('증상 체크 화면으로 이동하시겠어요?'), findsOneWidget);
  expect(find.text('이동'), findsOneWidget);
  expect(find.text('나중에'), findsOneWidget);
});

// TC-SRS-11: 증상 체크 화면 이동
testWidgets('should navigate to F005 on confirmation', (tester) async {
  // Arrange
  await tester.pumpAndSettle(); // 위 상태 이어받기

  // Act
  await tester.tap(find.text('이동'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(SymptomCheckScreen), findsOneWidget); // F005
});

// TC-SRS-12: 증상 체크 생략
testWidgets('should allow skipping symptom check', (tester) async {
  // Act
  await tester.tap(find.text('나중에'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

**Implementation Order에 추가**:
```
Step 6.5: F005 Navigation Logic
- BR-F002-04에 따라 severity >= 7 && isPersistent24h == true일 때만 안내
- Navigator.push()로 SymptomCheckScreen으로 이동
- 사용자가 거부 시 HomeScreen으로 복귀
```

---

### 1.6. 컨텍스트 태그 정규화 테스트 부족

**명세 요구사항** (spec.md BR-F002-06):
- "컨텍스트 태그는 symptom_context_tags 테이블에 정규화하여 저장"
- Sequence Diagram: "INSERT INTO symptom_context_tags (for each tag)"

**현재 Plan**:
```dart
// TC-ITR-03: 증상 기록 저장 (태그 포함)
test('should save SymptomLog with tags to Isar', () async {
  final log = SymptomLog(..., tags: ['기름진음식', '과식']);
  await repository.saveSymptomLog(log);

  final saved = await repository.getSymptomLogs(log.userId);
  expect(saved.first.tags, ['기름진음식', '과식']);
});
```

**문제점**:
1. 같은 태그 중복 저장 방지 로직 테스트 없음
2. 여러 증상 기록이 같은 태그를 참조할 때 정규화 확인 없음
3. 태그 조회 성능 최적화 고려 없음

**수정 필요 사항**:
```dart
// IsarTrackingRepository 테스트 추가
// TC-ITR-07: 태그 정규화 (중복 방지)
test('should normalize context tags across multiple logs', () async {
  // Arrange
  final log1 = SymptomLog(..., symptomName: '메스꺼움', tags: ['기름진음식']);
  final log2 = SymptomLog(..., symptomName: '복통', tags: ['기름진음식']); // 같은 태그

  // Act
  await repository.saveSymptomLog(log1);
  await repository.saveSymptomLog(log2);

  // Assert
  final tagDto = await isar.symptomContextTagDtos
      .filter()
      .tagNameEqualTo('기름진음식')
      .findAll();

  expect(tagDto.length, 2); // 2개의 연결만 생성 (태그 자체는 중복 없음)
  // 실제로는 symptom_log_id가 다른 2개 레코드
});

// TC-ITR-08: 태그 목록 조회 (역참조)
test('should get all symptom logs with specific tag', () async {
  // Arrange
  await repository.saveSymptomLog(SymptomLog(..., tags: ['기름진음식']));
  await repository.saveSymptomLog(SymptomLog(..., tags: ['기름진음식']));
  await repository.saveSymptomLog(SymptomLog(..., tags: ['과식']));

  // Act
  final logs = await repository.getSymptomLogsByTag('기름진음식');

  // Assert
  expect(logs.length, 2);
});
```

**TrackingRepository Interface에 추가**:
```dart
// 태그 기반 조회 메서드 추가
Future<List<SymptomLog>> getSymptomLogsByTag(String tagName);
Future<List<String>> getAllTags(String userId); // 사용자의 모든 태그 목록
```

---

## 2. 경미한 설계 개선 사항

### 2.1. 입력 검증 테스트 보강

**현재 Plan**:
```dart
// TC-WRS-03: 체중 입력 검증 (실시간)
testWidgets('should validate weight input in real-time', (tester) async {
  await tester.enterText(find.byType(TextField), '350'); // 비현실적
  expect(find.text('300kg 이하로 입력하세요'), findsOneWidget);
});
```

**개선 사항**:
```dart
// 추가 테스트 케이스:
// TC-WRS-09: 최소 체중 검증
testWidgets('should validate minimum weight', (tester) async {
  await tester.enterText(find.byType(TextField), '15'); // 20kg 미만
  expect(find.text('20kg 이상으로 입력하세요'), findsOneWidget);
});

// TC-WRS-10: 소수점 자리 제한
testWidgets('should limit weight decimal places', (tester) async {
  await tester.enterText(find.byType(TextField), '75.567'); // 3자리
  expect(find.text('소수점 한 자리까지 입력 가능합니다'), findsOneWidget);
});

// TC-WRS-11: 비숫자 입력 방지
testWidgets('should prevent non-numeric input', (tester) async {
  await tester.enterText(find.byType(TextField), 'abc');
  expect(find.text('숫자만 입력하세요'), findsOneWidget);
});
```

---

### 2.2. Stream 테스트 개선

**현재 Plan**:
```dart
// TC-ITR-05: Stream 실시간 동기화
test('should watch WeightLogs changes', () async {
  final stream = repository.watchWeightLogs('user-001');

  expectLater(
    stream,
    emitsInOrder([
      [], // 초기 빈 리스트
      [isA<WeightLog>()], // 추가 후
    ]),
  );

  await repository.saveWeightLog(WeightLog(...));
});
```

**개선 사항**:
```dart
// TC-ITR-09: Stream 취소 후 재구독
test('should handle stream cancellation and resubscription', () async {
  final stream = repository.watchWeightLogs('user-001');
  final subscription = stream.listen((_) {});

  await repository.saveWeightLog(WeightLog(...));
  await subscription.cancel(); // 구독 취소

  final newStream = repository.watchWeightLogs('user-001');
  expectLater(newStream, emits([isA<WeightLog>()])); // 최신 상태 반영
});

// TC-ITR-10: 다중 사용자 Stream 격리
test('should isolate streams per user', () async {
  final stream1 = repository.watchWeightLogs('user-001');
  final stream2 = repository.watchWeightLogs('user-002');

  await repository.saveWeightLog(WeightLog(..., userId: 'user-001'));

  expectLater(stream1, emits([isA<WeightLog>()])); // user-001만 업데이트
  expectLater(stream2, emits([])); // user-002는 빈 상태 유지
});
```

---

### 2.3. 성능 테스트 추가

**명세 요구사항** (spec.md BR-F002-05):
- "체중 기록은 3회 터치 이내 완료 가능해야 함"

**현재 Plan**:
```dart
// TC-WRS-05: 터치 횟수 확인 (3회 이내)
testWidgets('should complete recording within 3 touches', (tester) async {
  await tester.tap(find.text('오늘')); // 1회
  await tester.enterText(find.byType(TextField), '75.5'); // 2회
  await tester.tap(find.text('저장')); // 3회

  // 터치 카운터 검증 (실제로는 interaction 추적)
});
```

**개선 사항**:
```dart
// TC-WRS-05 수정 (구체적 검증)
testWidgets('should complete recording within 3 touches', (tester) async {
  int touchCount = 0;
  final gesture = await tester.createGesture();

  // Tap counting wrapper
  Future<void> tapAndCount(Finder finder) async {
    touchCount++;
    await gesture.down(tester.getCenter(finder));
    await gesture.up();
    await tester.pump();
  }

  await tapAndCount(find.text('오늘'));
  await tester.enterText(find.byType(TextField), '75.5');
  touchCount++; // 텍스트 입력도 터치로 간주
  await tapAndCount(find.text('저장'));

  expect(touchCount, lessThanOrEqualTo(3));
});

// Performance 테스트 추가
// TC-WRS-12: 저장 완료 시간
testWidgets('should complete save within 500ms', (tester) async {
  final stopwatch = Stopwatch()..start();

  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
});
```

---

### 2.4. 미래 날짜 선택 방지 보강

**현재 Plan**:
```dart
// TC-DSW-04: 미래 날짜 선택 불가
testWidgets('should disable future dates in calendar', (tester) async {
  final calendarWidget = tester.widget<CalendarDatePicker>(find.byType(CalendarDatePicker));
  expect(calendarWidget.lastDate, DateTime.now().toDateOnly());
});
```

**개선 사항**:
```dart
// TC-DSW-05: 미래 날짜 자동 조정 (Edge Case 명세)
testWidgets('should auto-adjust to today when future date selected', (tester) async {
  DateTime? selectedDate;

  // 프로그래매틱하게 미래 날짜 설정 시도
  final widget = DateSelectionWidget(
    initialDate: DateTime.now().add(Duration(days: 1)), // 내일
    onDateSelected: (date) => selectedDate = date,
  );

  await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  await tester.pumpAndSettle();

  // Assert: 자동으로 오늘로 조정
  expect(selectedDate, DateTime.now().toDateOnly());
  expect(find.text('미래 날짜는 선택할 수 없습니다'), findsOneWidget); // 에러 메시지
});
```

---

## 3. 테스트 커버리지 분석

### 현재 Plan의 테스트 비율:
- Unit Test: ~60% (Entity, DTO, Repository 메서드)
- Integration Test: ~25% (Notifier + Repository)
- Widget Test: ~15% (Screen 렌더링)

### 목표: 80% 이상 (spec.md 완료 조건)

**누락된 테스트 영역**:
1. **에러 처리**: 네트워크 오류, DB 오류 시나리오 (Phase 1 대비)
2. **동시성**: 여러 사용자가 동시에 기록할 때
3. **데이터 마이그레이션**: 스키마 변경 시 기존 데이터 호환성
4. **접근성**: Screen Reader 지원, 키보드 네비게이션

**추가 권장 테스트**:
```dart
// Error Handling
// TC-TN-07: Repository 오류 처리
test('should handle repository errors gracefully', () async {
  final mockRepo = MockTrackingRepository();
  when(() => mockRepo.saveWeightLog(any()))
      .thenThrow(IsarError('Database locked'));

  final notifier = TrackingNotifier(mockRepo);

  await expectLater(
    () => notifier.saveWeightLog(WeightLog(...)),
    throwsA(isA<RepositoryException>()),
  );
});

// Accessibility
// TC-WRS-13: Screen Reader 지원
testWidgets('should have semantic labels for screen readers', (tester) async {
  await tester.pumpWidget(...);

  expect(
    tester.getSemantics(find.byType(TextField)),
    matchesSemantics(label: '체중 입력'),
  );
});
```

---

## 4. 아키텍처 원칙 준수 확인

### ✅ 잘 지켜진 부분:
1. **Layer Dependency**: Presentation → Application → Domain ← Infrastructure (준수)
2. **Repository Pattern**: Interface(Domain) / Implementation(Infrastructure) 분리
3. **TDD Workflow**: Inside-Out (Domain → Infrastructure → Application → Presentation)
4. **Test Pyramid**: Unit 70% / Integration 20% / Widget 10% 목표

### ⚠️ 개선 필요:
1. **경과일 계산 위치**: 명세와 불일치 (spec.md 수정 필요)
2. **F004/F005 연동**: Interface/Contract 명시 부족
3. **에러 처리**: Phase 1 전환 시 네트워크 오류 대비 부족

---

## 5. 수정 우선순위

### P0 (Critical - 구현 전 필수 수정):
1. **중복 기록 확인 로직 추가** (1.1)
2. **isPersistent24h 필드 처리 명확화** (1.3)
3. **F005 증상 체크 화면 연동 추가** (1.5)

### P1 (High - 구현 중 추가):
4. **대처 가이드 연동 계약 정의** (1.4)
5. **컨텍스트 태그 정규화 테스트** (1.6)
6. **입력 검증 테스트 보강** (2.1)

### P2 (Medium - 완료 전 보완):
7. **Stream 테스트 개선** (2.2)
8. **성능 테스트 추가** (2.3)
9. **미래 날짜 자동 조정 테스트** (2.4)

### P3 (Low - 품질 향상):
10. **에러 처리 테스트** (3)
11. **접근성 테스트** (3)

---

## 6. 액션 아이템

### 즉시 조치:
- [ ] spec.md의 경과일 계산 Sequence Diagram 수정 (Application Layer로 변경)
- [ ] plan.md에 1.1~1.6의 누락된 테스트 시나리오 추가
- [ ] CopingGuideService, SymptomCheckScreen 인터페이스 정의

### 구현 중 조치:
- [ ] WeightRecordScreen에 TC-WRS-07~11 추가
- [ ] SymptomRecordScreen에 TC-SRS-07~12 추가
- [ ] IsarTrackingRepository에 TC-ITR-07~10 추가

### QA 단계 조치:
- [ ] 성능 테스트 (3회 터치, 500ms 이내 완료) 수동 검증
- [ ] 접근성 테스트 (Screen Reader, 키보드 네비게이션)
- [ ] Edge Case 수동 테스트 (중복 기록, 미래 날짜 등)

---

## 7. 결론

**Plan 전체 평가**: 60/100점

**강점**:
- TDD 방법론 철저히 적용
- Layer 분리 및 Repository Pattern 준수
- Inside-Out 접근으로 Core Logic 우선

**약점**:
- Edge Case 테스트 부족 (중복 기록, 24시간 지속 여부)
- 외부 모듈 연동(F004/F005) 명세 불명확
- 에러 처리 및 성능 테스트 미흡

**최종 권고**:
1. P0 항목을 반드시 구현 전 plan.md에 반영
2. spec.md의 Sequence Diagram 수정 (경과일 계산 위치)
3. 테스트 커버리지 목표 80% 달성을 위해 P1~P2 항목 추가

**수정 완료 후 예상 점수**: 85/100점

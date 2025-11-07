# UF-011 Plan 검증 결과

## 요약
전반적으로 설계가 spec을 잘 반영하고 있으나, **일부 누락된 요구사항**과 **구조적 개선 필요 사항**이 발견되었습니다.

---

## 1. 누락된 기능

### 1.1 감사 추적 (Audit Trail) 미구현
**Spec 요구사항 (BR-5)**:
> 데이터 무결성을 위해 기록 수정 내역이 로그됨 (투여 계획의 경우 plan_change_history에 저장)

**Plan 상태**:
- 감사 추적 관련 로직이 전혀 포함되지 않음
- Repository에 `logRecordChange()` 같은 메서드가 없음
- UseCase나 Notifier에 변경 이력 저장 로직 없음

**필요한 수정**:
```dart
// Domain Layer에 추가 필요
class LogRecordChangeUseCase {
  Future<void> execute({
    required String userId,
    required String recordId,
    required String recordType, // 'weight', 'symptom', 'dose'
    required String changeType,  // 'update', 'delete'
    required Map<String, dynamic> oldValue,
    required Map<String, dynamic>? newValue,
  });
}

// Repository Interface에 추가
abstract class AuditRepository {
  Future<void> logChange(AuditLog log);
  Future<List<AuditLog>> getChangeLogs(String userId, String recordId);
}

// Notifier에서 수정/삭제 시 감사 로그 생성
await _auditRepo.logChange(AuditLog(...));
```

---

### 1.2 증상 기록 삭제 시 컨텍스트 태그 연쇄 삭제 미명시
**Spec 요구사항 (Edge Case)**:
> 증상 기록 삭제: 연관된 대처 가이드 피드백도 함께 삭제됨, 컨텍스트 태그도 함께 삭제됨

**Plan 상태**:
- SymptomRecordEditNotifier 테스트에 "should delete symptom log including tags" 있으나 구체적 구현 방법 미명시
- Repository 메서드가 연쇄 삭제를 처리하는지 불분명

**필요한 수정**:
```dart
// TrackingRepository Interface에 명시
abstract class TrackingRepository {
  /// 증상 기록 삭제 시 연관된 태그, 피드백도 함께 삭제
  Future<void> deleteSymptomLog(String symptomLogId, {bool cascade = true});
}

// Test에 연쇄 삭제 검증 추가
test('should cascade delete symptom tags and feedback', () async {
  final recordId = 'symptom1';
  when(() => mockRepository.deleteSymptomLog(recordId, cascade: true))
      .thenAnswer((_) async => {});

  await notifier.deleteSymptom(recordId: recordId, userId: 'user123');

  verify(() => mockRepository.deleteSymptomLog(recordId, cascade: true)).called(1);
});
```

---

### 1.3 투여 기록 수정 기능 누락
**Spec 요구사항 (Main Scenario 4)**:
> 사용자가 값을 수정함 (날짜, 체중, 증상 심각도, **투여량, 주사 부위** 등)

**Plan 상태**:
- DoseRecordEditNotifier에 **삭제만** 구현되어 있음
- 투여 기록 수정 관련 테스트, 다이얼로그, UseCase가 전혀 없음

**필요한 수정**:
```dart
// DoseRecordEditNotifier에 추가
class DoseRecordEditNotifier extends AsyncNotifier<void> {
  // 기존 deleteDoseRecord() 외에 추가
  Future<void> updateDoseRecord({
    required String recordId,
    required double newDoseMg,
    required String newInjectionSite,
    String? note,
    required String userId,
  }) async {
    // Validation
    if (newDoseMg <= 0) {
      state = AsyncError('투여량은 0보다 커야 합니다', StackTrace.current);
      return;
    }

    // Update
    await _repo.updateDoseRecord(recordId, newDoseMg, newInjectionSite, note);

    // Recalculate
    await _recalculateNotifier.recalculate(userId);
  }
}

// DoseEditDialog 추가 필요
class DoseEditDialog extends StatefulWidget {
  final DoseRecord record;
  final Function(double doseMg, String site, String? note) onSave;
}
```

---

### 1.4 날짜 수정 기능 미구현
**Spec 요구사항 (Main Scenario 4)**:
> 사용자가 값을 수정함 (**날짜**, 체중, 증상 심각도, 투여량, 주사 부위 등)

**Plan 상태**:
- WeightEditDialog, SymptomEditDialog에 날짜 선택 UI 관련 테스트 없음
- ValidateDateUniqueConstraintUseCase는 있으나 UI와 연결되지 않음

**필요한 수정**:
```dart
// WeightEditDialog 테스트에 추가
testWidgets('should allow changing log date', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WeightEditDialog(
        currentWeight: 70.0,
        currentDate: DateTime(2025, 1, 1),
      ),
    ),
  );

  // 날짜 선택 버튼 탭
  await tester.tap(find.byIcon(Icons.calendar_today));
  await tester.pumpAndSettle();

  // 새로운 날짜 선택
  await tester.tap(find.text('2'));
  await tester.tap(find.text('확인'));
  await tester.pumpAndSettle();

  expect(find.text('2025-01-02'), findsOneWidget);
});

testWidgets('should validate date uniqueness', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WeightEditDialog(
        currentWeight: 70.0,
        currentDate: DateTime(2025, 1, 1),
      ),
    ),
  );

  // 중복 날짜 선택
  await tester.tap(find.byIcon(Icons.calendar_today));
  await tester.pumpAndSettle();
  await tester.tap(find.text('3')); // 이미 기록이 있는 날짜
  await tester.tap(find.text('확인'));
  await tester.pumpAndSettle();

  expect(find.textContaining('이미 기록이 존재'), findsOneWidget);
  expect(find.textContaining('덮어쓰기'), findsOneWidget);
});
```

---

## 2. 구조적 개선 필요 사항

### 2.1 RecalculateStatisticsNotifier의 Provider 타입 오류
**Plan 명시**:
```dart
RecalculateStatisticsNotifier[RecalculateStatisticsNotifier<br/>Provider]
```

**문제점**:
- Application Layer Notifier는 `Provider`가 아닌 `AsyncNotifierProvider` 또는 `NotifierProvider` 사용해야 함
- `recalculate()` 메서드가 Future를 반환하므로 `AsyncNotifierProvider` 적합

**수정**:
```dart
@riverpod
class RecalculateStatisticsNotifier extends AsyncNotifier<RecalculationResult> {
  @override
  Future<RecalculationResult> build() async {
    return RecalculationResult.initial();
  }

  Future<RecalculationResult> recalculate(String userId) async {
    state = const AsyncLoading();
    // ...
  }
}
```

---

### 2.2 Rollback 메커니즘 구체화 부족
**Plan 테스트**:
```dart
test('should rollback on recalculation failure', () async {
  // ...
  verify(() => mockRepository.updateWeightLog(recordId, originalWeight)).called(1);
});
```

**문제점**:
- 재계산 실패 시 롤백 로직은 있으나, **Repository 업데이트 자체가 실패**하는 경우 처리 없음
- 트랜잭션 관리 방법 불명확

**필요한 수정**:
```dart
// WeightRecordEditNotifier
Future<void> updateWeight(...) async {
  state = const AsyncLoading();

  // 1. 원본 데이터 백업
  final originalLog = await _repo.getWeightLog(recordId);

  try {
    // 2. Validation
    final validationResult = _validateUseCase.execute(newWeight);
    if (validationResult.isFailure) {
      state = AsyncError(validationResult.error, StackTrace.current);
      return;
    }

    // 3. Update
    await _repo.updateWeightLog(recordId, newWeight);

    // 4. Recalculate
    try {
      await _recalculateNotifier.recalculate(userId);
    } catch (recalcError) {
      // 5. Rollback on recalculation failure
      await _repo.updateWeightLog(recordId, originalLog.weightKg);
      rethrow;
    }

    state = const AsyncData(null);
  } catch (e, st) {
    // 6. Rollback on any failure
    if (originalLog != null) {
      await _repo.updateWeightLog(recordId, originalLog.weightKg);
    }
    state = AsyncError(e, st);
  }
}
```

---

### 2.3 Repository Interface 위치 오류
**Plan 명시**:
```
Infrastructure Layer (재사용)
TrackingRepository [Interface]
MedicationRepository [Interface]
```

**문제점**:
- Repository Interface는 **Domain Layer**에 있어야 함 (CLAUDE.md 준수)
- Infrastructure Layer에는 구현체(`IsarTrackingRepository`)만 있어야 함

**수정**:
```
Domain Layer:
  lib/features/tracking/domain/repositories/
    tracking_repository.dart (interface)

Infrastructure Layer:
  lib/features/tracking/infrastructure/repositories/
    isar_tracking_repository.dart (implementation)
```

---

### 2.4 DashboardRepository, BadgeRepository 누락
**Plan Architecture Diagram**:
```mermaid
RecalculateStatisticsNotifier --> DashboardRepository
RecalculateStatisticsNotifier --> BadgeRepository
```

**문제점**:
- 이 Repository들이 어느 feature에 속하는지 불명확
- 통계 재계산을 위해 필요한 메서드가 무엇인지 명시 안됨

**필요한 명시**:
```dart
// Domain Layer
abstract class DashboardRepository {
  Future<void> updateWeeklyProgress(String userId, WeeklyProgress progress);
  Future<void> updateContinuousRecordDays(String userId, int days);
  Future<void> updateWeeklySummary(String userId, WeeklySummary summary);
}

abstract class BadgeRepository {
  Future<List<UserBadge>> getUserBadges(String userId);
  Future<void> updateBadgeProgress(String userId, String badgeId, int percentage);
  Future<void> achieveBadge(String userId, String badgeId);
  Future<void> downgradeBadge(String userId, String badgeId); // 조건 미달 시
}
```

---

## 3. 테스트 누락 사항

### 3.1 체중 기록 날짜 중복 시 덮어쓰기 UI 플로우
**Spec 요구사항 (BR-3)**:
> 중복 날짜로 수정 시 덮어쓰기 확인 필요

**Plan 상태**:
- WeightRecordEditNotifier에 `allowOverwrite` 파라미터는 있으나 UI 테스트 없음

**필요한 테스트**:
```dart
testWidgets('should show overwrite confirmation for duplicate date', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WeightEditDialog(
        currentWeight: 70.0,
        currentDate: DateTime(2025, 1, 1),
      ),
    ),
  );

  // 이미 기록이 있는 날짜로 변경
  await tester.tap(find.byIcon(Icons.calendar_today));
  await tester.pumpAndSettle();
  await tester.tap(find.text('3')); // 2025-01-03에 이미 기록 존재
  await tester.tap(find.text('확인'));
  await tester.pumpAndSettle();

  // 덮어쓰기 확인 다이얼로그 표시
  expect(find.text('이미 기록이 존재합니다'), findsOneWidget);
  expect(find.text('덮어쓰기'), findsOneWidget);
  expect(find.text('취소'), findsOneWidget);

  // 덮어쓰기 선택
  await tester.tap(find.text('덮어쓰기'));
  await tester.pumpAndSettle();

  // 기존 기록 삭제 후 새 기록 저장
  verify(() => mockRepo.deleteWeightLog('existing_log_id')).called(1);
  verify(() => mockRepo.updateWeightLog(recordId, newWeight)).called(1);
});
```

---

### 3.2 동시 수정 충돌 처리
**Spec 언급**:
```dart
test('should handle concurrent edit attempts gracefully', () async {
  // Edge case: Multiple users editing same record
  expect(find.textContaining('이미 삭제되었거나'), findsOneWidget);
});
```

**문제점**:
- 테스트는 있으나 구체적 구현 방법 없음
- Optimistic Locking (버전 관리) 또는 Last-Write-Wins 전략 필요

**필요한 구현**:
```dart
// Entity에 version 추가
class WeightLog {
  final String id;
  final int version; // 수정마다 +1
  // ...
}

// Repository에 버전 검증 추가
abstract class TrackingRepository {
  Future<void> updateWeightLog(
    String id,
    double weightKg,
    {required int expectedVersion}
  );
}

// Notifier에서 Conflict 처리
try {
  await _repo.updateWeightLog(recordId, newWeight, expectedVersion: log.version);
} on ConflictException {
  state = AsyncError(
    '다른 기기에서 이미 수정되었습니다. 최신 데이터를 가져와 다시 시도하세요.',
    StackTrace.current,
  );
}
```

---

### 3.3 네트워크 오류 처리 테스트 부족
**QA Sheet 언급**:
> 8. 네트워크 오류 시 에러 처리 확인

**Plan 상태**:
- Manual Testing에만 있고 자동화된 테스트 없음

**필요한 테스트**:
```dart
test('should show retry option on network failure', () async {
  final recordId = 'log1';
  final userId = 'user123';
  when(() => mockRepository.updateWeightLog(recordId, any()))
      .thenThrow(NetworkException('Connection timeout'));

  final notifier = container.read(weightRecordEditNotifierProvider.notifier);
  await notifier.updateWeight(recordId: recordId, newWeight: 68.5, userId: userId);

  final state = container.read(weightRecordEditNotifierProvider);
  expect(state.hasError, true);
  expect(state.error, isA<NetworkException>());
});

// Presentation Layer
testWidgets('should show retry button on network error', (tester) async {
  await tester.pumpWidget(/* ... */);

  // Trigger network error
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  expect(find.text('네트워크 오류가 발생했습니다'), findsOneWidget);
  expect(find.text('다시 시도'), findsOneWidget);

  // Retry
  await tester.tap(find.text('다시 시도'));
  await tester.pumpAndSettle();

  expect(find.text('저장되었습니다'), findsOneWidget);
});
```

---

## 4. 성능 관련 명시 부족

### 4.1 통계 재계산 성능 목표 미달성 우려
**Plan 언급**:
> Performance Check: 통계 재계산 시간 측정 (< 500ms 목표)

**문제점**:
- RecalculateDashboardStatisticsUseCase가 모든 기록을 다시 조회하는 방식
- 증분 업데이트(Incremental Update) 고려 없음

**개선 방안**:
```dart
// Incremental Update 전략
class RecalculateDashboardStatisticsUseCase {
  Future<DashboardData> execute(
    String userId, {
    RecordChangeContext? changeContext,
  }) async {
    if (changeContext != null) {
      // 변경된 레코드만 고려한 증분 업데이트
      return _incrementalUpdate(userId, changeContext);
    } else {
      // 전체 재계산 (초기 로드 시)
      return _fullRecalculation(userId);
    }
  }

  Future<DashboardData> _incrementalUpdate(
    String userId,
    RecordChangeContext context,
  ) async {
    final currentData = await _dashboardRepo.getDashboardData(userId);

    // 예: 체중 기록 1개 삭제 시 -> 주간 진행도 -1만 적용
    if (context.type == 'weight' && context.operation == 'delete') {
      currentData.weeklyProgress.weightRecordCount -= 1;
    }

    return currentData;
  }
}
```

---

### 4.2 대량 삭제 시 성능 이슈
**Spec 명시 (Edge Case)**:
> 다중 기록 작업: 일괄 수정/삭제는 MVP에서 지원하지 않음

**문제점**:
- MVP에서 지원 안 하지만, 사용자가 여러 기록을 개별적으로 연속 삭제할 수 있음
- 각 삭제마다 통계 재계산 -> N번의 쿼리 발생

**최적화 방안**:
```dart
// Debounce/Throttle 적용
class RecalculateStatisticsNotifier extends AsyncNotifier<RecalculationResult> {
  Timer? _debounceTimer;

  Future<void> recalculate(String userId) async {
    // 300ms 내 중복 호출 무시
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () async {
      await _performRecalculation(userId);
    });
  }
}
```

---

## 5. 정리 및 권장사항

### 5.1 Critical (즉시 수정 필요)
1. ✅ **투여 기록 수정 기능 추가** (Spec에 명시되어 있으나 완전 누락)
2. ✅ **날짜 수정 UI 구현** (Spec의 핵심 요구사항)
3. ✅ **감사 추적 (Audit Trail) 구현** (BR-5 위반)
4. ✅ **Repository Interface를 Domain Layer로 이동** (Architecture 원칙 위반)

### 5.2 Important (릴리스 전 필수)
5. ✅ **날짜 중복 시 덮어쓰기 UI 플로우** (BR-3 미완성)
6. ✅ **증상 기록 연쇄 삭제 명시** (Edge Case 불명확)
7. ✅ **Rollback 메커니즘 구체화** (데이터 무결성 이슈)
8. ✅ **동시 수정 충돌 처리** (Acceptance Test에 있으나 구현 없음)

### 5.3 Nice-to-Have (차후 개선)
9. ⚠️ **통계 재계산 성능 최적화** (증분 업데이트)
10. ⚠️ **연속 삭제 시 Debounce 적용**
11. ⚠️ **네트워크 오류 재시도 UI**

### 5.4 Documentation
12. ✅ **DashboardRepository, BadgeRepository 인터페이스 명시**
13. ✅ **RecalculateStatisticsNotifier Provider 타입 수정**

---

## 6. 최종 결론

**설계 적합성**: 60/100
- ✅ Layer 구조는 올바름 (4-Layer + Repository Pattern)
- ✅ TDD 전략 명확함 (Inside-Out)
- ❌ **핵심 기능 누락** (투여 기록 수정, 날짜 수정 UI, 감사 추적)
- ❌ **Edge Case 처리 불완전** (날짜 중복, 연쇄 삭제, 동시 수정)
- ⚠️ 성능 최적화 고려 부족

**권장 조치**:
1. 위 Critical 항목 4개를 Plan에 반영하여 재작성
2. Important 항목 4개를 Implementation Phase에 포함
3. Nice-to-Have는 Phase 2 (Refactoring)에서 처리
4. QA Sheet를 자동화된 테스트로 전환하여 Coverage 향상

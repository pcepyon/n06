# F005: 증상 체크 및 전문가 상담 권장 - Plan 검증 결과

## 검증 일자
2025-11-07

## 검증 결과: ❌ 수정 필요

---

## 1. 중대한 설계 누락

### 1.1. 부작용 기록 자동 생성 로직 누락 (Critical)

**spec.md 요구사항**:
- Main Scenario 5번: "시스템이 자동으로 부작용 기록 생성 (심각도 10점, F002 연동)"
- BR2: "증상 체크 시 자동으로 symptom_logs 테이블에 기록 생성, 심각도는 10점으로 고정"
- Sequence Diagram: "자동 부작용 기록 생성" 단계 존재

**plan.md 현황**:
- `EmergencyCheckNotifier`가 `saveEmergencyCheck()` 메서드만 정의
- `symptom_logs` 테이블에 자동 기록 생성하는 로직 없음
- F002 (부작용 기록) Feature와의 연동 로직 전혀 없음

**수정 방안**:
```dart
// EmergencyCheckNotifier에 추가 필요
class EmergencyCheckNotifier extends AsyncNotifier<List<EmergencySymptomCheck>> {
  final EmergencyCheckRepository _emergencyCheckRepository;
  final SymptomLogRepository _symptomLogRepository; // ✅ 추가 필요
  final MedicationPlanRepository _planRepository; // ✅ 용량 증량 후 경과일 계산용

  Future<void> saveEmergencyCheck(EmergencySymptomCheck check) async {
    // 1. 증상 체크 저장
    await _emergencyCheckRepository.saveEmergencyCheck(check);

    // 2. ✅ 자동으로 부작용 기록 생성 (BR2)
    for (final symptom in check.checkedSymptoms) {
      final symptomLog = SymptomLog(
        id: uuid.v4(),
        userId: check.userId,
        symptomName: symptom,
        severity: 10, // 고정값
        recordedAt: check.checkedAt,
        daysAfterDoseIncrease: await _calculateDaysAfterIncrease(check.userId),
      );
      await _symptomLogRepository.saveSymptomLog(symptomLog);
    }

    // 3. 상태 갱신
    await _refreshState();
  }
}
```

**추가 의존성**:
- `SymptomLogRepository` (F002에서 가져옴)
- `SymptomLog` Entity (F002에서 가져옴)
- `MedicationPlanRepository` (용량 증량 후 경과일 계산용)

---

### 1.2. F002 (부작용 기록) Feature 의존성 누락

**spec.md 요구사항**:
- Sequence Diagram: "BE → BE: 투여 계획 조회하여 용량 증량 후 경과일 계산"
- BR2: "symptom_logs 테이블에 기록 생성"

**plan.md 현황**:
- Section 3.5 Dependencies에 F002 관련 의존성 전혀 없음
- `SymptomLogRepository`, `SymptomLog` Entity 언급 없음

**수정 방안**:
```
### 3.5. EmergencyCheckNotifier (Application)

**Dependencies**:
- EmergencyCheckRepository
- SymptomLogRepository (F002) ✅ 추가
- SymptomLog Entity (F002) ✅ 추가
- MedicationPlanRepository (F001) ✅ 추가
- riverpod_annotation
```

---

## 2. 설계 불완전

### 2.1. Repository Interface 메서드 부족

**spec.md 요구사항**:
- Edge Cases: "증상 체크 중 증상 완화: 기록 삭제 또는 수정 허용"

**plan.md 현황**:
- Section 3.2에서 `deleteEmergencyCheck()` 메서드는 있음
- **수정(update) 메서드 없음**

**수정 방안**:
```dart
// EmergencyCheckRepository Interface에 추가
abstract class EmergencyCheckRepository {
  Future<void> saveEmergencyCheck(EmergencySymptomCheck check);
  Future<List<EmergencySymptomCheck>> getEmergencyChecks(String userId);
  Future<void> deleteEmergencyCheck(String id);
  Future<void> updateEmergencyCheck(EmergencySymptomCheck check); // ✅ 추가
}
```

**해당 테스트 추가 필요**:
```dart
test('증상 체크 수정 시, DB에 업데이트', () async {
  // Arrange
  final check = EmergencySymptomCheck(...);
  await repository.saveEmergencyCheck(check);

  // Act
  final updated = check.copyWith(checkedSymptoms: ['새로운 증상']);
  await repository.updateEmergencyCheck(updated);

  // Assert
  final result = await repository.getEmergencyChecks(check.userId);
  expect(result.first.checkedSymptoms, ['새로운 증상']);
});
```

---

### 2.2. Provider 정의 누락

**plan.md 현황**:
- Section 3.4, 3.5에서 `emergencyCheckRepositoryProvider`, `emergencyCheckNotifierProvider`를 언급
- **실제 Provider 정의 코드 없음**

**수정 방안**:
각 섹션에 Provider 정의 추가

```dart
// Section 3.4 IsarEmergencyCheckRepository 마지막에 추가
@riverpod
EmergencyCheckRepository emergencyCheckRepository(
  EmergencyCheckRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);
  return IsarEmergencyCheckRepository(isar);
}
```

```dart
// Section 3.5 EmergencyCheckNotifier 마지막에 추가
@riverpod
class EmergencyCheckNotifier extends _$EmergencyCheckNotifier {
  @override
  Future<List<EmergencySymptomCheck>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    final repository = ref.watch(emergencyCheckRepositoryProvider);
    return repository.getEmergencyChecks(userId);
  }

  Future<void> saveEmergencyCheck(EmergencySymptomCheck check) async {
    // ...
  }
}
```

---

### 2.3. 데이터베이스 스키마 명시 부족

**spec.md 요구사항**:
- BR4: "체크 기록은 emergency_symptom_checks 테이블에 저장"
- "체크 시간은 timestamptz로 정확히 기록"
- "선택한 증상 목록은 jsonb 형태로 저장"

**plan.md 현황**:
- Section 3.3에서 `EmergencySymptomCheckDto` 정의만 있음
- **Isar 컬렉션 스키마 명시 없음**
- **jsonb → Isar List<String> 매핑 설명 없음**

**수정 방안**:
Section 3.3에 Isar 스키마 예시 추가

```dart
@collection
class EmergencySymptomCheckDto {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late DateTime checkedAt;

  late List<String> checkedSymptoms; // ✅ jsonb → List<String> 매핑

  // Entity ↔ DTO 변환 메서드
  factory EmergencySymptomCheckDto.fromEntity(EmergencySymptomCheck entity) {
    return EmergencySymptomCheckDto()
      ..userId = entity.userId
      ..checkedAt = entity.checkedAt
      ..checkedSymptoms = entity.checkedSymptoms;
  }

  EmergencySymptomCheck toEntity() {
    return EmergencySymptomCheck(
      id: id.toString(),
      userId: userId,
      checkedAt: checkedAt,
      checkedSymptoms: checkedSymptoms,
    );
  }
}
```

**추가 설명 필요**:
- Isar는 PostgreSQL jsonb를 `List<String>`으로 매핑
- Phase 1 전환 시 Supabase에서 jsonb로 변환 필요

---

## 3. 테스트 시나리오 누락

### 3.1. EmergencyCheckNotifier 테스트 시나리오 보완

**spec.md 요구사항**:
- Main Scenario 5번: "자동으로 부작용 기록 생성"

**plan.md 현황**:
- Section 3.5 테스트에 부작용 기록 자동 생성 검증 없음

**추가 테스트 시나리오**:
```dart
test('증상 체크 저장 시, 자동으로 부작용 기록 생성 (BR2)', () async {
  // Arrange
  final check = EmergencySymptomCheck(
    id: 'test-id',
    userId: 'user-123',
    checkedAt: DateTime.now(),
    checkedSymptoms: ['증상1', '증상2'],
  );
  when(() => mockEmergencyCheckRepository.saveEmergencyCheck(check))
      .thenAnswer((_) async => {});
  when(() => mockSymptomLogRepository.saveSymptomLog(any()))
      .thenAnswer((_) async => {});
  when(() => mockPlanRepository.getCurrentPlan('user-123'))
      .thenAnswer((_) async => mockPlan);

  // Act
  final notifier = container.read(emergencyCheckNotifierProvider.notifier);
  await notifier.saveEmergencyCheck(check);

  // Assert
  // ✅ 각 증상마다 부작용 기록 생성 확인
  verify(() => mockSymptomLogRepository.saveSymptomLog(any())).called(2);

  // ✅ 심각도 10점 확인
  final capturedLogs = verify(
    () => mockSymptomLogRepository.saveSymptomLog(captureAny()),
  ).captured;
  expect(capturedLogs.every((log) => log.severity == 10), true);
});

test('부작용 기록 생성 실패 시, 증상 체크도 롤백', () async {
  // Arrange
  final check = EmergencySymptomCheck(...);
  when(() => mockEmergencyCheckRepository.saveEmergencyCheck(check))
      .thenAnswer((_) async => {});
  when(() => mockSymptomLogRepository.saveSymptomLog(any()))
      .thenThrow(Exception('DB 오류'));

  // Act & Assert
  final notifier = container.read(emergencyCheckNotifierProvider.notifier);
  await expectLater(
    notifier.saveEmergencyCheck(check),
    throwsException,
  );

  // ✅ 증상 체크도 저장되지 않아야 함 (트랜잭션 롤백)
  final state = container.read(emergencyCheckNotifierProvider);
  expect(state.value, isEmpty);
});
```

---

### 3.2. Integration Test 시나리오 추가

**plan.md 현황**:
- Section 3.4에서 Repository 단위 Integration Test만 있음
- **전체 플로우 (증상 체크 → 부작용 기록 자동 생성) Integration Test 없음**

**추가 시나리오**:
```dart
group('증상 체크 전체 플로우 Integration', () {
  test('증상 체크 저장 시, emergency_symptom_checks + symptom_logs 모두 저장', () async {
    // Arrange
    final emergencyCheckRepo = IsarEmergencyCheckRepository(isar);
    final symptomLogRepo = IsarSymptomLogRepository(isar);
    final check = EmergencySymptomCheck(
      id: 'test-id',
      userId: 'user-123',
      checkedAt: DateTime.now(),
      checkedSymptoms: ['증상1', '증상2'],
    );

    // Act
    await emergencyCheckRepo.saveEmergencyCheck(check);
    for (final symptom in check.checkedSymptoms) {
      final log = SymptomLog(
        id: uuid.v4(),
        userId: check.userId,
        symptomName: symptom,
        severity: 10,
        recordedAt: check.checkedAt,
      );
      await symptomLogRepo.saveSymptomLog(log);
    }

    // Assert
    final savedChecks = await emergencyCheckRepo.getEmergencyChecks('user-123');
    final savedLogs = await symptomLogRepo.getSymptomLogs('user-123');
    expect(savedChecks.length, 1);
    expect(savedLogs.length, 2); // ✅ 증상 2개 → 부작용 기록 2개
    expect(savedLogs.every((log) => log.severity == 10), true);
  });
});
```

---

## 4. Edge Case 처리 보완

### 4.1. spec.md Edge Cases 반영 누락

**spec.md 요구사항**:
- "같은 증상 반복 체크: 각 기록 별도 저장 (날짜시간으로 구분)"
- "증상 체크 중 증상 완화: 기록 삭제 또는 수정 허용"

**plan.md 현황**:
- Section 3.1 Edge Cases에 "중복 증상 처리 (리스트에 중복 허용)" 언급
- **하지만 "같은 증상을 다른 시간에 체크"하는 케이스 테스트 없음**

**추가 테스트**:
```dart
// Section 3.4 IsarEmergencyCheckRepository
test('같은 증상 반복 체크 시, 별도 기록으로 저장', () async {
  // Arrange
  final check1 = EmergencySymptomCheck(
    id: '1',
    userId: 'user-123',
    checkedAt: DateTime(2025, 1, 1, 10, 0),
    checkedSymptoms: ['24시간 이상 계속 구토'],
  );
  final check2 = EmergencySymptomCheck(
    id: '2',
    userId: 'user-123',
    checkedAt: DateTime(2025, 1, 1, 14, 0), // 4시간 후
    checkedSymptoms: ['24시간 이상 계속 구토'], // 같은 증상
  );

  // Act
  await repository.saveEmergencyCheck(check1);
  await repository.saveEmergencyCheck(check2);

  // Assert
  final result = await repository.getEmergencyChecks('user-123');
  expect(result.length, 2); // ✅ 별도 기록
  expect(result[0].checkedAt, DateTime(2025, 1, 1, 14, 0)); // 최신순
  expect(result[1].checkedAt, DateTime(2025, 1, 1, 10, 0));
});
```

---

## 5. 문서화 개선

### 5.1. Architecture Diagram 보완

**현재 Diagram**:
- F002 (SymptomLog) 의존성 표시 없음

**수정 방안**:
```mermaid
graph TD
    subgraph Presentation
        A[EmergencyCheckScreen]
        B[ConsultationRecommendationDialog]
    end

    subgraph Application
        C[EmergencyCheckNotifier]
        D[emergencyCheckNotifierProvider]
    end

    subgraph Domain
        E[EmergencySymptomCheck Entity]
        F[EmergencyCheckRepository Interface]
    end

    subgraph Infrastructure
        G[EmergencySymptomCheckDto]
        H[IsarEmergencyCheckRepository]
        I[emergencyCheckRepositoryProvider]
    end

    subgraph "F002 Dependencies"
        J[SymptomLog Entity]
        K[SymptomLogRepository]
    end

    A -->|watch/read| D
    B -->|read| D
    C -->|uses| F
    C -->|uses| K  %% ✅ 추가
    D -->|provides| C
    C -->|returns| E
    C -->|creates| J  %% ✅ 추가
    H -.implements.-> F
    I -->|provides| H
    G -->|toEntity| E
    E -->|fromEntity| G
    H -->|uses| G

    style E fill:#e1f5ff
    style F fill:#e1f5ff
    style G fill:#fff4e1
    style H fill:#fff4e1
    style C fill:#f0ffe1
    style A fill:#ffe1f5
    style B fill:#ffe1f5
    style J fill:#ffe1e1  %% ✅ 추가
    style K fill:#ffe1e1  %% ✅ 추가
```

---

### 5.2. Implementation Order 수정

**현재**:
```
1. Domain Layer
2. Infrastructure Layer
3. Application Layer
4. Presentation Layer
```

**수정 방안**:
```
0. ✅ F002 의존성 확인 (SymptomLog, SymptomLogRepository)
1. Domain Layer
   ├─ EmergencySymptomCheck Entity
   └─ EmergencyCheckRepository Interface (✅ updateEmergencyCheck 추가)
2. Infrastructure Layer
   ├─ EmergencySymptomCheckDto (✅ Isar 스키마 명시)
   └─ IsarEmergencyCheckRepository (✅ update 메서드 추가)
3. Application Layer
   └─ EmergencyCheckNotifier (✅ SymptomLog 자동 생성 로직 추가)
4. Presentation Layer
   ├─ ConsultationRecommendationDialog
   └─ EmergencyCheckScreen
5. ✅ Integration Test (전체 플로우: 증상 체크 → 부작용 기록 자동 생성)
```

---

## 6. 수정 우선순위

### Priority 1 (Critical - 즉시 수정 필요)
1. ✅ **EmergencyCheckNotifier에 부작용 기록 자동 생성 로직 추가** (BR2 위반)
2. ✅ **F002 의존성 추가** (SymptomLogRepository, SymptomLog Entity)
3. ✅ **부작용 기록 자동 생성 테스트 시나리오 추가**

### Priority 2 (High - 설계 완성도)
4. ✅ **EmergencyCheckRepository에 updateEmergencyCheck 메서드 추가**
5. ✅ **Provider 정의 명시**
6. ✅ **전체 플로우 Integration Test 추가**

### Priority 3 (Medium - 문서 품질)
7. ✅ **Isar 스키마 명시 (jsonb 매핑 설명)**
8. ✅ **Architecture Diagram에 F002 의존성 표시**
9. ✅ **같은 증상 반복 체크 Edge Case 테스트 추가**

---

## 7. 결론

**plan.md의 주요 문제점**:
1. **spec.md의 핵심 요구사항 (BR2: 부작용 기록 자동 생성) 누락** → Critical
2. **F002 Feature 의존성 전혀 고려하지 않음** → Critical
3. **Repository Interface 불완전 (update 메서드 없음)** → High
4. **테스트 시나리오 불충분 (자동 생성 검증 없음)** → High
5. **문서화 부족 (Provider 정의, 스키마 명시 없음)** → Medium

**수정 후 재검증 필요**:
- [ ] Priority 1 항목 모두 반영
- [ ] TDD 순서에 F002 의존성 통합 단계 추가
- [ ] Section 3.5 EmergencyCheckNotifier 전면 재작성
- [ ] Integration Test 시나리오 추가
- [ ] Code Review 체크리스트에 "F002 연동 검증" 항목 추가

**예상 영향 범위**:
- EmergencyCheckNotifier (전면 수정)
- EmergencyCheckRepository Interface (메서드 추가)
- IsarEmergencyCheckRepository (메서드 구현)
- 테스트 코드 (30% 이상 추가)
- Architecture Diagram (의존성 관계 추가)

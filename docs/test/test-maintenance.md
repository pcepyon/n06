# Test Maintenance Rules - AI Agent 기반 개발 환경

## 문제 상황 진단

현재 프로젝트는 다음 상황에 직면했습니다:

1. **TDD로 시작**: 초기에 Test-First 방식으로 개발
2. **리팩토링 및 아키텍처 변화**: Phase 0 (Isar) → Phase 1 (Supabase) 전환
3. **테스트 유지보수 부재**: 코드는 변경되었으나 테스트는 동기화되지 않음
4. **AI Agent 기반 개발**: 대부분의 개발이 AI Agent를 통해 진행

**결과**: 테스트 실패 발생 (81개 성공, 5개 실패)

---

## 테스트 유지보수 프로세스

### Phase 1: 현재 상태 진단 (Test Audit)

AI Agent에게 다음 작업을 요청:

```
현재 테스트 스위트의 상태를 진단하세요:
1. 모든 테스트 실행 후 실패 목록 작성
2. 실패 원인 분류:
   - 아키텍처 변경으로 인한 실패 (예: Isar → Supabase)
   - 구현 디테일 변경으로 인한 실패
   - 비즈니스 로직 변경으로 인한 실패
   - 환경 설정 문제 (예: binding 초기화)
3. 각 실패 케이스에 대한 수정 전략 제안
```

**현재 프로젝트 진단 결과 예시:**
- 81개 성공, 5개 실패, 1개 스킵
- 실패 원인:
  - Mock 설정 오류 (notification_scheduler_test.dart)
  - Flutter binding 초기화 누락 (permission_service_test.dart)
  - Widget 테스트 설정 문제 (feedback_widget_test.dart)

### Phase 2: 테스트 분류 및 우선순위

#### 2.1 테스트 레벨별 분류

```
테스트를 다음 기준으로 분류하고 우선순위를 매기세요:

1. Domain Layer Tests (최우선)
   - Entities
   - UseCases
   - Value Objects
   - 이유: 비즈니스 로직의 핵심, 아키텍처 변경에 독립적

2. Application Layer Tests (우선)
   - Notifiers
   - State Management
   - 이유: 사용자 시나리오 보장

3. Infrastructure Layer Tests (조건부)
   - Repository Implementations
   - DTOs / Data Conversion
   - 이유: 아키텍처 변경 시 재작성 필요 (Phase 0 → Phase 1)

4. Presentation Layer Tests (선택적)
   - Widget Tests
   - Screen Tests
   - 이유: UI 변경이 잦고, 유지보수 비용이 높음
```

#### 2.2 아키텍처 변경 영향 분석

**Phase 0 → Phase 1 전환 시나리오:**

| 테스트 레벨 | 영향도 | 유지보수 전략 |
|------------|--------|--------------|
| Domain (Entity, UseCase) | ⭕ 없음 | 그대로 유지 |
| Application (Notifier) | 🔶 낮음 | Mock Repository 사용 → 변경 불필요 |
| Infrastructure (Repository Impl) | 🔴 높음 | **재작성 필요** (Isar → Supabase) |
| Presentation (Widget) | 🔶 낮음 | 데이터 소스 독립적 → 변경 불필요 |

**결론**: Infrastructure Layer 테스트만 재작성, 나머지는 유지

### Phase 3: 테스트 리팩토링 전략

#### 3.1 Implementation Detail vs Behavior

**❌ 안티패턴: Implementation Detail 테스트**

```dart
// 나쁜 예: Isar 특정 구현을 테스트
test('should use Isar writeTxn for saving', () {
  final isar = MockIsar();
  final repo = IsarMedicationRepository(isar);

  await repo.saveDose(dose);

  verify(() => isar.writeTxn(any())).called(1); // ❌ 구현 디테일
});
```

**✅ 좋은 패턴: Behavior 테스트**

```dart
// 좋은 예: 동작을 테스트 (Isar든 Supabase든 동일)
test('should save dose and return success', () async {
  final repo = FakeMedicationRepository(); // Fake 사용

  await repo.saveDose(dose);

  final savedDoses = await repo.getDoses(userId);
  expect(savedDoses, contains(dose)); // ✅ 결과 검증
});
```

#### 3.2 Mock vs Fake vs Stub

**사용 기준:**

| 타입 | 언제 사용 | 예시 |
|------|----------|------|
| **Fake** | 실제 로직의 간단한 구현 | In-memory Repository |
| **Stub** | 미리 정의된 응답 반환 | 고정된 데이터 반환 |
| **Mock** | 상호작용 검증 필요 | 메서드 호출 횟수 확인 |

**AI Agent 지침:**

```
테스트 작성 시 다음 우선순위로 선택하세요:
1. Fake (가장 선호): 실제 동작과 유사, 아키텍처 변경에 강건
2. Stub (차선): 단순 데이터 반환만 필요할 때
3. Mock (최후): 상호작용 검증이 필수적일 때만
```

#### 3.3 Test Data Builders

**재사용 가능한 테스트 데이터 생성:**

```dart
// test/helpers/builders/dose_record_builder.dart
class DoseRecordBuilder {
  String _userId = 'test-user';
  double _doseMg = 0.5;
  DateTime _administeredAt = DateTime.now();

  DoseRecordBuilder withUserId(String userId) {
    _userId = userId;
    return this;
  }

  DoseRecordBuilder withDose(double doseMg) {
    _doseMg = doseMg;
    return this;
  }

  DoseRecord build() => DoseRecord(
    userId: _userId,
    doseMg: _doseMg,
    administeredAt: _administeredAt,
  );
}

// 사용
final dose = DoseRecordBuilder()
  .withUserId('user-123')
  .withDose(1.0)
  .build();
```

**AI Agent 지침:**

```
복잡한 엔티티의 테스트 데이터가 3회 이상 중복되면 Builder 패턴을 적용하세요.
```

### Phase 4: 테스트 실행 전략

#### 4.1 CI/CD Integration

**필수 체크:**

```yaml
# .github/workflows/test.yml
name: Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter test --platform chrome  # Widget tests
```

#### 4.2 Test Coverage 기준

```
최소 커버리지 목표:
- Domain Layer: 95% (비즈니스 로직 핵심)
- Application Layer: 85% (상태 관리)
- Infrastructure Layer: 70% (구현체, 아키텍처 변경 시 재작성)
- Presentation Layer: 60% (UI, 변경 빈도 높음)
```

**AI Agent 지침:**

```
새 기능 구현 시:
1. Domain UseCase 테스트부터 작성 (TDD)
2. Application Notifier 테스트 작성
3. Infrastructure 테스트는 선택적 (Phase 전환 고려)
4. Presentation 테스트는 critical path만
```

#### 4.3 Flaky Test 관리

**Flaky Test 식별:**

```bash
# 같은 테스트를 10번 실행하여 불안정성 감지
for i in {1..10}; do flutter test; done | grep -E "PASSED|FAILED"
```

**원인 및 해결:**

| 원인 | 증상 | 해결책 |
|------|------|--------|
| 시간 의존성 | `DateTime.now()` 사용 | `Clock` 주입 또는 `fake_async` |
| 비동기 타이밍 | Race condition | `await` 명시, `pumpAndSettle()` |
| 외부 의존성 | 네트워크, DB | Mock/Fake 사용 |
| 공유 상태 | 테스트 간 간섭 | `setUp()`/`tearDown()` 격리 |

### Phase 5: 테스트 부채 관리

#### 5.1 테스트 부채 발생 시나리오

**언제 테스트가 부채가 되는가?**

1. **아키텍처 변경 후 방치**
   - Phase 0 → Phase 1 전환 후 Isar 테스트 그대로 유지
   - **해결**: Infrastructure 테스트 재작성 또는 삭제

2. **구현 디테일 테스트**
   - Mock 상호작용 검증 과다 (`verify()` 남용)
   - **해결**: Behavior 테스트로 전환

3. **중복 테스트**
   - 같은 시나리오를 여러 레이어에서 반복 테스트
   - **해결**: 테스트 피라미드 원칙 적용

#### 5.2 테스트 부채 청산 프로세스

**AI Agent 작업 지침:**

```
테스트 부채 청산 작업:

1. 실패 테스트 분석
   - 각 실패 케이스의 근본 원인 파악
   - 수정 vs 삭제 vs 재작성 결정

2. 테스트 카테고리별 작업
   a) Domain Tests: 수정 우선 (비즈니스 로직 보존)
   b) Application Tests: 수정 (Mock 의존성 확인)
   c) Infrastructure Tests: 재작성 (Supabase 기준)
   d) Presentation Tests: 선택적 삭제 (ROI 낮음)

3. 작업 우선순위
   Priority 1: Domain Layer (1-2일)
   Priority 2: Application Layer (2-3일)
   Priority 3: Infrastructure Layer (3-4일)
   Priority 4: Presentation Layer (선택적)

4. 완료 기준
   - 모든 테스트 통과 (0 failures)
   - 커버리지 목표 달성
   - Flaky test 없음 (10회 연속 성공)
```

---

## AI Agent 개발 시 테스트 규칙

### Rule 1: TDD Cycle 준수

**모든 새 기능/수정은 Test-First:**

```
AI Agent 작업 순서:
1. 실패하는 테스트 작성 (RED)
2. 최소 구현으로 통과 (GREEN)
3. 리팩토링 (REFACTOR)
4. 테스트 다시 실행하여 통과 확인
```

**예외 케이스:**
- Spike (탐색적 개발): 완료 후 테스트 추가
- UI 프로토타입: Golden Test 또는 Manual Test
- 아키텍처 전환: Infrastructure 테스트는 전환 후 작성

### Rule 2: 테스트 격리 (Isolation)

**각 테스트는 독립적:**

```dart
// ✅ 좋은 예
setUp(() {
  repository = FakeMedicationRepository();
  notifier = MedicationNotifier(repository: repository);
});

tearDown(() {
  repository.clear();
});

// ❌ 나쁜 예 (공유 상태)
final repository = FakeMedicationRepository(); // 전역 변수
```

### Rule 3: 레이어별 테스트 전략

**Domain Layer:**
```
✅ 필수 테스트:
- Entity 생성/변환 로직
- UseCase 비즈니스 로직
- Value Object 유효성 검증

❌ 불필요:
- Getter/Setter만 있는 단순 Entity
```

**Application Layer:**
```
✅ 필수 테스트:
- Notifier 상태 전환
- 에러 핸들링
- 비동기 작업 완료

❌ 불필요:
- Repository Mock 상호작용 세부사항
```

**Infrastructure Layer:**
```
✅ 필수 테스트:
- DTO ↔ Entity 변환
- Repository 구현 (Fake로 간단히)

❌ 불필요:
- Supabase SDK 메서드 호출 검증
- 데이터베이스 쿼리 세부사항
```

**Presentation Layer:**
```
✅ 필수 테스트:
- Critical User Flow (로그인, 결제 등)
- 에러 상태 UI 표시

❌ 불필요:
- 모든 위젯의 Golden Test
- 단순 Text 표시 검증
```

### Rule 4: 아키텍처 변경 대비

**Phase 전환 시 최소 영향:**

```dart
// ✅ 좋은 예: Repository Interface 의존
test('should load doses from repository', () async {
  final repository = FakeMedicationRepository(); // Fake 사용
  final notifier = MedicationNotifier(repository: repository);

  await notifier.loadDoses('user-123');

  expect(notifier.state, isA<AsyncData<List<Dose>>>()); // 결과 검증
});

// ❌ 나쁜 예: 구체 구현 의존
test('should load doses from Supabase', () async {
  final supabase = MockSupabaseClient();
  final repository = SupabaseMedicationRepository(supabase);

  when(() => supabase.from('dose_records').select()).thenReturn(...);
  // Phase 2로 전환 시 이 테스트 전체 재작성 필요!
});
```

### Rule 5: 테스트 코드도 프로덕션 코드처럼

**테스트 코드 품질 기준:**

```
1. 명확한 네이밍
   - 테스트 이름: "should [expected behavior] when [condition]"
   - 예: "should return empty list when user has no doses"

2. AAA 패턴 준수
   // Arrange
   final repository = FakeMedicationRepository();

   // Act
   final doses = await repository.getDoses(userId);

   // Assert
   expect(doses, isEmpty);

3. 한 테스트 당 한 가지 검증
   ❌ expect(doses.length, 3); expect(doses[0].doseMg, 0.5); ...
   ✅ 여러 테스트로 분리

4. Magic Number 제거
   ❌ expect(result, 42);
   ✅ const expectedDoseMg = 0.5; expect(result.doseMg, expectedDoseMg);
```

---

## 테스트 유지보수 체크리스트

### 매 커밋 전

```
[ ] 모든 테스트 통과 (`flutter test`)
[ ] 새 코드에 대한 테스트 작성 완료
[ ] 테스트 커버리지 목표 유지
[ ] Flaky test 없음
[ ] 테스트 실행 시간 < 2분 (Unit tests)
```

### 매 PR 전

```
[ ] CI 테스트 통과
[ ] 변경된 레이어의 테스트 업데이트
[ ] Test-First 원칙 준수 확인
[ ] 테스트 코드 리뷰 (일반 코드와 동일 기준)
```

### 아키텍처 변경 시 (Phase 전환)

```
[ ] Domain Layer 테스트: 그대로 유지 (0% 재작성)
[ ] Application Layer 테스트: Mock 업데이트 (< 10% 재작성)
[ ] Infrastructure Layer 테스트: 재작성 (100%)
[ ] Presentation Layer 테스트: 선택적 업데이트
[ ] 전체 테스트 스위트 실행 성공
```

### 분기별 테스트 감사 (Quarterly Test Audit)

```
[ ] Flaky test 제거 (10회 연속 실행으로 검증)
[ ] 느린 테스트 최적화 (> 1초 소요 테스트)
[ ] 중복 테스트 제거
[ ] Outdated 테스트 삭제 (기능 제거된 경우)
[ ] 테스트 커버리지 리포트 생성
[ ] 테스트 부채 측정 및 청산 계획 수립
```

---

## AI Agent 프롬프트 템플릿

### 테스트 작성 요청

```
새 기능 [기능명]을 TDD로 구현해주세요.

요구사항:
1. Domain Layer 테스트부터 작성 (RED)
2. 최소 구현으로 통과시키기 (GREEN)
3. 리팩토링 (REFACTOR)
4. Application Layer 테스트 추가
5. Infrastructure Layer는 Fake Repository 사용
6. Presentation Layer는 critical path만 테스트

준수사항:
- docs/tdd.md 프로세스 따르기
- Test-First 원칙
- AAA 패턴 사용
- 한 테스트 당 한 가지 검증
- Behavior 테스트 (Implementation Detail 아님)
```

### 테스트 수정 요청

```
실패한 테스트를 수정해주세요: [테스트 파일명]

분석 단계:
1. 실패 원인 분류:
   - 아키텍처 변경?
   - 비즈니스 로직 변경?
   - 환경 설정 문제?
2. 수정 전략 결정:
   - 수정 (Domain/Application)
   - 재작성 (Infrastructure)
   - 삭제 (Outdated)

수정 시 준수사항:
- 원래 테스트 의도 유지
- Behavior 테스트로 전환 (가능하면)
- Mock → Fake 전환 고려
- 테스트 격리 유지
```

### 테스트 리팩토링 요청

```
테스트 스위트를 리팩토링해주세요: [기능명]

목표:
1. Implementation Detail 테스트 → Behavior 테스트
2. Mock → Fake 전환
3. Test Data Builder 도입
4. 중복 제거
5. 테스트 실행 시간 단축

유지사항:
- 테스트 커버리지 동일 수준 유지
- 모든 테스트 통과
- 기존 테스트 의도 보존
```

---

## 실전 예제: Phase 1 전환 후 테스트 복구

### Before (Phase 0 - Isar)

```dart
// FAILING: infrastructure/repositories/isar_medication_repository_test.dart
test('should save dose using Isar writeTxn', () async {
  final isar = MockIsar();
  final repo = IsarMedicationRepository(isar);

  await repo.saveDose(dose);

  verify(() => isar.writeTxn(any())).called(1); // ❌ Isar 특정
});
```

### After (Phase 1 - Supabase)

**전략 1: Infrastructure 테스트 재작성 (선택적)**

```dart
// infrastructure/repositories/supabase_medication_repository_test.dart
test('should save dose to Supabase', () async {
  final supabase = MockSupabaseClient();
  final repo = SupabaseMedicationRepository(supabase);

  await repo.saveDose(dose);

  // Supabase 호출 검증 (선택적 - 구현 디테일)
  verify(() => supabase.from('dose_records').insert(any())).called(1);
});
```

**전략 2: Behavior 테스트로 전환 (권장)**

```dart
// domain/repositories/medication_repository_test.dart
test('should save and retrieve dose', () async {
  final repo = FakeMedicationRepository(); // Isar든 Supabase든 무관

  await repo.saveDose(dose);
  final doses = await repo.getDoses(userId);

  expect(doses, contains(dose)); // ✅ 결과 검증
});
```

**결과**: Phase 2 전환 시 테스트 재작성 불필요

---

## 핵심 원칙 요약

### 1. Test Behavior, Not Implementation
- ✅ "사용자가 투여 기록을 저장하면, 목록에서 조회된다"
- ❌ "Repository가 Isar writeTxn을 호출한다"

### 2. Prefer Fakes over Mocks
- ✅ In-memory Fake Repository
- ❌ Mock with `verify()` everywhere

### 3. Test at the Right Level
- Domain: 95% 커버리지 (비즈니스 핵심)
- Application: 85% 커버리지 (사용자 시나리오)
- Infrastructure: 70% 커버리지 (구현체, 변경 가능)
- Presentation: 60% 커버리지 (UI, ROI 낮음)

### 4. Architecture-Change Resilient
- Repository Pattern으로 추상화
- Interface 의존, 구현 독립
- Phase 전환 시 Infrastructure만 재작성

### 5. AI Agent Friendly
- 명확한 테스트 네이밍
- AAA 패턴 일관성
- Test Data Builder 재사용
- 테스트 격리 (Isolation)

---

## 다음 단계

### 즉시 실행 (1주 이내)

1. **테스트 부채 청산**
   ```bash
   flutter test  # 실패 목록 확인
   # AI Agent에게 각 실패 케이스 수정 요청
   ```

2. **Infrastructure 테스트 재작성/삭제**
   - Isar 관련 테스트 식별
   - Supabase 기준 재작성 또는 삭제

3. **CI/CD에 테스트 추가**
   ```yaml
   # .github/workflows/test.yml
   - run: flutter test --coverage
   ```

### 중기 계획 (1개월 이내)

1. **Test Data Builder 도입**
   - 복잡한 엔티티 (DoseRecord, SymptomLog 등)
   - `test/helpers/builders/` 디렉토리 생성

2. **Fake Repository 구현**
   - In-memory 구현으로 Mock 대체
   - `test/fakes/` 디렉토리 생성

3. **테스트 커버리지 목표 설정**
   - Domain: 95%
   - Application: 85%
   - Infrastructure: 70%
   - Presentation: 60%

### 장기 계획 (분기별)

1. **테스트 감사 (Quarterly Audit)**
   - Flaky test 제거
   - 느린 테스트 최적화
   - 중복 제거

2. **테스트 문서 업데이트**
   - `docs/tdd.md` 실전 예제 추가
   - AI Agent 프롬프트 템플릿 개선

3. **테스트 메트릭 모니터링**
   - 커버리지 트렌드
   - 테스트 실행 시간
   - Flaky test 발생률

---

## 참고 자료

### 프로젝트 문서
- `docs/tdd.md`: TDD 프로세스
- `docs/code_structure.md`: 아키텍처 레이어
- `docs/techstack.md`: Phase 전환 전략

### 외부 자료
- [Test-Driven Development Best Practices 2025](https://www.nopaccelerate.com/test-driven-development-guide-2025/)
- [Agentic Testing: AI Agents in Software Testing](https://www.uipath.com/ai/what-is-agentic-testing)
- [Flutter Clean Architecture Testing](https://betterprogramming.pub/flutter-clean-architecture-test-driven-development-practical-guide-445f388e8604)

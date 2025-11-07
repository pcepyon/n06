# Plan Check 전체 요약

## 검토 일시
2025-11-07

## 검토 대상
- docs/001 ~ docs/015 (15개 폴더)
- 각 폴더의 spec.md와 plan.md 비교 분석

---

## 전반적인 문제 패턴

### 1. 공통 이슈 (전체 Plan에서 반복적으로 발견됨)

#### 1.1 AuthRepository 인터페이스 정의 누락 또는 불명확
**발견 위치**: docs/001, docs/010

**문제**:
- 여러 plan에서 `AuthRepository` 인터페이스를 참조하지만 정의가 명확하지 않음
- 특히 `clearSession()`, `getCurrentUser()` 등의 메서드 시그니처가 일관되지 않음

**권장 수정**:
```dart
// 공통 AuthRepository 인터페이스를 baseline/architecture.md에 정의하고
// 각 plan에서 참조하도록 변경

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<void> clearSession();
  Future<void> saveUser(User user);
  Future<void> updateLastLogin();
}
```

**영향도**: 높음 (여러 feature에 걸쳐 의존성 존재)

---

#### 1.2 Provider 정의 누락
**발견 위치**: docs/001, docs/002, docs/003, docs/004, docs/010

**문제**:
- Plan에서 Provider를 참조하지만 정의 위치가 명시되지 않음
- 예: `authRepositoryProvider`, `trackingNotifierProvider`, `medicationRepositoryProvider`

**권장 수정**:
각 Plan의 Section 1.1 "모듈 목록"에 다음 추가:

```markdown
### Providers
- `{feature}RepositoryProvider`: `{feature}/infrastructure/providers/repository_provider.dart`
- `{feature}NotifierProvider`: `{feature}/application/providers/notifier_provider.dart`
```

**영향도**: 중간 (구현 시 혼란 야기 가능)

---

#### 1.3 Navigation Logic 구현 위치 불명확
**발견 위치**: docs/001, docs/002, docs/010

**문제**:
- 로그인 성공 후 → 온보딩 또는 홈
- 로그아웃 후 → 로그인 화면
- 증상 기록 후 → 가이드 표시 또는 증상 체크

이러한 화면 전환 로직의 책임 소재가 불명확함

**권장 수정**:
AppRouter에 통합된 네비게이션 로직 추가:

```markdown
### Navigation Strategy
- **Declarative Routing**: GoRouter의 `redirect` 활용
- **AuthNotifier 상태 감지**: `ref.listen(authNotifierProvider)` 사용
- **조건부 리다이렉트**:
  - 인증 상태 `null` → `/login`
  - 최초 로그인 + 온보딩 미완료 → `/onboarding`
  - 로그인 완료 → `/home`

**Implementation**:
- AppRouter는 각 Notifier의 상태 변화를 감지하여 자동 라우팅
- Screen은 명시적 navigation 호출 최소화
```

**영향도**: 높음 (Clean Architecture 원칙 준수 여부와 직결)

---

#### 1.4 Edge Case 구현 책임 불명확
**발견 위치**: docs/001 (재시도 로직), docs/010 (토큰 삭제 재시도)

**문제**:
- Spec에는 "최대 3회 재시도" 명시
- Plan에서 Repository Layer에 재시도 로직 배치
- 하지만 "재시도 후 다음 단계 진행"은 비즈니스 로직 → Domain Layer에 있어야 함

**예시 (docs/010)**:
```
Spec: "토큰 삭제 실패 시 재시도, 최대 3회 재시도 후에도 실패 시 세션 정보만 초기화"
Plan: FlutterSecureStorageRepository에 재시도 로직 구현 (잘못됨)
```

**권장 수정**:
- Repository: 단순 예외 throw
- UseCase: 재시도 로직 + 실패 시 대응 전략

```dart
// UseCase (Domain)
Future<void> execute() async {
  for (int i = 0; i < 3; i++) {
    try {
      await storageRepository.clearTokens();
      break;
    } catch (e) {
      if (i == 2) {
        // 3회 실패 시에도 세션 초기화 진행
        logger.warning('Token deletion failed, proceeding with session clear');
      }
    }
  }
  await authRepository.clearSession();
}
```

**영향도**: 높음 (Layer 책임 분리 원칙 위반)

---

#### 1.5 DTO 변환 로직 테스트 누락
**발견 위치**: docs/002, docs/003, docs/004

**문제**:
- DTO ↔ Entity 변환 테스트에 Round-trip 테스트 부족
- 특히 JSON 직렬화가 필요한 복잡한 구조 (e.g., `EscalationStep`, `SymptomContextTag`)

**권장 추가**:
```dart
test('should preserve data in round-trip conversion', () {
  // Arrange
  final original = {Entity}(...);

  // Act
  final dto = {Dto}.fromEntity(original);
  final converted = dto.toEntity();

  // Assert
  expect(converted, equals(original));
});
```

**영향도**: 중간 (데이터 손실 가능성)

---

### 2. Feature별 특정 이슈

#### 2.1 docs/001 (소셜 로그인)

**이슈**: OAuth 취소/실패 시 처리 불명확
- Spec: "OAuth 취소 시 로그인 화면 유지, 안내 메시지 표시"
- Plan: 테스트 시나리오에 포함되지 않음

**권장 추가**:
```dart
test('should handle OAuth cancellation gracefully', () async {
  // Arrange
  when(mockOAuthService.authenticateWithKakao())
      .thenThrow(OAuthCancelledException());

  // Act
  await notifier.loginWithKakao();

  // Assert
  final state = container.read(authNotifierProvider);
  expect(state.hasError, isTrue);
  expect(state.error, isA<OAuthCancelledException>());
});
```

---

#### 2.2 docs/002 (온보딩)

**이슈 1**: 트랜잭션 처리 명시 부족
- Spec BR-3: "모든 온보딩 데이터는 원자적으로 저장되어야 함"
- Plan: 트랜잭션 구현 방법이 명시되지 않음

**권장 추가**:
```markdown
### 3.3.2 OnboardingNotifier - Transaction Handling

**Test Scenario**:
```dart
test('should rollback all data when any save fails', () async {
  // Arrange
  when(() => mockProfileRepo.saveUserProfile(any()))
      .thenAnswer((_) async {});
  when(() => mockMedicationRepo.saveDosagePlan(any()))
      .thenThrow(Exception('DB error'));

  // Act
  await notifier.saveOnboardingData();

  // Assert
  verify(() => mockProfileRepo.deleteUserProfile(any())).called(1);
  final state = container.read(onboardingNotifierProvider);
  expect(state.hasError, isTrue);
});
```

**Implementation**:
- Isar의 `writeTxn` 활용
- 단일 트랜잭션 내에서 모든 저장 수행
- 실패 시 자동 롤백
```

**이슈 2**: 증량 계획 검증 로직 중복
- `ValidateDosagePlanUseCase` (Domain)와 `ValidationService` (Application) 역할 중복 가능성

**권장 수정**:
- ValidationService: UI 입력 검증 (실시간 피드백)
- ValidateDosagePlanUseCase: 비즈니스 규칙 검증 (저장 전)

---

#### 2.3 docs/003 (투여 스케줄)

**이슈 1**: 성능 테스트 구체성 부족
- Spec BR-001: "스케줄 생성 1초 이내"
- Plan: 테스트는 있으나 실제 성능 최적화 전략 없음

**권장 추가**:
```markdown
### Performance Optimization Strategy

1. **Batch 계산**: 증량 시점별로 그룹화하여 일괄 계산
2. **Lazy Evaluation**: 필요한 기간만 계산
3. **Memoization**: 같은 계획에 대한 재계산 방지
4. **Index 최적화**: Isar Index 활용 (scheduledDate, dosagePlanId)

**Test**:
```dart
test('should generate 6-month schedule within 1 second', () {
  // Arrange
  final plan = DosagePlan(...); // 복잡한 증량 계획

  // Act
  final stopwatch = Stopwatch()..start();
  final schedules = generateSchedules(plan, DateTime.now().add(Duration(days: 180)));
  stopwatch.stop();

  // Assert
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  expect(schedules.length, greaterThan(20));
});
```
```

**이슈 2**: 주사 부위 순환 로직 데이터 모델 불명확
- Plan: `InjectionSiteRotationUseCase` 존재
- 하지만 부위별 사용 이력을 어떻게 저장/조회하는지 명시 부족

---

#### 2.4 docs/004 (증상 및 체중 기록)

**이슈**: 경과일 계산 의존성 순환 가능성
- TrackingNotifier → MedicationRepository (경과일 조회)
- MedicationNotifier → TrackingRepository (투여 기록 저장)

**권장 수정**:
- Derived Provider로 경과일 계산 분리
- 또는 SharedRepository/Service 패턴 도입

```dart
@riverpod
Future<int?> daysSinceEscalation(ref, String userId) async {
  final medicationRepo = ref.watch(medicationRepositoryProvider);
  final escalationDate = await medicationRepo.getLatestEscalationDate(userId);

  if (escalationDate == null) return null;
  return DateTime.now().difference(escalationDate).inDays;
}

// TrackingNotifier에서 사용
final days = await ref.read(daysSinceEscalationProvider(userId).future);
```

---

#### 2.5 docs/005 (데이터 공유 모드)

**이슈**: 읽기 전용 모드 구현 방법 불명확
- Spec: "모든 편집 기능 비활성화"
- Plan: 구체적인 구현 방법 없음

**권장 추가**:
```markdown
### Read-Only Mode Implementation

**Strategy**: Provider Override 패턴

```dart
final isReadOnlyModeProvider = StateProvider<bool>((ref) => false);

// 편집 버튼에서 사용
final isReadOnly = ref.watch(isReadOnlyModeProvider);

ElevatedButton(
  onPressed: isReadOnly ? null : () => _onEdit(),
  child: Text('편집'),
)
```

**Test**:
```dart
testWidgets('should disable edit buttons in sharing mode', (tester) async {
  // Arrange
  final container = ProviderContainer(
    overrides: [
      isReadOnlyModeProvider.overrideWith((ref) => true),
    ],
  );

  // Act
  await tester.pumpWidget(...);

  // Assert
  final editButton = tester.widget<ElevatedButton>(find.text('편집'));
  expect(editButton.onPressed, isNull);
});
```
```

---

#### 2.6 docs/006 (부작용 대처 가이드)

**이슈 1**: 정적 데이터 관리 방법 불명확
- Plan: "하드코딩된 7가지 증상 가이드"
- 하지만 데이터 구조 및 관리 방법 명시 부족

**권장 추가**:
```markdown
### Static Guide Data Management

**Location**: `lib/features/coping_guide/infrastructure/data/guide_data.dart`

**Structure**:
```dart
class GuideData {
  static const Map<String, CopingGuide> guides = {
    '메스꺼움': CopingGuide(
      symptomName: '메스꺼움',
      shortGuide: '소량씩 자주 식사하세요. 기름진 음식은 피하고...',
      detailedSections: [
        GuideSection(title: '즉시 조치', content: '...'),
        GuideSection(title: '식이 조절', content: '...'),
        GuideSection(title: '생활 습관', content: '...'),
        GuideSection(title: '경과 관찰', content: '...'),
      ],
    ),
    // ... 나머지 6가지
  };
}
```

**Repository Implementation**:
```dart
class IsarCopingGuideRepository implements CopingGuideRepository {
  @override
  Future<CopingGuide?> getGuideBySymptom(String symptomName) async {
    return GuideData.guides[symptomName];
  }

  @override
  Future<List<CopingGuide>> getAllGuides() async {
    return GuideData.guides.values.toList();
  }
}
```
```

**이슈 2**: F002 연동 테스트 구체성 부족
- Plan: "Integration Test: 증상 기록 후 가이드 자동 표시"
- 구체적인 테스트 시나리오 없음

---

## 3. 권장 조치사항

### 우선순위 1 (즉시 수정 필요)
1. AuthRepository 인터페이스 통합 정의 (baseline/architecture.md)
2. Navigation Logic 전략 명확화 (각 Plan에 추가)
3. Edge Case 재시도 로직 Layer 재배치 (docs/001, 010)
4. Provider 정의 위치 명시 (모든 Plan)

### 우선순위 2 (구현 전 수정)
5. 트랜잭션 처리 명시 (docs/002)
6. 성능 최적화 전략 추가 (docs/003)
7. 경과일 계산 의존성 해결 (docs/004)
8. 읽기 전용 모드 구현 방법 (docs/005)
9. 정적 데이터 관리 구체화 (docs/006)

### 우선순위 3 (구현 중 보완 가능)
10. Round-trip DTO 변환 테스트 추가 (모든 Plan)
11. QA Sheet 접근성 항목 추가 (Presentation Layer)

---

## 4. 일관성 개선 권장사항

### 4.1 Plan 템플릿 표준화

각 Plan에 다음 섹션 필수 포함:

```markdown
## 1. 개요
### 1.1 모듈 목록 및 위치
- Domain Layer: ...
- Infrastructure Layer: ...
- Application Layer: ...
- Presentation Layer: ...
- **Providers**: ...  # 추가 필요

## 2. Architecture Diagram
(Mermaid 다이어그램)

## 3. Implementation Plan
### 3.x Domain Layer
- Test Strategy
- Test Scenarios (AAA 패턴)
- Edge Cases
- Implementation Order
- Dependencies

### 3.y Infrastructure Layer
...

### 3.z Application Layer
...

### 3.w Presentation Layer
- QA Sheet (수동 테스트 포함)

## 4. TDD Workflow
- 시작점
- 진행 순서 (Inside-Out)
- Commit 포인트
- 완료 조건

## 5. 핵심 원칙
- Layer Dependency
- Repository Pattern
- Test-First
- Phase 0 → Phase 1 전환 전략
```

### 4.2 공통 참조 문서 작성

`docs/baseline/` 폴더에 다음 문서 추가:

1. **shared_interfaces.md**: 공통 인터페이스 정의 (AuthRepository, BaseRepository 등)
2. **navigation_strategy.md**: AppRouter 설계 및 화면 전환 규칙
3. **provider_naming.md**: Provider 명명 규칙 및 위치 규칙
4. **error_handling.md**: Layer별 예외 처리 전략
5. **transaction_patterns.md**: 트랜잭션 처리 패턴 (Isar, Supabase)

---

## 5. 결론

전반적으로 Plan은 Spec의 요구사항을 충실히 반영하고 있으나, 다음 측면에서 개선이 필요합니다:

1. **Layer 책임 분리**: Edge Case 처리, 재시도 로직, Navigation 등의 책임 소재 명확화
2. **공통 인터페이스 정의**: 여러 Feature에서 공유하는 인터페이스의 통합 정의 필요
3. **테스트 완전성**: Round-trip 테스트, Transaction 테스트, 성능 테스트 보완
4. **구현 구체성**: 읽기 전용 모드, 정적 데이터 관리 등 구체적인 구현 방법 명시

이러한 이슈들을 수정하면 **Clean Architecture 원칙 준수**, **TDD 효과성 향상**, **Phase 1 전환 용이성**이 크게 개선될 것으로 예상됩니다.

---

## 다음 단계

1. 각 docs/{xxx}/plancheck.md 파일 생성 (개별 이슈 상세 설명)
2. docs/baseline/shared_interfaces.md 작성
3. 모든 Plan 수정 후 재검토
4. 수정된 Plan 기반 구현 시작

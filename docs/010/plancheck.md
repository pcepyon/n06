# Logout Implementation Plan - 검토 결과

## 검토 일시
2025-11-07

## 검토 결과 요약
**상태**: ⚠️ 수정 필요

**주요 이슈**: 7건
- 심각: 2건
- 보통: 3건
- 경미: 2건

---

## 1. 심각한 이슈 (Critical)

### 1.1 AuthRepository Interface 명세 누락
**문제점**:
- Plan에서 `AuthRepository.clearSession()` 메서드를 참조하지만, 이 인터페이스의 정의가 명시되지 않음
- Spec의 "7. 세션 정보 초기화" 단계에 대응하는 구현 계획이 불명확함

**영향**:
- Domain Layer 설계 불완전
- LogoutUseCase 구현 시 의존성 불명확

**수정 방안**:
```dart
// 추가 필요: lib/features/authentication/domain/repositories/auth_repository.dart

abstract class AuthRepository {
  // 기존 메서드들...

  /// 세션 정보 초기화 (메모리 내 사용자 데이터 제거)
  Future<void> clearSession();

  /// 현재 인증 상태 반환
  Future<AuthUser?> getCurrentUser();
}
```

**Plan 수정 위치**: Section 3.1 이전에 AuthRepository Interface 섹션 추가

---

### 1.2 Navigation Logic 구현 위치 불명확
**문제점**:
- Spec 8단계 "로그인 화면 이동"의 구현 주체가 불명확
- Plan에서 SettingsScreen이 네비게이션을 처리한다고 하지만, Clean Architecture 원칙상 Presentation Layer가 직접 라우팅 로직을 가지는 것이 적절한지 의문

**현재 Plan**:
```dart
// 3.6 SettingsScreen
testWidgets('should navigate to login screen after logout', (tester) async {
  // ...네비게이션 테스트
});
```

**문제점 분석**:
1. AuthNotifier의 상태 변화를 감지해서 자동으로 라우팅해야 하는가?
2. 아니면 SettingsScreen이 logout 성공 후 명시적으로 라우팅해야 하는가?

**수정 방안 (권장)**:
- **AppRouter에서 AuthNotifier 상태 변화 감지**하여 자동 라우팅
- GoRouter의 `redirect` 또는 Riverpod의 `ref.listen` 활용

**추가 필요**:
```dart
// Section 3.7 추가: AppRouter 수정

### 3.7 AppRouter Navigation Logic

**Location**: `lib/core/routing/app_router.dart`

**Responsibility**: 인증 상태 변화 감지 및 자동 라우팅

**Test Scenarios**:
- AuthNotifier 상태가 null로 변경되면 LoginScreen으로 리다이렉트
- 로그아웃 중(loading) 상태에서는 현재 화면 유지

**Implementation**:
- GoRouter redirect 콜백에 AuthNotifier 상태 체크 로직 추가
- 또는 Root Widget에서 ref.listen으로 AuthNotifier 감지
```

---

## 2. 보통 수준 이슈 (Medium)

### 2.1 SecureStorageRepository vs AuthRepository 책임 분리 불명확
**문제점**:
- LogoutUseCase가 두 개의 Repository를 동시에 의존함
- 책임 분리가 명확하지 않음:
  - SecureStorageRepository: 토큰 삭제
  - AuthRepository: 세션 초기화

**의문점**:
- AuthRepository가 내부적으로 SecureStorageRepository를 사용해야 하는가?
- 아니면 LogoutUseCase가 두 Repository를 직접 오케스트레이션해야 하는가?

**현재 설계**:
```
LogoutUseCase → SecureStorageRepository (토큰 삭제)
              → AuthRepository (세션 초기화)
```

**대안 설계 (더 나은 캡슐화)**:
```
LogoutUseCase → AuthRepository → SecureStorageRepository
```

**수정 방안**:
1. **현재 설계 유지** (추천):
   - LogoutUseCase가 두 책임을 명시적으로 분리
   - 토큰 삭제 실패 시에도 세션 초기화 진행 (EC3 대응)
   - **But**: Plan에 이 설계 의도를 명확히 문서화 필요

2. **대안 설계 적용**:
   - AuthRepository.logout() 메서드 추가
   - 내부에서 SecureStorageRepository 호출
   - **But**: 토큰 삭제 실패 시 세션 초기화 여부 제어 어려움

**Plan 수정 필요**:
- Section 3.3 LogoutUseCase에 "Why Two Repositories?" 설명 추가

---

### 2.2 EC3 재시도 로직의 책임 소재 불명확
**Spec EC3**:
> 6단계에서 안전한 저장소 접근 오류로 토큰 삭제 실패
> 처리: 에러를 로깅하고 재시도, 최대 3회 재시도 후에도 실패 시 세션 정보만 초기화

**Plan 구현**:
- FlutterSecureStorageRepository에서 재시도 구현 (Section 3.2)
- LogoutUseCase에서 예외 처리 (Section 3.3)

**문제점**:
- 재시도 로직이 Infrastructure Layer(Repository)에 있음
- 하지만 "재시도 후 세션만 초기화"는 비즈니스 로직 → Domain Layer(UseCase)에 있어야 함

**수정 방안**:
1. **FlutterSecureStorageRepository**: 단순 예외 throw (재시도 없음)
2. **LogoutUseCase**: 재시도 로직 + 실패 시 세션 초기화 진행

```dart
// LogoutUseCase (수정 필요)
Future<void> execute() async {
  bool tokenCleared = false;

  // 최대 3회 재시도
  for (int i = 0; i < 3; i++) {
    try {
      await storageRepository.clearTokens();
      tokenCleared = true;
      break;
    } catch (e) {
      logger.error('Token deletion failed (attempt ${i+1})', e);
      if (i == 2) {
        logger.warning('Token deletion failed after 3 attempts, proceeding with session clear');
      }
    }
  }

  // 토큰 삭제 실패해도 세션은 초기화
  await authRepository.clearSession();
}
```

**Plan 수정 위치**: Section 3.2, 3.3

---

### 2.3 Isar 데이터 보존 검증 테스트 누락
**Spec BR2**:
> Phase 0에서는 로그아웃 시 사용자의 로컬 데이터(투여 기록, 체중 기록 등)를 삭제하지 않음

**Spec EC5**:
> Phase 0에서는 로컬 데이터 유지 (투여 기록, 체중 기록 등)

**Plan 문제점**:
- 모든 테스트 시나리오에 Isar 데이터가 **삭제되지 않음**을 검증하는 테스트가 없음
- BR2 준수 여부를 검증할 방법이 없음

**수정 방안**:
Section 3.3 LogoutUseCase에 테스트 시나리오 추가:

```dart
test('should NOT clear Isar database when logging out', () async {
  // Arrange
  final mockIsarRepo = MockMedicationRepository(); // Isar 기반 Repository
  // Isar에 테스트 데이터 삽입

  // Act
  await useCase.execute();

  // Assert
  // Isar Repository의 clear/delete 메서드가 호출되지 않았음을 검증
  verifyNever(() => mockIsarRepo.clearAll());
});
```

**추가 위치**: Section 3.3 Test Scenarios

---

## 3. 경미한 이슈 (Minor)

### 3.1 Provider 정의 누락
**문제점**:
- Plan에서 여러 Provider를 참조하지만 정의가 없음:
  - `logoutUseCaseProvider`
  - `secureStorageRepositoryProvider`
  - `authRepositoryProvider`

**수정 방안**:
Section 1.1에 Provider 정의 위치 추가:

```markdown
### 1.1 모듈 목록 및 위치

**Providers**:
- `secureStorageRepositoryProvider`: `infrastructure/providers/storage_provider.dart`
- `authRepositoryProvider`: `infrastructure/providers/auth_provider.dart`
- `logoutUseCaseProvider`: `domain/providers/usecase_provider.dart`
- `authNotifierProvider`: `application/providers/notifier_provider.dart`
```

---

### 3.2 QA Sheet 항목 불완전
**문제점**:
- Section 3.5 LogoutConfirmDialog QA Sheet에 접근성(Accessibility) 항목 없음
- Section 3.6 SettingsScreen QA Sheet에 성능 측정 항목 없음

**수정 방안**:
Section 3.5 QA Sheet 추가:
```markdown
- [ ] VoiceOver/TalkBack에서 버튼 읽힘 확인
- [ ] 키보드 네비게이션 동작 확인
```

Section 3.6 QA Sheet 추가:
```markdown
- [ ] 로그아웃 완료까지 200ms 이내 (Section 7 기준)
- [ ] 메모리 릭 없음 확인
```

---

## 4. 긍정적 측면 (Strengths)

### ✅ 잘 설계된 부분
1. **TDD 워크플로우 명확** (Section 4)
   - Inside-Out 접근 방식
   - Red-Green-Refactor 사이클 명시
   - Commit 메시지 예시 제공

2. **Edge Cases 충실히 반영** (Section 5)
   - Spec의 모든 Edge Cases가 Plan에 반영됨

3. **Business Rules 준수** (Section 6)
   - BR1~BR5 모두 구현 계획에 포함됨

4. **테스트 전략 명확** (각 Section)
   - Unit/Integration/Widget Test 구분 명확
   - AAA Pattern 적용

5. **성능 제약 조건 명시** (Section 7)
   - 구체적인 시간 제한 설정

---

## 5. 수정 우선순위

### Priority 1 (즉시 수정 필요)
1. [1.1] AuthRepository Interface 명세 추가
2. [1.2] Navigation Logic 구현 위치 명확화
3. [2.2] EC3 재시도 로직 책임 재배치

### Priority 2 (구현 전 수정)
4. [2.1] Repository 책임 분리 문서화
5. [2.3] Isar 데이터 보존 테스트 추가

### Priority 3 (구현 중 수정 가능)
6. [3.1] Provider 정의 추가
7. [3.2] QA Sheet 항목 보완

---

## 6. 수정 후 재검토 필요 사항

수정 완료 후 다음 항목을 재확인:
- [ ] AuthRepository 인터페이스가 Domain Layer에 정의됨
- [ ] Navigation 로직이 Clean Architecture 원칙을 준수함
- [ ] EC3 재시도 로직이 적절한 Layer에 구현됨
- [ ] Isar 데이터 보존이 테스트로 검증됨
- [ ] 모든 Provider가 정의되고 위치가 명시됨
- [ ] QA Sheet가 접근성 및 성능 항목을 포함함

---

## 7. 추가 권장사항

### 7.1 로깅 전략
**추가 권장**:
- Section에 로깅 요구사항 추가
- 어떤 이벤트를 로깅할 것인가?
  - 로그아웃 시작
  - 토큰 삭제 성공/실패
  - 세션 초기화 완료
  - 로그아웃 완료

### 7.2 Analytics 이벤트
**추가 권장**:
- 로그아웃 이벤트 추적 (Phase 1 준비)
- 로그아웃 취소율 측정

### 7.3 Error Boundary
**추가 권장**:
- 로그아웃 중 예상치 못한 에러 발생 시 Fallback UI 정의
- 현재 Plan에는 에러 스낵바만 있음

---

## 결론

Plan은 전반적으로 Spec을 충실히 반영하고 있으나, **Clean Architecture 원칙 준수**와 **책임 분리** 측면에서 몇 가지 명확화가 필요합니다.

특히 **AuthRepository 인터페이스 정의**, **Navigation 로직 위치**, **재시도 로직 책임** 세 가지는 구현 전에 반드시 수정되어야 합니다.

수정 후 예상 완료 시간: +2시간 (문서화 + 테스트 시나리오 추가)

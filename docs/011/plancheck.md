# 프로필 및 목표 수정 Plan 검토 결과

## 1. 주요 누락 사항

### 1.1. 홈 대시보드 데이터 재계산 트리거
**spec.md 요구사항 (11번)**:
> 시스템은 홈 대시보드 관련 데이터 재계산을 트리거한다:
> - 목표 진행도
> - 목표 달성 예상 시기
> - 인사이트 메시지

**plan.md 누락**:
- UpdateProfileUseCase에서 "홈 대시보드 데이터 재계산 트리거 (이벤트 발행)"라고 언급만 했으나 구체적인 구현 계획이 없음
- 어떤 방식으로 이벤트를 발행할지 명시되지 않음
- 홈 대시보드와의 연동 방법이 설계되지 않음

**수정 필요**:
- 이벤트 버스 또는 Riverpod의 `ref.invalidate()`를 사용한 상태 갱신 방법 명시
- 홈 대시보드의 어떤 Provider들을 갱신해야 하는지 정의
- UpdateProfileUseCase 또는 ProfileNotifier에 구체적인 재계산 트리거 로직 추가

---

### 1.2. 현재 체중 변경 시 체중 기록과의 불일치 처리
**spec.md Edge Case**:
> 현재 체중 변경 시 최근 체중 기록과 불일치: 확인 메시지 표시 후 진행 허용

**plan.md 누락**:
- 현재 체중 변경 시 weight_logs 테이블의 최근 기록과 비교하는 로직이 설계되지 않음
- 확인 메시지 표시 기능이 ProfileEditScreen 테스트 시나리오에 없음
- UserProfile Entity에 이 검증 로직이 포함되지 않음

**수정 필요**:
- ProfileRepository에 `getLatestWeightLog()` 메서드 추가
- UpdateProfileUseCase 또는 ProfileNotifier에서 현재 체중 변경 시 최근 체중 기록과 비교
- Presentation Layer에 확인 다이얼로그 표시 로직 추가
- 테스트 시나리오에 이 케이스 추가

---

### 1.3. 저장 완료 확인 메시지
**spec.md 요구사항 (12번)**:
> 시스템은 저장 완료 확인 메시지를 표시한다.

**plan.md 누락**:
- ProfileEditScreen 테스트 시나리오에 "저장 완료 메시지 표시" 케이스가 없음
- 저장 성공 시 네비게이션만 있고, 확인 메시지(스낵바/다이얼로그) 표시가 설계되지 않음

**수정 필요**:
- ProfileEditScreen에 저장 성공 시 스낵바 표시 로직 추가
- 테스트 시나리오에 "저장 완료 메시지 표시" 케이스 추가

---

### 1.4. 변경사항 없이 저장 시도
**spec.md Edge Case**:
> 변경사항 없이 저장 시도: 그대로 유지, 설정 화면으로 복귀

**plan.md 누락**:
- ProfileNotifier 또는 UpdateProfileUseCase에서 변경사항 감지 로직이 설계되지 않음
- 변경사항이 없을 경우 저장 API 호출을 건너뛰는 최적화가 없음

**수정 필요**:
- ProfileNotifier에 `hasChanges()` 메서드 추가
- 변경사항이 없으면 저장 없이 바로 복귀하는 로직 추가
- 테스트 시나리오에 "변경사항 없이 저장" 케이스 추가

---

### 1.5. 저장 중 앱 종료
**spec.md Edge Case**:
> 저장 중 앱 종료: 변경사항 폐기, 다음 실행 시 기존 정보 유지

**plan.md 누락**:
- 저장 트랜잭션의 원자성(atomicity) 보장 방법이 명시되지 않음
- Isar의 트랜잭션 처리에 대한 언급 없음

**수정 필요**:
- IsarProfileRepository에서 `isar.writeTxn()`을 사용한 트랜잭션 처리 명시
- Integration Test에 "트랜잭션 롤백" 시나리오 추가 (가능하다면)

---

## 2. 설계 개선 사항

### 2.1. UserProfile Entity 검증 로직 보완
**현재 설계**:
- 목표 체중 < 현재 체중 검증
- 체중 범위 20-300kg 검증

**개선 필요**:
- `needsWeightLossWarning()` 메서드 구현 계획은 있으나, 테스트 시나리오 8번에서만 언급됨
- 이 메서드의 정확한 로직이 명시되지 않음 (주간 감량 목표 > 1kg일 때 true 반환)

**수정 필요**:
- UserProfile Entity에 `needsWeightLossWarning()` 메서드 명시적 정의
- 테스트 시나리오를 더 명확하게 수정

---

### 2.2. ProfileRepository Interface 메서드 부족
**현재 설계**:
```dart
- getUserProfile()
- updateUserProfile()
- watchUserProfile()
```

**개선 필요**:
- `getLatestWeightLog()` 메서드 추가 (현재 체중 불일치 감지용)
- 또는 별도의 WeightLogRepository와의 통합 방법 정의

**수정 필요**:
- ProfileRepository에 체중 기록 조회 메서드 추가 또는
- WeightLogRepository 참조 방법 명시

---

### 2.3. UpdateProfileUseCase 책임 범위 명확화
**현재 설계**:
- 프로필 업데이트 비즈니스 로직 수행
- 검증 후 Repository 호출
- 홈 대시보드 데이터 재계산 트리거 (이벤트 발행)

**문제점**:
- "홈 대시보드 데이터 재계산 트리거"가 UseCase의 책임인지 Notifier의 책임인지 불분명
- Clean Architecture에서 UseCase는 일반적으로 단일 비즈니스 로직만 처리하고, 외부 시스템 통지는 상위 레이어(Application)에서 처리하는 것이 일반적

**수정 필요**:
- UpdateProfileUseCase는 순수하게 프로필 업데이트만 담당
- ProfileNotifier에서 UseCase 실행 후 홈 대시보드 상태 갱신 (`ref.invalidate()`)
- 책임 분리를 명확히 문서화

---

### 2.4. ProfileEditForm 컴포넌트 분리 부족
**현재 설계**:
- ProfileEditForm이 모든 입력 필드를 관리

**개선 제안**:
- 입력 필드가 많으므로 재사용 가능한 컴포넌트 분리 권장:
  - `WeightInputField` (목표 체중, 현재 체중용)
  - `PeriodInputField` (목표 기간용)
  - `WeeklyGoalDisplay` (주간 감량 목표 표시용)

**수정 필요**:
- 컴포넌트 분리 계획을 Presentation Layer에 추가
- 각 컴포넌트별 Widget Test 시나리오 추가

---

## 3. 테스트 시나리오 보완

### 3.1. ProfileNotifier 테스트 누락
**추가 필요**:
```dart
7. 변경사항 없이 저장 시도
   - given: 수정되지 않은 프로필
   - when: updateProfile 호출
   - then: Repository 호출 없이 즉시 반환

8. 현재 체중 변경 시 불일치 감지
   - given: 최근 체중 기록과 다른 현재 체중
   - when: updateProfile 호출
   - then: 확인 메시지 필요 상태 반환
```

---

### 3.2. ProfileEditScreen 테스트 누락
**추가 필요**:
```dart
7. 저장 완료 시 확인 메시지 표시
   - given: updateProfile 성공
   - when: 저장 완료
   - then: "저장되었습니다" 스낵바 표시

8. 현재 체중 변경 시 확인 다이얼로그
   - given: 최근 체중 기록과 다른 현재 체중
   - when: 저장 시도
   - then: 확인 다이얼로그 표시

9. 변경사항 없이 저장 시도
   - given: 수정되지 않은 폼
   - when: 저장 버튼 탭
   - then: 저장 없이 이전 화면으로 이동
```

---

### 3.3. QA Sheet 보완
**ProfileEditScreen QA Sheet 추가**:
```markdown
- [ ] 저장 완료 시 확인 메시지가 표시되는가?
- [ ] 현재 체중 변경 시 확인 다이얼로그가 표시되는가?
- [ ] 변경사항 없이 저장 시도 시 즉시 복귀하는가?
- [ ] 저장 중 로딩 상태가 표시되는가?
- [ ] 저장 완료 후 홈 대시보드가 업데이트되는가?
```

---

## 4. Architecture Diagram 수정 필요

**현재 Diagram 문제점**:
- 홈 대시보드와의 연동이 표시되지 않음
- WeightLogRepository와의 관계가 없음 (현재 체중 불일치 감지용)

**수정 필요**:
```mermaid
graph TD
    subgraph Presentation
        Screen[ProfileEditScreen]
        Form[ProfileEditForm Widget]
    end

    subgraph Application
        Notifier[ProfileNotifier]
        DashboardNotifier[DashboardNotifier]
    end

    subgraph Domain
        Entity[UserProfile Entity]
        RepoInterface[ProfileRepository Interface]
        UseCase[UpdateProfileUseCase]
        WeightRepo[WeightLogRepository Interface]
    end

    subgraph Infrastructure
        RepoImpl[IsarProfileRepository]
        DTO[UserProfileDto]
        WeightRepoImpl[IsarWeightLogRepository]
    end

    Screen --> Notifier
    Form --> Screen
    Notifier --> RepoInterface
    Notifier --> UseCase
    Notifier -.invalidate.-> DashboardNotifier
    UseCase --> RepoInterface
    UseCase --> WeightRepo
    RepoInterface <|.. RepoImpl
    WeightRepo <|.. WeightRepoImpl
    RepoImpl --> DTO
    DTO --> Entity
```

---

## 5. 우선순위 정리

### Critical (반드시 수정)
1. 홈 대시보드 재계산 트리거 로직 추가
2. 현재 체중 불일치 감지 및 확인 메시지 로직 추가
3. 저장 완료 확인 메시지 표시 로직 추가
4. ProfileNotifier/UpdateProfileUseCase 책임 분리 명확화

### Important (수정 권장)
5. 변경사항 감지 및 최적화 로직 추가
6. Isar 트랜잭션 처리 명시
7. 테스트 시나리오 보완 (3.1, 3.2)
8. Architecture Diagram 업데이트

### Nice-to-Have (선택 사항)
9. ProfileEditForm 컴포넌트 분리
10. QA Sheet 보완

---

## 6. 수정 권장 사항 요약

### Domain Layer
- UpdateProfileUseCase에서 홈 대시보드 트리거 책임 제거 (Application Layer로 이동)
- ProfileRepository에 `getLatestWeightLog()` 메서드 추가 또는 WeightLogRepository 통합

### Application Layer
- ProfileNotifier에서 프로필 업데이트 후 홈 대시보드 상태 갱신 로직 추가
- `hasChanges()` 메서드 추가
- 현재 체중 불일치 감지 로직 추가

### Infrastructure Layer
- IsarProfileRepository에서 `isar.writeTxn()` 트랜잭션 처리 명시

### Presentation Layer
- ProfileEditScreen에 저장 완료 스낵바 추가
- 현재 체중 변경 시 확인 다이얼로그 추가
- 변경사항 없을 때 즉시 복귀 로직 추가

### Test
- 누락된 테스트 시나리오 추가 (3.1, 3.2 참조)
- QA Sheet 보완

---

## 7. 결론

전반적으로 plan.md는 Clean Architecture와 TDD 원칙을 잘 따르고 있으나, spec.md의 일부 요구사항과 Edge Case가 누락되었습니다. 특히 **홈 대시보드 재계산 트리거**, **현재 체중 불일치 처리**, **저장 완료 확인 메시지**는 사용자 경험에 핵심적인 요소이므로 반드시 보완이 필요합니다.

또한 UpdateProfileUseCase와 ProfileNotifier 간 책임 분리를 명확히 하여, Clean Architecture의 레이어 간 의존성 원칙을 더 엄격히 준수할 것을 권장합니다.

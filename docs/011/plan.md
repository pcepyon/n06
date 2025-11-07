# 프로필 및 목표 수정 Implementation Plan

## 1. 개요

프로필 및 목표 수정 기능(UF-008)을 위한 모듈 목록:

- **Domain Layer**: UserProfile Entity, ProfileRepository Interface, UpdateProfileUseCase
- **Application Layer**: ProfileNotifier (상태 관리)
- **Infrastructure Layer**: IsarProfileRepository (Repository 구현), UserProfileDto (DTO)
- **Presentation Layer**: ProfileEditScreen, ProfileEditForm Widget

**TDD 적용 범위**: Domain, Application, Infrastructure Layer

---

## 2. Architecture Diagram

```mermaid
graph TD
    subgraph Presentation
        Screen[ProfileEditScreen]
        Form[ProfileEditForm Widget]
    end

    subgraph Application
        Notifier[ProfileNotifier]
    end

    subgraph Domain
        Entity[UserProfile Entity]
        RepoInterface[ProfileRepository Interface]
        UseCase[UpdateProfileUseCase]
    end

    subgraph Infrastructure
        RepoImpl[IsarProfileRepository]
        DTO[UserProfileDto]
    end

    Screen --> Notifier
    Form --> Screen
    Notifier --> RepoInterface
    Notifier --> UseCase
    UseCase --> RepoInterface
    RepoInterface <|.. RepoImpl
    RepoImpl --> DTO
    DTO --> Entity
```

---

## 3. Implementation Plan

### 3.1. UserProfile Entity (Domain)

**Location**: `lib/features/profile/domain/entities/user_profile.dart`

**Responsibility**:
- 사용자 프로필 및 목표 데이터 표현
- 비즈니스 규칙 검증 (목표 체중 < 현재 체중, 체중 범위 20-300kg)
- 주간 감량 목표 계산

**Test Strategy**: Unit Test

**Test Scenarios (Red Phase)**:
```dart
// AAA 패턴: Arrange - Act - Assert

1. 생성 및 속성 검증
   - given: 유효한 프로필 데이터
   - when: UserProfile 생성
   - then: 모든 속성이 올바르게 저장됨

2. 주간 감량 목표 자동 계산
   - given: 현재 체중 80kg, 목표 체중 70kg, 목표 기간 10주
   - when: UserProfile 생성
   - then: weeklyLossGoalKg = 1.0

3. 목표 기간 없을 경우 주간 감량 목표 null
   - given: targetPeriodWeeks = null
   - when: UserProfile 생성
   - then: weeklyLossGoalKg = null

4. 목표 체중이 현재 체중보다 큰 경우 예외
   - given: 현재 체중 70kg, 목표 체중 80kg
   - when: UserProfile 생성
   - then: ArgumentError 발생

5. 체중이 20kg 미만인 경우 예외
   - given: targetWeightKg = 15kg
   - when: UserProfile 생성
   - then: ArgumentError 발생

6. 체중이 300kg 초과인 경우 예외
   - given: targetWeightKg = 350kg
   - when: UserProfile 생성
   - then: ArgumentError 발생

7. copyWith 메서드 동작 검증
   - given: 기존 UserProfile
   - when: copyWith로 일부 필드 변경
   - then: 변경된 필드만 업데이트됨

8. 주간 감량 목표가 1kg 초과 시 경고 필요 여부 확인
   - given: 주간 감량 목표 1.5kg
   - when: needsWeightLossWarning 호출
   - then: true 반환
```

**Implementation Order**:
1. Test: 기본 생성 및 속성 검증
2. Code: UserProfile 클래스, 기본 생성자
3. Test: 주간 감량 목표 계산
4. Code: 계산 로직 추가
5. Test: 검증 규칙 (목표 체중 < 현재 체중)
6. Code: 검증 로직 추가
7. Test: 체중 범위 검증
8. Code: 범위 검증 로직
9. Refactor: 검증 로직 분리, 상수 추출

**Dependencies**: 없음 (Pure Dart)

---

### 3.2. ProfileRepository Interface (Domain)

**Location**: `lib/features/profile/domain/repositories/profile_repository.dart`

**Responsibility**:
- 프로필 CRUD 인터페이스 정의
- Domain Layer가 Infrastructure에 의존하지 않도록 추상화

**Test Strategy**: Unit Test (UseCase, Notifier 테스트 시 Mock 사용)

**Test Scenarios (Red Phase)**:
```dart
// Mock을 사용한 계약 테스트

1. getUserProfile 호출 가능
   - given: Mock Repository
   - when: getUserProfile 호출
   - then: 정상 호출됨

2. updateUserProfile 호출 가능
   - given: Mock Repository, UserProfile
   - when: updateUserProfile 호출
   - then: 정상 호출됨

3. watchUserProfile 스트림 반환
   - given: Mock Repository
   - when: watchUserProfile 호출
   - then: Stream<UserProfile> 반환
```

**Implementation Order**:
1. Test: Interface 메서드 정의 확인
2. Code: ProfileRepository abstract class
3. Refactor: 문서화 주석 추가

**Dependencies**: UserProfile Entity

---

### 3.3. UpdateProfileUseCase (Domain)

**Location**: `lib/features/profile/domain/usecases/update_profile_usecase.dart`

**Responsibility**:
- 프로필 업데이트 비즈니스 로직 수행
- 검증 후 Repository 호출
- 홈 대시보드 데이터 재계산 트리거 (이벤트 발행)

**Test Strategy**: Unit Test

**Test Scenarios (Red Phase)**:
```dart
// Mock Repository 사용

1. 유효한 프로필 업데이트 성공
   - given: Mock Repository, 유효한 UserProfile
   - when: execute 호출
   - then: repository.updateUserProfile 호출됨

2. 목표 체중 > 현재 체중 시 실패
   - given: 잘못된 UserProfile
   - when: execute 호출
   - then: ValidationException 발생

3. 체중 범위 초과 시 실패
   - given: 체중 300kg 초과 UserProfile
   - when: execute 호출
   - then: ValidationException 발생

4. Repository 실패 시 예외 전파
   - given: Repository가 예외 발생
   - when: execute 호출
   - then: 동일한 예외 전파됨
```

**Implementation Order**:
1. Test: 기본 실행 및 Repository 호출
2. Code: UpdateProfileUseCase 클래스, execute 메서드
3. Test: 검증 실패 케이스
4. Code: 검증 로직 추가
5. Refactor: 검증 로직을 Entity로 이동

**Dependencies**: UserProfile, ProfileRepository

---

### 3.4. UserProfileDto (Infrastructure)

**Location**: `lib/features/profile/infrastructure/dtos/user_profile_dto.dart`

**Responsibility**:
- Isar 데이터베이스 스키마 정의
- DTO ↔ Entity 변환

**Test Strategy**: Unit Test

**Test Scenarios (Red Phase)**:
```dart
1. Entity → DTO 변환
   - given: UserProfile Entity
   - when: UserProfileDto.fromEntity 호출
   - then: 모든 필드가 올바르게 매핑됨

2. DTO → Entity 변환
   - given: UserProfileDto
   - when: toEntity 호출
   - then: 모든 필드가 올바르게 매핑됨

3. null 필드 처리
   - given: targetPeriodWeeks = null인 Entity
   - when: 변환 수행
   - then: null 값 유지됨

4. 왕복 변환 일관성
   - given: UserProfile Entity
   - when: Entity → DTO → Entity 변환
   - then: 원본과 동일한 데이터
```

**Implementation Order**:
1. Test: Entity → DTO 변환
2. Code: UserProfileDto 클래스, fromEntity 메서드
3. Test: DTO → Entity 변환
4. Code: toEntity 메서드
5. Test: 왕복 변환 일관성
6. Refactor: 중복 코드 제거

**Dependencies**: UserProfile Entity, Isar

---

### 3.5. IsarProfileRepository (Infrastructure)

**Location**: `lib/features/profile/infrastructure/repositories/isar_profile_repository.dart`

**Responsibility**:
- ProfileRepository 인터페이스 구현
- Isar를 통한 데이터 저장/조회
- DTO ↔ Entity 변환 관리

**Test Strategy**: Integration Test (실제 Isar 사용)

**Test Scenarios (Red Phase)**:
```dart
// 실제 Isar 인스턴스 사용

1. 프로필 저장 및 조회
   - given: IsarProfileRepository, UserProfile
   - when: updateUserProfile → getUserProfile
   - then: 저장한 데이터 반환됨

2. 프로필 업데이트
   - given: 기존 프로필 존재
   - when: 새로운 프로필로 updateUserProfile
   - then: 업데이트된 데이터 조회됨

3. 프로필 없을 때 null 반환
   - given: 빈 DB
   - when: getUserProfile 호출
   - then: null 반환

4. watchUserProfile 실시간 업데이트
   - given: IsarProfileRepository
   - when: watchUserProfile 구독 후 updateUserProfile
   - then: 스트림에서 업데이트된 데이터 수신

5. 동일 userId로 중복 저장 시 덮어쓰기
   - given: 동일 userId의 프로필 2개
   - when: 순차적으로 저장
   - then: 마지막 저장본만 존재
```

**Implementation Order**:
1. Test: 기본 저장 및 조회
2. Code: IsarProfileRepository 클래스, getUserProfile, updateUserProfile
3. Test: 업데이트 동작
4. Code: 업데이트 로직
5. Test: watchUserProfile 스트림
6. Code: watch 메서드 구현
7. Refactor: 에러 핸들링 추가

**Dependencies**: ProfileRepository, UserProfileDto, Isar

---

### 3.6. ProfileNotifier (Application)

**Location**: `lib/features/profile/application/notifiers/profile_notifier.dart`

**Responsibility**:
- 프로필 상태 관리
- UI 이벤트를 UseCase/Repository 호출로 변환
- AsyncValue를 통한 로딩/에러 상태 관리

**Test Strategy**: Unit Test (Mock Repository, UseCase)

**Test Scenarios (Red Phase)**:
```dart
// Mock 사용

1. 초기 로드 성공
   - given: Mock Repository with 프로필 데이터
   - when: build 호출
   - then: AsyncValue.data(profile) 반환

2. 초기 로드 실패
   - given: Mock Repository가 예외 발생
   - when: build 호출
   - then: AsyncValue.error 반환

3. 프로필 업데이트 성공
   - given: 초기 상태, Mock UseCase
   - when: updateProfile 호출
   - then: state = AsyncValue.loading → data

4. 프로필 업데이트 실패
   - given: Mock UseCase가 예외 발생
   - when: updateProfile 호출
   - then: state = AsyncValue.error

5. 주간 목표 업데이트
   - given: 초기 상태, Mock Repository
   - when: updateWeeklyGoals 호출
   - then: state 업데이트됨

6. 업데이트 중 중복 호출 방지
   - given: 업데이트 진행 중
   - when: updateProfile 재호출
   - then: 첫 번째 완료 후 두 번째 실행
```

**Implementation Order**:
1. Test: 초기 로드
2. Code: ProfileNotifier 클래스, build 메서드
3. Test: 업데이트 성공 케이스
4. Code: updateProfile 메서드
5. Test: 에러 핸들링
6. Code: AsyncValue.guard 적용
7. Refactor: 로직 분리, 상수 추출

**Dependencies**: ProfileRepository, UpdateProfileUseCase, Riverpod

---

### 3.7. ProfileEditScreen (Presentation)

**Location**: `lib/features/profile/presentation/screens/profile_edit_screen.dart`

**Responsibility**:
- 프로필 수정 UI 렌더링
- ProfileNotifier 상태 구독
- 사용자 입력 수집 및 검증

**Test Strategy**: Widget Test

**Test Scenarios (Red Phase)**:
```dart
1. 화면 로드 시 로딩 표시
   - given: ProfileNotifier state = loading
   - when: 화면 빌드
   - then: CircularProgressIndicator 표시

2. 프로필 데이터 로드 시 폼에 표시
   - given: ProfileNotifier state = data(profile)
   - when: 화면 빌드
   - then: 이름, 목표 체중, 현재 체중, 목표 기간 표시

3. 저장 버튼 클릭 시 updateProfile 호출
   - given: 수정된 폼 데이터
   - when: 저장 버튼 탭
   - then: ProfileNotifier.updateProfile 호출됨

4. 입력 검증 에러 표시
   - given: 목표 체중 > 현재 체중
   - when: 저장 시도
   - then: 에러 메시지 표시

5. 저장 성공 시 네비게이션
   - given: updateProfile 성공
   - when: 저장 완료
   - then: 이전 화면으로 이동

6. 저장 실패 시 스낵바 표시
   - given: updateProfile 실패
   - when: 에러 발생
   - then: 에러 스낵바 표시
```

**Implementation Order**:
1. Test: 기본 화면 렌더링
2. Code: ProfileEditScreen 클래스, Scaffold
3. Test: 폼 데이터 표시
4. Code: ProfileEditForm Widget
5. Test: 저장 동작
6. Code: 저장 버튼 핸들러
7. Refactor: UI 컴포넌트 분리

**Dependencies**: ProfileNotifier, Flutter Widgets

**QA Sheet** (수동 테스트):
- [ ] 화면 진입 시 현재 프로필 정보가 표시되는가?
- [ ] 이름 필드를 수정할 수 있는가?
- [ ] 목표 체중을 수정할 수 있는가?
- [ ] 현재 체중을 수정할 수 있는가?
- [ ] 목표 기간을 수정할 수 있는가?
- [ ] 목표 체중 > 현재 체중 입력 시 에러 메시지가 표시되는가?
- [ ] 체중 20kg 미만 입력 시 에러 메시지가 표시되는가?
- [ ] 체중 300kg 초과 입력 시 에러 메시지가 표시되는가?
- [ ] 주간 감량 목표가 실시간으로 재계산되는가?
- [ ] 주간 감량 목표 1kg 초과 시 경고가 표시되는가?
- [ ] 저장 버튼 클릭 시 로딩 표시가 나타나는가?
- [ ] 저장 완료 시 설정 화면으로 돌아가는가?
- [ ] 저장 실패 시 에러 메시지가 표시되는가?
- [ ] 변경사항 없이 저장 시 정상 동작하는가?

---

### 3.8. ProfileEditForm Widget (Presentation)

**Location**: `lib/features/profile/presentation/widgets/profile_edit_form.dart`

**Responsibility**:
- 입력 필드 렌더링 (이름, 목표 체중, 현재 체중, 목표 기간)
- 실시간 입력 검증
- 주간 감량 목표 표시

**Test Strategy**: Widget Test

**Test Scenarios (Red Phase)**:
```dart
1. 모든 입력 필드 렌더링
   - given: ProfileEditForm Widget
   - when: 빌드
   - then: 이름, 목표 체중, 현재 체중, 목표 기간 필드 표시

2. 초기 값 표시
   - given: 초기 UserProfile
   - when: 빌드
   - then: 각 필드에 초기 값 표시

3. 입력 값 변경 감지
   - given: 폼
   - when: 이름 필드 입력
   - then: onChanged 콜백 호출

4. 주간 감량 목표 계산 표시
   - given: 목표 체중 70kg, 현재 체중 80kg, 목표 기간 10주
   - when: 입력 완료
   - then: "주간 감량 목표: 1.0kg" 표시

5. 경고 메시지 표시
   - given: 주간 감량 목표 1.5kg
   - when: 계산 완료
   - then: 경고 아이콘 및 메시지 표시
```

**Implementation Order**:
1. Test: 기본 필드 렌더링
2. Code: TextField 위젯들
3. Test: 초기 값 표시
4. Code: Controller 연결
5. Test: 주간 감량 목표 표시
6. Code: 계산 로직 및 표시 위젯
7. Refactor: 재사용 가능한 입력 필드 컴포넌트 추출

**Dependencies**: Flutter Widgets, UserProfile

**QA Sheet** (수동 테스트):
- [ ] 각 필드에 라벨이 명확히 표시되는가?
- [ ] 숫자 입력 필드에 숫자 키패드가 나타나는가?
- [ ] 목표 기간 입력 시 주간 감량 목표가 즉시 계산되는가?
- [ ] 경고 메시지가 눈에 띄는 색상으로 표시되는가?
- [ ] 필드 간 탭 이동이 자연스러운가?

---

## 4. TDD Workflow

### 시작 단계
1. UserProfile Entity 테스트 작성
2. Red: 테스트 실패 확인
3. Green: 최소 코드로 테스트 통과
4. Refactor: 검증 로직 정리

### 중간 단계
5. ProfileRepository Interface 정의
6. UpdateProfileUseCase 테스트 작성 (Mock 사용)
7. Red → Green → Refactor
8. UserProfileDto 테스트 작성
9. Red → Green → Refactor

### 후반 단계
10. IsarProfileRepository Integration Test 작성
11. Red → Green → Refactor (실제 Isar 사용)
12. ProfileNotifier Unit Test 작성 (Mock 사용)
13. Red → Green → Refactor

### 완료 단계
14. ProfileEditScreen Widget Test 작성
15. Red → Green → Refactor
16. ProfileEditForm Widget Test 작성
17. Red → Green → Refactor
18. 통합 테스트 실행 및 수동 QA

### Commit 포인트
- Entity + Repository Interface 완료
- UseCase + DTO 완료
- Repository 구현 완료
- Notifier 완료
- Presentation Layer 완료

### 완료 조건
- 모든 Unit/Integration/Widget 테스트 통과
- Presentation Layer 수동 QA 체크리스트 완료
- 코드 커버리지 80% 이상
- flutter analyze 경고 0개

---

## 5. 핵심 원칙

### Test First
- 코드보다 테스트를 먼저 작성
- Red → Green → Refactor 사이클 엄격히 준수

### Small Steps
- 한 번에 하나의 시나리오만 구현
- 테스트 케이스 단위로 커밋

### FIRST 원칙
- Fast: 빠른 테스트 실행
- Independent: 독립적인 테스트
- Repeatable: 반복 가능한 결과
- Self-validating: 자동 검증
- Timely: 코드 작성 전 테스트 작성

### Test Pyramid
- Unit Test 70%: Entity, UseCase, DTO, Repository Mock
- Integration Test 20%: IsarProfileRepository
- Widget Test 10%: Screen, Form

### Outside-In 전략
- Presentation Layer에서 시작하여 필요한 하위 레이어를 순차적으로 구현
- 각 레이어는 Interface를 통해 하위 레이어와 통신

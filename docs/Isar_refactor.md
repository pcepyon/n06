# IsarDB 리팩토링 계획

## 문서 정보
- **작성일**: 2025-11-11
- **목적**: IsarDB 설정가이드와 현재 구현 비교 분석 및 수정 계획
- **참조 문서**: `docs/external/IsarDB_설정가이드.md`

---

## 현재 상황 요약

### ✅ 잘 구현된 부분

현재 코드베이스는 IsarDB를 **체계적이고 일관성 있게** 사용하고 있습니다:

1. **중앙 집중식 초기화**: `main.dart`에서 단 한 번 `Isar.open()` 호출
2. **Provider 기반 DI**: Riverpod으로 Repository 의존성 주입
3. **Repository Pattern 준수**: Domain/Infrastructure 계층 완전 분리
4. **DTO 계층 분리**: Entity ↔ DTO 변환 철저히 구현
5. **실시간 동기화**: `watch()` 활용한 reactive UI 구현
6. **인덱스 최적화**: 주요 쿼리 필드에 `@Index` 적용
7. **Phase 1 전환 준비**: Repository Interface 기반으로 95% 완료

### ⚠️ 발견된 문제점

IsarDB 설정가이드와 비교하여 **3가지 주요 차이점** 발견:

---

## 문제점 상세 분석

### 🔴 Priority 1: writeTxn 누락 (High - 즉시 수정 필요)

#### 문제 설명

일부 Repository 메서드에서 `writeTxn()` 없이 직접 `put()`/`delete()` 호출:

**현재 구현 예시**:
```dart
// lib/features/onboarding/infrastructure/repositories/isar_profile_repository.dart:13-16
@override
Future<void> saveUserProfile(UserProfile profile) async {
  final dto = UserProfileDto.fromEntity(profile);
  // 트랜잭션 내에서 호출될 수 있으므로 writeTxn 제거  ❌
  await _isar.userProfileDtos.put(dto);
}
```

#### 가이드 권장사항

```dart
@override
Future<void> saveUserProfile(UserProfile profile) async {
  final dto = UserProfileDto.fromEntity(profile);

  await _isar.writeTxn(() async {  // ⭐ 필수
    await _isar.userProfileDtos.put(dto);
  });
}
```

#### 발생하는 문제

1. **Watcher 알림 누락**
   - `writeTxn()` 없이 `put()` 호출 시 `watch()` Stream이 변경을 감지하지 못함
   - UI가 자동으로 업데이트되지 않음

2. **데이터 일관성 위험**
   - 트랜잭션 없이 실행되어 ACID 보장 불가
   - 중간 실패 시 일부만 저장되어 데이터 불일치 발생 가능

3. **가이드 베스트 프랙티스 위반**
   ```
   모든 쓰기 작업(put, delete, clear)은 반드시 writeTxn() 안에서
   실행하세요. 그래야 ACID 보장과 watcher 알림이 작동합니다.
   - docs/external/IsarDB_설정가이드.md:979-980
   ```

#### 영향 받는 파일

검토 필요 Repository:
- `lib/features/onboarding/infrastructure/repositories/isar_profile_repository.dart`
- `lib/features/onboarding/infrastructure/repositories/isar_user_repository.dart`
- `lib/features/tracking/infrastructure/repositories/isar_tracking_repository.dart` (일부 메서드)
- 기타 "트랜잭션 내에서 호출될 수 있으므로 writeTxn 제거" 주석이 있는 모든 메서드

#### 수정 방안

**옵션 A: Repository 메서드에 writeTxn 복원 (권장)**

```dart
// ✅ 권장 방법
@override
Future<void> saveUserProfile(UserProfile profile) async {
  final dto = UserProfileDto.fromEntity(profile);
  await _isar.writeTxn(() async {
    await _isar.userProfileDtos.put(dto);
  });
}
```

**장점**:
- 가이드 권장사항 준수
- watcher 알림 보장
- 단독 호출 시 안전
- 코드 단순성 유지

**단점**:
- 중첩 트랜잭션 불가 (상위에서 writeTxn 사용 시 에러)
- 하지만 현재 코드베이스에서 복합 트랜잭션 사용 사례가 거의 없음

**옵션 B: 메서드 분리 (복잡도 증가)**

```dart
// Public API: 트랜잭션 포함
@override
Future<void> saveUserProfile(UserProfile profile) async {
  await _isar.writeTxn(() async {
    await _saveUserProfileInternal(profile);
  });
}

// Internal: 트랜잭션 없음 (복합 작업용)
Future<void> _saveUserProfileInternal(UserProfile profile) async {
  final dto = UserProfileDto.fromEntity(profile);
  await _isar.userProfileDtos.put(dto);
}
```

**장점**:
- 단독/복합 작업 모두 지원
- 유연성 최대화

**단점**:
- 코드 복잡도 증가
- 모든 Repository 메서드 2배로 증가

**결정**: **옵션 A 채택**
- 현재 복합 트랜잭션 사용 사례가 적음
- 단순성과 안전성 우선

---

### 🟡 Priority 2: Isar Provider keepAlive 누락 (Medium)

#### 문제 설명

`isarProvider`에 `keepAlive` 설정이 없어 Provider가 dispose될 수 있는 위험:

**현재 구현**:
```dart
// lib/core/providers.dart
@riverpod  // ❌ keepAlive 없음
Isar isar(IsarRef ref) {
  throw UnimplementedError(
    'isarProvider must be initialized via ProviderScope override in main.dart',
  );
}
```

#### 가이드 권장사항

```dart
@Riverpod(keepAlive: true)  // ⭐ 앱 전체에서 단일 인스턴스 유지
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();

  return await Isar.open(
    [/* schemas */],
    directory: dir.path,
    name: 'glp1_database',
  );
}
```

#### 발생하는 문제

1. **Provider dispose 위험**: Auto-dispose 모드에서 Isar 인스턴스 손실 가능
2. **테스트 환경 불안정성**: Provider override 시 생명주기 관리 복잡
3. **가이드 베스트 프랙티스 위반**:
   ```
   Isar Provider는 @Riverpod(keepAlive: true)로 설정하여
   앱 전체에서 단일 인스턴스를 유지하세요.
   - docs/external/IsarDB_설정가이드.md:987-988
   ```

#### 현재 동작 상태

- **Production 환경**: 정상 작동 (main.dart에서 ProviderScope override로 keepAlive 유지)
- **잠재적 위험**: 테스트 환경에서 Provider dispose 시 Isar 인스턴스 손실 가능성

#### 수정 방안

```dart
// lib/core/providers.dart
@Riverpod(keepAlive: true)  // ✅ 추가
Isar isar(IsarRef ref) {
  throw UnimplementedError(
    'isarProvider must be initialized via ProviderScope override in main.dart',
  );
}
```

**효과**:
- Provider dispose 방지
- 테스트 환경 안정성 향상
- 가이드 베스트 프랙티스 준수

**주의**: 현재 `main.dart`의 override 패턴은 유지 (문제 없음)

---

### 🔵 Priority 3: watch() 과다 사용 (Low - 선택적 최적화)

#### 문제 설명

모든 Repository에서 `watch()` 사용 (자동 데이터 로드):

**현재 구현**:
```dart
Stream<List<WeightLog>> watchWeightLogs(String userId) {
  return _isar.weightLogDtos
      .filter()
      .userIdEqualTo(userId)
      .watch(fireImmediately: true)  // ❌ 자동 로드
      .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
}
```

#### 가이드 권장사항

```dart
// watchLazy: 변경 감지만, 데이터는 수동 로드 (권장)
Stream<List<Dose>> watchDoses() {
  return isar.doseRecordDtos
      .watchLazy()  // ⭐ 변경 감지만
      .asyncMap((_) async => await getAllDoses());  // 수동 로드
}
```

#### 발생하는 문제

1. **불필요한 쿼리 실행**: 데이터 변경 시 전체 쿼리 자동 재실행
2. **메모리 오버헤드**: `watch()`는 항상 최신 데이터를 메모리에 유지
3. **복잡한 쿼리 비효율**: filter 조건이 많거나 join이 필요한 경우 매번 전체 쿼리 실행

#### 가이드 설명

```
watchLazy vs watch: 대부분은 watchLazy()를 사용하고 수동으로
데이터를 로드하세요. watch()는 자동 로드하지만 불필요한 쿼리가
실행될 수 있습니다.
- docs/external/IsarDB_설정가이드.md:983-984
```

#### 영향도

- **현재**: 작은 데이터셋이라 성능 문제 없음
- **장기적**: 데이터 증가 시 성능 저하 가능성

#### 수정 방안

**전환 기준**:

**watch() 유지**:
- 단순 쿼리 (filter 1-2개)
- 작은 데이터셋 (<100개)
- 실시간성이 중요한 UI

**watchLazy() 전환**:
- 복잡한 쿼리 (filter 3개 이상, join 필요)
- 큰 데이터셋 (>100개)
- 통계/집계 쿼리

**예시 (전환 추천)**:

```dart
// Before
Stream<List<SymptomLog>> watchSymptomLogs(String userId) {
  return _isar.symptomLogDtos
      .filter()
      .userIdEqualTo(userId)
      .watch(fireImmediately: true)  // ❌ 복잡한 쿼리에 비효율적
      .asyncMap((dtos) async {
        // 각 SymptomLog의 태그 조회 (N+1 쿼리)
        for (final dto in dtos) {
          final tags = await _isar.symptomContextTagDtos
              .filter()
              .symptomLogIsarIdEqualTo(dto.id)
              .findAll();
        }
        return logs;
      });
}

// After
Stream<List<SymptomLog>> watchSymptomLogs(String userId) {
  return _isar.symptomLogDtos
      .watchLazy()  // ✅ 변경 감지만
      .asyncMap((_) async => await getAllSymptomLogs(userId));  // 수동 로드
}

Future<List<SymptomLog>> getAllSymptomLogs(String userId) async {
  // 최적화된 쿼리 로직
}
```

**결정**: Phase 0 완료 후 성능 테스트를 통해 선택적 적용

---

### 🟢 Priority 4: 인덱스 추가 기회 (Low - 선택적 최적화)

#### 현재 상태

@Index가 적용된 필드 (5개 DTO):
- `UserDto`: `oauthProvider` + `oauthUserId` (composite, unique)
- `ConsentRecordDto`: `userId`
- `DoseRecordDto`: `indexedDate`
- `EmergencySymptomCheckDto`: `userId`, `checkedAt`

#### 추가 인덱스 추천

```dart
// WeightLogDto
@Index()
late DateTime logDate;  // 날짜 범위 쿼리 최적화

// SymptomLogDto
@Index()
late DateTime logDate;

// DosagePlanDto
@Index()
late String userId;
@Index()
late bool isActive;

// DoseScheduleDto
@Index()
late String userId;
```

#### 효과

- 자주 쿼리하는 필드의 조회 속도 향상
- filter 조건으로 사용되는 필드 최적화

#### 영향도

- **현재**: 성능 문제 없음
- **권장**: Phase 1 전환 전 데이터 증가를 고려하여 추가

#### 주의사항

가이드 베스트 프랙티스:
```
인덱스는 신중하게: 자주 쿼리하는 필드에만 @Index()를 추가하세요.
인덱스가 많으면 쓰기 성능이 저하됩니다.
- docs/external/IsarDB_설정가이드.md:981-982
```

**결정**: Phase 1 전환 전 성능 모니터링 후 결정

---

## 수정 계획

### Phase 1: Critical Fixes (즉시 수정)

#### 1.1 writeTxn 복원

**작업 범위**: 약 5개 Repository

**대상 파일**:
```
lib/features/onboarding/infrastructure/repositories/
  - isar_profile_repository.dart
  - isar_user_repository.dart

lib/features/tracking/infrastructure/repositories/
  - isar_tracking_repository.dart (일부 메서드)
  - isar_medication_repository.dart (검토 필요)

lib/features/authentication/infrastructure/repositories/
  - isar_auth_repository.dart (검토 필요)
```

**수정 패턴**:
```dart
// Before
Future<void> saveData(Entity entity) async {
  final dto = EntityDto.fromEntity(entity);
  await _isar.entityDtos.put(dto);  // ❌
}

// After
Future<void> saveData(Entity entity) async {
  final dto = EntityDto.fromEntity(entity);
  await _isar.writeTxn(() async {  // ✅
    await _isar.entityDtos.put(dto);
  });
}
```

**검증 방법**:
```dart
test('데이터 저장 시 watcher 알림 확인', () async {
  final stream = repository.watchData();

  await repository.saveData(testData);

  await expectLater(
    stream,
    emits(contains(testData)),  // watcher가 변경 감지했는지 확인
  );
});
```

**예상 소요 시간**: 1-2시간

---

#### 1.2 keepAlive 추가

**작업 범위**: 1개 파일

**대상 파일**:
```
lib/core/providers.dart
```

**수정 내용**:
```dart
// Before
@riverpod
Isar isar(IsarRef ref) {
  throw UnimplementedError(
    'isarProvider must be initialized via ProviderScope override in main.dart',
  );
}

// After
@Riverpod(keepAlive: true)  // ✅
Isar isar(IsarRef ref) {
  throw UnimplementedError(
    'isarProvider must be initialized via ProviderScope override in main.dart',
  );
}
```

**Code Generation 재실행**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**예상 소요 시간**: 5분

---

### Phase 2: Optimization (선택적, Phase 0 완료 후)

#### 2.1 watchLazy 전환

**작업 범위**: 복잡한 쿼리만 선택적 적용

**전환 대상 우선순위**:

1. **High Priority**: N+1 쿼리가 있는 메서드
   ```dart
   // SymptomLog + ContextTag join
   Stream<List<SymptomLog>> watchSymptomLogs(String userId)
   ```

2. **Medium Priority**: Filter 조건이 3개 이상
   ```dart
   // 날짜 범위 + 유저 + 타입 필터
   Stream<List<DoseRecord>> watchFilteredDoses(...)
   ```

3. **Low Priority**: 큰 데이터셋 (>100개 예상)
   ```dart
   Stream<List<WeightLog>> watchAllWeightLogs(String userId)
   ```

**예상 소요 시간**: 3-4시간

**성능 테스트 필요**: 전환 전후 벤치마크

---

#### 2.2 인덱스 추가

**작업 범위**: 약 4개 DTO

**대상 파일**:
```
lib/features/tracking/infrastructure/dtos/
  - weight_log_dto.dart
  - symptom_log_dto.dart
  - dosage_plan_dto.dart
  - dose_schedule_dto.dart
```

**수정 예시**:
```dart
// weight_log_dto.dart
@collection
class WeightLogDto {
  Id id = Isar.autoIncrement;

  late String userId;

  @Index()  // ✅ 추가
  late DateTime logDate;

  late double weightKg;
  String? notes;
}
```

**Code Generation 재실행 필요**

**예상 소요 시간**: 1시간

---

## 실행 순서

### Step 1: 사전 준비
```bash
# 1. 현재 브랜치 확인 및 새 브랜치 생성
git checkout -b refactor/isar-improvements

# 2. 모든 테스트 실행 (baseline)
flutter test

# 3. 결과 기록
```

### Step 2: Priority 1 수정 (필수)
```bash
# 1. keepAlive 추가
# - lib/core/providers.dart 수정

# 2. Code generation
dart run build_runner build --delete-conflicting-outputs

# 3. writeTxn 복원
# - Repository 파일들 수정

# 4. 테스트 실행
flutter test

# 5. 수동 테스트
# - 앱 실행하여 watcher 동작 확인
# - 데이터 저장 후 UI 자동 업데이트 확인

# 6. Commit
git add .
git commit -m "fix: IsarDB writeTxn 복원 및 keepAlive 추가

- Repository 메서드에 writeTxn() 복원하여 watcher 알림 보장
- isarProvider에 keepAlive: true 추가하여 dispose 방지
- IsarDB 설정가이드 베스트 프랙티스 준수

Fixes: #[issue-number]"
```

### Step 3: Priority 2-3 수정 (선택적)
```bash
# Phase 0 완료 후 성능 테스트를 통해 결정
# 1. watchLazy 전환 (필요시)
# 2. 인덱스 추가 (필요시)
```

---

## 테스트 체크리스트

### Unit Test
- [ ] `writeTxn` 복원 후 모든 Repository 테스트 통과
- [ ] watcher 알림 정상 작동 확인
- [ ] 중첩 트랜잭션 에러 발생하지 않는지 확인

### Integration Test
- [ ] 데이터 저장 후 UI 자동 업데이트 확인
- [ ] 여러 데이터 동시 저장 시 트랜잭션 정상 처리
- [ ] 에러 발생 시 롤백 확인

### Performance Test (Phase 2)
- [ ] `watch()` vs `watchLazy()` 성능 비교
- [ ] 인덱스 추가 전후 쿼리 속도 측정
- [ ] 메모리 사용량 모니터링

---

## 예상 영향 범위

### 긍정적 영향

1. **데이터 일관성 보장**
   - 트랜잭션을 통한 ACID 보장
   - 중간 실패 시 자동 롤백

2. **실시간 동기화 보장**
   - watcher 알림 정상 작동
   - UI 자동 업데이트 보장

3. **가이드 준수**
   - IsarDB 베스트 프랙티스 준수
   - 유지보수성 향상

4. **테스트 안정성**
   - Provider dispose 방지
   - 테스트 환경 안정화

### 잠재적 리스크

1. **중첩 트랜잭션 에러** (Low Risk)
   - 현재 복합 트랜잭션 사용 사례가 적음
   - 발생 시 상위 레이어에서 트랜잭션 관리로 해결

2. **성능 영향** (Very Low Risk)
   - 트랜잭션 오버헤드는 무시할 수준
   - 오히려 watcher 알림으로 사용자 경험 개선

3. **빌드 시간 증가** (Code Generation)
   - keepAlive 추가 시 build_runner 재실행 필요
   - 일회성 작업

---

## Phase 1 전환 준비도

### 수정 전
- **95%** 준비 완료
- Repository Interface 기반 구조 완성
- 데이터 일관성 이슈 존재

### 수정 후
- **100%** 준비 완료
- 모든 Repository가 가이드 베스트 프랙티스 준수
- 안정적인 데이터 계층 확보
- Supabase 전환 시 1줄 변경으로 가능

```dart
// Phase 0
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarMedicationRepository(isar);  // ✅ 안정적
}

// Phase 1 (1줄 변경)
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationRepository(supabase);  // 🚀 전환 완료
}
```

---

## 참고 자료

### 내부 문서
- `docs/external/IsarDB_설정가이드.md` - IsarDB 공식 설정 가이드
- `docs/code_structure.md` - 4-Layer Architecture 구조
- `docs/state-management.md` - Riverpod 상태 관리 패턴
- `docs/tdd.md` - TDD 워크플로우

### 외부 문서
- [Isar Official Documentation](https://isar.dev)
- [Isar Transactions](https://isar.dev/transactions.html)
- [Isar Watchers](https://isar.dev/watchers.html)
- [Riverpod keepAlive](https://riverpod.dev/docs/concepts/modifiers/keep_alive)

---

## 결론

### 즉시 수정 필요 (Priority 1)
- ✅ **writeTxn 복원**: 데이터 일관성 및 watcher 알림 보장
- ✅ **keepAlive 추가**: Provider 안정성 확보

### 선택적 최적화 (Priority 2-3)
- 🔧 **watchLazy 전환**: 성능 테스트 후 결정
- 🔧 **인덱스 추가**: Phase 1 전환 전 고려

### 기대 효과
- **데이터 일관성**: 100% 보장
- **실시간 동기화**: watcher 알림 정상화
- **Phase 1 전환**: 완벽한 준비 상태
- **유지보수성**: 가이드 준수로 코드 품질 향상

---

**작업 시작 준비 완료** ✅

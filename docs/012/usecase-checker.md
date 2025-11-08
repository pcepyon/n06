# UF-009: 투여 계획 수정 기능 점검 보고서

## 기능명
투여 계획 수정 (UF-009: Edit Dosage Plan)

## 최종 상태
부분완료 (Partially Complete)

---

## 1. 구현 완료 항목

### Domain Layer (Entity 및 UseCase)
- [x] **DosagePlan Entity** (`lib/features/tracking/domain/entities/dosage_plan.dart`)
  - EscalationStep 클래스 포함
  - copyWith, getCurrentDose, getWeeksElapsed 메서드 구현
  - 구성자에서 엄격한 검증 로직 적용
  - 테스트: 모든 테스트 통과 (13개 테스트)

- [x] **PlanChangeHistory Entity** (`lib/features/tracking/domain/entities/plan_change_history.dart`)
  - 완전 구현, copyWith 메서드 포함
  - 프로덕션 레벨 코드

- [x] **DoseSchedule Entity** (`lib/features/tracking/domain/entities/dose_schedule.dart`)
  - isOverdue, isToday, isUpcoming 등 유틸리티 메서드 구현
  - 완전 구현 및 테스트 통과

- [x] **ValidateDosagePlanUseCase** (`lib/features/tracking/domain/usecases/validate_dosage_plan_usecase.dart`)
  - 약물명, 주기, 용량, 증량 계획 검증
  - ValidationResult 클래스 포함
  - 테스트: 모든 테스트 통과 (6개 테스트)

- [x] **RecalculateDoseScheduleUseCase** (`lib/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart`)
  - 미래 스케줄 재계산 로직 구현
  - 증량 계획 반영 (getCurrentDose 활용)
  - 성능: 1초 이내 완료 보장하도록 설계
  - 테스트: 모든 테스트 통과

- [x] **AnalyzePlanChangeImpactUseCase** (`lib/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart`)
  - PlanChangeImpact 데이터 클래스 포함
  - 필드 변경 감지, 영향받는 스케줄 개수 계산
  - 경고 메시지 생성 로직 (증량 단계 진행 중, 대폭 용량 변경 등)
  - 테스트: 모든 테스트 통과

### Infrastructure Layer (DTO)
- [x] **DosagePlanDto** (`lib/features/tracking/infrastructure/dtos/dosage_plan_dto.dart`)
  - EscalationStepDto 임베디드 클래스 포함
  - toEntity/fromEntity 메서드 구현
  - Isar 컬렉션 설정 완료

- [x] **DoseScheduleDto** (`lib/features/tracking/infrastructure/dtos/dose_schedule_dto.dart`)
  - toEntity/fromEntity 메서드 구현
  - Isar 컬렉션 설정 완료

- [x] **PlanChangeHistoryDto** (`lib/features/tracking/infrastructure/dtos/plan_change_history_dto.dart`)
  - Isar 컬렉션 설정 완료
  - 기본 구조 구현

### Presentation Layer (UI)
- [x] **EditDosagePlanScreen** (`lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart`)
  - ConsumerWidget으로 구현
  - 투여 계획 입력 폼 구현
  - 실시간 입력 검증
  - 영향 분석 다이얼로그 표시
  - 저장 버튼 및 확인 다이얼로그 구현
  - 성공/실패 스낵바 표시
  - 프로덕션 레벨 코드

### Application Layer
- [x] **UpdateDosagePlanUseCase** (`lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart`)
  - UpdateDosagePlanResult 클래스 포함
  - 완전한 워크플로우 구현:
    1. 계획 검증
    2. 영향 분석
    3. 변경 없으면 조기 복귀
    4. 계획 업데이트 및 이력 저장
    5. 미래 스케줄 삭제
    6. 스케줄 재계산 및 저장
  - 에러 처리 로직 포함

- [x] **Provider 설정** (`lib/features/tracking/application/providers.dart`)
  - validateDosagePlanUseCaseProvider
  - recalculateDoseScheduleUseCaseProvider
  - analyzePlanChangeImpactUseCaseProvider
  - updateDosagePlanUseCaseProvider
  - 모두 올바르게 연결됨

---

## 2. 미구현 항목

### 1. DoseScheduleRepository 인터페이스 부재
**위치**: 필요 위치 `/lib/features/tracking/domain/repositories/dose_schedule_repository.dart`

**현황**:
- MedicationRepository에 DoseSchedule 관련 메서드가 포함되어 있음
- 하지만 spec의 아키텍처 다이어그램에서는 별도의 DoseScheduleRepository 인터페이스를 지정함
- 현재 구조: MedicationRepository가 모든 책임을 가짐

**구현 필요 메서드**:
```dart
abstract class DoseScheduleRepository {
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId);
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules);
  Future<void> deleteFutureSchedules(String dosagePlanId, DateTime fromDate);
}
```

### 2. IsarDoseScheduleRepository 부재
**위치**: 필요 위치 `/lib/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart`

**현황**:
- MedicationRepository 구현체(IsarMedicationRepository)에서 모든 기능 처리
- 별도의 저장소 클래스 미존재

### 3. DosagePlanRepository 인터페이스 부재
**위치**: 필요 위치 `/lib/features/tracking/domain/repositories/dosage_plan_repository.dart`

**현황**:
- MedicationRepository에 통합되어 있음
- spec에서는 DosagePlanRepository와 DoseScheduleRepository 분리를 명시

### 4. DosagePlanNotifier 부재
**위치**: 필요 위치 `/lib/features/tracking/application/notifiers/dosage_plan_notifier.dart`

**현황**:
- MedicationNotifier가 있으나, 투여 계획만 관리하는 전용 Notifier 없음
- spec에서는 DosagePlanNotifier를 명시함

### 5. PlanChangeHistoryDto JSON 처리 미완성
**파일**: `/lib/features/tracking/infrastructure/dtos/plan_change_history_dto.dart`

**문제**:
```dart
static String _mapToJson(Map<String, dynamic> map) {
  return map.toString();  // ❌ 임시 구현
}

static Map<String, dynamic> _jsonToMap(String json) {
  return {};  // ❌ 빈 맵 반환
}
```

**필요 조치**:
- dart:convert의 jsonEncode/jsonDecode 사용
- 정상적인 JSON 직렬화/역직렬화 구현

---

## 3. 구현 문제점 및 개선사항

### 고위험 (High Priority)

#### 문제 1: PlanChangeHistoryDto JSON 직렬화 버그
- **심각도**: 높음
- **영향**: 투여 계획 변경 이력이 데이터베이스에 제대로 저장되지 않음
- **현재 코드**:
  ```dart
  // plan_change_history_dto.dart line 39-48
  static String _mapToJson(Map<String, dynamic> map) {
    return map.toString();  // 문자열 변환만 함
  }

  static Map<String, dynamic> _jsonToMap(String json) {
    return {};  // 항상 빈 맵 반환
  }
  ```
- **수정안**:
  ```dart
  import 'dart:convert';

  static String _mapToJson(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  static Map<String, dynamic> _jsonToMap(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }
  ```

#### 문제 2: 아키텍처 위반 (Repository Pattern)
- **심각도**: 높음
- **영향**: Phase 1 전환 시 Infrastructure 레이어 변경 불가능
- **현재 구조**: MedicationRepository (모놀리식)
- **필요 구조**: DosagePlanRepository + DoseScheduleRepository (분리된 책임)
- **CLAUDE.md 규칙 위반**: "Repository Pattern 엄격하게 시행"

#### 문제 3: DoseSchedule Entity 필드명 불일치
- **파일**: `/lib/features/tracking/domain/entities/dose_schedule.dart`
- **문제**:
  - Entity: `scheduledDoseMg`
  - DTO: `scheduledDoseMg`
  - 하지만 UpdateDosagePlanUseCase에서는 `doseMg` 참조 가능
- **영향**: 필드명 일관성 부족

#### 문제 4: Repository 트랜잭션 관리
- **파일**: `/lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart`
- **문제**:
  ```dart
  // updateDosagePlan과 savePlanChangeHistory가 분리됨
  await medicationRepository.updateDosagePlan(newPlan);
  await medicationRepository.savePlanChangeHistory(...);
  ```
- **필요성**: spec에서 "계획 업데이트와 이력 저장은 하나의 트랜잭션"이라고 명시
- **현재 상태**: 원자성 미보장

### 중간위험 (Medium Priority)

#### 문제 5: MedicationRepository 메서드 명명 불일치
- **파일**: `/lib/features/tracking/domain/repositories/medication_repository.dart`
- **문제**:
  - savePlanChangeHistory(String planId, Map, Map) - 3개 파라미터
  - PlanChangeHistory 엔티티를 직접 받는 메서드와 다름
- **개선안**:
  ```dart
  // 추가 메서드 지원
  Future<void> savePlanChangeHistoryEntity(PlanChangeHistory history);
  ```

#### 문제 6: 성능 검증 테스트 부재
- **파일**: test/features/tracking/domain/usecases/
- **문제**: RecalculateDoseScheduleUseCase의 "1초 이내 완료" 요구사항 검증 테스트 없음
- **필요**: Stopwatch를 이용한 성능 테스트

#### 문제 7: 통합 테스트 부재
- **현황**: 각 모듈 단위 테스트는 있으나, 전체 워크플로우 통합 테스트 없음
- **필요**: 투여 계획 수정 전체 프로세스 테스트
  - 계획 생성
  - 초기 스케줄 생성
  - 계획 수정
  - 스케줄 재계산
  - 이력 저장 확인

### 낮은 위험 (Low Priority)

#### 문제 8: Widget Test 부재
- **Presentation Layer**: EditDosagePlanScreen은 구현되었으나 widget test 없음
- **필요**:
  - 폼 렌더링 테스트
  - 입력 검증 피드백 테스트
  - 영향 분석 다이얼로그 표시 테스트
  - 저장 버튼 동작 테스트

#### 문제 9: 네트워크 오류 재시도 로직 미구현
- **Spec**: "네트워크 오류 시 최대 3회 자동 재시도"
- **현황**: UpdateDosagePlanUseCase에 재시도 로직 없음
- **필요**: 재시도 메커니즘 추가

#### 문제 10: 앱 종료 시 임시 저장 미구현
- **Spec**: "저장 중 앱 종료 시 로컬에 변경사항 임시 저장"
- **현황**: 미구현

---

## 4. 아키텍처 분석

### 현재 상태
```
Presentation Layer (EditDosagePlanScreen) ✓
    ↓
Application Layer
  ├─ UpdateDosagePlanUseCase ✓
  └─ Providers ✓
    ↓
Domain Layer
  ├─ Entity (DosagePlan, DoseSchedule, PlanChangeHistory) ✓
  ├─ UseCase (Validate, Recalculate, AnalyzePlanChangeImpact) ✓
  └─ Repository Interface (MedicationRepository only) ⚠️
    ↓
Infrastructure Layer
  ├─ DTO (DosagePlanDto, DoseScheduleDto, PlanChangeHistoryDto) ✓
  └─ Repository Implementation (IsarMedicationRepository) ⚠️
```

### 문제점
1. **Repository 분리 부족**: DosagePlanRepository와 DoseScheduleRepository로 분리 필요
2. **트랜잭션 관리**: 계획 업데이트와 이력 저장을 원자적으로 처리하는 메서드 필요
3. **Interface Segregation**: MedicationRepository가 너무 많은 책임을 가짐

---

## 5. 테스트 현황

### 통과한 테스트
- [x] DosagePlan Entity 테스트 (13개 테스트, 100% 통과)
- [x] ValidateDosagePlanUseCase 테스트 (6개 테스트, 100% 통과)
- [x] RecalculateDoseScheduleUseCase 테스트 (100% 통과)
- [x] AnalyzePlanChangeImpactUseCase 테스트 (100% 통과)
- [x] DoseSchedule Entity 테스트 (100% 통과)

### 미실시 테스트
- [ ] UpdateDosagePlanUseCase (Unit Test - Mock Repository 필요)
- [ ] IsarMedicationRepository 통합 테스트
- [ ] EditDosagePlanScreen Widget 테스트
- [ ] 전체 워크플로우 통합 테스트
- [ ] 성능 테스트 (RecalculateDoseScheduleUseCase 1초 이내)

---

## 6. 구현 계획 (미완료 항목)

### Phase 1: Repository 분리 (Critical)
```dart
// 1. DosagePlanRepository 인터페이스 생성
abstract class DosagePlanRepository {
  Future<DosagePlan?> getActiveDosagePlan(String userId);
  Future<void> saveDosagePlan(DosagePlan plan);
  Future<void> updateDosagePlan(DosagePlan plan);
  Future<DosagePlan?> getDosagePlan(String planId);
  Future<void> savePlanChangeHistory(PlanChangeHistory history);
  Future<List<PlanChangeHistory>> getPlanChangeHistory(String planId);
  Future<void> updatePlanWithHistory(DosagePlan plan, PlanChangeHistory history);
}

// 2. DoseScheduleRepository 인터페이스 생성
abstract class DoseScheduleRepository {
  Future<List<DoseSchedule>> getSchedulesByPlanId(String dosagePlanId);
  Future<void> saveBatchSchedules(List<DoseSchedule> schedules);
  Future<void> deleteFutureSchedules(String dosagePlanId, DateTime fromDate);
}

// 3. 기존 MedicationRepository에서 분리
// 4. IsarMedicationRepository 리팩토링
// 5. IsarDosagePlanRepository, IsarDoseScheduleRepository 생성
```

### Phase 2: JSON 직렬화 수정 (Critical)
```dart
// PlanChangeHistoryDto 수정
import 'dart:convert';

static String _mapToJson(Map<String, dynamic> map) {
  return jsonEncode(map);
}

static Map<String, dynamic> _jsonToMap(String json) {
  return jsonDecode(json) as Map<String, dynamic>;
}
```

### Phase 3: 트랜잭션 관리 개선 (High)
```dart
// DosagePlanRepository에 추가
Future<void> updatePlanWithHistory(
  DosagePlan plan,
  PlanChangeHistory history,
);
```

### Phase 4: DosagePlanNotifier 생성 (Medium)
```dart
// AsyncNotifier 기반으로 생성
class DosagePlanNotifier extends AsyncNotifier<DosagePlan?> {
  @override
  Future<DosagePlan?> build() async {
    // userId 주입 필요
  }

  Future<void> updatePlan(DosagePlan oldPlan, DosagePlan newPlan) async {
    // UpdateDosagePlanUseCase 호출
  }
}
```

### Phase 5: Widget 테스트 추가 (Medium)
- EditDosagePlanScreen 테스트
- 영향 분석 다이얼로그 테스트
- 폼 검증 피드백 테스트

### Phase 6: 통합 테스트 추가 (Medium)
- 투여 계획 수정 전체 워크플로우
- 스케줄 재계산 검증
- 이력 저장 검증

---

## 7. 프로덕션 레벨 점검표

| 항목 | 상태 | 설명 |
|-----|------|------|
| Entity 구현 | ✅ | 모든 엔티티 완전 구현 |
| UseCase 구현 | ✅ | 모든 도메인 UseCase 완전 구현 |
| Repository Interface | ⚠️ | MedicationRepository로 통합, 분리 필요 |
| Repository 구현 | ⚠️ | IsarMedicationRepository만 존재 |
| DTO 구현 | ⚠️ | 기본 구현, JSON 직렬화 버그 |
| Provider 설정 | ✅ | 올바르게 설정됨 |
| UI 구현 | ✅ | EditDosagePlanScreen 완전 구현 |
| 도메인 로직 테스트 | ✅ | 모든 테스트 통과 |
| 통합 테스트 | ❌ | 미구현 |
| Widget 테스트 | ❌ | 미구현 |
| 성능 검증 | ⚠️ | 1초 이내 요구사항 검증 테스트 없음 |
| 트랜잭션 관리 | ⚠️ | 원자성 미보장 |
| 에러 처리 | ✅ | 기본 에러 처리 구현 |
| 네트워크 재시도 | ❌ | 미구현 |
| 임시 저장 | ❌ | 미구현 |

---

## 8. 최종 평가

### 완료도
- **Domain Layer**: 95% (테스트 포함)
- **Application Layer**: 90% (UpdateDosagePlanUseCase 완전, Notifier 미분리)
- **Infrastructure Layer**: 70% (DTO 기본, Repository 분리 필요, JSON 버그)
- **Presentation Layer**: 90% (UI 완성, Widget 테스트 미실시)

### 프로덕션 배포 가능성
**현재: 불가능** (Critical 이슈 2개 존재)

#### Critical Issues
1. PlanChangeHistoryDto JSON 직렬화 버그 - 즉시 수정 필요
2. Repository 분리 미실시 - 아키텍처 규칙 위반

#### 배포 전 필수 조치
1. ✓ PlanChangeHistoryDto JSON 직렬화 수정
2. ✓ DosagePlanRepository, DoseScheduleRepository 분리 생성
3. ✓ 통합 테스트 작성 및 통과
4. ✓ Widget 테스트 작성 및 통과

#### 권장 사항
- 네트워크 오류 재시도 로직 추가
- 앱 종료 시 임시 저장 기능 추가
- 성능 테스트 추가

---

## 9. 관련 파일 목록

### 완료된 파일
1. `/lib/features/tracking/domain/entities/dosage_plan.dart`
2. `/lib/features/tracking/domain/entities/dose_schedule.dart`
3. `/lib/features/tracking/domain/entities/plan_change_history.dart`
4. `/lib/features/tracking/domain/usecases/validate_dosage_plan_usecase.dart`
5. `/lib/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart`
6. `/lib/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart`
7. `/lib/features/tracking/infrastructure/dtos/dosage_plan_dto.dart`
8. `/lib/features/tracking/infrastructure/dtos/dose_schedule_dto.dart`
9. `/lib/features/tracking/infrastructure/dtos/plan_change_history_dto.dart` (JSON 버그 있음)
10. `/lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart`
11. `/lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart`
12. `/lib/features/tracking/application/providers.dart`

### 미구현 파일
1. `/lib/features/tracking/domain/repositories/dosage_plan_repository.dart` (필수)
2. `/lib/features/tracking/domain/repositories/dose_schedule_repository.dart` (필수)
3. `/lib/features/tracking/infrastructure/repositories/isar_dosage_plan_repository.dart` (필수)
4. `/lib/features/tracking/infrastructure/repositories/isar_dose_schedule_repository.dart` (필수)
5. `/lib/features/tracking/application/notifiers/dosage_plan_notifier.dart` (권장)
6. `test/features/tracking/application/usecases/update_dosage_plan_usecase_test.dart`
7. `test/features/tracking/presentation/screens/edit_dosage_plan_screen_test.dart`
8. `test/features/tracking/integration/dosage_plan_workflow_test.dart`

---

## 결론

**투여 계획 수정 기능은 부분적으로 구현되었으며, 아래 사항을 해결하면 프로덕션 배포 가능:**

1. **PlanChangeHistoryDto JSON 직렬화 버그 수정** (1-2시간)
2. **Repository 분리** (DosagePlanRepository, DoseScheduleRepository 생성) (2-3시간)
3. **통합 테스트 작성** (2시간)
4. **Widget 테스트 작성** (1.5시간)

**총 소요 시간: 약 6.5-8.5시간**

이후 권장사항 (네트워크 재시도, 임시 저장, 성능 테스트)까지 구현하면 완전한 프로덕션 레벨 기능이 될 것으로 예상됨.

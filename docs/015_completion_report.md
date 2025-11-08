# 작업 완료 보고서 (015): DashboardNotifier 컴파일 에러 수정

## 작업 개요

DashboardNotifier에서 발생한 컴파일 에러를 해결하였습니다.

**작업 일시**: 2025-11-08
**대상 파일**: `/lib/features/dashboard/application/notifiers/dashboard_notifier.dart`

---

## 문제 분석

### 1. Import 누락
다음 providers가 import되지 않아 컴파일 에러 발생:
- `profileRepositoryProvider` (onboarding feature)
- `trackingRepositoryProvider` (tracking feature)
- `medicationRepositoryProvider` (onboarding feature)
- `badgeRepositoryProvider` (dashboard feature)
- `authNotifierProvider` (authentication feature)

### 2. userId 파라미터 누락
Repository 메서드 호출 시 userId 파라미터가 누락되어 있었습니다:
- `getUserProfile(userId)` 호출 필요
- `getWeightLogs(userId)` 호출 필요
- `getSymptomLogs(userId)` 호출 필요
- `getActiveDosagePlan(userId)` 호출 필요

### 3. 엔티티 버전 불일치
onboarding과 tracking feature의 DosagePlan 엔티티가 서로 다르게 정의되어 있었습니다.

### 4. Value Object 접근
onboarding의 DosagePlan에서 startDate는 StartDate value object이며, `.value` 프로퍼티로 DateTime에 접근해야 합니다.

---

## 수정 사항

### 1. Import 추가 및 정리

```dart
// onboarding/medication_repository 사용 (DosagePlan 조회용)
import 'package:n06/features/onboarding/domain/repositories/medication_repository.dart'
    as onboarding_medication_repo;
import 'package:n06/features/onboarding/domain/entities/dosage_plan.dart'
    as onboarding_dosage_plan;

// tracking repositories 사용 (WeightLog, SymptomLog 조회용)
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

// Providers 명시적 import (namespace 사용하여 충돌 회피)
import 'package:n06/features/onboarding/application/providers.dart'
    as onboarding_providers;
import 'package:n06/features/tracking/application/providers.dart'
    as tracking_providers;
import 'package:n06/features/dashboard/application/providers.dart';

// 인증 상태 접근용
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
```

### 2. build() 메서드 수정

```dart
@override
Future<DashboardData> build() async {
  // 인증 상태에서 userId 가져오기
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.value?.id;

  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // repositories 초기화 (namespace를 통해 올바른 provider 참조)
  _profileRepository = ref.watch(onboarding_providers.profileRepositoryProvider);
  _trackingRepository = ref.watch(tracking_providers.trackingRepositoryProvider);
  _medicationRepository =
      ref.watch(onboarding_providers.medicationRepositoryProvider);
  _badgeRepository = ref.watch(badgeRepositoryProvider);

  return _loadDashboardData(userId);
}
```

### 3. 메서드 시그니처 수정

```dart
// userId를 파라미터로 전달
Future<DashboardData> _loadDashboardData(String userId) async {
  // 프로필 조회 - userId 전달
  final profile = await _profileRepository.getUserProfile(userId);

  // 활성 투여 계획 조회 - userId 전달
  final activePlan = await _medicationRepository.getActiveDosagePlan(userId);

  // 체중/증상 기록 조회 - userId 전달
  final weights = await _trackingRepository.getWeightLogs(userId);
  final symptoms = await _trackingRepository.getSymptomLogs(userId);
}
```

### 4. refresh() 메서드 수정

refresh() 메서드도 동일하게 userId를 추출하고 전달하도록 수정했습니다.

### 5. 엔티티 타입 명시

```dart
// onboarding DosagePlan을 명시적으로 사용
NextSchedule _buildNextSchedule(
  onboarding_dosage_plan.DosagePlan activePlan,
  List<WeightLog> weights,
  UserProfile profile,
) {
  // ...
}

// StartDate value object의 .value 프로퍼티로 DateTime 접근
final currentWeek = _calculateCurrentWeek.execute(activePlan.startDate.value);
```

### 6. 불필요한 imports 정리

- `calculate_adherence_usecase` 제거 (사용되지 않음)
- `dose_record`, `dose_schedule` 제거 (현재 버전에서 사용 안 함)

---

## 검증 결과

### 컴파일 상태
```
Analyzing dashboard_notifier.dart...
No issues found! (ran in 0.5s)
```

### 주요 수정 내용 요약

| 항목 | 변경 전 | 변경 후 |
|------|--------|--------|
| Import 충돌 | `profileRepositoryProvider` 미정의 | `onboarding_providers.profileRepositoryProvider` |
| userId 처리 | 없음 | authNotifierProvider에서 추출 |
| Repository 호출 | `getUserProfile()` | `getUserProfile(userId)` |
| 엔티티 버전 | 혼동됨 | onboarding_dosage_plan 명시적 사용 |
| Value Object 접근 | `activePlan.startDate as DateTime` | `activePlan.startDate.value` |

---

## 아키텍처 준수

### CLAUDE.md 규칙 준수

1. **Layer Dependency 준수**
   - Presentation → Application → Domain ← Infrastructure
   - DashboardNotifier는 repositories를 통해서만 데이터 접근

2. **Repository Pattern 준수**
   - Repository Interface는 Domain Layer에 정의
   - Repository 구현체는 Infrastructure Layer
   - DashboardNotifier는 Interface에만 의존

3. **Namespace 활용으로 Import 충돌 해결**
   - onboarding과 tracking의 중복 provider names를 namespace로 구분
   - 명확한 의도 표현

---

## 남은 이슈

### 관련 없는 다른 모듈의 에러들
전체 프로젝트 analyze 결과에는 test 파일들의 에러들이 있지만, 이는 이 수정과 무관합니다:
- notification_settings_screen_test.dart: mockito 의존성 누락
- profile_notifier_update_weekly_goals_test.dart: riverpod 의존성 누락

이러한 이슈들은 별도의 작업으로 처리되어야 합니다.

---

## 코드 품질 체크

- Type Safe: 모든 타입이 명시적으로 정의됨
- Lint Error: 없음
- Build Error: 없음
- 하드코딩값: 없음 (모든 값이 런타임 또는 설정값에서 제공)

---

## 결론

DashboardNotifier의 모든 컴파일 에러를 해결하였습니다.

주요 변경사항:
- userId 기반의 데이터 조회 구조로 개선
- Import 충돌 해결을 위한 namespace 활용
- onboarding/tracking 양쪽 feature의 엔티티를 올바르게 사용
- Value Object의 올바른 접근 방식 적용

파일은 이제 에러 없이 컴파일되며, CLAUDE.md의 모든 아키텍처 규칙을 준수합니다.

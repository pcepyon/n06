# UF-013: 주간 기록 목표 조정 - Plan 검증 결과

## 검증 일시
2025-11-07

## 검증 결과: ❌ 수정 필요

---

## 1. 누락된 구현 사항

### 1.1. UserProfile Entity 필드 누락
**문제점:**
- Plan에서 UserProfile Entity의 기존 필드 구조를 명시하지 않음
- `weeklyWeightRecordGoal`, `weeklySymptomRecordGoal` 필드가 신규 추가인지 기존 필드인지 불명확

**spec 요구사항:**
- user_profiles 테이블에 weekly_weight_record_goal, weekly_symptom_record_goal 필드 존재
- 기본값: 각각 7회/주

**수정 방안:**
```dart
// lib/features/profile/domain/entities/user_profile.dart
class UserProfile {
  final String id;
  final String userId;
  final int weeklyWeightRecordGoal;  // 추가 필드
  final int weeklySymptomRecordGoal; // 추가 필드
  final DateTime createdAt;
  final DateTime updatedAt;

  // 검증 로직
  UserProfile({
    required this.weeklyWeightRecordGoal,
    required this.weeklySymptomRecordGoal,
  }) {
    if (weeklyWeightRecordGoal < 0 || weeklyWeightRecordGoal > 7) {
      throw ArgumentError('주간 체중 기록 목표는 0~7 범위여야 합니다');
    }
    if (weeklySymptomRecordGoal < 0 || weeklySymptomRecordGoal > 7) {
      throw ArgumentError('주간 부작용 기록 목표는 0~7 범위여야 합니다');
    }
  }
}
```

**Plan 수정 필요:**
- Section 3.1에 기존 UserProfile Entity 구조 명시
- 신규 필드 추가 여부 명확화

---

### 1.2. DashboardNotifier 연동 로직 누락
**문제점:**
- Plan에서 "DashboardNotifier invalidation 트리거"만 언급
- HOW (어떤 메서드를 호출하여 진행도를 재계산하는지) 명시 안 됨

**spec 요구사항 (Main Scenario Step 12-13):**
```
12. 시스템이 DashboardNotifier에 변경 이벤트를 전달
13. 시스템이 홈 대시보드 주간 목표 진행도를 재계산
    - 변경된 목표 기준으로 달성률(%) 재계산
    - 현재 주간 기록 건수는 유지
```

**수정 방안:**
```dart
// ProfileNotifier.updateWeeklyGoals() 내부
Future<void> updateWeeklyGoals(int weightGoal, int symptomGoal) async {
  state = const AsyncValue.loading();

  try {
    await _repository.updateWeeklyGoals(_userId, weightGoal, symptomGoal);

    // DashboardNotifier 재계산 트리거
    ref.invalidate(dashboardNotifierProvider);
    // 또는
    ref.read(dashboardNotifierProvider.notifier).recalculateWeeklyProgress();

    state = AsyncValue.data(updatedProfile);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}
```

**Plan 수정 필요:**
- Section 3.5에 DashboardNotifier 재계산 메서드 호출 명시
- DashboardNotifier.recalculateWeeklyProgress() 메서드 존재 여부 확인 필요

---

### 1.3. 설정 화면 Navigation 구조 누락
**문제점:**
- Plan에서 WeeklyGoalSettingsScreen으로 진입하는 경로 미명시
- Settings 메인 화면 구조 및 라우팅 로직 없음

**spec 요구사항 (Main Scenario Step 1-3):**
```
1. 사용자가 홈 대시보드 또는 다른 화면에서 설정 아이콘/메뉴를 터치
2. 시스템이 설정 화면을 표시
3. 사용자가 "주간 기록 목표 조정" 메뉴를 선택
```

**수정 방안:**
- Settings 메인 화면 추가 (SettingsScreen)
- Navigator.push 라우팅 구현

**Plan 수정 필요:**
- Section 3.6 이전에 "3.6-1. SettingsScreen" 추가
- WeeklyGoalSettingsScreen 진입 라우팅 명시

---

### 1.4. Edge Case 처리 로직 누락

#### 1.4.1. 목표 0 입력 시 확인 다이얼로그
**spec 요구사항:**
```
- 목표 값 0 입력: 경고 메시지 "목표를 0으로 설정하시겠습니까?" 표시하되 허용
```

**Plan 현재 상태:**
- Section 3.1 테스트에서 "주간 목표 0 허용 (경고용)" 언급만 있음
- 실제 UI 구현 없음

**수정 방안:**
```dart
// WeeklyGoalSettingsScreen._onSave()
if (weightGoal == 0 || symptomGoal == 0) {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('목표 0 설정'),
      content: Text('목표를 0으로 설정하시겠습니까?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('확인')),
      ],
    ),
  );
  if (confirm != true) return;
}
```

**Plan 수정 필요:**
- Section 3.6에 "0 입력 시 확인 다이얼로그" 구현 단계 추가

---

#### 1.4.2. 네트워크 오류 재시도 옵션
**spec 요구사항:**
```
- 네트워크/DB 오류: 에러 메시지 표시 후 재시도 옵션 제공
```

**Plan 현재 상태:**
- QA Sheet에 "에러 메시지 및 재시도 옵션 표시" 언급만 있음
- 구현 방법 미명시

**수정 방안:**
```dart
// WeeklyGoalSettingsScreen
AsyncValue.error(:final error) => Center(
  child: Column(
    children: [
      Text('저장 중 오류가 발생했습니다'),
      ElevatedButton(
        onPressed: () => ref.read(profileNotifierProvider.notifier)
          .updateWeeklyGoals(weightGoal, symptomGoal),
        child: Text('재시도'),
      ),
    ],
  ),
),
```

**Plan 수정 필요:**
- Section 3.6 Implementation Order에 "에러 상태 재시도 버튼 구현" 추가

---

#### 1.4.3. 달성률 100% 초과 처리
**spec 요구사항:**
```
- 목표 감소로 달성률 100% 초과 시: 100%로 표시하되 실제 기록 건수는 유지
```

**Plan 현재 상태:**
- 완전 누락

**수정 방안:**
```dart
// DashboardNotifier 또는 별도 유틸리티 함수
double calculateAchievementRate(int actualCount, int goalCount) {
  if (goalCount == 0) return 0.0;
  final rate = (actualCount / goalCount) * 100;
  return rate > 100 ? 100.0 : rate; // 100% 상한선
}
```

**Plan 수정 필요:**
- Section 3.5 또는 별도 Section에 "달성률 계산 로직" 추가
- Business Rule BR-2 구현 명시

---

### 1.5. Business Rules 구현 누락

#### 1.5.1. BR-3: 주간 집계 기준
**spec 요구사항:**
```
BR-3: 주간 집계 기준
- 주간 기준: 월요일 00:00 ~ 일요일 23:59
- 기록 건수 계산: log_date 기준 (created_at 아님)
- 중복 날짜 기록: 1건으로 계산
```

**Plan 현재 상태:**
- 완전 누락

**수정 방안:**
```dart
// DashboardNotifier.calculateWeeklyRecordCount()
int calculateWeeklyRecordCount(List<WeightLog> logs) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1)); // 월요일 00:00
  final weekEnd = weekStart.add(Duration(days: 6, hours: 23, minutes: 59)); // 일요일 23:59

  final uniqueDates = logs
    .where((log) => log.logDate.isAfter(weekStart) && log.logDate.isBefore(weekEnd))
    .map((log) => log.logDate.toIso8601String().substring(0, 10)) // YYYY-MM-DD만 추출
    .toSet();

  return uniqueDates.length; // 중복 날짜 제거
}
```

**Plan 수정 필요:**
- Section 3.5 또는 별도 Section에 "주간 집계 로직" 추가

---

#### 1.5.2. BR-4: 투여 목표는 수정 불가
**spec 요구사항:**
```
BR-4: 데이터 동기화
- 투여 목표는 dosage_plans 스케줄 기반으로 자동 계산 (수정 불가)
```

**Plan 현재 상태:**
- 완전 누락

**수정 방안:**
- WeeklyGoalSettingsScreen에서 투여 목표 입력 필드 제외
- 체중 기록 목표, 부작용 기록 목표만 수정 가능하도록 UI 구성

**Plan 수정 필요:**
- Section 3.6에 "투여 목표는 표시 전용(read-only)" 명시
- QA Sheet에 "투여 목표 수정 불가 확인" 항목 추가

---

## 2. 설계 일관성 문제

### 2.1. Sequence Diagram vs Implementation Plan 불일치
**문제점:**
- Spec의 Sequence Diagram은 FE-BE 분리 구조
- Plan은 Flutter Isar 로컬 DB 구조
- "BE → Database: SELECT" 단계가 Plan의 "IsarProfileRepository" 단계와 매핑 불명확

**수정 방안:**
- Plan의 Architecture Diagram을 Sequence Diagram과 일치시키기
- 또는 Sequence Diagram을 Flutter 로컬 앱 구조로 수정

**Plan 수정 필요:**
- Section 2 Architecture Diagram에 Sequence Diagram 단계 매핑 추가

---

### 2.2. Test Strategy 불일치
**문제점:**
- Section 3.4 IsarProfileRepository: "Integration Test (Isar Test Instance)"
- Section 4 TDD Workflow Phase 2: "Refactor: 에러 핸들링 강화"
- Integration Test에서 Refactor 단계가 어떻게 작동하는지 불명확 (TDD는 보통 Unit Test 기반)

**수정 방안:**
- IsarProfileRepository는 "Integration Test"지만 TDD Cycle (Red-Green-Refactor) 적용
- Isar Test Instance를 사용한 Integration Test도 TDD 가능함을 명시

**Plan 수정 필요:**
- Section 3.4에 "Integration Test with TDD Cycle" 명시

---

## 3. 구현 순서 개선 제안

### 3.1. Phase 4 Manual QA 시점 문제
**문제점:**
- Phase 4에서 "Manual QA 수행 (QA Sheet 기반)" 후 "UI 개선"
- QA 전에 기본 UI가 동작해야 하는데, QA Sheet가 너무 늦게 실행됨

**수정 방안:**
```
Phase 4: Presentation Layer
1. WeeklyGoalInputWidget 구현
2. WeeklyGoalSettingsScreen 기본 구조 구현
3. **Smoke Test** (화면 렌더링 확인)
4. ProfileNotifier 연동
5. **Manual QA 수행** (QA Sheet 기반)
6. Edge Case 처리 (0 입력 확인 다이얼로그 등)
7. UI/UX 최적화
```

**Plan 수정 필요:**
- Section 3.6 Implementation Order 재정렬

---

### 3.2. DashboardNotifier 재계산 시점
**문제점:**
- Plan에서 ProfileNotifier가 목표 업데이트 후 DashboardNotifier를 invalidate
- 하지만 DashboardNotifier의 재계산 로직이 어디에 구현되는지 불명확

**수정 방안:**
- DashboardNotifier에 `recalculateWeeklyProgress()` 메서드 추가
- 또는 `ref.invalidate(dashboardNotifierProvider)` 시 자동 재계산되도록 설계

**Plan 수정 필요:**
- Section 3.5에 DashboardNotifier 재계산 메서드 명시
- 또는 Section 3.8에 "DashboardNotifier 수정사항" 추가

---

## 4. 완료 기준 누락 항목

현재 완료 기준에 누락된 항목:
- [ ] BR-3 주간 집계 로직 구현 및 테스트 통과
- [ ] BR-4 투여 목표 수정 불가 UI 확인
- [ ] 목표 0 입력 시 확인 다이얼로그 동작 확인
- [ ] 네트워크 오류 재시도 옵션 동작 확인
- [ ] 달성률 100% 초과 시 상한선 처리 확인
- [ ] Settings 메인 화면에서 WeeklyGoalSettingsScreen 진입 확인

**Plan 수정 필요:**
- Section 6 완료 기준에 위 항목 추가

---

## 5. 권장 수정사항 요약

### 우선순위 High (즉시 수정 필요)
1. **Section 3.1**: UserProfile Entity 기존 필드 구조 명시
2. **Section 3.5**: DashboardNotifier 재계산 메서드 호출 로직 추가
3. **Section 3.6**: 목표 0 입력 시 확인 다이얼로그 구현 단계 추가
4. **Section 3.6**: 네트워크 오류 재시도 옵션 구현 단계 추가
5. **Section 6**: 누락된 완료 기준 항목 추가

### 우선순위 Medium (설계 개선)
6. **Section 3.5 또는 신규 Section**: BR-3 주간 집계 로직 구현 추가
7. **Section 3.5 또는 신규 Section**: 달성률 계산 로직 (BR-2) 구현 추가
8. **Section 3.6 이전**: SettingsScreen 추가 및 라우팅 구조 명시

### 우선순위 Low (문서 일관성)
9. **Section 2**: Architecture Diagram과 Sequence Diagram 매핑 추가
10. **Section 3.4**: "Integration Test with TDD Cycle" 명시

---

## 6. 다음 단계

1. 본 plancheck.md를 기반으로 plan.md 수정
2. 수정된 plan.md로 TDD 구현 시작
3. 구현 중 추가 발견된 이슈는 plancheck.md에 업데이트

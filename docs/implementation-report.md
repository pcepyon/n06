# GLP-1 MVP 구현 현황 및 개발 필요 항목 보고서

**작성일**: 2025-11-14
**대상**: AI Implementation Agent

---

## 1. 현재 구현 상태 요약

### 1.1 구현 완료된 기능 (11/15)

| 기능 번호 | 기능명 | 화면 | 라우트 | 상태 |
|----------|--------|------|--------|------|
| 001 | 소셜 로그인 | LoginScreen | `/login` | ✅ 완료 |
| 002 | 온보딩 | OnboardingScreen | `/onboarding` | ✅ 완료 |
| 004 | 체중/부작용 기록 | WeightRecordScreen, SymptomRecordScreen | `/tracking/weight`, `/tracking/symptom` | ✅ 완료 |
| 005 | 데이터 공유 | DataSharingScreen | `/data-sharing` | ⚠️ 화면 구현됨, 접근 경로 미흡 |
| 006 | 대처 가이드 | CopingGuideScreen | `/coping-guide` | ⚠️ 화면 구현됨, 접근 경로 없음 |
| 007 | 증상 체크 | EmergencyCheckScreen | `/emergency/check` | ⚠️ 화면 구현됨, 접근 경로 없음 |
| 008 | 홈 대시보드 | HomeDashboardScreen | `/home` | ⚠️ 구현됨, 설정 아이콘 누락 |
| 009 | 설정 | SettingsScreen | `/settings` | ✅ 완료 |
| 010 | 로그아웃 | LogoutConfirmDialog | 설정 내부 | ✅ 완료 |
| 011 | 프로필 수정 | ProfileEditScreen | `/profile/edit` | ✅ 완료 |
| 012 | 투여 계획 수정 | EditDosagePlanScreen | `/dose-plan/edit` | ✅ 완료 |
| 014 | 알림 설정 | NotificationSettingsScreen | `/notification/settings` | ✅ 완료 |
| 015 | 주간 목표 조정 | WeeklyGoalSettingsScreen | `/weekly-goal/edit` | ✅ 완료 |

### 1.2 미구현 기능 (2/15)

| 기능 번호 | 기능명 | 상태 |
|----------|--------|------|
| 003 | 투여 스케줄 관리 | ❌ 화면 자체 미구현 |
| 013 | 과거 기록 수정/삭제 | ❌ 화면 자체 미구현 |

---

## 2. 개발 필요 항목 (우선순위별)

### 2.1 우선순위 1: 긴급 (UI 접근성 개선)

#### Task 1-1: 홈 대시보드에 설정 아이콘 추가

**파일**: `/lib/features/dashboard/presentation/screens/home_dashboard_screen.dart`

**수정 위치**: 라인 20-23

**현재 코드**:
```dart
appBar: AppBar(
  title: const Text('홈 대시보드'),
  elevation: 0,
),
```

**수정 코드**:
```dart
appBar: AppBar(
  title: const Text('홈 대시보드'),
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => context.push('/settings'),
    ),
  ],
),
```

**필요 import**:
```dart
import 'package:go_router/go_router.dart';
```

---

#### Task 1-2: 주간 리포트 위젯에 데이터 공유 화면 연결

**파일**: `/lib/features/dashboard/presentation/widgets/weekly_report_widget.dart`

**수정 위치**: 라인 17-22

**현재 코드**:
```dart
return Card(
  elevation: 0,
  color: Colors.purple[50],
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
```

**수정 코드**:
```dart
return Card(
  elevation: 0,
  color: Colors.purple[50],
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: InkWell(
    onTap: () {
      // docs/005 spec: 주간 리포트 클릭 시 데이터 공유 화면으로 이동
      context.push('/data-sharing');
    },
    child: Padding(
```

**필요 import**:
```dart
import 'package:go_router/go_router.dart';
```

**수정 대상**: 기존 `child: Padding(` 부분을 `child: InkWell(...` 로 감싸기

---

### 2.2 우선순위 2: 높음 (핵심 기능 구현)

#### Task 2-1: 투여 스케줄 관리 화면 구현 (003)

**참조 문서**: `/docs/003/spec.md`, `/docs/003/plan.md`

**구현 필요 화면**:

1. **DoseScheduleScreen** - 투여 스케줄러 메인 화면
   - 경로: `/lib/features/dose_schedule/presentation/screens/dose_schedule_screen.dart`
   - 기능: 캘린더/리스트 뷰로 투여 예정일 표시
   - 라우트: `/dose-schedule`

2. **DoseRecordScreen** - 투여 완료 기록 화면
   - 경로: `/lib/features/dose_schedule/presentation/screens/dose_record_screen.dart`
   - 기능: 투여 완료 기록 (부위 선택, 메모)
   - 라우트: `/dose-schedule/record`

3. **InjectionSiteSelectWidget** - 부위 선택 위젯
   - 경로: `/lib/features/dose_schedule/presentation/widgets/injection_site_select_widget.dart`
   - 기능: 복부/허벅지/상완 선택, 7일 재사용 경고

**라우터 수정**:
- 파일: `/lib/core/routing/app_router.dart`
- 추가 위치: 라인 141 (마지막 라우트 다음)

```dart
/// Dose Schedule Management (003)
GoRoute(
  path: '/dose-schedule',
  name: 'dose_schedule',
  builder: (context, state) => const DoseScheduleScreen(),
),
GoRoute(
  path: '/dose-schedule/record',
  name: 'dose_record',
  builder: (context, state) => const DoseRecordScreen(),
),
```

**QuickActionWidget 수정**:
- 파일: `/lib/features/dashboard/presentation/widgets/quick_action_widget.dart`
- 수정 위치: 라인 36-41

```dart
onTap: () => context.push('/dose-schedule'),
```

**필요한 Domain/Application Layer**:
- Entity: `DoseSchedule`, `DoseRecord`, `InjectionSite`
- Repository: `DoseScheduleRepository` (interface in domain, implementation in infrastructure)
- Notifier: `DoseScheduleNotifier`
- Provider: `doseScheduleNotifierProvider`

**아키텍처 준수사항**:
- Clean Architecture 계층 분리 엄수
- Repository Pattern 사용 (Phase 1 전환 대비)
- TDD 방식 개발 (`docs/tdd.md` 참조)

---

#### Task 2-2: 과거 기록 수정/삭제 화면 구현 (013)

**참조 문서**: `/docs/013/spec.md`

**구현 필요 화면**:

1. **RecordListScreen** - 기록 목록 화면
   - 경로: `/lib/features/record_management/presentation/screens/record_list_screen.dart`
   - 기능: 체중/부작용/투여 기록 목록 표시
   - 라우트: `/records`

2. **RecordEditScreen** - 기록 수정 화면
   - 경로: `/lib/features/record_management/presentation/screens/record_edit_screen.dart`
   - 기능: 기록 수정/삭제 (확인 대화상자 포함)
   - 라우트: `/records/edit`

**라우터 수정**:
- 파일: `/lib/core/routing/app_router.dart`

```dart
/// Record Management (013)
GoRoute(
  path: '/records',
  name: 'record_list',
  builder: (context, state) => const RecordListScreen(),
),
GoRoute(
  path: '/records/edit',
  name: 'record_edit',
  builder: (context, state) {
    final recordData = state.extra as Map<String, dynamic>;
    return RecordEditScreen(recordData: recordData);
  },
),
```

**접근 경로 추가**:

옵션 A: 대시보드에 "기록 관리" 버튼 추가
- 파일: `/lib/features/dashboard/presentation/screens/home_dashboard_screen.dart`
- 위치: QuickActionWidget 아래

옵션 B: 설정 메뉴에 추가
- 파일: `/lib/features/settings/presentation/screens/settings_screen.dart`
- 위치: 라인 140 (알림 설정 아래)

```dart
SettingsMenuItem(
  title: '기록 관리',
  subtitle: '저장된 기록을 수정하거나 삭제할 수 있습니다',
  onTap: () => context.push('/records'),
),
```

---

### 2.3 우선순위 3: 중간 (UX 개선)

#### Task 3-1: 대처 가이드 접근 경로 추가

**현재 상태**: 화면은 구현되었으나 접근 방법 없음

**옵션 A (권장)**: 부작용 기록 후 자동 표시

**참조**: `docs/006/spec.md` - "부작용 기록 후 자동으로 간단 버전 표시"

**수정 파일**: `/lib/features/tracking/presentation/screens/symptom_record_screen.dart`

**구현 내용**:
```dart
// 부작용 저장 성공 후
await notifier.saveSymptom(symptomData);

if (!mounted) return;

// 대처 가이드 자동 표시
await showDialog(
  context: context,
  builder: (context) => CopingGuideDialog(
    symptomType: selectedSymptom,
  ),
);
```

**옵션 B**: 대시보드에 "가이드" 탭/버튼 추가

---

#### Task 3-2: 증상 체크 접근 경로 추가

**현재 상태**: 화면은 구현되었으나 접근 방법 없음

**옵션 A (권장)**: 부작용 기록에서 심각도 7-10점 선택 시 자동 연결

**참조**: `docs/007/spec.md` - "심각도 7-10점 + 24시간 지속 선택 시 진입"

**수정 파일**: `/lib/features/tracking/presentation/screens/symptom_record_screen.dart`

**구현 내용**:
```dart
// 심각도 7-10 + 24시간 지속 선택 시
if (severity >= 7 && isDurationOver24Hours) {
  final shouldCheck = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('긴급 증상 체크'),
      content: const Text('심각한 증상이 지속되고 있습니다. 긴급 증상 체크를 진행하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('확인하기'),
        ),
      ],
    ),
  );

  if (shouldCheck == true && mounted) {
    context.push('/emergency/check');
  }
}
```

**옵션 B**: 대시보드 퀵 액션에 버튼 추가

---

### 2.4 우선순위 4: 낮음 (향후 개선)

#### Task 4-1: 하단 네비게이션 바 추가

**목적**: 주요 화면 간 빠른 이동

**구현 위치**: `/lib/core/routing/app_router.dart` 또는 별도 Scaffold wrapper

**구성**:
- 홈 (대시보드)
- 기록 (투여/체중/부작용)
- 가이드
- 설정

---

## 3. 구현 시 준수사항

### 3.1 아키텍처 규칙 (필수)

```
Presentation → Application → Domain ← Infrastructure
```

**절대 금지**:
- ❌ Application/Presentation에서 Isar 직접 접근
- ❌ Domain에서 Flutter import
- ❌ Repository Interface 없이 구현체만 작성
- ❌ 테스트 없이 코드 작성 (TDD 위반)

**필수 준수**:
- ✅ Repository Pattern 사용 (Domain에 interface, Infrastructure에 implementation)
- ✅ Test 먼저 작성 후 구현 (`docs/tdd.md` 참조)
- ✅ 계층별 파일 위치 준수 (`docs/code_structure.md` 참조)
- ✅ Riverpod AsyncNotifier 사용 (`docs/state-management.md` 참조)

### 3.2 파일 위치 규칙

```
features/{feature}/
  domain/
    entities/          # 비즈니스 엔티티
    repositories/      # Repository 인터페이스
  application/
    notifiers/         # Riverpod Notifier
  presentation/
    screens/           # 화면
    widgets/           # 위젯
  infrastructure/
    repositories/      # Repository 구현체
    dtos/              # DTO (Isar/Supabase 변환)
```

### 3.3 네이밍 규칙

- Entity: `DoseRecord` (domain/entities/)
- DTO: `DoseRecordDto` (infrastructure/dtos/)
- Repository Interface: `DoseScheduleRepository` (domain/repositories/)
- Repository Impl: `IsarDoseScheduleRepository` (infrastructure/repositories/)
- Notifier: `DoseScheduleNotifier` (application/notifiers/)
- Provider: `doseScheduleNotifierProvider`

### 3.4 에러 처리

**autoDispose + async 작업 주의**:
```dart
// ❌ 잘못된 예
await notifier.save(data);
await showDialog(...); // Provider 조기 해제 가능

// ✅ 올바른 예
await notifier.save(data);
if (!mounted) return;
await showDialog(...);
```

**Notifier state 접근**:
```dart
// ❌ 잘못된 예
return state.asData!.value; // null 위험

// ✅ 올바른 예
final prev = state.asData?.value ?? defaultState;
return prev;
```

**userId 처리**:
```dart
// ❌ 잘못된 예
const userId = 'current-user-id';

// ✅ 올바른 예
final userId = ref.read(authNotifierProvider).value?.id ?? '';
if (userId.isEmpty) throw Exception('User not authenticated');
```

---

## 4. 구현 순서 권장

### Phase 1: UI 접근성 개선 (1-2시간)
1. Task 1-1: 대시보드 설정 아이콘 추가
2. Task 1-2: 주간 리포트 클릭 연결

### Phase 2: 투여 스케줄 관리 (1-2일)
3. Task 2-1: 003 기능 완전 구현 (TDD)
   - Domain Layer 먼저
   - Infrastructure Layer
   - Application Layer
   - Presentation Layer

### Phase 3: 기록 관리 (1일)
4. Task 2-2: 013 기능 구현 (TDD)

### Phase 4: UX 개선 (0.5일)
5. Task 3-1: 대처 가이드 연결
6. Task 3-2: 증상 체크 연결

---

## 5. 테스트 체크리스트

각 구현 완료 후 확인:

```bash
# 테스트 실행
flutter test

# 정적 분석
flutter analyze

# 빌드 확인
flutter build apk --debug
```

**TDD 사이클 준수**:
1. ❌ Red: 실패하는 테스트 작성
2. ✅ Green: 최소한의 코드로 테스트 통과
3. 🔄 Refactor: 코드 개선

---

## 6. 참고 문서

- 전체 아키텍처: `/docs/code_structure.md`
- 상태 관리: `/docs/state-management.md`
- TDD 가이드: `/docs/tdd.md`
- 데이터베이스: `/docs/database.md`
- 기술 스택: `/docs/techstack.md`
- 개발 오케스트레이션: `/CLAUDE.md`

---

## 7. 긴급 문의 시

**의사결정 트리**:
- 아키텍처 질문 → `docs/code_structure.md`
- 상태 관리 질문 → `docs/state-management.md`
- 비즈니스 로직 질문 → `docs/requirements.md` 또는 각 기능 `spec.md`
- 데이터 모델 질문 → `docs/database.md`
- 테스트 질문 → `docs/tdd.md`

**작업 전 필수 확인**:
```
[ ] Repository Pattern 사용?
[ ] Layer 의존성 올바른가?
[ ] Test 먼저 작성했는가?
[ ] autoDispose + mounted 체크 했는가?
[ ] userId 하드코딩 없는가?
```

---

**보고서 종료**

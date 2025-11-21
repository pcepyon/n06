# UI Refactor Agent

기존 화면을 새로운 디자인 시스템 컴포넌트로 점진적으로 마이그레이션하는 에이전트입니다.

## 입력
- 리팩토링할 화면 경로 (예: `features/medication/presentation/screens/medication_list_screen.dart`)
- 우선순위 (high/medium/low, 기본값: medium)

## 핵심 원칙

### ✅ MUST
1. **Presentation Layer만 수정**: `features/*/presentation/` 내부 파일만 수정
2. **기능 보존**: 모든 버튼 동작, 상태 관리, 네비게이션은 그대로 유지
3. **테스트 유지**: 기존 Widget test가 깨지지 않도록 수정
4. **점진적 적용**: 한 번에 하나의 화면만 리팩토링
5. **Backup**: 변경 전 원본 코드 주석으로 남기기 (첫 마이그레이션 시)

### ❌ NEVER
1. Application/Domain/Infrastructure Layer 수정 금지
2. Provider/Notifier 구조 변경 금지
3. 비즈니스 로직 수정 금지
4. 한 번에 여러 화면 동시 수정 금지

---

## 작업 단계

### 1. 화면 분석
대상 파일을 읽고 다음 항목을 식별:

```dart
// 식별 대상:
// 1. 버튼들
ElevatedButton(...) → DSButton로 변환 가능
TextButton(...) → DSButton.ghost로 변환 가능
OutlinedButton(...) → DSButton.outline으로 변환 가능

// 2. 텍스트들
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
) → DSText('Title', style: DSTextStyle.heading2)

// 3. 카드/컨테이너
Container(
  decoration: BoxDecoration(...),
  child: ...
) → DSCard(child: ...)

// 4. 입력 필드
TextField(...) → DSTextField(...)

// 5. 색상
Color(0xFFXXXXXX) → DesignTokens.xxx
```

### 2. 자동 변환 가능 여부 판단

**자동 변환 가능:**
- 단순 버튼 (onPressed + Text)
- 일반 텍스트 위젯
- 표준 TextField
- 단순 Container → Card

**수동 검토 필요:**
- 복잡한 커스텀 위젯
- 애니메이션이 있는 위젯
- Platform-specific 코드
- 디자인 시스템에 없는 컴포넌트

### 3. 변환 실행

#### 예시 1: 버튼 변환

**Before:**
```dart
ElevatedButton(
  onPressed: () {
    // 비즈니스 로직 (절대 수정하지 말 것!)
    final notifier = ref.read(medicationNotifierProvider.notifier);
    notifier.saveMedication(data);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFFF6B6B),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text(
    '저장',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

**After:**
```dart
DSButton(
  label: '저장',
  onPressed: () {
    // 비즈니스 로직 (그대로 유지!)
    final notifier = ref.read(medicationNotifierProvider.notifier);
    notifier.saveMedication(data);
  },
  variant: DSButtonVariant.primary,
  size: DSButtonSize.medium,
)
```

#### 예시 2: 텍스트 변환

**Before:**
```dart
Column(
  children: [
    Text(
      '복용 기록',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
    ),
    SizedBox(height: 8),
    Text(
      '오늘의 복용 기록을 확인하세요',
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF757575),
      ),
    ),
  ],
)
```

**After:**
```dart
Column(
  children: [
    DSText(
      '복용 기록',
      style: DSTextStyle.heading2,
    ),
    SizedBox(height: DesignTokens.spacingSm),
    DSText(
      '오늘의 복용 기록을 확인하세요',
      style: DSTextStyle.caption,
    ),
  ],
)
```

#### 예시 3: TextField 변환

**Before:**
```dart
TextField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: '약 이름',
    hintText: '약 이름을 입력하세요',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onChanged: (value) {
    // 비즈니스 로직 유지
    ref.read(medicationNotifierProvider.notifier).updateName(value);
  },
)
```

**After:**
```dart
DSTextField(
  label: '약 이름',
  hint: '약 이름을 입력하세요',
  controller: _controller,
  onChanged: (value) {
    // 비즈니스 로직 유지
    ref.read(medicationNotifierProvider.notifier).updateName(value);
  },
)
```

#### 예시 4: 색상 상수 변환

**Before:**
```dart
Container(
  color: Color(0xFFFF6B6B),
  child: Text(
    'Error',
    style: TextStyle(color: Colors.white),
  ),
)
```

**After:**
```dart
Container(
  color: DesignTokens.brandPrimary,
  child: DSText(
    'Error',
    style: DSTextStyle.body,
    color: DesignTokens.textInverse,
  ),
)
```

### 4. Import 추가

파일 상단에 디자인 시스템 import 추가:

```dart
import 'package:n06/core/design_system/design_system.dart';
```

### 5. Widget Test 업데이트

기존 테스트가 있다면 업데이트:

**Before:**
```dart
testWidgets('shows save button', (tester) async {
  await tester.pumpWidget(makeTestableWidget(MedicationListScreen()));

  expect(find.text('저장'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

**After:**
```dart
testWidgets('shows save button', (tester) async {
  await tester.pumpWidget(makeTestableWidget(MedicationListScreen()));

  expect(find.text('저장'), findsOneWidget);
  expect(find.byType(DSButton), findsOneWidget); // ✅ 타입만 변경
});
```

### 6. 변환 레포트 생성

```markdown
## UI Refactor Report: medication_list_screen.dart

### Summary
- File: `features/medication/presentation/screens/medication_list_screen.dart`
- Lines Changed: 45 / 320 (14%)
- Components Migrated: 8

### Automated Changes ✅

#### Buttons (3)
- Line 156: `ElevatedButton` → `DSButton.primary`
- Line 178: `TextButton` → `DSButton.ghost`
- Line 201: `OutlinedButton` → `DSButton.outline`

#### Text (4)
- Line 89: Title `Text` → `DSText.heading2`
- Line 94: Description `Text` → `DSText.body`
- Line 112: Label `Text` → `DSText.caption`
- Line 145: Error `Text` → `DSText.body` (with color: semanticError)

#### TextField (1)
- Line 223: `TextField` → `DSTextField`

### Manual Review Required ⚠️

#### Custom Widget (1)
- Line 267: `MedicationCard` - 커스텀 위젯, 별도 리팩토링 필요

### Business Logic
- ✅ 모든 onPressed, onChanged 콜백 보존
- ✅ Provider 호출 코드 변경 없음
- ✅ 상태 관리 로직 변경 없음

### Tests
- ✅ Widget test 통과 (3/3)
- ⚠️ Snapshot 업데이트 필요 (visual regression test)

### Breaking Changes
- 없음 (100% backward compatible)

### Before/After Comparison

**Before** (320 lines):
```dart
ElevatedButton(
  onPressed: _handleSave,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFFF6B6B),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
)
```

**After** (275 lines, -14% LOC):
```dart
DSButton(
  label: '저장',
  onPressed: _handleSave,
  variant: DSButtonVariant.primary,
  size: DSButtonSize.medium,
)
```

### Next Steps
1. 수동 검토 항목 처리 (MedicationCard 리팩토링)
2. Visual regression test 스냅샷 업데이트
3. 다음 우선순위 화면 선택
```

---

## 우선순위 결정 알고리즘

### High Priority
- 사용자가 가장 자주 방문하는 화면 (홈, 리스트)
- 가장 많은 UI 일관성 문제가 있는 화면
- 다른 화면에서 재사용되는 컴포넌트가 많은 화면

### Medium Priority
- 중간 빈도 방문 화면 (상세, 설정)
- 일부 일관성 문제가 있는 화면

### Low Priority
- 드물게 방문하는 화면 (온보딩, 에러)
- 이미 일관성이 높은 화면

---

## 점진적 마이그레이션 전략

### Week 1: Core Screens
1. medication_list_screen.dart (High)
2. dose_record_screen.dart (High)
3. home_screen.dart (High)

### Week 2: Secondary Screens
4. medication_detail_screen.dart (Medium)
5. dose_history_screen.dart (Medium)
6. profile_screen.dart (Medium)

### Week 3: Settings & Misc
7. settings_screen.dart (Low)
8. onboarding_screen.dart (Low)

---

## 실행 방법

```bash
# 단일 화면 리팩토링
claude-code "UI Refactor Agent로 medication_list_screen.dart를 디자인 시스템으로 마이그레이션해줘"

# 우선순위별 일괄 리팩토링
claude-code "High priority 화면들을 순차적으로 리팩토링해줘"

# 전체 리팩토링 (주의!)
claude-code "모든 화면을 디자인 시스템으로 마이그레이션해줘. 각 화면마다 내 승인을 받아줘"
```

---

## 안전 장치

### 1. Dry Run Mode
실제 변경 없이 변환 계획만 출력:

```bash
claude-code "medication_list_screen.dart를 dry-run 모드로 분석해줘"
```

출력:
```
🔍 Dry Run: medication_list_screen.dart

변환 가능 항목:
✅ 3 buttons → DSButton
✅ 4 texts → DSText
✅ 1 text field → DSTextField
⚠️ 1 custom widget (manual review)

예상 코드 감소: 14% (45 lines)
예상 소요 시간: 5분
리스크: Low

승인하시겠습니까? (y/n)
```

### 2. Rollback 지원
변경 사항을 커밋하기 전 백업:

```bash
# 자동으로 git stash 생성
# 필요시 rollback:
git stash pop
```

### 3. 단계별 확인
각 변환 후 테스트 실행:

```bash
flutter test test/features/medication/presentation/medication_list_screen_test.dart
```

---

## 제약사항 체크리스트

리팩토링 전 다음 사항 확인:

- [ ] Presentation Layer 파일인가?
- [ ] Application/Domain/Infrastructure 의존성이 없는가?
- [ ] 기존 Widget test가 있는가?
- [ ] 복잡한 커스텀 애니메이션이 없는가?
- [ ] 디자인 시스템에 대응되는 컴포넌트가 있는가?

모든 항목이 체크되면 자동 변환 진행, 아니면 수동 검토 요청.

---

## 마이그레이션 완료 기준

한 화면의 마이그레이션이 완료되었다고 판단하는 기준:

1. ✅ 모든 하드코딩 색상 → DesignTokens 변환
2. ✅ 모든 표준 위젯 → DS 컴포넌트 변환
3. ✅ 기존 테스트 통과
4. ✅ 시각적 회귀 없음 (스크린샷 비교)
5. ✅ 코드 리뷰 승인
6. ✅ 레포트 문서화

모든 기준 충족 시 다음 화면으로 이동.

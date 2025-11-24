# ProfileEditScreen 구현 가이드

## Phase 2B: 상세 구현 사양서

**작성일**: 2025-11-24
**버전**: 1.0
**대상 파일**:
- lib/features/profile/presentation/screens/profile_edit_screen.dart
- lib/features/profile/presentation/widgets/profile_edit_form.dart

---

## 변경사항 상세 사양

### 변경 1: AppBar 스타일 Design System 적용

**파일**: `profile_edit_screen.dart`
**대상 코드 위치**: Line 24-27

**변경 전**:
```dart
appBar: AppBar(
  title: const Text('프로필 및 목표 수정'),
  elevation: 0,
),
```

**변경 후**:
```dart
appBar: AppBar(
  title: const Text('프로필 및 목표 수정'),
  backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  toolbarHeight: 56,
  titleTextStyle: const TextStyle(
    color: Color(0xFF1E293B), // Neutral-800
    fontSize: 20,
    fontWeight: FontWeight.w600, // Semibold
    fontFamily: 'Pretendard',
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(
      color: const Color(0xFFE2E8F0), // Neutral-200
      height: 1,
    ),
  ),
),
```

**Design System 토큰**:
- 배경: `#F8FAFC` (Neutral-50)
- 텍스트: `#1E293B` (Neutral-800)
- 타이포: 20px, w600 (Semibold)
- 높이: 56px
- 테두리: 1px solid `#E2E8F0` (Neutral-200)

---

### 변경 2: Body 배경색 명시화

**파일**: `profile_edit_screen.dart`
**대상 코드 위치**: Line 23 (Scaffold 직후)

**변경 전**:
```dart
Scaffold(
  appBar: ...,
  body: profileState.when(...),
)
```

**변경 후**:
```dart
Scaffold(
  backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
  appBar: ...,
  body: profileState.when(...),
)
```

**Design System 토큰**:
- 배경: `#F8FAFC` (Neutral-50)

---

### 변경 3: 로딩 상태 표시 개선

**파일**: `profile_edit_screen.dart`
**대상 코드 위치**: Line 29-31

**변경 전**:
```dart
loading: () => const Center(
  child: CircularProgressIndicator(),
),
```

**변경 후**:
```dart
loading: () => const Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(
      Color(0xFF4ADE80), // Primary
    ),
  ),
),
```

**Design System 토큰**:
- 스피너 색상: `#4ADE80` (Primary)

---

### 변경 4: 에러 상태 표시 개선

**파일**: `profile_edit_screen.dart`
**대상 코드 위치**: Line 32-46

**변경 전**:
```dart
error: (error, stack) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('오류가 발생했습니다: $error'),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          ref.invalidate(profileNotifierProvider);
        },
        child: const Text('다시 시도'),
      ),
    ],
  ),
),
```

**변경 후**:
```dart
error: (error, stack) => Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon
        Icon(
          Icons.error_outline,
          size: 48,
          color: const Color(0xFFEF4444), // Error
        ),
        const SizedBox(height: 16),
        // Error title
        Text(
          '오류 발생',
          style: const TextStyle(
            color: Color(0xFF1E293B), // Neutral-800
            fontSize: 18,
            fontWeight: FontWeight.w600, // Semibold
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 8),
        // Error message
        Text(
          '프로필을 불러오는 중에 오류가 발생했습니다. 다시 시도해주세요.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B), // Neutral-500
            fontSize: 14,
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 24),
        // Retry button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80), // Primary
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.invalidate(profileNotifierProvider);
            },
            child: const Text(
              '다시 시도',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
```

**Design System 토큰**:
- 아이콘: Error `#EF4444`
- 제목: lg (18px, Semibold, Neutral-800)
- 메시지: sm (14px, Neutral-500)
- 버튼: Primary `#4ADE80`

---

### 변경 5: 검증 오류 피드백 → GabiumToast 전환

**파일**: `profile_edit_screen.dart`
**변경 위치**: `_handleSave()` 메서드 및 Stack 제거

**변경 전**:
```dart
// Line 54-81: Stack 사용
Stack(
  children: [
    ProfileEditForm(...),
    if (_validationError != null)
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.red.withValues(alpha: 0.8),
          padding: const EdgeInsets.all(16),
          child: Text(
            _validationError!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
  ],
)
```

**변경 후**:
```dart
// ProfileEditForm만 표시 (Stack 제거)
ProfileEditForm(
  profile: profile,
  onProfileChanged: (newProfile) {
    setState(() {
      _editedProfile = newProfile;
      _validationError = null;
    });
  },
)
```

**변경 전** (`_handleSave()` 메서드):
```dart
// Line 103-108: 검증 오류 표시
if (_editedProfile!.targetWeight.value >= _editedProfile!.currentWeight.value) {
  setState(() {
    _validationError = '목표 체중은 현재 체중보다 작아야 합니다.';
  });
  return;
}
```

**변경 후**:
```dart
// GabiumToast 사용
if (_editedProfile!.targetWeight.value >= _editedProfile!.currentWeight.value) {
  GabiumToast.show(
    context: context,
    message: '목표 체중은 현재 체중보다 작아야 합니다.',
    variant: ToastVariant.error,
  );
  return;
}
```

**import 추가**:
```dart
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
```

---

### 변경 6: ProfileEditForm 입력 필드 → GabiumTextField

**파일**: `profile_edit_form.dart`
**대상 코드 위치**: Line 118-170 (모든 TextField)

**변경 전**:
```dart
TextField(
  controller: _nameController,
  decoration: const InputDecoration(
    labelText: '이름',
    border: OutlineInputBorder(),
  ),
  onChanged: (_) => _notifyProfileChanged(),
),
```

**변경 후**:
```dart
GabiumTextField(
  controller: _nameController,
  label: '이름',
  hint: '예: 김철수',
  keyboardType: TextInputType.text,
  onChanged: (_) => _notifyProfileChanged(),
)
```

**모든 4개 필드 적용**:
1. 이름 (nameController)
2. 목표 체중 (targetWeightController)
3. 현재 체중 (currentWeightController)
4. 목표 기간 (targetPeriodController)

**import 추가**:
```dart
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
```

---

### 변경 7: 주간 감량 목표 박스 → Card Pattern

**파일**: `profile_edit_form.dart`
**대상 코드 위치**: Line 174-210

**변경 전**:
```dart
if (_calculatedWeeklyGoal != null) ...[
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(
        color: _showWeeklyGoalWarning ? Colors.orange : Colors.grey,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주간 감량 목표: ${_calculatedWeeklyGoal!.toStringAsFixed(2)}kg',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (_showWeeklyGoalWarning) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '주당 1kg 초과의 감량 목표는 위험할 수 있습니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  ),
],
```

**변경 후**:
```dart
if (_calculatedWeeklyGoal != null) ...[
  Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: _showWeeklyGoalWarning
          ? const Border(
              left: BorderSide(
                color: Color(0xFFF59E0B), // Warning
                width: 4,
              ),
            )
          : Border.all(
              color: const Color(0xFFE2E8F0), // Neutral-200
              width: 1,
            ),
      borderRadius: BorderRadius.circular(12), // md
      boxShadow: [
        BoxShadow(
          color: _showWeeklyGoalWarning
              ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
              : const Color(0xFF0F172A).withValues(alpha: 0.06),
          blurRadius: _showWeeklyGoalWarning ? 8 : 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16), // md
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          '주간 감량 목표',
          style: const TextStyle(
            color: Color(0xFF334155), // Neutral-700
            fontSize: 14,
            fontWeight: FontWeight.w600, // Semibold
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 8),
        // Goal value
        Text(
          '${_calculatedWeeklyGoal!.toStringAsFixed(2)}kg',
          style: const TextStyle(
            color: Color(0xFF1E293B), // Neutral-800
            fontSize: 20,
            fontWeight: FontWeight.w700, // Bold
            fontFamily: 'Pretendard',
          ),
        ),
        if (_showWeeklyGoalWarning) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Warning-50
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B), // Warning
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '주당 1kg 초과의 감량 목표는 위험할 수 있습니다.',
                    style: const TextStyle(
                      color: Color(0xFF92400E), // Dark Warning
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  ),
],
```

**Design System 토큰**:
- 카드 배경: White `#FFFFFF`
- 일반 테두리: Neutral-200 `#E2E8F0`
- 경고 테두리: Warning `#F59E0B` (좌측 4px)
- 경고 배경: Warning-50 `#FFFBEB`
- 제목: sm (14px, Semibold, Neutral-700)
- 값: 20px Bold, Neutral-800
- 경고 텍스트: Dark Warning `#92400E`
- 패딩: 16px (md)

---

### 변경 8: 저장 버튼 → GabiumButton Primary (폼 하단 추가)

**파일**: `profile_edit_form.dart`
**변경 위치**: Form 구조 재편성, 폼 끝에 저장 버튼 추가

**변경 전**:
```dart
// profile_edit_screen.dart 라인 84-89
floatingActionButton: _editedProfile != null
    ? FloatingActionButton(
        onPressed: _handleSave,
        child: const Icon(Icons.check),
      )
    : null,
```

**새 구조**: ProfileEditForm에 onSave 콜백 추가

**profile_edit_form.dart 변경**:

```dart
// 프롭 추가
class ProfileEditForm extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback? onSave; // 새 프롭

  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    this.onSave,
  });
  ...
}

// build 메서드의 SingleChildScrollView를 Column으로 감싸기
@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기존 모든 폼 필드...

        const SizedBox(height: 24), // lg spacing

        // 저장 버튼 (하단)
        GabiumButton(
          onPressed: onSave ?? () {},
          label: '저장',
          variant: ButtonVariant.primary,
          size: ButtonSize.medium,
          fullWidth: true,
        ),

        const SizedBox(height: 16), // Safe area 여백
      ],
    ),
  );
}
```

**profile_edit_screen.dart 변경**:

```dart
// FloatingActionButton 제거
// (floatingActionButton 프롭 삭제)

// ProfileEditForm 호출
ProfileEditForm(
  profile: profile,
  onProfileChanged: (newProfile) {
    setState(() {
      _editedProfile = newProfile;
      _validationError = null;
    });
  },
  onSave: _editedProfile != null ? _handleSave : null,
)
```

**import 추가**:
```dart
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
```

**Design System 토큰**:
- 버튼: Primary `#4ADE80`
- 높이: 44px (Medium)
- 전체 너비: true
- 텍스트: Semibold, White

---

### 변경 9: 전체 간격 시스템 재조정

**파일**: `profile_edit_form.dart`
**모든 SizedBox 높이를 8px 배수로 정렬**:

| 현재 | 변경 후 | Design System |
|------|--------|--------------|
| 16px | 16px | md |
| 12px | 16px | md (또는 8px if inline) |
| 8px | 8px | sm |
| 24px | 24px | lg |

---

## 구현 체크리스트

### ProfileEditScreen (profile_edit_screen.dart)

- [ ] AppBar 스타일 적용 (56px, Header pattern)
- [ ] 배경색 Neutral-50 명시화
- [ ] 로딩 상태 Primary 스피너 적용
- [ ] 에러 상태 개선 (아이콘, 제목, 버튼)
- [ ] Stack 제거 및 ProfileEditForm만 표시
- [ ] FloatingActionButton 제거
- [ ] _validationError 상태 제거 (Toast로 전환)
- [ ] ProfileEditForm에 onSave 콜백 추가
- [ ] GabiumToast import 추가
- [ ] GabiumButton import 추가

### ProfileEditForm (profile_edit_form.dart)

- [ ] 모든 TextField → GabiumTextField 변경
  - [ ] 이름 필드
  - [ ] 목표 체중 필드
  - [ ] 현재 체중 필드
  - [ ] 목표 기간 필드
- [ ] 주간 감량 목표 박스 → Card Pattern
  - [ ] 배경색: White
  - [ ] 일반 테두리: Neutral-200 1px
  - [ ] 경고 테두리: Warning 4px (좌측)
  - [ ] 경고 배경: Warning-50
  - [ ] 타이포 표준화
  - [ ] 패딩 16px
- [ ] 저장 버튼 추가 (Form 하단, GabiumButton)
- [ ] 간격 시스템 정렬 (8px 배수)
- [ ] GabiumTextField import 추가
- [ ] GabiumButton import 추가

---

## 테스트 시나리오

### 1. 화면 로드
- [ ] AppBar 56px 높이, Neutral-50 배경 확인
- [ ] 로딩 스피너 Primary 색상 확인
- [ ] 프로필 데이터 로드 완료 확인

### 2. 입력 필드 상호작용
- [ ] 각 필드 GabiumTextField 스타일 적용 확인
- [ ] 포커스 시 Primary 테두리 표시 확인
- [ ] 입력 완료 후 주간 감량 목표 자동 계산 확인

### 3. 주간 감량 목표 표시
- [ ] 정상 범위: Neutral-200 테두리, 카드 스타일
- [ ] 경고 범위 (>1kg): Warning 테두리, Warning-50 배경, 경고 메시지 표시
- [ ] 경고 메시지: 아이콘, 텍스트, Dark Warning 색상

### 4. 저장 기능
- [ ] 변경사항 없음: 버튼 비활성화
- [ ] 목표 체중 >= 현재 체중: Toast 에러 메시지 표시
- [ ] 유효한 값: 저장 성공, Toast 성공 메시지, 이전 화면 복귀

### 5. 에러 상태
- [ ] 프로필 로드 실패: 에러 상태 표시 (아이콘, 제목, 메시지, 재시도 버튼)

---

## 디자인 시스템 토큰 사용 요약

**색상 (18개)**:
- Primary: `#4ADE80`
- Error: `#EF4444`
- Warning: `#F59E0B`, `#FFFBEB`, `#92400E`
- Neutral: `#F8FAFC`, `#E2E8F0`, `#1E293B`, `#334155`, `#475569`, `#64748B`

**타이포그래피 (8개)**:
- 3xl (28px, Bold): AppBar 제목 (기존)
- xl (20px, Semibold): 세부 제목, 목표값
- lg (18px, Semibold): 섹션 제목
- base (16px, Regular): 본문, 입력
- sm (14px, Semibold): 라벨
- xs (12px, Regular): 경고 메시지

**간격 (4개)**:
- xs (4px)
- sm (8px)
- md (16px)
- lg (24px)

**테두리 반경 (2개)**:
- sm (8px): 버튼, 입력 필드
- md (12px): 카드, 경고 박스

**쉐도우 (3개)**:
- xs: 경고 박스 (정상)
- sm: 카드 (기본)
- md: 카드 (경고)


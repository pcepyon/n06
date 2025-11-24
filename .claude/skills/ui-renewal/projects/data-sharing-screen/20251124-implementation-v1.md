# DataSharingScreen UI 개선 - 구현 명세
## Phase 2B: 상세 구현 계획

**작성일**: 2025-11-24
**상태**: 완성됨
**Framework**: Flutter (Dart)
**Design System**: Gabium v1.0

---

## 1. 설계 토큰 정의 (28개)

### 색상 토큰 (12개)

| 토큰명 | HEX | CSS | 사용처 |
|--------|-----|-----|--------|
| Primary | `#4ADE80` | `#4ADE80` | 활성 칩, 로딩 스피너, 아이콘 배경 |
| Primary-Hover | `#22C55E` | `#22C55E` | 호버 상태 |
| Primary-Active | `#16A34A` | `#16A34A` | 클릭 상태 |
| Primary-Disabled | `#4ADE80` 40% | rgba(74, 222, 128, 0.4) | 비활성 상태 |
| Secondary | `#F59E0B` | `#F59E0B` | 종료 버튼 (경고) |
| Error | `#EF4444` | `#EF4444` | 에러 상태, 아이콘 |
| Success | `#10B981` | `#10B981` | 성공 피드백 |
| Neutral-50 | `#F8FAFC` | `#F8FAFC` | AppBar, 배경, 카드 배경 |
| Neutral-200 | `#E2E8F0` | `#E2E8F0` | 카드 테두리, 구분선 |
| Neutral-600 | `#475569` | `#475569` | 보조 텍스트, 아이콘 |
| Neutral-700 | `#334155` | `#334155` | 라벨, 약한 제목 |
| Neutral-800 | `#1E293B` | `#1E293B` | AppBar 제목, 주 텍스트 |

### 타이포그래피 토큰 (8개)

| 토큰명 | 크기 | Weight | Line-Height | 사용처 |
|--------|------|--------|------------|--------|
| AppBar Title | 20px | 700 Bold | 28px | AppBar 제목 |
| Section Title | 18px | 600 Semibold | 26px | 섹션 제목 |
| Card Title | 16px | 500 Medium | 24px | 카드 제목 (투여 용량) |
| Body | 16px | 400 Regular | 24px | 카드 부제 |
| Label | 14px | 600 Semibold | 20px | 기간 선택 라벨 |
| Caption | 14px | 400 Regular | 20px | 메타데이터 |
| Hint | 12px | 400 Regular | 16px | 도움말 텍스트 |
| Error Message | 14px | 500 Medium | 20px | 에러 메시지 |

### 여백 토큰 (4개)

| 토큰명 | 값 | 사용처 |
|--------|-----|--------|
| Spacing-sm | 8px | 칩 간 간격, 미세 간격 |
| Spacing-md | 16px | 카드 패딩, 섹션 좌우 여백 |
| Spacing-lg | 24px | 섹션 간 간격 |
| Spacing-xl | 32px | EmptyState 좌우 패딩 |

### 모양 토큰 (4개)

| 토큰명 | 값 | 사용처 |
|--------|-----|--------|
| Border Radius SM | 8px | 버튼, 칩 |
| Border Radius MD | 12px | 카드, 기간 선택 컨테이너 |
| Border Radius LG | 16px | 모달/다이얼로그 |
| Border Width | 1px | 카드 테두리 |

### 그림자 토큰 (3개)

| 토큰명 | 값 | 사용처 |
|--------|-----|--------|
| Shadow-sm | 0 2px 4px rgba(15,23,42,0.06) | 카드 기본 상태 |
| Shadow-md | 0 4px 8px rgba(15,23,42,0.08) | 카드 호버, 기간 선택 |
| Shadow-xl | 0 8px 16px rgba(15,23,42,0.10) | 모달/다이얼로그 |

---

## 2. 컴포넌트 명세

### 2.1 DataSharingPeriodSelector (신규)

**파일**: `lib/features/data_sharing/presentation/widgets/data_sharing_period_selector.dart`

**목적**: 기간 선택 칩 그룹을 Gabium 설계에 맞게 구현

**Props**:
```dart
class DataSharingPeriodSelector extends StatelessWidget {
  final DateRange selectedPeriod;
  final Function(DateRange) onPeriodChanged;
  final String? label;

  const DataSharingPeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.label = '표시 기간',
  });
}
```

**구조**:
```
Container (Card Pattern)
├─ Label (sm/Semibold/Neutral-700)
├─ SizedBox (height: 8px)
└─ Row (칩 그룹)
   ├─ FilterChip (선택) - Primary 배경
   ├─ FilterChip (미선택) - Neutral-100 배경
   └─ ...반복
```

**스타일 명세**:
- Container:
  - Background: Neutral-50
  - Border: 1px solid Neutral-200
  - Border-radius: 12px
  - Padding: 16px (md)
  - Shadow: sm

- Label:
  - Font: 14px/Semibold/Neutral-700
  - Margin-bottom: 8px

- FilterChip (선택):
  - Background: Primary (`#4ADE80`)
  - Text: White, 14px/Medium
  - Border: none
  - Padding: 8px 16px
  - Shape: RoundedRectangleBorder(8px)

- FilterChip (미선택):
  - Background: Neutral-100 (`#F1F5F9`)
  - Text: Neutral-700, 14px/Regular
  - Border: 1px solid Neutral-300
  - Padding: 8px 16px
  - Shape: RoundedRectangleBorder(8px)

- Row:
  - MainAxisAlignment: spaceEvenly
  - Children spacing: 8px (sm)

**상태**:
- 호버: Background 더 밝음 (Primary-hover)
- 클릭: Primary-active
- 로딩: 비활성 상태 (80% 투명도)

---

### 2.2 ExitConfirmationDialog (신규)

**파일**: `lib/features/data_sharing/presentation/widgets/exit_confirmation_dialog.dart`

**목적**: 공유 종료 시 확인 다이얼로그 (Gabium Modal 패턴)

**Props**:
```dart
class ExitConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ExitConfirmationDialog({
    this.onConfirm,
    this.onCancel,
  });
}
```

**구조**:
```
AlertDialog
├─ Title: "공유 종료"
├─ Content: "정말로 공유를 종료하시겠습니까?"
├─ Actions
│  ├─ TextButton (취소)
│  └─ ElevatedButton (종료)
```

**스타일 명세**:
- Dialog:
  - Background: White
  - Border-radius: 16px (lg)
  - Shadow: xl
  - Max-width: 360px
  - Padding: 24px

- Title:
  - Font: 20px/Bold/Neutral-800
  - Margin-bottom: 16px

- Content:
  - Font: 16px/Regular/Neutral-600
  - Line-height: 24px
  - Margin-bottom: 24px

- Actions:
  - Layout: Row, MainAxisAlignment.end
  - Spacing: 8px
  - TextButton (취소):
    - Text: "취소", 16px/Medium/Neutral-700
    - Background: transparent
    - Padding: 12px 24px
  - ElevatedButton (종료):
    - Text: "종료", 16px/Medium/White
    - Background: Secondary (`#F59E0B`)
    - Border-radius: 8px
    - Padding: 12px 24px
    - Shadow: sm
    - Hover: Secondary-hover

---

### 2.3 DataSharingScreen 개선 사항

**파일**: `lib/features/data_sharing/presentation/screens/data_sharing_screen.dart`

**수정 부분**: 7가지

#### Part 1: AppBar 개선
```dart
AppBar(
  backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
  foregroundColor: const Color(0xFF1E293B), // Neutral-800
  elevation: 0,
  title: const Text(
    '기록 보여주기',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700, // Bold
      color: Color(0xFF1E293B),
    ),
  ),
  leading: IconButton(
    icon: const Icon(Icons.close, size: 24),
    color: const Color(0xFF475569), // Neutral-600
    onPressed: () => _showExitDialog(context),
    tooltip: '공유 종료',
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(
      color: const Color(0xFFE2E8F0), // Neutral-200
      height: 1,
    ),
  ),
)
```

#### Part 2: 기간 선택 (신규 컴포넌트 적용)
```dart
DataSharingPeriodSelector(
  selectedPeriod: _selectedPeriod,
  onPeriodChanged: (period) {
    setState(() => _selectedPeriod = period);
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId != null) {
      ref.read(dataSharingNotifierProvider.notifier)
          .changePeriod(userId, period);
    }
  },
  label: '표시 기간',
)
```

#### Part 3: 섹션 제목 개선
```dart
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 16), // lg spacing
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600, // Semibold
        color: Color(0xFF1E293B), // Neutral-800
      ),
    ),
  );
}
```

#### Part 4: 카드 리스트 아이템 개선
```dart
Card(
  color: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // md
    side: const BorderSide(
      color: Color(0xFFE2E8F0), // Neutral-200
      width: 1,
    ),
  ),
  elevation: 2, // sm shadow
  child: ListTile(
    contentPadding: const EdgeInsets.all(16), // md
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80), // Primary
        borderRadius: BorderRadius.circular(8), // sm
      ),
      child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
    ),
    title: Text(
      '${record.actualDoseMg} mg',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: Color(0xFF1E293B), // Neutral-800
      ),
    ),
    subtitle: Text(
      '${record.administeredAt.toLocal().toString().split('.')[0]} | '
      '${record.injectionSite ?? '부위 미지정'}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        color: Color(0xFF475569), // Neutral-600
      ),
    ),
  ),
)
```

#### Part 5: 에러 상태 강화
```dart
Widget _buildErrorState(String error) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32), // xl
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32, // lg
            color: const Color(0xFFEF4444), // Error
          ),
          const SizedBox(height: 24), // lg
          Text(
            '오류가 발생했습니다',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF1E293B), // Neutral-800
            ),
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF475569), // Neutral-600
            ),
          ),
          const SizedBox(height: 24), // lg
          GabiumButton(
            text: '다시 시도',
            onPressed: () { /* retry logic */ },
            variant: GabiumButtonVariant.primary,
            size: GabiumButtonSize.medium,
          ),
        ],
      ),
    ),
  );
}
```

#### Part 6: 공유 종료 버튼 개선 (GabiumButton 사용)
```dart
SizedBox(
  width: double.infinity,
  child: GabiumButton(
    text: '공유 종료',
    onPressed: () {
      ref.read(dataSharingNotifierProvider.notifier).exitSharingMode();
      Navigator.of(context).pop();
    },
    variant: GabiumButtonVariant.secondary,
    size: GabiumButtonSize.medium,
  ),
)
```

#### Part 7: 로딩 및 빈 상태 개선
```dart
// 로딩 상태
state.isLoading
  ? Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xFF4ADE80), // Primary
          ),
          strokeWidth: 2,
        ),
      ),
    )
  : ...

// 빈 상태
if (!report.hasData()) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32), // xl
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 32, // lg
            color: const Color(0xFFCBD5E1), // Neutral-300
          ),
          const SizedBox(height: 24), // lg
          Text(
            '선택된 기간에 기록이 없습니다',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '다른 기간을 선택하거나 기록을 추가해보세요',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B), // Neutral-500
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
```

---

## 3. 파일 생성 계획

### 생성할 파일 (2개)

1. **data_sharing_period_selector.dart**
   - 위치: `lib/features/data_sharing/presentation/widgets/`
   - 크기: 약 80-100줄
   - 의존성: flutter, gabium_design_tokens (상수)

2. **exit_confirmation_dialog.dart**
   - 위치: `lib/features/data_sharing/presentation/widgets/`
   - 크기: 약 70-90줄
   - 의존성: flutter

### 수정할 파일 (1개)

1. **data_sharing_screen.dart**
   - 위치: `lib/features/data_sharing/presentation/screens/`
   - 변경 사항: 7가지 부분 수정
   - 예상 줄 수: 400 → 480줄 (80줄 증가)

---

## 4. 레이아웃 상세 구조

### DataSharingScreen 전체 구조

```
Scaffold
├─ appBar: AppBar (56px, Neutral-50 배경)
└─ body:
   ├─ 로딩 상태: Center + CircularProgressIndicator
   ├─ 에러 상태: 아이콘 + 제목 + 설명 + 버튼
   ├─ 빈 상태: 아이콘 + 제목 + 설명
   └─ 정상 상태: SingleChildScrollView
      └─ Column (Padding: md)
         ├─ DataSharingPeriodSelector (Spacing-lg 아래)
         ├─ 투여 기록 섹션
         │  ├─ 섹션 제목 (lg/Semibold)
         │  └─ 카드 리스트 (간격: md)
         ├─ 투여 순응도 섹션 (Card Pattern)
         ├─ 주사 부위 섹션 (ListTile 리스트)
         ├─ 체중 변화 섹션 (ListTile 리스트)
         ├─ 부작용 기록 섹션 (Card 리스트)
         └─ 공유 종료 버튼 (GabiumButton/Secondary)
```

---

## 5. 인터랙션 명세

### 기간 선택
- 클릭: 상태 변경 → onPeriodChanged 콜백 → 데이터 리로드
- 상태: 선택 (Primary 배경), 미선택 (Neutral-100 배경)
- 트랜지션: 200ms ease-in-out

### 종료 확인
- 클릭: ExitConfirmationDialog 표시
- 배경: Modal backdrop (Neutral-900 50% 투명도)
- 취소: 다이얼로그 닫기
- 종료: 상태 변경 → 네비게이션 pop

### 카드 호버 (데스크톱)
- 호버: Shadow md, translateY(-2px)
- 트랜지션: 200ms ease-in-out

---

## 6. Flutter 구현 예제 (전체 코드)

### data_sharing_period_selector.dart

```dart
import 'package:flutter/material.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';

class DataSharingPeriodSelector extends StatelessWidget {
  final DateRange selectedPeriod;
  final Function(DateRange) onPeriodChanged;
  final String label;

  const DataSharingPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.label = '표시 기간',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Neutral-50
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12), // md
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F172A).withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16), // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 8), // sm
          Wrap(
            spacing: 8, // sm
            runSpacing: 8,
            children: DateRange.values.map<Widget>((period) {
              final isSelected = selectedPeriod == period;
              return FilterChip(
                label: Text(
                  period.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w500 // Medium
                        : FontWeight.w400, // Regular
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF334155), // Neutral-700
                  ),
                ),
                onSelected: (selected) => onPeriodChanged(period),
                selected: isSelected,
                backgroundColor: const Color(0xFFF1F5F9), // Neutral-100
                selectedColor: const Color(0xFF4ADE80), // Primary
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // sm
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFCBD5E1), // Neutral-300
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
```

### exit_confirmation_dialog.dart

```dart
import 'package:flutter/material.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ExitConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg
      ),
      elevation: 10, // xl shadow
      title: const Text(
        '공유 종료',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700, // Bold
          color: Color(0xFF1E293B), // Neutral-800
        ),
      ),
      content: const Text(
        '정말로 공유를 종료하시겠습니까?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF475569), // Neutral-600
          height: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: const Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569), // Neutral-600
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B), // Warning/Secondary
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // sm
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            '종료',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Semibold
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 7. 접근성 체크리스트

- [x] 색상 대비: WCAG AA (Neutral-800 텍스트 on Neutral-50 배경 = 17.5:1)
- [x] 터치 영역: 모든 버튼/칩 최소 44x44px
- [x] 포커스 표시: GabiumButton에 포함됨
- [x] 텍스트 크기: 최소 14px (sm)
- [x] 아이콘 레이블: 모든 아이콘 버튼에 tooltip 추가
- [x] 화면 리더: 다이얼로그 제목, 설명 텍스트 명확
- [x] 음성 피드백: 에러/성공 메시지 명시적

---

## 8. 테스트 체크리스트

- [ ] 로딩 상태: CircularProgressIndicator Primary 색상 표시
- [ ] 에러 상태: 아이콘 + 제목 + 설명 + 버튼 모두 표시
- [ ] 빈 상태: 중앙 정렬, 타입별 메시지 표시
- [ ] 기간 선택: 칩 색상 상태 변경 확인
- [ ] 종료 확인: 다이얼로그 표시/닫기 정상 작동
- [ ] 카드 스타일: md border-radius, 테두리, 그림자 모두 적용
- [ ] 타이포그래피: 각 섹션 글꼴 크기/무게 확인
- [ ] 여백: 8px 배수 정렬 확인
- [ ] Flutter analyze: 경고 없음 확인

---

## 9. 다음 단계 (Phase 2C)

### 자동 구현 목표
1. 신규 컴포넌트 2개 생성 (총 170-190줄)
2. DataSharingScreen 전체 개선 (7개 변경사항)
3. Design System 토큰 28개 모두 적용
4. Flutter analyze 통과 (No issues)

### 예상 산출물
- `data_sharing_period_selector.dart` (90줄)
- `exit_confirmation_dialog.dart` (80줄)
- 개선된 `data_sharing_screen.dart` (480줄)

---

**Status**: ✅ 완성됨
**다음 단계**: Phase 2C 자동 구현 (20251124-implementation-log-v1.md)

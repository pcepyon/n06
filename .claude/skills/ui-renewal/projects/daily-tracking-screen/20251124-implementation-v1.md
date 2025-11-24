# DailyTrackingScreen 구현 가이드

## 구현 개요

승인된 개선 제안을 기반으로 이 가이드는 DailyTrackingScreen의 정확한 구현 명세를 제공합니다.

**구현할 변경사항:**
1. AppBar 스타일 Design System 적용
2. 식욕 조절 칩 스타일 개선
3. 부작용 섹션 초기 확장 및 카드 스타일 개선
4. 심각도 슬라이더 의미 시각화
5. 조건부 UI 섹션 시각적 구분 강화
6. 라디오 버튼 & FilterChip Design System 적용
7. 입력 필드 높이 & 스타일 통일
8. Toast 피드백으로 AlertDialog 대체
9. 저장 버튼 로딩 상태 시각화 강화
10. 섹션 제목 타이포그래피 계층 개선
11. 전체 간격 시스템 8px 배수로 정렬

---

## Design System 토큰 값

| 요소 | 토큰 경로 | 값 | 사용처 |
|---------|-----------|-------|-------|
| AppBar 높이 | Component - Header | 56px | 상단 헤더 |
| AppBar 배경 | Colors - Neutral - 50 | #F8FAFC | 헤더 배경 |
| AppBar 테두리 | Colors - Neutral - 200 | #E2E8F0 | 하단 구분선 |
| Primary 버튼 배경 | Colors - Primary | #4ADE80 | 저장 버튼 |
| Primary 버튼 텍스트 | Typography - lg | 18px, Semibold | 저장 버튼 |
| Primary 버튼 패딩 | Spacing - lg | 32px | 버튼 좌우 패딩 |
| Primary 버튼 높이 | Component - Button Large | 52px | 저장 버튼 높이 |
| 고심각도 배경 | Colors - Warning at 8% | #F59E0B + opacity 8% | 조건부 섹션 배경 |
| 고심각도 테두리 | Colors - Warning | #F59E0B | 강조 테두리 |
| 저심각도 배경 | Colors - Info at 8% | #3B82F6 + opacity 8% | 조건부 섹션 배경 |
| 저심각도 테두리 | Colors - Info | #3B82F6 | 강조 테두리 |
| 카드 배경 | Colors - White | #FFFFFF | 카드 배경 |
| 카드 테두리 | Colors - Neutral - 200 | #E2E8F0 | 카드 테두리 |
| 카드 그림자 | Shadow - sm | 0 2px 4px rgba(15,23,42,0.06) | 카드 깊이감 |
| 입력 필드 높이 | Component - Input | 48px | 입력 필드 높이 |
| 입력 필드 포커스 테두리 | Colors - Primary | #4ADE80 | 포커스 상태 |
| 칩 선택 배경 | Colors - Primary | #4ADE80 | 선택된 칩 배경 |
| 칩 선택 텍스트 | Colors - White | #FFFFFF | 선택된 칩 텍스트 |
| 섹션 제목 | Typography - xl | 20px, Semibold | 섹션 제목 |
| 소 제목 | Typography - lg | 18px, Semibold | 소 제목 |
| 본문 | Typography - base | 16px, Regular | 본문 |
| Toast 에러 배경 | Colors - Error Variant | #FEF2F2 | 에러 토스트 |
| Toast 에러 테두리 | Colors - Error | #EF4444 | 에러 토스트 테두리 |
| 섹션 간 간격 | Spacing - lg | 24px | 섹션 간 간격 |
| 카드 외부 간격 | Spacing - md | 16px | 카드 외부 간격 |

---

## 컴포넌트 명세

### Change 1: AppBar 스타일 Design System 적용

**컴포넌트 타입:** Layout - Header

**시각적 명세:**
- 배경: Neutral-50 (#F8FAFC)
- 텍스트 색상: Neutral-800 (#1E293B)
- 글꼴 크기: 20px (Typography - xl)
- 글꼴 가중치: Semibold (600)
- 패딩: 16px 좌우 (Spacing - md)
- 테두리: 1px solid, Neutral-200 (#E2E8F0)
- 테두리 반경: 없음 (직각)
- 그림자: 없음

**크기:**
- 높이: 56px (Component - Header)
- 너비: 100% of container
- 최소/최대 너비: 없음 (전체 너비)

**대화형 상태:**
- Default: 위 사양대로
- Hover: 상태 없음 (정적 영역)
- Active: 상태 없음
- Disabled: 상태 없음
- Focus: 상태 없음

**접근성:**
- ARIA label: "데일리 기록 페이지"
- Role: banner
- 키보드 네비게이션: 포커스 필요 없음

**코드 예시 (Flutter):**
```dart
// AppBar with Design System tokens
AppBar(
  backgroundColor: Color(0xFFF8FAFC),  // Neutral-50
  elevation: 0,
  title: Text(
    '데일리 기록',
    style: TextStyle(
      fontSize: 20.0,           // xl
      fontWeight: FontWeight.w600,  // Semibold
      color: Color(0xFF1E293B),     // Neutral-800
    ),
  ),
  centerTitle: false,
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(1.0),
    child: Container(
      color: Color(0xFFE2E8F0),  // Neutral-200
      height: 1.0,
    ),
  ),
)
```

---

### Change 2: 식욕 조절 칩 스타일 개선

**컴포넌트 타입:** Form Elements - Custom Chip Variant (신규 컴포넌트: AppealScoreChip)

**시각적 명세:**
- 배경 (기본): Neutral-100 (#F1F5F9)
- 배경 (선택): Primary (#4ADE80)
- 텍스트 색상 (기본): Neutral-700 (#334155)
- 텍스트 색상 (선택): White (#FFFFFF)
- 글꼴 크기: 16px (Typography - base)
- 글꼴 가중치 (기본): Regular (400)
- 글꼴 가중치 (선택): Medium (500)
- 패딩: 8px 좌우 (Spacing - sm), 4px 상하 (Spacing - xs)
- 테두리 반경: 8px (sm)
- 그림자 (기본): xs (0 1px 2px rgba(15,23,42,0.05))
- 그림자 (선택): sm (0 2px 4px rgba(15,23,42,0.06))

**크기:**
- 높이: 44px (터치 권장 높이)
- 너비: auto (컨텐츠 기반)
- 최소 너비: 60px

**대화형 상태:**
- Default: 위 사양대로 (Neutral-100 배경)
- Hover: Primary at 90% 배경 (#5FD899), 그림자 sm
- Active/Pressed: Primary -10% 배경 (#369A64), 그림자 xs
- Selected: Primary 배경 (#4ADE80), White 텍스트, Semibold, 그림자 sm
- Disabled: Neutral-100 배경, Neutral-400 텍스트, opacity 0.4

**접근성:**
- Touch target: 44x44px 이상
- 색상 대비: 4.5:1 (선택/미선택)
- ARIA label: "식욕 조절 {level}"
- Keyboard navigation: Tab, Space/Enter로 선택

**코드 예시 (Flutter):**
```dart
// AppealScoreChip - Custom Widget
class AppealScoreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppealScoreChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),  // sm, xs
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4ADE80) : Color(0xFFF1F5F9),  // Primary or Neutral-100
          borderRadius: BorderRadius.circular(8.0),  // sm
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4.0,
                offset: Offset(0, 2),
              )  // sm shadow
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2.0,
                offset: Offset(0, 1),
              ),  // xs shadow
          ],
        ),
        constraints: BoxConstraints(minHeight: 44.0),  // 터치 높이
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.0,  // base
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,  // Medium or Regular
            color: isSelected ? Colors.white : Color(0xFF334155),  // White or Neutral-700
          ),
        ),
      ),
    );
  }
}
```

---

### Change 3: 부작용 섹션 초기 확장 및 카드 스타일 개선

**컴포넌트 타입:** Layout - Card Container

**시각적 명세:**
- 배경: White (#FFFFFF)
- 텍스트 색상: Neutral-800 (#1E293B)
- 테두리: 1px solid, Neutral-200 (#E2E8F0) OR 그림자만 사용
- 테두리 반경: 12px (md)
- 그림자 (기본): sm (0 2px 4px rgba(15,23,42,0.06))
- 그림자 (호버): md (0 4px 8px rgba(15,23,42,0.08))
- 패딩: 16px (Spacing - md)
- 카드 간 간격: 16px (Spacing - md)
- 호버 효과: translateY(-2px), Shadow upgrade to md

**레이아웃 변경:**
- ExpansionTile 초기 상태: 기본적으로 expanded=true (항상 확장)
- 또는 ExpansionTile 제거 후 항상 표시

**크기:**
- 너비: 100% of container
- 높이: 동적 (컨텐츠에 따라)

**대화형 상태:**
- Default: 위 사양대로
- Hover: Shadow md, translateY(-2px)
- Active: 상태 없음
- Disabled: 상태 없음
- Focus: 2px solid Neutral-300 outline, 2px offset

**접근성:**
- Focus indicator: 명확한 아웃라인
- Color contrast: 4.5:1 이상

**코드 예시 (Flutter):**
```dart
// Card with Design System tokens
Container(
  decoration: BoxDecoration(
    color: Colors.white,  // White
    borderRadius: BorderRadius.circular(12.0),  // md
    border: Border.all(
      color: Color(0xFFE2E8F0),  // Neutral-200
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),  // sm shadow
    ],
  ),
  padding: EdgeInsets.all(16.0),  // md
  child: Column(
    children: [
      // 부작용 섹션 컨텐츠
    ],
  ),
)

// ExpansionTile 초기 확장
ExpansionTile(
  initiallyExpanded: true,  // 초기 확장 상태
  title: Text('부작용 기록'),
  children: [
    // 부작용 섹션 컨텐츠
  ],
)
```

---

### Change 4: 심각도 슬라이더 의미 시각화

**컴포넌트 타입:** Form Elements - Severity Level Indicator (신규 컴포넌트: SeverityLevelIndicator)

**시각적 명세:**

**레벨 라벨:**
- 글꼴 크기: 14px (Typography - sm)
- 글꼴 가중치: Regular (400)
- 색상: Neutral-700 (#334155)
- 배치: 슬라이더 위 좌우 (경미 좌측, 중증 우측)
- 간격: 8px 슬라이더로부터

**슬라이더 트랙:**
- 배경 (미채움): Neutral-200 (#E2E8F0)
- 높이: 4px

**슬라이더 채운 부분:**
- 색상 (1-6점): Info (#3B82F6)
- 색상 (7-10점): Warning (#F59E0B)
- 높이: 4px
- Transition: 200ms ease

**값 표시:**
- 글꼴 크기: 16px (Typography - base)
- 글꼴 가중치: Semibold (600)
- 색상: Neutral-800 (#1E293B)
- 배치: 슬라이더 아래 중앙
- 포맷: "{현재값}점"

**크기:**
- 너비: 100% of container
- 높이: 동적 (라벨 + 슬라이더 + 값 = 약 80px)

**대화형 상태:**
- Slider Thumb (드래그 손잡이):
  - 크기: 20x20px
  - 배경: Slider 색상 (Info/Warning에 따라)
  - Border: 2px solid White
  - Shadow: sm
  - Hover: 크기 24x24px로 확대, shadow md
  - Active: 색상 밝기 +10%, shadow xs

**접근성:**
- Semantic label: "심각도 레벨, 현재값 {n}점"
- Keyboard: 좌우 화살표로 조정, Home(1), End(10)
- Touch target: 44px 이상 높이 (터치 영역)

**코드 예시 (Flutter):**
```dart
// SeverityLevelIndicator - Custom Widget
class SeverityLevelIndicator extends StatelessWidget {
  final int severity;  // 1-10
  final ValueChanged<int> onChanged;

  const SeverityLevelIndicator({
    required this.severity,
    required this.onChanged,
  });

  Color get _sliderColor =>
      severity <= 6 ? Color(0xFF3B82F6) : Color(0xFFF59E0B);  // Info or Warning
  String get _levelLabel =>
      severity <= 6 ? '경미' : '중증';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 레벨 라벨
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),  // xs
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '경미',
                style: TextStyle(
                  fontSize: 14.0,  // sm
                  fontWeight: FontWeight.w400,  // Regular
                  color: Color(0xFF334155),  // Neutral-700
                ),
              ),
              Text(
                '중증',
                style: TextStyle(
                  fontSize: 14.0,  // sm
                  fontWeight: FontWeight.w400,  // Regular
                  color: Color(0xFF334155),  // Neutral-700
                ),
              ),
            ],
          ),
        ),
        // 슬라이더
        Slider(
          value: severity.toDouble(),
          min: 1.0,
          max: 10.0,
          divisions: 9,
          activeColor: _sliderColor,
          inactiveColor: Color(0xFFE2E8F0),  // Neutral-200
          onChanged: (value) => onChanged(value.toInt()),
        ),
        // 값 표시
        Padding(
          padding: EdgeInsets.only(top: 8.0),  // xs
          child: Text(
            '${severity}점',
            style: TextStyle(
              fontSize: 16.0,  // base
              fontWeight: FontWeight.w600,  // Semibold
              color: Color(0xFF1E293B),  // Neutral-800
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### Change 5: 조건부 UI 섹션 시각적 구분 강화

**컴포넌트 타입:** Layout - Conditional Section Container (신규 컴포넌트: ConditionalSection)

**고심각도 섹션 (7-10점):**

**시각적 명세:**
- 배경: Warning at 8% opacity (#F59E0B, opacity 0.08) = rgba(245,158,11,0.08)
- 테두리 좌측: 4px solid, Warning (#F59E0B)
- 아이콘: alert-circle, 20x20px, Warning 색상
- 패딩: 16px (Spacing - md)
- 마진 하단: 16px (Spacing - md)
- 라벨 타이포그래피: 18px (Typography - lg), Semibold, Neutral-700

**저심각도 섹션 (1-6점):**

**시각적 명세:**
- 배경: Info at 8% opacity (#3B82F6, opacity 0.08) = rgba(59,130,246,0.08)
- 테두리 좌측: 4px solid, Info (#3B82F6)
- 아이콘: tag, 20x20px, Info 색상
- 패딩: 16px (Spacing - md)
- 마진 하단: 16px (Spacing - md)
- 라벨 타이포그래피: 18px (Typography - lg), Semibold, Neutral-700

**크기:**
- 너비: 100% of container
- 높이: 동적 (컨텐츠에 따라)

**대화형 상태:**
- Default: 위 사양대로
- Hover: 상태 없음 (정적 컨테이너)
- Focus: 2px solid Neutral-300 outline

**접근성:**
- ARIA label: "고심각도 섹션" or "저심각도 섹션"
- Role: region
- Screen reader: 심각도 레벨 명시

**코드 예시 (Flutter):**
```dart
// ConditionalSection - Custom Widget
class ConditionalSection extends StatelessWidget {
  final bool isHighSeverity;  // true: 고심각도, false: 저심각도
  final Widget child;

  const ConditionalSection({
    required this.isHighSeverity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isHighSeverity
        ? Color(0xFFF59E0B).withOpacity(0.08)  // Warning at 8%
        : Color(0xFF3B82F6).withOpacity(0.08);  // Info at 8%

    final Color borderColor = isHighSeverity
        ? Color(0xFFF59E0B)  // Warning
        : Color(0xFF3B82F6);  // Info

    final IconData icon = isHighSeverity
        ? Icons.error_outline  // alert-circle equivalent
        : Icons.label_outline;  // tag equivalent

    final String label = isHighSeverity ? '24시간 지속 여부' : '관련 상황';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4.0,
          ),
        ),
      ),
      padding: EdgeInsets.all(16.0),  // md
      margin: EdgeInsets.only(bottom: 16.0),  // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Row(
            children: [
              Icon(
                icon,
                size: 20.0,
                color: borderColor,
              ),
              SizedBox(width: 8.0),  // sm
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.0,  // lg
                  fontWeight: FontWeight.w600,  // Semibold
                  color: Color(0xFF334155),  // Neutral-700
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),  // md/2
          // 컨텐츠
          child,
        ],
      ),
    );
  }
}
```

---

### Change 6: 라디오 버튼 & FilterChip Design System 적용

**라디오 버튼:**

**컴포넌트 타입:** Form Elements - Radio Button

**시각적 명세:**
- 크기 (시각적): 24x24px
- 크기 (터치 영역): 44x44px
- 테두리: 2px solid, Neutral-400 (#94A3B8)
- 배경: White (#FFFFFF)
- 선택됨 (내부): 12x12px 원, Primary (#4ADE80)
- 라벨 간격: 16px (Spacing - md)
- 라벨 타이포그래피: 16px (Typography - base), Regular

**대화형 상태:**
- Default: Neutral-400 테두리
- Hover: Neutral-400 테두리 + 배경 #4ADE80 at 8%
- Active: Primary 테두리, 내부 dot 표시
- Disabled: 모든 요소 opacity 0.4

**FilterChip:**

**컴포넌트 타입:** Form Elements - Chip Variant

**시각적 명세:**
- 배경 (기본): Neutral-100 (#F1F5F9)
- 배경 (선택): Primary (#4ADE80)
- 텍스트 색상 (기본): Neutral-700 (#334155)
- 텍스트 색상 (선택): White (#FFFFFF)
- 높이: 36px
- 패딩: 8px 좌우 (Spacing - sm)
- 테두리 반경: full (999px)
- 그림자: xs
- 칩 간 간격: 4px (Spacing - xs)

**대화형 상태:**
- Default: 위 사양대로
- Hover: Primary at 90%
- Active/Selected: Primary 배경, White 텍스트
- Disabled: opacity 0.4

**코드 예시 (Flutter):**
```dart
// Radio Button (기존 RadioListTile 리팩토링)
Theme(
  data: Theme.of(context).copyWith(
    radioTheme: RadioThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),
  ),
  child: RadioListTile<int>(
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    title: Text(
      label,
      style: TextStyle(
        fontSize: 16.0,  // base
        fontWeight: FontWeight.w400,  // Regular
        color: Color(0xFF334155),
      ),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
    dense: true,
  ),
)

// FilterChip
FilterChip(
  label: Text(
    label,
    style: TextStyle(
      fontSize: 14.0,  // base
      color: isSelected ? Colors.white : Color(0xFF334155),
    ),
  ),
  selected: isSelected,
  onSelected: onSelected,
  backgroundColor: Color(0xFFF1F5F9),  // Neutral-100
  selectedColor: Color(0xFF4ADE80),  // Primary
  side: BorderSide.none,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(999.0),  // full
  ),
  padding: EdgeInsets.symmetric(horizontal: 8.0),  // sm
)
```

---

### Change 7: 입력 필드 높이 & 스타일 통일

**컴포넌트 타입:** Form Elements - Text Input

**시각적 명세:**
- 높이: 48px (고정, minHeight 사용하지 말 것)
- 패딩: 12px 상하 (vertical), 16px 좌우 (horizontal)
- 테두리: 2px solid, Neutral-300 (#CBD5E1)
- 테두리 반경: 8px (sm)
- 배경: White (#FFFFFF)
- 글꼴: 16px (Typography - base), Regular
- 텍스트 색상: Neutral-900 (#0F172A)

**포커스 상태:**
- 테두리: 2px solid, Primary (#4ADE80)
- 배경: Primary at 10% (#4ADE80 + 0.1 opacity) = rgba(74,222,128,0.1)
- Outline: 없음

**에러 상태:**
- 테두리: 2px solid, Error (#EF4444)
- 에러 메시지: xs (12px), Regular, Error 색상
- 위치: 입력 필드 아래 4px 간격

**비활성 상태:**
- 배경: Neutral-100 (#F1F5F9)
- 텍스트 색상: Neutral-400 (#94A3B8)
- Opacity: 0.6

**라벨:**
- 글꼴: 14px (Typography - sm), Semibold
- 색상: Neutral-700 (#334155)
- 간격: 8px 입력 필드 위

**헬퍼 텍스트:**
- 글꼴: 12px (Typography - xs), Regular
- 색상: Neutral-500 (#64748B)
- 간격: 4px 입력 필드 아래

**코드 예시 (Flutter):**
```dart
// GabiumTextField (리팩토링)
class GabiumTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const GabiumTextField({
    required this.label,
    this.hint,
    this.errorText,
    this.helperText,
    required this.controller,
    this.onChanged,
  });

  @override
  State<GabiumTextField> createState() => _GabiumTextFieldState();
}

class _GabiumTextFieldState extends State<GabiumTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.0,  // sm
            fontWeight: FontWeight.w600,  // Semibold
            color: Color(0xFF334155),  // Neutral-700
          ),
        ),
        SizedBox(height: 8.0),  // sm
        // 입력 필드
        Container(
          height: 48.0,  // 고정 높이
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),  // 패딩
          decoration: BoxDecoration(
            color: Colors.white,  // White
            border: Border.all(
              color: widget.errorText != null
                  ? Color(0xFFEF4444)  // Error
                  : _isFocused
                  ? Color(0xFF4ADE80)  // Primary (focus)
                  : Color(0xFFCBD5E1),  // Neutral-300 (default)
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),  // sm
            color: _isFocused
                ? Color(0xFF4ADE80).withOpacity(0.1)  // Primary at 10%
                : Colors.white,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                fontSize: 16.0,  // base
                color: Color(0xFF94A3B8),  // Neutral-400
              ),
            ),
            style: TextStyle(
              fontSize: 16.0,  // base
              fontWeight: FontWeight.w400,  // Regular
              color: Color(0xFF0F172A),  // Neutral-900
            ),
            onChanged: widget.onChanged,
          ),
        ),
        // 에러 메시지
        if (widget.errorText != null) ...[
          SizedBox(height: 4.0),  // xs
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: 12.0,  // xs
              fontWeight: FontWeight.w400,  // Regular
              color: Color(0xFFEF4444),  // Error
            ),
          ),
        ],
        // 헬퍼 텍스트
        if (widget.helperText != null) ...[
          SizedBox(height: 4.0),  // xs
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12.0,  // xs
              fontWeight: FontWeight.w400,  // Regular
              color: Color(0xFF64748B),  // Neutral-500
            ),
          ),
        ],
      ],
    );
  }
}
```

---

### Change 8: Toast 피드백으로 AlertDialog 대체

**컴포넌트 타입:** Feedback - Toast/Snackbar

**시각적 명세 (에러 변형):**
- 너비: 모바일 90% (최대 360px)
- 패딩: 16px (Spacing - md)
- 테두리 반경: 12px (md)
- 그림자: lg (0 8px 16px rgba(15,23,42,0.10))
- 위치: 화면 하단 중앙
- 애니메이션: Slide-up (300ms)
- 지속 시간: 5초 (에러)

**배경 및 텍스트:**
- 배경: Error Variant (#FEF2F2)
- 테두리 좌측: 4px solid, Error (#EF4444)
- 텍스트 색상: Error Dark (#991B1B)
- 텍스트 글꼴: 14px (sm), Regular
- 아이콘: error-circle, 24x24px, left-aligned
- 아이콘-텍스트 간격: 12px
- 닫기 버튼: 20x20px, 우측 정렬, Ghost 스타일

**Success 변형:**
- 배경: Success Variant (#ECFDF5)
- 테두리: 4px solid, Success (#10B981)
- 텍스트 색상: Success Dark (#065F46)
- 지속 시간: 3초

**Warning 변형:**
- 배경: Warning Variant (#FFFBEB)
- 테두리: 4px solid, Warning (#F59E0B)
- 텍스트 색상: Warning Dark (#92400E)
- 지속 시간: 5초

**Info 변형:**
- 배경: Info Variant (#EFF6FF)
- 테두리: 4px solid, Info (#3B82F6)
- 텍스트 색상: Info Dark (#1E40AF)
- 지속 시간: 4초

**코드 예시 (Flutter):**
```dart
// GabiumToast - Custom Widget (기존 SnackBar 대체)
class GabiumToast {
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      type: ToastType.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      type: ToastType.success,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      type: ToastType.warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      type: ToastType.info,
    );
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    required ToastType type,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final colors = {
      ToastType.error: (
        bg: Color(0xFFFEF2F2),  // Error Variant
        border: Color(0xFFEF4444),  // Error
        text: Color(0xFF991B1B),  // Error Dark
        duration: 5,
      ),
      ToastType.success: (
        bg: Color(0xFFECFDF5),  // Success Variant
        border: Color(0xFF10B981),  // Success
        text: Color(0xFF065F46),  // Success Dark
        duration: 3,
      ),
      ToastType.warning: (
        bg: Color(0xFFFFFBEB),  // Warning Variant
        border: Color(0xFFF59E0B),  // Warning
        text: Color(0xFF92400E),  // Warning Dark
        duration: 5,
      ),
      ToastType.info: (
        bg: Color(0xFFEFF6FF),  // Info Variant
        border: Color(0xFF3B82F6),  // Info
        text: Color(0xFF1E40AF),  // Info Dark
        duration: 4,
      ),
    };

    final config = colors[type]!;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            color: config.bg,
            borderRadius: BorderRadius.circular(12.0),  // md
            border: Border(
              left: BorderSide(
                color: config.border,
                width: 4.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16.0,
                spreadRadius: 8.0,
              ),  // lg shadow
            ],
          ),
          padding: EdgeInsets.all(16.0),  // md
          child: Row(
            children: [
              // 아이콘
              Icon(
                _getIconForType(type),
                size: 24.0,
                color: config.border,
              ),
              SizedBox(width: 12.0),  // 아이콘-텍스트 간격
              // 메시지
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.0,  // sm
                    fontWeight: FontWeight.w400,  // Regular
                    color: config.text,
                  ),
                ),
              ),
              // 닫기 버튼 (선택)
              GestureDetector(
                onTap: () => scaffoldMessenger.hideCurrentSnackBar(),
                child: Icon(
                  Icons.close,
                  size: 20.0,
                  color: config.border,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,  // 5%
          vertical: 16.0,
        ),
        duration: Duration(seconds: config.duration),
      ),
    );
  }

  static IconData _getIconForType(ToastType type) {
    return switch (type) {
      ToastType.error => Icons.error_outline,
      ToastType.success => Icons.check_circle_outline,
      ToastType.warning => Icons.warning_outlined,
      ToastType.info => Icons.info_outlined,
    };
  }
}

enum ToastType { error, success, warning, info }
```

---

### Change 9: 저장 버튼 로딩 상태 시각화 강화

**컴포넌트 타입:** Buttons - Primary (로딩 상태 포함)

**시각적 명세 (Default):**
- 배경: Primary (#4ADE80)
- 텍스트: White (#FFFFFF), 18px (lg), Semibold
- 높이: 52px (Large)
- 패딩: 32px 좌우 (Spacing - lg)
- 테두리 반경: 12px (md) 또는 8px (sm)
- 그림자: sm
- 너비: 100% of container

**로딩 상태:**
- 배경: Primary (#4ADE80) (변화 없음)
- 텍스트: "저장 중..." (흰색)
- 스피너: 16px circular spinner (흰색)
- 스피너 위치: 텍스트 좌측 8px 간격
- 버튼 비활성화: 클릭 불가
- Opacity: 1.0 (변화 없음)

**대화형 상태:**
- Default: 위 사양대로
- Hover: Background #22C55E (Primary +10%), Shadow md
- Active: Background #16A34A (Primary -10%), Shadow xs
- Disabled: Opacity 0.4
- Loading: Primary 배경 + 스피너, 비활성

**접근성:**
- ARIA label: "저장하기" (로딩 중: "저장 중입니다")
- Touch target: 52px 높이 (44px 이상 권장)

**코드 예시 (Flutter):**
```dart
// GabiumButton with Loading State
class GabiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final GabiumButtonVariant variant;
  final GabiumButtonSize size;

  const GabiumButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.variant = GabiumButtonVariant.primary,
    this.size = GabiumButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = switch (size) {
      GabiumButtonSize.small => (height: 36.0, padding: 16.0, fontSize: 14.0),
      GabiumButtonSize.medium => (height: 44.0, padding: 24.0, fontSize: 16.0),
      GabiumButtonSize.large => (height: 52.0, padding: 32.0, fontSize: 18.0),
    };

    if (variant == GabiumButtonVariant.primary) {
      return ElevatedButton(
        onPressed: (isLoading || !isEnabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4ADE80),  // Primary
          foregroundColor: Colors.white,
          minimumSize: Size.fromHeight(buttonSize.height),
          padding: EdgeInsets.symmetric(horizontal: buttonSize.padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),  // md
          ),
          elevation: 2.0,  // sm shadow
          disabledBackgroundColor: Color(0xFF4ADE80).withOpacity(0.4),
        ),
        child: isLoading
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.0,  // 스피너 크기
                  height: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8.0),  // 스피너-텍스트 간격
                Text(
                  '저장 중...',
                  style: TextStyle(
                    fontSize: 18.0,  // lg
                    fontWeight: FontWeight.w600,  // Semibold
                  ),
                ),
              ],
            )
            : Text(
              label,
              style: TextStyle(
                fontSize: buttonSize.fontSize.toInt() == 18 ? 18.0 : 16.0,
                fontWeight: FontWeight.w600,  // Semibold
              ),
            ),
      );
    }

    // Secondary, Tertiary, Ghost variants 구현 (동일 패턴)
    return SizedBox();  // 부분 구현
  }
}

enum GabiumButtonVariant { primary, secondary, tertiary, ghost, danger }
enum GabiumButtonSize { small, medium, large }
```

---

### Change 10: 섹션 제목 타이포그래피 계층 개선

**주 섹션 제목:**
- 글꼴 크기: 20px (Typography - xl)
- 글꼴 가중치: Semibold (600)
- 색상: Neutral-800 (#1E293B)
- 사용: 신체 기록, 부작용 기록 메인 제목
- 마진 하단: 12px (sm)

**소 제목:**
- 글꼴 크기: 18px (Typography - lg)
- 글꼴 가중치: Semibold (600)
- 색상: Neutral-700 (#334155)
- 사용: 증상 선택, 선택된 증상 제목
- 마진 하단: 8px (xs)

**본문 텍스트:**
- 글꼴 크기: 16px (Typography - base)
- 글꼴 가중치: Regular (400)
- 색상: Neutral-600 (#475569)
- 사용: 일반 텍스트, 설명

**헬퍼 텍스트:**
- 글꼴 크기: 14px (Typography - sm)
- 글꼴 가중치: Regular (400)
- 색상: Neutral-500 (#64748B)
- 사용: 라벨, 보조 정보

**캡션:**
- 글꼴 크기: 12px (Typography - xs)
- 글꼴 가중치: Regular (400)
- 색상: Neutral-400 (#94A3B8)
- 사용: 메타정보, 타임스탐프

**코드 예시 (Flutter):**
```dart
// 주 제목 (신체 기록)
Text(
  '신체 기록',
  style: TextStyle(
    fontSize: 20.0,  // xl
    fontWeight: FontWeight.w600,  // Semibold
    color: Color(0xFF1E293B),  // Neutral-800
  ),
)

// 소 제목 (증상 선택)
Text(
  '증상 선택',
  style: TextStyle(
    fontSize: 18.0,  // lg
    fontWeight: FontWeight.w600,  // Semibold
    color: Color(0xFF334155),  // Neutral-700
  ),
)

// 본문
Text(
  '체중을 입력해주세요',
  style: TextStyle(
    fontSize: 16.0,  // base
    fontWeight: FontWeight.w400,  // Regular
    color: Color(0xFF475569),  // Neutral-600
  ),
)
```

---

### Change 11: 전체 간격 시스템 8px 배수로 정렬

**간격 토큰 정의:**
- xs: 4px - 아이콘과 텍스트 간격
- sm: 8px - 컴포넌트 내부 간격
- md: 16px - 기본 요소 간 간격, 카드 패딩
- lg: 24px - 섹션 간 간격
- xl: 32px - 주요 섹션 구분
- 2xl: 48px - 대형 섹션 구분

**구체적 레이아웃:**

```
화면 전체:
- 상단 패딩: 0 (AppBar 바로 아래)
- 좌우 패딩: 16px (Spacing - md)
- 하단 패딩: 32px (Spacing - xl)

섹션 배치:
- 날짜 선택: 섹션 상단
- [간격 24px - lg]
- 신체 기록 (카드):
  - 카드 패딩: 16px (md)
  - 카드 내부 요소 간격: 12px (sm + 4px)
- [간격 24px - lg]
- 부작용 기록 (카드):
  - 카드 패딩: 16px (md)
  - 부작용 선택 칩:
    - 칩 간 간격: 4px (xs)
    - 칩 행 간: 8px (sm)
  - 선택된 증상 카드:
    - 카드 간 간격: 12px (sm + 4px)
- [간격 24px - lg]
- 저장 버튼
- [간격 32px - xl]
```

**코드 예시 (Flutter):**
```dart
// DailyTrackingScreen with proper spacing
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // AppBar 명세 (Change 1)
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),  // md
      child: Column(
        children: [
          // 날짜 선택
          DateSelectionWidget(),

          // 섹션 간 간격
          SizedBox(height: 24.0),  // lg

          // 신체 기록 카드
          Container(
            // Card 스타일 (Change 3)
            padding: EdgeInsets.all(16.0),  // md
            child: Column(
              children: [
                // 제목
                Text('신체 기록', style: _titleStyle()),  // Change 10
                SizedBox(height: 12.0),  // sm + xs

                // 체중 입력
                GabiumTextField(label: '체중 (kg)'),  // Change 7
                SizedBox(height: 12.0),  // sm + xs

                // 식욕 조절
                Text('식욕 조절', style: _subtitleStyle()),
                SizedBox(height: 8.0),  // sm
                Row(
                  children: [
                    // AppealScoreChip들 with xs (4px) 간격
                  ],
                ),
              ],
            ),
          ),

          // 섹션 간 간격
          SizedBox(height: 24.0),  // lg

          // 부작용 기록 카드
          Container(
            // Card 스타일
            padding: EdgeInsets.all(16.0),  // md
            child: Column(
              children: [
                // 증상 선택 칩 (sm 간격)
                Wrap(
                  spacing: 4.0,  // xs (칩 수평 간격)
                  runSpacing: 8.0,  // sm (칩 수직 간격)
                  children: [
                    // FilterChip들
                  ],
                ),
                SizedBox(height: 12.0),  // sm + xs

                // 선택된 증상 카드들
                Column(
                  children: [
                    // 증상 카드 with 12px 간격
                  ],
                ),
              ],
            ),
          ),

          // 섹션 간 간격
          SizedBox(height: 24.0),  // lg

          // 저장 버튼
          GabiumButton(
            label: '저장하기',
            onPressed: _handleSave,
            isLoading: isLoading,
          ),

          // 하단 여백
          SizedBox(height: 32.0),  // xl
        ],
      ),
    ),
  );
}
```

---

## 레이아웃 명세

### 전체 레이아웃 구조

```
┌──────────────────────────────────────┐
│ AppBar (56px)                        │
│ 데일리 기록 (xl, Semibold)            │
│ ─────────────────────────────────── │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ 콘텐츠 영역 (Padding: md/16px)       │
│                                      │
│ [DateSelectionWidget]                │
│                                      │
│ [Space lg/24px]                      │
│                                      │
│ ┌────────────────────────────────┐  │
│ │ 신체 기록 (xl)                 │  │
│ │ [Space sm/8px]                 │  │
│ │ 체중 (kg) * [Input 48px]       │  │
│ │ [Space sm/8px]                 │  │
│ │ 식욕 조절 * (lg title)         │  │
│ │ [Space sm/8px]                 │  │
│ │ [Chip] [Chip] [Chip] [Chip]... │  │
│ └────────────────────────────────┘  │
│                                      │
│ [Space lg/24px]                      │
│                                      │
│ ┌────────────────────────────────┐  │
│ │ 부작용 기록 선택 (xl)           │  │
│ │ [Space sm/8px]                 │  │
│ │ 증상 선택 (lg title)           │  │
│ │ [Space sm/8px]                 │  │
│ │ [FilterChip] [FilterChip] ...  │  │
│ │ [Space md/16px]                │  │
│ │                                │  │
│ │ ┌──────────────────────────┐   │  │
│ │ │ 메스꺼움 (lg)            │   │  │
│ │ │ 심각도: [Slider] 7점     │   │  │
│ │ │ [Space md/16px]          │   │  │
│ │ │                          │   │  │
│ │ │ ⚠️ 심각도 7-10점 섹션    │   │  │
│ │ │ [ConditionalSection]     │   │  │
│ │ │ 24시간 지속: [Radio]...  │   │  │
│ │ │                          │   │  │
│ │ │ 메모 (lg, 선택)          │   │  │
│ │ │ [Textarea 96px]          │   │  │
│ │ └──────────────────────────┘   │  │
│ │                                │  │
│ │ [Space md/16px] (다음 증상)    │  │
│ │                                │  │
│ └────────────────────────────────┘  │
│                                      │
│ [Space lg/24px]                      │
│                                      │
│ [저장 버튼 52px, Primary, full-width]│
│                                      │
│ [Space xl/32px]                      │
└──────────────────────────────────────┘
```

### 반응형 동작

**모바일 (< 768px):**
- 모든 요소 전체 너비
- 좌우 패딩: 16px (md)
- 레이아웃 변경 없음

**태블릿 (768px - 1024px):**
- 콘텐츠 최대 너비: 640px
- 중앙 정렬 (auto margin)
- 좌우 패딩: 24px (lg)

**데스크톱 (> 1024px):**
- 콘텐츠 최대 너비: 640px
- 중앙 정렬

---

## 인터랙션 명세

### 입력 필드 인터랙션 (체중)

**Click/Tap:**
- Trigger: 포커스 획득
- Visual feedback: Primary 테두리, Primary at 10% 배경
- Duration: 즉시

**입력:**
- Trigger: 사용자 입력 (0-300kg)
- Visual feedback: 유효성 검증 (실시간)
- 에러 표시: 빨간색 테두리 + 에러 메시지 Toast

**검증:**
- 필수 항목: 공백 불가
- 범위: 20-300kg
- 범위 벗어남: Toast 에러 메시지 표시

### 식욕 조절 칩 인터랙션

**Click/Tap:**
- Trigger: 칩 클릭
- Visual feedback:
  - Selected: Primary 배경, White 텍스트, Semibold, Shadow sm
  - Unselected: Neutral-100 배경, Neutral-700 텍스트, Regular, Shadow xs
- Duration: 200ms transition
- Enforced: 필수 1개 선택

**선택 상태 변경:**
- 다른 칩 선택 시 이전 선택 해제 (단일 선택)
- 상태 변경 즉시 반영

### 심각도 슬라이더 인터랙션

**Drag:**
- Trigger: 슬라이더 드래그
- Visual feedback:
  - Thumb color 변경 (Info/Warning에 따라)
  - 값 숫자 실시간 업데이트
  - 배경색 변경 (Info/Warning 8% opacity)
- Duration: 즉시
- Range: 1-10

**값 변경 감지:**
- 7점 기준 조건부 UI 변경
  - 1-6점: 태그 섹션 표시
  - 7-10점: 24h 지속 여부 섹션 표시
- 변경 애니메이션: 200ms fade-in

### 조건부 섹션 렌더링

**조건부 표시:**
- 심각도 <= 6점: Info (파란색) 섹션만 표시
  - 태그 선택 목록 (관련 상황)
- 심각도 >= 7점: Warning (주황색) 섹션만 표시
  - 24시간 지속 여부 라디오 버튼

**전환 애니메이션:**
- Fade-out 이전 섹션 (200ms)
- Fade-in 새 섹션 (200ms)
- 또는 Instant 변경 (성능 우선)

### 라디오 버튼 (24h 지속) 인터랙션

**Click/Tap:**
- Trigger: 라디오 버튼 또는 라벨 클릭
- Visual feedback: 선택 표시 (Primary 색상)
- Duration: 즉시
- Enforced: 필수 1개 선택

**포커스:**
- Focus indicator: 2px solid Neutral-300 outline
- Keyboard: Space/Enter로 선택

### FilterChip (관련 상황/증상) 인터랙션

**Click/Tap:**
- Trigger: 칩 클릭
- Visual feedback:
  - Selected: Primary 배경, White 텍스트
  - Unselected: Neutral-100 배경, Neutral-700 텍스트
- Duration: 200ms
- Multiple selection 가능

**Wrap 레이아웃:**
- 칩 간 간격: xs (4px) 수평, sm (8px) 수직
- 줄바꿈: 자동

### 저장 버튼 인터랙션

**Click/Tap:**
- Trigger: 버튼 클릭
- Visual feedback: Active 상태 (Background #16A34A, Shadow xs)
- Duration: 즉시

**로딩 상태:**
- Replace button text: "저장 중..."
- Show spinner: 16px 흰색 CircularProgressIndicator
- Disable interaction: 클릭 불가
- Duration: 완료될 때까지

**완료 후:**
- 상태 복구: 기본 상태로 돌아감
- 피드백: Toast (Success or Error)
- Auto-dismiss: Toast 3-5초 자동 닫힘
- Navigation: 성공 시 이전 화면 또는 유지

### Textarea (메모) 인터랙션

**Focus:**
- Visual feedback: Primary 테두리, Primary at 10% 배경
- Duration: 즉시

**입력:**
- Max length: 제한 없음 (또는 500자)
- Resize: Vertical only
- Line height: 1.5배 (한글 가독성)
- Min height: 96px (Typography base, 4줄)

---

## 접근성 체크리스트

- [ ] 색상 대비: WCAG AA 이상 (4.5:1 텍스트, 3:1 UI)
  - 검증: Primary (#4ADE80) on White (4.5:1+)
  - 검증: Neutral-700 (#334155) on Neutral-100 (#F1F5F9) (4.5:1+)
  - 검증: Error (#EF4444) on Error Variant (#FEF2F2) (4.5:1+)

- [ ] 터치 영역: 모든 인터랙티브 요소 44x44px 이상
  - 버튼: 52px (Large), 44px (Medium), 36px (Small)
  - 칩: 44px (AppealScoreChip), 36px (FilterChip)
  - 라디오: 44x44px 터치 영역
  - 체크박스: 44x44px 터치 영역

- [ ] 포커스 상태: 키보드 네비게이션 명확
  - 포커스 indicator: 2px solid Neutral-300 outline, 2px offset
  - Tab 순서: 자연스러운 순서 (위→아래, 좌→우)

- [ ] ARIA 라벨:
  - AppBar: "데일리 기록 페이지"
  - 필수 필드: asterisk (*) + "필수" 라벨
  - 칩: "식욕 조절 {level}"
  - 슬라이더: "심각도 레벨, 현재값 {n}점"
  - 라디오: "{label} 라디오 버튼"

- [ ] 스크린리더 지원:
  - 모든 이미지: alt text 제공
  - 아이콘: aria-label 또는 hidden (decorative)
  - 에러 메시지: 명시적 텍스트
  - 성공: "저장 완료" Toast로 공지

- [ ] 키보드 네비게이션:
  - Tab: 다음 요소로 이동
  - Shift+Tab: 이전 요소로 이동
  - Enter/Space: 버튼, 라디오, 체크박스 활성화
  - Arrow keys: 슬라이더 값 조정, 라디오 그룹 이동

---

## 테스트 체크리스트

- [ ] 모든 대화형 상태 작동 (호버, 활성, 비활성)
- [ ] 반응형 동작 검증 (모바일, 태블릿, 데스크톱)
- [ ] 접근성 요구사항 충족
- [ ] Design System 토큰 정확성
- [ ] 다른 화면에서 시각적 회귀 없음
- [ ] 로딩 상태 순환 테스트
- [ ] 에러 메시지 Toast 표시
- [ ] 유효성 검증 (체중 범위, 필수 필드)
- [ ] 조건부 UI 변경 (심각도 1-6, 7-10)
- [ ] 스크린 키보드 입력 (모바일)

---

## 생성/수정할 파일 목록

### 신규 컴포넌트 파일:
- `lib/features/tracking/presentation/widgets/appeal_score_chip.dart` (AppealScoreChip)
- `lib/features/tracking/presentation/widgets/severity_level_indicator.dart` (SeverityLevelIndicator)
- `lib/features/tracking/presentation/widgets/conditional_section.dart` (ConditionalSection)

### 수정할 파일:
- `lib/features/tracking/presentation/screens/daily_tracking_screen.dart`
  - AppBar 스타일 적용 (Change 1)
  - 레이아웃 간격 조정 (Change 11)
  - AlertDialog → Toast 전환 (Change 8)
  - 로딩 상태 시각화 (Change 9)

- `lib/shared/widgets/gabium_text_field.dart`
  - 높이 48px 고정 (Change 7)
  - 포커스 상태 스타일 강화

- `lib/shared/widgets/gabium_button.dart`
  - Large 크기(52px) 명시 (Change 9)
  - 로딩 상태 스피너 추가

- `lib/shared/widgets/date_selection_widget.dart`
  - 타이포그래피 Design System 토큰 적용 (Change 10)

### 필요한 자산:
- 아이콘: alert-circle, tag, error, success, warning, info (Material Symbols)
- 폰트: Pretendard Variable (기존 사용)

**참고:** Component Registry는 Phase 3 Step 4에서 업데이트합니다.

---

## 구현 순서

1. **신규 컴포넌트 생성 (3개):**
   - AppealScoreChip
   - SeverityLevelIndicator
   - ConditionalSection

2. **기존 컴포넌트 수정:**
   - GabiumTextField (높이 48px)
   - GabiumButton (Large 크기, 로딩 상태)
   - GabiumToast (Toast 컴포넌트 생성 또는 기존 SnackBar 리팩토링)

3. **DailyTrackingScreen 메인 리팩토링:**
   - AppBar 스타일 적용
   - 레이아웃 간격 시스템 정렬
   - 모든 Change 사항 통합
   - AlertDialog → Toast로 변경
   - 로딩 상태 UI 추가

4. **테스트:**
   - 단위 테스트 (신규 컴포넌트)
   - 통합 테스트 (DailyTrackingScreen)
   - 접근성 테스트

---

**문서 작성 완료:** 2025-11-24
**Design System:** Gabium v1.0
**Framework:** Flutter
**상태:** Phase 2B 구현 가이드 완성

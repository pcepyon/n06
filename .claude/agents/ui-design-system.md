# UI Design System Agents - 범용 UI/UX 개선 자동화 시스템

> 2025년 베스트 프랙티스 기반 Design Token + Atomic Design + AI Audit

## 개요

이 에이전트 시스템은 **어떤 Flutter 프로젝트든** 일관된 디자인 시스템을 구축하고 UI를 자동으로 개선할 수 있도록 설계되었습니다.

### 핵심 원칙
1. **Design Tokens First**: JSON 기반 토큰으로 색상, 타이포그래피, 스페이싱 중앙화
2. **Atomic Design**: Atoms → Molecules → Organisms → Templates 계층 구조
3. **Zero Logic Change**: Presentation Layer만 수정, 비즈니스 로직 보존
4. **AI-Powered Audit**: 자동 분석으로 일관성 문제 탐지
5. **Reusable Components**: 프로젝트 간 재사용 가능한 컴포넌트 라이브러리

---

## 에이전트 파이프라인

```
1. ui-analyzer (분석)
   ↓
2. design-token-generator (토큰 생성)
   ↓
3. component-library-builder (컴포넌트 생성)
   ↓
4. ui-refactor-agent (기존 UI 마이그레이션)
   ↓
5. design-system-documenter (문서화)
```

---

## 1. UI Analyzer Agent

### 목적
현재 프로젝트의 UI 상태를 자동으로 분석하고 일관성 문제를 탐지합니다.

### 입력
- 프로젝트 경로
- 분석 범위 (전체 / 특정 feature)

### 출력
```json
{
  "screens": {
    "total": 15,
    "paths": ["features/*/presentation/screens/*.dart"]
  },
  "colors_used": {
    "primary": ["#FF6B6B", "#FF5252", "#F44336"],
    "inconsistency": "3 variations of red found"
  },
  "typography": {
    "font_families": ["Pretendard", "Roboto"],
    "sizes_used": [12, 13, 14, 16, 18, 20, 24],
    "inconsistency": "No systematic scale detected"
  },
  "spacing_patterns": {
    "values": [4, 8, 10, 12, 16, 20, 24, 32],
    "inconsistency": "10, 12 don't follow 8pt grid"
  },
  "widgets_reused": {
    "custom_buttons": 3,
    "custom_cards": 2,
    "inconsistency": "Multiple button implementations"
  },
  "accessibility_issues": [
    "5 buttons without semantic labels",
    "3 color contrasts below WCAG AA"
  ]
}
```

### 실행 방법
```bash
claude-code "UI Analyzer 에이전트를 실행해서 현재 프로젝트의 UI 상태를 분석해줘"
```

---

## 2. Design Token Generator Agent

### 목적
분석 결과를 바탕으로 W3C 표준 Design Token JSON을 생성합니다.

### 입력
- UI Analyzer 결과
- 디자인 의도 (선택사항)

### 출력: `design_tokens.json`
```json
{
  "color": {
    "brand": {
      "primary": { "value": "#FF6B6B" },
      "secondary": { "value": "#4ECDC4" }
    },
    "semantic": {
      "success": { "value": "#4CAF50" },
      "error": { "value": "#F44336" },
      "warning": { "value": "#FF9800" }
    },
    "neutral": {
      "50": { "value": "#FAFAFA" },
      "100": { "value": "#F5F5F5" },
      "900": { "value": "#212121" }
    }
  },
  "typography": {
    "font-family": {
      "base": { "value": "Pretendard" }
    },
    "font-size": {
      "xs": { "value": "12px" },
      "sm": { "value": "14px" },
      "base": { "value": "16px" },
      "lg": { "value": "18px" },
      "xl": { "value": "20px" },
      "2xl": { "value": "24px" },
      "3xl": { "value": "32px" }
    },
    "font-weight": {
      "regular": { "value": "400" },
      "medium": { "value": "500" },
      "semibold": { "value": "600" },
      "bold": { "value": "700" }
    }
  },
  "spacing": {
    "xs": { "value": "4px" },
    "sm": { "value": "8px" },
    "md": { "value": "16px" },
    "lg": { "value": "24px" },
    "xl": { "value": "32px" }
  },
  "radius": {
    "sm": { "value": "4px" },
    "md": { "value": "8px" },
    "lg": { "value": "12px" },
    "full": { "value": "9999px" }
  }
}
```

### 출력: `lib/core/design_system/tokens.dart` (자동 생성)
```dart
// Auto-generated from design_tokens.json
// DO NOT EDIT MANUALLY

class DesignTokens {
  // Colors
  static const primaryColor = Color(0xFFFF6B6B);
  static const secondaryColor = Color(0xFF4ECDC4);

  // Typography
  static const fontFamilyBase = 'Pretendard';
  static const fontSizeBase = 16.0;
  static const fontWeightRegular = FontWeight.w400;

  // Spacing
  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 24.0;

  // Radius
  static const radiusMd = 8.0;
}
```

### 실행 방법
```bash
claude-code "Design Token Generator 에이전트로 design_tokens.json과 Dart 코드를 생성해줘"
```

---

## 3. Component Library Builder Agent

### 목적
Atomic Design 원칙에 따라 재사용 가능한 컴포넌트 라이브러리를 생성합니다.

### 입력
- `design_tokens.json`
- 필요한 컴포넌트 목록

### 출력 구조
```
lib/core/design_system/
├── tokens.dart                    # 자동 생성된 토큰
├── atoms/
│   ├── ds_button.dart            # Primary, Secondary, Outline
│   ├── ds_text.dart              # Heading, Body, Caption
│   ├── ds_icon.dart
│   └── ds_spacer.dart
├── molecules/
│   ├── ds_text_field.dart        # 입력 필드 + 라벨
│   ├── ds_card.dart
│   └── ds_list_tile.dart
├── organisms/
│   ├── ds_app_bar.dart
│   ├── ds_bottom_sheet.dart
│   └── ds_dialog.dart
└── theme/
    └── app_theme.dart            # ThemeData 통합
```

### 예시: `ds_button.dart`
```dart
import '../tokens.dart';

enum DSButtonVariant { primary, secondary, outline, ghost }
enum DSButtonSize { small, medium, large }

class DSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final Widget? icon;

  const DSButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final sizing = _getSizing();

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        padding: EdgeInsets.symmetric(
          horizontal: sizing.paddingHorizontal,
          vertical: sizing.paddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: DesignTokens.spacingSm),
                ],
                Text(label),
              ],
            ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case DSButtonVariant.primary:
        return _ButtonColors(
          background: DesignTokens.primaryColor,
          foreground: Colors.white,
        );
      case DSButtonVariant.secondary:
        return _ButtonColors(
          background: DesignTokens.secondaryColor,
          foreground: Colors.white,
        );
      // ... 다른 variants
    }
  }

  _ButtonSizing _getSizing() {
    switch (size) {
      case DSButtonSize.small:
        return _ButtonSizing(paddingHorizontal: 12, paddingVertical: 8);
      case DSButtonSize.medium:
        return _ButtonSizing(paddingHorizontal: 16, paddingVertical: 12);
      case DSButtonSize.large:
        return _ButtonSizing(paddingHorizontal: 24, paddingVertical: 16);
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  _ButtonColors({required this.background, required this.foreground});
}

class _ButtonSizing {
  final double paddingHorizontal;
  final double paddingVertical;
  _ButtonSizing({required this.paddingHorizontal, required this.paddingVertical});
}
```

### 실행 방법
```bash
claude-code "Component Library Builder 에이전트로 Button, Card, TextField 컴포넌트를 생성해줘"
```

---

## 4. UI Refactor Agent

### 목적
기존 화면을 새로운 디자인 시스템 컴포넌트로 점진적으로 마이그레이션합니다.

### 입력
- 리팩토링할 화면 경로
- 우선순위 (high/medium/low)

### 동작 방식
1. 기존 화면의 위젯 트리 분석
2. 디자인 시스템 컴포넌트로 매핑 가능 여부 판단
3. 자동 교체 (안전한 경우만)
4. 수동 검토 필요 항목 리스트업

### 예시: Before → After

**Before** (일관성 없는 버튼)
```dart
ElevatedButton(
  onPressed: _handleSave,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFFF6B6B),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  child: Text('저장'),
)
```

**After** (디자인 시스템 적용)
```dart
DSButton(
  label: '저장',
  onPressed: _handleSave,
  variant: DSButtonVariant.primary,
  size: DSButtonSize.medium,
)
```

### 리팩토링 레포트
```markdown
## UI Refactor Report

### Automated Changes
- ✅ `medication_list_screen.dart`: 3 buttons → DSButton
- ✅ `dose_record_screen.dart`: 2 cards → DSCard
- ✅ `profile_screen.dart`: 1 text field → DSTextField

### Manual Review Required
- ⚠️ `settings_screen.dart`: Custom switch widget (no DS equivalent)
- ⚠️ `chart_screen.dart`: Complex chart layout (out of scope)

### Breaking Changes
- None (100% backward compatible)

### Test Status
- ✅ All existing widget tests passing
- ✅ No runtime errors detected
```

### 실행 방법
```bash
claude-code "UI Refactor 에이전트로 medication_list_screen.dart를 디자인 시스템으로 마이그레이션해줘"
```

---

## 5. Design System Documenter Agent

### 목적
Storybook 스타일의 인터랙티브 문서를 자동 생성합니다.

### 출력: `docs/design-system.md`
```markdown
# GLP-1 Design System

## Color Palette

### Brand Colors
- **Primary**: `#FF6B6B` (사용처: CTA 버튼, 강조 텍스트)
- **Secondary**: `#4ECDC4` (사용처: 보조 액션, 인포 배지)

### Semantic Colors
- **Success**: `#4CAF50` (성공 메시지, 완료 상태)
- **Error**: `#F44336` (에러 메시지, 삭제 액션)
- **Warning**: `#FF9800` (경고 메시지)

## Typography Scale

| Name      | Size | Weight  | Usage                  |
|-----------|------|---------|------------------------|
| Heading 1 | 32px | Bold    | 페이지 타이틀          |
| Heading 2 | 24px | SemiBold| 섹션 타이틀            |
| Body      | 16px | Regular | 본문 텍스트            |
| Caption   | 14px | Regular | 보조 설명              |

## Components

### DSButton

**Usage**
```dart
DSButton(
  label: '저장',
  onPressed: () {},
  variant: DSButtonVariant.primary,
  size: DSButtonSize.medium,
)
```

**Variants**
- Primary: 주요 액션 (예: 저장, 확인)
- Secondary: 보조 액션 (예: 취소, 뒤로가기)
- Outline: 비강조 액션 (예: 더보기)
- Ghost: 텍스트 버튼 (예: 건너뛰기)

**States**
- Default
- Hover (웹)
- Pressed
- Disabled
- Loading

### DSCard
...
```

### 출력: 인터랙티브 데모 앱
```dart
// lib/design_system_demo.dart
// flutter run -t lib/design_system_demo.dart

void main() {
  runApp(DesignSystemDemo());
}

class DesignSystemDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            _Section(
              title: 'Buttons',
              children: [
                DSButton(label: 'Primary', variant: DSButtonVariant.primary),
                DSButton(label: 'Secondary', variant: DSButtonVariant.secondary),
                DSButton(label: 'Outline', variant: DSButtonVariant.outline),
                DSButton(label: 'Loading', isLoading: true),
                DSButton(label: 'Disabled', onPressed: null),
              ],
            ),
            _Section(
              title: 'Typography',
              children: [
                DSText('Heading 1', style: DSTextStyle.heading1),
                DSText('Body', style: DSTextStyle.body),
                DSText('Caption', style: DSTextStyle.caption),
              ],
            ),
            // ... 다른 컴포넌트들
          ],
        ),
      ),
    );
  }
}
```

### 실행 방법
```bash
claude-code "Design System Documenter 에이전트로 문서와 데모 앱을 생성해줘"
```

---

## 전체 워크플로우 실행

```bash
# 1단계: 전체 파이프라인 실행
claude-code "UI Design System 에이전트 파이프라인을 처음부터 끝까지 실행해줘"

# 2단계: 수동 검토
# - design_tokens.json 확인 및 수정
# - 생성된 컴포넌트 검토

# 3단계: 점진적 마이그레이션
claude-code "높은 우선순위 화면부터 순차적으로 리팩토링해줘"

# 4단계: 데모 앱 확인
flutter run -t lib/design_system_demo.dart
```

---

## 다른 프로젝트에 적용하기

### 1. 설정 파일 복사
```bash
cp .claude/agents/ui-design-system.md {new_project}/.claude/agents/
```

### 2. 프로젝트 컨텍스트 제공
```bash
claude-code "이 프로젝트는 [도메인 설명]. UI Analyzer부터 실행해줘"
```

### 3. 커스터마이징
- `design_tokens.json` 수정 (브랜드 색상 등)
- 필요한 컴포넌트만 선택적으로 생성
- 기존 디자인 가이드 참고 자료 제공

---

## 장점

### 1. 완전 자동화
- 수동 UI Audit 불필요
- 토큰 → 코드 변환 자동화
- 문서 자동 생성

### 2. 일관성 보장
- 단일 소스 (design_tokens.json)
- 타입 안전성 (Dart 코드 생성)
- 컴파일 타임 체크

### 3. 확장 가능
- 새 컴포넌트 추가 용이
- 토큰 수정 시 전체 앱 자동 반영
- 다크 모드 지원 (토큰만 추가)

### 4. 프로젝트 간 재사용
- 에이전트는 프로젝트 독립적
- 토큰 JSON만 교체하면 다른 브랜드 적용 가능
- 컴포넌트 라이브러리 별도 패키지로 추출 가능

---

## 제약사항 및 주의사항

### DO
- ✅ Presentation Layer만 수정
- ✅ 기존 테스트 유지/업데이트
- ✅ 점진적 마이그레이션 (feature 단위)
- ✅ 디자인 토큰 우선 수정 후 코드 재생성

### DON'T
- ❌ Application/Domain/Infrastructure Layer 수정
- ❌ 비즈니스 로직 변경
- ❌ 기존 Provider/Notifier 구조 변경
- ❌ 한 번에 전체 앱 리팩토링 (리스크 높음)

---

## 참고 자료

### 베스트 프랙티스 출처
- [Style Dictionary](https://amzn.github.io/style-dictionary/) - 디자인 토큰 자동화
- [Atomic Design](https://bradfrost.com/blog/post/atomic-web-design/) - 컴포넌트 계층 구조
- [Material Design 3](https://m3.material.io/) - Flutter 기본 디자인 시스템
- [W3C Design Tokens](https://design-tokens.github.io/community-group/) - 토큰 표준

### AI 도구
- UI Auditor (Feedspace) - 무료 UI 분석
- Valido UX Audit - 접근성 체크
- Tokens Studio (Figma) - 디자인 → 코드 동기화

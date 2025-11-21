# Design System Documenter Agent

디자인 시스템의 모든 컴포넌트, 토큰, 사용 방법을 자동으로 문서화하고 인터랙티브 데모 앱을 생성하는 에이전트입니다.

## 입력
- `design_tokens.json`
- `lib/core/design_system/` 내 모든 컴포넌트
- (선택) 사용자 제공 스크린샷

## 출력

### 1. docs/design-system.md
### 2. lib/design_system_demo.dart (실행 가능한 데모 앱)
### 3. docs/design-system-migration-guide.md
### 4. CHANGELOG.md 업데이트

---

## 1. Design System 문서 (docs/design-system.md)

```markdown
# GLP-1 Design System

> 버전: 1.0.0
> 최종 업데이트: 2025-01-21
> 관리자: Development Team

## 목차
1. [개요](#개요)
2. [시작하기](#시작하기)
3. [디자인 토큰](#디자인-토큰)
4. [컴포넌트](#컴포넌트)
5. [레이아웃 가이드](#레이아웃-가이드)
6. [접근성](#접근성)
7. [다크 모드](#다크-모드)
8. [FAQ](#faq)

---

## 개요

GLP-1 Design System은 일관되고 접근 가능한 사용자 경험을 제공하기 위한 디자인 언어입니다.

### 핵심 원칙
1. **일관성**: 모든 화면에서 동일한 시각적 언어
2. **접근성**: WCAG 2.1 AA 기준 준수
3. **확장성**: 새로운 컴포넌트 쉽게 추가
4. **유지보수성**: 토큰 기반 중앙 관리

### 기술 스택
- Framework: Flutter 3.x
- Design Tokens: W3C Standard (JSON)
- Architecture: Atomic Design

---

## 시작하기

### Installation

```dart
// 1. Import design system
import 'package:n06/core/design_system/design_system.dart';

// 2. Apply theme
void main() {
  runApp(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: MyApp(),
    ),
  );
}

// 3. Use components
DSButton(
  label: '저장',
  onPressed: () {},
  variant: DSButtonVariant.primary,
)
```

### 데모 앱 실행

```bash
flutter run -t lib/design_system_demo.dart
```

---

## 디자인 토큰

### Color Palette

#### Brand Colors
주요 브랜드 색상으로 CTA, 강조 요소에 사용됩니다.

| Token | Value | Preview | Usage |
|-------|-------|---------|-------|
| `brandPrimary` | `#FF6B6B` | 🟥 | Primary buttons, Links, Active states |
| `brandSecondary` | `#4ECDC4` | 🟦 | Secondary actions, Info badges |

#### Semantic Colors
의미를 가진 색상으로 피드백, 상태 표시에 사용됩니다.

| Token | Value | Preview | Usage |
|-------|-------|---------|-------|
| `semanticSuccess` | `#4CAF50` | 🟩 | Success messages, Completed |
| `semanticError` | `#F44336` | 🟥 | Error messages, Destructive |
| `semanticWarning` | `#FF9800` | 🟧 | Warning messages, Caution |
| `semanticInfo` | `#2196F3` | 🟦 | Info messages, Tips |

#### Neutral Colors
배경, 텍스트, 경계선 등 중립적인 요소에 사용됩니다.

| Token | Value | Preview |
|-------|-------|---------|
| `neutral50` | `#FAFAFA` | ⬜ |
| `neutral100` | `#F5F5F5` | ⬜ |
| `neutral200` | `#EEEEEE` | ⬜ |
| ... | ... | ... |
| `neutral900` | `#212121` | ⬛ |

**사용 예시:**
```dart
Container(
  color: DesignTokens.neutral100,
  child: DSText(
    'Content',
    color: DesignTokens.neutral900,
  ),
)
```

### Typography

#### Font Family
- **Primary**: Pretendard (한글 + 영문)
- **Monospace**: SF Mono (코드, 숫자)

#### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Heading 1 | 32px | Bold (700) | 1.2 | Page titles |
| Heading 2 | 24px | Semibold (600) | 1.2 | Section titles |
| Heading 3 | 20px | Semibold (600) | 1.5 | Subsection titles |
| Body | 16px | Regular (400) | 1.5 | Main content |
| Body Bold | 16px | Semibold (600) | 1.5 | Emphasized text |
| Caption | 14px | Regular (400) | 1.5 | Secondary info |
| Label | 14px | Medium (500) | 1.5 | Form labels |

**사용 예시:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    DSText('페이지 제목', style: DSTextStyle.heading1),
    SizedBox(height: DesignTokens.spacingMd),
    DSText('본문 내용입니다.', style: DSTextStyle.body),
    DSText('부가 설명', style: DSTextStyle.caption),
  ],
)
```

### Spacing

8pt Grid System을 사용합니다.

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXs` | 4px | 최소 여백, 밀접한 요소 |
| `spacingSm` | 8px | 관련 요소 간 여백 |
| `spacingMd` | 16px | 기본 여백 (가장 많이 사용) |
| `spacingLg` | 24px | 섹션 간 여백 |
| `spacingXl` | 32px | 큰 여백 |
| `spacing2xl` | 48px | 주요 섹션 구분 |

**DO:**
```dart
// ✅ Use tokens
Padding(
  padding: EdgeInsets.all(DesignTokens.spacingMd),
  child: ...
)
```

**DON'T:**
```dart
// ❌ Hard-coded values
Padding(
  padding: EdgeInsets.all(16),
  child: ...
)
```

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSm` | 4px | Small elements (chips, badges) |
| `radiusMd` | 8px | Default (buttons, cards, inputs) |
| `radiusLg` | 12px | Large cards |
| `radiusFull` | 9999px | Pills, circular buttons |

### Shadows

| Token | Elevation | Usage |
|-------|-----------|-------|
| `shadowSm` | 1dp | Subtle elevation |
| `shadowMd` | 4dp | Cards, buttons |
| `shadowLg` | 10dp | Modals, dialogs |

---

## 컴포넌트

### DSButton

Primary 액션, Secondary 액션, Outline, Ghost 스타일을 지원합니다.

#### Variants

**Primary** - 주요 액션 (저장, 확인, 시작)
```dart
DSButton(
  label: '저장',
  onPressed: () {},
  variant: DSButtonVariant.primary,
)
```

**Secondary** - 보조 액션 (취소, 건너뛰기)
```dart
DSButton(
  label: '취소',
  onPressed: () {},
  variant: DSButtonVariant.secondary,
)
```

**Outline** - 비강조 액션 (더보기, 편집)
```dart
DSButton(
  label: '편집',
  onPressed: () {},
  variant: DSButtonVariant.outline,
)
```

**Ghost** - 텍스트 버튼 (링크, 건너뛰기)
```dart
DSButton(
  label: '건너뛰기',
  onPressed: () {},
  variant: DSButtonVariant.ghost,
)
```

#### Sizes

```dart
// Small (32px height)
DSButton(label: 'Small', size: DSButtonSize.small)

// Medium (44px height) - Default
DSButton(label: 'Medium', size: DSButtonSize.medium)

// Large (56px height)
DSButton(label: 'Large', size: DSButtonSize.large)
```

#### States

```dart
// Loading
DSButton(
  label: '저장 중...',
  isLoading: true,
)

// Disabled
DSButton(
  label: '비활성화',
  onPressed: null, // null = disabled
)

// With Icon
DSButton(
  label: '추가',
  icon: Icon(Icons.add),
  onPressed: () {},
)

// Full Width
DSButton(
  label: '계속하기',
  fullWidth: true,
  onPressed: () {},
)
```

#### DO / DON'T

**DO:**
- ✅ 화면당 하나의 Primary 버튼
- ✅ 명확한 액션 동사 사용 (저장, 삭제, 시작)
- ✅ Loading 상태 표시
- ✅ 최소 터치 영역 44x44px

**DON'T:**
- ❌ 여러 개의 Primary 버튼
- ❌ 모호한 레이블 ("확인", "OK")
- ❌ 긴 텍스트 (2줄 이상)
- ❌ 아이콘만 있는 버튼 (Label 필수)

---

### DSText

#### 사용법

```dart
// Heading 1 (페이지 타이틀)
DSText('복용 기록', style: DSTextStyle.heading1)

// Body (본문)
DSText('오늘의 복용 기록을 확인하세요', style: DSTextStyle.body)

// Caption (부가 설명)
DSText('마지막 업데이트: 1시간 전', style: DSTextStyle.caption)

// Custom color
DSText(
  '에러 메시지',
  style: DSTextStyle.body,
  color: DesignTokens.semanticError,
)
```

#### DO / DON'T

**DO:**
- ✅ Semantic 스타일 사용 (heading1, body, caption)
- ✅ 색상은 토큰 사용
- ✅ 계층 구조 유지 (h1 → h2 → h3)

**DON'T:**
- ❌ TextStyle 직접 정의
- ❌ 하드코딩된 색상
- ❌ 계층 건너뛰기 (h1 → h3)

---

### DSTextField

#### 기본 사용

```dart
DSTextField(
  label: '약 이름',
  hint: '약 이름을 입력하세요',
  controller: _controller,
  onChanged: (value) {
    // Handle change
  },
)
```

#### States

```dart
// Error
DSTextField(
  label: '이메일',
  error: '유효한 이메일을 입력하세요',
)

// Disabled
DSTextField(
  label: '읽기 전용',
  enabled: false,
)

// With Icons
DSTextField(
  label: '비밀번호',
  obscureText: true,
  prefixIcon: Icon(Icons.lock),
  suffixIcon: IconButton(
    icon: Icon(Icons.visibility),
    onPressed: _toggleVisibility,
  ),
)
```

---

### DSCard

#### Variants

```dart
// Elevated (기본, 그림자 있음)
DSCard(
  variant: DSCardVariant.elevated,
  child: Text('Content'),
)

// Outlined (테두리만)
DSCard(
  variant: DSCardVariant.outlined,
  child: Text('Content'),
)

// Flat (그림자/테두리 없음)
DSCard(
  variant: DSCardVariant.flat,
  child: Text('Content'),
)
```

#### Interactive

```dart
DSCard(
  onTap: () {
    // Navigate to detail
  },
  child: ListTile(
    title: Text('약 이름'),
    subtitle: Text('복용 시간: 아침'),
  ),
)
```

---

## 레이아웃 가이드

### 화면 구조

```dart
Scaffold(
  appBar: DSAppBar(title: '페이지 제목'),
  body: Padding(
    padding: EdgeInsets.all(DesignTokens.spacingMd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText('섹션 제목', style: DSTextStyle.heading2),
        SizedBox(height: DesignTokens.spacingSm),

        // Content
        DSCard(child: ...),

        Spacer(),

        // CTA at bottom
        DSButton(
          label: '계속하기',
          fullWidth: true,
          onPressed: () {},
        ),
      ],
    ),
  ),
)
```

### 여백 규칙

- **화면 패딩**: 16px (spacingMd)
- **섹션 간**: 24px (spacingLg)
- **관련 요소**: 8px (spacingSm)
- **밀접 요소**: 4px (spacingXs)

---

## 접근성

### 색상 대비
모든 색상 조합은 WCAG 2.1 AA 기준 (4.5:1)을 충족합니다.

| Foreground | Background | Ratio | Pass |
|------------|------------|-------|------|
| textPrimary | backgroundPrimary | 16:1 | ✅ AAA |
| textSecondary | backgroundPrimary | 4.6:1 | ✅ AA |
| brandPrimary | textInverse | 4.5:1 | ✅ AA |

### Semantic Labels

```dart
// ✅ DO
DSButton(
  label: '저장',
  onPressed: _save,
)

// ❌ DON'T (아이콘만)
IconButton(
  icon: Icon(Icons.save),
  onPressed: _save,
)
```

### 터치 영역
최소 44x44px (iOS), 48x48px (Android)

---

## 다크 모드

현재 버전은 Light 모드만 지원합니다.
다크 모드는 v2.0에서 추가 예정입니다.

**준비 사항:**
1. `design_tokens.json`에 dark 토큰 추가
2. `AppTheme.darkTheme()` 구현
3. 자동 전환 지원

---

## FAQ

### Q1: 디자인 시스템에 없는 컴포넌트가 필요하면?
**A:** 먼저 기존 컴포넌트 조합으로 해결 가능한지 확인하세요. 불가능하다면:
1. `#design-system` 채널에 요청
2. 승인 후 `lib/core/design_system/` 에 추가
3. 이 문서 업데이트

### Q2: 토큰 값을 수정하려면?
**A:**
1. `design_tokens.json` 수정
2. `claude-code "design_tokens.json에서 Dart 코드 재생성"`
3. Hot reload로 즉시 반영

### Q3: 기존 화면을 마이그레이션하려면?
**A:** [Migration Guide](design-system-migration-guide.md) 참고

### Q4: 커스텀 스타일이 꼭 필요하면?
**A:** 예외적으로 허용되지만, 다음 경우만:
- 디자인 시스템으로 불가능한 경우
- 팀 리뷰 승인
- 주석으로 사유 명시

---

## 버전 히스토리

### v1.0.0 (2025-01-21)
- 🎉 Initial release
- ✅ Design tokens
- ✅ Core components (Button, Text, Card, TextField)
- ✅ Light theme

### Roadmap
- v1.1.0: 추가 컴포넌트 (Dialog, BottomSheet, Tabs)
- v1.2.0: Animation system
- v2.0.0: Dark mode

---

## 기여하기

디자인 시스템 개선 제안은 언제나 환영합니다!

1. GitHub Issue 생성
2. 제안 내용 + 사용 사례 설명
3. 팀 검토 후 반영

---

## 지원

- 📧 Email: dev-team@example.com
- 💬 Slack: #design-system
- 📖 Docs: [Notion Design System](link)
```

---

## 2. 인터랙티브 데모 앱 (lib/design_system_demo.dart)

```dart
// flutter run -t lib/design_system_demo.dart

import 'package:flutter/material.dart';
import 'package:n06/core/design_system/design_system.dart';

void main() {
  runApp(const DesignSystemDemo());
}

class DesignSystemDemo extends StatelessWidget {
  const DesignSystemDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Demo',
      theme: AppTheme.lightTheme(),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLP-1 Design System'),
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignTokens.spacingMd),
        children: [
          _buildSection(
            title: 'Colors',
            child: _ColorPalette(),
          ),
          _buildSection(
            title: 'Typography',
            child: _TypographyExamples(),
          ),
          _buildSection(
            title: 'Buttons',
            child: _ButtonExamples(),
          ),
          _buildSection(
            title: 'Text Fields',
            child: _TextFieldExamples(),
          ),
          _buildSection(
            title: 'Cards',
            child: _CardExamples(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText(title, style: DSTextStyle.heading2),
        SizedBox(height: DesignTokens.spacingSm),
        child,
        SizedBox(height: DesignTokens.spacing2xl),
      ],
    );
  }
}

class _ColorPalette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DesignTokens.spacingSm,
      runSpacing: DesignTokens.spacingSm,
      children: [
        _colorSwatch('Primary', DesignTokens.brandPrimary),
        _colorSwatch('Secondary', DesignTokens.brandSecondary),
        _colorSwatch('Success', DesignTokens.semanticSuccess),
        _colorSwatch('Error', DesignTokens.semanticError),
        _colorSwatch('Warning', DesignTokens.semanticWarning),
      ],
    );
  }

  Widget _colorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            boxShadow: DesignTokens.shadowSm,
          ),
        ),
        SizedBox(height: DesignTokens.spacingXs),
        DSText(label, style: DSTextStyle.caption),
      ],
    );
  }
}

class _TypographyExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText('Heading 1', style: DSTextStyle.heading1),
        DSText('Heading 2', style: DSTextStyle.heading2),
        DSText('Heading 3', style: DSTextStyle.heading3),
        DSText('Body text', style: DSTextStyle.body),
        DSText('Body Bold text', style: DSTextStyle.bodyBold),
        DSText('Caption text', style: DSTextStyle.caption),
      ],
    );
  }
}

class _ButtonExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSButton(label: 'Primary', variant: DSButtonVariant.primary, onPressed: () {}),
        SizedBox(height: DesignTokens.spacingSm),
        DSButton(label: 'Secondary', variant: DSButtonVariant.secondary, onPressed: () {}),
        SizedBox(height: DesignTokens.spacingSm),
        DSButton(label: 'Outline', variant: DSButtonVariant.outline, onPressed: () {}),
        SizedBox(height: DesignTokens.spacingSm),
        DSButton(label: 'Ghost', variant: DSButtonVariant.ghost, onPressed: () {}),
        SizedBox(height: DesignTokens.spacingSm),
        DSButton(label: 'Loading', isLoading: true),
        SizedBox(height: DesignTokens.spacingSm),
        DSButton(label: 'Disabled', onPressed: null),
      ],
    );
  }
}

class _TextFieldExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSTextField(
          label: '기본 입력',
          hint: '내용을 입력하세요',
        ),
        SizedBox(height: DesignTokens.spacingMd),
        DSTextField(
          label: '에러 상태',
          hint: '이메일',
          error: '유효한 이메일을 입력하세요',
        ),
        SizedBox(height: DesignTokens.spacingMd),
        DSTextField(
          label: '비활성화',
          enabled: false,
        ),
      ],
    );
  }
}

class _CardExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSCard(
          variant: DSCardVariant.elevated,
          child: DSText('Elevated Card', style: DSTextStyle.body),
        ),
        SizedBox(height: DesignTokens.spacingMd),
        DSCard(
          variant: DSCardVariant.outlined,
          child: DSText('Outlined Card', style: DSTextStyle.body),
        ),
        SizedBox(height: DesignTokens.spacingMd),
        DSCard(
          variant: DSCardVariant.flat,
          child: DSText('Flat Card', style: DSTextStyle.body),
        ),
      ],
    );
  }
}
```

---

## 3. Migration Guide (docs/design-system-migration-guide.md)

(별도 파일, 기존 화면을 디자인 시스템으로 마이그레이션하는 상세 가이드)

---

## 실행 방법

```bash
claude-code "Design System Documenter 에이전트로 전체 문서와 데모 앱을 생성해줘"
```

## 출력 요약

```
📚 Design System 문서 생성 완료

Generated Files:
✅ docs/design-system.md (15,000 words)
   - Overview, Tokens, Components, Guidelines
✅ lib/design_system_demo.dart (인터랙티브 데모)
✅ docs/design-system-migration-guide.md
✅ CHANGELOG.md 업데이트

Demo App:
🚀 flutter run -t lib/design_system_demo.dart

다음 단계:
1. 문서 검토 및 팀 공유
2. 데모 앱으로 컴포넌트 확인
3. Migration Guide에 따라 기존 화면 마이그레이션 시작
```

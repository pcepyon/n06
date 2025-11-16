# Design System 현대화 제안서

## 현재 상태 분석

### 문제점
- 기본 Material 3 테마만 사용 (`ColorScheme.fromSeed(seedColor: Colors.blue)`)
- 타이포그래피, 스페이싱, 컴포넌트 스타일 가이드 부재
- AI agent가 참고할 수 있는 디자인 토큰 시스템 없음
- 현대적인 앱(Airbnb, TikTok, Toss) 대비 식상한 디자인

## 2025 디자인 트렌드 분석

### 주요 트렌드
1. **Neubrutalism + 3D Design**: 평면과 입체의 조화, 미묘한 그림자와 하이라이트
2. **Rounded Edges**: 부드럽고 친근한 모서리 (사용자 친화적)
3. **Bold Typography**: 강한 시각적 존재감, 브랜드 아이덴티티 강화
4. **Hyper-Personalization**: AI 기반 개인화된 마이크로 인터랙션
5. **Dynamic Color**: Material 3의 동적 색상 시스템

### 벤치마크 앱 특징

#### Airbnb (2025)
- 3D 아이콘, 모던 스큐어모피즘
- Bold Typography로 브랜드 강화
- Fluid motion design (부드러운 전환)
- 개인화된 대시보드 (no two dashboards are the same)

#### Toss
- 강렬한 컬러 시스템 (브랜드 블루)
- 명확한 위계 구조의 타이포그래피
- 마이크로 인터랙션 (haptic feedback, 애니메이션)
- 최소한의 인터페이스, 최대한의 정보

## AI Agent 기반 개발을 위한 제안

### Option 1: Claude Skill 생성 (추천 ⭐)

**방식**: `.claude/skills/design-system.md` 파일 생성

**장점**:
- 재사용 가능한 스킬로 모든 AI agent가 사용
- 단일 명령어로 디자인 가이드 적용 가능
- 문서화 + 실행 가능한 템플릿 제공
- 프로젝트에 커밋되어 팀 전체가 공유

**구조**:
```markdown
# Design System Skill

## 목적
Flutter 앱의 현대적인 디자인 시스템 적용

## 사용법
/design-system [component-name]

## Design Tokens
- Colors
- Typography
- Spacing
- Shadows
- Radius

## Component Templates
- 버튼, 카드, 입력 필드 등
```

### Option 2: Sub Agent 생성

**방식**: CLAUDE.md에 전용 agent 타입 정의

**장점**:
- 복잡한 디자인 작업에 특화
- 다단계 디자인 리뷰 가능
- 디자인 일관성 자동 검증

**단점**:
- 설정이 복잡함
- 간단한 작업에는 오버헤드

### Option 3: Design Token 파일 시스템 (보조 수단)

**방식**: `lib/core/design/` 폴더에 Dart 상수 파일

**장점**:
- Type-safe 디자인 토큰
- IDE 자동완성 지원
- 컴파일 타임 검증

**필수 파일**:
- `design_tokens.dart` - 색상, 크기, 간격
- `app_theme.dart` - ThemeData 통합
- `typography.dart` - 텍스트 스타일
- `spacing.dart` - 레이아웃 간격

## 추천 구현 방안

### Phase 1: Design Token 시스템 구축 (필수)
```
lib/core/design/
├── tokens/
│   ├── colors.dart           # 색상 팔레트
│   ├── typography.dart        # 텍스트 스타일
│   ├── spacing.dart           # 간격 시스템
│   ├── shadows.dart           # 그림자
│   └── radius.dart            # 모서리 반경
├── theme/
│   ├── app_theme.dart         # ThemeData 통합
│   └── component_themes.dart  # 개별 컴포넌트 테마
└── widgets/
    └── design_system_preview.dart  # 디자인 토큰 미리보기 화면
```

### Phase 2: Claude Skill 생성 (추천)
```
.claude/skills/
└── design-system.md           # 디자인 시스템 적용 가이드
```

### Phase 3: 컴포넌트 라이브러리
```
lib/core/design/components/
├── buttons/
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   └── text_button.dart
├── cards/
│   ├── info_card.dart
│   └── action_card.dart
└── inputs/
    ├── text_field.dart
    └── search_field.dart
```

## 구체적인 디자인 시스템 스펙

### Color System (Material 3 + Custom)
```dart
// Seed Color from brand (예: 건강한 녹색)
final seedColor = Color(0xFF4CAF50);

// Generated scheme
ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
  // Custom accents
  primary: Color(0xFF4CAF50),      // 주요 액션
  secondary: Color(0xFF2196F3),    // 보조 액션
  tertiary: Color(0xFFFF9800),     // 강조
  error: Color(0xFFE53935),        // 경고/에러
  surface: Color(0xFFFAFAFA),      // 배경
  onPrimary: Colors.white,
);
```

### Typography Scale
```dart
// Display - 큰 헤더 (Bold)
displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700)
displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700)
displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700)

// Headline - 섹션 헤더 (SemiBold)
headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)
headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)
headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)

// Title - 카드 제목 (Medium)
titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)
titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)

// Body - 본문 (Regular)
bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)
bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)
bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)

// Label - 라벨/버튼 (Medium)
labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)
```

### Spacing System (8pt Grid)
```dart
class Spacing {
  static const double xs = 4.0;    // 최소 간격
  static const double sm = 8.0;    // 작은 간격
  static const double md = 16.0;   // 기본 간격
  static const double lg = 24.0;   // 큰 간격
  static const double xl = 32.0;   // 매우 큰 간격
  static const double xxl = 48.0;  // 섹션 간격
}
```

### Border Radius (Rounded Edges Trend)
```dart
class AppRadius {
  static const double sm = 8.0;    // 작은 요소
  static const double md = 12.0;   // 버튼, 카드
  static const double lg = 16.0;   // 큰 카드
  static const double xl = 24.0;   // 모달, 시트
  static const double full = 999.0; // 완전히 둥근 (pill)
}
```

### Shadows (Neubrutalism Influence)
```dart
class AppShadows {
  // 미묘한 그림자 (Neubrutalism)
  static const subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // 부드러운 그림자 (카드)
  static const soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // 강한 그림자 (모달)
  static const strong = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
```

## AI Agent 활용 전략

### Claude Skill 사용 예시
```bash
# 버튼 컴포넌트 생성
/design-system button primary

# 카드 레이아웃 생성
/design-system card info

# 디자인 토큰 적용
/design-system apply-tokens [file-path]

# 디자인 일관성 검증
/design-system validate
```

### Skill 내부 로직
1. **Template 생성**: 미리 정의된 컴포넌트 템플릿 사용
2. **Token 적용**: Design Token 자동 삽입
3. **검증**: 디자인 가이드 준수 여부 체크
4. **문서화**: 컴포넌트 사용법 자동 생성

## 구현 우선순위

### 1단계 (즉시 시작 가능)
- [ ] `lib/core/design/tokens/` 디렉토리 생성
- [ ] 색상, 타이포그래피, 간격 토큰 정의
- [ ] `app_theme.dart`로 통합
- [ ] `main.dart`에서 새 테마 적용

### 2단계 (병렬 진행)
- [ ] `.claude/skills/design-system.md` 스킬 생성
- [ ] 기본 컴포넌트 템플릿 작성
- [ ] 디자인 미리보기 화면 생성

### 3단계 (점진적 적용)
- [ ] 기존 화면에 새 디자인 시스템 적용
- [ ] 컴포넌트 라이브러리 확장
- [ ] 애니메이션 및 마이크로 인터랙션 추가

## 참고 자료

### Flutter 공식
- [Material Design 3](https://m3.material.io/develop/flutter)
- [Flutter Theming Guide](https://docs.flutter.dev/cookbook/design/themes)
- [ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)

### 디자인 트렌드
- [2025 Mobile App Design Trends](https://spdload.com/blog/mobile-app-ui-ux-design-trends/)
- [Neubrutalism Design](https://www.bloomberg.com/news/articles/2025-06-13/apple-airbnb-ditch-flat-app-icons-for-new-3d-ui-design)

### 벤치마크 UI Kit
- [Airbnb UI Kit](https://figr.design/blog/best-ui-kits-for-2025-inspired-by-duolingo-tiktok-airbnb-and-more)
- [Material 3 Components](https://m3.material.io/components)

## 다음 단계

어떤 방식으로 진행하실지 선택해주세요:

1. **빠른 시작**: Design Token 파일부터 생성 (바로 코딩 시작)
2. **자동화 우선**: Claude Skill 먼저 만들고 토큰 생성 자동화
3. **단계적 접근**: 디자인 토큰 → 스킬 → 컴포넌트 순차 진행

선택하시면 즉시 구현을 시작하겠습니다!

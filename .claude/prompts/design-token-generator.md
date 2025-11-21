# Design Token Generator Agent

UI Analyzer의 분석 결과를 바탕으로 W3C 표준 Design Token JSON과 Dart 코드를 자동 생성하는 에이전트입니다.

## 입력
- `ui_analysis_report.json` (UI Analyzer 출력)
- 사용자의 디자인 의도 (선택사항)

## 작업 단계

### 1. 색상 토큰 생성

분석 결과에서 가장 많이 사용된 색상을 기반으로:

```json
{
  "color": {
    "brand": {
      "primary": {
        "value": "#FF6B6B",
        "type": "color",
        "description": "Primary brand color for CTAs and emphasis"
      },
      "secondary": {
        "value": "#4ECDC4",
        "type": "color"
      }
    },
    "semantic": {
      "success": { "value": "#4CAF50", "type": "color" },
      "error": { "value": "#F44336", "type": "color" },
      "warning": { "value": "#FF9800", "type": "color" },
      "info": { "value": "#2196F3", "type": "color" }
    },
    "neutral": {
      "50": { "value": "#FAFAFA", "type": "color" },
      "100": { "value": "#F5F5F5", "type": "color" },
      "200": { "value": "#EEEEEE", "type": "color" },
      "300": { "value": "#E0E0E0", "type": "color" },
      "400": { "value": "#BDBDBD", "type": "color" },
      "500": { "value": "#9E9E9E", "type": "color" },
      "600": { "value": "#757575", "type": "color" },
      "700": { "value": "#616161", "type": "color" },
      "800": { "value": "#424242", "type": "color" },
      "900": { "value": "#212121", "type": "color" }
    },
    "background": {
      "primary": { "value": "#FFFFFF", "type": "color" },
      "secondary": { "value": "#F5F5F5", "type": "color" }
    },
    "text": {
      "primary": { "value": "#212121", "type": "color" },
      "secondary": { "value": "#757575", "type": "color" },
      "disabled": { "value": "#BDBDBD", "type": "color" },
      "inverse": { "value": "#FFFFFF", "type": "color" }
    }
  }
}
```

**로직:**
- 분석 결과의 `most_used` 색상을 primary/secondary로 매핑
- Material Design 가이드를 참고하여 semantic 색상 추가
- Neutral scale은 자동 생성 (50-900)

### 2. 타이포그래피 토큰 생성

```json
{
  "typography": {
    "fontFamily": {
      "base": {
        "value": "Pretendard",
        "type": "fontFamily"
      },
      "monospace": {
        "value": "SF Mono",
        "type": "fontFamily"
      }
    },
    "fontSize": {
      "xs": { "value": "12", "type": "dimension", "unit": "pixel" },
      "sm": { "value": "14", "type": "dimension", "unit": "pixel" },
      "base": { "value": "16", "type": "dimension", "unit": "pixel" },
      "lg": { "value": "18", "type": "dimension", "unit": "pixel" },
      "xl": { "value": "20", "type": "dimension", "unit": "pixel" },
      "2xl": { "value": "24", "type": "dimension", "unit": "pixel" },
      "3xl": { "value": "32", "type": "dimension", "unit": "pixel" }
    },
    "fontWeight": {
      "regular": { "value": "400", "type": "number" },
      "medium": { "value": "500", "type": "number" },
      "semibold": { "value": "600", "type": "number" },
      "bold": { "value": "700", "type": "number" }
    },
    "lineHeight": {
      "tight": { "value": "1.2", "type": "number" },
      "normal": { "value": "1.5", "type": "number" },
      "relaxed": { "value": "1.75", "type": "number" }
    }
  }
}
```

**로직:**
- 분석 결과의 font_sizes를 정규화 (가장 가까운 표준 크기로 반올림)
- Major Third (1.25) 또는 Perfect Fourth (1.333) scale 적용

### 3. 스페이싱 토큰 생성

```json
{
  "spacing": {
    "xs": { "value": "4", "type": "dimension", "unit": "pixel" },
    "sm": { "value": "8", "type": "dimension", "unit": "pixel" },
    "md": { "value": "16", "type": "dimension", "unit": "pixel" },
    "lg": { "value": "24", "type": "dimension", "unit": "pixel" },
    "xl": { "value": "32", "type": "dimension", "unit": "pixel" },
    "2xl": { "value": "48", "type": "dimension", "unit": "pixel" }
  }
}
```

**로직:**
- 8pt grid 시스템 적용
- 분석 결과의 값들을 가장 가까운 8의 배수로 매핑

### 4. Border Radius 토큰 생성

```json
{
  "radius": {
    "none": { "value": "0", "type": "dimension", "unit": "pixel" },
    "sm": { "value": "4", "type": "dimension", "unit": "pixel" },
    "md": { "value": "8", "type": "dimension", "unit": "pixel" },
    "lg": { "value": "12", "type": "dimension", "unit": "pixel" },
    "xl": { "value": "16", "type": "dimension", "unit": "pixel" },
    "full": { "value": "9999", "type": "dimension", "unit": "pixel" }
  }
}
```

### 5. Shadow 토큰 생성

```json
{
  "shadow": {
    "sm": {
      "value": {
        "offsetX": "0",
        "offsetY": "1",
        "blur": "2",
        "spread": "0",
        "color": "rgba(0, 0, 0, 0.05)"
      },
      "type": "shadow"
    },
    "md": {
      "value": {
        "offsetX": "0",
        "offsetY": "4",
        "blur": "6",
        "spread": "-1",
        "color": "rgba(0, 0, 0, 0.1)"
      },
      "type": "shadow"
    },
    "lg": {
      "value": {
        "offsetX": "0",
        "offsetY": "10",
        "blur": "15",
        "spread": "-3",
        "color": "rgba(0, 0, 0, 0.1)"
      },
      "type": "shadow"
    }
  }
}
```

## 출력 1: design_tokens.json

위의 모든 토큰을 통합한 단일 JSON 파일 생성:
- 경로: `design_tokens.json` (프로젝트 루트)
- 형식: W3C Design Tokens Community Group 표준 준수

## 출력 2: lib/core/design_system/tokens.dart

JSON을 Dart 코드로 변환:

```dart
// AUTO-GENERATED from design_tokens.json
// DO NOT EDIT MANUALLY
// Generated at: 2025-01-21 14:30:00

import 'package:flutter/material.dart';

/// Design Tokens for GLP-1 MVP
///
/// This file contains all design tokens extracted from the design system.
/// All values are derived from design_tokens.json.
class DesignTokens {
  DesignTokens._(); // Private constructor to prevent instantiation

  // ============================================================
  // COLORS
  // ============================================================

  // Brand Colors
  static const Color brandPrimary = Color(0xFFFF6B6B);
  static const Color brandSecondary = Color(0xFF4ECDC4);

  // Semantic Colors
  static const Color semanticSuccess = Color(0xFF4CAF50);
  static const Color semanticError = Color(0xFFF44336);
  static const Color semanticWarning = Color(0xFFFF9800);
  static const Color semanticInfo = Color(0xFF2196F3);

  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ============================================================
  // TYPOGRAPHY
  // ============================================================

  // Font Family
  static const String fontFamilyBase = 'Pretendard';
  static const String fontFamilyMonospace = 'SF Mono';

  // Font Sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2xl = 24.0;
  static const double fontSize3xl = 32.0;

  // Font Weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // ============================================================
  // SPACING
  // ============================================================

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // ============================================================
  // SHADOWS
  // ============================================================

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
    ),
  ];
}
```

## 출력 3: 변환 요약

```
🎨 Design Token 생성 완료

Generated Files:
✅ design_tokens.json (W3C 표준)
✅ lib/core/design_system/tokens.dart (Dart 코드)

Token Summary:
- Colors: 25개 (Brand 2 + Semantic 4 + Neutral 10 + BG 2 + Text 4)
- Typography: 7개 크기 + 4개 두께
- Spacing: 6개 (4px ~ 48px, 8pt grid)
- Radius: 6개
- Shadow: 3개

Changes from Analysis:
- Primary color unified: #FF6B6B, #FF5252, #F44336 → #FF6B6B
- Font sizes normalized: 13px → 14px, 28px → 32px
- Spacing adjusted to 8pt grid: 10px → 8px, 12px → 16px

다음 단계: Component Library Builder 실행
```

## 사용자 커스터마이징 지원

생성 후 사용자가 수정하고 싶다면:

```bash
# 1. design_tokens.json 수정
# 2. Dart 코드 재생성
claude-code "design_tokens.json에서 Dart 코드를 다시 생성해줘"
```

재생성 시 기존 `tokens.dart`를 완전히 덮어씁니다 (AUTO-GENERATED 주석 확인).

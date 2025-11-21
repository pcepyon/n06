# Component Library Builder Agent

Design Tokens를 기반으로 Atomic Design 원칙에 따라 재사용 가능한 컴포넌트 라이브러리를 생성하는 에이전트입니다.

## 입력
- `lib/core/design_system/tokens.dart`
- 생성할 컴포넌트 목록 (기본값: Button, Text, Card, TextField, AppBar, BottomSheet)

## 출력 구조

```
lib/core/design_system/
├── tokens.dart                    # 이미 생성됨 (Design Token Generator)
├── atoms/
│   ├── ds_button.dart
│   ├── ds_text.dart
│   ├── ds_icon.dart
│   ├── ds_spacer.dart
│   └── ds_divider.dart
├── molecules/
│   ├── ds_text_field.dart
│   ├── ds_card.dart
│   ├── ds_list_tile.dart
│   └── ds_chip.dart
├── organisms/
│   ├── ds_app_bar.dart
│   ├── ds_bottom_sheet.dart
│   ├── ds_dialog.dart
│   └── ds_loading_indicator.dart
├── theme/
│   └── app_theme.dart
└── design_system.dart             # Public API (barrel file)
```

---

## 1. Atoms: ds_button.dart

```dart
import 'package:flutter/material.dart';
import '../tokens.dart';

/// Design System Button Component
///
/// Variants:
/// - primary: Main actions (저장, 확인)
/// - secondary: Secondary actions (취소)
/// - outline: Less emphasis (더보기)
/// - ghost: Text-only button (건너뛰기)
///
/// Sizes:
/// - small: 32px height
/// - medium: 44px height (default)
/// - large: 56px height
enum DSButtonVariant { primary, secondary, outline, ghost }
enum DSButtonSize { small, medium, large }

class DSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;

  const DSButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final sizing = _getSizing();

    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        disabledBackgroundColor: DesignTokens.neutral200,
        disabledForegroundColor: DesignTokens.textDisabled,
        elevation: variant == DSButtonVariant.ghost ? 0 : 2,
        shadowColor: Colors.black26,
        padding: EdgeInsets.symmetric(
          horizontal: sizing.paddingHorizontal,
          vertical: sizing.paddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          side: variant == DSButtonVariant.outline
              ? BorderSide(color: DesignTokens.brandPrimary, width: 1.5)
              : BorderSide.none,
        ),
        minimumSize: Size(0, sizing.height),
      ),
      child: isLoading
          ? SizedBox(
              height: sizing.loaderSize,
              width: sizing.loaderSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
              ),
            )
          : Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: DesignTokens.spacingSm),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: sizing.fontSize,
                    fontWeight: DesignTokens.fontWeightSemibold,
                    fontFamily: DesignTokens.fontFamilyBase,
                  ),
                ),
              ],
            ),
    );

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case DSButtonVariant.primary:
        return _ButtonColors(
          background: DesignTokens.brandPrimary,
          foreground: DesignTokens.textInverse,
        );
      case DSButtonVariant.secondary:
        return _ButtonColors(
          background: DesignTokens.brandSecondary,
          foreground: DesignTokens.textInverse,
        );
      case DSButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: DesignTokens.brandPrimary,
        );
      case DSButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: DesignTokens.brandPrimary,
        );
    }
  }

  _ButtonSizing _getSizing() {
    switch (size) {
      case DSButtonSize.small:
        return _ButtonSizing(
          height: 32,
          paddingHorizontal: DesignTokens.spacingSm,
          paddingVertical: DesignTokens.spacingXs,
          fontSize: DesignTokens.fontSizeSm,
          loaderSize: 16,
        );
      case DSButtonSize.medium:
        return _ButtonSizing(
          height: 44,
          paddingHorizontal: DesignTokens.spacingMd,
          paddingVertical: DesignTokens.spacingSm,
          fontSize: DesignTokens.fontSizeBase,
          loaderSize: 20,
        );
      case DSButtonSize.large:
        return _ButtonSizing(
          height: 56,
          paddingHorizontal: DesignTokens.spacingLg,
          paddingVertical: DesignTokens.spacingMd,
          fontSize: DesignTokens.fontSizeLg,
          loaderSize: 24,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  _ButtonColors({required this.background, required this.foreground});
}

class _ButtonSizing {
  final double height;
  final double paddingHorizontal;
  final double paddingVertical;
  final double fontSize;
  final double loaderSize;
  _ButtonSizing({
    required this.height,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.fontSize,
    required this.loaderSize,
  });
}
```

---

## 2. Atoms: ds_text.dart

```dart
import 'package:flutter/material.dart';
import '../tokens.dart';

/// Design System Text Component
///
/// Provides semantic text styles:
/// - heading1, heading2, heading3: Page/Section titles
/// - body, bodyBold: Main content
/// - caption: Secondary info
/// - label: Form labels
enum DSTextStyle {
  heading1,
  heading2,
  heading3,
  body,
  bodyBold,
  caption,
  label,
}

class DSText extends StatelessWidget {
  final String text;
  final DSTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const DSText(
    this.text, {
    Key? key,
    this.style = DSTextStyle.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getTextStyle().copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getTextStyle() {
    switch (style) {
      case DSTextStyle.heading1:
        return TextStyle(
          fontSize: DesignTokens.fontSize3xl,
          fontWeight: DesignTokens.fontWeightBold,
          height: DesignTokens.lineHeightTight,
          color: DesignTokens.textPrimary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
      case DSTextStyle.heading2:
        return TextStyle(
          fontSize: DesignTokens.fontSize2xl,
          fontWeight: DesignTokens.fontWeightSemibold,
          height: DesignTokens.lineHeightTight,
          color: DesignTokens.textPrimary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
      case DSTextStyle.heading3:
        return TextStyle(
          fontSize: DesignTokens.fontSizeXl,
          fontWeight: DesignTokens.fontWeightSemibold,
          height: DesignTokens.lineHeightNormal,
          color: DesignTokens.textPrimary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
      case DSTextStyle.body:
        return TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightRegular,
          height: DesignTokens.lineHeightNormal,
          color: DesignTokens.textPrimary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
      case DSTextStyle.bodyBold:
        return TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightSemibold,
          height: DesignTokens.lineHeightNormal,
          color: DesignTokens.textPrimary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
      case DSTextStyle.caption:
        return TextStyle(
          fontSize: DesignTokens.fontSizeSm,
          fontWeight: DesignTokens.fontWeightRegular,
          height: DesignTokens.lineHeightNormal,
          color: DesignTokens.textSecondary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
      case DSTextStyle.label:
        return TextStyle(
          fontSize: DesignTokens.fontSizeSm,
          fontWeight: DesignTokens.fontWeightMedium,
          height: DesignTokens.lineHeightNormal,
          color: DesignTokens.textPrimary,
          fontFamily: DesignTokens.fontFamilyBase,
        );
    }
  }
}
```

---

## 3. Molecules: ds_text_field.dart

```dart
import 'package:flutter/material.dart';
import '../tokens.dart';
import '../atoms/ds_text.dart';

class DSTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;

  const DSTextField({
    Key? key,
    this.label,
    this.hint,
    this.error,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          DSText(
            label!,
            style: DSTextStyle.label,
          ),
          SizedBox(height: DesignTokens.spacingXs),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            fontSize: DesignTokens.fontSizeBase,
            fontFamily: DesignTokens.fontFamilyBase,
            color: DesignTokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: DesignTokens.textSecondary,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: error,
            filled: true,
            fillColor: enabled ? DesignTokens.backgroundSecondary : DesignTokens.neutral100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                color: DesignTokens.neutral300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                color: DesignTokens.neutral300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                color: DesignTokens.brandPrimary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                color: DesignTokens.semanticError,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingMd,
              vertical: DesignTokens.spacingSm,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 4. Molecules: ds_card.dart

```dart
import 'package:flutter/material.dart';
import '../tokens.dart';

enum DSCardVariant { elevated, outlined, flat }

class DSCard extends StatelessWidget {
  final Widget child;
  final DSCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const DSCard({
    Key? key,
    required this.child,
    this.variant = DSCardVariant.elevated,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = _getDecoration();

    Widget card = Container(
      padding: padding ?? EdgeInsets.all(DesignTokens.spacingMd),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case DSCardVariant.elevated:
        return BoxDecoration(
          color: DesignTokens.backgroundPrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          boxShadow: DesignTokens.shadowMd,
        );
      case DSCardVariant.outlined:
        return BoxDecoration(
          color: DesignTokens.backgroundPrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: DesignTokens.neutral300,
            width: 1,
          ),
        );
      case DSCardVariant.flat:
        return BoxDecoration(
          color: DesignTokens.backgroundSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        );
    }
  }
}
```

---

## 5. Public API: design_system.dart

```dart
/// Design System for GLP-1 MVP
///
/// Usage:
/// ```dart
/// import 'package:n06/core/design_system/design_system.dart';
///
/// DSButton(
///   label: '저장',
///   onPressed: () {},
///   variant: DSButtonVariant.primary,
/// )
/// ```
library design_system;

// Tokens
export 'tokens.dart';

// Atoms
export 'atoms/ds_button.dart';
export 'atoms/ds_text.dart';
export 'atoms/ds_icon.dart';
export 'atoms/ds_spacer.dart';
export 'atoms/ds_divider.dart';

// Molecules
export 'molecules/ds_text_field.dart';
export 'molecules/ds_card.dart';
export 'molecules/ds_list_tile.dart';
export 'molecules/ds_chip.dart';

// Organisms
export 'organisms/ds_app_bar.dart';
export 'organisms/ds_bottom_sheet.dart';
export 'organisms/ds_dialog.dart';
export 'organisms/ds_loading_indicator.dart';

// Theme
export 'theme/app_theme.dart';
```

---

## 6. Theme Integration: app_theme.dart

```dart
import 'package:flutter/material.dart';
import '../tokens.dart';

/// App-wide ThemeData using Design Tokens
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: DesignTokens.brandPrimary,
        secondary: DesignTokens.brandSecondary,
        error: DesignTokens.semanticError,
        background: DesignTokens.backgroundPrimary,
        surface: DesignTokens.backgroundSecondary,
      ),

      // Typography
      fontFamily: DesignTokens.fontFamilyBase,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: DesignTokens.fontSize3xl,
          fontWeight: DesignTokens.fontWeightBold,
          color: DesignTokens.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: DesignTokens.fontSize2xl,
          fontWeight: DesignTokens.fontWeightSemibold,
          color: DesignTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: DesignTokens.fontSizeSm,
          fontWeight: DesignTokens.fontWeightRegular,
          color: DesignTokens.textSecondary,
        ),
      ),

      // Component Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      ),

      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        elevation: 2,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.backgroundPrimary,
        foregroundColor: DesignTokens.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
```

---

## 실행 방법

```bash
claude-code "Component Library Builder 에이전트로 Button, Text, TextField, Card 컴포넌트를 생성해줘"
```

## 출력 요약

```
🧩 Component Library 생성 완료

Generated Components:
✅ Atoms (5개)
   - DSButton (4 variants, 3 sizes)
   - DSText (7 semantic styles)
   - DSIcon
   - DSSpacer
   - DSDivider

✅ Molecules (4개)
   - DSTextField (label, error, icons)
   - DSCard (3 variants)
   - DSListTile
   - DSChip

✅ Organisms (4개)
   - DSAppBar
   - DSBottomSheet
   - DSDialog
   - DSLoadingIndicator

✅ Theme
   - AppTheme.lightTheme()

✅ Public API
   - lib/core/design_system/design_system.dart

사용 예시:
```dart
import 'package:n06/core/design_system/design_system.dart';

DSButton(
  label: '저장',
  onPressed: _handleSave,
  variant: DSButtonVariant.primary,
  size: DSButtonSize.medium,
)
```

다음 단계: UI Refactor Agent로 기존 화면 마이그레이션
```

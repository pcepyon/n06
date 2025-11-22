# Gabium Logo - Implementation Guide

**Version:** 1.0
**Last Updated:** 2025-11-22
**Target:** Flutter (GLP-1 MVP)

---

## 🎯 빠른 시작 가이드

### Step 1: 로고 파일 준비

1. **제공된 이미지를 저장**:
   - 이미지 #2 (3D 녹색 큐브)를 다운로드
   - 파일명: `gabium-logo-primary.png`

2. **필요한 사이즈 생성**:
   ```bash
   # ImageMagick 사용 (설치 필요: brew install imagemagick)

   # 1024x1024 (앱 아이콘)
   convert gabium-logo-primary.png -resize 1024x1024 gabium-logo-1024.png

   # 512x512 (스플래시 스크린)
   convert gabium-logo-primary.png -resize 512x512 gabium-logo-512.png

   # 192x192 (UI 요소)
   convert gabium-logo-primary.png -resize 192x192 gabium-logo-192.png
   ```

3. **Flutter 프로젝트에 저장**:
   ```bash
   # GLP-1 MVP 프로젝트 기준
   mkdir -p assets/logos
   cp gabium-logo-*.png assets/logos/
   ```

---

## 📁 Flutter 프로젝트 통합

### 1. pubspec.yaml 설정

```yaml
flutter:
  assets:
    - assets/logos/gabium-logo-primary.png
    - assets/logos/gabium-logo-1024.png
    - assets/logos/gabium-logo-512.png
    - assets/logos/gabium-logo-192.png
```

### 2. 로고 위젯 생성

**파일**: `lib/core/presentation/widgets/gabium_logo.dart`

```dart
import 'package:flutter/material.dart';

/// Gabium 앱의 공식 로고 위젯
///
/// 사용 가이드:
/// - 최소 크기: 32x32px
/// - 여백: 로고 높이의 25% 이상 확보
/// - 배경: 밝은 색상 (#F8FAFC ~ #FFFFFF) 권장
class GabiumLogo extends StatelessWidget {
  /// 로고 크기 (가로/세로 동일)
  final double size;

  /// 애니메이션 활성화 여부 (로딩 상태용)
  final bool animated;

  /// 로고 변형 (기본: primary)
  final LogoVariant variant;

  const GabiumLogo({
    Key? key,
    this.size = 48.0,
    this.animated = false,
    this.variant = LogoVariant.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 최소 크기 검증
    assert(size >= 32.0, 'Logo size must be at least 32px');

    final String assetPath = _getAssetPath();

    Widget logo = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // 애니메이션 래핑
    if (animated) {
      return _AnimatedLogo(
        size: size,
        child: logo,
      );
    }

    return logo;
  }

  String _getAssetPath() {
    switch (variant) {
      case LogoVariant.primary:
        return 'assets/logos/gabium-logo-primary.png';
      case LogoVariant.large:
        return 'assets/logos/gabium-logo-512.png';
      case LogoVariant.medium:
        return 'assets/logos/gabium-logo-192.png';
    }
  }
}

/// 로고 변형 타입
enum LogoVariant {
  primary,  // 기본 (원본 해상도)
  large,    // 512x512 (스플래시용)
  medium,   // 192x192 (UI 요소용)
}

/// 로고 펄스 애니메이션 (로딩 상태)
class _AnimatedLogo extends StatefulWidget {
  final Widget child;
  final double size;

  const _AnimatedLogo({
    required this.child,
    required this.size,
  });

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
```

---

## 🖼️ 사용 예시

### 예시 1: 스플래시 스크린

**파일**: `lib/features/splash/presentation/screens/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:n06/core/presentation/widgets/gabium_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
      body: Center(
        child: GabiumLogo(
          size: 120.0,
          variant: LogoVariant.large,
          animated: true,
        ),
      ),
    );
  }
}
```

### 예시 2: 앱바 (네비게이션 바)

**파일**: `lib/core/presentation/widgets/app_bar_with_logo.dart`

```dart
import 'package:flutter/material.dart';
import 'package:n06/core/presentation/widgets/gabium_logo.dart';

class GabiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;

  const GabiumAppBar({
    Key? key,
    this.title,
    this.actions,
    this.showLogo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showLogo
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: GabiumLogo(
                size: 32.0,
                variant: LogoVariant.medium,
              ),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: Color(0xFF1E293B), // Neutral-800
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFE2E8F0), // Neutral-200
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
```

### 예시 3: 로딩 인디케이터

**파일**: `lib/core/presentation/widgets/loading_overlay.dart`

```dart
import 'package:flutter/material.dart';
import 'package:n06/core/presentation/widgets/gabium_logo.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 펄스 애니메이션 로고
            GabiumLogo(
              size: 80.0,
              variant: LogoVariant.medium,
              animated: true,
            ),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 전역 오버레이로 표시
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingOverlay(message: message),
    );
  }

  /// 오버레이 닫기
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
```

### 예시 4: 온보딩 헤더

**파일**: `lib/features/onboarding/presentation/widgets/onboarding_header.dart`

```dart
import 'package:flutter/material.dart';
import 'package:n06/core/presentation/widgets/gabium_logo.dart';

class OnboardingHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingHeader({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 로고
        GabiumLogo(
          size: 80.0,
          variant: LogoVariant.medium,
        ),
        const SizedBox(height: 24),

        // 제목
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // 부제목
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

---

## 📱 앱 아이콘 설정

### iOS (ios/Runner/Assets.xcassets/AppIcon.appiconset/)

1. **Xcode에서 AppIcon 설정**:
   - Xcode 열기: `ios/Runner.xcworkspace`
   - Assets.xcassets → AppIcon 선택
   - 각 사이즈에 `gabium-logo-1024.png` 드래그

2. **필요한 사이즈**:
   - 1024x1024 (App Store)
   - 180x180 (iPhone @3x)
   - 120x120 (iPhone @2x)
   - 167x167 (iPad Pro)
   - 152x152 (iPad)

### Android (android/app/src/main/res/)

1. **리소스 디렉토리에 배치**:
   ```bash
   # mipmap 디렉토리에 각 해상도별 저장
   cp gabium-logo-1024.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   cp gabium-logo-512.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
   cp gabium-logo-192.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
   ```

2. **android/app/src/main/AndroidManifest.xml**:
   ```xml
   <application
       android:icon="@mipmap/ic_launcher"
       ...
   >
   ```

---

## 🎨 디자인 시스템 토큰 연동

### 로고와 조화로운 색상 사용

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Logo 관련 색상
  static const logoHighlight = Color(0xFF86EFAC); // Green-200
  static const logoPrimary = Color(0xFF4ADE80);   // Green-400 (Primary)
  static const logoShadow = Color(0xFF22C55E);    // Green-500

  // 로고를 배경으로 사용할 때
  static const logoBackground = Color(0xFFF8FAFC); // Neutral-50

  // 로고 여백 색상
  static const logoClearSpace = Colors.transparent;
}
```

### 로고 주변 여백 헬퍼

```dart
// lib/core/utils/logo_spacing.dart

class LogoSpacing {
  /// 로고 크기에 따른 권장 여백 (25%)
  static double getClearSpace(double logoSize) {
    return logoSize * 0.25;
  }

  /// 로고를 감싸는 컨테이너 생성
  static Widget withClearSpace({
    required double logoSize,
    required Widget logo,
  }) {
    final padding = getClearSpace(logoSize);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: logo,
    );
  }
}

// 사용 예시:
LogoSpacing.withClearSpace(
  logoSize: 80.0,
  logo: GabiumLogo(size: 80.0),
)
```

---

## ✅ 체크리스트

로고 적용 후 확인사항:

### 디자인 검증
- [ ] 로고 크기가 32px 이상인가?
- [ ] 주변에 25% 여백이 확보되었는가?
- [ ] 배경색이 밝은 색상(#F8FAFC ~ #FFFFFF)인가?
- [ ] 로고 비율이 1:1로 유지되는가?
- [ ] 회전이나 왜곡이 없는가?

### 기술 검증
- [ ] `pubspec.yaml`에 asset 경로가 등록되었는가?
- [ ] 이미지 파일이 `assets/logos/` 디렉토리에 있는가?
- [ ] 앱을 재실행하여 로고가 정상 표시되는가?
- [ ] 다양한 화면 크기에서 테스트했는가?
- [ ] 다크모드에서도 확인했는가? (배경 대비)

### 성능 검증
- [ ] 이미지 용량이 적절한가? (각 파일 < 100KB 권장)
- [ ] 불필요한 애니메이션이 과도하지 않은가?
- [ ] 로딩 시간이 빠른가?

---

## 🚀 고급 활용

### 1. 동적 색상 변경 (다크모드)

```dart
class AdaptiveLogo extends StatelessWidget {
  final double size;

  const AdaptiveLogo({Key? key, this.size = 48.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // 다크모드에서는 하이라이트 강화
    return Container(
      decoration: brightness == Brightness.dark
          ? BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.3),
              borderRadius: BorderRadius.circular(size * 0.2),
            )
          : null,
      child: GabiumLogo(size: size),
    );
  }
}
```

### 2. 히어로 애니메이션

```dart
// 스플래시 → 메인 화면 전환 시
Hero(
  tag: 'gabium_logo',
  child: GabiumLogo(size: 120.0),
)

// 메인 화면 앱바
Hero(
  tag: 'gabium_logo',
  child: GabiumLogo(size: 32.0),
)
```

### 3. 캐싱 최적화

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // 로고 이미지 사전 캐싱
  precacheImage(
    const AssetImage('assets/logos/gabium-logo-512.png'),
    context,
  );
}
```

---

## 📚 참고 문서

- **로고 가이드라인**: `.claude/skills/ui-renewal/assets/logo-guidelines.md`
- **디자인 시스템**: `.claude/skills/ui-renewal/design-systems/gabium-design-system.md`
- **컴포넌트 라이브러리**: `.claude/skills/ui-renewal/component-library/COMPONENTS.md`

---

**End of Implementation Guide v1.0**

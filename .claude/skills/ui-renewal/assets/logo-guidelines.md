# Gabium Logo Guidelines

**Version:** 1.0
**Last Updated:** 2025-11-22
**Logo Type:** 3D Soft Cube Icon

---

## 1. Logo Overview

### Primary Logo
- **File:** `logos/gabium-logo-primary.png`
- **Style:** 3D soft rounded cube with glossy gradient
- **Color:** Emerald Green (#4ADE80 spectrum)
- **Format:** Square (1:1 aspect ratio)
- **Background:** Light gray/white

### Logo Concept
둥근 모서리의 3D 큐브 형태로, 토스 스타일의 입체감과 부드러움을 반영하면서도 가비움만의 녹색 정체성을 전달합니다.

**상징성:**
- **부드러운 큐브**: 안정감 + 친근함
- **광택 표면**: 희망, 긍정적 미래
- **녹색 그라데이션**: 건강, 성장, 치료 여정
- **3D 입체감**: 새로운 차원의 건강 관리

---

## 2. Logo Variants

### 2.1. 기본 버전들

| Variant | File Name | Size | Usage |
|---------|-----------|------|-------|
| App Icon (1024) | `gabium-logo-1024.png` | 1024x1024px | iOS/Android 앱 아이콘 |
| Large Icon | `gabium-logo-512.png` | 512x512px | 웹, 대형 디스플레이 |
| Medium Icon | `gabium-logo-192.png` | 192x192px | 파비콘, 작은 UI 요소 |
| Transparent BG | `gabium-logo-transparent.png` | Variable | 다양한 배경에 오버레이 |
| White BG | `gabium-logo-white-bg.png` | Variable | 문서, 프레젠테이션 |
| Dark Mode | `gabium-logo-dark-mode.png` | Variable | 다크 테마 UI |

### 2.2. 향후 제작 필요 (선택)

- **Wordmark Version**: 로고 + "GABIUM" 텍스트 (가로 배치)
- **Monochrome**: 흑백 버전 (인쇄물용)
- **Favicon**: 16x16px, 32x32px ICO 파일

---

## 3. Usage Guidelines

### 3.1. 앱 내 사용 위치

#### ✅ 필수 위치
1. **앱 아이콘** (홈 스크린)
   - File: `gabium-logo-1024.png`
   - Platform: iOS, Android

2. **스플래시 스크린**
   - File: `gabium-logo-512.png` (투명 배경)
   - Placement: 화면 중앙, 배경색 #F8FAFC

3. **네비게이션 바** (상단 좌측 또는 중앙)
   - File: `gabium-logo-192.png` (축소)
   - Size: 32x32px ~ 48x48px
   - Placement: 앱바 좌측 또는 타이틀 위치

4. **로딩 인디케이터**
   - File: `gabium-logo-192.png`
   - Animation: 부드러운 페이드 인/아웃 또는 펄스 효과

#### ⚠️ 권장 위치
5. **온보딩 화면**
   - File: `gabium-logo-512.png`
   - Placement: 각 온보딩 페이지 상단

6. **설정 화면 헤더**
   - File: `gabium-logo-192.png`
   - Placement: 프로필 이미지 대체 또는 상단 장식

7. **데이터 공유 모드 워터마크**
   - File: `gabium-logo-192.png` (반투명)
   - Opacity: 15-20%
   - Placement: 화면 우측 하단 또는 좌측 상단

#### ❌ 사용 금지 위치
- 버튼 내부 (대신 아이콘 사용)
- 밀집된 리스트 아이템
- 경고/에러 다이얼로그 (의료적 심각성 감소)

---

### 3.2. 크기 및 여백 규정

#### Minimum Clear Space
로고 주변에 최소 여백을 확보하여 시각적 혼잡함 방지:

```
┌─────────────────────┐
│                     │
│    [  LOGO  ]       │  ← 로고 높이의 25% 이상 여백
│                     │
└─────────────────────┘
```

#### Minimum Size
- **디지털**: 32x32px 이하로 축소 금지
- **인쇄**: 10mm x 10mm 이하로 축소 금지

---

### 3.3. 배경 규정

#### ✅ 적합한 배경
- **Light Mode**: 흰색 (#FFFFFF), 밝은 회색 (#F8FAFC ~ #F1F5F9)
- **Dark Mode**: 어두운 회색 (#1E293B ~ #0F172A)
- **투명 배경**: 어떤 배경에도 오버레이 가능

#### ❌ 부적합한 배경
- 로고와 유사한 녹색 배경 (대비 부족)
- 패턴이 복잡한 배경 (가독성 저하)
- 너무 밝은 흰색 배경에 어두운 로고 (역광 효과)

---

### 3.4. 금지 사항

#### ❌ 절대 하지 말 것

1. **변형 금지**
   - 로고 비율 왜곡 (찌그러뜨림)
   - 회전 (90도, 180도 등)
   - 기울임 (Skew)

2. **색상 변경 금지**
   - 녹색 이외의 색상으로 변경
   - 그라데이션 방향 변경
   - 색상 반전 (녹색 → 빨간색 등)

3. **효과 추가 금지**
   - 외곽선(Stroke) 추가
   - 드롭 섀도우 과도하게 추가
   - 텍스트 오버레이
   - 필터 효과 (블러, 노이즈 등)

4. **잘라내기 금지**
   - 로고의 일부만 사용
   - 모서리 자르기

---

## 4. Color Specifications

### 4.1. 로고 색상 분석

이 로고는 **그라데이션 녹색**을 사용하며, 디자인 시스템의 Primary Color를 기반으로 합니다.

| Area | Approximate Color | Design System Token |
|------|-------------------|---------------------|
| Highlight (상단 밝은 부분) | #6EE7B7 ~ #86EFAC | Green-300 ~ Green-200 |
| Main Surface | #4ADE80 | color.primary (Green-400) |
| Shadow (하단 어두운 부분) | #22C55E ~ #16A34A | Green-500 ~ Green-600 |

### 4.2. 색상 추출 가이드

프로젝트에서 로고와 조화로운 UI 요소를 만들 때:

```dart
// Flutter 예시
const Color logoHighlight = Color(0xFF86EFAC);
const Color logoPrimary = Color(0xFF4ADE80);
const Color logoShadow = Color(0xFF22C55E);
```

```css
/* CSS 예시 */
--logo-highlight: #86EFAC;
--logo-primary: #4ADE80;
--logo-shadow: #22C55E;
```

---

## 5. Platform-Specific Guidelines

### 5.1. iOS

#### App Icon
- **File**: `gabium-logo-1024.png`
- **Format**: PNG (no alpha for app icon)
- **Sizes Needed**:
  - 1024x1024 (App Store)
  - 180x180 (iPhone)
  - 167x167 (iPad Pro)
  - 152x152 (iPad)
  - 120x120 (iPhone small)

#### Considerations
- iOS는 자동으로 둥근 모서리 적용하므로 정사각형 이미지 사용
- Safe area 고려 (테두리에서 10% 안쪽 여백)

### 5.2. Android

#### App Icon (Adaptive)
- **File**: `gabium-logo-1024.png`
- **Format**: PNG with transparency
- **Sizes Needed**:
  - 512x512 (Play Store)
  - 192x192 (xxxhdpi)
  - 144x144 (xxhdpi)
  - 96x96 (xhdpi)
  - 72x72 (hdpi)
  - 48x48 (mdpi)

#### Adaptive Icon Layers
```
foreground.png: 로고 (투명 배경, 안전 영역 66% 내부)
background.png: 단색 #4ADE80 또는 그라데이션
```

### 5.3. Web

#### Favicon
- **Sizes**: 16x16, 32x32, 48x48
- **Format**: ICO or PNG
- **File**: `favicon.ico` + `gabium-logo-192.png`

#### Web App Manifest
```json
{
  "icons": [
    { "src": "/icons/gabium-logo-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/gabium-logo-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

## 6. Animation Guidelines (Optional)

### 6.1. 허용되는 애니메이션

#### ✅ 권장 효과
1. **페이드 인/아웃** (Fade In/Out)
   - Duration: 300ms
   - Easing: cubic-bezier(0.4, 0, 0.2, 1)

2. **펄스 효과** (Pulse)
   - Scale: 1.0 → 1.05 → 1.0
   - Duration: 1.5s
   - Loop: infinite
   - Use case: 로딩 상태

3. **부드러운 회전** (Gentle Rotation)
   - Rotation: 0° → 360°
   - Duration: 2s
   - Easing: linear
   - Loop: infinite
   - Use case: 데이터 동기화

#### ❌ 금지 효과
- 급격한 회전 (Spin)
- 바운스 (Bounce)
- 흔들림 (Shake)
- 3D 플립 (Flip)

### 6.2. 로딩 애니메이션 예시

```dart
// Flutter 예시: 펄스 효과
AnimatedScale(
  scale: _isPulsing ? 1.05 : 1.0,
  duration: Duration(milliseconds: 600),
  curve: Curves.easeInOut,
  child: Image.asset('assets/logos/gabium-logo-192.png'),
)
```

---

## 7. File Management

### 7.1. 파일 명명 규칙

```
gabium-logo-{variant}-{size}.{ext}

예시:
- gabium-logo-primary-1024.png
- gabium-logo-transparent-512.png
- gabium-logo-dark-192.png
```

### 7.2. 버전 관리

로고 업데이트 시 버전 관리:

```
logos/
  v1/
    gabium-logo-primary.png
  v2/
    gabium-logo-primary.png  (업데이트된 버전)
  current/
    gabium-logo-primary.png  → symlink to v2
```

### 7.3. Asset Path (Flutter)

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/logos/gabium-logo-primary.png
    - assets/logos/gabium-logo-1024.png
    - assets/logos/gabium-logo-512.png
    - assets/logos/gabium-logo-192.png
    - assets/logos/gabium-logo-transparent.png
```

---

## 8. Integration with Design System

### 8.1. Design System 업데이트

`gabium-design-system.md`에 다음 섹션 추가:

```markdown
## 13. Logo & Brand Mark

### Primary Logo
- **Type**: 3D Soft Cube Icon
- **File**: `.claude/skills/ui-renewal/assets/logos/gabium-logo-primary.png`
- **Color**: Emerald Green gradient (#4ADE80 base)
- **Usage**: App icon, splash screen, navigation

### Logo Specifications
- **Aspect Ratio**: 1:1 (square)
- **Minimum Size**: 32x32px (digital), 10mm (print)
- **Clear Space**: 25% of logo height
- **Format**: PNG with transparency

### Integration Points
- App Icon: 1024x1024px
- Splash Screen: 512x512px center-aligned on #F8FAFC background
- Navigation Bar: 32-48px in header
- Loading States: 192px with pulse animation

See: `.claude/skills/ui-renewal/assets/logo-guidelines.md` for detailed guidelines.
```

### 8.2. Component Library 업데이트

새로운 로고 컴포넌트 생성:

```dart
// lib/core/widgets/gabium_logo.dart

class GabiumLogo extends StatelessWidget {
  final double size;
  final LogoVariant variant;
  final bool animated;

  const GabiumLogo({
    Key? key,
    this.size = 48.0,
    this.variant = LogoVariant.primary,
    this.animated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String assetPath = _getAssetPath(variant);

    Widget logo = Image.asset(
      assetPath,
      width: size,
      height: size,
    );

    if (animated) {
      return _AnimatedLogo(child: logo);
    }

    return logo;
  }

  String _getAssetPath(LogoVariant variant) {
    switch (variant) {
      case LogoVariant.primary:
        return 'assets/logos/gabium-logo-primary.png';
      case LogoVariant.transparent:
        return 'assets/logos/gabium-logo-transparent.png';
      case LogoVariant.dark:
        return 'assets/logos/gabium-logo-dark-mode.png';
      default:
        return 'assets/logos/gabium-logo-primary.png';
    }
  }
}

enum LogoVariant { primary, transparent, dark }
```

---

## 9. Quality Checklist

로고를 새로운 곳에 적용하기 전 체크리스트:

- [ ] 로고 크기가 최소 기준(32px) 이상인가?
- [ ] 주변에 25% 여백이 확보되었는가?
- [ ] 배경색이 로고와 충분한 대비를 이루는가?
- [ ] 로고 비율이 왜곡되지 않았는가?
- [ ] 로고가 변형(회전, 기울임)되지 않았는가?
- [ ] 색상이 원본과 일치하는가?
- [ ] 해상도가 적절한가? (흐릿하지 않은가?)
- [ ] 다크모드에서도 확인했는가?

---

## 10. Resources

### 10.1. Download Links

- **Primary Logo**: `.claude/skills/ui-renewal/assets/logos/gabium-logo-primary.png`
- **All Variants**: `.claude/skills/ui-renewal/assets/logos/`
- **Design System**: `.claude/skills/ui-renewal/design-systems/gabium-design-system.md`

### 10.2. Contact

로고 사용 관련 문의 또는 새로운 변형 제작 요청:
- Project: GLP-1 MVP (Gabium)
- Design System Version: 1.0

---

**End of Logo Guidelines v1.0**

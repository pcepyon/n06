# LoginScreen 구현 명세서

**프로젝트:** GLP-1 MVP - LoginScreen UI 갱신
**날짜:** 2025-11-24
**버전:** 1.0
**상태:** Phase 2B (구현 명세)
**설계 시스템:** Gabium v1.0

---

## 1. 설계 토큰 상세 명세

### 1.1 색상 토큰 (28개)

#### Brand 색상
| Token | Hex | RGB | 용도 | Notes |
|-------|-----|-----|------|-------|
| Primary | #4ADE80 | rgb(74, 222, 128) | 주요 CTA, 활성 상태 | 밝은 녹색, WCAG AA |
| Primary-Dark | #22C55E | rgb(34, 197, 94) | 호버 상태 | Primary의 진하게 |
| Primary-Darker | #16A34A | rgb(22, 163, 74) | 눌림 상태 | Primary의 더 진하게 |

#### Social Brand 색상
| Token | Hex | RGB | 용도 | Notes |
|-------|-----|-----|------|-------|
| Kakao | #FEE500 | rgb(254, 229, 0) | 카카오 버튼 배경 | 공식 브랜드 색 |
| Kakao-Text | #000000 | rgb(0, 0, 0) | 카카오 버튼 텍스트 | Black87 |
| Naver | #03C75A | rgb(3, 199, 90) | 네이버 버튼 배경 | 공식 브랜드 색 |
| Naver-Text | #FFFFFF | rgb(255, 255, 255) | 네이버 버튼 텍스트 | White |

#### Semantic 색상
| Token | Hex | RGB | 용도 | Notes |
|-------|-----|-----|------|-------|
| Success | #10B981 | rgb(16, 185, 129) | 성공 메시지, 토스트 | Emerald-500 |
| Warning | #F59E0B | rgb(245, 158, 11) | 경고, 주의 알림 | Amber-500 |
| Error | #EF4444 | rgb(239, 68, 68) | 에러, 삭제 | Red-500 |
| Info | #3B82F6 | rgb(59, 130, 246) | 정보, 안내 | Blue-500 |

#### Neutral 색상
| Token | Hex | RGB | 용도 | Notes |
|-------|-----|-----|------|-------|
| Neutral-50 | #F8FAFC | rgb(248, 250, 252) | 전체 배경 | 밝음 |
| Neutral-100 | #F1F5F9 | rgb(241, 245, 249) | 카드, 섹션 배경 | 약간 어두움 |
| Neutral-200 | #E2E8F0 | rgb(226, 232, 240) | Divider, 약한 테두리 | - |
| Neutral-300 | #CBD5E1 | rgb(203, 213, 225) | 기본 테두리 | - |
| Neutral-400 | #94A3B8 | rgb(148, 163, 184) | Placeholder 텍스트 | - |
| Neutral-500 | #64748B | rgb(100, 116, 139) | 보조 텍스트 | - |
| Neutral-600 | #475569 | rgb(71, 85, 105) | 기본 텍스트 | - |
| Neutral-700 | #334155 | rgb(51, 65, 85) | 강조 텍스트 | - |
| Neutral-800 | #1E293B | rgb(30, 41, 59) | 제목 | - |

#### Opacity 상태
| State | Opacity | 용도 |
|-------|---------|------|
| Disabled | 0.4 | 비활성 버튼, 입력 필드 |
| Muted | 0.6 | 로딩 중 배경 |
| Subtle | 0.8 | 약한 강조 |
| Overlay | 0.5 | 모달 배경 |

---

### 1.2 타이포그래피 토큰

#### Type Scale
| Token | Size | Weight | Line Height | Usage | CSS-like |
|-------|------|--------|-------------|-------|----------|
| 3xl | 28px | 700 | 36px | 페이지 제목 | font: 700 28px/36px |
| 2xl | 24px | 700 | 32px | 섹션 제목, 모달 제목 | font: 700 24px/32px |
| xl | 20px | 600 | 28px | 부제목, 강조 | font: 600 20px/28px |
| lg | 18px | 600 | 26px | 부제목, 강조 | font: 600 18px/26px |
| base | 16px | 400 | 24px | 본문, 버튼 텍스트 | font: 400 16px/24px |
| sm | 14px | 400 | 20px | 라벨, 헬퍼 텍스트 | font: 400 14px/20px |
| xs | 12px | 400 | 16px | 캡션, 메타 | font: 400 12px/16px |

#### Font Family
```dart
// Flutter 사용
const String fontFamily = 'Pretendard';
// fallback: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue"
```

---

### 1.3 여백 & 크기 토큰

#### Spacing Scale (4px 기반)
| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | 텍스트-아이콘 간격 |
| sm | 8px | 요소 간 미세 간격 |
| md | 16px | 기본 패딩, 카드 간격 |
| lg | 24px | 섹션 간 여백 |
| xl | 32px | 주요 섹션 구분 |
| 2xl | 48px | 특별 섹션 여백 |

#### 컴포넌트 크기
| Component | Size | Notes |
|-----------|------|-------|
| Button (Medium) | 44px height | iOS 최소 터치 |
| Checkbox (Visual) | 24x24px | - |
| Checkbox (Touch) | 44x44px | 터치 영역 |
| Icon (Standard) | 24x24px | - |
| Logo | 192x192px | 헤로 섹션 |
| Input Field | 48px height | 여유 있는 높이 |

#### Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| sm | 8px | 버튼, 입력 필드 |
| md | 12px | 카드 |
| lg | 16px | 모달, 섹션 |

---

### 1.4 Shadow & Elevation

#### Shadow Levels
| Level | Shadow | Usage |
|-------|--------|-------|
| xs | 0 1px 2px rgba(15,23,42,0.05) | 약한 깊이 |
| sm | 0 2px 4px rgba(15,23,42,0.06), 0 1px 2px rgba(15,23,42,0.04) | 버튼, 카드 |
| md | 0 4px 8px rgba(15,23,42,0.08), 0 2px 4px rgba(15,23,42,0.04) | 기본 카드 |
| lg | 0 8px 16px rgba(15,23,42,0.10), 0 4px 8px rgba(15,23,42,0.06) | 모달 |

---

## 2. 컴포넌트 상세 명세

### 2.1 AuthHeroSection 컴포넌트

#### 목적
로그인 화면의 상단 헤로 섹션 (로고, 제목, 부제목)

#### 구조
```
AuthHeroSection (Container)
├── Gabium Logo (SvgPicture or Image)
│   └── Size: 192x192px
├── SizedBox (height: 24px)
├── Title Text (3xl Bold)
│   └── "GLP-1 치료 관리"
├── SizedBox (height: 8px)
└── Subtitle Text (lg Semibold, Primary color)
    └── "체계적으로 관리하세요"
```

#### 토큰
```
Container Padding: xl (32px) 상하, md (16px) 좌우
Background: Neutral-50 (#F8FAFC)
Logo Size: 192x192px
Title Font: 3xl, Semibold, Neutral-900
Subtitle Font: lg, Semibold, Primary (#4ADE80)
Border Radius: md (12px) (optional, 카드 효과)
Shadow: xs (optional)
```

#### Flutter 코드 예제
```dart
class AuthHeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoAssetPath;

  const AuthHeroSection({
    Key? key,
    this.title = 'GLP-1 치료 관리',
    this.subtitle = '체계적으로 관리하세요',
    this.logoAssetPath = 'assets/logos/gabium-logo-192.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F172A).withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            logoAssetPath,
            width: 192,
            height: 192,
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              height: 36 / 28,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4ADE80),
              height: 26 / 18,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 2.2 ConsentCheckbox 컴포넌트

#### 목적
필수/선택 동의 체크박스 (44x44px 터치 영역)

#### 구조
```
ConsentCheckbox (GestureDetector)
├── SizedBox (44x44px - 터치 영역)
│   └── Row
│       ├── Checkbox (24x24px visual)
│       ├── SizedBox (width: 12px)
│       └── Expanded
│           └── Text (label + optional badge)
```

#### 토큰
```
Touch Area: 44x44px
Checkbox Visual: 24x24px
Checkbox Border: 2px, Neutral-400 (#94A3B8)
Checkbox Border Radius: 4px
Checked Background: Primary (#4ADE80)
Checked Mark: White
Label Font: base (16px), Regular, Neutral-700
Badge: sm (14px), Semibold, Error (Required) or Warning (Optional)
Spacing (Checkbox-Text): sm (8px)
Padding: md (16px) 좌우
```

#### Flutter 코드 예제
```dart
class ConsentCheckbox extends StatefulWidget {
  final String label;
  final bool isRequired;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ConsentCheckbox({
    Key? key,
    required this.label,
    this.isRequired = false,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ConsentCheckbox> createState() => _ConsentCheckboxState();
}

class _ConsentCheckboxState extends State<ConsentCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.value
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF94A3B8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: widget.value
                      ? const Color(0xFF4ADE80)
                      : Colors.transparent,
                ),
                child: widget.value
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            // Label
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  if (widget.isRequired)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '필수',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 2.3 SocialLoginButton 컴포넌트

#### 목적
Kakao/Naver 소셜 로그인 버튼

#### 구조
```
SocialLoginButton (ElevatedButton)
├── Icon (24x24px)
├── SizedBox (width: 12px)
└── Text (label)
```

#### 토큰 (Kakao)
```
Background: #FEE500
Text Color: Black87
Text Font: base (16px), Semibold
Icon: 24x24px
Height: 44px
Border Radius: sm (8px)
Padding: md (16px) 좌우, sm (8px) 상하
Shadow: sm
States:
  - Hover: 약간 진하게, Shadow md
  - Active: 더 진하게, Shadow xs
  - Disabled: 40% opacity
  - Loading: Spinner 표시
```

#### 토큰 (Naver)
```
Background: #03C75A
Text Color: White
Text Font: base (16px), Semibold
Icon: 24x24px
Height: 44px
Border Radius: sm (8px)
Padding: md (16px) 좌우, sm (8px) 상하
Shadow: sm
(Kakao와 동일한 구조)
```

#### Flutter 코드 예제
```dart
class SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isLoading = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

### 2.4 ConsentCardSection 컴포넌트

#### 목적
동의 섹션을 카드로 감싸서 강조

#### 구조
```
Container (Card-like)
├── Padding: md (16px)
└── Column
    ├── ConsentCheckbox (terms)
    ├── SizedBox (height: 16px)
    └── ConsentCheckbox (privacy)
```

#### 토큰
```
Background: Neutral-100 (#F1F5F9)
Border: 1px, Neutral-200 (#E2E8F0)
Border Radius: md (12px)
Padding: md (16px)
Shadow: xs
Checkbox Spacing: md (16px)
```

#### Flutter 코드 예제
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0xFFF1F5F9),
    border: Border.all(
      color: const Color(0xFFE2E8F0),
      width: 1,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: const Color(0x0F172A).withOpacity(0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      ConsentCheckbox(
        label: '이용약관에 동의합니다',
        isRequired: true,
        value: _agreedToTerms,
        onChanged: (val) {
          setState(() => _agreedToTerms = val);
        },
      ),
      const SizedBox(height: 16),
      ConsentCheckbox(
        label: '개인정보처리방침에 동의합니다',
        isRequired: true,
        value: _agreedToPrivacy,
        onChanged: (val) {
          setState(() => _agreedToPrivacy = val);
        },
      ),
    ],
  ),
)
```

---

### 2.5 HelperTextAlert 컴포넌트

#### 목적
동의 전 헬퍼 텍스트 (아이콘 + 메시지)

#### 구조
```
Container (Alert-like)
├── Padding: md (16px)
├── BorderRadius: sm (8px)
└── Row
    ├── Icon (24x24px)
    ├── SizedBox (width: 12px)
    └── Expanded
        └── Text (message)
```

#### 토큰
```
Background: Warning (#F59E0B) at 8% opacity
Border: 1px, Warning (#F59E0B) at 20% opacity
Border Radius: sm (8px)
Padding: md (16px)
Icon: 24x24px, Warning color
Icon Spacing: sm (12px)
Text Font: base (16px), Regular, Warning color
```

#### Flutter 코드 예제
```dart
if (!_canLogin && !_isLoading)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF59E0B).withOpacity(0.08),
      border: Border.all(
        color: const Color(0xFFF59E0B).withOpacity(0.2),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline,
          color: Color(0xFFF59E0B),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '소셜 로그인하려면 약관에 모두 동의해주세요',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    ),
  )
```

---

## 3. 레이아웃 상세 구조

### 3.1 전체 화면 레이아웃

```
Scaffold
├── AppBar (없음 - SafeArea에 포함)
└── body: SafeArea
    └── SingleChildScrollView
        └── Padding (md=16px 좌우)
            └── Column
                ├── SizedBox (height: xl=32px)
                ├── AuthHeroSection
                ├── SizedBox (height: lg=24px)
                ├── ConsentCardSection
                │   ├── ConsentCheckbox (terms)
                │   ├── Spacing (md=16px)
                │   └── ConsentCheckbox (privacy)
                ├── SizedBox (height: lg=24px)
                ├── [CONDITIONS]
                │   └── HelperTextAlert
                ├── SizedBox (height: md=16px)
                ├── SocialLoginButton (Kakao)
                ├── SizedBox (height: sm=8px)
                ├── SocialLoginButton (Naver)
                ├── SizedBox (height: lg=24px)
                ├── Divider
                ├── SizedBox (height: lg=24px)
                ├── SectionLabel ('다른 계정으로 계속하기')
                ├── SizedBox (height: sm=8px)
                ├── SecondaryButton (Email Signin)
                ├── SizedBox (height: sm=8px)
                ├── SecondaryButton (Email Signup)
                └── SizedBox (height: xl=32px)
```

### 3.2 간격 명세 (Spacing)

```
화면 전체 패딩: 좌우 md (16px), 상하 xl (32px)

섹션별 간격:
- 헤로 섹션 ↓ 동의 섹션: lg (24px)
- 동의 섹션 ↓ 헬퍼 텍스트: lg (24px)
- 헬퍼 텍스트 ↓ 카카오 버튼: md (16px)
- 카카오 버튼 ↓ 네이버 버튼: sm (8px)
- 네이버 버튼 ↓ 이메일 섹션: lg (24px)

이메일 섹션:
- Divider 양쪽 여백: lg (24px)
- 섹션 라벨 ↓ 버튼: sm (8px)
- 이메일 로그인 ↓ 회원가입: sm (8px)
- 회원가입 ↓ 하단 여백: xl (32px)
```

---

## 4. 인터랙션 명세

### 4.1 체크박스 상태 전환

```
[Unchecked] ← tap → [Checked]
  │                     │
  ├─ 경계선: Neutral-400  ├─ 배경: Primary
  ├─ 배경: Transparent    ├─ 경계선: Primary
  └─ 아이콘: 없음         └─ 아이콘: Check (White)

애니메이션: 150ms ease-in-out
```

### 4.2 버튼 상태 전환

```
[Default] ← hover → [Hover] ← tap → [Active]
  │                    │               │
  ├─ Shadow: sm       ├─ Shadow: md   ├─ Shadow: xs
  └─ 배경: Brand      └─ 배경: Darker  └─ 배경: Darker

[Disabled]
  └─ Opacity: 0.4
  └─ 터치 불가

[Loading]
  └─ Spinner 표시
  └─ 텍스트 숨김 또는 "로그인 중..." 표시
```

### 4.3 동의 상태 피드백

```
둘 다 체크 안 함:
├─ 버튼: disabled (opacity 0.4)
├─ 헬퍼 텍스트: 표시 (Warning 색상)
└─ 사용자 가이드: 명확함

부분 체크:
├─ 버튼: 여전히 disabled
├─ 헬퍼 텍스트: 계속 표시
└─ "모두 동의해야 함" 메시지 강조

모두 체크:
├─ 버튼: enabled (상태 복구)
├─ 헬퍼 텍스트: 숨김
└─ 사용자 행동 대기
```

---

## 5. 에러 & 피드백 처리

### 5.1 OAuth 에러 처리

#### OAuthCancelledException
```
시나리오: 사용자가 로그인 캔슬

피드백:
- GabiumToast (Warning, 3초)
- 메시지: "로그인이 취소되었습니다. 다시 시도해주세요."
- 아이콘: Info
- 배경색: #FFFBEB (Warning-50)
- 테두리색: #F59E0B (Warning)
```

#### MaxRetriesExceededException
```
시나리오: 네트워크 오류 (재시도 초과)

피드백:
- GabiumToast (Error, 5초) + 액션 버튼
- 메시지: "네트워크 연결을 확인하고 다시 시도해주세요."
- 액션: "재시도" 버튼
- 배경색: #FEF2F2 (Error-50)
- 테두리색: #EF4444 (Error)
```

#### 일반 에러
```
시나리오: 예기치 않은 오류

피드백:
- GabiumToast (Error, 5초)
- 메시지: "로그인 중 오류가 발생했습니다. [에러 내용]"
- 배경색: #FEF2F2
- 테두리색: #EF4444
```

### 5.2 로딩 상태 피드백

```
로그인 시작:
├─ _isLoading = true
├─ 모든 입력 필드 disabled (IgnorePointer)
├─ 버튼 Opacity: 0.6
├─ 버튼 내 Spinner 표시 (Primary 색상)
└─ 상태 메시지: "로그인 중..." (선택사항)

로그인 완료 또는 취소:
├─ _isLoading = false
├─ 입력 필드 다시 활성화
├─ 버튼 Opacity: 1.0
└─ 버튼 아이콘 복구
```

---

## 6. 파일 구조 & 생성 계획

### 6.1 생성할 파일

```
lib/features/authentication/presentation/
├── screens/
│   └── login_screen.dart (개선)
└── widgets/
    ├── auth_hero_section.dart (신규)
    ├── consent_checkbox.dart (신규)
    ├── social_login_button.dart (신규)
    ├── consent_card_section.dart (신규)
    ├── helper_text_alert.dart (신규)
    ├── gabium_button.dart (재사용 or 신규)
    └── gabium_toast.dart (재사용 or 신규)
```

### 6.2 Asset 폴더

```
assets/
└── logos/
    ├── gabium-logo-192.png (필수)
    └── gabium-logo-transparent.png (선택)
```

---

## 7. Flutter 구현 가이드

### 7.1 상태 관리

```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _isLoading = false;

  bool get _canLogin => _agreedToTerms && _agreedToPrivacy && !_isLoading;

  // 기존 _handleKakaoLogin, _handleNaverLogin 유지
  // (로직 변경 없음, UI만 개선)
}
```

### 7.2 빌드 메서드 구조

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 헤로 섹션
              AuthHeroSection(),
              const SizedBox(height: 24),

              // 2. 동의 섹션
              ConsentCardSection(...),
              const SizedBox(height: 24),

              // 3. 헬퍼 텍스트 (조건부)
              if (!_canLogin && !_isLoading)
                HelperTextAlert(...),
              const SizedBox(height: 16),

              // 4. 소셜 로그인 버튼
              SocialLoginButton(
                label: '카카오 로그인',
                icon: Icons.chat_bubble,
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black87,
                isLoading: _isLoading && _lastProvider == 'kakao',
                onPressed: _canLogin ? _handleKakaoLogin : null,
              ),
              const SizedBox(height: 8),
              SocialLoginButton(
                label: '네이버 로그인',
                icon: Icons.language,
                backgroundColor: const Color(0xFF03C75A),
                foregroundColor: Colors.white,
                isLoading: _isLoading && _lastProvider == 'naver',
                onPressed: _canLogin ? _handleNaverLogin : null,
              ),
              const SizedBox(height: 24),

              // 5. 이메일 섹션
              _buildEmailSection(),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildEmailSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Divider
      Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '또는',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // 섹션 라벨
      Text(
        '다른 계정으로 계속하기',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
      const SizedBox(height: 12),

      // 이메일 로그인/가입 버튼
      ElevatedButton.icon(
        onPressed: () => context.go('/email-signin'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4ADE80),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xFF4ADE80),
              width: 2,
            ),
          ),
        ),
        icon: const Icon(Icons.email_outlined),
        label: const Text('이메일로 로그인'),
      ),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        onPressed: () => context.go('/email-signup'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4ADE80),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xFF4ADE80),
              width: 2,
            ),
          ),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('이메일로 회원가입'),
      ),
    ],
  );
}
```

---

## 8. 접근성 & 테스팅 체크리스트

### 8.1 접근성 (WCAG AA)

- [ ] 색상 대비: 4.5:1 이상 (텍스트)
- [ ] 터치 영역: 44x44px 이상 (모든 인터랙티브 요소)
- [ ] 키보드 네비게이션: Tab, Enter, Space, Esc 지원
- [ ] 포커스 표시: 2px 이상 outline (명확한 색상)
- [ ] 레이블: 모든 입력 필드에 적절한 레이블
- [ ] ARIA/Semantics: 한글 접근성 고려 (폰트 크기, 줄 높이)
- [ ] 애니메이션: prefers-reduced-motion 존중

### 8.2 테스팅 체크리스트

#### 기능 테스트
- [ ] 체크박스 토글 작동
- [ ] Kakao 로그인 클릭 → 실행
- [ ] Naver 로그인 클릭 → 실행
- [ ] 동의 전 버튼 비활성 확인
- [ ] 동의 후 버튼 활성 확인
- [ ] 이메일 로그인/가입 라우팅 작동
- [ ] 로딩 중 다중 클릭 방지

#### 시각 테스트
- [ ] 헤로 섹션 로고 표시 여부
- [ ] 제목/부제목 글꼴 크기 및 색상 확인
- [ ] 동의 섹션 카드 배경 표시
- [ ] 헬퍼 텍스트 경고색 표시
- [ ] 버튼 상태별 색상 (활성/비활성/호버)
- [ ] 로딩 스피너 표시 및 회전

#### 반응형 테스트
- [ ] 모바일 (375px): 텍스트 overflow 없음
- [ ] 태블릿 (768px): 레이아웃 자연스러움
- [ ] 회전 (가로): 레이아웃 정상 작동
- [ ] 키보드 표시 시: 입력 필드 접근 가능

#### 에러 처리 테스트
- [ ] OAuth 취소: 경고 토스트 표시
- [ ] 네트워크 오류: 재시도 액션 포함 토스트
- [ ] 일반 오류: 에러 토스트 표시

---

## 9. 성능 고려사항

### 9.1 이미지 최적화
```dart
Image.asset(
  'assets/logos/gabium-logo-192.png',
  width: 192,
  height: 192,
  cacheHeight: 192,  // 캐싱으로 메모리 절약
  cacheWidth: 192,
)
```

### 9.2 빌드 최적화
```dart
const SizedBox(height: 24)  // const 사용으로 재생성 방지

class AuthHeroSection extends StatelessWidget {  // StatelessWidget 사용
  const AuthHeroSection({Key? key}) : super(key: key);
}
```

---

## 10. 추가 참고사항

- **Design System 문서:** `.claude/skills/ui-renewal/design-systems/gabium-design-system-v1.0.md`
- **로고 가이드라인:** `.claude/skills/ui-renewal/assets/logo-guidelines.md`
- **기존 컴포넌트:** `lib/features/authentication/presentation/widgets/`
- **라우팅 설정:** `lib/config/router/app_router.dart`
- **인증 상태:** `lib/features/authentication/application/notifiers/auth_notifier.dart`

---

**작성자:** UI Renewal Agent
**상태:** Phase 2B 완료 (구현 준비)
**예상 Phase 2C 소요 시간:** 2시간

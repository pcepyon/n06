# 앱스토어 심사 Critical 항목 수정 계획

> 작성일: 2025-12-15
> 상태: 계획 수립
> 우선순위: P0 (출시 전 필수)

---

## 개요

### 배경
2025년 12월 앱스토어 출시 준비 상태 종합 검증 결과, 5개의 Critical 항목이 발견되었다. 이 항목들은 심사 거절 가능성이 높아 **출시 전 반드시 수정**이 필요하다.

### 목적
Apple App Store 심사 기준을 충족하여 첫 제출에서 승인받는 것을 목표로 한다.

### 범위
- Privacy Policy 접근성 개선
- App Tracking Transparency 정책 준수
- iOS 접근성(VoiceOver) 지원
- 다크모드 테마 지원
- Privacy Manifest 파일 생성

---

## Critical 항목 상세 계획

---

### 1. Privacy Policy 접근 불가 수정

#### 문제 정의
로그인/회원가입 화면의 `ConsentCheckbox` 위젯에서 사용자가 동의 체크 전에 개인정보처리방침 내용을 확인할 수 없다. Apple 심사 기준상 동의 전 내용 확인 기능은 필수이다.

#### 영향 받는 파일
| 파일 | 위치 | 역할 |
|------|------|------|
| `login_screen.dart` | `lib/features/authentication/presentation/screens/` | 로그인 화면 |
| `email_signup_screen.dart` | `lib/features/authentication/presentation/screens/` | 이메일 회원가입 화면 |
| `consent_checkbox.dart` | `lib/features/authentication/presentation/widgets/` | 동의 체크박스 위젯 |

#### 요구사항

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| PP-01 | ConsentCheckbox의 텍스트 라벨을 탭하면 해당 법적 문서 URL로 이동해야 한다 | 필수 |
| PP-02 | 체크박스 영역과 텍스트 영역의 터치 영역이 분리되어야 한다 | 필수 |
| PP-03 | 외부 브라우저 또는 인앱 웹뷰로 문서를 표시해야 한다 | 필수 |
| PP-04 | URL 열기 실패 시 사용자에게 피드백을 제공해야 한다 | 권장 |

#### 수정 방향
- `ConsentCheckbox` 위젯에 `onViewTap` 콜백 파라미터 추가
- 로그인/회원가입 화면에서 `LegalUrls` 상수를 사용하여 콜백 구현
- `url_launcher` 패키지의 `launchUrl` 함수 활용

#### 검증 기준
- [ ] 개인정보처리방침 라벨 탭 시 해당 URL로 이동
- [ ] 이용약관 라벨 탭 시 해당 URL로 이동
- [ ] 민감정보 동의 라벨 탭 시 해당 URL로 이동
- [ ] 체크박스 탭 시 체크 상태만 변경 (URL 이동 없음)

---

### 2. Firebase Analytics 무단 수집 해결

#### 문제 정의
`Info.plist`에 `NSUserTrackingUsageDescription`이 설정되어 있으나, 실제 ATT(App Tracking Transparency) 권한 요청 코드가 없다. iOS 14.5 이상에서 사용자 추적 시 ATT 동의는 필수이다.

#### 현재 상태 분석
- `AnalyticsService`의 메서드들이 디버그 모드에서 early return하고 있음
- 릴리스 모드에서는 Firebase Analytics가 자동 활성화됨
- ATT 권한 요청 없이 데이터 수집은 정책 위반

#### 영향 받는 파일
| 파일 | 위치 | 역할 |
|------|------|------|
| `analytics_service.dart` | `lib/core/services/` | Firebase Analytics 래퍼 |
| `main.dart` | `lib/` | 앱 초기화 |
| `Info.plist` | `ios/Runner/` | iOS 설정 |

#### 요구사항

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| ATT-01 | 앱 최초 실행 시 ATT 권한 요청 다이얼로그를 표시해야 한다 | 필수 |
| ATT-02 | 사용자가 추적을 거부하면 Firebase Analytics 수집을 비활성화해야 한다 | 필수 |
| ATT-03 | 사용자가 추적을 허용하면 Analytics 수집을 활성화해야 한다 | 필수 |
| ATT-04 | ATT 상태는 앱 재시작 시에도 유지되어야 한다 | 필수 |
| ATT-05 | 설정 화면에서 추적 설정 변경 안내를 제공해야 한다 | 권장 |

#### 수정 방향 (Option A - 권장)
ATT 구현 및 조건부 Analytics 활성화:
1. `app_tracking_transparency` 패키지 추가
2. 앱 초기화 시 ATT 권한 상태 확인
3. 권한 상태에 따라 `FirebaseAnalytics.setAnalyticsCollectionEnabled()` 호출
4. `AnalyticsService`에 활성화 상태 플래그 추가

#### 수정 방향 (Option B - 대안)
Analytics 완전 비활성화:
1. `Info.plist`에서 `NSUserTrackingUsageDescription` 제거
2. `AnalyticsService` 메서드들을 no-op으로 변경
3. Firebase Crashlytics만 유지 (에러 추적용)

#### 검증 기준
- [ ] 앱 최초 실행 시 ATT 다이얼로그 표시
- [ ] 거부 시 Analytics 이벤트 전송 안 됨 (Firebase Console 확인)
- [ ] 허용 시 Analytics 이벤트 정상 전송
- [ ] 앱 재시작 후에도 설정 유지

---

### 3. 접근성(VoiceOver) 지원 추가

#### 문제 정의
앱 전체에서 `Semantics` 위젯 사용이 0건이다. VoiceOver를 사용하는 시각장애인이 앱을 사용할 수 없으며, Apple Human Interface Guidelines 및 App Review Guideline 2.5.7 위반이다.

#### 영향 범위
- 모든 인터랙티브 위젯 (버튼, 입력 필드, 체크박스 등)
- 커스텀 위젯 (GabiumButton, GabiumTextField, ConsentCheckbox 등)
- 네비게이션 요소 (하단 탭바, 앱바 등)

#### 요구사항

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| A11Y-01 | 모든 버튼에 `Semantics.label`을 제공해야 한다 | 필수 |
| A11Y-02 | 모든 입력 필드에 `Semantics.label`과 `Semantics.hint`를 제공해야 한다 | 필수 |
| A11Y-03 | 체크박스/토글에 `Semantics.checked` 상태를 제공해야 한다 | 필수 |
| A11Y-04 | 이미지에 `Semantics.label` 또는 `excludeSemantics`를 적용해야 한다 | 필수 |
| A11Y-05 | 로딩 상태에 `Semantics.liveRegion`을 적용해야 한다 | 권장 |
| A11Y-06 | 에러 메시지에 `Semantics.liveRegion`을 적용해야 한다 | 권장 |

#### 수정 대상 위젯 (우선순위순)

**1순위 - 공용 위젯**
| 위젯 | 파일 | 적용 내용 |
|------|------|----------|
| GabiumButton | `lib/features/authentication/presentation/widgets/gabium_button.dart` | button, label, enabled |
| GabiumTextField | `lib/features/authentication/presentation/widgets/gabium_text_field.dart` | textField, label, hint |
| ConsentCheckbox | `lib/features/authentication/presentation/widgets/consent_checkbox.dart` | checkbox, checked, label |
| GabiumBottomNavigation | `lib/core/presentation/widgets/gabium_bottom_navigation.dart` | tab, selected, label |

**2순위 - 주요 화면**
| 화면 | 파일 | 적용 내용 |
|------|------|----------|
| 로그인 화면 | `lib/features/authentication/presentation/screens/login_screen.dart` | 소셜 로그인 버튼 라벨 |
| 홈 대시보드 | `lib/features/dashboard/presentation/screens/home_dashboard_screen.dart` | 차트, 카드 설명 |
| 설정 화면 | `lib/features/settings/presentation/screens/settings_screen.dart` | 설정 항목 라벨 |

#### 수정 방향
1. 공용 위젯에 `Semantics` 래퍼 적용
2. 한글 접근성 라벨 추가 (l10n 활용)
3. 상태 변화 시 VoiceOver 알림 (liveRegion)

#### 검증 기준
- [ ] VoiceOver 활성화 후 모든 화면 탐색 가능
- [ ] 버튼 탭 시 "버튼, [라벨명]" 읽힘
- [ ] 입력 필드 포커스 시 "[라벨명], 텍스트 필드" 읽힘
- [ ] 체크박스 상태 변경 시 "선택됨/선택 안 됨" 읽힘

---

### 4. 다크모드 테마 지원

#### 문제 정의
`AppTheme.lightTheme`만 구현되어 있고 `darkTheme`이 없다. 시스템 다크모드 설정을 무시하며 Human Interface Guidelines 위반이다.

#### 영향 받는 파일
| 파일 | 위치 | 역할 |
|------|------|------|
| `app_theme.dart` | `lib/core/presentation/theme/` | 테마 정의 |
| `app_colors.dart` | `lib/core/presentation/theme/` | 색상 상수 |
| `main.dart` | `lib/` | MaterialApp 테마 설정 |

#### 요구사항

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| DM-01 | 시스템 다크모드 설정을 자동으로 따라야 한다 | 필수 |
| DM-02 | 다크모드에서 텍스트 대비율 WCAG 4.5:1 이상 유지 | 필수 |
| DM-03 | 모든 화면에서 다크모드 색상이 일관되어야 한다 | 필수 |
| DM-04 | 차트/그래프 색상이 다크모드에서 가시성 유지 | 필수 |
| DM-05 | 앱 내 테마 전환 옵션 제공 (시스템/라이트/다크) | 권장 |

#### 색상 매핑 가이드

| 용도 | 라이트 모드 | 다크 모드 |
|------|------------|----------|
| 배경 (scaffold) | neutral50 | neutral900 |
| 표면 (card, dialog) | white | neutral800 |
| 주요 텍스트 | neutral900 | neutral50 |
| 보조 텍스트 | neutral600 | neutral400 |
| 구분선 | neutral200 | neutral700 |
| Primary | primary600 | primary400 |
| Error | error600 | error400 |

#### 수정 방향
1. `AppTheme.darkTheme` getter 추가
2. `AppColors`에 다크모드용 시맨틱 색상 추가
3. `main.dart`에서 `darkTheme` 및 `themeMode: ThemeMode.system` 설정
4. 하드코딩된 색상을 테마 색상으로 교체

#### 검증 기준
- [ ] 시스템 다크모드 활성화 시 앱 자동 전환
- [ ] 모든 텍스트 가독성 확보
- [ ] 차트/그래프 색상 명확히 구분
- [ ] 입력 필드 테두리/포커스 상태 구분 가능

---

### 5. PrivacyInfo.xcprivacy 파일 생성

#### 문제 정의
2024년 5월 이후 App Store 제출 시 `PrivacyInfo.xcprivacy` 파일이 필수이다. Required Reason API 사용 및 데이터 수집에 대한 선언이 필요하다.

#### 영향 받는 파일
| 파일 | 위치 | 역할 |
|------|------|------|
| `PrivacyInfo.xcprivacy` | `ios/Runner/` | **신규 생성** |
| `project.pbxproj` | `ios/Runner.xcodeproj/` | 파일 참조 추가 |

#### 요구사항

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| PM-01 | `NSPrivacyTracking` 키로 추적 여부를 선언해야 한다 | 필수 |
| PM-02 | `NSPrivacyTrackingDomains`에 추적 도메인을 나열해야 한다 | 필수 |
| PM-03 | `NSPrivacyCollectedDataTypes`에 수집 데이터를 선언해야 한다 | 필수 |
| PM-04 | `NSPrivacyAccessedAPITypes`에 Required Reason API를 선언해야 한다 | 필수 |
| PM-05 | Xcode 프로젝트에 파일 참조를 추가해야 한다 | 필수 |

#### 선언해야 할 내용

**추적 여부**
- `NSPrivacyTracking`: false (광고 추적 미사용)
- `NSPrivacyTrackingDomains`: 빈 배열

**수집 데이터 타입**
| 데이터 타입 | 수집 목적 | 사용자 연결 |
|------------|----------|------------|
| Health & Fitness | App Functionality | Yes |
| Contact Info (Email) | App Functionality | Yes |
| Identifiers (User ID) | App Functionality, Analytics | Yes |
| Diagnostics (Crash Data) | App Functionality | No |

**Required Reason API**
- 앱 코드에서 직접 사용하는 Required Reason API 없음
- 의존성 플러그인(shared_preferences, Firebase)은 자체 Privacy Manifest 포함

#### 수정 방향
1. `ios/Runner/PrivacyInfo.xcprivacy` 파일 생성
2. Apple 문서 형식에 맞게 plist 작성
3. Xcode에서 Runner 타겟에 파일 추가
4. 빌드 후 Privacy Manifest 포함 확인

#### 검증 기준
- [ ] Xcode에서 파일이 Runner 타겟에 포함됨
- [ ] `flutter build ios --release` 성공
- [ ] App Store Connect 업로드 시 경고 없음

---

## 구현 순서

```
[1일차]
├── 5. PrivacyInfo.xcprivacy 생성 (30분)
├── 1. Privacy Policy 접근성 수정 (1시간)
└── 2. ATT 구현 또는 Analytics 비활성화 (2시간)

[2일차]
├── 4. 다크모드 테마 구현 (4시간)
│   ├── AppColors 다크모드 색상 정의
│   ├── AppTheme.darkTheme 구현
│   └── 하드코딩 색상 교체
└── 테스트 및 검증 (2시간)

[3일차]
├── 3. 접근성 지원 추가 (4시간)
│   ├── 공용 위젯 Semantics 적용
│   └── 주요 화면 접근성 검증
└── 통합 테스트 및 최종 검증 (2시간)
```

---

## 참고 문서

- [App Review Guidelines - Apple Developer](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Privacy Manifest Files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency)
- [Supporting Dark Mode](https://developer.apple.com/documentation/uikit/appearance_customization/supporting_dark_mode_in_your_interface)

---

## 변경 이력

| 날짜 | 버전 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 2025-12-15 | 1.0 | 초안 작성 | Claude |

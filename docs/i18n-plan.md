# GLP-1 앱 다국어(i18n) 지원 계획

## 1. 개요

### 현재 상태
- 하드코딩된 한국어 문자열: ~1,100-1,560개 (97개 파일)
- 기존 i18n: 없음 (intl은 DateFormat용으로만 사용)
- 문자열 분리된 모듈: `daily_checkin/presentation/constants/checkin_strings.dart` (150+ 상수)
- 기술 스택: Flutter 3.9+, Riverpod, Supabase

### 목표
- 지원 언어: 한국어(ko, 기본), 영어(en)
- 방식: Flutter gen_l10n + ARB
- 기존 기능/UI 100% 유지

---

## 2. 인프라 설정

### 2.1 l10n.yaml 설정

```yaml
# l10n.yaml (프로젝트 루트)
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
output-class: L10n
output-dir: lib/l10n/generated
nullable-getter: false
use-deferred-loading: false
format: icu
```

### 2.1.1 .gitignore 업데이트

```gitignore
# L10n generated files
lib/l10n/generated/
lib/l10n/*.g.dart
```

### 2.2 ARB 파일 구조

```
lib/
└── l10n/
    ├── app_ko.arb          # 한국어 (기본/템플릿)
    ├── app_en.arb          # 영어
    └── generated/
        └── app_localizations.dart  # 자동 생성
```

### 2.3 pubspec.yaml 변경

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2  # 기존 유지

flutter:
  generate: true  # 추가
```

### 2.4 MaterialApp 설정 변경

```dart
// lib/main.dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    L10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: L10n.supportedLocales,
  locale: ref.watch(localeProvider),  // Riverpod으로 관리
);
```

### 2.5 언어 전환 방식

> **결정**: 디바이스 자동 감지 + 앱 내 설정 모두 지원

**기본 동작**: 디바이스 시스템 언어 자동 감지
**사용자 선택**: Settings 화면에서 언어 직접 변경 가능

```dart
// lib/features/settings/application/locale_notifier.dart
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    // SharedPreferences에서 저장된 값 로드
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_key);
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
    return null;  // null = 시스템 기본값 (디바이스 감지)
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);  // 시스템 기본값으로 복귀
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    state = locale;
  }
}
```

```dart
// lib/main.dart
MaterialApp(
  locale: ref.watch(localeNotifierProvider),  // null이면 시스템 언어
  localeResolutionCallback: (locale, supportedLocales) {
    // 지원하지 않는 언어면 한국어로 fallback
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode) {
        return supportedLocale;
      }
    }
    return const Locale('ko');
  },
  // ...
);
```

```dart
// Settings 화면 언어 선택 UI
ListTile(
  title: Text(context.l10n.settings_language_title),
  subtitle: Text(_getLanguageDisplayName(currentLocale)),
  onTap: () => _showLanguageSelector(context),
);

// 언어 선택 옵션
enum AppLanguage {
  system,  // 시스템 기본값
  ko,      // 한국어
  en,      // English
}
```

---

## 3. 키 네이밍 컨벤션

### 3.1 규칙

```
{feature}_{screen/widget}_{element}_{variant}
```

| 세그먼트 | 설명 | 예시 |
|---------|------|------|
| feature | 기능 모듈 | `checkin`, `tracking`, `dashboard` |
| screen/widget | 화면 또는 위젯 | `greeting`, `weightInput`, `redFlag` |
| element | UI 요소 유형 | `title`, `button`, `label`, `message`, `hint` |
| variant | 상태/변형 (선택) | `morning`, `error`, `success` |

### 3.2 예시 10개

```json
{
  "checkin_greeting_morning": "좋은 아침이에요",
  "@checkin_greeting_morning": {
    "description": "Morning greeting (5-11 AM)"
  },

  "checkin_weightInput_title": "오늘 체중을 입력해주세요",
  "@checkin_weightInput_title": {
    "description": "Weight input screen title"
  },

  "checkin_weightInput_feedbackDecreased": "조금 줄었네요! 💚",
  "@checkin_weightInput_feedbackDecreased": {
    "description": "Feedback when weight decreased"
  },

  "checkin_redFlag_pancreatitis": "윗배 통증이 등 쪽으로도 느껴지고,\n몇 시간 이상 지속되셨군요.\n\n이런 경우 드물지만 확인이 필요할 때가 있어요.\n오늘 중으로 가까운 병원에 들러서\n한 번 확인받아 보시는 게 안심이 될 것 같아요.\n\n💡 응급실이 아니어도 괜찮아요.\n   가까운 내과에서 확인받으시면 돼요.",
  "@checkin_redFlag_pancreatitis": {
    "description": "Pancreatitis warning message - MEDICAL REVIEW REQUIRED"
  },

  "tracking_calendar_title": "투약 달력",
  "@tracking_calendar_title": {
    "description": "Dose calendar screen title"
  },

  "tracking_symptom_nausea": "메스꺼움",
  "@tracking_symptom_nausea": {
    "description": "Symptom: Nausea - MEDICAL TERM"
  },

  "dashboard_badge_streak7_name": "7일 연속",
  "@dashboard_badge_streak7_name": {
    "description": "Badge name for 7-day streak"
  },

  "settings_menu_termsOfService": "이용약관",
  "@settings_menu_termsOfService": {
    "description": "Terms of service menu item"
  },

  "common_button_confirm": "확인",
  "@common_button_confirm": {
    "description": "Generic confirm button"
  },

  "common_error_networkFailed": "네트워크 연결을 확인해주세요",
  "@common_error_networkFailed": {
    "description": "Network error message"
  }
}
```

### 3.3 플레이스홀더 처리

```json
{
  "checkin_completion_consecutiveDays": "벌써 {days}일째 함께하고 있어요.",
  "@checkin_completion_consecutiveDays": {
    "description": "Consecutive days message",
    "placeholders": {
      "days": {
        "type": "int",
        "example": "5"
      }
    }
  },

  "tracking_dose_scheduledMessage": "{dose}mg 투여 시간입니다.",
  "@tracking_dose_scheduledMessage": {
    "placeholders": {
      "dose": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  },

  "tracking_weight_changeMessage": "꾸준히 변화하고 있어요! ({change}kg)",
  "@tracking_weight_changeMessage": {
    "placeholders": {
      "change": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  }
}
```

### 3.4 복수형 처리

```json
{
  "checkin_completion_daysMessage": "{count, plural, =1{첫 날이에요!} =3{벌써 3일째 함께하고 있어요!} =7{일주일 완주! 대단해요 🎉} =14{2주 동안 꾸준히 기록하셨네요!} =21{3주! 이제 습관이 되셨을 거예요} =30{한 달 완주! 정말 대단해요 🏆} other{벌써 {count}일째 함께하고 있어요.}}",
  "@checkin_completion_daysMessage": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

---

## 4. 의료 용어 번역 가이드라인

### 4.1 원칙

| 원칙 | 설명 | 예시 |
|-----|------|-----|
| **환자 친화적 표현 우선** | 의학 용어 대신 일상어 사용 | "췌장염" → "윗배 통증" |
| **톤 유지** | 한국어의 따뜻한 톤을 영어에도 반영 | "힘드셨죠" → "That sounds tough" (not "You experienced discomfort") |
| **의료적 정확성** | Red Flag 메시지는 의료진 검수 필수 | `@` 메타데이터에 `MEDICAL REVIEW REQUIRED` 태그 |
| **이모지 공통** | 이모지는 양 언어에서 동일하게 사용 | 💚, 🎉, 💧 등 |

### 4.2 증상명 번역표

#### 기본 증상 (10개)

| 한국어 | 영어 (환자용) | 의학 용어 | 비고 |
|-------|-------------|----------|------|
| 메스꺼움 | Nausea / Feeling queasy | Nausea | 증상 선택에서 사용 |
| 구토 | Vomiting / Throwing up | Emesis | - |
| 변비 | Constipation | Constipation | 일상어와 의학용어 동일 |
| 설사 | Diarrhea / Loose stools | Diarrhea | - |
| 복통 | Stomach pain / Belly ache | Abdominal pain | - |
| 두통 | Headache | Cephalgia | 일상어 사용 |
| 피로 | Tiredness / Fatigue | Fatigue | - |
| 속쓰림 | Heartburn | Pyrosis | - |
| 배가 빵빵함 | Bloating | Abdominal distension | - |
| 어지러움 | Dizziness | Vertigo/Dizziness | - |

#### 추가 증상 (데일리 체크인) (7개)

| 한국어 | 영어 (환자용) | 의학 용어 | 비고 |
|-------|-------------|----------|------|
| 입맛이 없었어요 | Loss of appetite / Not feeling hungry | Anorexia | 식욕 저하 |
| 조금만 먹어도 배불러요 | Feeling full quickly | Early satiety | 조기 포만감 |
| 손이 떨리거나 | Hand shaking / Trembling | Tremor | 저혈당 체크 |
| 심장이 빨리 뛰었어요 | Heart racing / Fast heartbeat | Palpitation | 저혈당 체크 |
| 식은땀이 났어요 | Cold sweat / Sweating | Diaphoresis | 저혈당 체크 |
| 숨이 찼어요 | Shortness of breath / Breathing difficulty | Dyspnea | 신부전 체크 |
| 붓기가 있었어요 | Swelling | Edema | 신부전 체크 |

#### Red Flag 관련 용어 (4개)

| 한국어 | 영어 (환자용) | 의학 용어 | 비고 |
|-------|-------------|----------|------|
| 췌장염 의심 | Possible pancreas issue | Pancreatitis | **MEDICAL REVIEW** |
| 담낭염 의심 | Possible gallbladder issue | Cholecystitis | **MEDICAL REVIEW** |
| 장폐색 의심 | Possible bowel blockage | Bowel obstruction | **MEDICAL REVIEW** |
| 신부전 의심 | Possible kidney issue | Renal impairment | **MEDICAL REVIEW** |

### 4.3 Red Flag 메시지 번역 원칙

```
1. 긴급성 전달: 한국어의 부드러운 톤을 유지하면서 긴급성 전달
   - KO: "오늘 중으로 병원에 들러보시는 게 좋겠어요"
   - EN: "It would be good to visit a clinic today" (NOT "Go to ER immediately")

2. 안심 제공: 두려움 최소화 메시지 유지
   - KO: "드문 경우지만 확인이 필요할 수 있어요"
   - EN: "This is rare, but it's worth getting checked"

3. 실행 가능한 조언: 구체적 행동 안내
   - KO: "가까운 내과에서 확인받으시면 돼요"
   - EN: "A nearby clinic can check this for you"
```

### 4.4 번역 검수 프로세스

```
1단계: 초벌 번역 (AI 또는 번역가)
   ↓
2단계: 의료 용어 검수 (의료진/약사)
   - Red Flag 메시지 정확성
   - 증상 설명의 적절성
   - 행동 지침의 안전성
   ↓
3단계: UX 라이팅 검토
   - 톤 & 보이스 일관성
   - 길이 적절성 (UI overflow 방지)
   ↓
4단계: 네이티브 스피커 검토 (영어)
```

#### 4.4.1 의료 콘텐츠 검수 체크리스트

| 체크 항목 | 담당 | 기준 |
|----------|------|------|
| 의학적 정확성 | 약사/의료진 | 임상 가이드라인과 일치 |
| 긴급성 전달 | 의료진 | 응급 vs 당일진료 명확 구분 |
| 환자 이해도 | UX 리서처 | 비의료인 이해 가능 |
| 문화적 맥락 | 네이티브 | 영어권 의료 문화 반영 |
| 행동 지침 실현성 | 간호사 | 구체적이고 실행 가능 |

#### 4.4.2 검수 완료 기준

```
✅ 의료 콘텐츠 검수 완료 조건:
- [ ] 약사 2인 이상 검토 서명
- [ ] Red Flag 메시지별 개별 승인
- [ ] 영어권 의료진 1인 검토 (영어 버전)
- [ ] 검수 완료일 기록 (@metadata에 review_date 추가)

❌ 자동 Fail 기준:
- 의학적 부정확성 발견
- 긴급성 수준 불명확
- 행동 지침 누락
```

#### 4.4.3 ARB 메타데이터 예시 (의료 콘텐츠)

```json
{
  "checkin_redFlag_pancreatitis": "윗배 통증이 등 쪽으로도...",
  "@checkin_redFlag_pancreatitis": {
    "description": "Pancreatitis warning - MEDICAL REVIEW REQUIRED",
    "context": "Red Flag guidance dialog",
    "reviewed_by": "pharmacist_name",
    "review_date": "2025-12-03",
    "review_status": "APPROVED"
  }
}
```

---

## 5. Phase별 작업 목록

### Phase 0: 인프라 설정 (1회) - **필수 선행 작업**

| # | 작업 | 파일 | 상세 |
|---|-----|------|-----|
| 1 | l10n.yaml 생성 | `l10n.yaml` | gen_l10n 설정 (nullable-getter: false) |
| 2 | .gitignore 업데이트 | `.gitignore` | lib/l10n/generated/ 추가 |
| 3 | pubspec.yaml 수정 | `pubspec.yaml` | flutter_localizations, generate: true |
| 4 | ARB 파일 초기화 | `lib/l10n/app_ko.arb`, `app_en.arb` | 빈 템플릿 생성 |
| 5 | L10n Extension 생성 | `lib/core/extensions/l10n_extension.dart` | `context.l10n` 헬퍼 |
| 6 | DateFormat Extension | `lib/core/extensions/date_format_extension.dart` | locale 연동 날짜 포맷 |
| 7 | MaterialApp 설정 | `lib/main.dart` | localizationsDelegates 추가 |
| 8 | **LocaleNotifier 생성** | `lib/features/settings/application/notifiers/locale_notifier.dart` | 언어 설정 상태 관리 |
| 9 | 테스트 헬퍼 생성 | `test/helpers/l10n_test_helper.dart` | L10n 모킹 유틸 |
| 10 | ARB 검증 스크립트 | `scripts/validate_arb.sh` | CI/CD 통합용 |
| 11 | 첫 번역 테스트 | - | common_button_confirm 키로 빌드 검증 |

> **중요**: Phase 0 완료 전까지 Phase 1-10 진행 불가

### Phase 1: 공통 컴포넌트 (우선순위 높음)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 공통 버튼 | `lib/core/presentation/widgets/` | ~20 |
| 공통 다이얼로그 | `lib/core/presentation/widgets/` | ~15 |
| 에러 메시지 | `lib/core/errors/domain_exception.dart` | ~10 |
| 법적 문서 메뉴 | `lib/core/constants/legal_urls.dart` + settings | ~10 |

### Phase 2: Settings & Profile (우선순위 높음)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 설정 화면 | `settings_screen.dart` | ~40 |
| 설정 메뉴 아이템 | `settings_menu_item_improved.dart` | ~15 |
| **언어 설정 추가** | `locale_notifier.dart` (신규), `language_selector_dialog.dart` (신규) | ~10 |
| 프로필 편집 | `profile_edit_screen.dart`, `profile_edit_form.dart` | ~30 |
| 주간 목표 설정 | `weekly_goal_settings_screen.dart`, `weekly_goal_input_widget.dart` | ~20 |

### Phase 3: Authentication (우선순위 높음)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 로그인 화면 | `login_screen.dart` | ~25 |
| 이메일 가입 | `email_signup_screen.dart` | ~30 |
| 이메일 로그인 | `email_signin_screen.dart` | ~20 |
| 비밀번호 재설정 | `password_reset_screen.dart` | ~15 |
| 계정 삭제 | `delete_account_confirm_dialog.dart` | ~10 |
| 로그아웃 | `logout_confirm_dialog.dart` | ~8 |
| 동의 체크박스 | `consent_checkbox.dart` | ~10 |

### Phase 4: Dashboard (우선순위 중간)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 홈 대시보드 | `home_dashboard_screen.dart` | ~20 |
| 인사말 위젯 | `emotional_greeting_widget.dart` | ~15 |
| 진행률 위젯 | `encouraging_progress_widget.dart` | ~25 |
| 일정 위젯 | `hopeful_schedule_widget.dart` | ~20 |
| 뱃지 위젯 | `celebratory_badge_widget.dart` | ~15 |
| 리포트 위젯 | `celebratory_report_widget.dart` | ~20 |

### Phase 5: Daily Checkin (우선순위 중간) - 마이그레이션

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 기존 strings 마이그레이션 | `checkin_strings.dart` → ARB | ~150 |
| 체크인 화면 | `daily_checkin_screen.dart` | ~15 |
| 질문 카드 | `question_card.dart`, `answer_button.dart` | ~10 |
| 체중 입력 | `weight_input_section.dart` | ~10 |
| Red Flag 안내 | `red_flag_guidance_dialog.dart`, `red_flag_guidance_sheet.dart` | ~20 |
| 완료 화면 | `share_report_screen.dart` | ~15 |

### Phase 6: Tracking (우선순위 중간)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 일일 기록 | `daily_tracking_screen.dart` | ~50 |
| 투약 달력 | `dose_calendar_screen.dart` | ~25 |
| 투약 기록 다이얼로그 | `dose_record_dialog_v2.dart`, `off_schedule_dose_dialog.dart` | ~30 |
| 트렌드 대시보드 | `trend_dashboard_screen.dart` | ~30 |
| 투약 계획 편집 | `edit_dosage_plan_screen.dart` | ~35 |
| 응급 체크 | `emergency_check_screen.dart` | ~20 |

### Phase 7: Onboarding (우선순위 중간)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 온보딩 메인 | `onboarding_screen.dart` | ~15 |
| 교육 화면들 | `welcome_screen.dart`, `not_your_fault_screen.dart`, `food_noise_screen.dart`, `how_it_works_screen.dart`, `side_effects_screen.dart`, `journey_roadmap_screen.dart` | ~120 |
| 준비 화면들 | `injection_guide_screen.dart`, `app_features_screen.dart`, `commitment_screen.dart` | ~60 |
| 입력 폼들 | `basic_profile_form.dart`, `weight_goal_form.dart`, `dosage_plan_form.dart` | ~40 |
| 요약 화면 | `summary_screen.dart`, `summary_card.dart` | ~20 |

### Phase 8: Coping Guide (우선순위 낮음) - 의료 콘텐츠

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 가이드 화면 | `coping_guide_screen.dart`, `detailed_guide_screen.dart` | ~30 |
| 정적 데이터 | `static_coping_guide_repository.dart` | ~200 |
| 피드백 위젯 | `feedback_widget.dart`, `coping_guide_feedback_result.dart` | ~15 |

### Phase 9: Notification (우선순위 낮음)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 알림 설정 | `notification_settings_screen.dart` | ~30 |
| 알림 메시지 | `dose_notification_usecase.dart` | ~10 |

### Phase 10: Record Management (우선순위 낮음)

| 작업 | 파일 | 문자열 수 |
|-----|------|---------|
| 기록 목록 | `record_list_screen.dart`, `record_list_card.dart` | ~20 |

---

## 6. 코드 변환 패턴

### 6.1 기본 Text 위젯

**Before:**
```dart
Text('설정')
```

**After:**
```dart
Text(context.l10n.settings_screen_title)
```

### 6.2 플레이스홀더 포함

**Before:**
```dart
Text('${schedule.scheduledDoseMg}mg 투여 시간입니다.')
```

**After:**
```dart
Text(context.l10n.tracking_dose_scheduledMessage(schedule.scheduledDoseMg))
```

### 6.3 조건부 문자열

**Before:**
```dart
static String consecutiveDays(int days) {
  if (days == 3) return '벌써 3일째 함께하고 있어요!';
  if (days == 7) return '일주일 완주! 대단해요 🎉';
  if (days > 1) return '벌써 $days일째 함께하고 있어요.';
  return '';
}
```

**After:**
```dart
// ARB에서 plural 처리
Text(context.l10n.checkin_completion_daysMessage(days))

// app_ko.arb
{
  "checkin_completion_daysMessage": "{count, plural, =3{벌써 3일째 함께하고 있어요!} =7{일주일 완주! 대단해요 🎉} other{벌써 {count}일째 함께하고 있어요.}}"
}
```

### 6.4 기존 strings 클래스 마이그레이션

**Before (checkin_strings.dart):**
```dart
class GreetingStrings {
  static const morning = '좋은 아침이에요';
  static const afternoon = '오늘 하루 어떠세요?';
}

// 사용처
Text(GreetingStrings.morning)
```

**After:**
```dart
// checkin_strings.dart 제거 또는 래퍼로 변경

// 사용처
Text(context.l10n.checkin_greeting_morning)
```

### 6.5 Dialog/AlertDialog

**Before:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('계정 삭제 확인'),
    content: const Text('정말로 계정을 삭제하시겠습니까?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      TextButton(
        onPressed: _deleteAccount,
        child: const Text('삭제'),
      ),
    ],
  ),
);
```

**After:**
```dart
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(context.l10n.auth_deleteAccount_confirmTitle),
    content: Text(context.l10n.auth_deleteAccount_confirmMessage),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: Text(context.l10n.common_button_cancel),
      ),
      TextButton(
        onPressed: _deleteAccount,
        child: Text(context.l10n.common_button_delete),
      ),
    ],
  ),
);
```

### 6.6 DateFormat locale 연동

**Before:**
```dart
DateFormat('M월 d일 (E)', 'ko_KR').format(date)
```

**After:**
```dart
// lib/core/extensions/date_format_extension.dart
extension DateFormatL10n on DateTime {
  String formatMedium(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ko') {
      return DateFormat('M월 d일 (E)', 'ko_KR').format(this);
    } else {
      return DateFormat('MMM d (E)', 'en_US').format(this);
    }
  }
}

// 사용처
Text(date.formatMedium(context))
```

### 6.7 L10n Extension 정의

```dart
// lib/core/extensions/l10n_extension.dart
import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  L10n get l10n => L10n.of(this);
}
```

---

## 7. 특수 콘텐츠 처리

### 7.1 서버 콘텐츠 (Badge)

> **결정**: 클라이언트 매핑 방식 사용

**현재**: badge_widget.dart에 하드코딩

**구현 방식**: 클라이언트에서 Badge ID → 다국어 문자열 매핑

```dart
// lib/features/dashboard/presentation/utils/badge_l10n.dart
extension BadgeL10n on BuildContext {
  String getBadgeName(String badgeId) {
    return switch (badgeId) {
      'streak_7' => l10n.dashboard_badge_streak7_name,
      'streak_14' => l10n.dashboard_badge_streak14_name,
      'streak_30' => l10n.dashboard_badge_streak30_name,
      'first_checkin' => l10n.dashboard_badge_firstCheckin_name,
      'weight_goal' => l10n.dashboard_badge_weightGoal_name,
      _ => badgeId,  // fallback
    };
  }

  String getBadgeDescription(String badgeId) {
    return switch (badgeId) {
      'streak_7' => l10n.dashboard_badge_streak7_description,
      'streak_14' => l10n.dashboard_badge_streak14_description,
      'streak_30' => l10n.dashboard_badge_streak30_description,
      'first_checkin' => l10n.dashboard_badge_firstCheckin_description,
      'weight_goal' => l10n.dashboard_badge_weightGoal_description,
      _ => '',
    };
  }
}

// 사용처 (celebratory_badge_widget.dart)
Text(context.getBadgeName(badge.id))
```

**ARB 키 추가**:
```json
{
  "dashboard_badge_streak7_name": "7일 연속",
  "dashboard_badge_streak7_description": "7일 연속으로 체크인을 완료했어요!",
  "dashboard_badge_streak14_name": "2주 연속",
  "dashboard_badge_streak30_name": "한 달 완주"
}
```

### 7.2 Push Notification

```dart
// 로컬 알림: ARB에서 관리
// lib/features/notification/application/dose_notification_usecase.dart

final message = l10n.tracking_dose_scheduledMessage(schedule.scheduledDoseMg);

// 주의: 백그라운드 알림은 context 없이 처리해야 함
// → lookupL10n() 사용 또는 SharedPreferences에서 locale 로드
```

### 7.3 법적 문서

```dart
// URL은 언어별로 동일 (서버에서 Accept-Language 헤더로 분기)
// 또는 URL에 locale 파라미터 추가
class LegalUrls {
  static String privacyPolicy(Locale locale) =>
    'https://your-domain.com/privacy?lang=${locale.languageCode}';
}
```

### 7.4 단위/포맷

| 항목 | 한국어 | 영어 |
|-----|-------|-----|
| 체중 | kg | kg (동일) |
| 용량 | mg | mg (동일) |
| 날짜 | 2024년 1월 15일 | Jan 15, 2024 |
| 시간 | 14:30 | 2:30 PM |

```dart
// DateFormat은 locale에 따라 자동 변환
DateFormat.yMMMd(locale).format(date)
```

---

## 8. 품질 보증

### 8.1 컴파일 타임 검증

```yaml
# l10n.yaml
nullable-getter: false  # null 반환 방지 → 컴파일 에러로 누락 감지
```

### 8.2 텍스트 Overflow 검증

```dart
// 1. 영어는 한국어보다 평균 30% 길어짐을 감안
// 2. 테스트 시 pseudo-localization 활용

// 개발 중 긴 텍스트 시뮬레이션
Text(
  kDebugMode ? '${text} [extended for testing]' : text,
  overflow: TextOverflow.ellipsis,
)
```

### 8.3 누락 키 검증 스크립트

```bash
# scripts/check_l10n.sh
flutter gen-l10n
grep -r "context.l10n\." lib/ | grep -v "generated" | \
  while read line; do
    key=$(echo $line | grep -oP 'l10n\.\K[a-zA-Z_]+')
    if ! grep -q "\"$key\"" lib/l10n/app_ko.arb; then
      echo "Missing key: $key"
    fi
  done
```

### 8.4 Fallback 전략

```dart
// gen_l10n은 지원하지 않는 locale에 대해 기본 locale(ko)로 fallback
// 추가 fallback은 불필요
```

---

## 9. 번역 워크플로우

### 9.1 초벌 번역 방식

**추천: AI + 수동 검수**

```
1. ARB 파일 완성 (한국어)
2. Claude/GPT로 영어 초벌 번역
3. 의료 용어 → 전문가 검수
4. 네이티브 스피커 검토
5. QA 테스트
```

### 9.2 ARB 관리

```
1. app_ko.arb가 Source of Truth
2. 키 추가 시 ko → en 순서
3. 번역 상태 추적: @description에 status 태그
   - "NEEDS_TRANSLATION"
   - "NEEDS_REVIEW"
   - "APPROVED"
```

---

## 10. 제약사항 준수

### CLAUDE.md 레이어 구조

```
✅ Presentation Layer에서만 context.l10n 사용
✅ Application Layer는 문자열 키(String)만 전달
✅ Domain Layer는 언어 무관 (순수 비즈니스 로직)

// 잘못된 예 (Application Layer에서 L10n 접근)
class SomeNotifier {
  void doSomething() {
    final message = context.l10n.someKey;  // ❌ context 접근 불가
  }
}

// 올바른 예
class SomeNotifier {
  void doSomething() {
    state = SomeState(messageKey: 'someKey');  // ✅ 키만 전달
  }
}

// Presentation에서 변환
Text(context.l10n.getMessage(state.messageKey))  // ✅
```

### checkin_strings.dart 점진적 마이그레이션

```
Phase 5에서:
1. ARB에 모든 키 추가
2. checkin_strings.dart → ARB 래퍼로 변경 (선택적)
3. 사용처를 context.l10n으로 점진적 변경
4. 모든 변경 완료 후 checkin_strings.dart 삭제
```

---

## 11. 예상 작업량

| Phase | 파일 수 | 문자열 수 | 난이도 |
|-------|--------|---------|-------|
| Phase 0 | 11 | 0 | 중간 (인프라) |
| Phase 1 | 4 | ~55 | 낮음 |
| Phase 2 | 5 | ~115 | 낮음 |
| Phase 3 | 7 | ~118 | 중간 |
| Phase 4 | 8 | ~125 | 중간 |
| Phase 5 | 7 | ~220 | 높음 (마이그레이션) |
| Phase 6 | 10 | ~190 | 중간 |
| Phase 7 | 11 | ~255 | 중간 |
| Phase 8 | 4 | ~245 | 높음 (의료 콘텐츠) |
| Phase 9 | 2 | ~40 | 낮음 |
| Phase 10 | 2 | ~20 | 낮음 |
| **합계** | **71** | **~1,383** | - |

---

## 12. 결정 사항 (확정)

| 항목 | 결정 | 상세 |
|-----|------|------|
| **언어 전환 방식** | 디바이스 감지 + 앱 내 설정 | 기본은 시스템 언어, Settings에서 수동 변경 가능 |
| **Badge 다국어** | 클라이언트 매핑 | ARB 파일에서 Badge ID → 문자열 매핑 |
| **배포 전략** | 전체 완료 후 배포 | Phase 0-10 모두 완료 후 단일 릴리스 |

---

## 13. 구현 순서 요약

```
Phase 0: 인프라 설정
    ↓
Phase 1-3: 공통/Settings/Auth (핵심 화면)
    ↓
Phase 4-7: Dashboard/Checkin/Tracking/Onboarding
    ↓
Phase 8-10: Coping Guide/Notification/Records
    ↓
전체 QA 테스트
    ↓
단일 릴리스 배포
```

---

## 14. 테스트 전략

### 14.1 테스트 헬퍼

```dart
// test/helpers/l10n_test_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/l10n/generated/app_localizations.dart';

class L10nTestHelper {
  /// 특정 locale로 Widget을 래핑
  static Widget wrapWithL10n(
    Widget child, {
    Locale locale = const Locale('ko'),
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }
}
```

### 14.2 다국어 UI 테스트 예시

```dart
// 한국어 테스트
testWidgets('displays Korean text', (tester) async {
  await tester.pumpWidget(
    L10nTestHelper.wrapWithL10n(
      const LogoutConfirmDialog(),
      locale: const Locale('ko'),
    ),
  );
  expect(find.text('로그아웃'), findsOneWidget);
});

// 영어 테스트
testWidgets('displays English text', (tester) async {
  await tester.pumpWidget(
    L10nTestHelper.wrapWithL10n(
      const LogoutConfirmDialog(),
      locale: const Locale('en'),
    ),
  );
  expect(find.text('Logout'), findsOneWidget);
});
```

### 14.3 Overflow 테스트

```dart
testWidgets('long English text does not overflow', (tester) async {
  // 작은 화면 시뮬레이션
  tester.binding.window.physicalSizeTestValue = const Size(300, 600);

  await tester.pumpWidget(
    L10nTestHelper.wrapWithL10n(
      const RedFlagGuidanceDialog(...),
      locale: const Locale('en'),
    ),
  );

  // overflow 없어야 함
  expect(tester.takeException(), isNull);
});
```

---

## 15. 에지 케이스 처리

### 15.1 언어 전환 시나리오

| 시나리오 | 처리 방법 |
|---------|---------|
| 시스템 언어 변경 중 다이얼로그 열림 | MaterialApp의 locale 변경으로 자동 리빌드 |
| 지원하지 않는 언어 (일본어 등) | localeResolutionCallback에서 ko로 fallback |
| 앱 재시작 시 언어 유지 | SharedPreferences에서 locale 복원 |

### 15.2 백그라운드 알림 처리

```dart
// context 없이 locale 접근
Future<void> scheduleNotification(DoseSchedule schedule) async {
  // SharedPreferences에서 직접 locale 읽기
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('app_locale') ?? 'ko';

  final message = _getLocalizedMessage(schedule, localeCode);
  await _notificationPlugin.show(message: message);
}

String _getLocalizedMessage(DoseSchedule schedule, String localeCode) {
  return switch (localeCode) {
    'en' => '${schedule.doseMg}mg dose time',
    _ => '${schedule.doseMg}mg 투여 시간입니다',
  };
}
```

### 15.3 부분 마이그레이션 관리

```markdown
<!-- docs/i18n-migration-status.md -->
| 파일 | 상태 | 남은 문자열 |
|------|------|-----------|
| daily_checkin_screen | ✅ 완료 | 0 |
| question_card | ⏳ 진행 중 | 15 |
| red_flag_guidance | ❌ 미시작 | 20 |
```

### 15.4 텍스트 Overflow 방지

```dart
// 모든 Dialog에 적용
Dialog(
  child: SingleChildScrollView(  // 스크롤 가능
    child: Column(
      children: [
        Text(
          message,
          maxLines: 10,  // 최대 줄 수 제한
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  ),
)
```

---

## 16. CI/CD 통합

### 16.1 ARB 검증 스크립트

```bash
#!/bin/bash
# scripts/validate_arb.sh
set -e

echo "🔍 Validating ARB files..."

# JSON 구조 검증
for file in lib/l10n/app_*.arb; do
  if ! jq empty "$file" 2>/dev/null; then
    echo "❌ Invalid JSON: $file"
    exit 1
  fi
done

# 키 일관성 검증
ko_keys=$(jq -r 'keys[] | select(startswith("@") | not)' lib/l10n/app_ko.arb | sort)
en_keys=$(jq -r 'keys[] | select(startswith("@") | not)' lib/l10n/app_en.arb | sort)

missing=$(comm -23 <(echo "$ko_keys") <(echo "$en_keys"))
if [ -n "$missing" ]; then
  echo "⚠️ Missing English keys:"
  echo "$missing"
fi

echo "✅ ARB validation passed"
```

### 16.2 GitHub Actions 설정

```yaml
# .github/workflows/i18n-check.yml
name: i18n Check
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter gen-l10n
      - run: chmod +x scripts/validate_arb.sh && ./scripts/validate_arb.sh
```

---

## 17. 검증 완료 체크리스트

### 배포 전 필수 확인

```
Phase 0 완료:
[ ] l10n.yaml 생성 및 설정 확인
[ ] flutter_localizations 의존성 추가
[ ] ARB 파일 JSON 유효성 검증
[ ] MaterialApp 설정 완료
[ ] LocaleNotifier 구현 및 테스트
[ ] 테스트 헬퍼 생성

의료 콘텐츠:
[ ] 증상명 번역표 21개 완성 (기본 10 + 추가 7 + Red Flag 4)
[ ] Red Flag 메시지 약사 2인 검수 완료
[ ] 영어 버전 네이티브 검토 완료
[ ] 법적 면책조항 영어판 작성

테스트:
[ ] 한국어/영어 UI 테스트 통과
[ ] Overflow 테스트 통과
[ ] 언어 전환 시나리오 테스트
[ ] CI/CD ARB 검증 통과
```

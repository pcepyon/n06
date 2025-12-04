# Phase 2: Settings & Profile

> 출처: docs/i18n-plan.md §5 Phase 2

## 개요

- **목적**: 설정 화면, 프로필 편집, 언어 설정 UI i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~115개

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 설정 화면 | `settings_screen.dart` | ~40 |
| 설정 메뉴 아이템 | `settings_menu_item_improved.dart` | ~15 |
| **언어 설정 추가** | `locale_notifier.dart`, `language_selector_dialog.dart` (신규) | ~10 |
| 프로필 편집 | `profile_edit_screen.dart`, `profile_edit_form.dart` | ~30 |
| 주간 목표 설정 | `weekly_goal_settings_screen.dart`, `weekly_goal_input_widget.dart` | ~20 |

---

## 언어 설정 UI 구현

### 언어 선택 옵션

```dart
enum AppLanguage {
  system,  // 시스템 기본값
  ko,      // 한국어
  en,      // English
}
```

### 언어 선택 UI

```dart
// Settings 화면 언어 선택 UI
ListTile(
  title: Text(context.l10n.settings_language_title),
  subtitle: Text(_getLanguageDisplayName(currentLocale)),
  onTap: () => _showLanguageSelector(context),
);
```

### ARB 키

```json
{
  "settings_language_title": "언어",
  "settings_language_system": "시스템 설정",
  "settings_language_ko": "한국어",
  "settings_language_en": "English"
}
```

---

## ARB 키 목록 (예상)

### 설정 화면

```json
{
  "settings_screen_title": "설정",
  "settings_section_account": "계정",
  "settings_section_app": "앱 설정",
  "settings_section_support": "지원",
  "settings_section_legal": "약관 및 정책"
}
```

### 설정 메뉴 아이템

```json
{
  "settings_menu_profile": "프로필 편집",
  "settings_menu_notification": "알림 설정",
  "settings_menu_language": "언어",
  "settings_menu_weeklyGoal": "주간 목표",
  "settings_menu_logout": "로그아웃",
  "settings_menu_deleteAccount": "계정 삭제",
  "settings_menu_termsOfService": "이용약관",
  "settings_menu_privacyPolicy": "개인정보처리방침",
  "settings_menu_version": "버전",
  "settings_menu_feedback": "피드백 보내기"
}
```

### 프로필 편집

```json
{
  "profile_edit_title": "프로필 편집",
  "profile_edit_nickname": "닉네임",
  "profile_edit_nicknameHint": "닉네임을 입력해주세요",
  "profile_edit_birthYear": "출생연도",
  "profile_edit_gender": "성별",
  "profile_edit_gender_male": "남성",
  "profile_edit_gender_female": "여성",
  "profile_edit_gender_other": "기타",
  "profile_edit_height": "키",
  "profile_edit_heightUnit": "cm",
  "profile_edit_saveSuccess": "프로필이 저장되었습니다"
}
```

### 주간 목표 설정

```json
{
  "weeklyGoal_title": "주간 목표 설정",
  "weeklyGoal_weightLoss": "체중 감량 목표",
  "weeklyGoal_weightLossHint": "주당 감량 목표 (kg)",
  "weeklyGoal_exercise": "운동 목표",
  "weeklyGoal_exerciseHint": "주당 운동 횟수"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/settings/presentation/
├── screens/
│   └── settings_screen.dart
├── widgets/
│   └── settings_menu_item_improved.dart

lib/features/profile/presentation/
├── screens/
│   ├── profile_edit_screen.dart
│   └── weekly_goal_settings_screen.dart
├── widgets/
│   ├── profile_edit_form.dart
│   └── weekly_goal_input_widget.dart
```

---

## 완료 기준

```
[ ] 설정 화면 문자열 ARB 추가 (ko, en)
[ ] 설정 메뉴 아이템 문자열 ARB 추가 (ko, en)
[ ] 언어 설정 UI 구현
[ ] 언어 선택 다이얼로그 구현
[ ] 프로필 편집 문자열 ARB 추가 (ko, en)
[ ] 주간 목표 설정 문자열 ARB 추가 (ko, en)
[ ] 모든 사용처 context.l10n으로 변경
[ ] 언어 전환 테스트 (한국어 ↔ 영어)
[ ] 빌드 성공
```

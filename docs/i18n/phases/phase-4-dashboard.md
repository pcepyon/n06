# Phase 4: Dashboard

> 출처: docs/i18n-plan.md §5 Phase 4

## 개요

- **목적**: 홈 대시보드, 인사말, 진행률 위젯 등 i18n
- **선행 조건**: Phase 0, Phase 1 완료
- **문자열 수**: ~125개

---

## 작업 목록

| 작업 | 파일 | 문자열 수 |
|-----|------|---------:|
| 홈 대시보드 | `home_dashboard_screen.dart` | ~20 |
| 인사말 위젯 | `emotional_greeting_widget.dart` | ~15 |
| 진행률 위젯 | `encouraging_progress_widget.dart` | ~25 |
| 일정 위젯 | `hopeful_schedule_widget.dart` | ~20 |
| 뱃지 위젯 | `celebratory_badge_widget.dart` | ~15 |
| 리포트 위젯 | `celebratory_report_widget.dart` | ~20 |

---

## 특수 처리: Badge 다국어

> 결정: 클라이언트 매핑 방식 사용

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
```

---

## ARB 키 목록 (예상)

### 홈 대시보드

```json
{
  "dashboard_title": "홈",
  "dashboard_welcomeBack": "다시 만나서 반가워요",
  "dashboard_todayStatus": "오늘의 상태"
}
```

### 인사말 위젯

```json
{
  "dashboard_greeting_morning": "좋은 아침이에요",
  "dashboard_greeting_afternoon": "오늘 하루 어떠세요?",
  "dashboard_greeting_evening": "오늘도 수고하셨어요"
}
```

### 진행률 위젯

```json
{
  "dashboard_progress_title": "이번 주 진행률",
  "dashboard_progress_checkinCount": "{count}회 체크인",
  "dashboard_progress_goalAchieved": "목표 달성!",
  "dashboard_progress_keepGoing": "조금만 더 힘내요"
}
```

### 일정 위젯

```json
{
  "dashboard_schedule_title": "다음 투약 일정",
  "dashboard_schedule_nextDose": "다음 투약",
  "dashboard_schedule_noDoseToday": "오늘 투약 일정이 없어요",
  "dashboard_schedule_doseTime": "{time}에 투약 예정"
}
```

### 뱃지 위젯

```json
{
  "dashboard_badge_title": "획득한 뱃지",
  "dashboard_badge_streak7_name": "7일 연속",
  "dashboard_badge_streak7_description": "7일 연속으로 체크인을 완료했어요!",
  "dashboard_badge_streak14_name": "2주 연속",
  "dashboard_badge_streak14_description": "2주 연속으로 체크인을 완료했어요!",
  "dashboard_badge_streak30_name": "한 달 완주",
  "dashboard_badge_streak30_description": "한 달 동안 꾸준히 체크인했어요!",
  "dashboard_badge_firstCheckin_name": "첫 체크인",
  "dashboard_badge_firstCheckin_description": "첫 번째 체크인을 완료했어요!",
  "dashboard_badge_weightGoal_name": "목표 달성",
  "dashboard_badge_weightGoal_description": "체중 목표를 달성했어요!"
}
```

### 리포트 위젯

```json
{
  "dashboard_report_title": "주간 리포트",
  "dashboard_report_weightChange": "체중 변화",
  "dashboard_report_symptomSummary": "증상 요약",
  "dashboard_report_viewDetail": "자세히 보기"
}
```

---

## 대상 파일 (경로 확인 필요)

```
lib/features/dashboard/presentation/
├── screens/
│   └── home_dashboard_screen.dart
├── widgets/
│   ├── emotional_greeting_widget.dart
│   ├── encouraging_progress_widget.dart
│   ├── hopeful_schedule_widget.dart
│   ├── celebratory_badge_widget.dart
│   └── celebratory_report_widget.dart
├── utils/
│   └── badge_l10n.dart (신규)
```

---

## 완료 기준

```
[ ] 홈 대시보드 문자열 ARB 추가 (ko, en)
[ ] 인사말 위젯 문자열 ARB 추가 (ko, en)
[ ] 진행률 위젯 문자열 ARB 추가 (ko, en)
[ ] 일정 위젯 문자열 ARB 추가 (ko, en)
[ ] 뱃지 위젯 문자열 ARB 추가 (ko, en)
[ ] Badge L10n 유틸 생성
[ ] 리포트 위젯 문자열 ARB 추가 (ko, en)
[ ] 모든 사용처 context.l10n으로 변경
[ ] 빌드 성공
```

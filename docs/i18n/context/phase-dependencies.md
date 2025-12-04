# Phase 의존성

> 출처: docs/i18n-plan.md §5, §13

## 의존성 그래프

```
Phase 0 (인프라)
    │
    ├──→ Phase 1 (공통 컴포넌트)
    │        │
    │        └──→ Phase 2-10 (common_* 키 사용)
    │
    ├──→ Phase 2 (Settings)
    │        │
    │        └──→ LocaleNotifier (언어 전환 기능)
    │
    ├──→ Phase 3 (Auth)
    │
    ├──→ Phase 4 (Dashboard)
    │
    ├──→ Phase 5 (Daily Checkin)
    │        │
    │        └──→ checkin_strings.dart 마이그레이션
    │
    ├──→ Phase 6 (Tracking)
    │
    ├──→ Phase 7 (Onboarding)
    │
    ├──→ Phase 8 (Coping Guide) ← 의료 콘텐츠 검수 필요
    │
    ├──→ Phase 9 (Notification) ← 백그라운드 알림 특수 처리
    │
    └──→ Phase 10 (Records)
```

---

## 필수 선행 조건

| Phase | 선행 조건 |
|-------|----------|
| 0 | 없음 |
| 1 | Phase 0 완료 (인프라) |
| 2 | Phase 0 완료, Phase 1 완료 (common_* 키) |
| 3 | Phase 0 완료, Phase 1 완료 |
| 4 | Phase 0 완료, Phase 1 완료 |
| 5 | Phase 0 완료, Phase 1 완료 |
| 6 | Phase 0 완료, Phase 1 완료 |
| 7 | Phase 0 완료, Phase 1 완료 |
| 8 | Phase 0 완료, Phase 1 완료, 의료 콘텐츠 검수 |
| 9 | Phase 0 완료, Phase 1 완료 |
| 10 | Phase 0 완료, Phase 1 완료 |

---

## Phase 0 완료 기준

Phase 0이 완료되지 않으면 다른 Phase 진행 불가:

```
[ ] l10n.yaml 생성
[ ] pubspec.yaml 수정 (flutter_localizations, generate: true)
[ ] lib/l10n/app_ko.arb 생성
[ ] lib/l10n/app_en.arb 생성
[ ] flutter gen-l10n 성공
[ ] L10n Extension 생성 (context.l10n)
[ ] MaterialApp 설정 완료
[ ] LocaleNotifier 생성
[ ] 테스트 헬퍼 생성
[ ] 빌드 성공 확인
```

---

## Phase 1 완료 기준

Phase 1이 완료되어야 common_* 키 사용 가능:

```
[ ] common_button_confirm
[ ] common_button_cancel
[ ] common_button_delete
[ ] common_button_save
[ ] common_button_close
[ ] common_error_networkFailed
[ ] common_error_unknown
... (공통 키들)
```

---

## 특수 의존성

### Phase 5: checkin_strings.dart 마이그레이션

```
1. ARB에 모든 키 추가
2. 사용처를 context.l10n으로 변경
3. 모든 참조 제거 확인
4. checkin_strings.dart 삭제
```

**주의**: 삭제 전 모든 참조가 제거되었는지 확인 필수

### Phase 8: 의료 콘텐츠

```
의료 콘텐츠 번역 전 검수 필요:
- Red Flag 메시지
- 증상명
- 대처법 가이드

검수자: 약사 2인 이상
```

### Phase 9: 백그라운드 알림

```
백그라운드에서는 BuildContext 없음
→ SharedPreferences에서 직접 locale 읽기
→ 별도 locale 처리 로직 필요
```

---

## 병렬 작업 가능 여부

Phase 0, 1 완료 후:

```
┌─────────────────────────────────────┐
│ 병렬 작업 가능:                      │
│  - Phase 2, 3, 4 (의존성 없음)       │
│  - Phase 5, 6, 7 (의존성 없음)       │
│  - Phase 10 (의존성 없음)            │
│                                     │
│ 순차 작업 필요:                      │
│  - Phase 8 (의료 검수 대기)          │
│  - Phase 9 (특수 처리 필요)          │
└─────────────────────────────────────┘
```

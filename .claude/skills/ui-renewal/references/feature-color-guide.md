# Feature Color Guide - 기능별 색상 적용 가이드

## 개요

이 가이드는 PRD의 감정적 UX 원칙을 색상으로 구현하기 위한 전략입니다.
기존 디자인 시스템의 색상을 **전략적으로 활용**하여 각 기능의 감정적 목표를 달성합니다.

---

## 1. Feature Color Mapping

### 핵심 원칙

| 감정 목표 | 색상 | Hex | 사용 컨텍스트 |
|----------|------|-----|--------------|
| **성장/건강** | Primary (Green) | `#4ADE80` | 투여 완료, 건강 지표, 기본 CTA |
| **성취/자부심** | Gold (Amber) | `#F59E0B` | 뱃지, 마일스톤, 연속 기록, 축하 |
| **안심/신뢰** | Info (Blue) | `#3B82F6` | 대처 가이드, 팁, 교육 콘텐츠 |
| **연결/회고** | Purple | `#8B5CF6` | 타임라인, 기록 히스토리, 차트 |
| **따뜻함/환영** | Warm (Orange) | `#F97316` | 복귀 메시지, 응원, 격려 |
| **위험/경고** | Error (Red) | `#EF4444` | 심각 증상, 필수 알림, 삭제 |
| **주의/확인** | Warning (Amber) | `#F59E0B` | 미완료, 확인 필요 항목 |

### app_colors.dart 추가 상수

```dart
// ============================================
// Feature Colors (감정적 UX 매핑)
// ============================================

/// 성취/마일스톤: 뱃지, 축하, 연속 기록
static const Color achievement = gold;  // #F59E0B

/// 따뜻한 환영: 복귀 메시지, 격려
static const Color warmWelcome = Color(0xFFF97316);  // Orange-500

/// 교육/안내: 대처 가이드, 팁
static const Color education = info;  // #3B82F6

/// 기록/회고: 타임라인, 히스토리
static const Color history = Color(0xFF8B5CF6);  // Purple-500

/// 연속 기록 배경
static const Color streakBackground = Color(0xFFFEF3C7);  // Amber-100

/// 환영 메시지 배경
static const Color welcomeBackground = Color(0xFFFFF7ED);  // Orange-50

/// 교육 콘텐츠 배경
static const Color educationBackground = Color(0xFFEFF6FF);  // Blue-50

/// 히스토리 배경
static const Color historyBackground = Color(0xFFF5F3FF);  // Purple-50
```

---

## 2. Feature별 색상 적용 가이드

### 2.1 Dashboard (홈 대시보드)

**감정 목표:** 성취감, 동기부여, 연결감

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 연속 기록 뱃지 | Primary | **Achievement** | Gold `#F59E0B` |
| 주간 진행률 100% | Primary | **Achievement** | Gold `#F59E0B` |
| 오늘의 인사 (복귀) | Neutral | **WarmWelcome** | Orange `#F97316` |
| 팁/가이드 카드 | Primary | **Education** | Blue `#3B82F6` |
| 투여 완료 버튼 | Primary | Primary 유지 | Green `#4ADE80` |
| 타임라인 | Neutral | **History** | Purple `#8B5CF6` |

### 2.2 Tracking (기록)

**감정 목표:** 성취감, 꾸준함 인정

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 투여 완료 | Primary | Primary 유지 | Green `#4ADE80` |
| 연속 투여 표시 | Primary | **Achievement** | Gold `#F59E0B` |
| 증상 기록 완료 | Primary | Primary 유지 | Green `#4ADE80` |
| 트렌드 차트 | Primary만 | **다중 색상** | Chart Colors |
| 투여 스케줄 알림 | Neutral | **Education** | Blue `#3B82F6` |

### 2.3 Coping Guide (대처 가이드)

**감정 목표:** 안심, 신뢰

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 가이드 카드 | Primary | **Education** | Blue `#3B82F6` |
| 안심 메시지 | Neutral | **Education** 배경 | Blue-50 `#EFF6FF` |
| 대처법 리스트 | Primary | **Education** | Blue `#3B82F6` |
| 전문가 상담 권유 | Neutral | **Info** | Blue `#3B82F6` |
| 응급 증상 경고 | Primary | **Error** | Red `#EF4444` |

### 2.4 Onboarding (온보딩)

**감정 목표:** 희망, 안심, 환영

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 환영 메시지 | Primary | **WarmWelcome** | Orange `#F97316` |
| 교육 콘텐츠 | Primary | **Education** | Blue `#3B82F6` |
| 진행 완료 표시 | Primary | Primary 유지 | Green `#4ADE80` |
| 여정 로드맵 | Primary | **History** | Purple `#8B5CF6` |
| 두려움 정상화 | Neutral | **WarmWelcome** 배경 | Orange-50 |

### 2.5 Authentication (인증)

**감정 목표:** 신뢰, 안정

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 로그인 버튼 | Primary | Primary 유지 | Green `#4ADE80` |
| 입력 필드 포커스 | Primary | Primary 유지 | Green `#4ADE80` |
| 에러 메시지 | Error | Error 유지 | Red `#EF4444` |

### 2.6 Settings / Profile

**감정 목표:** 안정, 신뢰

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 설정 항목 | Neutral | Neutral 유지 | 기존 유지 |
| 저장 버튼 | Primary | Primary 유지 | Green `#4ADE80` |
| 위험한 액션 (탈퇴 등) | Primary | **Error** | Red `#EF4444` |

### 2.7 Data Sharing (데이터 공유)

**감정 목표:** 주도권, 신뢰

| 컴포넌트 | 현재 | 개선 | 색상 |
|---------|-----|------|------|
| 공유 모드 활성화 | Primary | **Education** | Blue `#3B82F6` |
| 데이터 카드 | Neutral | **History** 배경 | Purple-50 |
| 안내 메시지 | Neutral | **Education** | Blue `#3B82F6` |

---

## 3. 구현 우선순위

### Phase 0: 기반 작업 (필수)
1. `app_colors.dart`에 Feature Color 상수 추가
2. 디자인 시스템 문서에 Feature Color Mapping 섹션 추가
3. ui-renewal skill에 본 가이드 추가 (완료)

### Phase 1: Dashboard (최우선)
- 사용자가 가장 많이 보는 화면
- 성취감/동기부여가 핵심인 화면
- 예상 작업: 연속 기록 뱃지, 주간 진행률, 인사 메시지

### Phase 2: Tracking
- 핵심 기능 영역
- 연속 투여 표시, 트렌드 차트 다양화

### Phase 3: Coping Guide
- 안심감이 핵심인 영역
- 전체를 Education(Blue) 계열로 전환

### Phase 4: Onboarding
- 첫인상 결정
- 환영/교육 색상 적용

### Phase 5: 나머지
- Authentication, Settings, Profile, Data Sharing
- 대부분 기존 유지, 포인트만 개선

---

## 4. 신규 기능 개발 시 적용 규칙

### 색상 선택 의사결정 트리

```
새로운 UI 요소를 만들 때:

1. 이 요소의 감정적 목표는?
   ├─ 성취/축하 → Achievement (Gold)
   ├─ 안심/교육 → Education (Blue)
   ├─ 환영/격려 → WarmWelcome (Orange)
   ├─ 회고/연결 → History (Purple)
   ├─ 건강/완료 → Primary (Green)
   ├─ 위험/경고 → Error (Red)
   └─ 중립/설정 → Neutral

2. 배경색이 필요하면?
   → 해당 색상의 50 또는 100 톤 사용
   예: Achievement → Amber-100 (#FEF3C7)

3. 아이콘/텍스트 색상은?
   → 해당 색상의 500 또는 600 톤 사용
```

### 필수 체크리스트

신규 화면/컴포넌트 개발 시:

- [ ] PRD의 해당 터치포인트 감정 목표 확인
- [ ] Feature Color Mapping에서 적합한 색상 선택
- [ ] AppColors 상수 사용 (하드코딩 금지)
- [ ] 한 화면에 3개 이상의 포인트 색상 사용 지양
- [ ] Primary는 CTA/완료 액션에만 사용

---

## 5. 색상 사용 금지 사항

1. **하드코딩 금지**: `Color(0xFF...)` 직접 사용 금지, 반드시 `AppColors.xxx` 사용
2. **Primary 남용 금지**: 모든 강조에 Primary 사용 금지
3. **과도한 색상 금지**: 한 화면에 4개 이상의 포인트 색상 사용 금지
4. **의미 없는 색상 금지**: 감정적 목표 없이 "예쁘니까" 색상 사용 금지

---

## 6. 참고: PRD 감정 목표 매핑

| PRD 터치포인트 | 예상 감정 | 목표 감정 | 적용 색상 |
|--------------|----------|----------|----------|
| 첫 로그인 | 기대+불안 | 희망 | WarmWelcome |
| 부작용 기록 | 불안 | 안심 | Education |
| 체중 정체 | 좌절 | 인내 | Education |
| 투여 완료 | 뿌듯함 | 성취 | Primary → Achievement |
| 공백 후 복귀 | 죄책감 | 수용 | WarmWelcome |
| 마일스톤 달성 | 성취감 | 자부심 | Achievement |

---

**Last Updated:** 2024-12-01
**Version:** 1.0

# DoseScheduleScreen 구현 가이드

## 구현 요약

승인된 개선 제안에 따라, 이 가이드는 DoseScheduleScreen의 정확한 구현 명세를 제공합니다.

**구현 대상 변경사항:**
1. 상태별 색상 시스템을 가비움 의미 색상으로 통일
2. 카드 컨테이너를 가비움 Card 컴포넌트로 표준화
3. 타이포그래피 계층을 가비움 Type Scale로 강화
4. 상태 표시를 아이콘 + 배지 조합으로 개선
5. 버튼을 가비움 Button 컴포넌트로 표준화
6. Empty State를 가비움 패턴으로 강화
7. Dialog를 가비움 Modal 컴포넌트로 재설계
8. 여백(Spacing) 시스템을 가비움 Spacing Scale로 통일
9. 로딩 상태의 시각적 강화

---

## 설계 토큰 값

| 요소 | 토큰 경로 | 값 | 사용처 |
|------|---------|-----|-------|
| Success 배경 | Colors - Semantic - Success | `#10B981` | 완료된 투여 배경 |
| Success 밝은 배경 | Colors - Semantic - Success Light | `#ECFDF5` | 완료 배지 배경 |
| Success 진한 텍스트 | Colors - Semantic - Success Dark | `#065F46` | 완료 배지 텍스트 |
| Error 배경 | Colors - Semantic - Error | `#EF4444` | 연체된 투여 배경 |
| Error 밝은 배경 | Colors - Semantic - Error Light | `#FEF2F2` | 에러 배지 배경 |
| Error 진한 텍스트 | Colors - Semantic - Error Dark | `#991B1B` | 에러 배지 텍스트 |
| Warning 배경 | Colors - Semantic - Warning | `#F59E0B` | 오늘 투여 배경 |
| Warning 밝은 배경 | Colors - Semantic - Warning Light | `#FFFBEB` | 경고 배지 배경 |
| Warning 진한 텍스트 | Colors - Semantic - Warning Dark | `#92400E` | 경고 배지 텍스트 |
| Info 배경 | Colors - Semantic - Info | `#3B82F6` | 예정 투여 배경 |
| Info 밝은 배경 | Colors - Semantic - Info Light | `#EFF6FF` | 정보 배지 배경 |
| Info 진한 텍스트 | Colors - Semantic - Info Dark | `#1E40AF` | 정보 배지 텍스트 |
| Primary | Colors - Primary | `#4ADE80` | CTA 버튼, 진행 표시 |
| Primary Hover | Colors - Primary Hover | `#22C55E` | 호버 상태 |
| Primary Active | Colors - Primary Active | `#16A34A` | 활성 상태 |
| Primary Disabled | Colors - Primary Disabled | `#4ADE80` at 40% | 비활성 상태 |
| Neutral-50 | Colors - Neutral - 50 | `#F8FAFC` | 앱 배경 |
| Neutral-100 | Colors - Neutral - 100 | `#F1F5F9` | 카드 배경 |
| Neutral-200 | Colors - Neutral - 200 | `#E2E8F0` | 구분선, 테두리 |
| Neutral-300 | Colors - Neutral - 300 | `#CBD5E1` | 기본 테두리, Empty State 아이콘 |
| Neutral-500 | Colors - Neutral - 500 | `#64748B` | 보조 텍스트 |
| Neutral-700 | Colors - Neutral - 700 | `#334155` | 본문 텍스트, Empty State 제목 |
| Neutral-800 | Colors - Neutral - 800 | `#1E293B` | 제목 텍스트 |
| Neutral-900 | Colors - Neutral - 900 | `#0F172A` | 그림자 기조 |
| Card 배경 | Layout - Card | `#FFFFFF` | 카드 컨테이너 |
| Card 테두리 | Layout - Card | `#E2E8F0` (Neutral-200) | 카드 테두리 |
| Card 그림자 | Layout - Card | sm (0 2px 4px rgba(15,23,42,0.06)) | 카드 그림자 기본 |
| Card 호버 그림자 | Layout - Card | md (0 4px 8px rgba(15,23,42,0.08)) | 카드 호버 그림자 |
| Heading xl | Typography - xl | 20px, Semibold | 카드 제목 (투여량) |
| Body base | Typography - base | 16px, Regular | 기본 텍스트 (날짜) |
| Label sm | Typography - sm | 14px, Regular | 라벨, 보조 텍스트 |
| Heading lg | Typography - lg | 18px, Semibold | Empty State 제목 |
| Heading 2xl | Typography - 2xl | 24px, Bold | 다이얼로그 제목 |
| Button Primary BG | Buttons - Primary | `#4ADE80` | CTA 버튼 배경 |
| Button Primary Text | Buttons - Primary | `#FFFFFF`, Semibold | CTA 버튼 텍스트 |
| Button Secondary BG | Buttons - Secondary | Transparent | 보조 버튼 배경 |
| Button Secondary Border | Buttons - Secondary | 2px solid `#4ADE80` | 보조 버튼 테두리 |
| Border Radius sm | Visual - Border Radius | 8px | 버튼, 입력 필드 |
| Border Radius md | Visual - Border Radius | 12px | 카드 |
| Border Radius lg | Visual - Border Radius | 16px | 다이얼로그 |
| Shadow sm | Visual - Shadow | 0 2px 4px rgba(15,23,42,0.06), 0 1px 2px rgba(15,23,42,0.04) | 버튼, 작은 카드 |
| Shadow md | Visual - Shadow | 0 4px 8px rgba(15,23,42,0.08), 0 2px 4px rgba(15,23,42,0.04) | 기본 카드 |
| Shadow xl | Visual - Shadow | 0 16px 32px rgba(15,23,42,0.12), 0 8px 16px rgba(15,23,42,0.08) | 다이얼로그 |
| Spacing xs | Spacing | 4px | 텍스트-아이콘 간격 |
| Spacing sm | Spacing | 8px | 컴포넌트 내부 패딩 |
| Spacing md | Spacing | 16px | 기본 요소 간 간격, 카드 패딩 |
| Spacing lg | Spacing | 24px | 섹션 간 여백, 다이얼로그 패딩 |
| Spacing xl | Spacing | 32px | 주요 섹션 구분, 페이지 상하 여백 |
| Transition | Visual - Transitions | 200ms, cubic-bezier(0.4, 0, 0.2, 1) | 상태 전환, 애니메이션 |
| Opacity Disabled | Visual - Opacity | 0.4 | 비활성 요소 |

---

## 컴포넌트 명세

### Change 1: 상태별 색상 시스템을 가비움 의미 색상으로 통일

**컴포넌트 타입:** 상태 색상 시스템 (Semantic Color System)

**색상 매핑:**
- 완료된 투여 → Success: `#10B981` (Emerald-500)
- 연체된 투여 → Error: `#EF4444` (Red-500)
- 오늘 투여 → Warning: `#F59E0B` (Amber-500)
- 예정된 투여 → Info: `#3B82F6` (Blue-500)

**적용 대상:**
- DoseScheduleCard 배경색
- StatusBadge 배경색
- 상태별 텍스트 색상

**시각적 명세:**
- 배경: 위 색상에 40% 투명도 추가 (의미 색상 밝게) 또는 전용 밝은 색상 사용
  - Success: `#ECFDF5` (밝은 배경) + `#10B981` 테두리
  - Error: `#FEF2F2` (밝은 배경) + `#EF4444` 테두리
  - Warning: `#FFFBEB` (밝은 배경) + `#F59E0B` 테두리
  - Info: `#EFF6FF` (밝은 배경) + `#3B82F6` 테두리
- 텍스트 색상 (진한 계열):
  - Success: `#065F46`
  - Error: `#991B1B`
  - Warning: `#92400E`
  - Info: `#1E40AF`
- 테두리: 1px solid (각 색상의 기본값)

**접근성:**
- 색상 + 아이콘 + 텍스트 조합으로 색맹 사용자도 구분 가능
- 색상 대비: 모든 조합이 WCAG AA 기준 충족 (4.5:1 이상)

---

### Change 2: 카드 컨테이너를 가비움 Card 컴포넌트로 표준화

**컴포넌트 타입:** Card Container

**시각적 명세:**

**기본 상태:**
- 배경: `#FFFFFF`
- 테두리: 1px solid `#E2E8F0` (Neutral-200)
- Border Radius: 12px (md)
- 그림자: sm (0 2px 4px rgba(15,23,42,0.06), 0 1px 2px rgba(15,23,42,0.04))
- 패딩: 16px (md) - 상하좌우 균일
- 여백: 16px (md) 하단 여백 (카드 간 간격)

**크기:**
- 너비: 100% (컨테이너)
- 최소 높이: auto (컨텐츠에 따라)
- 최대 너비: 제한 없음

**호버 상태:**
- 그림자: md (0 4px 8px rgba(15,23,42,0.08), 0 2px 4px rgba(15,23,42,0.04))
- Transform: translateY(-2px) (2px 위로 이동)
- Transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1)
- Cursor: pointer

**활성/클릭 상태:**
- 그림자: sm (기본값으로 돌아감)
- Transform: translateY(0) (원위치)

**비활성 상태:**
- Opacity: 0.4
- Cursor: not-allowed

**컨텐츠 구조:**
```
┌─ Card Container (padding: 16px)
  ├─ [상단] 투여량 (xl, Semibold)
  ├─ [중단] 예정 날짜 (base, Regular)
  ├─ [중단] StatusBadge (의미 색상별)
  └─ [하단] 액션 버튼 또는 상태 표시
```

---

### Change 3: 타이포그래피 계층을 가비움 Type Scale로 강화

**컴포넌트 타입:** Typography System

**사용되는 타입:**

**3xl (28px, Bold)**
- 사용처: 페이지 주 제목 (현재 화면에서는 미사용)
- 줄 높이: 36px
- 문자 간격: -0.02em

**2xl (24px, Bold)**
- 사용처: 다이얼로그 제목
- 줄 높이: 32px
- 문자 간격: -0.01em
- 예: "투여 기록" (다이얼로그 헤더)

**xl (20px, Semibold)**
- 사용처: 카드 제목
- 줄 높이: 28px
- 문자 간격: 0
- 예: "2.5 mg" (DoseScheduleCard 상단)

**lg (18px, Semibold)**
- 사용처: Empty State 제목
- 줄 높이: 26px
- 문자 간격: 0
- 예: "투여 계획이 없습니다"

**base (16px, Regular)**
- 사용처: 본문 텍스트, 기본 UI 텍스트
- 줄 높이: 24px
- 문자 간격: 0
- 예: "11월 24일 (일)" (카드 날짜), Empty State 설명

**sm (14px, Regular)**
- 사용처: 보조 텍스트, 라벨, 설명
- 줄 높이: 20px
- 문자 간격: 0
- 예: StatusBadge 텍스트 "완료됨"

**xs (12px, Regular)**
- 사용처: 캡션, 메타데이터 (현재 화면에서는 미사용)
- 줄 높이: 16px
- 문자 간격: 0.01em

**색상 적용:**
- xl, lg: `#1E293B` (Neutral-800) - 강조
- base: `#334155` (Neutral-700) - 본문
- sm: `#64748B` (Neutral-500) - 보조
- xs: `#64748B` (Neutral-500) - 보조

---

### Change 4: 상태 표시를 아이콘 + 배지 조합으로 개선

**컴포넌트 타입:** StatusBadge (새로 생성)

**변형 종류:** Success, Error, Warning, Info

**Success 배지:**
- 배경: `#ECFDF5` (Success 밝은 배경)
- 텍스트: `#065F46` (Success 진한 텍스트), 14px (sm), Regular
- 테두리: 1px solid `#10B981` (Success)
- 아이콘: check-circle (20x20px), `#10B981`
- 패딩: 8px 12px (아이콘 포함하여 최소 44x44px 터치 영역)
- Border Radius: 8px (sm)
- 아이콘-텍스트 간격: 8px (sm)
- 표시 텍스트: "완료됨" 또는 "✓"

**Error 배지:**
- 배경: `#FEF2F2` (Error 밝은 배경)
- 텍스트: `#991B1B` (Error 진한 텍스트), 14px (sm), Regular
- 테두리: 1px solid `#EF4444` (Error)
- 아이콘: alert-circle (20x20px), `#EF4444`
- 패딩: 8px 12px
- Border Radius: 8px (sm)
- 아이콘-텍스트 간격: 8px (sm)
- 표시 텍스트: "연체됨" 또는 "⚠"

**Warning 배지:**
- 배경: `#FFFBEB` (Warning 밝은 배경)
- 텍스트: `#92400E` (Warning 진한 텍스트), 14px (sm), Regular
- 테두리: 1px solid `#F59E0B` (Warning)
- 아이콘: flag (20x20px), `#F59E0B`
- 패딩: 8px 12px
- Border Radius: 8px (sm)
- 아이콘-텍스트 간격: 8px (sm)
- 표시 텍스트: "오늘" 또는 "◐"

**Info 배지:**
- 배경: `#EFF6FF` (Info 밝은 배경)
- 텍스트: `#1E40AF` (Info 진한 텍스트), 14px (sm), Regular
- 테두리: 1px solid `#3B82F6` (Info)
- 아이콘: clock (20x20px), `#3B82F6`
- 패딩: 8px 12px
- Border Radius: 8px (sm)
- 아이콘-텍스트 간격: 8px (sm)
- 표시 텍스트: "예정" 또는 "○"

**호버 상태:**
- 배경 투명도 증가: 기본 배경에서 -5% 밝기
- 테두리 색상: 기본 색상에서 +10% 진하게

**터치 영역:**
- 최소 44x44px 확보
- 패딩으로 확대 필요 시 적용

---

### Change 5: 버튼을 가비움 Button 컴포넌트로 표준화

**컴포넌트 타입:** GabiumButton (기존 재사용)

**Primary Button ("기록", "저장"):**

**기본 상태:**
- 배경: `#4ADE80` (Primary)
- 텍스트: `#FFFFFF`, Semibold (600), 16px (base)
- 높이: 44px (Medium)
- 패딩: 24px 수평, 10px 수직 (높이 44px 유지)
- Border Radius: 8px (sm)
- 그림자: sm (0 2px 4px rgba(15,23,42,0.06), 0 1px 2px rgba(15,23,42,0.04))
- 테두리: None

**호버 상태:**
- 배경: `#22C55E` (Primary Hover)
- 그림자: md (0 4px 8px rgba(15,23,42,0.08), 0 2px 4px rgba(15,23,42,0.04))
- Cursor: pointer
- Transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1)

**활성 상태:**
- 배경: `#16A34A` (Primary Active)
- 그림자: sm

**비활성 상태:**
- 배경: `#4ADE80` at 40% opacity
- 텍스트: `#FFFFFF` at 50% opacity
- Cursor: not-allowed

**로딩 상태:**
- 배경: `#4ADE80` (유지)
- 텍스트 대체: 16px 스피너 (`#FFFFFF`)
- 스피너 애니메이션: 1s linear infinite rotation

**Secondary Button ("취소"):**

**기본 상태:**
- 배경: Transparent
- 텍스트: `#4ADE80` (Primary), Semibold (600), 16px (base)
- 높이: 44px (Medium)
- 패딩: 24px 수평, 10px 수직
- Border Radius: 8px (sm)
- 테두리: 2px solid `#4ADE80`
- 그림자: None

**호버 상태:**
- 배경: `#4ADE80` at 8% opacity
- 텍스트 색상: `#22C55E`
- 테두리: 2px solid `#22C55E`
- Cursor: pointer
- Transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1)

**활성 상태:**
- 배경: `#4ADE80` at 12% opacity
- 텍스트 색상: `#16A34A`
- 테두리: 2px solid `#16A34A`

**비활성 상태:**
- 텍스트: `#4ADE80` at 40% opacity
- 테두리: 2px solid `#4ADE80` at 40% opacity
- Cursor: not-allowed

---

### Change 6: Empty State를 가비움 패턴으로 강화

**컴포넌트 타입:** EmptyStateWidget (새로 생성)

**컨테이너:**
- 정렬: 중앙 (수직 + 수평)
- 패딩: xl (32px) 상하, 16px (md) 좌우
- 배경: `#F8FAFC` (Neutral-50)

**아이콘:**
- 크기: 120x120px
- 색상: `#CBD5E1` (Neutral-300)
- 패딩 하단: 24px (lg)

**제목:**
- 크기: lg (18px, Semibold)
- 색상: `#334155` (Neutral-700)
- 패딩 하단: 12px (sm)
- 예: "투여 계획이 없습니다"

**설명:**
- 크기: base (16px, Regular)
- 색상: `#64748B` (Neutral-500)
- 줄 높이: 24px
- 최대 너비: 320px (가독성)
- 패딩 하단: 24px (lg)
- 예: "온보딩을 완료하여 투여 일정을 등록해주세요"

**CTA 버튼 (선택사항):**
- Primary Button 스타일
- 패딩 상단: 24px (lg)

**요소 간 간격:**
- 모든 요소 간: 24px (lg)

**호버 상태:**
- 버튼이 있는 경우만 적용

---

### Change 7: Dialog를 가비움 Modal 컴포넌트로 재설계

**컴포넌트 타입:** Modal/Dialog

**기본 스타일:**

**배경 (Backdrop):**
- 색상: rgba(15, 23, 42, 0.5) (Neutral-900 at 50%)
- Transition: Fade-in 200ms

**다이얼로그 박스:**
- 최대 너비: 480px (데스크탑/태블릿)
- 모바일: 90% viewport 너비 (좌우 5% margin)
- 패딩: 24px (lg)
- Border Radius: 16px (lg)
- 그림자: xl (0 16px 32px rgba(15,23,42,0.12), 0 8px 16px rgba(15,23,42,0.08))
- 배경: `#FFFFFF`
- Transition: Scale-up + Fade-in 200ms cubic-bezier(0.4, 0, 0.2, 1)

**헤더 섹션:**
- 패딩 하단: 16px (md)
- 제목: 2xl (24px, Bold), `#1E293B` (Neutral-800)
- 닫기 버튼: 44x44px 아이콘 버튼, 상단우측, Ghost 스타일

**바디 섹션:**
- 패딩: 24px (lg) 상하
- 텍스트: base (16px, Regular), `#334155` (Neutral-700)
- 최대 높이: 60vh (스크롤 가능)
- 콘텐츠:
  - 주사 부위 선택 위젯 (투여량 정보 포함)
  - 메모 입력 필드 (선택사항)

**푸터 섹션:**
- 패딩 상단: 24px (lg)
- 정렬: 우측 정렬
- 버튼 간격: 16px (md)
- 버튼: [취소 (Secondary)] [저장 (Primary)]

**애니메이션:**
- Backdrop: Fade-in 200ms
- Modal: Scale 0.95 → 1.0, Fade-in 200ms
- Easing: cubic-bezier(0.4, 0, 0.2, 1)

**접근성:**
- ARIA label: "투여 기록 다이얼로그"
- Keyboard: Esc로 닫기, Tab 네비게이션
- Focus 관리: 열 때 제목으로 포커스, 닫을 때 트리거 버튼으로 복귀

---

### Change 8: 여백(Spacing) 시스템을 가비움 Spacing Scale로 통일

**컴포넌트 타입:** Spacing System

**적용 대상:**

**xs (4px):**
- 텍스트와 아이콘 간격 (StatusBadge 내부)

**sm (8px):**
- 컴포넌트 내부 패딩 (버튼 내 아이콘-텍스트)
- 폼 요소 내부 간격

**md (16px):**
- 카드 간 여백 (ListView 아이템)
- 카드 내부 패딩 (DoseScheduleCard)
- 요소 간 기본 간격

**lg (24px):**
- 섹션 간 여백 (카드 그룹 간)
- 다이얼로그 패딩
- Empty State 요소 간 간격

**xl (32px):**
- 페이지 상하 여백
- 주요 섹션 구분

**레이아웃 구조:**

```
Page (padding: xl 32px 상하, md 16px 좌우)
├── AppBar (고정)
│
├── Content (ListView.builder)
│   │
│   ├── DoseScheduleCard (margin-bottom: md 16px)
│   │   ├── Dose Amount (xl, Semibold)
│   │   ├── Scheduled Date (margin-top: sm 8px)
│   │   ├── StatusBadge (margin-top: sm 8px)
│   │   └── Action Button (margin-top: md 16px)
│   │
│   ├── [다음 카드...]
│   │
│   └── EmptyState (조건: 일정 없음)
│       ├── Icon
│       ├── Title (margin-top: lg 24px)
│       ├── Description (margin-top: lg 24px)
│       └── CTA Button (margin-top: lg 24px)
│
└── DoseRecordDialog (Modal)
    ├── Header (padding-bottom: md 16px)
    ├── Body (padding: lg 24px 상하)
    └── Footer (padding-top: lg 24px)
```

---

### Change 9: 로딩 상태의 시각적 강화

**컴포넌트 타입:** Loading Indicator (Spinner)

**풀페이지 로딩:**
- 크기: 48px (Large)
- 색상: `#4ADE80` (Primary)
- 애니메이션: 1s linear infinite rotation
- 배치: 중앙 (수직 + 수평)
- 배경: `#F8FAFC` (Neutral-50) with 50% opacity overlay

**버튼 내 로딩:**
- 크기: 16px (Small)
- 색상: `#FFFFFF` (Primary Button 내)
- 애니메이션: 1s linear infinite rotation
- 배치: 버튼 왼쪽, 텍스트 앞
- 텍스트 간격: 8px (sm)
- 텍스트: "저장 중..." (선택사항)

**카드 내 로딩 (조건부):**
- 크기: 24px (Medium)
- 색상: `#4ADE80` (Primary)
- 배치: 카드 오른쪽
- 불투명도: 0.6

**Transition:**
- 지속 시간: 1s
- 타입: linear infinite rotation
- 시작 각도: 0deg
- 종료 각도: 360deg

**상태 전환:**
- 로딩 중 → 완료: 로더 제거, 체크마크 표시 (0.5s)
- 로딩 중 → 에러: 로더 제거, 에러 아이콘 표시 (0.5s)

---

## 레이아웃 명세

### 전체 화면 구조

```
┌─────────────────────────────────────────┐
│ AppBar (56px)                           │
│ 투여 스케줄                             │
├─────────────────────────────────────────┤
│ ListView.builder (가변 높이)            │
│                                         │
│ [각 아이템]                             │
│ ┌─────────────────────────────────────┐│
│ │ DoseScheduleCard                    ││
│ │ ├─ Dose Amount (xl, Semibold)      ││
│ │ │  2.5 mg                           ││
│ │ ├─ Scheduled Date (base, Regular)  ││
│ │ │  11월 24일 (일)                   ││
│ │ ├─ StatusBadge                      ││
│ │ │  [Success/Error/Warning/Info]     ││
│ │ └─ Action Button (Primary)          ││
│ │    기록 (44px height)               ││
│ └─────────────────────────────────────┘│
│                                         │
│ [다음 카드...]                         │
│                                         │
│ 또는 EmptyState (일정 없음 시)         │
│ ┌─────────────────────────────────────┐│
│ │     [Icon: 120x120px]               ││
│ │                                      ││
│ │  투여 계획이 없습니다                 ││
│ │  (lg, Semibold)                     ││
│ │                                      ││
│ │ 온보딩을 완료하여 투여 일정을        ││
│ │ 등록해주세요                         ││
│ │ (base, Regular)                     ││
│ └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

### DoseScheduleCard 상세 구조

```
┌─ Card Container (radius: 12px, shadow: sm)
│   padding: 16px md
│
│  ┌─────────────────────────────────────┐
│  │ Dose Amount                         │
│  │ 2.5 mg (20px, Semibold)            │
│  │ Color: #1E293B (Neutral-800)        │
│  │ margin-bottom: 8px sm               │
│  └─────────────────────────────────────┘
│
│  ┌─────────────────────────────────────┐
│  │ Scheduled Date                      │
│  │ 11월 24일 (일) (16px, Regular)      │
│  │ Color: #334155 (Neutral-700)        │
│  │ margin-bottom: 8px sm               │
│  └─────────────────────────────────────┘
│
│  ┌─────────────────────────────────────┐
│  │ StatusBadge (의미 색상별)           │
│  │ [success/error/warning/info]       │
│  │ margin-bottom: 16px md              │
│  └─────────────────────────────────────┘
│
│  ┌─────────────────────────────────────┐
│  │ Action Button (Primary)             │
│  │ 기록 (44px height, 24px h-padding)  │
│  │ Background: #4ADE80                 │
│  │ On Hover: shadow md, translateY(-2px)
│  └─────────────────────────────────────┘
│
└─ Card Container End
   margin-bottom: 16px md (다음 카드와의 거리)
```

### StatusBadge 상세 구조

```
┌─ Badge Container
│   padding: 8px 12px (flex, center aligned)
│   border-radius: 8px sm
│   min-height: 44px (터치 영역)
│
│  ┌─ Icon (20x20px)
│  │  Color: [semantic color]
│  │  margin-right: 8px sm
│  │
│  ├─ Text (14px, Regular)
│  │  "완료됨" | "연체됨" | "오늘" | "예정"
│  │  Color: [semantic dark color]
│  │
│  └─ Background: [semantic light color]
│     Border: 1px solid [semantic color]
│
└─ Badge Container End
```

### EmptyState 상세 구조

```
┌─ Container (center aligned)
│   padding: 32px xl vertical, 16px md horizontal
│
│  ┌─────────────────────────────────────┐
│  │ Icon (120x120px)                   │
│  │ Color: #CBD5E1 (Neutral-300)        │
│  │ margin-bottom: 24px lg              │
│  └─────────────────────────────────────┘
│
│  ┌─────────────────────────────────────┐
│  │ Title (18px, Semibold)             │
│  │ 투여 계획이 없습니다                 │
│  │ Color: #334155 (Neutral-700)        │
│  │ margin-bottom: 24px lg              │
│  └─────────────────────────────────────┘
│
│  ┌─────────────────────────────────────┐
│  │ Description (16px, Regular)        │
│  │ 온보딩을 완료하여 투여 일정을       │
│  │ 등록해주세요                         │
│  │ Color: #64748B (Neutral-500)        │
│  │ max-width: 320px                    │
│  │ margin-bottom: 24px lg              │
│  └─────────────────────────────────────┘
│
│  ┌─────────────────────────────────────┐
│  │ CTA Button (Primary) [선택사항]    │
│  │ 온보딩 시작                          │
│  │ margin-top: 24px lg                 │
│  └─────────────────────────────────────┘
│
└─ Container End
```

### Modal/Dialog 상세 구조

```
┌─ Backdrop
│  Background: rgba(15, 23, 42, 0.5)
│  Animation: Fade-in 200ms
│
├─ Dialog Box (max-width: 480px, mobile: 90%)
│
│  ┌─ Header (padding-bottom: 16px md)
│  │
│  │  ┌─────────────────────────────────┐
│  │  │ Title (24px, Bold)             │
│  │  │ 투여 기록                        │
│  │  │ Color: #1E293B (Neutral-800)    │
│  │  │                                 │
│  │  │         [Close Button 우측]    │
│  │  └─────────────────────────────────┘
│  │
│  ├─ Body (padding: 24px lg 상하, scrollable)
│  │
│  │  ┌─────────────────────────────────┐
│  │  │ Confirmation Text (16px, Reg)  │
│  │  │ 2.5 mg를 투여했습니다.          │
│  │  │ Color: #334155 (Neutral-700)    │
│  │  │ margin-bottom: 16px md          │
│  │  └─────────────────────────────────┘
│  │
│  │  ┌─────────────────────────────────┐
│  │  │ Section Label (14px, Semibold) │
│  │  │ 주사 부위                        │
│  │  │ Color: #334155 (Neutral-700)    │
│  │  │ margin-bottom: 8px sm           │
│  │  └─────────────────────────────────┘
│  │
│  │  ┌─────────────────────────────────┐
│  │  │ InjectionSiteSelectWidget       │
│  │  │ (기존 컴포넌트 재사용)          │
│  │  │ margin-bottom: 16px md          │
│  │  └─────────────────────────────────┘
│  │
│  │  ┌─────────────────────────────────┐
│  │  │ Memo Section (optional)        │
│  │  │ Label: "메모 (선택사항)"        │
│  │  │ TextField: GabiumTextField      │
│  │  │ (기존 컴포넌트 재사용)          │
│  │  └─────────────────────────────────┘
│  │
│  └─ Footer (padding-top: 24px lg)
│     Button Container (justify: flex-end)
│
│     ┌──────────────┐  ┌──────────────┐
│     │ 취소 (2nd)   │  │ 저장 (1st)   │
│     │ gap: 16px md │
│     └──────────────┘  └──────────────┘
│
└─ Dialog Box End
   Animation: Scale 0.95→1.0, Fade-in 200ms
```

---

## 인터랙션 명세

### Change 1-2: 카드 클릭/탭

**트리거:** DoseScheduleCard 클릭

**동작:**
1. 호버 상태 진입: 그림자 md, translateY(-2px)
2. 클릭 피드백: 1 프레임 스냅샷 (active 상태)
3. 모달 열기: DoseRecordDialog 표시
4. Backdrop 및 모달 애니메이션: Fade-in + Scale-up 200ms

**로딩 상태:**
- 카드 비활성화 (opacity 0.6)
- 카드 우측에 24px 스피너 표시
- 이전 모달 닫기

**완료 상태:**
- 카드 활성화
- 모달 닫기 (자동 또는 사용자 확인)
- 토스트 메시지: "투여 기록이 저장되었습니다" (Success, 3s)

**에러 상태:**
- 카드 활성화
- 모달 유지 또는 닫기
- 에러 메시지 표시 (Error, 5s)

### Change 3: 모달 버튼 인터랙션

**취소 버튼:**
- 클릭: 모달 닫기 (백드롭 Fade-out 200ms)
- 입력된 데이터: 폐기
- 포커스 복귀: 트리거 버튼 (DoseScheduleCard 액션)

**저장 버튼:**
- 호버: 배경 #22C55E, 그림자 md
- 클릭: 로딩 상태 진입
  - 버튼 텍스트 → 16px 스피너 (`#FFFFFF`)
  - 버튼 비활성화 (disabled = true)
- 완료: 모달 닫기 (즉시)
- 에러: 모달 유지, 에러 메시지 상단 표시

### Change 4: StatusBadge 상태 전환

**기본 상태:**
- 배경: [semantic light color]
- 텍스트: [semantic dark color]
- 테두리: 1px solid [semantic color]

**호버 상태 (터치 가능한 경우):**
- 배경: [semantic light color] - 5% 진하게
- 테두리: 1px solid [semantic color] + 10% 진하게
- Transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1)

### Change 5: Empty State 애니메이션

**표시 조건:**
- 투여 스케줄 리스트가 비어있을 때

**애니메이션:**
- 진입: Fade-in 300ms
- 아이콘: Pulse 효과 (선택사항) - scale 1.0 → 1.05 → 1.0 (2s infinite)

### Change 6: Loading Indicator 애니메이션

**풀페이지 로딩:**
- 표시: 데이터 로드 중
- 애니메이션: 1s linear infinite rotation
- 배경: `#F8FAFC` + 50% overlay
- Z-index: 최상층

**버튼 로딩:**
- 표시: 저장 버튼 클릭 후
- 애니메이션: 1s linear infinite rotation
- 크기: 16px
- 색상: `#FFFFFF`

---

## 구현 순서

**Phase 2C (자동 구현)에서 다음 순서로 진행:**

1. **Step 1: 새 컴포넌트 생성**
   - `lib/features/tracking/presentation/widgets/status_badge.dart` (StatusBadge)
   - `lib/features/tracking/presentation/widgets/dose_schedule_card.dart` (DoseScheduleCard)
   - `lib/features/tracking/presentation/widgets/empty_state_widget.dart` (EmptyStateWidget)

2. **Step 2: DoseScheduleScreen 레이아웃 수정**
   - AppBar 유지 (기존)
   - ListView.builder 구조 유지
   - 각 아이템에 DoseScheduleCard 적용

3. **Step 3: 색상 시스템 적용**
   - 의미 색상 정의 (Semantic Colors)
   - StatusBadge에 의미 색상 적용
   - 카드 배경색 조정

4. **Step 4: 타이포그래피 적용**
   - 제목: xl (20px, Semibold)
   - 본문: base (16px, Regular)
   - 라벨: sm (14px, Regular)
   - Empty State: lg (18px, Semibold)
   - 다이얼로그: 2xl (24px, Bold)

5. **Step 5: 여백 시스템 통일**
   - 카드 패딩: 16px md
   - 카드 간 여백: 16px md
   - 섹션 여백: 24px lg

6. **Step 6: 카드 스타일 적용**
   - Border Radius: 12px md
   - Shadow: sm (기본), md (호버)
   - 호버 Transform: translateY(-2px)

7. **Step 7: 버튼 표준화**
   - GabiumButton Primary 적용
   - 높이: 44px, 패딩: 24px 수평
   - 상태별 색상 정의

8. **Step 8: Dialog 재설계**
   - Max Width: 480px (모바일: 90%)
   - Border Radius: 16px lg
   - Shadow: xl
   - 헤더/바디/푸터 구조 분리
   - 애니메이션: Fade + Scale 200ms

9. **Step 9: 로딩 상태 강화**
   - 풀페이지 로더: 48px
   - 버튼 로더: 16px
   - 색상: Primary `#4ADE80`
   - 애니메이션: 1s linear infinite

10. **Step 10: 접근성 검증**
    - 색상 대비: 4.5:1 이상 (모든 조합)
    - 터치 영역: 44x44px 이상
    - Keyboard: Tab, Enter, Esc 네비게이션
    - Screen Reader: ARIA labels

---

## Flutter 구현 예제

### StatusBadge 위젯

```dart
// lib/features/tracking/presentation/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:gabium_design_system/tokens/colors.dart';
import 'package:gabium_design_system/tokens/typography.dart';

enum StatusBadgeType {
  success,
  error,
  warning,
  info,
}

class StatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String text;
  final IconData icon;

  const StatusBadge({
    Key? key,
    required this.type,
    required this.text,
    required this.icon,
  }) : super(key: key);

  Color get backgroundColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFFECFDF5); // Success Light
      case StatusBadgeType.error:
        return const Color(0xFFFEF2F2); // Error Light
      case StatusBadgeType.warning:
        return const Color(0xFFFFFBEB); // Warning Light
      case StatusBadgeType.info:
        return const Color(0xFFEFF6FF); // Info Light
    }
  }

  Color get textColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFF065F46); // Success Dark
      case StatusBadgeType.error:
        return const Color(0xFF991B1B); // Error Dark
      case StatusBadgeType.warning:
        return const Color(0xFF92400E); // Warning Dark
      case StatusBadgeType.info:
        return const Color(0xFF1E40AF); // Info Dark
    }
  }

  Color get borderColor {
    switch (type) {
      case StatusBadgeType.success:
        return const Color(0xFF10B981); // Success
      case StatusBadgeType.error:
        return const Color(0xFFEF4444); // Error
      case StatusBadgeType.warning:
        return const Color(0xFFF59E0B); // Warning
      case StatusBadgeType.info:
        return const Color(0xFF3B82F6); // Info
    }
  }

  Color get iconColor => borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44), // Touch target
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8), // sm radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 8), // sm spacing
          Text(
            text,
            style: TextStyle(
              fontSize: 14, // sm
              fontWeight: FontWeight.w400, // Regular
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

### DoseScheduleCard 위젯

```dart
// lib/features/tracking/presentation/widgets/dose_schedule_card.dart
import 'package:flutter/material.dart';

class DoseScheduleCard extends StatefulWidget {
  final String doseAmount;
  final String scheduledDate;
  final StatusBadgeType statusType;
  final String statusText;
  final IconData statusIcon;
  final VoidCallback onActionPressed;
  final bool isLoading;

  const DoseScheduleCard({
    Key? key,
    required this.doseAmount,
    required this.scheduledDate,
    required this.statusType,
    required this.statusText,
    required this.statusIcon,
    required this.onActionPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<DoseScheduleCard> createState() => _DoseScheduleCardState();
}

class _DoseScheduleCardState extends State<DoseScheduleCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onActionPressed,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -2 * _hoverController.value), // 2px lift
              child: Container(
                margin: const EdgeInsets.only(bottom: 16), // md spacing
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0), // Neutral-200
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12), // md radius
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(
                        0.06 + 0.02 * _hoverController.value,
                      ),
                      blurRadius: 4 + 4 * _hoverController.value,
                      offset: Offset(0, 2 + 2 * _hoverController.value),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16), // md padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dose Amount (xl, Semibold)
                    Text(
                      widget.doseAmount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B), // Neutral-800
                      ),
                    ),
                    const SizedBox(height: 8), // sm spacing

                    // Scheduled Date (base, Regular)
                    Text(
                      widget.scheduledDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155), // Neutral-700
                      ),
                    ),
                    const SizedBox(height: 8), // sm spacing

                    // Status Badge
                    StatusBadge(
                      type: widget.statusType,
                      text: widget.statusText,
                      icon: widget.statusIcon,
                    ),
                    const SizedBox(height: 16), // md spacing

                    // Action Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : widget.onActionPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADE80), // Primary
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF4ADE80)
                              .withOpacity(0.4),
                          disabledForegroundColor: Colors.white.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // sm radius
                          ),
                          elevation: 2, // sm shadow
                        ),
                        child: widget.isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              )
                            : const Text(
                                '기록',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### EmptyStateWidget 위젯

```dart
// lib/features/tracking/presentation/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onButtonPressed;
  final String? buttonText;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.onButtonPressed,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon (120x120px)
            Icon(
              icon,
              size: 120,
              color: const Color(0xFFCBD5E1), // Neutral-300
            ),
            const SizedBox(height: 24), // lg spacing

            // Title (lg, Semibold)
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155), // Neutral-700
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24), // lg spacing

            // Description (base, Regular)
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B), // Neutral-500
                height: 1.5, // 24px line height
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Optional CTA Button
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24), // lg spacing
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ADE80), // Primary
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // sm radius
                    ),
                    elevation: 2, // sm shadow
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 접근성 체크리스트

- [ ] 모든 색상 대비가 WCAG AA 기준 충족 (4.5:1 이상)
- [ ] 모든 터치 타겟이 44x44px 이상
- [ ] 버튼, 배지, 링크 모두 충분한 터치 영역 확보
- [ ] Keyboard 네비게이션 전체 동작 검증
  - [ ] Tab 키로 모든 요소 접근 가능
  - [ ] Enter/Space로 버튼 활성화
  - [ ] Esc로 모달/다이얼로그 닫기
- [ ] 포커스 표시 명확 (2px solid `#4ADE80` outline)
- [ ] ARIA labels 적용
  - [ ] StatusBadge: role="status"
  - [ ] 다이얼로그: role="dialog", aria-labelledby="dialog-title"
  - [ ] 로딩: aria-busy="true"
- [ ] 색상 + 아이콘 조합으로 정보 전달
- [ ] 로더 애니메이션: 최소 1초 (움직임 감지 가능)

---

## 테스팅 체크리스트

- [ ] 모든 상태 변환 동작 검증 (호버, 활성, 비활성, 로딩)
- [ ] 반응형 동작 검증
  - [ ] 모바일 (< 768px): 전체 너비
  - [ ] 태블릿 (768px - 1024px): 제약 없음
  - [ ] 데스크탑 (> 1024px): 제약 없음
- [ ] 접근성 요구사항 검증
- [ ] 토큰 값 정확성 검증 (색상, 크기, 여백)
- [ ] 다른 화면에서 시각적 회귀 확인
- [ ] 로딩, 완료, 에러 상태 검증
- [ ] 다이얼로그 열기/닫기 애니메이션 부드러움 검증

---

## 생성/수정 대상 파일

**새로 생성할 파일:**
- `lib/features/tracking/presentation/widgets/status_badge.dart` (StatusBadge)
- `lib/features/tracking/presentation/widgets/dose_schedule_card.dart` (DoseScheduleCard)
- `lib/features/tracking/presentation/widgets/empty_state_widget.dart` (EmptyStateWidget)

**수정할 파일:**
- `lib/features/tracking/presentation/screens/dose_schedule_screen.dart` (메인 화면)
- `lib/features/tracking/presentation/screens/dose_record_dialog.dart` (다이얼로그)

**재사용할 파일 (변경 불필요):**
- `lib/shared/presentation/widgets/gabium_button.dart` (GabiumButton)
- `lib/shared/presentation/widgets/gabium_text_field.dart` (GabiumTextField)

**필수 자산:**
- 의료 관련 아이콘 (Material Symbols): check-circle, alert-circle, flag, clock
- Empty State 아이콘 (Material Symbols): schedule, calendar-today, 등

**참고:** Component Registry는 Phase 3 Step 4에서 업데이트됩니다.

---

**구현 가이드 v1.0 완성**
**작성 일시: 2025-11-24**
**Framework: Flutter (Dart)**
**Design System: Gabium v1.0**

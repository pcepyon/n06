# Gabium (가비움) Design System

**Version:** 1.0
**Last Updated:** 2025-11-22
**Status:** Active

---

## 1. Brand Foundation

### Brand Values
- **안전성 (Safety First)**: GLP-1 치료는 의료적 관리가 필요한 영역이므로, 신뢰할 수 있고 안정적인 느낌을 전달
- **친근함 (Approachability)**: 토스처럼 부드럽고 편안한 인터페이스로 사용자가 매일 사용하기 부담 없는 경험 제공
- **동기부여 (Motivation)**: 성취감과 긍정적 피드백을 통해 치료 여정을 끝까지 완주하도록 지원
- **효율성 (Efficiency)**: 복잡한 데이터를 직관적으로 시각화하여 의료진과의 커뮤니케이션 효율 극대화

### Target Audience
- **Primary**: GLP-1 주사제를 사용하는 모든 연령대의 사용자 (20-50대 중심)
- **Tech Savviness**: 기본적인 모바일 앱 사용에 익숙함
- **Usage Context**: 일상적 건강 관리 - 매일 아침/저녁 체크, 투여일 기록, 증상 모니터링
- **Emotional State**: 치료 초기 불안감 → 지속적 동기 필요 → 목표 달성 성취감

### Design Principles

1. **신뢰를 통한 안정감 (Trust through Stability)**
   - 의료 앱으로서 신뢰할 수 있는 비주얼 언어 사용
   - 일관된 레이아웃과 예측 가능한 인터랙션
   - 충분한 여백과 명확한 계층 구조

2. **부드러운 친근함 (Soft Friendliness)**
   - 날카롭지 않은 둥근 모서리
   - 차분하면서도 밝은 색상 팔레트
   - 딱딱하지 않은 톤앤매너 (토스 스타일)

3. **동기부여 중심 디자인 (Motivation-Centric Design)**
   - 성취 시각화 (뱃지, 진행 바, 차트)
   - 긍정적 피드백 컬러 시스템 (성공, 진행, 도전)
   - 마이크로 인터랙션으로 즐거움 제공

4. **데이터 가독성 우선 (Data Readability First)**
   - 명확한 타이포그래피 계층
   - 색상을 통한 정보 구분 (증상 레벨, 용량 변화 등)
   - 모바일 최적화된 차트 및 시각화

5. **접근성 보장 (Accessibility Assurance)**
   - WCAG AA 이상의 색상 대비
   - 터치 영역 최소 44x44px
   - 명확한 에러/경고 메시지

---

## 2. Color System

### Brand Colors

#### Primary (신뢰의 밝은 녹색)
- **Color:** `#4ADE80` (Green-400)
- **Usage:** 주요 CTA 버튼, 성공 상태, 긍정적 피드백, 진행 상황 표시
- **Accessibility:** WCAG AA 적합 (흰 배경에 4.5:1 이상 대비)
- **Psychology:** 녹색 = 건강, 성장, 안전 + 밝은 톤 = 희망, 친근함
- **States:**
  - Default: `#4ADE80`
  - Hover: `#22C55E` (Green-500, 약간 진하게)
  - Active/Pressed: `#16A34A` (Green-600, 더 진하게)
  - Disabled: `#4ADE80` at 40% opacity

#### Secondary (따뜻한 보조 색상)
- **Color:** `#F59E0B` (Amber-500)
- **Usage:** 강조 포인트, 중요 알림, 주의 필요 항목 (위험하지 않은 경고)
- **Psychology:** 주황 계열 = 따뜻함, 에너지, 주의 환기
- **States:**
  - Default: `#F59E0B`
  - Hover: `#D97706` (Amber-600)
  - Active/Pressed: `#B45309` (Amber-700)
  - Disabled: `#F59E0B` at 40% opacity

### Semantic Colors

#### Success
- **Color:** `#10B981` (Emerald-500)
- **Usage:** 성공 메시지, 목표 달성, 완료된 작업, 뱃지 획득
- **Example:** "체중 기록 완료", "이번 주 목표 100% 달성"

#### Error
- **Color:** `#EF4444` (Red-500)
- **Usage:** 에러 상태, 위험 증상, 필수 입력 오류, 삭제 경고
- **Accessibility:** WCAG AA 적합
- **Example:** "투여 기록 실패", "심각한 증상 감지"

#### Warning
- **Color:** `#F59E0B` (Amber-500, Secondary와 동일)
- **Usage:** 주의 필요 상태, 미완료 작업, 확인 필요 항목
- **Example:** "오늘 체중 미기록", "알림 권한 필요"

#### Info
- **Color:** `#3B82F6` (Blue-500)
- **Usage:** 일반 정보, 도움말, 팁, 중립적 알림
- **Example:** "투여 스케줄 안내", "데이터 공유 방법"

### Achievement Colors (동기부여 색상)

#### Gold (최고 등급 뱃지)
- **Color:** `#F59E0B` (Amber-500)
- **Usage:** 골드 뱃지, 특별 업적, 장기 목표 달성

#### Silver (중간 등급 뱃지)
- **Color:** `#94A3B8` (Slate-400)
- **Usage:** 실버 뱃지, 중간 목표 달성

#### Bronze (기본 등급 뱃지)
- **Color:** `#EA580C` (Orange-600)
- **Usage:** 브론즈 뱃지, 소소한 업적

### Neutral Scale

| Level | Hex | Usage |
|-------|-----|-------|
| 50 | `#F8FAFC` | 전체 앱 배경, 가장 밝은 표면 |
| 100 | `#F1F5F9` | 카드/섹션 배경, 비활성 영역 |
| 200 | `#E2E8F0` | 미세한 구분선, 입력 필드 배경 |
| 300 | `#CBD5E1` | 기본 테두리, 구분선 |
| 400 | `#94A3B8` | 비활성 요소, Placeholder 텍스트 |
| 500 | `#64748B` | 보조 텍스트, 아이콘 |
| 600 | `#475569` | 본문 텍스트 |
| 700 | `#334155` | 강조 텍스트, 소제목 |
| 800 | `#1E293B` | 제목, 헤더 |
| 900 | `#0F172A` | 최고 강조, 중요 제목 |

### Interactive States

**Primary Button States:**
- Default: `#4ADE80` background, `#FFFFFF` text
- Hover: `#22C55E` background
- Active: `#16A34A` background
- Disabled: `#4ADE80` at 40% opacity
- Loading: `#4ADE80` background + spinner

**Link/Text Button States:**
- Default: `#4ADE80` text
- Hover: `#22C55E` text + underline
- Active: `#16A34A` text
- Visited: `#334155` text (neutral-700)

---

## 3. Typography

### Font Family
- **Primary:** Pretendard Variable, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif
  - **Rationale:** Pretendard는 한글 가독성이 우수하고 다양한 웨이트를 지원하여 명확한 계층 구조 표현 가능. 시스템 폰트 fallback으로 크로스 플랫폼 일관성 확보
- **Monospace (optional):** "SF Mono", Menlo, Monaco, Consolas, monospace
  - **Usage:** 데이터 테이블, 숫자 정렬, 코드 표시

### Type Scale

| Name | Size | Weight | Line Height | Letter Spacing | Usage |
|------|------|--------|-------------|----------------|-------|
| 3xl | 28px | 700 (Bold) | 36px | -0.02em | 페이지 주 제목, 환영 메시지 |
| 2xl | 24px | 700 (Bold) | 32px | -0.01em | 섹션 제목, 모달 제목 |
| xl | 20px | 600 (Semibold) | 28px | 0 | 하위 섹션 제목, 카드 제목 |
| lg | 18px | 600 (Semibold) | 26px | 0 | 강조 텍스트, 리스트 헤더 |
| base | 16px | 400 (Regular) | 24px | 0 | 본문, 기본 UI 텍스트 |
| sm | 14px | 400 (Regular) | 20px | 0 | 보조 텍스트, 라벨, 설명 |
| xs | 12px | 400 (Regular) | 16px | 0.01em | 캡션, 메타데이터, 타임스탬프 |

### Weight Variations
- **Regular (400):** 본문, 일반 UI 요소
- **Medium (500):** 약한 강조, 탭 라벨
- **Semibold (600):** 중간 강조, 버튼 텍스트, 섹션 제목
- **Bold (700):** 강한 강조, 페이지 제목, 중요 CTA

### Usage Guidelines
- **Headings:** 3xl-lg 사용, 위계에 따라 순차적 적용 (3xl → 2xl → xl)
- **Body:** base 크기 사용, 최대 줄 길이 60-75자 권장
- **UI Elements:** sm 크기로 라벨/힌트 표시, xs는 메타정보만
- **Mobile Optimization:** 최소 본문 크기 16px (iOS zoom 방지)
- **Emphasis:** 색상 변경보다 weight 변경 우선 (가독성)
- **Line Height:** 한글 특성상 영문보다 1.5-1.6배 높게 설정

---

## 4. Spacing & Sizing

### Spacing Scale
4px 기반 8의 배수 시스템 사용 (디자인-개발 정합성)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | 텍스트와 아이콘 간격, 밀집된 리스트 간격 |
| sm | 8px | 컴포넌트 내부 패딩 (버튼, 입력 필드) |
| md | 16px | 기본 요소 간 간격, 카드 내부 패딩 |
| lg | 24px | 섹션 간 간격, 큰 카드 패딩 |
| xl | 32px | 주요 섹션 구분, 페이지 상/하단 여백 |
| 2xl | 48px | 대형 섹션 구분, 히어로 영역 패딩 |
| 3xl | 64px | 페이지 레벨 여백, 특별 섹션 |

### Component Heights
- **Button (Small):** 36px
- **Button (Medium/Default):** 44px (iOS 터치 권장)
- **Button (Large):** 52px
- **Input Field:** 48px (터치 용이성)
- **Select Dropdown:** 48px
- **Checkbox/Radio:** 24x24px (터치 영역: 44x44px)
- **Tab Bar (Bottom):** 56px
- **App Bar (Top):** 56px

### Container Widths
- **Mobile:** 100% width (좌우 16px padding)
- **Tablet:** 100% width, max 768px (좌우 24px padding)
- **Desktop (참고용):** max 1200px (중앙 정렬)
- **Content Max Width:** 640px (최적 가독성)

### Border Widths
- **Thin:** 1px (기본 구분선, 입력 필드)
- **Medium:** 2px (강조 테두리, 포커스 상태)
- **Thick:** 4px (특별 강조, 진행 바)

---

## 5. Visual Effects

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 8px | 버튼, 입력 필드, 태그 |
| md | 12px | 카드, 작은 모달, 이미지 컨테이너 |
| lg | 16px | 큰 카드, 바텀시트, 다이얼로그 |
| xl | 24px | 히어로 카드, 특별 섹션 |
| full | 999px | 원형 아바타, 필 버튼, 뱃지 |

**Rationale:** 토스 스타일의 부드러운 느낌 전달. 의료 앱의 신뢰감 유지를 위해 너무 둥글지 않게 조절 (기본 8px)

### Shadow Levels

| Level | Shadow | Usage |
|-------|--------|-------|
| xs | 0 1px 2px rgba(15, 23, 42, 0.05) | 미세한 깊이감 (입력 필드) |
| sm | 0 2px 4px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04) | 버튼, 작은 카드 |
| md | 0 4px 8px rgba(15, 23, 42, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04) | 기본 카드, 드롭다운 |
| lg | 0 8px 16px rgba(15, 23, 42, 0.10), 0 4px 8px rgba(15, 23, 42, 0.06) | 모달, 팝오버 |
| xl | 0 16px 32px rgba(15, 23, 42, 0.12), 0 8px 16px rgba(15, 23, 42, 0.08) | 다이얼로그, 바텀시트 |
| 2xl | 0 24px 48px rgba(15, 23, 42, 0.16), 0 12px 24px rgba(15, 23, 42, 0.10) | 풀스크린 오버레이 |

**색상 선택:** Neutral-900 (`#0F172A`) 기반으로 일관성 유지, 낮은 투명도로 부드러운 그림자 표현

### Opacity Scale
- **Disabled:** 0.4 (비활성 요소)
- **Muted:** 0.6 (보조 요소)
- **Subtle:** 0.8 (약한 강조)
- **Overlay:** 0.5 (모달 배경)

### Transitions
- **Fast:** 150ms (호버, 클릭 피드백)
- **Base:** 200ms (기본 상태 전환)
- **Slow:** 300ms (패널 열림/닫힘)
- **Easing:** cubic-bezier(0.4, 0, 0.2, 1) (Material Design 표준)

---

## 6. Core Components

### Buttons

#### Variants

**Primary (주요 액션)**
- **Background:** `#4ADE80` (Primary)
- **Text:** `#FFFFFF` (White), Semibold (600)
- **Border:** None
- **Shadow:** sm
- **Usage:** 주요 CTA ("저장", "기록하기", "시작하기")
- **States:**
  - Hover: Background `#22C55E`, Shadow md
  - Active: Background `#16A34A`, Shadow xs
  - Disabled: Background `#4ADE80` at 40%, Text at 50%
  - Loading: Primary background + 16px spinner (white)

**Secondary (보조 액션)**
- **Background:** Transparent
- **Text:** `#4ADE80` (Primary), Semibold (600)
- **Border:** 2px solid `#4ADE80`
- **Shadow:** None
- **Usage:** 보조 액션 ("취소", "건너뛰기", "나중에")
- **States:**
  - Hover: Background `#4ADE80` at 8%, Border darker
  - Active: Background `#4ADE80` at 12%
  - Disabled: Border/Text at 40%

**Tertiary (부드러운 강조)**
- **Background:** `#F1F5F9` (Neutral-100)
- **Text:** `#334155` (Neutral-700), Semibold (600)
- **Border:** None
- **Shadow:** None
- **Usage:** 덜 강조된 액션 ("편집", "더보기")
- **States:**
  - Hover: Background `#E2E8F0` (Neutral-200)
  - Active: Background `#CBD5E1` (Neutral-300)
  - Disabled: Text at 40%

**Ghost (텍스트 버튼)**
- **Background:** Transparent
- **Text:** `#4ADE80` (Primary), Medium (500)
- **Border:** None
- **Shadow:** None
- **Usage:** 최소 강조 ("취소", 모달 닫기)
- **States:**
  - Hover: Background `#4ADE80` at 8%
  - Active: Background `#4ADE80` at 12%
  - Disabled: Text at 40%

**Danger (위험/삭제)**
- **Background:** `#EF4444` (Error)
- **Text:** `#FFFFFF`, Semibold (600)
- **Border:** None
- **Shadow:** sm
- **Usage:** 삭제, 위험한 액션 ("기록 삭제", "계정 탈퇴")
- **States:**
  - Hover: Background `#DC2626` (Red-600)
  - Active: Background `#B91C1C` (Red-700)

#### Sizes
- **Small:** 36px height, 14px text (sm), 16px horizontal padding, 8px radius
- **Medium:** 44px height, 16px text (base), 24px horizontal padding, 8px radius
- **Large:** 52px height, 18px text (lg), 32px horizontal padding, 12px radius

#### Icon Buttons
- **Size:** 44x44px (터치 영역)
- **Icon Size:** 24x24px
- **Background:** Transparent or Neutral-100
- **Padding:** 10px (중앙 정렬)

### Form Elements

#### Text Input
- **Height:** 48px
- **Padding:** 12px 16px
- **Border:** 2px solid `#CBD5E1` (Neutral-300)
- **Border Radius:** 8px (sm)
- **Font:** 16px (base), Regular
- **Background:** `#FFFFFF`
- **States:**
  - Default: Neutral-300 border
  - Focus: `#4ADE80` border, `#4ADE80` at 10% background, outline none
  - Error: `#EF4444` border, error message below
  - Disabled: `#F1F5F9` background, `#94A3B8` text, 0.6 opacity
  - Read-only: `#F8FAFC` background, no border change

#### Textarea
- Similar to Text Input
- **Min Height:** 96px (4 lines)
- **Resize:** Vertical only
- **Max Height:** 240px

#### Select Dropdown
- Same as Text Input styling
- **Icon:** Chevron-down 20px, right-aligned, 12px from edge
- **Dropdown:**
  - Background: `#FFFFFF`
  - Border: 1px solid `#CBD5E1`
  - Shadow: md
  - Border Radius: 8px
  - Max Height: 240px (scrollable)
  - Item Height: 44px
  - Item Hover: `#F1F5F9` background

#### Checkbox
- **Size:** 24x24px (visual), 44x44px (touch area)
- **Border:** 2px solid `#94A3B8` (Neutral-400)
- **Border Radius:** 4px
- **Checked State:**
  - Background: `#4ADE80`
  - Border: `#4ADE80`
  - Checkmark: White, 16px icon
- **Indeterminate:** `-` icon instead of checkmark
- **Disabled:** 0.4 opacity

#### Radio Button
- **Size:** 24x24px (visual), 44x44px (touch area)
- **Border:** 2px solid `#94A3B8`
- **Border Radius:** 999px (full)
- **Checked State:**
  - Border: `#4ADE80`
  - Inner Dot: 12x12px circle, `#4ADE80`
- **Disabled:** 0.4 opacity

#### Toggle Switch
- **Width:** 48px
- **Height:** 28px
- **Border Radius:** 999px
- **Off State:**
  - Background: `#CBD5E1` (Neutral-300)
  - Thumb: 20x20px circle, `#FFFFFF`, 4px from edge
- **On State:**
  - Background: `#4ADE80`
  - Thumb: moved to right (4px from edge)
- **Transition:** 200ms ease

#### Label
- **Font:** 14px (sm), Semibold (600)
- **Color:** `#334155` (Neutral-700)
- **Spacing:** 8px below label, 4px to input

#### Helper Text
- **Font:** 12px (xs), Regular
- **Color:** `#64748B` (Neutral-500)
- **Spacing:** 4px below input

#### Error Message
- **Font:** 12px (xs), Medium (500)
- **Color:** `#EF4444` (Error)
- **Icon:** Alert-circle 16px, left-aligned
- **Spacing:** 4px below input

#### Placeholder
- **Color:** `#94A3B8` (Neutral-400)
- **Font:** Same as input (16px, Regular)

### Feedback Components

#### Toast/Snackbar
- **Width:** Mobile: 90% viewport (max 360px), Desktop: 400px
- **Padding:** 16px
- **Border Radius:** 12px (md)
- **Shadow:** lg
- **Position:** Bottom-center (mobile), top-right (desktop)
- **Duration:** 3 seconds (info/success), 5 seconds (warning/error)
- **Animation:** Slide-up (mobile), Slide-in-right (desktop)
- **Variants:**
  - Success: `#10B981` left border (4px), `#ECFDF5` background, `#065F46` text
  - Error: `#EF4444` left border, `#FEF2F2` background, `#991B1B` text
  - Warning: `#F59E0B` left border, `#FFFBEB` background, `#92400E` text
  - Info: `#3B82F6` left border, `#EFF6FF` background, `#1E40AF` text
- **Icon:** 24px, left-aligned, 12px spacing to text
- **Close Button:** 20x20px, right-aligned, Ghost style

#### Alert Banner
- **Width:** 100% container
- **Padding:** 16px
- **Border Radius:** 8px (sm)
- **Border:** 1px solid (variant color at 40%)
- **Same color variants as Toast**
- **Dismissible:** Optional close button (top-right)

#### Modal/Dialog
- **Max Width:** 480px (mobile: 90% viewport)
- **Padding:** 24px
- **Border Radius:** 16px (lg)
- **Shadow:** xl
- **Backdrop:** rgba(15, 23, 42, 0.5) (Neutral-900 at 50%)
- **Animation:** Fade-in backdrop + Scale-up modal (200ms)
- **Structure:**
  - **Header:** Title (xl, Bold), Close button (top-right)
  - **Body:** base text, scrollable if needed, 24px top/bottom padding
  - **Footer:** Actions (right-aligned), Primary + Secondary buttons, 16px spacing

#### Bottom Sheet
- **Width:** 100% viewport
- **Max Height:** 90vh
- **Padding:** 24px (top), 16px (sides), 32px (bottom for safe area)
- **Border Radius:** 16px (top corners only)
- **Shadow:** 2xl
- **Backdrop:** Same as Modal
- **Handle:** 32x4px rounded bar, `#CBD5E1`, centered, 12px from top
- **Animation:** Slide-up (300ms)

#### Loading Indicator (Spinner)
- **Type:** Circular spinner
- **Color:** `#4ADE80` (Primary)
- **Sizes:**
  - Small: 16px (inline with text)
  - Medium: 24px (buttons)
  - Large: 48px (full-page loading)
- **Animation:** 1s linear infinite rotation

#### Progress Bar
- **Height:** 8px
- **Border Radius:** 999px (full)
- **Background:** `#E2E8F0` (Neutral-200)
- **Fill:** `#4ADE80` (Primary), animated transition
- **Variants:**
  - Linear: Full width
  - Circular: 48px-120px diameter, 8px stroke

#### Skeleton Loader
- **Background:** `#E2E8F0` (Neutral-200)
- **Animation:** Shimmer effect (1.5s infinite)
- **Border Radius:** Match target component
- **Usage:** Text lines, Cards, Images during loading

### Layout Patterns

#### Card Container
- **Background:** `#FFFFFF`
- **Border:** 1px solid `#E2E8F0` (Neutral-200) OR no border with shadow
- **Border Radius:** 12px (md)
- **Shadow:** sm (default) or md (hover/important)
- **Padding:** 16px (mobile), 20px (tablet+)
- **Spacing:** 16px between cards
- **Hover:** Shadow md, 2px lift (transform: translateY(-2px))

#### List Item
- **Height:** Min 56px (comfortable tap)
- **Padding:** 16px horizontal, 12px vertical
- **Border Bottom:** 1px solid `#E2E8F0` (last item: none)
- **Hover/Active:** `#F8FAFC` background
- **Leading:** Icon/Avatar (40x40px), 16px spacing
- **Trailing:** Icon/Text/Switch, 16px spacing

#### Section Divider
- **Line:** 1px solid `#E2E8F0` (Neutral-200)
- **Spacing:** 24px (lg) above and below
- **With Label:**
  - Center-aligned text (sm, Neutral-500)
  - Line on both sides (flex-grow)

#### Header (App Bar)
- **Height:** 56px
- **Background:** `#FFFFFF`
- **Border Bottom:** 1px solid `#E2E8F0`
- **Padding:** 0 16px
- **Title:** xl size, Bold, `#1E293B` (Neutral-800)
- **Actions:** 44x44px icon buttons, right-aligned
- **Back Button:** 44x44px, left-aligned

#### Bottom Navigation
- **Height:** 56px + safe area inset
- **Background:** `#FFFFFF`
- **Border Top:** 1px solid `#E2E8F0`
- **Shadow:** Reverse md (top shadow)
- **Items:** 3-5 items, evenly distributed
- **Item:**
  - Icon: 24x24px
  - Label: 12px (xs), Medium
  - Active: `#4ADE80` color
  - Inactive: `#64748B` color
  - Padding: 8px top, 4px bottom

#### Tab Bar
- **Height:** 48px
- **Background:** Transparent or `#F8FAFC`
- **Border Bottom:** 1px solid `#E2E8F0`
- **Tab:**
  - Padding: 12px 16px
  - Font: base (16px), Medium (500)
  - Inactive: `#64748B` text
  - Active: `#4ADE80` text, 2px bottom border `#4ADE80`
  - Hover: `#F1F5F9` background

#### Empty State
- **Alignment:** Center (vertical + horizontal)
- **Illustration:** 120x120px, `#CBD5E1` color
- **Title:** lg size, Semibold, `#334155`
- **Description:** base size, Regular, `#64748B`
- **Action:** Primary or Secondary button
- **Spacing:** 24px between elements

---

## 7. Component Registry

This section tracks all designed components for reuse and consistency.

| Component | Created Date | Used In | Notes |
|-----------|--------------|---------|-------|
| AuthHeroSection | 2025-11-22 | Email Signup, Email Signin | Welcoming hero with title, subtitle, optional icon. Reusable for all auth screens. |
| GabiumTextField | 2025-11-22 | Email Signup, Email Signin | Branded text input with label, validation, focus/error states. Height 48px. |
| GabiumButton | 2025-11-22 | Email Signup, Email Signin | Button with Primary/Ghost variants. Small/Medium/Large sizes. Loading state support. |
| PasswordStrengthIndicator | 2025-11-22 | Email Signup | Visual password strength indicator with semantic colors (Weak/Medium/Strong). |
| ConsentCheckbox | 2025-11-22 | Email Signup | Styled checkbox with required/optional badge. 44x44px touch area. |
| GabiumToast | 2025-11-22 | Email Signup, Email Signin | Toast notification with Error/Success/Warning/Info variants. Replaces SnackBar. |

**Component Files:**
- Design System: `.claude/skills/ui-renewal/design-systems/gabium-design-system.md`
- Component Library Docs: `.claude/skills/ui-renewal/component-library/COMPONENTS.md`
- Flutter Implementation: `lib/features/authentication/presentation/widgets/`
- Component Backup: `.claude/skills/ui-renewal/component-library/flutter/`

---

## 8. Design Tokens Export

This Design System can be exported to various formats:
- **Flutter Theme** (ThemeData + ThemeExtension)
- **JSON** (범용)
- **CSS Variables** (Web 참고용)

See `scripts/export_design_tokens.py` for conversion.

---

## 9. Icon System

### Icon Library
- **Primary:** Material Symbols (Outlined style)
- **Fallback:** Material Icons (Flutter built-in)
- **Style:** Outlined (부드럽고 친근함), Rounded corners

### Icon Sizes
- **xs:** 16px (inline with text)
- **sm:** 20px (small buttons, tags)
- **base:** 24px (standard UI)
- **lg:** 32px (featured icons)
- **xl:** 48px (empty states, hero)

### Icon Colors
- **Default:** `#475569` (Neutral-600)
- **Active:** `#4ADE80` (Primary)
- **Disabled:** `#CBD5E1` (Neutral-300)
- **Error:** `#EF4444` (Error)

### Common Icons
- **Navigation:** arrow-back, arrow-forward, close, menu
- **Actions:** add, edit, delete, check, refresh
- **Content:** home, calendar, chart, list, settings
- **Feedback:** check-circle, error, warning, info
- **Health:** medical-bag, pill, syringe, heart-pulse

---

## 10. Data Visualization

### Chart Colors (순서대로 사용)
1. `#4ADE80` (Primary - 주요 데이터)
2. `#3B82F6` (Blue - 보조 데이터)
3. `#F59E0B` (Amber - 경고/주의)
4. `#8B5CF6` (Purple - 부가 정보)
5. `#EC4899` (Pink - 특별 항목)
6. `#10B981` (Emerald - 성공/목표)

### Chart Types
- **Line Chart:** 체중 추이, 증상 강도 변화
- **Bar Chart:** 주간 투여 횟수, 증상 빈도
- **Progress Circle:** 목표 달성률, 순응도
- **Timeline:** 투여 일정, 증상 이력

### Chart Styling
- **Grid Lines:** `#E2E8F0` (Neutral-200), 1px
- **Axis:** `#64748B` (Neutral-500), 12px (xs)
- **Labels:** 12px (xs), Medium (500), `#475569`
- **Tooltip:**
  - Background: `#1E293B` (Neutral-800)
  - Text: `#FFFFFF`, 14px (sm)
  - Border Radius: 8px
  - Padding: 8px 12px
  - Shadow: md

---

## 11. Accessibility Guidelines

### Color Contrast
- **Text on Background:** WCAG AA 적합 (4.5:1 이상)
- **Large Text (18px+):** WCAG AA 적합 (3:1 이상)
- **UI Components:** WCAG AA 적합 (3:1 이상)
- **Test Tools:** Use WebAIM Contrast Checker

### Touch Targets
- **Minimum Size:** 44x44px (Apple HIG, Material Design)
- **Recommended Spacing:** 8px between touch targets
- **Exception:** Inline text links (rely on text size)

### Focus States
- **Keyboard Focus:** 2px solid `#4ADE80` outline, 2px offset
- **Order:** Logical tab order (top to bottom, left to right)

### Screen Reader Support
- **Labels:** All interactive elements must have labels
- **Announcements:** Success/Error states announced
- **Landmarks:** Proper semantic HTML/Flutter semantics

### Motion
- **Respect Reduced Motion:** Use `prefers-reduced-motion`
- **Alternative:** Instant state changes instead of animations

---

## 12. Notes & Decisions

### Design Decisions Log

- **2025-11-22** Primary Color `#4ADE80` 선택: 밝은 녹색으로 건강/성장/안전 이미지 전달하면서도 신뢰감 있는 톤. WCAG AA 적합성 확보. 토스의 블루 대신 헬스케어 특성 반영한 그린 계열 채택.

- **2025-11-22** Pretendard 폰트 채택: 한글 가독성 우수, Variable Font로 다양한 웨이트 지원, 오픈소스. 의료 데이터 가독성이 중요한 만큼 명확한 타이포그래피 필수.

- **2025-11-22** 8px 기본 Border Radius: 토스 스타일의 부드러움 유지하되, 의료 앱으로서 너무 캐주얼하지 않도록 중간 값 선택. 4px는 너무 딱딱하고, 12px는 너무 둥근 느낌.

- **2025-11-22** 동기부여 색상 시스템 추가: Gold/Silver/Bronze 뱃지 색상을 별도 정의하여 사용자의 성취감 극대화. 게이미피케이션 요소 강화.

- **2025-11-22** 48px Input Height: 모바일 터치 용이성과 한글 입력 시 충분한 공간 확보. iOS 44px 최소 기준보다 여유 있게 설정.

- **2025-11-22** Neutral 색상을 Slate 계열 선택: Pure Gray보다 약간 차가운 느낌으로 깔끔함과 현대적인 느낌 전달. 녹색 Primary와 조화로운 조합.

### Future Considerations

- **Dark Mode:** Phase 2에서 검토. 의료 앱 특성상 야간 사용 시나리오 고려 필요. Neutral-900 배경, Primary 색상 밝기 조정 필요.

- **Illustrations:** 온보딩, 빈 상태, 성공 화면에 사용할 일러스트레이션 스타일 가이드 추가 예정. 친근하고 부드러운 라인 스타일 권장.

- **Animation Library:** Lottie 또는 Rive 도입 검토. 뱃지 획득, 목표 달성 시 즐거운 애니메이션으로 동기 부여 강화.

- **Localization:** 한국어 중심이지만, 향후 영문 지원 시 타이포그래피 스케일 재검토 필요 (영문은 줄 높이 낮춤).

---

**End of Gabium Design System v1.0**

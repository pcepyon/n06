# 🎨 GLP-1 Care Design System Guide

## 1. Design Philosophy: "Clean & Trust"
본 프로젝트는 **토스(Toss)** 스타일의 **"간결함(Simplicity)"**과 **"신뢰감(Trust)"**을 핵심 가치로 합니다.
사용자가 복잡한 의료 데이터 속에서도 편안함과 안정감을 느낄 수 있도록 **과감한 여백**, **명확한 타이포그래피**, **부드러운 인터랙션**을 제공합니다.

---

## 2. Color Palette (색상 시스템)

### Primary (Brand)
가장 중요한 액션과 강조에 사용합니다.
- **Primary Green:** `#00C73C` (신뢰, 긍정, 완료)
- **Primary Light:** `#E5F9EB` (배경 강조, 틴트)

### Secondary & Status
- **Error (위험/오류):** `#FF3B30`
- **Warning (주의):** `#FF9500`
- **Success (성공):** `#00C73C` (Primary와 동일)

### Neutral (Grayscale)
가독성과 계층 구조를 위해 정교하게 설계된 회색조입니다.
- **Black (Heading):** `#191F28` (완전 검정이 아닌 짙은 남색 계열)
- **Dark Gray (Body):** `#333D4B` (본문 텍스트)
- **Gray (SubText):** `#4E5968` (부가 설명)
- **Light Gray (Border/Hint):** `#8B95A1` (비활성 텍스트, 테두리)
- **Background Gray:** `#F2F4F6` (그룹 배경, 리스트 구분)
- **White:** `#FFFFFF` (카드, 메인 배경)

---

## 3. Typography (타이포그래피)

폰트는 **Pretendard**를 기본으로 사용합니다. (미적용 시 시스템 기본 Sans-serif)

| Role | Size | Weight | Height | Usage |
|:--- |:--- |:--- |:--- |:--- |
| **H1** | 24px | Bold (700) | 1.4 | 메인 화면 제목, 핵심 강조 |
| **H2** | 20px | Bold (700) | 1.4 | 섹션 타이틀, 모달 제목 |
| **H3** | 18px | SemiBold (600) | 1.4 | 카드 제목, 중요 정보 |
| **Body1** | 16px | Medium (500) | 1.5 | 일반 본문, 입력 필드 |
| **Body2** | 14px | Regular (400) | 1.5 | 보조 설명, 리스트 상세 |
| **Caption** | 12px | Regular (400) | 1.5 | 하단 설명, 태그 |

---

## 4. Layout & Spacing (레이아웃 및 여백)

### Spacing System (8-point Grid)
모든 여백은 4의 배수를 기본으로 합니다.
- **xs:** 4px
- **s:** 8px
- **m:** 16px (기본 패딩)
- **l:** 24px (섹션 간격)
- **xl:** 32px
- **xxl:** 48px

### Radius (둥글기)
부드러운 느낌을 위해 넉넉한 둥글기를 사용합니다.
- **Button:** 12px
- **Card:** 20px
- **Modal/Sheet:** 24px (상단)

### Elevation (그림자)
- **Level 1 (Card):** `color: Black(5%), blur: 10, offset: (0, 4)`
- **Level 2 (Floating/Modal):** `color: Black(10%), blur: 20, offset: (0, 8)`

---

## 5. Components Guideline (컴포넌트 가이드)

### Buttons (`AppButton`)
- **Primary:** 녹색 배경 + 흰색 텍스트. 화면의 주요 액션(저장, 다음 등)에 **페이지당 1개**만 사용 권장.
- **Secondary:** 회색 배경(`#F2F4F6`) + 짙은 회색 텍스트. 취소, 이전 등 보조 액션.
- **Ghost:** 배경 없음. 텍스트만 있는 버튼.

### Text Fields (`AppTextField`)
- 배경: `#F9FAFB` (아주 연한 회색)
- 테두리: 없음 (Focus 시 녹색 테두리)
- 높이: 넉넉하게 확보

### Cards (`AppCard`)
- 흰색 배경에 은은한 그림자 적용.
- 내부 패딩은 기본 `20px` 사용.

---

## 6. Development Rules (개발 규칙)

1. **하드코딩 금지:** 색상, 폰트 크기 등을 직접 입력하지 말고 `AppColors`, `AppTextStyles`를 사용하세요.
2. **컴포넌트 재사용:** `ElevatedButton` 대신 `AppButton`, `Container` 대신 `AppCard`를 우선 사용하세요.
3. **로직 분리:** UI 변경 시 `ref.read`, `ref.watch` 등 상태 관리 로직은 건드리지 않습니다.

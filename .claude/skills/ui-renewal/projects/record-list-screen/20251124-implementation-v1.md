# RecordListScreen 구현 가이드

## 구현 요약

승인된 개선 제안서를 기반으로 RecordListScreen의 UI를 Gabium Design System과 완전히 일관되게 개선합니다.

**구현할 변경사항:**
1. 브랜드 색상 시스템 적용
2. 기록 항목 카드 구조 개선
3. 타이포그래피 계층 강화
4. 기록 타입별 시각적 구분
5. 빈 상태(Empty State) 개선
6. 피드백 컴포넌트 현대화
7. 로딩 및 인터랙션 상태 강화

---

## Design System 토큰 값

제안서의 Design System Token Reference 테이블 그대로 사용:

| 요소 | 토큰 경로 | 값 | 사용처 |
|------|---------|-----|-------|
| AppBar 배경 | Colors - Neutral - 50 | #F8FAFC | 상단 바 배경 |
| AppBar 텍스트 | Typography - xl | 20px, Bold (700), #1E293B | 화면 제목 |
| 탭 활성 텍스트 | Colors - Primary | #4ADE80 | 활성 탭 라벨 |
| 탭 활성 라인 | Colors - Primary + Border | #4ADE80, 2px | 탭 하단 강조 |
| 탭 비활성 텍스트 | Colors - Neutral - 500 | #64748B | 비활성 탭 라벨 |
| 카드 배경 | Neutral - White | #FFFFFF | 기록 항목 컨테이너 |
| 카드 테두리 | Colors - Neutral - 200 | #E2E8F0, 1px | 카드 경계 |
| 카드 모서리 | Border Radius - md | 12px | 카드 라운딩 |
| 카드 그림자 | Shadow - sm | 0 2px 4px rgba(15,23,42,0.06) | 카드 깊이감 |
| 카드 호버 그림자 | Shadow - md | 0 4px 8px rgba(15,23,42,0.08) | 상호작용 피드백 |
| 카드 내부 패딩 | Spacing - md | 16px | 컨텐츠 여백 |
| 항목 간 간격 | Spacing - md | 16px | 카드 사이 간격 |
| 기본 정보 텍스트 | Typography - lg | 18px, Semibold (600) | 주요 정보 표시 |
| 보조 정보 텍스트 | Typography - base | 16px, Regular (400) | 보조 정보 표시 |
| 메타데이터 텍스트 | Typography - sm | 14px, Regular (400), #64748B | 날짜/시간 |
| 아이콘 색상(체중) | Colors - Emerald | #10B981 | 체중 기록 구분 |
| 아이콘 색상(증상) | Colors - Amber | #F59E0B | 증상 기록 구분 |
| 아이콘 색상(투여) | Colors - Primary | #4ADE80 | 투여 기록 구분 |
| 삭제 버튼 | Colors - Error | #EF4444 | 위험 액션 |
| 삭제 버튼 호버 | Colors - Error darker | #DC2626 | 호버 상태 |
| 에러 색상 | Colors - Error | #EF4444 | 에러 메시지 |
| 성공 색상 | Colors - Success | #10B981 | 성공 메시지 |
| 모달 배경 | Neutral - White | #FFFFFF | 다이얼로그 컨테이너 |
| 모달 모서리 | Border Radius - lg | 16px | 다이얼로그 라운딩 |
| 모달 그림자 | Shadow - xl | 0 16px 32px rgba(15,23,42,0.12) | 모달 강조 |
| 로딩 스피너 | Colors - Primary | #4ADE80 | 로딩 표시 |
| Empty State 제목 | Typography - lg | 18px, Semibold (600), #334155 | 빈 화면 제목 |
| Empty State 설명 | Typography - base | 16px, Regular (400), #64748B | 빈 화면 설명 |

---

## Change 1: 브랜드 색상 시스템 적용

### 컴포넌트 명세

**AppBar (화면 상단)**

- **배경색:** #F8FAFC (Colors - Neutral - 50)
- **높이:** 56px
- **테두리:** 1px solid #E2E8F0 (Colors - Neutral - 200) 하단
- **제목 텍스트:**
  - 내용: "기록 관리"
  - 크기: 20px (Typography - xl)
  - 무게: Bold (700)
  - 색상: #1E293B (Colors - Neutral - 800)
  - 패딩: 좌측 16px, 수직 중앙 정렬
- **상호작용 상태:** 없음 (정적 요소)

**TabBar (탭 네비게이션)**

- **배경색:** Transparent (투명)
- **높이:** 48px
- **하단 테두리:** 1px solid #E2E8F0 (Colors - Neutral - 200)
- **탭 아이템:**
  - **패딩:** 12px 수평, 0px 수직
  - **폰트:** 16px (Typography - base), Medium (500)
  - **비활성 탭 텍스트 색상:** #64748B (Colors - Neutral - 500)
  - **활성 탭 텍스트 색상:** #4ADE80 (Colors - Primary)
  - **활성 탭 하단 강조:** 2px 굵기, #4ADE80 (Colors - Primary)
  - **호버 배경:** #F1F5F9 (Colors - Neutral - 100)

**TabBarView 배경**

- **색상:** #F8FAFC (Colors - Neutral - 50)
- **패딩:** 16px 좌우 (모바일 마진)

### 레이아웃 구조

```
┌──────────────────────────────────────────┐
│ AppBar (#F8FAFC 배경)                    │
│ "기록 관리" (20px, Bold, #1E293B)        │
├──────────────────────────────────────────┤
│ TabBar                                   │
│ [체중] [증상] [투여]                      │
│ 활성 탭: #4ADE80 텍스트 + 2px 하단선      │
├──────────────────────────────────────────┤
│ TabBarView Content (#F8FAFC 배경)        │
│ (이하 Change 2 참조)                      │
└──────────────────────────────────────────┘
```

### 상호작용 명세

**탭 클릭:**
- 트리거: 다른 탭으로 전환
- 시각적 피드백: 텍스트 색상 변경 (비활성 → 활성), 하단선 이동
- 애니메이션: 200ms ease-in-out (Transitions - base)
- TabBarView 콘텐츠 전환 (기본 TabBar 동작)

---

## Change 2: 기록 항목 카드 구조 개선

### 컴포넌트 명세

**RecordListCard 컨테이너**

- **배경색:** #FFFFFF (White)
- **테두리:** 1px solid #E2E8F0 (Colors - Neutral - 200)
- **모서리:** 12px (Border Radius - md)
- **그림자 (기본):** 0 2px 4px rgba(15, 23, 42, 0.06) (Shadow - sm)
- **그림자 (호버):** 0 4px 8px rgba(15, 23, 42, 0.08) (Shadow - md)
- **패딩:** 16px (Spacing - md)
- **좌측 컬러바:** 4px 굵기, 타입별 색상 (Change 4 참조)
- **높이:** 자동 (콘텐츠 기반)
- **최소 높이:** 72px (comfortable touch area)
- **마진:** 상하 16px (Spacing - md), 좌우 16px (모바일 마진)
- **너비:** 100% - 32px (좌우 마진)

**카드 내부 구조:**

```
┌─────────────────────────────────────────────┐
│ │●│ [기본 정보] (lg, Semibold)         [Delete]
│ │  │ [보조 정보] (base, Regular)
│ │  │ [메타데이터] (sm, Regular, #64748B)
└─────────────────────────────────────────────┘
   ↑
   좌측 4px 컬러바 (타입별 색상)
```

**좌측 컬러바 색상:**
- 체중: #10B981 (Colors - Emerald)
- 증상: #F59E0B (Colors - Amber)
- 투여: #4ADE80 (Colors - Primary)

### 레이아웃 상세

**카드 내부 레이아웃:**
- **플렉스 방향:** Row (수평)
- **정렬:** Space-between (왼쪽 컨텐츠, 오른쪽 삭제 버튼)
- **수직 정렬:** Center

**좌측 컬러바:**
- **위치:** 카드 왼쪽 끝, 거터 없음 (카드 가장자리)
- **너비:** 4px
- **높이:** 100% (카드 전체 높이)
- **모서리:** 좌상단 12px, 좌하단 12px

**기본 정보 영역:**
- **폰트:** 18px (Typography - lg), Semibold (600)
- **색상:** #1E293B (Colors - Neutral - 800, 기본값 또는 토큰명시)
- **여백:** 하단 4px (xs)

**보조 정보 영역:**
- **폰트:** 16px (Typography - base), Regular (400)
- **색상:** #475569 (Colors - Neutral - 600)
- **여백:** 하단 4px (xs)

**메타데이터 영역:**
- **폰트:** 14px (Typography - sm), Regular (400)
- **색상:** #64748B (Colors - Neutral - 500)
- **형식:** "YYYY-MM-DD HH:mm"

**삭제 아이콘 버튼:**
- **크기:** 44x44px (터치 영역)
- **아이콘:** delete_outline, 24x24px
- **아이콘 색상:** #EF4444 (Colors - Error)
- **배경:** Transparent
- **호버 배경:** #FEF2F2 (Error at 10% opacity)
- **위치:** 카드 오른쪽, 자체 정렬

### 상호작용 명세

**카드 호버 상태:**
- **배경:** 변경 없음 (#FFFFFF 유지)
- **그림자:** Shadow md (0 4px 8px rgba(15, 23, 42, 0.08))
- **변환:** translateY(-2px)
- **전환 시간:** 200ms ease-in-out (Transitions - base)
- **커서:** pointer

**카드 클릭:**
- **현재:** 네비게이션 없음 (향후 상세 보기 기능 추가 가능)
- **피드백:** 호버 상태 유지, 삭제 버튼 활성화

**삭제 버튼 상호작용:**
- **기본 상태:**
  - 배경: Transparent
  - 아이콘 색상: #EF4444 (Colors - Error)
- **호버 상태:**
  - 배경: #FEF2F2 (Error 색상 at 10% opacity)
  - 아이콘 색상: #DC2626 (Colors - Error darker)
  - 커서: pointer
- **클릭:**
  - 트리거: Change 6의 삭제 확인 모달 표시
  - 동작: 모달을 통한 확인 후 기록 삭제

**롱프레스 피드백:**
- **배경:** #F1F5F9 (Colors - Neutral - 100)
- **전환 시간:** Instant (150ms 또는 없음)

---

## Change 3: 타이포그래피 계층 강화

### 컴포넌트 명세

**기본 정보 텍스트 (주요 데이터)**

- **폰트 크기:** 18px (Typography - lg)
- **폰트 무게:** Semibold (600)
- **색상:** #1E293B (Colors - Neutral - 800, 기본 텍스트)
- **줄높이:** 26px
- **글자 간격:** 0
- **사용처:**
  - 체중: "68.5 kg"
  - 증상: "복부 팽만감"
  - 투여: "0.25 mg"

**보조 정보 텍스트 (컨텍스트)**

- **폰트 크기:** 16px (Typography - base)
- **폰트 무게:** Regular (400)
- **색상:** #475569 (Colors - Neutral - 600)
- **줄높이:** 24px
- **글자 간격:** 0
- **사용처:**
  - 체중: (특별한 보조정보 없음)
  - 증상: "심각도: 5/10" 또는 "중간 정도"
  - 투여: "왼쪽 허벅지"

**메타데이터 텍스트 (날짜/시간)**

- **폰트 크기:** 14px (Typography - sm)
- **폰트 무게:** Regular (400)
- **색상:** #64748B (Colors - Neutral - 500)
- **줄높이:** 20px
- **글자 간격:** 0
- **포맷:** "2025년 11월 24일 오전 10:30" 또는 ISO 형식
- **위치:** 메타데이터 영역 (가장 아래)

### 레이아웃 구조 (타입별)

**체중 기록:**
```
┌────────────────────────────────────────┐
│ 68.5 kg (lg, Semibold, #1E293B)       │
│ 2025년 11월 24일 10:30                 │ (sm, Regular, #64748B)
└────────────────────────────────────────┘
```

**증상 기록:**
```
┌────────────────────────────────────────┐
│ 복부 팽만감 (lg, Semibold, #1E293B)   │
│ 심각도: 5/10 (base, Regular, #475569) │
│ 2025년 11월 24일 10:30                 │ (sm, Regular, #64748B)
└────────────────────────────────────────┘
```

**투여 기록:**
```
┌────────────────────────────────────────┐
│ 0.25 mg (lg, Semibold, #1E293B)       │
│ 왼쪽 허벅지 (base, Regular, #475569)   │
│ 2025년 11월 24일 10:30                 │ (sm, Regular, #64748B)
└────────────────────────────────────────┘
```

### 상호작용 명세

**선택 상태:**
- 텍스트 색상 변경 없음
- 카드 호버 상태로 인한 시각적 구분 (Change 2 참조)

---

## Change 4: 기록 타입별 시각적 구분

### 컴포넌트 명세

**RecordTypeIcon 컴포넌트**

이는 기록 타입에 따라 올바른 아이콘과 색상을 반환하는 재사용 가능한 위젯입니다.

**체중 기록:**
- **아이콘:** scale (무게 저울)
- **크기:** 24x24px
- **색상:** #10B981 (Colors - Emerald)
- **좌측 컬러바:** #10B981 (Colors - Emerald), 4px 굵기

**증상 기록:**
- **아이콘:** alert_circle (경고 원)
- **크기:** 24x24px
- **색상:** #F59E0B (Colors - Amber)
- **좌측 컬러바:** #F59E0B (Colors - Amber), 4px 굵기

**투여 기록:**
- **아이콘:** syringe (주사)
- **크기:** 24x24px
- **색상:** #4ADE80 (Colors - Primary)
- **좌측 컬러바:** #4ADE80 (Colors - Primary), 4px 굵기

### 레이아웃 구조

**카드 내부 아이콘 배치:**

좌측 컬러바와 함께, 기본 정보 앞에 아이콘 표시 (선택사항):

```
┌─────────────────────────────────────────┐
│ │●│ [Icon] 기본 정보           [Delete] │
│ │  │         보조 정보                   │
│ │  │         메타데이터                  │
└─────────────────────────────────────────┘
```

또는 좌측 컬러바만 유지하고, 탭 제목에서 시각적 구분 제공.

### 구현 옵션

**Option 1 (추천):** 좌측 컬러바만 사용
- 최소한의 시각적 복잡도
- RecordListCard 컴포넌트에 좌측 4px 컬러바 내장
- 타입별로 자동 색상 적용

**Option 2:** 아이콘 + 컬러바 함께 사용
- 더 강한 시각적 구분
- RecordTypeIcon 컴포넌트 생성
- 각 카드의 텍스트 앞에 아이콘 표시

**권장:** 당분간 Option 1로 시작하여, 추후 필요시 Option 2로 확장.

### 상호작용 명세

**아이콘 호버 (Option 2 선택 시):**
- 색상 변경 없음
- 카드 호버에 포함

---

## Change 5: 빈 상태(Empty State) 개선

### 컴포넌트 명세

**EmptyRecordState 컴포넌트**

이는 기록이 없을 때 표시되는 재사용 가능한 위젯입니다.

**정렬:**
- **수평:** Center (중앙)
- **수직:** Center (화면 중앙)
- **전체 높이:** 화면 높이 - AppBar - TabBar

**컨테이너:**
- **배경:** #F8FAFC (Colors - Neutral - 50)
- **패딩:** 64px 상하 (Spacing - 3xl)
- **너비:** 100%

**일러스트레이션:**
- **크기:** 120x120px
- **색상:** #CBD5E1 (Colors - Neutral - 300)
- **형태:** 스켈레톤 또는 단순 아이콘 (예: empty_box, folder_open)

**제목:**
- **텍스트:** "기록이 없습니다"
- **폰트 크기:** 18px (Typography - lg)
- **폰트 무게:** Semibold (600)
- **색상:** #334155 (Colors - Neutral - 700)
- **여백:** 상단 24px (Spacing - lg)

**설명:**
- **텍스트:** "아직 기록이 없습니다. 첫 번째 기록을 추가해보세요."
- **폰트 크기:** 16px (Typography - base)
- **폰트 무게:** Regular (400)
- **색상:** #64748B (Colors - Neutral - 500)
- **줄높이:** 24px
- **여백:** 상단 8px (Spacing - sm)
- **최대 너비:** 280px (텍스트 가독성)
- **정렬:** Center

**액션 버튼:**
- **스타일:** Secondary (GabiumButton Secondary variant)
- **텍스트:** "돌아가기" 또는 "홈으로"
- **백그라운드:** Transparent
- **테두리:** 2px solid #4ADE80 (Colors - Primary)
- **텍스트 색상:** #4ADE80 (Colors - Primary), Semibold (600)
- **여백:** 상단 32px (Spacing - xl)
- **크기:** Medium (44px 높이)
- **너비:** Auto (텍스트 기반)
- **호버:** 배경 #4ADE80 at 8%, 테두리 더 진함

### 레이아웃 구조

```
┌──────────────────────────────────────────┐
│                                          │
│              [일러스트레이션]              │
│              (120x120px)                 │
│                                          │
│          기록이 없습니다                   │
│    (18px, Semibold, #334155)            │
│                                          │
│   아직 기록이 없습니다.                   │
│   첫 번째 기록을 추가해보세요.             │
│   (16px, Regular, #64748B)              │
│                                          │
│           [돌아가기 버튼]                  │
│      (Secondary 스타일, 44px 높이)       │
│                                          │
└──────────────────────────────────────────┘
```

### 상호작용 명세

**버튼 클릭:**
- 트리거: 이전 화면 또는 홈으로 네비게이션
- 라우터 호출: `context.pop()` 또는 `context.go('/')`

**조건:**
- 선택된 탭(체중/증상/투여)에 기록이 없을 때 표시
- 각 탭마다 독립적으로 표시/숨김

---

## Change 6: 피드백 컴포넌트 현대화

### 삭제 확인 모달 (GabiumModal 사용)

**컨테이너:**
- **배경:** #FFFFFF (White)
- **모서리:** 16px (Border Radius - lg)
- **그림자:** 0 16px 32px rgba(15, 23, 42, 0.12) (Shadow - xl)
- **최대 너비:** 480px (모바일: 90% viewport)
- **패딩:** 24px

**모달 배경 (Backdrop):**
- **색상:** rgba(15, 23, 42, 0.5) (Neutral-900 at 50% opacity)
- **전환 시간:** 200ms ease-in-out

**헤더:**
- **제목:** "기록을 삭제하시겠습니까?"
- **폰트 크기:** 24px (Typography - 2xl)
- **폰트 무게:** Bold (700)
- **색상:** #1E293B (Colors - Neutral - 800)
- **여백:** 하단 16px
- **닫기 버튼:** 상단 우측, 기본 제공 (X 아이콘)

**본문:**
- **텍스트:** "삭제된 기록은 복구할 수 없습니다."
- **폰트 크기:** 16px (Typography - base)
- **폰트 무게:** Regular (400)
- **색상:** #64748B (Colors - Neutral - 500)
- **줄높이:** 24px
- **여백:** 하단 24px (Spacing - lg)

**액션 영역:**
- **정렬:** 우측 정렬 (right-aligned)
- **버튼 간격:** 16px

**취소 버튼:**
- **스타일:** Secondary (GabiumButton Secondary variant)
- **텍스트:** "취소"
- **백그라운드:** Transparent
- **테두리:** 2px solid #4ADE80 (Colors - Primary)
- **크기:** Medium (44px 높이)

**삭제 버튼:**
- **스타일:** Danger (GabiumButton Danger variant)
- **텍스트:** "삭제"
- **배경:** #EF4444 (Colors - Error)
- **텍스트 색상:** #FFFFFF, Semibold (600)
- **호버:** 배경 #DC2626 (Colors - Error darker)
- **크기:** Medium (44px 높이)

### 삭제 성공 토스트 (GabiumToast 사용)

**컨테이너:**
- **너비:** 모바일 90% viewport (최대 360px), 데스크톱 400px
- **배경:** #ECFDF5 (Success 색상 at 10% opacity)
- **테두리 좌측:** 4px #10B981 (Colors - Success)
- **모서리:** 12px (Border Radius - md)
- **패딩:** 16px
- **그림자:** 0 8px 16px rgba(15, 23, 42, 0.10) (Shadow - lg)
- **위치:** 하단 중앙 (모바일), 상단 우측 (데스크톱)

**아이콘:**
- **아이콘:** check_circle
- **크기:** 24x24px
- **색상:** #10B981 (Colors - Success)
- **위치:** 좌측, 12px 여백

**텍스트:**
- **텍스트:** "기록이 삭제되었습니다."
- **폰트 크기:** 16px (Typography - base)
- **폰트 무게:** Regular (400)
- **색상:** #065F46 (Success darker)
- **여백:** 좌측 12px (아이콘과의 간격)

**애니메이션:**
- **진입:** Slide-up (모바일) 또는 Slide-in-right (데스크톱), 200ms
- **표시 시간:** 3초 (자동 닫힘)
- **종료:** Fade-out, 200ms

**닫기 버튼 (선택사항):**
- **크기:** 20x20px
- **위치:** 우측, 12px 여백
- **아이콘:** close

### 삭제 실패 토스트 (GabiumToast 사용)

**컨테이너:**
- **배경:** #FEF2F2 (Error 색상 at 10% opacity)
- **테두리 좌측:** 4px #EF4444 (Colors - Error)
- 나머지는 성공 토스트와 동일

**아이콘:**
- **아이콘:** error 또는 alert_circle
- **색상:** #EF4444 (Colors - Error)

**텍스트:**
- **텍스트:** "기록 삭제 중 오류가 발생했습니다. 다시 시도해주세요."
- **색상:** #991B1B (Error darker)

**표시 시간:** 5초 (오류는 더 길게)

### 상호작용 명세

**삭제 버튼 클릭 → 모달 표시:**
- 트리거: RecordListCard의 삭제 버튼 클릭
- 시각적 피드백: 모달 페이드인 + 배경 어두워짐
- 애니메이션: 200ms ease-in-out (모달 나타남)

**모달에서 "삭제" 클릭:**
- 트리거: 기록 삭제 시작
- 동작:
  1. 모달 닫힘 (200ms fade-out)
  2. 기록 삭제 API 호출
  3. 성공 시 토스트 표시
  4. 목록에서 항목 제거 (애니메이션)

**모달에서 "취소" 클릭:**
- 트리거: 모달 닫힘
- 애니메이션: 200ms fade-out

**토스트 자동 닫힘:**
- 성공: 3초 후 자동 종료
- 실패: 5초 후 자동 종료
- 수동 닫기: 닫기 버튼 클릭 (선택사항)

---

## Change 7: 로딩 및 인터랙션 상태 강화

### 로딩 상태

**전체 페이지 로딩:**
- **트리거:** 화면 진입, 탭 변경, 새로고침
- **표시:**
  - CircularProgressIndicator (24x24px 또는 48x48px)
  - 색상: #4ADE80 (Colors - Primary)
  - 텍스트: "기록을 불러오는 중..." (base, Regular, #64748B)
  - 위치: 화면 중앙
  - 배경: 투명 (목록 뒤에 표시) 또는 반투명 오버레이 (선택사항)

**스켈레톤 로더 (선택사항):**
- 로딩 중 카드 모양의 스켈레톤 표시
- **배경:** #E2E8F0 (Colors - Neutral - 200)
- **애니메이션:** Shimmer 효과 (1.5초 무한 반복)
- **개수:** 3개 (예상 아이템 수)

### 인터랙션 피드백

**카드 호버 상태:**
- **트리거:** 마우스 오버 또는 포커스
- **배경:** 변경 없음 (#FFFFFF 유지)
- **그림자:** Shadow md (0 4px 8px rgba(15, 23, 42, 0.08))
- **변환:** translateY(-2px)
- **전환 시간:** 200ms ease-in-out (Transitions - base)
- **커서:** pointer

**카드 롱프레스/포커스:**
- **배경:** #F1F5F9 (Colors - Neutral - 100)
- **전환 시간:** Instant (150ms 또는 없음)
- **모바일:** 롱프레스 제스처 감지 시 적용 (선택사항)

**삭제 버튼 호버:**
- **기본:**
  - 배경: Transparent
  - 아이콘 색상: #EF4444 (Colors - Error)
- **호버:**
  - 배경: #FEF2F2 (Error at 10% opacity)
  - 아이콘 색상: #DC2626 (Colors - Error darker)
  - 전환 시간: 150ms (Transitions - fast)
  - 커서: pointer

**삭제 버튼 클릭:**
- **시각적 피드백:** 배경 색상 변경, 아이콘 색상 진함
- **전환 시간:** Instant
- **동작:** 삭제 확인 모달 표시 (Change 6)

### 레이아웃 구조 (로딩 상태)

```
┌──────────────────────────────────────────┐
│ AppBar                                   │
├──────────────────────────────────────────┤
│ TabBar                                   │
├──────────────────────────────────────────┤
│                                          │
│          [CircularProgressIndicator]     │
│          (24x24px, #4ADE80)              │
│                                          │
│          기록을 불러오는 중...            │
│          (base, Regular, #64748B)        │
│                                          │
└──────────────────────────────────────────┘
```

또는 스켈레톤 로더:

```
┌──────────────────────────────────────────┐
│ AppBar                                   │
├──────────────────────────────────────────┤
│ TabBar                                   │
├──────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │▒▒▒▒▒▒▒▒▒▒▒▒▒ (Shimmer animation)    │ │
│ └─────────────────────────────────────┘ │
│                                          │
│ ┌─────────────────────────────────────┐ │
│ │▒▒▒▒▒▒▒▒▒▒▒▒▒ (Shimmer animation)    │ │
│ └─────────────────────────────────────┘ │
│                                          │
│ ┌─────────────────────────────────────┐ │
│ │▒▒▒▒▒▒▒▒▒▒▒▒▒ (Shimmer animation)    │ │
│ └─────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

---

## 구현별 프레임워크 가이드

### Flutter (Dart)

**전체 화면 구조:**

```dart
// record_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gabium_tokens.dart';

class RecordListScreen extends ConsumerWidget {
  const RecordListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildWeightRecordList(context, ref),
                  _buildSymptomRecordList(context, ref),
                  _buildDoseRecordList(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Change 1: AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFFF8FAFC), // Colors - Neutral - 50
      title: Text(
        '기록 관리',
        style: TextStyle(
          fontSize: 20, // Typography - xl
          fontWeight: FontWeight.bold, // 700
          color: Color(0xFF1E293B), // Colors - Neutral - 800
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          color: Color(0xFFE2E8F0), // Colors - Neutral - 200
          height: 1,
        ),
      ),
    );
  }

  // Change 1: TabBar
  Widget _buildTabBar() {
    return Container(
      color: Colors.transparent,
      child: TabBar(
        labelColor: Color(0xFF4ADE80), // Colors - Primary
        unselectedLabelColor: Color(0xFF64748B), // Colors - Neutral - 500
        labelStyle: TextStyle(
          fontSize: 16, // Typography - base
          fontWeight: FontWeight.w500, // Medium (500)
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xFF4ADE80), // Colors - Primary
            width: 2, // 2px
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: '체중'),
          Tab(text: '증상'),
          Tab(text: '투여'),
        ],
      ),
    );
  }

  // Change 2: RecordListCard 컴포넌트
  Widget _buildWeightRecordList(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weightRecordsProvider);

    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return _buildEmptyState(); // Change 5
        }

        return Container(
          color: Color(0xFFF8FAFC), // Colors - Neutral - 50
          padding: EdgeInsets.symmetric(horizontal: 16), // md
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16), // md
            itemCount: records.length,
            separatorBuilder: (_, __) => SizedBox(height: 16), // md
            itemBuilder: (context, index) {
              final record = records[index];
              return RecordListCard(
                record: record,
                recordType: RecordType.weight,
                colorBar: Color(0xFF10B981), // Colors - Emerald
                onDelete: () => _showDeleteConfirm(context, record),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Change 3: 기본 정보
                    Text(
                      '${record.weight} kg',
                      style: TextStyle(
                        fontSize: 18, // Typography - lg
                        fontWeight: FontWeight.w600, // Semibold (600)
                        color: Color(0xFF1E293B), // Neutral - 800
                      ),
                    ),
                    SizedBox(height: 4), // xs
                    // Change 3: 메타데이터
                    Text(
                      formatDateTime(record.recordedAt),
                      style: TextStyle(
                        fontSize: 14, // Typography - sm
                        fontWeight: FontWeight.normal, // Regular (400)
                        color: Color(0xFF64748B), // Neutral - 500
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => _buildLoadingState(), // Change 7
      error: (err, _) => _buildErrorState(err),
    );
  }

  // Change 2: RecordListCard 재사용 컴포넌트
  // 파일: lib/features/record_management/presentation/widgets/record_list_card.dart
}

// 별도 파일: record_list_card.dart
class RecordListCard extends StatefulWidget {
  final Widget child;
  final Record record;
  final RecordType recordType;
  final Color colorBar;
  final VoidCallback onDelete;

  const RecordListCard({
    required this.child,
    required this.record,
    required this.recordType,
    required this.colorBar,
    required this.onDelete,
  });

  @override
  _RecordListCardState createState() => _RecordListCardState();
}

class _RecordListCardState extends State<RecordListCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
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
        setState(() => _isHovering = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onLongPress: () {
          // Change 7: 롱프레스 피드백
          setState(() {});
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -2 * _hoverController.value),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF), // White
                  border: Border.all(
                    color: Color(0xFFE2E8F0), // Neutral - 200
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12), // md
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                    if (_isHovering)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // Change 4: 좌측 컬러바
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: widget.colorBar,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16), // md
                        child: widget.child,
                      ),
                    ),
                    // 삭제 버튼
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: widget.onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Color(0xFFEF4444), // Error
                          size: 24,
                        ),
                        splashColor: Color(0xFFFEF2F2),
                        highlightColor: Color(0xFFFEF2F2),
                        hoverColor: Color(0xFFFEF2F2),
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

// Change 5: EmptyRecordState 컴포넌트
Widget _buildEmptyState() {
  return Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 일러스트레이션
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFCBD5E1), // Neutral - 300
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 60,
              color: Color(0xFFE2E8F0), // Neutral - 200
            ),
          ),
          SizedBox(height: 24), // lg
          // 제목
          Text(
            '기록이 없습니다',
            style: TextStyle(
              fontSize: 18, // lg
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral - 700
            ),
          ),
          SizedBox(height: 8), // sm
          // 설명
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '아직 기록이 없습니다.\n첫 번째 기록을 추가해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B), // Neutral - 500
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32), // xl
          // 버튼
          GabiumButton.secondary(
            label: '돌아가기',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

// Change 6: 삭제 확인 모달
void _showDeleteConfirm(BuildContext context, Record record) {
  showDialog(
    context: context,
    builder: (context) => GabiumModal(
      title: '기록을 삭제하시겠습니까?',
      content: '삭제된 기록은 복구할 수 없습니다.',
      actions: [
        GabiumButton.secondary(
          label: '취소',
          onPressed: () => Navigator.pop(context),
        ),
        GabiumButton.danger(
          label: '삭제',
          onPressed: () {
            // 삭제 로직
            Navigator.pop(context);
            _deleteRecord(context, record);
          },
        ),
      ],
    ),
  );
}

// Change 6: 삭제 성공/실패 토스트
void _deleteRecord(BuildContext context, Record record) {
  try {
    // API 호출
    // ...
    GabiumToast.success(
      message: '기록이 삭제되었습니다.',
      duration: Duration(seconds: 3),
    ).show(context);
  } catch (e) {
    GabiumToast.error(
      message: '기록 삭제 중 오류가 발생했습니다. 다시 시도해주세요.',
      duration: Duration(seconds: 5),
    ).show(context);
  }
}

// Change 7: 로딩 상태
Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF4ADE80), // Colors - Primary
          ),
          strokeWidth: 3,
        ),
        SizedBox(height: 16), // md
        Text(
          '기록을 불러오는 중...',
          style: TextStyle(
            fontSize: 16, // base
            fontWeight: FontWeight.normal,
            color: Color(0xFF64748B), // Neutral - 500
          ),
        ),
      ],
    ),
  );
}
```

**Gabium 컴포넌트 (기존 또는 생성):**

```dart
// 파일: lib/features/common/presentation/widgets/gabium_button.dart
class GabiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final GabiumButtonVariant variant;
  final GabiumButtonSize size;
  final bool isLoading;

  const GabiumButton({
    required this.label,
    this.onPressed,
    this.variant = GabiumButtonVariant.primary,
    this.size = GabiumButtonSize.medium,
    this.isLoading = false,
  });

  factory GabiumButton.secondary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GabiumButton(
      label: label,
      onPressed: onPressed,
      variant: GabiumButtonVariant.secondary,
    );
  }

  factory GabiumButton.danger({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GabiumButton(
      label: label,
      onPressed: onPressed,
      variant: GabiumButtonVariant.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 구현...
  }
}

enum GabiumButtonVariant { primary, secondary, tertiary, ghost, danger }
enum GabiumButtonSize { small, medium, large }
```

```dart
// 파일: lib/features/common/presentation/widgets/gabium_modal.dart
class GabiumModal extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const GabiumModal({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24, // 2xl
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 16, // base
          fontWeight: FontWeight.normal,
          color: Color(0xFF64748B),
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg
      ),
      elevation: 4, // xl shadow approximation
      actions: actions,
    );
  }
}
```

```dart
// 파일: lib/features/common/presentation/widgets/gabium_toast.dart
class GabiumToast {
  final String message;
  final Duration duration;
  final GabiumToastVariant variant;

  GabiumToast({
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.variant = GabiumToastVariant.info,
  });

  factory GabiumToast.success({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return GabiumToast(
      message: message,
      duration: duration,
      variant: GabiumToastVariant.success,
    );
  }

  factory GabiumToast.error({
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    return GabiumToast(
      message: message,
      duration: duration,
      variant: GabiumToastVariant.error,
    );
  }

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getBackgroundColor(),
        duration: duration,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case GabiumToastVariant.success:
        return Color(0xFF10B981); // Success
      case GabiumToastVariant.error:
        return Color(0xFFEF4444); // Error
      default:
        return Color(0xFF3B82F6); // Info
    }
  }
}

enum GabiumToastVariant { success, error, warning, info }
```

---

## 구현 순서

전체 구현을 다음 순서대로 진행하세요:

### Phase 1: 기초 구조 (1-2일)
1. **Change 1 구현**: AppBar + TabBar 색상 및 스타일 변경
2. **Change 2 구현**: RecordListCard 컴포넌트 생성 및 적용
3. **Gabium 컴포넌트 확보**: GabiumButton, GabiumModal, GabiumToast 확인/생성

### Phase 2: 콘텐츠 계층 (1-2일)
4. **Change 3 구현**: 타이포그래피 계층 (기본/보조/메타데이터)
5. **Change 4 구현**: 좌측 컬러바 + RecordTypeIcon (선택사항)
6. **Change 5 구현**: EmptyRecordState 컴포넌트

### Phase 3: 상호작용 및 상태 (1-2일)
7. **Change 6 구현**: 삭제 모달 + 토스트
8. **Change 7 구현**: 로딩 상태 + 호버 애니메이션

### Phase 4: 테스트 및 마무리 (1일)
9. 모든 상태 조합 테스트 (로딩, 빈 상태, 일반 목록)
10. 반응형 확인 (다양한 기기 크기)
11. 접근성 검증 (터치 타겟, 색상 대비, 포커스)

---

## 파일 구조 (생성/수정)

### 생성할 파일

**새로운 재사용 컴포넌트:**
- `lib/features/record_management/presentation/widgets/record_list_card.dart` (RecordListCard)
- `lib/features/record_management/presentation/widgets/record_type_icon.dart` (RecordTypeIcon - 선택사항)
- `lib/features/record_management/presentation/widgets/empty_record_state.dart` (EmptyRecordState)

**Gabium 컴포넌트 (필요시 생성/업데이트):**
- `lib/features/common/presentation/widgets/gabium_button.dart` (Secondary, Danger 변형 확인)
- `lib/features/common/presentation/widgets/gabium_modal.dart`
- `lib/features/common/presentation/widgets/gabium_toast.dart`

**디자인 토큰 정의:**
- `lib/design_system/gabium_tokens.dart` (색상, 타이포그래피, 간격 상수)

### 수정할 파일

**기존 화면:**
- `lib/features/record_management/presentation/screens/record_list_screen.dart`
  - AppBar 스타일 변경 (Change 1)
  - TabBar 스타일 변경 (Change 1)
  - 기록 목록 레이아웃 개선 (Change 2-7)
  - 삭제 로직 업데이트 (Change 6)

### 필요 자산

- 일러스트레이션 (120x120px) - Empty State용
- 또는 Material Icons/Symbols 사용 (folder_open 등)

---

## 접근성 체크리스트

- [ ] 색상 대비 WCAG AA 충족 (4.5:1 이상)
  - 텍스트: #1E293B/#64748B on #FFFFFF ✓
  - 버튼: #FFFFFF on #4ADE80 ✓
  - 에러: #FFFFFF on #EF4444 ✓
- [ ] 터치 타겟 최소 44x44px
  - 삭제 버튼: 44x44px ✓
  - 탭: 최소 48px 높이 ✓
  - 모달 버튼: 44px 높이 ✓
- [ ] 포커스 인디케이터 시각화
  - 키보드 네비게이션 지원
  - Focus outline 적용
- [ ] 스크린 리더 지원
  - 아이콘 버튼에 Semantics 레이블
  - 모달 타이틀 공지
- [ ] 모션 설정 존중
  - prefers-reduced-motion 확인 후 애니메이션 비활성화 (향후)

---

## 테스트 체크리스트

- [ ] 기록 목록 표시 (3가지 타입 모두)
- [ ] 빈 상태 표시 (각 탭별)
- [ ] 로딩 상태 표시
- [ ] 기록 삭제 (모달 → 확인 → 토스트)
- [ ] 탭 전환 애니메이션
- [ ] 카드 호버 효과 (데스크톱)
- [ ] 삭제 버튼 호버/클릭
- [ ] 모달 열림/닫힘
- [ ] 토스트 자동 닫힘 (3초/5초)
- [ ] 기기별 반응형 (모바일, 태블릿)
- [ ] 한글 텍스트 줄 바꿈 확인

---

## 주요 고려사항

### 1. 기존 로직 보존
- 탭별 기록 조회 로직 변경 없음
- 삭제 API 호출 방식 유지
- Riverpod 상태 관리 구조 유지

### 2. 점진적 적용
- 한 번에 한 Change씩 구현하여 테스트
- 각 단계에서 시각적 회귀 확인
- 커밋 단위: 변경당 1-2개 커밋

### 3. 재사용성
- RecordListCard, EmptyRecordState 컴포넌트화
- Gabium 컴포넌트 라이브러리 확장
- Component Registry 업데이트 (Phase 3)

### 4. 성능
- 불필요한 리빌드 방지 (const 생성자 활용)
- 큰 목록의 경우 LazyBuilder 고려
- 애니메이션 프레임 드롭 모니터링

---

**이 가이드는 Gabium Design System v1.0을 엄격히 따르며, 모든 토큰 값을 명확히 기재합니다. 구현 시 이 명세를 그대로 따르면 디자인 완벽성을 보장할 수 있습니다.**

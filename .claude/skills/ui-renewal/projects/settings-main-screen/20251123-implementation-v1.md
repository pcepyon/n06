# 설정 메인 화면 구현 가이드

**문서 버전:** v1
**작성일:** 2025-11-23
**프레임워크:** Flutter (Null-safe Dart)
**상태:** 구현 준비 완료

---

## 1. 구현 개요

승인된 개선 제안에 따라 설정 화면을 Gabium Design System에 맞춰 리디자인합니다.

**구현할 변경사항:**
1. 사용자 정보 섹션을 카드 기반 디자인으로 강화
2. 설정 메뉴 항목 스타일 개선 (터치 영역, 구분선, 호버 상태)
3. 로그아웃 버튼을 Danger 스타일로 구분
4. 섹션 간 시각적 계층 강화 (제목, 일관된 여백)
5. 전체 배경색을 Design System 토큰으로 통일

---

## 2. Design System 토큰 값

| 요소 | 토큰 경로 | 값 | 사용처 |
|------|----------|-----|---------|
| 화면 배경 | Colors - Neutral - 50 | #F8FAFC | 전체 화면 배경 |
| AppBar 배경 | Colors - White | #FFFFFF | 상단 앱바 |
| AppBar 제목 | Typography - 2xl | 24px, Bold, Neutral-800 (#1E293B) | 화면 제목 "설정" |
| 섹션 제목 | Typography - xl | 20px, Semibold, Neutral-800 (#1E293B) | "사용자 정보", "설정" 섹션 제목 |
| 카드 배경 | Colors - White | #FFFFFF | 사용자 정보 카드 배경 |
| 카드 테두리 | Colors - Neutral - 200 | #E2E8F0, 1px | 카드 테두리 |
| 카드 그림자 | Shadow - sm | 0 2px 4px rgba(15, 23, 42, 0.06) | 카드 깊이감 |
| 카드 모서리 | Border Radius - md | 12px | 카드 border-radius |
| 카드 안쪽 여백 | Spacing - md | 16px | 카드 내부 padding |
| 데이터 레이블 | Typography - sm | 14px, Medium, Neutral-700 (#334155) | 카드 데이터 레이블 (이름, 목표 체중) |
| 데이터 값 | Typography - base | 16px, Regular, Neutral-600 (#475569) | 카드 데이터 값 |
| 메뉴 항목 제목 | Typography - base | 16px, Semibold, Neutral-800 (#1E293B) | 메뉴 항목 제목 |
| 메뉴 항목 설명 | Typography - sm | 14px, Regular, Neutral-500 (#64748B) | 메뉴 항목 설명 텍스트 |
| 메뉴 항목 구분선 | Colors - Neutral - 200 | #E2E8F0, 1px bottom | 각 메뉴 항목 하단 선 |
| 메뉴 항목 호버 배경 | Colors - Neutral - 100 | #F1F5F9 | 메뉴 항목 호버 상태 배경 |
| 메뉴 항목 활성 배경 | Colors - Primary | #4ADE80 at 10% opacity (#E8F8ED) | 메뉴 항목 활성 상태 배경 |
| Danger 버튼 배경 | Colors - Error | #EF4444 | 로그아웃 버튼 배경 |
| Danger 버튼 호버 | Colors - Error | #DC2626 | 로그아웃 버튼 호버 상태 |
| Danger 버튼 활성 | Colors - Error | #B91C1C | 로그아웃 버튼 활성 상태 |
| 버튼 텍스트 | Colors - White | #FFFFFF | 로그아웃 버튼 텍스트 |
| 버튼 높이 | Sizing - Medium | 44px | 로그아웃 버튼 높이 (터치 영역) |
| 버튼 모서리 | Border Radius - sm | 8px | 로그아웃 버튼 border-radius |
| 버튼 그림자 | Shadow - sm | 0 2px 4px rgba(15, 23, 42, 0.06) | 버튼 깊이감 |
| 아이콘 색상 | Colors - Neutral - 400 | #94A3B8 | 메뉴 chevron 아이콘 |
| 아이콘 크기 | Sizing - Icon | 20px | chevron 아이콘 크기 |
| 섹션 간 여백 | Spacing - lg | 24px | 섹션 간 위아래 여백 |
| 메인 좌우 여백 | Spacing - md | 16px | 메인 컨테이너 좌우 padding |
| 메인 상하 여백 | Spacing - xl | 32px | 메인 컨테이너 상하 padding |

---

## 3. 컴포넌트 상세 명세

### 3.1 UserInfoCard - 사용자 정보 카드 컴포넌트

**컴포넌트 타입:** Card (Display)

**시각 명세:**
- **배경:** White (#FFFFFF)
- **테두리:** Neutral-200 (#E2E8F0), 1px solid
- **모서리:** Border Radius md (12px)
- **그림자:** sm (0 2px 4px rgba(15, 23, 42, 0.06))
- **안쪽 여백:** md (16px)

**구조:**
```
UserInfoCard
├── 제목 (사용자 정보)
│   ├── 텍스트: "사용자 정보"
│   ├── 색상: Neutral-800 (#1E293B)
│   ├── 타이포그래피: Typography xl (20px, Semibold)
│   └── 하단 여백: sm (8px)
│
└── 데이터 항목들 (Column, spacing: sm)
    ├── Item 1: 이름
    │   ├── 레이블: "이름"
    │   ├── 값: userName
    │   ├── 레이블 색상: Neutral-700 (#334155)
    │   ├── 레이블 타이포그래피: Typography sm (14px, Medium)
    │   ├── 값 색상: Neutral-600 (#475569)
    │   ├── 값 타이포그래피: Typography base (16px, Regular)
    │   └── 항목 간 여백: sm (8px)
    │
    └── Item 2: 목표 체중
        ├── 레이블: "목표 체중"
        ├── 값: "${targetWeight.value}kg"
        ├── 레이블 색상: Neutral-700 (#334155)
        ├── 레이블 타이포그래피: Typography sm (14px, Medium)
        ├── 값 색상: Neutral-600 (#475569)
        └── 값 타이포그래피: Typography base (16px, Regular)
```

**인터랙티브 상태:**
- **기본 상태:** 일반 카드, 호버 상태 없음 (정보 표시만 목적)
- **시각적 깊이:** sm 그림자로 카드 강조

**접근성:**
- 카드 전체 읽기 가능 (semantic widget)
- 터치 영역 충분 (카드 전체)
- 색상 대비: WCAG AA 충족

---

### 3.2 SettingsMenuItemImproved - 개선된 설정 메뉴 항목 컴포넌트

**컴포넌트 타입:** List Item (Interactive)

**시각 명세:**
- **높이:** 44px (터치 영역)
- **좌우 패딩:** md (16px)
- **상하 패딩:** sm (8px)
- **제목 색상:** Neutral-800 (#1E293B)
- **제목 타이포그래피:** Typography base (16px, Semibold)
- **설명 색상:** Neutral-500 (#64748B)
- **설명 타이포그래피:** Typography sm (14px, Regular)
- **하단 구분선:** Neutral-200 (#E2E8F0), 1px
- **아이콘 색상:** Neutral-400 (#94A3B8)
- **아이콘 크기:** 20px (chevron_right)

**구조:**
```
SettingsMenuItemImproved (height: 44px, width: 100%)
├── Container with border-bottom
│   ├── Row (MainAxisAlignment.spaceBetween)
│   │   ├── Column (flex: 1, crossAxisAlignment.start)
│   │   │   ├── Title (Neutral-800, base 16px Semibold)
│   │   │   └── Subtitle (Neutral-500, sm 14px Regular)
│   │   │
│   │   └── Icon (chevron_right, Neutral-400, 20px)
│   │
│   └── Divider (bottom, Neutral-200 #E2E8F0, 1px)
```

**인터랙티브 상태:**
- **기본 상태:**
  - 배경: Colors.transparent
  - 텍스트: 명시된 색상

- **호버 상태:**
  - 배경: Neutral-100 (#F1F5F9)
  - 트랜지션: 150ms ease-in-out
  - 커서: pointer

- **활성 상태 (탭 후):**
  - 배경: Primary (#4ADE80) at 10% opacity, 즉 #E8F8ED
  - 트랜지션: 150ms ease-in-out
  - 지속 시간: 100ms 후 원래대로 복구

- **비활성화 상태:**
  - 불투명도: 0.4
  - 커서: not-allowed
  - 상호작용 불가

**터치 피드백:**
- InkWell 또는 GestureDetector 사용
- 탭 시 ripple effect 또는 short opacity feedback

**접근성:**
- 터치 영역 최소 44×44px 만족
- 의미론적 구조: Row, Column으로 스크린리더 호환
- 키보드 네비게이션: Tab으로 선택 가능
- WCAG AA 색상 대비 준수

---

### 3.3 DangerButton - Danger 스타일 버튼 컴포넌트

**컴포넌트 타입:** Button - Danger (Primary 변형)

**시각 명세:**
- **배경:** Error (#EF4444)
- **텍스트 색상:** White (#FFFFFF)
- **텍스트 타이포그래피:** Typography base (16px, Semibold)
- **높이:** 44px (Medium size)
- **좌우 패딩:** md (16px)
- **전체 너비:** true (100% of container)
- **모서리:** Border Radius sm (8px)
- **그림자:** sm (0 2px 4px rgba(15, 23, 42, 0.06))

**구조:**
```
DangerButton (width: double.infinity, height: 44px)
├── ElevatedButton 또는 GestureDetector + Container
│   ├── 배경: Error (#EF4444)
│   ├── 텍스트: "로그아웃"
│   ├── 텍스트 색상: White (#FFFFFF)
│   ├── 텍스트 스타일: base 16px Semibold
│   ├── 패딩: 16px horizontal, 8px vertical
│   ├── 모서리: 8px border-radius
│   └── 그림자: sm shadow
```

**인터랙티브 상태:**
- **기본 상태:**
  - 배경: Error (#EF4444)
  - 그림자: sm
  - 스케일: 1.0

- **호버 상태:**
  - 배경: Error (#DC2626) (더 진한 error 색)
  - 그림자: md (더 깊은 그림자)
  - 스케일: 1.0 (호버 scale 효과 없음)
  - 트랜지션: 150ms ease-in-out

- **활성/눌린 상태:**
  - 배경: Error (#B91C1C) (가장 진한 error 색)
  - 그림자: xs (가장 얕은 그림자)
  - 스케일: 0.98 (약간 눌린 듯한 효과)
  - 트랜지션: 100ms ease-in-out

- **비활성화 상태:**
  - 배경: Error (#EF4444) at 40% opacity
  - 커서: not-allowed
  - 상호작용 불가
  - 텍스트 색상: White at 60% opacity

**로딩 상태:**
- 로그아웃 처리 중일 때
  - 버튼 비활성화 (disabled: true)
  - 텍스트 대신 CircularProgressIndicator (흰색, 크기: 20px)
  - 버튼 크기 유지

**터치 피드백:**
- InkWell 또는 GestureDetector 사용
- 탭 시 명확한 피드백 (색상 변화 + 그림자 변화)
- 애니메이션 지속 시간: 100-150ms

**접근성:**
- 터치 영역: 44×44px 이상 (버튼 높이 44px, 전체 너비)
- 색상 대비: Error #EF4444 on White #FFFFFF = 3.99:1 (WCAG AA 충족)
- Semantic: ElevatedButton 또는 Button 위젯 사용
- ARIA/키보드: Tab으로 선택, Enter/Space로 활성화 가능

---

## 4. 레이아웃 상세 명세

**전체 구조:**

```
SettingsScreen (ConsumerWidget)
│
├── Scaffold
│   ├── AppBar
│   │   ├── 배경: White (#FFFFFF)
│   │   ├── 제목: "설정"
│   │   ├── 제목 스타일: Typography 2xl (24px, Bold, Neutral-800)
│   │   ├── Elevation: 0
│   │   └── 그림자: sm (0 2px 4px rgba(15, 23, 42, 0.06))
│   │
│   └── Body: ListView (스크롤 가능)
│       ├── SafeArea consideration
│       ├── 배경: Neutral-50 (#F8FAFC)
│       └── 컨텐츠:
│           │
│           ├── [사용자 정보 섹션]
│           │   ├── 상단 여백: xl (32px)
│           │   ├── 좌우 여백: md (16px)
│           │   ├── 섹션 제목: "사용자 정보" (없어도 됨 - 카드 내부에 있음)
│           │   ├── 하단 여백: md (16px)
│           │   └── UserInfoCard 컴포넌트
│           │       └── 하단 여백: lg (24px)
│           │
│           ├── [설정 메뉴 섹션]
│           │   ├── 좌우 여백: md (16px)
│           │   ├── 섹션 제목: "설정"
│           │   │   ├── 타이포그래피: Typography xl (20px, Semibold, Neutral-800)
│           │   │   └── 하단 여백: md (16px)
│           │   │
│           │   ├── SettingsMenuItemImproved x 5
│           │   │   ├── Item 1: 프로필 및 목표 수정
│           │   │   ├── Item 2: 투여 계획 수정
│           │   │   ├── Item 3: 주간 기록 목표 조정
│           │   │   ├── Item 4: 푸시 알림 설정
│           │   │   └── Item 5: 기록 관리
│           │   │
│           │   └── 하단 여백: lg (24px)
│           │
│           ├── [구분선 - 선택사항]
│           │   ├── 높이: 1px
│           │   ├── 색상: Neutral-200 (#E2E8F0)
│           │   └── 하단 여백: lg (24px)
│           │
│           ├── [로그아웃 버튼 섹션]
│           │   ├── 좌우 여백: md (16px)
│           │   ├── DangerButton 컴포넌트
│           │   │   ├── 텍스트: "로그아웃"
│           │   │   └── onTap: _handleLogout() 함수 호출
│           │   │
│           │   └── 하단 여백: xl (32px)
```

**여백 규칙:**
- 상단 AppBar: 직접 attached (elevation 0)
- Body 전체 배경: Neutral-50 (#F8FAFC)
- 각 섹션 좌우: md (16px) padding
- 섹션 간: lg (24px) gap
- 메인 상하: xl (32px) padding

**반응형:**
- 모바일 (< 768px): 위 레이아웃 그대로 사용
- 태블릿 (768px - 1024px): 좌우 여백 증가 가능 (md 유지 또는 lg로 조정)
- 데스크톱 (> 1024px): 최대 너비 제약 가능, 중앙 정렬

---

## 5. 인터랙션 명세

### 5.1 메뉴 항목 클릭

**트리거:** SettingsMenuItemImproved 탭/클릭

**시각 피드백:**
1. 호버 상태: 배경 Neutral-100 (#F1F5F9) + 150ms 트랜지션
2. 활성 상태: 배경 Primary #4ADE80 at 10% + 150ms 트랜지션
3. 복구: 100ms 후 자동으로 기본 상태로 복구

**동작:**
- 각 메뉴 항목의 onTap 콜백 실행
- GoRouter를 통해 해당 화면으로 네비게이션
  - 프로필 및 목표 수정: context.push('/profile/edit')
  - 투여 계획 수정: context.push('/dose-plan/edit')
  - 주간 기록 목표 조정: context.push('/weekly-goal/edit')
  - 푸시 알림 설정: context.push('/notification/settings')
  - 기록 관리: context.push('/records')

**네비게이션 애니메이션:**
- 기본 GoRouter 전환 애니메이션 사용
- 지속 시간: 300ms (일반적인 Material 애니메이션)

### 5.2 로그아웃 버튼 클릭

**트리거:** DangerButton 탭/클릭

**시각 피드백:**
1. 호버 상태: 배경 Error #DC2626 + md 그림자 + 150ms 트랜지션
2. 활성 상태: 배경 Error #B91C1C + xs 그림자 + 0.98 스케일 + 100ms 트랜지션
3. 복구: 즉시 기본 상태로 복구

**동작:**
1. _handleLogout() 함수 호출
2. LogoutConfirmDialog 표시 (기존 로직 유지)
3. 사용자가 확인하면 _performLogout() 실행
4. 로그아웃 진행 중: 로딩 다이얼로그 표시 (기존 로직 유지)
5. 완료 후: 로그인 화면으로 네비게이션 (context.go('/login'))

**로딩 상태:**
- 로그아웃 처리 중 버튼은 비활성화
- 버튼 텍스트 대신 CircularProgressIndicator 표시
- 사용자가 버튼 다시 클릭 불가

### 5.3 화면 로드

**초기 로딩:**
1. authNotifierProvider 상태 확인
2. 사용자 미인증: 로그인 화면으로 리다이렉트
3. 인증됨: profileNotifierProvider 로드
4. 프로필 로드 중: 중앙에 CircularProgressIndicator 표시
5. 프로필 로드 완료: UI 렌더링

**에러 처리:**
- 세션 만료: 로그인 화면으로 자동 리다이렉트
- 네트워크 에러: 에러 메시지 + 재시도 버튼 표시 (기존 로직 유지)

---

## 6. 파일 생성/수정 상세 가이드

### 6.1 새로 생성할 파일

#### 파일 1: `lib/features/settings/presentation/widgets/user_info_card.dart`

```dart
import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final String userName;
  final double targetWeight;

  const UserInfoCard({
    required this.userName,
    required this.targetWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // White
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0), // md (12px)
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06), // sm shadow
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0), // md (16px)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            '사용자 정보',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1E293B), // Neutral-800
              fontSize: 20.0, // xl
              fontWeight: FontWeight.w600, // Semibold
            ),
          ),
          const SizedBox(height: 8.0), // sm spacing after title

          // Data item 1: Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이름',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF334155), // Neutral-700
                  fontSize: 14.0, // sm
                  fontWeight: FontWeight.w500, // Medium
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569), // Neutral-600
                  fontSize: 16.0, // base
                  fontWeight: FontWeight.w400, // Regular
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0), // sm spacing between items

          // Data item 2: Target weight
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '목표 체중',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF334155), // Neutral-700
                  fontSize: 14.0, // sm
                  fontWeight: FontWeight.w500, // Medium
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${targetWeight.toStringAsFixed(1)}kg',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569), // Neutral-600
                  fontSize: 16.0, // base
                  fontWeight: FontWeight.w400, // Regular
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### 파일 2: `lib/features/settings/presentation/widgets/settings_menu_item_improved.dart`

```dart
import 'package:flutter/material.dart';

class SettingsMenuItemImproved extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const SettingsMenuItemImproved({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  @override
  State<SettingsMenuItemImproved> createState() =>
      _SettingsMenuItemImprovedState();
}

class _SettingsMenuItemImprovedState extends State<SettingsMenuItemImproved>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _bgColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: const Color(0xFFF1F5F9), // Neutral-100
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: Container(
          height: 44.0, // Touch area height
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0, // md
            vertical: 8.0, // sm
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE2E8F0), // Neutral-200
                width: 1.0,
              ),
            ),
          ),
          child: AnimatedBuilder(
            animation: _bgColorAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: _bgColorAnimation.value,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: widget.enabled
                              ? const Color(0xFF1E293B) // Neutral-800
                              : const Color(0xFF1E293B).withOpacity(0.4),
                          fontSize: 16.0, // base
                          fontWeight: FontWeight.w600, // Semibold
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.enabled
                              ? const Color(0xFF64748B) // Neutral-500
                              : const Color(0xFF64748B).withOpacity(0.4),
                          fontSize: 14.0, // sm
                          fontWeight: FontWeight.w400, // Regular
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),

                // Trailing chevron icon
                Icon(
                  Icons.chevron_right,
                  size: 20.0, // Icon size
                  color: widget.enabled
                      ? const Color(0xFF94A3B8) // Neutral-400
                      : const Color(0xFF94A3B8).withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 파일 3: `lib/features/settings/presentation/widgets/danger_button.dart`

```dart
import 'package:flutter/material.dart';

class DangerButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const DangerButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _bgColorAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _bgColorAnimation = ColorTween(
      begin: const Color(0xFFEF4444), // Error
      end: const Color(0xFFDC2626), // Error darker (hover)
    ).animate(_controller);

    _elevationAnimation = Tween<double>(
      begin: 2.0, // sm shadow elevation
      end: 4.0, // md shadow elevation
    ).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.isLoading;

    return GestureDetector(
      onTap: (!isDisabled) ? widget.onPressed : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        cursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            Color bgColor;
            double elevation;

            if (_isPressed && !isDisabled) {
              // Active state
              bgColor = const Color(0xFFB91C1C); // Error darkest
              elevation = 1.0; // xs shadow
            } else if (_controller.value > 0 && !isDisabled) {
              // Hover state (interpolated)
              bgColor = Color.lerp(
                const Color(0xFFEF4444),
                const Color(0xFFDC2626),
                _controller.value,
              )!;
              elevation = 2.0 + (2.0 * _controller.value);
            } else {
              // Default state
              bgColor = const Color(0xFFEF4444); // Error
              elevation = 2.0; // sm shadow
            }

            if (isDisabled) {
              bgColor = const Color(0xFFEF4444).withOpacity(0.4);
            }

            return Container(
              width: double.infinity,
              height: 44.0, // Medium button height
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8.0), // sm border-radius
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.06),
                    blurRadius: elevation * 2,
                    offset: Offset(0, elevation),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: null, // Already handled by GestureDetector
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(
                            isDisabled ? 0.6 : 1.0,
                          ),
                        ),
                        strokeWidth: 2.0,
                      ),
                    )
                        : Text(
                      widget.text,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        color: Colors.white.withOpacity(
                          isDisabled ? 0.6 : 1.0,
                        ),
                        fontSize: 16.0, // base
                        fontWeight: FontWeight.w600, // Semibold
                      ),
                    ),
                  ),
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

### 6.2 수정할 기존 파일

#### 파일 수정 1: `lib/features/settings/presentation/screens/settings_screen.dart`

**변경 요약:**
1. 새로운 컴포넌트 import 추가
2. 배경색을 Neutral-50으로 변경
3. AppBar 스타일 업데이트
4. UserInfoCard 컴포넌트 사용
5. SettingsMenuItemImproved로 메뉴 항목 개선
6. DangerButton으로 로그아웃 버튼 변경
7. 섹션 레이아웃 및 여백 조정

**상세 수정 사항:**

1. **Import 추가** (파일 최상단):
```dart
import 'package:n06/features/settings/presentation/widgets/user_info_card.dart';
import 'package:n06/features/settings/presentation/widgets/settings_menu_item_improved.dart';
import 'package:n06/features/settings/presentation/widgets/danger_button.dart';
```

2. **Scaffold body 변경** (_buildSettings 메서드 내):

기존 코드:
```dart
return ListView(
  children: [
    // User information section
    Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사용자 정보',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('이름'),
            subtitle: Text(userName),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: const Text('목표 체중'),
            subtitle: Text('${profile.targetWeight.value}kg'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),
    // ... 나머지 코드
  ],
);
```

새로운 코드:
```dart
return ListView(
  color: const Color(0xFFF8FAFC), // Neutral-50 배경
  padding: const EdgeInsets.symmetric(
    horizontal: 16.0, // md
    vertical: 32.0, // xl
  ),
  children: [
    // User information section
    UserInfoCard(
      userName: userName,
      targetWeight: profile.targetWeight.value,
    ),
    const SizedBox(height: 24.0), // lg spacing

    // Settings menu section
    Text(
      '설정',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: const Color(0xFF1E293B), // Neutral-800
        fontSize: 20.0, // xl
        fontWeight: FontWeight.w600, // Semibold
      ),
    ),
    const SizedBox(height: 16.0), // md spacing

    // Menu items
    SettingsMenuItemImproved(
      title: '프로필 및 목표 수정',
      subtitle: '이름과 목표 체중을 변경할 수 있습니다',
      onTap: () => context.push('/profile/edit'),
    ),
    SettingsMenuItemImproved(
      title: '투여 계획 수정',
      subtitle: '약물 투여 계획을 변경할 수 있습니다',
      onTap: () => context.push('/dose-plan/edit'),
    ),
    SettingsMenuItemImproved(
      title: '주간 기록 목표 조정',
      subtitle: '주간 체중 및 증상 기록 목표를 설정합니다',
      onTap: () => context.push('/weekly-goal/edit'),
    ),
    SettingsMenuItemImproved(
      title: '푸시 알림 설정',
      subtitle: '알림 시간과 방식을 설정합니다',
      onTap: () => context.push('/notification/settings'),
    ),
    SettingsMenuItemImproved(
      title: '기록 관리',
      subtitle: '저장된 기록을 확인하거나 삭제할 수 있습니다',
      onTap: () => context.push('/records'),
    ),
    const SizedBox(height: 24.0), // lg spacing after menu items

    // Logout section
    DangerButton(
      text: '로그아웃',
      onPressed: () => _handleLogout(context, ref),
    ),
    const SizedBox(height: 32.0), // xl spacing at bottom
  ],
);
```

3. **AppBar 스타일 업데이트** (두 곳 모두):

기존 코드:
```dart
appBar: AppBar(
  title: const Text('설정'),
  elevation: 0,
),
```

새로운 코드:
```dart
appBar: AppBar(
  title: const Text('설정'),
  elevation: 0,
  backgroundColor: const Color(0xFFFFFFFF), // White
  surfaceTintColor: Colors.transparent,
  shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
  titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
    color: const Color(0xFF1E293B), // Neutral-800
    fontSize: 24.0, // 2xl
    fontWeight: FontWeight.bold,
  ),
),
```

#### 파일 수정 2: `lib/features/settings/presentation/widgets/settings_menu_item.dart`

**선택사항:** 기존 SettingsMenuItem을 유지하거나 deprecated 처리 가능
- 다른 화면에서 사용하지 않으면 삭제 가능
- 사용 중이면 SettingsMenuItemImproved로 마이그레이션 필요

현재 상황: settings_screen.dart에서만 사용되므로 **삭제 가능**

---

## 7. 구현 체크리스트

구현 전 검증:
- [ ] 모든 Design System 토큰 값이 정확함
- [ ] 컴포넌트 파일 생성 경로 확인
- [ ] 기존 파일 수정 사항 검토
- [ ] 모든 import 문 확인
- [ ] 색상 코드 16진수 정확성 확인

구현 중:
- [ ] UserInfoCard 컴포넌트 작성 및 테스트
- [ ] SettingsMenuItemImproved 컴포넌트 작성 및 테스트
- [ ] DangerButton 컴포넌트 작성 및 테스트
- [ ] SettingsScreen 수정 및 UI 확인
- [ ] 모든 상호작용(호버, 클릭, 로딩) 테스트

구현 후 검증:
- [ ] flutter analyze 통과 (경고 없음)
- [ ] flutter format 적용
- [ ] 모든 Device 크기에서 렌더링 테스트
- [ ] 터치 영역 44×44px 확인
- [ ] 색상 대비 WCAG AA 준수 확인
- [ ] 네비게이션 정상 작동
- [ ] 로그아웃 다이얼로그 정상 작동
- [ ] 로딩 상태 정상 작동

---

## 8. 테스트 체크리스트

**시각적 테스트:**
- [ ] UserInfoCard 시각적 일치 확인
  - 배경색, 테두리, 그림자, 모서리
  - 텍스트 색상, 크기, 굵기
  - 여백 정확성

- [ ] SettingsMenuItemImproved 시각적 일치 확인
  - 높이 44px, 터치 영역 확인
  - 호버 상태 배경색 변화
  - 구분선 정확성
  - 아이콘 위치 및 색상

- [ ] DangerButton 시각적 일치 확인
  - 배경색 (Error #EF4444)
  - 호버 상태 색상 변화
  - 활성 상태 색상 변화 및 스케일
  - 그림자 변화
  - 로딩 상태 CircularProgressIndicator

**인터랙션 테스트:**
- [ ] 메뉴 항목 클릭 시 해당 화면으로 네비게이션
- [ ] 로그아웃 버튼 클릭 시 확인 다이얼로그 표시
- [ ] 로그아웃 확인 후 로그인 화면으로 네비게이션
- [ ] 로그아웃 중 로딩 상태 표시
- [ ] 로그아웃 에러 시 에러 메시지 표시

**접근성 테스트:**
- [ ] 모든 요소가 키보드로 네비게이션 가능
- [ ] 색상 대비 WCAG AA 충족
- [ ] 터치 영역 최소 44×44px 확인

---

## 9. 파일 생성/수정 요약

**새로 생성할 파일 (3개):**
1. `lib/features/settings/presentation/widgets/user_info_card.dart`
2. `lib/features/settings/presentation/widgets/settings_menu_item_improved.dart`
3. `lib/features/settings/presentation/widgets/danger_button.dart`

**수정할 파일 (1개):**
1. `lib/features/settings/presentation/screens/settings_screen.dart`

**선택적 삭제 파일 (1개):**
1. `lib/features/settings/presentation/widgets/settings_menu_item.dart` (다른 곳에서 미사용 시)

---

## 10. 주요 주의사항

1. **Color 생성자:** Flutter에서는 `Color(0xFFRRGGBB)` 형식 사용 (0xFF는 알파값 100%)
2. **텍스트 스타일:** Theme.of(context).textTheme을 기반으로 커스터마이징
3. **애니메이션:** 150ms (호버), 100ms (활성) 지속 시간 엄격히 적용
4. **그림자 값:** Material Design의 elevation 시스템이 아닌 BoxShadow 직접 지정
5. **반응형:** 현재 설정은 모바일 중심, 태블릿/데스크톱은 향후 조정
6. **Riverpod 호환성:** 기존 authNotifierProvider, profileNotifierProvider 그대로 사용
7. **라우팅:** GoRouter context.push(), context.go() 그대로 사용
8. **Safe Area:** Scaffold가 자동으로 처리, 추가 설정 불필요

---

## 11. 완성 후 다음 단계

1. **Phase 2B 완료:** 이 구현 가이드 승인
2. **Phase 2C:** 자동 코드 생성 및 파일 수정 (사용자 또는 에이전트)
3. **Phase 3:** 검증 및 Component Registry 업데이트
4. **배포:** 머지 및 프로덕션 배포

---

**문서 끝**

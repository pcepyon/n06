# UI Renewal Projects Index

## Completed Projects

### onboarding-screen
- **Status**: Completed
- **Date**: 2025-11-23
- **Framework**: Flutter
- **Files Modified**: 5
- **Components Created**: 2 (ValidationAlert, SummaryCard)
- **Design System**: Gabium v1.0
- **Documents**:
  - Proposal: 20251123-proposal-v1.md
  - Implementation: 20251123-implementation-v1.md
  - Implementation Log: 20251123-implementation-log-v1.md
  - Verification: 20251123-verification-v1.md

### coping-guide-screen
- **Status**: Completed
- **Date**: 2025-11-23
- **Framework**: Flutter
- **Files Modified**: 7
- **Components Created**: 1 (CopingGuideFeedbackResult)
- **Components Reused**: 2 (ValidationAlert, GabiumButton)
- **Design System**: Gabium v1.0
- **Library Status**: Component added to library
- **Documents**:
  - Proposal: 20251123-proposal-v1.md
  - Implementation: 20251123-implementation-v1.md
  - Implementation Log: 20251123-implementation-log-v1.md

### detailed-guide-screen
- **Status**: Completed
- **Date**: 2025-11-23
- **Framework**: Flutter
- **Files Modified**: 1
- **Design System**: Gabium v1.0
- **Screen Path**: lib/features/coping_guide/presentation/screens/detailed_guide_screen.dart
- **Documents**:
  - Proposal: 20251123-proposal-v1.md
  - Implementation: 20251123-implementation-v1.md
  - Implementation Log: 20251123-implementation-log-v1.md
- **Notes**: Screen-specific implementation, no reusable components extracted

### notification-settings-screen
- **Status**: Completed
- **Date**: 2025-11-23
- **Framework**: Flutter
- **Files Modified**: 2
- **Design System**: Gabium v1.0
- **Description**: 알림 설정 화면 개선 - Design System 토큰 적용, 카드 높이감 조정, 정보 박스 시각화, 시각적 계층 강화
- **Documents**:
  - Proposal: 20251123-proposal-v1.md
  - Implementation: 20251123-implementation-v1.md
  - Implementation Log: 20251123-implementation-log-v1.md
- **Key Changes**:
  - 하드코딩된 Info 색상을 Design System Info 토큰으로 통일
  - 정보 메시지 박스를 Alert Banner 패턴으로 구조화
  - 알림 활성화 카드 shadow 강화 (md)
  - 알림 시간 제목 타이포그래피 표준화 (xl, Semibold)
  - TimePickerButton을 Secondary 버튼 스타일로 개선
  - 섹션 간 spacing 조정 (lg - 24px)
  - 페이지 배경색 명시적 정의 (Neutral-50)
- **Library Status**: Component Registry 업데이트 필요 없음 (신규 컴포넌트 미생성)
- **Notes**: 기존 Material 위젯의 Design System 토큰 적용 및 스타일 개선, 새로운 컴포넌트 미추출

### settings-main-screen
- **Status**: Completed
- **Date**: 2025-11-23
- **Framework**: Flutter
- **Files Modified**: 1
- **Files Created**: 3
- **Components Created**: 3 (UserInfoCard, SettingsMenuItemImproved, DangerButton)
- **Design System**: Gabium v1.0
- **Description**: Settings Main Screen redesign - Card-based user info, enhanced menu items, Danger-styled logout button
- **Documents**:
  - Proposal: 20251123-proposal-v1.md
  - Implementation: 20251123-implementation-v1.md
  - Implementation Log: 20251123-implementation-log-v1.md
- **Library Status**: ✅ 3 components added to registry
- **Key Changes**:
  - 사용자 정보 섹션을 카드 기반 디자인으로 강화
  - 설정 메뉴 항목 스타일 개선 (터치 영역, 구분선, 호버 상태)
  - 로그아웃 버튼을 Danger 스타일로 구분
  - 섹션 간 시각적 계층 강화
  - Design System 토큰 100% 적용

### weekly-goal-settings-screen
- **Status**: Completed
- **Date**: 2025-11-23
- **Framework**: Flutter
- **Files Modified**: 1
- **Components Created**: 0
- **Design System**: Gabium v1.0
- **Description**: 주간 기록 목표 조정 화면 개선 - Design System 토큰 적용, 카드 스타일 통일, 타이포그래피 정규화
- **Documents**:
  - Proposal: 20251123-proposal-v1.md
  - Implementation: 20251123-implementation-v1.md
  - Implementation Log: 20251123-implementation-log-v1.md
- **Key Changes**:
  - 정보 박스 색상 표준화 (Colors.blue[50/200] → Design System tokens)
  - 섹션 제목 타이포그래피 정규화 (xl - 20px, Semibold)
  - 투여 목표 박스 스타일 개선 (Card pattern + subtle shadow)
  - 저장 버튼 스타일 표준화 (Primary variant)
  - 입력 필드 스타일 정규화 (Design System 토큰)
  - 다이얼로그/토스트 컴포넌트 표준화
- **Library Status**: Component Registry 업데이트 필요 없음 (신규 컴포넌트 미생성)
- **Notes**: 기존 Material 위젯의 Design System 토큰 적용 및 스타일 개선

## Pending

# GLP-1 치료 관리 MVP (Phase 0)

GLP-1 사용자의 복잡한 개인별 투여 스케줄을 자동 관리하고, 주요 증상 및 체중 변화를 기록하며, 데이터 기반 보고서를 자동 생성하는 Flutter 기반 건강관리 애플리케이션입니다.

## 🎯 핵심 가치

| 항목 | 내용 |
| :--- | :--- |
| **안전성** | 투여 스케줄 관리, 응급 증상 체크리스트 |
| **효율성** | 데이터 기반 치료 관리, 의료진과의 데이터 공유 |
| **동기 부여** | 성취감, 개인화 인사, 뱃지, 진행도 대시보드 |

## 🚀 핵심 기능 (Features)

### F000: 온보딩 & 목표 설정
- 초기 사용자 프로필 설정
- GLP-1 투여 계획 및 치료 목표 설정

### F001: 투여 스케줄러
- 개인별 투여 스케줄 자동 관리
- 투여 완료 기록
- 주사 부위 순환 관리

### F002: 체중/증상 기록
- 체중 변화 추적
- 부작용 및 증상 기록
- 기록 이력 관리

### F003: 데이터 공유 모드
- 읽기 전용 요약 리포트
- 의료진과의 안전한 데이터 공유

### F004: 부작용 대처 가이드
- 증상별 맞춤 대처 방법 제시
- 전문가 조언 기반 가이드

### F005: 증상 체크
- 심각한 증상 체크리스트
- 전문가 상담 필요성 판단
- 응급 상황 안내

### F006: 홈 대시보드 (동기 부여 중심)
- 치료 진행 상황 요약
- 개인화 인사말 및 뱃지
- 주간 진행도 및 타임라인
- 퀵 액션: 체중, 증상, 투여 기록

## 🏗️ 기술 스택

- **Frontend**: Flutter
- **Local Database**: Isar
- **Backend**: Supabase (Phase 1+)
- **Architecture**: Repository Pattern
- **State Management**: Riverpod

## 📁 프로젝트 구조

```
lib/
├── features/
│   ├── authentication/
│   ├── medication_scheduler/
│   ├── health_record/
│   ├── symptom_check/
│   ├── data_sharing/
│   ├── home/
│   └── settings/
├── core/
│   ├── constants/
│   └── theme/
└── main.dart
```

## 📋 사용자 여정 (User Scenarios)

| 시나리오 | 타겟 | 여정 | 기능 |
| :--- | :--- | :--- | :--- |
| **SC0. 치료 시작** | 신규 사용자 | 로그인 → 온보딩 → 홈 | F001, F000 |
| **SC1. 일상 투여 & 기록** | 활성 사용자 | 알림 → 투여 기록 → 증상 기록 → 가이드 | F001, F002, F004 |
| **SC2. 전문가 상담** | 정기 상담 사용자 | 홈 → 데이터 공유 모드 진입 | F003 |
| **SC3. 응급 증상** | 위기 사용자 | 홈 → 증상 체크 → 전문가 상담 안내 | F005 |
| **SC4. 동기 부여** | 꾸준한 사용자 | 홈 대시보드 → 성취감/뱃지 확인 | F006 |

## 🔄 개발 가이드

### 의존성 규칙 (Non-negotiable)
```
Presentation → Application → Domain ← Infrastructure
```

### Repository Pattern
```
Application/Presentation → Repository Interface (Domain)
                        → Repository Implementation (Infrastructure)
```

### 코드 배치 규칙
```dart
// UI 렌더링 → Presentation Layer
features/{feature}/presentation/screens/

// 상태 관리 & UseCase → Application Layer
features/{feature}/application/notifiers/

// 비즈니스 로직 & 데이터 모델 → Domain Layer
features/{feature}/domain/entities/
features/{feature}/domain/repositories/

// DB 접근 & DTO 변환 → Infrastructure Layer
features/{feature}/infrastructure/repositories/
features/{feature}/infrastructure/dtos/
```

## ✅ 개발 전 필수 확인

- [ ] `flutter test` 모든 테스트 통과
- [ ] `flutter analyze` 경고 없음
- [ ] TDD 사이클 완료 (test first, code second)
- [ ] Repository Pattern 유지
- [ ] 레이어 간 의존성 위반 없음
- [ ] 성능 제약 조건 충족

## 📚 추가 문서

- [Architecture Guide](docs/code_structure.md)
- [State Management](docs/state-management.md)
- [Database Schema](docs/database.md)
- [Testing Guide](docs/tdd.md)
- [Tech Stack Details](docs/techstack.md)
- [Product Requirements](docs/prd.md)

## 🚀 Getting Started

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, Freezed 등)
flutter pub run build_runner build

# 앱 실행
flutter run

# 테스트 실행
flutter test

# 분석 (경고 확인)
flutter analyze
```

## 📞 문의 및 피드백

이 프로젝트는 GLP-1 치료 사용자의 안전하고 효율적인 치료 관리를 목표로 개발되고 있습니다.
피드백이나 질문은 이슈 트래커를 통해 등록해주세요.

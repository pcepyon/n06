# Gabium Brand Assets

**Version:** 1.0
**Last Updated:** 2025-11-22
**Project:** GLP-1 MVP (Gabium)

---

## 📁 디렉토리 구조

```
assets/
├── README.md                          (이 문서)
├── logo-guidelines.md                 (로고 사용 가이드라인)
├── logo-implementation-guide.md       (Flutter 구현 가이드)
│
└── logos/
    ├── gabium-logo-primary.png        (기본 로고)
    ├── gabium-logo-1024.png           (앱 아이콘용)
    ├── gabium-logo-512.png            (스플래시 스크린용)
    ├── gabium-logo-192.png            (UI 요소용)
    ├── gabium-logo-transparent.png    (투명 배경)
    ├── gabium-logo-white-bg.png       (흰 배경)
    └── gabium-logo-dark-mode.png      (다크모드용)
```

---

## 🎨 로고 개요

### 가비움 로고
- **타입**: 3D Soft Cube Icon
- **스타일**: 둥근 모서리 큐브, 광택 그라데이션, 토스 스타일 입체감
- **색상**: 에메랄드 그린 그라데이션 (베이스: #4ADE80)
- **포맷**: PNG, 정사각형 (1:1)

### 로고 의미
- **부드러운 큐브**: 안정감 + 친근함
- **광택 표면**: 희망, 긍정적 미래
- **녹색 그라데이션**: 건강, 성장, 치료 여정
- **3D 입체감**: 새로운 차원의 건강 관리

---

## 📖 문서 가이드

### 1. logo-guidelines.md
**대상**: 디자이너, 마케터, 브랜드 관리자

**내용**:
- 로고 변형 (Variants)
- 사용 위치 및 금지 사항
- 크기 및 여백 규정
- 배경 규정
- 색상 스펙
- 플랫폼별 가이드 (iOS, Android, Web)
- 애니메이션 가이드라인
- 파일 관리 및 버전 관리

**언제 읽어야 하는가**:
- 로고를 새로운 곳에 적용하기 전
- 마케팅 자료 제작 시
- 브랜드 일관성 확인 시

### 2. logo-implementation-guide.md
**대상**: Flutter 개발자

**내용**:
- Flutter 프로젝트 통합 방법
- `GabiumLogo` 위젯 전체 코드
- 스플래시 스크린, 앱바, 로딩 인디케이터 구현 예시
- 앱 아이콘 설정 (iOS/Android)
- 디자인 시스템 토큰 연동
- 고급 활용 (다크모드, 히어로 애니메이션)

**언제 읽어야 하는가**:
- 로고를 앱에 처음 추가할 때
- 새로운 화면에 로고를 배치할 때
- 로딩/애니메이션 구현 시

---

## 🚀 빠른 시작

### 디자이너/마케터인 경우:
1. `logo-guidelines.md` 읽기
2. `logos/` 폴더에서 필요한 로고 파일 다운로드
3. 사용 가이드라인 준수하며 디자인 작업

### Flutter 개발자인 경우:
1. `logo-implementation-guide.md` 읽기
2. 로고 파일을 `assets/logos/` 에 복사
3. `pubspec.yaml` 업데이트
4. `GabiumLogo` 위젯 코드 복사
5. 필요한 화면에 적용

---

## 📋 로고 파일 다운로드

### 현재 사용 가능한 파일

| 파일명 | 크기 | 용도 |
|--------|------|------|
| `gabium-logo-primary.png` | 원본 | 기본 로고 |
| `gabium-logo-1024.png` | 1024x1024 | iOS/Android 앱 아이콘 |
| `gabium-logo-512.png` | 512x512 | 스플래시 스크린, 웹 |
| `gabium-logo-192.png` | 192x192 | 네비게이션 바, UI 요소 |

### 추가 생성 필요 (선택)

- [ ] `gabium-logo-transparent.png` - 투명 배경 버전
- [ ] `gabium-logo-white-bg.png` - 흰 배경 버전
- [ ] `gabium-logo-dark-mode.png` - 다크모드용 (하이라이트 강화)
- [ ] `favicon.ico` - 웹용 파비콘 (16x16, 32x32)

---

## 🔗 관련 문서

### Design System
- **Main**: `.claude/skills/ui-renewal/design-systems/gabium-design-system.md`
- **Section 2**: Logo & Brand Mark

### Component Library
- **Docs**: `.claude/skills/ui-renewal/component-library/COMPONENTS.md`
- **Flutter**: `lib/core/presentation/widgets/gabium_logo.dart`

### Project Files
- **Requirements**: `docs/requirements.md`
- **PRD**: `docs/prd.md`

---

## ✅ 로고 사용 체크리스트

로고를 새로운 곳에 적용하기 전:

- [ ] `logo-guidelines.md`를 읽었는가?
- [ ] 최소 크기(32px) 이상인가?
- [ ] 25% 여백이 확보되었는가?
- [ ] 배경색이 적합한가?
- [ ] 비율이 왜곡되지 않았는가?
- [ ] 금지 사항을 위반하지 않았는가?
- [ ] 다크모드에서도 확인했는가?

---

## 🎯 ui-renewal Skill과의 연동

### Phase 2A (Analysis & Direction)
- **로고 재사용 권장**: 새로운 화면 디자인 시 이 로고를 일관되게 사용
- **Component Registry 확인**: `GabiumLogo` 컴포넌트가 이미 등록되어 있음

### Phase 2B (Implementation)
- **로고 컴포넌트 활용**: `GabiumLogo` 위젯을 import하여 사용
- **디자인 시스템 토큰**: 로고 색상(#4ADE80)과 조화로운 UI 요소 설계

### Phase 3 (Verification)
- **로고 사용 검증**:
  - 크기 및 여백 규정 준수 확인
  - 배경 대비 적절성 확인
  - 애니메이션 성능 확인

---

## 📞 문의 및 업데이트

### 새로운 로고 변형 요청
1. `logo-guidelines.md`에서 현재 변형 확인
2. 필요한 변형이 없다면 요청 사항 정리:
   - 용도 (예: 소셜 미디어 프로필)
   - 크기 (예: 400x400px)
   - 배경 (투명/단색)
   - 특수 요구사항

### 로고 업데이트 시
1. 새 버전을 `logos/v2/` 디렉토리에 저장
2. `logo-guidelines.md` 업데이트
3. `gabium-design-system.md` Section 2 업데이트
4. 변경 이력을 `CHANGELOG.md`에 기록

---

## 📊 버전 히스토리

### v1.0 (2025-11-22)
- **초기 로고 확정**: 3D Soft Cube 디자인
- **기본 변형 생성**: 1024px, 512px, 192px
- **가이드라인 문서 작성**: 사용 규정, 구현 가이드
- **Design System 통합**: Section 2 추가
- **Flutter 위젯 생성**: `GabiumLogo` 컴포넌트

---

**가비움 브랜드를 일관되게 유지하기 위해 이 가이드를 준수해주세요!**

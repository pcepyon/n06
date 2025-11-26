# Implementation Guide Creator - Claude Code Skill

외부 서비스, 라이브러리, 프레임워크를 위한 집중된 컨텍스트 기반 구현 가이드를 생성하는 스킬입니다.

## 설치 방법

### 방법 1: 전역 스킬로 설치 (권장 - 모든 프로젝트에서 사용)

```bash
# 스킬 디렉토리 생성
mkdir -p ~/.claude/skills

# 스킬 폴더 복사
cp -r implementation-guide-creator ~/.claude/skills/

# 설치 확인
ls ~/.claude/skills/implementation-guide-creator/
```

### 방법 2: 프로젝트별 스킬로 설치

```bash
# 프로젝트 루트로 이동
cd /path/to/your/project

# 스킬 디렉토리 생성
mkdir -p .claude/skills

# 스킬 폴더 복사
cp -r implementation-guide-creator .claude/skills/

# 설치 확인
ls .claude/skills/implementation-guide-creator/
```

## 사용 방법

### Claude Code에서 자동 활성화

스킬이 설치되면 Claude Code가 자동으로 인식합니다. 다음과 같은 요청을 하면 자동으로 이 스킬이 활성화됩니다:

```
"Kakao 로그인을 Next.js에 통합하는 구현 가이드를 만들어줘"
"Supabase Auth 구현 가이드 생성해줘"
"Stripe 결제 연동 가이드 만들어줘"
```

### 스크립트 직접 실행

```bash
# 구현 분석
python ~/.claude/skills/implementation-guide-creator/scripts/analyze_implementation.py \
  --target "Next.js 15" \
  --goal "Multilingual blog" \
  --features "i18n,mdx,dynamic-routes"

# 가이드 초기화
python ~/.claude/skills/implementation-guide-creator/scripts/init_guide.py \
  --target "Next.js 15" \
  --goal "Multilingual blog" \
  --type framework \
  --output "./docs/implementation/nextjs-i18n-blog.md"

# 가이드 검증
python ~/.claude/skills/implementation-guide-creator/scripts/validate_guide.py \
  ./docs/implementation/nextjs-i18n-blog.md
```

## 폴더 구조

```
implementation-guide-creator/
├── SKILL.md                          # 메인 스킬 정의
├── README.md                         # 이 파일
├── assets/
│   ├── examples/
│   │   └── nextjs-i18n-blog.md      # 예제 가이드
│   └── templates/
│       ├── framework-guide.md        # 프레임워크용 템플릿
│       ├── library-guide.md          # 라이브러리용 템플릿
│       └── service-integration.md    # 서비스 연동용 템플릿
├── references/
│   ├── extraction-strategy.md        # 문서 추출 전략
│   ├── guide-patterns.md             # 가이드 작성 패턴
│   ├── version-tracking.md           # 버전 관리 가이드
│   └── feature-mapping/
│       ├── nextjs-features.md        # Next.js 기능 매핑
│       └── supabase-features.md      # Supabase 기능 매핑
└── scripts/
    ├── analyze_implementation.py     # 구현 분석 스크립트
    ├── init_guide.py                 # 가이드 초기화 스크립트
    └── validate_guide.py             # 가이드 검증 스크립트
```

## 출력 위치

생성된 가이드는 프로젝트의 `./docs/implementation/` 디렉토리에 저장됩니다:

```
your-project/
├── docs/
│   └── implementation/
│       ├── kakao-auth.md
│       ├── supabase-realtime.md
│       └── nextjs-i18n-blog.md
└── ...
```

## 템플릿 종류

| 템플릿 | 사용 상황 | 예시 |
|--------|----------|------|
| `framework-guide.md` | 풀스택 프레임워크 | Next.js, SvelteKit, Remix |
| `library-guide.md` | 단일 목적 라이브러리 | React Query, Zustand, Zod |
| `service-integration.md` | 외부 서비스 연동 | Stripe, Kakao, Supabase |

## 스킬이 자동으로 사용되는 경우

- 외부 서비스 API/SDK 연동 요청
- 특정 라이브러리 기능 구현 요청
- 복합 기술 스택 통합 요청
- 이전에 할루시네이션이 발생했던 구현 재시도

## 스킬이 사용되지 않는 경우

- 단순한 코딩 질문
- Claude가 이미 잘 알고 있는 안정적인 개념
- 공식 퀵스타트로 충분한 간단한 연동

## 문제 해결

### 스킬이 인식되지 않는 경우

```bash
# 스킬 폴더 확인
ls ~/.claude/skills/

# SKILL.md 존재 확인
cat ~/.claude/skills/implementation-guide-creator/SKILL.md | head -10
```

### 스크립트 실행 오류

```bash
# Python 버전 확인 (3.8+ 필요)
python --version

# 스크립트 권한 확인
chmod +x ~/.claude/skills/implementation-guide-creator/scripts/*.py
```

## 라이선스

MIT License

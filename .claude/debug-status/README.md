# Debug Status Directory

버그 디버깅 파이프라인의 모든 리포트가 저장되는 디렉토리입니다.

## 파일 구조

```
.claude/debug-status/
├── README.md                          # 이 파일
├── current-bug.md                     # 최신 버그 리포트 (빠른 참조용)
├── bug-20251119-143052.md            # 아카이브된 버그 리포트 (타임스탬프)
├── bug-20251118-092341.md            # 이전 버그 리포트
└── ...
```

## 파일명 규칙

### 타임스탬프 기반 파일
- **형식**: `bug-YYYYMMDD-HHMMSS.md`
- **예시**: `bug-20251119-143052.md` (2025년 11월 19일 14시 30분 52초)
- **목적**: 영구 보관 및 히스토리 추적

### current-bug.md
- **목적**: 항상 최신 버그 리포트를 가리킴
- **업데이트**: 각 디버깅 파이프라인 실행 시 자동 덮어쓰기
- **사용**: 빠른 참조 및 CI/CD 통합

## 사용 방법

### 1. 새 버그 디버깅 시작
```bash
/debug-pipeline 로그인 시 null 에러 발생
```

orchestrator가 자동으로:
1. 타임스탬프 생성: `bug-20251119-143052.md`
2. 각 에이전트에 파일명 전달
3. 완료 시 `current-bug.md`에도 복사

### 2. 이전 버그 리포트 조회
```bash
# 최신 버그
cat .claude/debug-status/current-bug.md

# 특정 날짜/시간 버그
ls -lt .claude/debug-status/bug-*.md
cat .claude/debug-status/bug-20251119-143052.md
```

### 3. 버그 히스토리 검색
```bash
# 날짜별 검색
ls .claude/debug-status/bug-20251119-*.md

# 내용 검색 (예: "Riverpod" 관련 버그)
grep -l "Riverpod" .claude/debug-status/bug-*.md
```

## 리포트 구조

각 버그 리포트는 3단계로 구성됩니다:

### Stage 1: Error Verification (에러 검증)
```yaml
status: VERIFIED
verified_by: error-verifier
timestamp: 2025-11-19T14:30:52+09:00
severity: High
```

### Stage 2: Root Cause Analysis (근본 원인 분석)
```yaml
status: ANALYZED
analyzed_by: root-cause-analyzer
analyzed_at: 2025-11-19T14:45:23+09:00
confidence: 95%
```

### Stage 3: Fix Validation (수정 및 검증)
```yaml
status: FIXED_AND_TESTED
fixed_by: fix-validator
fixed_at: 2025-11-19T15:12:08+09:00
test_coverage: 87%
commits: [abc123, def456, ghi789]
```

## 자동화 및 통합

### CI/CD 통합
```bash
# 최신 버그 상태 확인
if grep -q "status: FIXED_AND_TESTED" .claude/debug-status/current-bug.md; then
  echo "버그 수정 완료, 배포 가능"
else
  echo "버그 수정 진행 중..."
fi
```

### Slack/Discord 알림
```bash
# 버그 검증 완료 시 알림
if grep -q "status: VERIFIED" .claude/debug-status/current-bug.md; then
  SEVERITY=$(grep "severity:" .claude/debug-status/current-bug.md | awk '{print $2}')
  curl -X POST $SLACK_WEBHOOK -d "{\"text\":\"새 버그 검증 완료 (심각도: $SEVERITY)\"}"
fi
```

## 파일 정리

### 보관 정책
- **최근 30일**: 모든 파일 보관
- **30-90일**: Critical/High 심각도만 보관
- **90일 이상**: 삭제

### 자동 정리 스크립트
```bash
# 90일 이상 된 파일 삭제
find .claude/debug-status -name "bug-*.md" -mtime +90 -delete

# current-bug.md는 항상 유지
```

## 문제 해결

### current-bug.md가 없을 때
- 최초 실행 시 자동 생성됨
- 수동 생성 필요 시: `touch .claude/debug-status/current-bug.md`

### 타임스탬프 충돌
- 1초 내 여러 실행 시 자동으로 microsecond 추가
- 예: `bug-20251119-143052-001.md`

### 파일 권한 오류
```bash
chmod 755 .claude/debug-status
chmod 644 .claude/debug-status/*.md
```

## 참고

- **디버깅 파이프라인**: `.claude/commands/debug-pipeline.md`
- **에이전트 문서**: `.claude/agents/error-verifier.md`, `root-cause-analyzer.md`, `fix-validator.md`

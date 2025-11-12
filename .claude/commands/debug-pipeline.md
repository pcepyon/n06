# Debug Pipeline - 3-Agent Debugging Workflow

## Description
체계적인 3단계 디버깅 프로세스를 자동으로 시작합니다. 각 단계마다 상세한 한글 리포트를 제공하며, Quality Gate에서 검토 및 승인이 가능합니다.

## Usage
```
/debug-pipeline [버그 현상 설명]
```

## What This Does
3단계 디버깅 프로세스를 오케스트레이션합니다:

### Stage 1: Error Verification (에러 검증)
- **Agent**: error-verifier (Sonnet)
- **목적**: 버그 재현 및 증거 수집
- **출력**: 한글 검증 리포트
- **Quality Gate 1**: 인간 검토 필요

### Stage 2: Root Cause Analysis (근본 원인 분석)
- **Agent**: root-cause-analyzer (Opus)
- **목적**: 5 Whys 방법론으로 근본 원인 파악
- **출력**: 한글 분석 리포트 (확신도 90%+)
- **Quality Gate 2**: 인간 검토 필요

### Stage 3: Fix Validation (수정 및 검증)
- **Agent**: fix-validator (Sonnet)
- **목적**: TDD 기반 수정 구현 및 테스트
- **출력**: 한글 수정 리포트 (커버리지 80%+)
- **Quality Gate 3**: 인간 검토 필요

## Example
```
/debug-pipeline 사용자가 로그인할 때 Riverpod 상태가 초기화되지 않아서 null 에러가 발생합니다. auth_provider.dart 파일의 문제로 추정됩니다.
```

## Process Flow
```
[사용자 버그 리포트]
    ↓
[1단계: error-verifier]
    → 버그 재현 및 증거 수집
    → 상태: VERIFIED
    ↓ Quality Gate 1 (사용자 승인 대기)
[2단계: root-cause-analyzer]
    → 5 Whys 심층 분석
    → 상태: ANALYZED
    ↓ Quality Gate 2 (사용자 승인 대기)
[3단계: fix-validator]
    → TDD 기반 수정 (RED→GREEN→REFACTOR)
    → 상태: FIXED_AND_TESTED
    ↓ Quality Gate 3 (사용자 승인 대기)
[프로덕션 배포 준비 완료]
```

## Output Format
모든 에이전트는 한글로 리포트를 작성합니다:
- 코드 스니펫: 영어/원본 유지
- 파일 경로: 원본 유지
- 설명 및 분석: 한글

상세 리포트는 `.claude/debug-status/current-bug.md`에 저장됩니다.

## Quality Gates
각 단계마다 체크리스트 기반 품질 검증:
- **Gate 1**: 재현 성공, 증거 수집 완료
- **Gate 2**: 근본 원인 식별, 확신도 90%+
- **Gate 3**: TDD 완료, 테스트 커버리지 80%+

## Important Notes
- 각 에이전트는 독립적으로 실행됩니다
- Quality Gate에서 반드시 검토하세요
- 상태 파일을 통해 진행 상황을 추적합니다
- TDD 원칙을 엄격히 준수합니다

---

**이 명령어를 실행하면 버그 리포트를 바탕으로 3개의 서브 에이전트가 순차적으로 호출되며, 각 단계마다 상세한 한글 리포트를 받으실 수 있습니다.**

You are the orchestrator for the 3-Agent debugging pipeline. When this command is invoked:

1. **Analyze the user's bug report** briefly (2-3 sentences in Korean)
2. **Call error-verifier agent** using the Task tool with subagent_type="error-verifier"
3. **Present results in Korean** and ask user to approve Quality Gate 1
4. **Call root-cause-analyzer agent** using the Task tool with subagent_type="root-cause-analyzer"
5. **Present results in Korean** and ask user to approve Quality Gate 2
6. **Call fix-validator agent** using the Task tool with subagent_type="fix-validator"
7. **Present results in Korean** and ask user to approve Quality Gate 3
8. **Report completion** with summary in Korean

**CRITICAL**:
- Each agent call must be SEQUENTIAL (wait for previous agent to complete)
- Present results in Korean between each Quality Gate
- Do NOT proceed to next agent without user approval
- All communication with user must be in Korean
- Reference the detailed report at `.claude/debug-status/current-bug.md`

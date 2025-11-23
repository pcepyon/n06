# Phase 2C: Automated Implementation Guide

This guide is for agents executing Phase 2C of the UI Renewal workflow.

## Objective

Automatically implement UI code in the project based on the approved Implementation Guide, modifying ONLY the Presentation layer while maintaining project architecture and code quality.

## Table of Contents

1. [Objective](#objective)
2. [Prerequisites](#prerequisites)
3. [Git Branch Workflow](#git-branch-workflow-recommended)
4. [Process](#process)
   - [Step 1a: Validate Implementation Guide](#step-1a-validate-implementation-guide)
   - [Step 1b: Explore Project Structure](#step-1b-explore-project-structure)
   - [Step 1c: Validate Presentation Layer](#step-1c-validate-presentation-layer-pre-implementation-check)
   - [Step 1d: Load Context and Understand Architecture](#step-1d-load-context-and-understand-architecture)
   - [Step 2: Explore Project Structure](#step-2-explore-project-structure)
   - [Step 3: Plan Implementation](#step-3-plan-implementation)
   - [Step 4: Implement Components](#step-4-implement-components)
   - [Step 5: Ensure Presentation Layer Only](#step-5-ensure-presentation-layer-only)
   - [Step 6: Code Quality Check](#step-6-code-quality-check)
   - [Step 7: Create Implementation Log](#step-7-create-implementation-log)
   - [Step 8: Update metadata.json](#step-8-update-metadatajson)
   - [Step 9: Present to User](#step-9-present-to-user)
5. [Critical Guidelines](#critical-guidelines)
6. [Implementation Scope](#implementation-scope-critical)
7. [Handling Errors](#handling-errors)
8. [Quality Checklist](#quality-checklist)
9. [Success Criteria](#success-criteria)
10. [Output Language](#output-language)

---

## Prerequisites

**Required:**
- Implementation Guide artifact from Phase 2B (MUST be in context)
- Project architecture documentation (CLAUDE.md, docs/code_structure.md)
- User has approved the specification

**Context Strategy:**
- Load Implementation Guide as Single Source of Truth
- Read project architecture rules
- Analyze existing code patterns
- Do NOT modify Application/Domain/Infrastructure layers

## Git Branch Workflow (Recommended)

**For safety and easy rollback, use Git branch-based workflow:**

### Option A: Git Available (Recommended)

**Before Phase 2C starts:**
```bash
# Create feature branch for this screen
git checkout -b ui-renewal/{screen-name}

# Commit current state (if needed)
git add .
git commit -m "Before UI renewal: {screen-name}"
```

**Benefits:**
- ✅ Easy rollback if needed
- ✅ Clean separation of changes
- ✅ Can review all changes with `git diff main`
- ✅ Safe experimentation

**After Phase 3 completes:**
```bash
# Merge changes to main
git checkout main
git merge ui-renewal/{screen-name}
git branch -d ui-renewal/{screen-name}
```

**If you want to rollback:**
```bash
# Discard all changes and return to main
git checkout main
git branch -D ui-renewal/{screen-name}
```

### Option B: No Git (Manual Backup)

**If Git is not available or project doesn't use version control:**

```bash
# Before Phase 2C, backup Presentation layer
cp -r lib/features/{feature}/presentation \
      lib/features/{feature}/presentation.backup-$(date +%Y%m%d-%H%M%S)
```

**Rollback if needed:**
```bash
# Restore from backup
rm -rf lib/features/{feature}/presentation
mv lib/features/{feature}/presentation.backup-YYYYMMDD-HHMMSS \
   lib/features/{feature}/presentation
```

**Note:** Option A (Git branch) is strongly recommended for production projects.

---

## Process

### Step 1a: Validate Implementation Guide

**Before loading the Implementation Guide, validate it exists and is complete:**

```bash
bash .claude/skills/ui-renewal/scripts/validate_artifact.sh \
  implementation \
  .claude/skills/ui-renewal/projects/{screen-name}/{date}-implementation-v{n}.md
```

**Expected output:** `✅ Artifact validated successfully`

**If validation fails:**
- ❌ Return to Phase 2B to fix the Implementation Guide
- ❌ Do NOT proceed to Phase 2C

**Validation checks:**
- File exists
- Component Specifications section present
- Layout Structure section present
- Code examples included

---

### Step 1b: Explore Project Structure

**IMPORTANT: Before starting, ensure Git branch workflow is set up (see Git Branch Workflow section above).**

If using Git (recommended):
```bash
# Verify you're on the feature branch
git branch --show-current
# Should show: ui-renewal/{screen-name}
```

If not on feature branch, create it now:
```bash
git checkout -b ui-renewal/{screen-name}
```

---

### Step 1c: Validate Presentation Layer (Pre-Implementation Check)

**IMPORTANT: Before implementing any code, set up validation:**

If using Git (recommended):
```bash
# Add git hook to validate on commit
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
bash .claude/skills/ui-renewal/scripts/validate_presentation_layer.sh stage
EOF
chmod +x .git/hooks/pre-commit
```

This ensures every commit is validated automatically.

**Manual validation (anytime):**
```bash
# Check current changes
bash .claude/skills/ui-renewal/scripts/validate_presentation_layer.sh check

# Check staged changes
bash .claude/skills/ui-renewal/scripts/validate_presentation_layer.sh stage
```

**Validation Rules:**
- ✅ **Allowed:** `lib/features/{feature}/presentation/`, `lib/core/presentation/`
- ❌ **Forbidden:** `application/`, `domain/`, `infrastructure/` layers

**If validation fails:**
- Review which files are in forbidden layers
- Revert those changes
- Only use existing providers/notifiers, don't modify them

---

### Step 1d: Load Context and Understand Architecture

**CRITICAL: Read project architecture first:**

1. **Read CLAUDE.md:**
   - Understand Clean Architecture principles
   - Identify layer boundaries
   - Note critical rules (non-negotiable)

2. **Read docs/code_structure.md:**
   - Understand file structure patterns
   - Note naming conventions
   - Identify DO/DON'T patterns

3. **Load Implementation Guide:**
   - This is the Single Source of Truth for WHAT to implement
   - Contains all component specifications
   - Contains all Design System token values
   - Contains framework-specific code examples

**Verify checklist:**
```
✅ Implementation Guide validated
✅ Implementation Guide loaded
✅ Project architecture understood
✅ Layer boundaries identified
✅ Presentation layer scope confirmed
✅ Git branch created (if using Git)
```

---

### Step 2: Explore Project Structure

**Identify existing patterns:**

1. **Find feature directory:**
   ```bash
   # Identify which feature this screen/widget belongs to
   ls lib/features/

   # Example: For login screen
   lib/features/authentication/presentation/
   ```

2. **Analyze existing code patterns:**
   ```dart
   // Read existing widgets to understand:
   - Import patterns
   - Provider usage patterns
   - Error handling patterns
   - Widget structure patterns
   - Styling approaches
   ```

3. **Find existing screens/widgets:**
   ```bash
   # Check what already exists
   ls lib/features/{feature}/presentation/screens/
   ls lib/features/{feature}/presentation/widgets/
   ls lib/core/presentation/widgets/
   ```

4. **Identify shared/core components:**
   ```bash
   # Check for reusable core widgets
   ls lib/core/presentation/
   ```

---

### Step 3: Plan Implementation

**Map Implementation Guide to project files:**

1. **For each component in Implementation Guide:**
   - Determine if it's a screen or widget
   - Determine if it's feature-specific or shared/core
   - Identify file path following project conventions
   - Check if file already exists (update) or needs creation (new)

2. **Example mapping:**
   ```
   Implementation Guide Component: "LoginScreen"
   → File: lib/features/authentication/presentation/screens/login_screen.dart
   → Action: Update existing file

   Implementation Guide Component: "PrimaryButton"
   → File: lib/core/presentation/widgets/gabium_button.dart
   → Action: Create new file (shared component)

   Implementation Guide Component: "EmailInputWidget"
   → File: lib/features/authentication/presentation/widgets/email_input_widget.dart
   → Action: Create new file
   ```

3. **Create implementation plan:**
   ```markdown
   Files to Create:
   - lib/core/presentation/widgets/gabium_button.dart
   - lib/features/authentication/presentation/widgets/email_input_widget.dart

   Files to Modify:
   - lib/features/authentication/presentation/screens/login_screen.dart
   - lib/core/routing/app_router.dart (if new route needed)
   ```

---

### Step 4: Implement Components

**For each component, follow this process:**

#### 4.1 Generate Widget Code

**Use Implementation Guide specifications:**

```dart
// Example: Implementing PrimaryButton from guide

import 'package:flutter/material.dart';

class GabiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GabiumButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        // Use exact token values from Implementation Guide
        backgroundColor: Color(0xFF4ADE80), // Primary from tokens
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontSize: 16,  // base from tokens
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16,  // md from tokens
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),  // sm from tokens
        ),
        elevation: 2,  // sm shadow approximation
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}
```

**Critical rules:**
```
✅ Use exact token values from Implementation Guide
✅ Follow existing code patterns in project
✅ Use proper imports
✅ Add proper documentation
✅ Implement all states (default, hover, active, disabled, loading, error)
✅ Follow Flutter/Dart best practices
```

#### 4.2 Update Screens

**Modify existing screen files to use new components:**

```dart
// Example: Updating LoginScreen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/email_input_widget.dart';
import '../../../../core/presentation/widgets/gabium_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use EXISTING providers - DO NOT create new ones
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
        // Use token values from Implementation Guide
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),  // lg from tokens
        child: Column(
          children: [
            EmailInputWidget(
              onChanged: (value) {
                // Use existing notifier methods
                ref.read(authNotifierProvider.notifier).updateEmail(value);
              },
            ),
            SizedBox(height: 16),  // md from tokens
            GabiumButton(
              text: '로그인',
              onPressed: () {
                // Use existing notifier methods
                ref.read(authNotifierProvider.notifier).login();
              },
              isLoading: authState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Critical rules for screens:**
```
✅ Use EXISTING providers/notifiers (ref.watch/ref.read)
✅ DO NOT create new providers
✅ DO NOT modify Application layer
✅ Only change UI presentation
✅ Maintain existing business logic calls
```

#### 4.3 Update Routing (If Needed)

**Only if Implementation Guide specifies new routes:**

```dart
// lib/core/routing/app_router.dart

// Add new route ONLY if it's a new screen
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),
```

**Rules:**
```
✅ Only add routes, do not modify routing logic
✅ Follow existing route naming patterns
✅ Do not change navigation guards or middleware
```

---

### Step 5: Ensure Presentation Layer Only

**CRITICAL VERIFICATION:**

Before saving any file, verify:

```
✅ File is in lib/features/{feature}/presentation/
   OR lib/core/presentation/
   OR lib/core/routing/ (routes only)

❌ File is NOT in:
   - lib/features/{feature}/application/
   - lib/features/{feature}/domain/
   - lib/features/{feature}/infrastructure/
   - Any business logic layer
```

**If you need to modify Application/Domain/Infrastructure:**
```
STOP immediately.
Report to user:
"구현 가이드에 Application/Domain/Infrastructure 계층 변경이 필요한 부분이 있습니다.
이는 UI Renewal 범위를 벗어납니다. 유저의 승인이 필요합니다."
```

---

### Step 6: Code Quality Check

**Run analysis before reporting completion:**

---

#### 6a. Validate Presentation Layer

**Before linting, validate architecture compliance:**

```bash
bash .claude/skills/ui-renewal/scripts/validate_presentation_layer.sh check
```

**Expected output:** `✅ VALIDATION PASSED`

**If validation fails:**
- ❌ You have modified Application/Domain/Infrastructure layers
- ❌ This violates Phase 2C constraints
- ❌ Revert forbidden changes and use only Presentation layer

---

#### 6b. Run Code Quality Checks

1. **Run flutter analyze:**
   ```bash
   flutter analyze lib/features/{feature}/presentation/
   flutter analyze lib/core/presentation/
   ```

2. **Check for common issues:**
   - Import errors
   - Missing dependencies
   - Unused imports
   - Type errors
   - Lint warnings

3. **If errors found:**
   - Fix automatically if simple (imports, formatting)
   - For complex errors, include in implementation log

---

### Step 7: Create Implementation Log

**Save detailed log of what was implemented:**

**File location:**
`.claude/skills/ui-renewal/projects/{screen-name}/{YYYYMMDD}-implementation-log-v1.md`

**Format:**
```markdown
# {Screen Name} Implementation Log

**날짜**: {YYYY-MM-DD}
**버전**: v1
**상태**: Completed / Partial (with errors)

## 구현 요약

Implementation Guide를 바탕으로 다음 항목을 자동 구현했습니다.

## 생성된 파일

### 1. lib/core/presentation/widgets/gabium_button.dart
- **타입**: 공유 위젯
- **목적**: 브랜드 Primary 버튼
- **토큰 사용**:
  - Primary color (#4ADE80)
  - Typography base (16px Medium)
  - Spacing md (16px)
  - Border radius sm (8px)
- **상태 구현**: Default, Hover, Active, Disabled, Loading
- **라인 수**: 45

### 2. lib/features/authentication/presentation/widgets/email_input_widget.dart
- **타입**: Feature 전용 위젯
- **목적**: 이메일 입력 필드
- **토큰 사용**:
  - Neutral colors
  - Typography base
  - Spacing md
- **라인 수**: 60

## 수정된 파일

### 1. lib/features/authentication/presentation/screens/login_screen.dart
- **변경 내용**:
  - 기존 TextField를 EmailInputWidget로 교체
  - 기존 버튼을 GabiumButton으로 교체
  - 레이아웃 간격 Design System 토큰으로 통일
- **보존된 로직**:
  - authNotifierProvider 사용 (변경 없음)
  - 기존 로그인 로직 (변경 없음)
- **수정 라인**: 30-80 (50줄)

### 2. lib/core/routing/app_router.dart (해당 시)
- **변경 내용**: /login 라우트 추가
- **수정 라인**: 45

## 아키텍처 준수 확인

✅ Presentation Layer만 수정
✅ Application Layer 변경 없음
✅ Domain Layer 변경 없음
✅ Infrastructure Layer 변경 없음
✅ 기존 Provider/Notifier 재사용
✅ 비즈니스 로직 보존

## 코드 품질 검사

```bash
$ flutter analyze lib/features/authentication/presentation/
Analyzing lib/features/authentication/presentation/...
No issues found!

$ flutter analyze lib/core/presentation/
Analyzing lib/core/presentation/...
No issues found!
```

**결과**: ✅ 모든 Lint 검사 통과

## 재사용 가능 컴포넌트

다음 컴포넌트는 다른 화면에서 재사용 가능:
- GabiumButton (lib/core/presentation/widgets/gabium_button.dart)

Phase 3에서 Component Registry 업데이트 예정.

## 구현 가정

1. authNotifierProvider는 기존에 존재하며 다음 메서드 제공:
   - updateEmail(String email)
   - login()
2. 기존 로그인 로직 변경 불필요
3. 에러 처리는 기존 방식 유지

## 다음 단계

Phase 3 (에셋 정리)으로 자동 진행.
```

---

### Step 8: Update metadata.json

**Update project metadata:**

```json
{
  "project_name": "{screen-name}",
  "status": "in_progress",
  "current_phase": "phase2c",
  "created_date": "{YYYY-MM-DD}",
  "last_updated": "{now}",
  "framework": "Flutter",
  "design_system_version": "v1.0",
  "versions": {
    "proposal": "v1",
    "implementation": "v1",
    "implementation_log": "v1"
  },
  "dependencies": [],
  "components_created": [
    "GabiumButton"
  ]
}
```

---

### Step 9: Present to User (Korean)

**Concise summary:**

```markdown
코드 구현이 완료되었습니다!

## 생성된 파일
- lib/core/presentation/widgets/gabium_button.dart
- lib/features/authentication/presentation/widgets/email_input_widget.dart

## 수정된 파일
- lib/features/authentication/presentation/screens/login_screen.dart

## 코드 품질
✅ Flutter analyze 통과
✅ Presentation Layer만 수정
✅ 기존 비즈니스 로직 보존

## 문서
- 구현 로그: projects/{screen-name}/{date}-implementation-log-v1.md

Phase 3 (에셋 정리)으로 진행합니다.
```

---

## Critical Guidelines

### Phase 2C DOES:
✅ Implement UI code based on Implementation Guide
✅ Create/modify widgets and screens
✅ Use EXISTING providers/notifiers
✅ Follow project architecture strictly
✅ Use exact Design System token values
✅ Add proper documentation
✅ Run code analysis
✅ Create implementation log

### Phase 2C DOES NOT:
❌ Create new providers or notifiers
❌ Modify Application layer
❌ Modify Domain layer
❌ Modify Infrastructure layer
❌ Change business logic
❌ Modify data models
❌ Change routing logic (only add routes)
❌ Update Component Registry (done in Phase 3)

**Note:** Component Registry is NOT updated in Phase 2C. This is done in Phase 3 after implementation is complete.

---

## Implementation Scope (CRITICAL)

**✅ CAN modify:**
```
lib/features/{feature}/presentation/screens/
lib/features/{feature}/presentation/widgets/
lib/core/presentation/widgets/
lib/core/routing/app_router.dart (only add routes)
```

**❌ CANNOT modify:**
```
lib/features/{feature}/application/
lib/features/{feature}/domain/
lib/features/{feature}/infrastructure/
lib/core/[anything except presentation and routing]
Any business logic, state management, or data access
```

**If Implementation Guide requires non-Presentation changes:**
```
STOP and report to user:
"이 구현 가이드는 Presentation Layer 외 계층 변경이 필요합니다.
UI Renewal 범위를 벗어나므로 유저의 승인이 필요합니다."
```

---

## Handling Errors

**During implementation, if errors occur:**

1. **Simple errors (imports, formatting):**
   - Fix automatically
   - Document in implementation log

2. **Complex errors (missing dependencies, type issues):**
   - Document in implementation log
   - Mark status as "Partial (with errors)"
   - Include error details
   - Report to user for manual review

3. **Architectural violations detected:**
   - STOP immediately
   - Report to user
   - Do not proceed to Phase 3

**Do NOT:**
- ❌ Try to fix errors by modifying Application/Domain/Infrastructure
- ❌ Create new providers to avoid errors
- ❌ Skip error reporting

---

## Quality Checklist

✅ **Architecture:**
- Only Presentation layer modified
- No Application/Domain/Infrastructure changes
- Existing providers/notifiers reused
- Business logic preserved

✅ **Code Quality:**
- Flutter analyze passes
- No lint errors
- Proper imports
- Clean code structure

✅ **Specification:**
- All components from Implementation Guide implemented
- All Design System token values used exactly
- All states implemented (default, hover, active, disabled, etc.)

✅ **Documentation:**
- Implementation log created
- metadata.json updated
- Clear file list provided

---

## Success Criteria

Phase 2C succeeds when:
- ✅ All UI code implemented in Presentation layer
- ✅ No Application/Domain/Infrastructure changes
- ✅ Existing providers/notifiers reused
- ✅ Flutter analyze passes
- ✅ Implementation log saved
- ✅ metadata.json updated
- ✅ Ready for Phase 3 asset organization

---

## OUTPUT LANGUAGE

**CRITICAL: All user-facing output MUST be in Korean.**

### Korean Output (사용자 대면):
- ✅ Implementation completion summary
- ✅ File lists
- ✅ Status messages
- ✅ Error messages
- ✅ Next steps

### English OK (Internal):
- ✅ Code (Dart/Flutter)
- ✅ Comments in code
- ✅ Implementation log (can mix Korean/English)
- ✅ Technical terms

### Example:

**Good (Korean summary):**
```
코드 구현이 완료되었습니다!

생성된 파일:
- lib/core/presentation/widgets/gabium_button.dart

✅ Flutter analyze 통과
✅ Presentation Layer만 수정

Phase 3 (에셋 정리)로 진행합니다.
```

**Code can be in English:**
```dart
class GabiumButton extends StatelessWidget {
  // Implementation...
}
```

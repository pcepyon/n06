# Git Branch Workflow for UI Renewal

## Workflow Diagram

```
main branch (stable)
    |
    |--- git checkout -b ui-renewal/screen-name
    |
    +--- ui-renewal/screen-name (feature branch)
         |
         | Phase 2C: Implement code changes
         |   - Modify Presentation layer
         |   - Create new widgets
         |   - Update screens
         |
         | Phase 3 Step 1: Initial Verification
         |   - Verify implementation
         |   - Check code quality
         |
         | Phase 3 Step 2: Revision Loop (if needed)
         |   ├── Minor fixes → Phase 2C fixes → Re-verify
         |   └── Major issues → Rollback option available
         |
         | Phase 3 Step 3: Final Confirmation
         |
         +--- Decision Point:
              |
              ├── ✅ User confirms "완료"
              |   |
              |   | git checkout main
              |   | git merge ui-renewal/screen-name --no-ff
              |   | git branch -d ui-renewal/screen-name
              |   |
              |   +---> main (changes merged, feature branch deleted)
              |
              └── ❌ Major issues / User wants to restart
                  |
                  | git checkout main
                  | git branch -D ui-renewal/screen-name (force delete)
                  |
                  +---> main (all changes discarded, clean state)
```

## Branch Strategy

### Feature Branch Naming Convention
```
ui-renewal/{screen-name}
```

Examples:
- `ui-renewal/login-screen`
- `ui-renewal/dashboard`
- `ui-renewal/email-signup-screen`

### Branch Lifecycle

1. **Creation (Before Phase 2C)**
   ```bash
   git checkout -b ui-renewal/{screen-name}
   ```

2. **Development (Phase 2C)**
   - All code changes happen on feature branch
   - Presentation layer modifications only
   - Safe experimentation without affecting main

3. **Verification (Phase 3)**
   - Verify while still on feature branch
   - Can rollback anytime if needed
   - Multiple revision iterations possible

4. **Completion (Phase 3 Step 3)**
   - **Success Path**: Merge to main, delete branch
   - **Failure Path**: Discard branch, return to main

## Rollback Options

### Option 1: Discard All Changes (Full Rollback)
```bash
git checkout main
git branch -D ui-renewal/{screen-name}
```

**Use when:**
- Major architectural issues found
- Need to restart from scratch
- Approach was fundamentally wrong

**Result:**
- All changes discarded
- Return to clean main branch
- Can restart from Phase 2A or 2B

### Option 2: Partial Rollback (Specific Files)
```bash
# Stay on feature branch
git checkout main -- lib/features/{feature}/presentation/screens/{file}.dart

# Or reset specific files
git restore --source=main lib/features/{feature}/presentation/screens/{file}.dart
```

**Use when:**
- Only specific files need to be reverted
- Want to keep other changes
- Selective undo needed

### Option 3: Commit and Continue (No Rollback)
```bash
# Commit current state
git add .
git commit -m "WIP: Partial implementation"

# Continue with fixes
# (Phase 2C makes additional changes)
```

**Use when:**
- Minor fixes needed
- Progress worth saving
- Iterative improvement approach

## Comparison: Git Workflow vs Manual Backup

| Aspect | Git Branch Workflow | Manual Backup |
|--------|---------------------|---------------|
| **Rollback Speed** | Instant (`git checkout main`) | Slow (manual copy/restore) |
| **Storage** | Efficient (Git compression) | Wasteful (full folder copy) |
| **History** | Full commit history | Single snapshot |
| **Selective Undo** | File-level granularity | All-or-nothing |
| **Review Changes** | `git diff main` | Manual file comparison |
| **Parallel Work** | Easy branch switching | Complex manual management |
| **Safety** | Very safe (Git guarantees) | Risk of backup corruption |

## Integration with UI Renewal Phases

### Phase 2C: Automated Implementation
```bash
# Step 1: Create branch
git checkout -b ui-renewal/{screen-name}

# Step 2: Verify branch
git branch --show-current
# Should output: ui-renewal/{screen-name}

# Step 3: Phase 2C implements code
# (Automatic code generation in Presentation layer)

# Step 4: Review changes
git status
git diff main
```

### Phase 3 Step 1: Initial Verification
```bash
# Still on feature branch
git branch --show-current

# If verification fails, can rollback anytime
git diff main  # Review all changes
```

### Phase 3 Step 2: Revision Loop
```bash
# Option A: Minor fixes - Stay on branch
# Phase 2C makes fixes, re-verify

# Option B: Major issues - Rollback
git checkout main
git branch -D ui-renewal/{screen-name}
# Restart from Phase 2B or 2A
```

### Phase 3 Step 3: Final Confirmation
```bash
# User confirms "완료"
git checkout main
git merge ui-renewal/{screen-name} --no-ff -m "UI Renewal: {screen-name} completed"
git branch -d ui-renewal/{screen-name}

# Verify merge
git log --oneline --graph -5
```

## Best Practices

### 1. Always Verify Current Branch
```bash
# Before making changes
git branch --show-current

# Should show: ui-renewal/{screen-name}
# NOT: main
```

### 2. Review Changes Before Merging
```bash
# See all files changed
git diff --name-status main

# See full diff
git diff main

# See commit history
git log main..HEAD
```

### 3. Use No-FF Merge for Clear History
```bash
# Good: Creates merge commit
git merge ui-renewal/{screen-name} --no-ff -m "UI Renewal: login-screen completed"

# Bad: Fast-forward merge (loses context)
git merge ui-renewal/{screen-name}
```

### 4. Clean Up After Merge
```bash
# After successful merge
git branch -d ui-renewal/{screen-name}  # Delete local branch

# Verify cleanup
git branch  # Should not show feature branch
```

### 5. Commit Message Convention
```bash
# For merge commits
git merge ui-renewal/{screen-name} --no-ff -m "UI Renewal: {screen-name} completed

- Implemented Design System tokens
- Created reusable components: [list]
- Updated Presentation layer only
- All tests passing

Phase 3 verification: PASS
"
```

## Safety Checklist

Before merging to main:

- [ ] All Phase 3 verification checks passed
- [ ] User explicitly confirmed "완료"
- [ ] No Application/Domain/Infrastructure changes
- [ ] All files in Presentation layer only
- [ ] No lint errors (`flutter analyze`)
- [ ] Reviewed `git diff main`
- [ ] Clean commit history
- [ ] Branch name follows convention

## Troubleshooting

### Problem: Accidentally started changes on main
```bash
# Stash changes
git stash

# Create feature branch
git checkout -b ui-renewal/{screen-name}

# Apply stashed changes
git stash pop
```

### Problem: Need to switch branches mid-work
```bash
# Commit work in progress
git add .
git commit -m "WIP: Partial implementation"

# Switch to main
git checkout main

# Return later
git checkout ui-renewal/{screen-name}
```

### Problem: Merge conflicts
```bash
# During merge
git checkout main
git merge ui-renewal/{screen-name}

# If conflicts occur
git status  # See conflicted files
# Resolve conflicts manually
git add .
git commit -m "UI Renewal: {screen-name} completed"
```

### Problem: Want to preview merge without committing
```bash
# Dry run merge
git merge --no-commit --no-ff ui-renewal/{screen-name}

# Review changes
git status
git diff --cached

# Abort if needed
git merge --abort

# Or commit if satisfied
git commit -m "UI Renewal: {screen-name} completed"
```

## Summary

**Git branch workflow provides:**
- ✅ Safe experimentation (easy rollback)
- ✅ Clean separation of changes
- ✅ Full change history
- ✅ Flexible undo options
- ✅ Professional version control
- ✅ Easy code review

**Recommended for:**
- All production projects
- Team collaboration
- Complex UI changes
- Multiple iteration cycles

**Manual backup only for:**
- No Git available
- Personal/experimental projects
- One-time changes

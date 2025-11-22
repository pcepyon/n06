#!/bin/bash

# Presentation Layer Validation Script
# Ensures Phase 2C only modifies Presentation layer (Clean Architecture)

set -e

MODE="${1:-check}"

if [ "$MODE" != "check" ] && [ "$MODE" != "stage" ]; then
  echo "Usage: $0 [check|stage]"
  echo ""
  echo "Modes:"
  echo "  check  - Check git changes (default)"
  echo "  stage  - Check staged files only"
  echo ""
  echo "Purpose:"
  echo "  Validates that only Presentation layer files are modified"
  echo "  Prevents Phase 2C from violating Clean Architecture"
  exit 1
fi

echo "🔍 Validating Presentation Layer changes..."

# Get list of changed files
if [ "$MODE" = "stage" ]; then
  CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
else
  CHANGED_FILES=$(git diff --name-only --diff-filter=ACM 2>/dev/null || echo "")
fi

if [ -z "$CHANGED_FILES" ]; then
  echo "✅ No changes detected"
  exit 0
fi

# Track violations
VIOLATIONS=0
ALLOWED_CHANGES=0

echo ""
echo "Checking files:"

for file in $CHANGED_FILES; do
  # Skip non-Dart files (allowing config, assets, etc.)
  if [[ ! $file =~ \.dart$ ]]; then
    echo "  ℹ️  Skipped (non-code): $file"
    continue
  fi

  # Check if file is in allowed Presentation layer paths
  if [[ $file =~ lib/features/[^/]+/presentation/ ]] || \
     [[ $file =~ lib/core/presentation/ ]] || \
     [[ $file =~ lib/shared/presentation/ ]]; then
    echo "  ✅ Allowed: $file"
    ((ALLOWED_CHANGES++))
  else
    # Check if it's a forbidden layer
    if [[ $file =~ lib/features/[^/]+/application/ ]] || \
       [[ $file =~ lib/features/[^/]+/domain/ ]] || \
       [[ $file =~ lib/features/[^/]+/infrastructure/ ]] || \
       [[ $file =~ lib/core/(application|domain|infrastructure)/ ]]; then
      echo "  ❌ VIOLATION: $file"
      echo "     This file is in Application/Domain/Infrastructure layer!"
      ((VIOLATIONS++))
    else
      # Warn about other files (might be routing, main, etc.)
      echo "  ⚠️  Warning: $file"
      echo "     This file is outside standard layers (review manually)"
    fi
  fi
done

echo ""
echo "Summary:"
echo "  ✅ Allowed Presentation layer changes: $ALLOWED_CHANGES"
echo "  ❌ Architecture violations: $VIOLATIONS"

if [ $VIOLATIONS -gt 0 ]; then
  echo ""
  echo "❌ VALIDATION FAILED"
  echo ""
  echo "Phase 2C can ONLY modify:"
  echo "  ✅ lib/features/{feature}/presentation/"
  echo "  ✅ lib/core/presentation/"
  echo "  ✅ lib/shared/presentation/"
  echo ""
  echo "Phase 2C CANNOT modify:"
  echo "  ❌ lib/features/{feature}/application/"
  echo "  ❌ lib/features/{feature}/domain/"
  echo "  ❌ lib/features/{feature}/infrastructure/"
  echo "  ❌ lib/core/(application|domain|infrastructure)/"
  echo ""
  echo "Please revert changes to non-Presentation files."
  exit 1
fi

echo ""
echo "✅ VALIDATION PASSED - All changes are in Presentation layer"
exit 0

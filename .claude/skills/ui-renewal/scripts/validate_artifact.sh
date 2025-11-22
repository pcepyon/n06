#!/bin/bash

# UI Renewal Artifact Validation Script
# Validates artifacts before phase transitions

set -e

ARTIFACT_TYPE="${1:-}"
ARTIFACT_PATH="${2:-}"

if [ -z "$ARTIFACT_TYPE" ] || [ -z "$ARTIFACT_PATH" ]; then
  echo "Usage: $0 <type> <path>"
  echo ""
  echo "Types:"
  echo "  proposal          - Improvement Proposal (Phase 2A output)"
  echo "  implementation    - Implementation Guide (Phase 2B output)"
  echo "  implementation-log - Implementation Log (Phase 2C output)"
  echo "  verification      - Verification Report (Phase 3 output)"
  echo ""
  echo "Example:"
  echo "  $0 proposal projects/login-screen/20251122-proposal-v1.md"
  exit 1
fi

# Check file exists
if [ ! -f "$ARTIFACT_PATH" ]; then
  echo "❌ ERROR: Artifact not found: $ARTIFACT_PATH"
  exit 1
fi

# Validate based on type
case "$ARTIFACT_TYPE" in
  proposal)
    echo "Validating Improvement Proposal..."

    # Required sections (check for both naming conventions)
    if ! grep -q "## Current State" "$ARTIFACT_PATH"; then
      echo "❌ ERROR: Missing section 'Current State Analysis' or 'Current State Issues'"
      exit 1
    fi

    if ! grep -q "## \(Proposed Changes\|Improvement Direction\)" "$ARTIFACT_PATH"; then
      echo "❌ ERROR: Missing section 'Proposed Changes' or 'Improvement Direction'"
      exit 1
    fi

    grep -q "## Design System Token Reference" "$ARTIFACT_PATH" || {
      echo "❌ ERROR: Missing section 'Design System Token Reference'"
      exit 1
    }

    # Check token reference table has content
    if ! grep -A 5 "## Design System Token Reference" "$ARTIFACT_PATH" | grep -q "|"; then
      echo "❌ ERROR: Design System Token Reference table is empty"
      exit 1
    fi

    echo "✅ Proposal validation passed"
    ;;

  implementation)
    echo "Validating Implementation Guide..."

    # Required sections
    grep -q "## Component Specifications" "$ARTIFACT_PATH" || {
      echo "❌ ERROR: Missing section 'Component Specifications'"
      exit 1
    }

    if ! grep -q "## Layout \(Structure\|Specification\)" "$ARTIFACT_PATH"; then
      echo "❌ ERROR: Missing section 'Layout Structure' or 'Layout Specification'"
      exit 1
    fi

    # Check for code examples
    if ! grep -q "\`\`\`" "$ARTIFACT_PATH"; then
      echo "⚠️  WARNING: No code examples found"
    fi

    echo "✅ Implementation Guide validation passed"
    ;;

  implementation-log)
    echo "Validating Implementation Log..."

    # Required sections
    grep -q "## Files Created/Modified" "$ARTIFACT_PATH" || {
      echo "❌ ERROR: Missing section 'Files Created/Modified'"
      exit 1
    }

    grep -q "## Changes Summary" "$ARTIFACT_PATH" || {
      echo "❌ ERROR: Missing section 'Changes Summary'"
      exit 1
    }

    echo "✅ Implementation Log validation passed"
    ;;

  verification)
    echo "Validating Verification Report..."

    # Required sections
    grep -q "## 검증 결과 요약" "$ARTIFACT_PATH" || {
      echo "❌ ERROR: Missing section '검증 결과 요약'"
      exit 1
    }

    grep -q "## 발견된 문제점" "$ARTIFACT_PATH" || {
      echo "❌ ERROR: Missing section '발견된 문제점'"
      exit 1
    }

    # Check status
    if ! grep -q "상태.*:.*\(PASS\|FAIL\|NEEDS WORK\)" "$ARTIFACT_PATH"; then
      echo "❌ ERROR: No validation status found (PASS/FAIL/NEEDS WORK)"
      exit 1
    fi

    echo "✅ Verification Report validation passed"
    ;;

  *)
    echo "❌ ERROR: Unknown artifact type: $ARTIFACT_TYPE"
    exit 1
    ;;
esac

echo "✅ Artifact validated successfully: $ARTIFACT_PATH"

#!/bin/bash

# UI Renewal Git Workflow Helper Script
# Manages Git branches for safe Phase 2C implementation

set -e

SCREEN_NAME="${1:-}"
ACTION="${2:-start}"

if [ -z "$SCREEN_NAME" ]; then
  echo "Usage: $0 <screen-name> [start|merge|rollback]"
  echo ""
  echo "Examples:"
  echo "  $0 login-screen start      # Start new UI renewal branch"
  echo "  $0 login-screen merge      # Merge completed work to main"
  echo "  $0 login-screen rollback   # Discard changes and return to main"
  exit 1
fi

BRANCH_NAME="ui-renewal/${SCREEN_NAME}"

case "$ACTION" in
  start)
    echo "Creating UI renewal branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"
    echo "✅ Branch created. Ready for Phase 2C."
    ;;

  merge)
    echo "Merging $BRANCH_NAME to main..."
    git checkout main
    git merge "$BRANCH_NAME" --no-ff -m "UI Renewal: ${SCREEN_NAME} completed"
    git branch -d "$BRANCH_NAME"
    echo "✅ Merged and branch deleted."
    ;;

  rollback)
    echo "⚠️  WARNING: This will discard all changes in $BRANCH_NAME"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
      git checkout main
      git branch -D "$BRANCH_NAME"
      echo "✅ Rolled back. All changes discarded."
    else
      echo "Cancelled."
    fi
    ;;

  *)
    echo "Unknown action: $ACTION"
    echo "Valid actions: start, merge, rollback"
    exit 1
    ;;
esac

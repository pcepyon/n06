#!/bin/bash

# Design System Versioning Helper
# Creates new version and updates VERSION_HISTORY.md

set -e

ACTION="${1:-}"
VERSION="${2:-}"
PRODUCT="${3:-gabium}"

if [ -z "$ACTION" ]; then
  echo "Usage: $0 <action> [version] [product]"
  echo ""
  echo "Actions:"
  echo "  create <version>  - Create new Design System version"
  echo "  rollback <version> - Rollback to specific version"
  echo "  list              - List all versions"
  echo ""
  echo "Examples:"
  echo "  $0 create v1.1 gabium"
  echo "  $0 rollback v1.0 gabium"
  echo "  $0 list"
  exit 1
fi

DS_DIR=".claude/skills/ui-renewal/design-systems"
CURRENT_FILE="$DS_DIR/${PRODUCT}-design-system.md"

case "$ACTION" in
  create)
    if [ -z "$VERSION" ]; then
      echo "ERROR: Version required for create action"
      exit 1
    fi

    NEW_FILE="$DS_DIR/${PRODUCT}-design-system-${VERSION}.md"

    if [ -f "$NEW_FILE" ]; then
      echo "ERROR: Version $VERSION already exists"
      exit 1
    fi

    echo "Creating Design System version $VERSION..."

    # Copy current to new version
    if [ -L "$CURRENT_FILE" ]; then
      CURRENT_TARGET=$(readlink "$CURRENT_FILE")
      cp "$DS_DIR/$CURRENT_TARGET" "$NEW_FILE"
    elif [ -f "$CURRENT_FILE" ]; then
      cp "$CURRENT_FILE" "$NEW_FILE"
    else
      echo "ERROR: Current Design System not found"
      exit 1
    fi

    # Update symlink
    cd "$DS_DIR"
    ln -sf "${PRODUCT}-design-system-${VERSION}.md" "${PRODUCT}-design-system.md"
    cd - > /dev/null

    echo "✅ Version $VERSION created: $NEW_FILE"
    echo "✅ Symlink updated"
    echo ""
    echo "Next steps:"
    echo "1. Edit $NEW_FILE with your changes"
    echo "2. Update VERSION_HISTORY.md with change log"
    ;;

  rollback)
    if [ -z "$VERSION" ]; then
      echo "ERROR: Version required for rollback action"
      exit 1
    fi

    ROLLBACK_FILE="$DS_DIR/${PRODUCT}-design-system-${VERSION}.md"

    if [ ! -f "$ROLLBACK_FILE" ]; then
      echo "ERROR: Version $VERSION not found"
      exit 1
    fi

    echo "Rolling back to version $VERSION..."

    # Update symlink
    cd "$DS_DIR"
    ln -sf "${PRODUCT}-design-system-${VERSION}.md" "${PRODUCT}-design-system.md"
    cd - > /dev/null

    echo "✅ Rolled back to $VERSION"
    echo "⚠️  Don't forget to update VERSION_HISTORY.md"
    ;;

  list)
    echo "Design System Versions:"
    echo ""

    if [ -L "$CURRENT_FILE" ]; then
      CURRENT_TARGET=$(readlink "$CURRENT_FILE")
      echo "Current (symlink): $CURRENT_TARGET"
      echo ""
    fi

    echo "Available versions:"
    ls -1 "$DS_DIR"/*.md | grep -E "v[0-9]+\.[0-9]+" | xargs -n1 basename || echo "  (none found)"
    ;;

  *)
    echo "ERROR: Unknown action: $ACTION"
    exit 1
    ;;
esac

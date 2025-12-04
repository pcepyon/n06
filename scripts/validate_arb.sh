#!/bin/bash
# ARB File Validation Script
# Usage: ./scripts/validate_arb.sh
set -e

echo "🔍 Validating ARB files..."

ARB_DIR="lib/l10n"

# Check if ARB files exist
if [ ! -f "$ARB_DIR/app_ko.arb" ]; then
  echo "❌ Missing: $ARB_DIR/app_ko.arb"
  exit 1
fi

if [ ! -f "$ARB_DIR/app_en.arb" ]; then
  echo "❌ Missing: $ARB_DIR/app_en.arb"
  exit 1
fi

# JSON syntax validation
echo "📋 Checking JSON syntax..."
for file in $ARB_DIR/app_*.arb; do
  if ! python3 -m json.tool "$file" > /dev/null 2>&1; then
    echo "❌ Invalid JSON syntax: $file"
    exit 1
  fi
  echo "  ✓ $file"
done

# Key consistency check
echo "📋 Checking key consistency..."
ko_keys=$(python3 -c "import json; f=open('$ARB_DIR/app_ko.arb'); d=json.load(f); print('\n'.join(sorted([k for k in d.keys() if not k.startswith('@')])))")
en_keys=$(python3 -c "import json; f=open('$ARB_DIR/app_en.arb'); d=json.load(f); print('\n'.join(sorted([k for k in d.keys() if not k.startswith('@')])))")

missing_in_en=$(comm -23 <(echo "$ko_keys") <(echo "$en_keys"))
missing_in_ko=$(comm -13 <(echo "$ko_keys") <(echo "$en_keys"))

if [ -n "$missing_in_en" ]; then
  echo "⚠️  Missing English keys:"
  echo "$missing_in_en" | sed 's/^/    /'
fi

if [ -n "$missing_in_ko" ]; then
  echo "⚠️  Missing Korean keys:"
  echo "$missing_in_ko" | sed 's/^/    /'
fi

# Count keys
ko_count=$(echo "$ko_keys" | wc -l | tr -d ' ')
en_count=$(echo "$en_keys" | wc -l | tr -d ' ')

echo ""
echo "📊 Key counts:"
echo "  Korean: $ko_count keys"
echo "  English: $en_count keys"

if [ "$ko_count" -eq "$en_count" ] && [ -z "$missing_in_en" ] && [ -z "$missing_in_ko" ]; then
  echo ""
  echo "✅ ARB validation passed"
  exit 0
else
  echo ""
  echo "⚠️  ARB validation completed with warnings"
  exit 0
fi

#!/usr/bin/env python3
"""
Add MEDICAL REVIEW REQUIRED tags to medical/health-related ARB keys.
"""

import json
import re
import sys

# Patterns that require MEDICAL REVIEW tag
MEDICAL_PATTERNS = [
    # Checkin feedback
    r'^checkin_.*Feedback$',
    r'^checkin_.*_feedback$',
    # Checkin questions
    r'^checkin_.*Question$',
    r'^checkin_.*_question$',
    # Checkin answers
    r'^checkin_.*Answer$',
    r'^checkin_.*_answer$',
    # Emergency tracking
    r'^tracking_emergency_',
    # Symptom tracking
    r'^tracking_symptom',
    # Onboarding medical content
    r'^onboarding_sideEffects_',
    r'^onboarding_injection_',
    r'^onboarding_evidence_',
    r'^onboarding_howItWorks_',
    # Records symptoms
    r'^records_symptom_',
    # Coping guides
    r'^coping_',
]

def should_have_medical_review(key: str) -> bool:
    """Check if key matches medical patterns."""
    for pattern in MEDICAL_PATTERNS:
        if re.match(pattern, key):
            return True
    return False

def add_medical_review_tags(arb_file_path: str):
    """Add MEDICAL REVIEW tags to qualifying keys."""

    # Read ARB file
    with open(arb_file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Parse JSON
    data = json.loads(content)

    # Track changes
    added_count = 0
    already_tagged_count = 0
    categories = {}

    # Process each key
    for key in list(data.keys()):
        # Skip metadata keys
        if key.startswith('@'):
            continue

        # Check if key should have medical review
        if not should_have_medical_review(key):
            continue

        # Get category
        category = key.split('_')[0]
        if category not in categories:
            categories[category] = {'added': 0, 'already_tagged': 0}

        # Get or create metadata
        metadata_key = f'@{key}'
        metadata = data.get(metadata_key, {})

        # Check if already has MEDICAL REVIEW tag
        description = metadata.get('description', '')
        if 'MEDICAL REVIEW' in description:
            already_tagged_count += 1
            categories[category]['already_tagged'] += 1
            continue

        # Add MEDICAL REVIEW tag
        if description:
            new_description = f"{description} - MEDICAL REVIEW REQUIRED"
        else:
            new_description = "MEDICAL REVIEW REQUIRED"

        metadata['description'] = new_description
        data[metadata_key] = metadata

        added_count += 1
        categories[category]['added'] += 1

    # Write back to file
    with open(arb_file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')

    # Report
    print(f"\n=== {arb_file_path} ===")
    print(f"Added MEDICAL REVIEW tags: {added_count}")
    print(f"Already tagged: {already_tagged_count}")
    print(f"Total MEDICAL REVIEW keys: {added_count + already_tagged_count}")

    print("\nBy category:")
    for cat, counts in sorted(categories.items()):
        total = counts['added'] + counts['already_tagged']
        print(f"  {cat}: {total} total ({counts['added']} added, {counts['already_tagged']} already tagged)")

    return added_count, already_tagged_count

if __name__ == '__main__':
    ko_added, ko_existing = add_medical_review_tags('lib/l10n/app_ko.arb')
    en_added, en_existing = add_medical_review_tags('lib/l10n/app_en.arb')

    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"Total tags added: {ko_added}")
    print(f"Total MEDICAL REVIEW keys: {ko_added + ko_existing}")

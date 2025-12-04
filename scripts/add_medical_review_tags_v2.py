#!/usr/bin/env python3
"""
Add MEDICAL REVIEW REQUIRED tags to medical/health-related ARB keys.
Phase C: Comprehensive medical content tagging
"""

import json
import re
import sys

def should_have_medical_review(key: str) -> bool:
    """
    Check if key is medical content requiring review.

    Based on task requirements:
    - All checkin_* (except pure UI labels)
    - All coping_*
    - tracking_emergency_*, tracking_symptom*
    - onboarding medical: sideEffects, injection, evidence, howItWorks
    - records_symptom_*
    """

    # Pure UI/navigation keys (exclude from medical review)
    ui_only_patterns = [
        r'^checkin_screen_',
        r'^checkin_button_',
        r'^checkin_nav',
        r'_title$',
        r'_label$',
        r'_hint$',
        r'_unit$',
    ]

    for pattern in ui_only_patterns:
        if re.search(pattern, key):
            return False

    # Medical content patterns (include for medical review)
    medical_patterns = [
        # All checkin content (questions, answers, feedback, etc.)
        r'^checkin_',

        # All coping guide content
        r'^coping_',

        # Tracking - emergency and symptoms
        r'^tracking_emergency_',
        r'^tracking_symptom',
        r'^tracking_condition_',
        r'^tracking_redFlag_',

        # Onboarding medical content
        r'^onboarding_sideEffects_',
        r'^onboarding_injection_',
        r'^onboarding_evidence_',
        r'^onboarding_howItWorks_',
        r'^onboarding_foodNoise_',
        r'^onboarding_notYourFault_',

        # Records symptoms
        r'^records_symptom_',

        # Dashboard health-related messages
        r'^dashboard_greeting_encouragement',
        r'^dashboard_progress_',
        r'^dashboard_checkin_',
    ]

    for pattern in medical_patterns:
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
    skipped_count = 0
    categories = {}

    # Process each key
    for key in list(data.keys()):
        # Skip metadata keys
        if key.startswith('@'):
            continue

        # Check if key should have medical review
        if not should_have_medical_review(key):
            skipped_count += 1
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
    print(f"Skipped (non-medical): {skipped_count}")
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
    print(f"Total tags added (per language): {ko_added}")
    print(f"Total MEDICAL REVIEW keys (per language): {ko_added + ko_existing}")
    print(f"\nExpected target: 415 keys")
    print(f"Current total: {ko_added + ko_existing}")
    if ko_added + ko_existing >= 415:
        print("✓ Target achieved!")
    else:
        print(f"Gap: {415 - (ko_added + ko_existing)} keys")

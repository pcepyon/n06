#!/usr/bin/env python3
"""
Generate detailed report of MEDICAL REVIEW tagged keys by pattern.
"""

import json
import re

def analyze_medical_review_keys(arb_file_path: str):
    """Analyze and categorize all MEDICAL REVIEW tagged keys."""

    with open(arb_file_path, 'r', encoding='utf-8') as f:
        data = json.loads(f.read())

    # Pattern categories from task requirements
    pattern_categories = {
        'Checkin - Feedback': r'^checkin_.*[Ff]eedback$',
        'Checkin - Questions': r'^checkin_.*[Qq]uestion$',
        'Checkin - Answers': r'^checkin_.*[Aa]nswer.*',
        'Checkin - Derived': r'^checkin_.*[Dd]erived.*',
        'Checkin - Greeting': r'^checkin_greeting_',
        'Checkin - Other': r'^checkin_',
        'Coping Guide': r'^coping_',
        'Tracking - Emergency': r'^tracking_emergency_',
        'Tracking - Symptom': r'^tracking_symptom',
        'Tracking - Red Flag': r'^tracking_redFlag_',
        'Tracking - Condition': r'^tracking_condition_',
        'Onboarding - Side Effects': r'^onboarding_sideEffects_',
        'Onboarding - Injection': r'^onboarding_injection_',
        'Onboarding - Evidence': r'^onboarding_evidence_',
        'Onboarding - How It Works': r'^onboarding_howItWorks_',
        'Onboarding - Food Noise': r'^onboarding_foodNoise_',
        'Onboarding - Not Your Fault': r'^onboarding_notYourFault_',
        'Records - Symptoms': r'^records_symptom_',
        'Dashboard - Health': r'^dashboard_(greeting_encouragement|progress_|checkin_)',
    }

    results = {}
    for category in pattern_categories:
        results[category] = []

    uncategorized = []

    # Check all keys
    for key in data.keys():
        if key.startswith('@'):
            continue

        # Check if has MEDICAL REVIEW tag
        metadata_key = f'@{key}'
        metadata = data.get(metadata_key, {})
        description = metadata.get('description', '')

        if 'MEDICAL REVIEW' not in description:
            continue

        # Categorize
        categorized = False
        for category, pattern in pattern_categories.items():
            if re.search(pattern, key):
                results[category].append(key)
                categorized = True
                break

        if not categorized:
            uncategorized.append(key)

    return results, uncategorized

if __name__ == '__main__':
    print("="*70)
    print("MEDICAL REVIEW TAGGED KEYS - DETAILED REPORT")
    print("="*70)

    results, uncategorized = analyze_medical_review_keys('lib/l10n/app_ko.arb')

    total_count = 0
    for category, keys in sorted(results.items()):
        if len(keys) > 0:
            print(f"\n{category}: {len(keys)} keys")
            total_count += len(keys)

    if uncategorized:
        print(f"\nUncategorized: {len(uncategorized)} keys")
        total_count += len(uncategorized)

    print("\n" + "="*70)
    print(f"TOTAL MEDICAL REVIEW KEYS: {total_count}")
    print("="*70)

    # Show breakdown by major feature
    print("\nBREAKDOWN BY FEATURE:")
    print("-" * 70)

    feature_totals = {}
    for category, keys in results.items():
        feature = category.split(' - ')[0]
        feature_totals[feature] = feature_totals.get(feature, 0) + len(keys)

    for feature, count in sorted(feature_totals.items(), key=lambda x: x[1], reverse=True):
        print(f"{feature:.<40} {count:>4} keys")

    print("-" * 70)
    print(f"{'TOTAL':.<40} {total_count:>4} keys")

#!/usr/bin/env python3
"""
Analyze implementation goals and identify required features.

This script helps break down what the user wants to build into
specific features that need documentation.
"""

import sys
import json
import argparse
from typing import List, Dict


def analyze_implementation(target: str, goal: str, features: List[str]) -> Dict:
    """
    Analyze implementation goal and suggest required features.
    
    Args:
        target: Library/framework/service name (e.g., "Next.js 15")
        goal: What user wants to build (e.g., "multilingual MDX blog")
        features: Initial feature list (e.g., ["i18n", "dynamic-routes"])
    
    Returns:
        Dictionary with analysis results
    """
    result = {
        "target": target,
        "goal": goal,
        "provided_features": features,
        "analysis": {}
    }
    
    # Feature categorization
    feature_categories = {
        "routing": ["i18n", "dynamic-routes", "parallel-routes", "intercepting-routes"],
        "data": ["server-actions", "data-fetching", "caching", "revalidation"],
        "ui": ["mdx", "styling", "fonts", "images", "metadata"],
        "auth": ["authentication", "authorization", "session", "middleware"],
        "api": ["route-handlers", "webhooks", "api-routes"],
    }
    
    # Categorize provided features
    categorized = {}
    for feature in features:
        for category, items in feature_categories.items():
            if feature.lower() in [item.lower() for item in items]:
                if category not in categorized:
                    categorized[category] = []
                categorized[category].append(feature)
    
    result["analysis"]["categorized_features"] = categorized
    result["analysis"]["total_features"] = len(features)
    
    # Suggest related features based on goal keywords
    suggestions = []
    goal_lower = goal.lower()
    
    if "blog" in goal_lower:
        suggestions.extend(["metadata", "seo", "rss"])
    if "multilingual" in goal_lower or "i18n" in goal_lower:
        suggestions.extend(["i18n", "locale-detection"])
    if "auth" in goal_lower or "login" in goal_lower:
        suggestions.extend(["authentication", "session", "middleware"])
    if "realtime" in goal_lower or "chat" in goal_lower:
        suggestions.extend(["websocket", "server-sent-events"])
    if "payment" in goal_lower:
        suggestions.extend(["webhook", "api-integration", "error-handling"])
    
    # Remove duplicates and already provided features
    suggestions = list(set(suggestions) - set([f.lower() for f in features]))
    result["analysis"]["suggested_features"] = suggestions
    
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Analyze implementation goals and identify required features"
    )
    parser.add_argument("--target", required=True, help="Target library/framework/service")
    parser.add_argument("--goal", required=True, help="Implementation goal description")
    parser.add_argument("--features", required=True, help="Comma-separated feature list")
    parser.add_argument("--output", help="Output JSON file path (optional)")
    
    args = parser.parse_args()
    
    features = [f.strip() for f in args.features.split(",")]
    result = analyze_implementation(args.target, args.goal, features)
    
    # Print results
    print("\n" + "="*60)
    print(f"📋 IMPLEMENTATION ANALYSIS")
    print("="*60)
    print(f"\n🎯 Target: {result['target']}")
    print(f"📝 Goal: {result['goal']}")
    print(f"\n✅ Provided Features ({len(features)}):")
    for feature in features:
        print(f"   - {feature}")
    
    if result["analysis"]["categorized_features"]:
        print(f"\n📦 Categorized:")
        for category, items in result["analysis"]["categorized_features"].items():
            print(f"   {category.upper()}: {', '.join(items)}")
    
    if result["analysis"]["suggested_features"]:
        print(f"\n💡 Suggested Additional Features:")
        for suggestion in result["analysis"]["suggested_features"]:
            print(f"   - {suggestion}")
    
    print("\n" + "="*60)
    
    # Save to file if requested
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(result, f, indent=2)
        print(f"\n💾 Results saved to: {args.output}")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())

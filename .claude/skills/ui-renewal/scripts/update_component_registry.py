#!/usr/bin/env python3
"""
Update Component Registry in all 3 locations:
1. Design System Component Registry table
2. registry.json
3. COMPONENTS.md

Usage:
    python update_component_registry.py --component ComponentName --framework flutter --used-in "screen-name"
"""

import argparse
import json
import re
from pathlib import Path
from datetime import datetime

def update_design_system_registry(design_system_path, component_info):
    """Update Design System Component Registry table"""
    with open(design_system_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find Component Registry section
    registry_pattern = r'(## 7\. Component Registry.*?\n\n.*?\n\|.*?\n\|.*?\n)(.*?)(\n\n---)'

    match = re.search(registry_pattern, content, re.DOTALL)
    if not match:
        print("❌ Component Registry section not found in Design System")
        return False

    header = match.group(1)
    existing_rows = match.group(2)
    footer = match.group(3)

    # Check if component already exists
    if component_info['name'] in existing_rows:
        print(f"⚠️  Component '{component_info['name']}' already in Design System Registry")
        # Update "Used In" column
        # TODO: Implement update logic
        return True

    # Add new row
    new_row = f"| {component_info['name']} | {component_info['date']} | {component_info['used_in']} | {component_info['description']} |\n"

    new_content = content.replace(
        match.group(0),
        header + existing_rows + new_row + footer
    )

    with open(design_system_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"✅ Updated Design System Component Registry: {design_system_path}")
    return True


def update_registry_json(registry_path, component_info):
    """Update registry.json"""
    if registry_path.exists():
        with open(registry_path, 'r', encoding='utf-8') as f:
            registry = json.load(f)
    else:
        registry = {
            "version": "1.0.0",
            "designSystem": "Gabium Design System v1.0",
            "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
            "components": [],
            "metadata": {
                "totalComponents": 0,
                "frameworks": [],
                "categories": []
            }
        }

    # Check if component exists
    existing = next((c for c in registry['components'] if c['name'] == component_info['name']), None)

    if existing:
        # Update "usedIn" list
        if component_info['used_in'] not in existing['usedIn']:
            existing['usedIn'].append(component_info['used_in'])
        print(f"⚠️  Component '{component_info['name']}' already in registry.json - updated 'usedIn'")
    else:
        # Add new component
        registry['components'].append(component_info)
        registry['metadata']['totalComponents'] = len(registry['components'])

        # Update frameworks
        if component_info['framework'] not in registry['metadata']['frameworks']:
            registry['metadata']['frameworks'].append(component_info['framework'])

        # Update categories
        if component_info['category'] not in registry['metadata']['categories']:
            registry['metadata']['categories'].append(component_info['category'])

    registry['lastUpdated'] = datetime.now().strftime("%Y-%m-%d")

    with open(registry_path, 'w', encoding='utf-8') as f:
        json.dump(registry, f, indent=2, ensure_ascii=False)

    print(f"✅ Updated registry.json: {registry_path}")
    return True


def update_components_md(components_md_path, component_info):
    """Update COMPONENTS.md Component Registry table"""
    with open(components_md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find Component Registry table
    registry_pattern = r'(## Component Registry\n\n\|.*?\n\|.*?\n)(.*?)(\n\n---)'

    match = re.search(registry_pattern, content, re.DOTALL)
    if not match:
        print("❌ Component Registry table not found in COMPONENTS.md")
        return False

    header = match.group(1)
    existing_rows = match.group(2)
    footer = match.group(3)

    # Check if component exists
    if component_info['name'] in existing_rows:
        print(f"⚠️  Component '{component_info['name']}' already in COMPONENTS.md")
        return True

    # Add new row
    new_row = f"| {component_info['name']} | {component_info['date']} | {component_info['used_in']} | {component_info['framework']} | `{component_info['file']}` | {component_info['description']} |\n"

    new_content = content.replace(
        match.group(0),
        header + existing_rows + new_row + footer
    )

    with open(components_md_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"✅ Updated COMPONENTS.md: {components_md_path}")
    return True


def main():
    parser = argparse.ArgumentParser(description='Update Component Registry in all 3 locations')
    parser.add_argument('--component', required=True, help='Component name')
    parser.add_argument('--framework', required=True, help='Framework (e.g., flutter, react)')
    parser.add_argument('--used-in', required=True, help='Screen/feature name')
    parser.add_argument('--category', default='Form', help='Component category')
    parser.add_argument('--description', default='', help='Component description')
    parser.add_argument('--file', help='Component file path (auto-generated if not provided)')
    parser.add_argument('--project-file', help='Project file path')

    args = parser.parse_args()

    # Determine file path
    if not args.file:
        ext = 'dart' if args.framework.lower() == 'flutter' else 'jsx'
        args.file = f"{args.framework}/{args.component}.{ext}"

    # Create component info
    component_info = {
        "name": args.component,
        "createdDate": datetime.now().strftime("%Y-%m-%d"),
        "date": datetime.now().strftime("%Y-%m-%d"),
        "framework": args.framework,
        "file": args.file,
        "projectFile": args.project_file or "",
        "usedIn": [args.used_in],
        "used_in": args.used_in,
        "category": args.category,
        "description": args.description or f"{args.component} component"
    }

    # Determine base path
    base_path = Path(__file__).parent.parent

    # Update all 3 locations
    print(f"\n🔄 Updating Component Registry for: {args.component}\n")

    # 1. Design System
    design_system_path = base_path / "design-systems" / "gabium-design-system.md"
    if design_system_path.exists():
        update_design_system_registry(design_system_path, component_info)
    else:
        print(f"⚠️  Design System not found: {design_system_path}")

    # 2. registry.json
    registry_path = base_path / "component-library" / "registry.json"
    update_registry_json(registry_path, component_info)

    # 3. COMPONENTS.md
    components_md_path = base_path / "component-library" / "COMPONENTS.md"
    if components_md_path.exists():
        update_components_md(components_md_path, component_info)
    else:
        print(f"⚠️  COMPONENTS.md not found: {components_md_path}")

    print(f"\n✅ Component Registry update complete!\n")


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Initialize a new implementation guide from template.

Creates a new guide document with proper structure and placeholders.
"""

import sys
import argparse
from pathlib import Path
from datetime import datetime


GUIDE_TYPES = {
    "framework": "framework-guide.md",
    "library": "library-guide.md",
    "service": "service-integration.md",
}


def init_guide(target: str, goal: str, guide_type: str, output_path: str, template_dir: str = None):
    """
    Initialize a new guide from template.
    
    Args:
        target: Target framework/library/service
        goal: Implementation goal
        guide_type: Type of guide (framework/library/service)
        output_path: Where to save the guide
        template_dir: Optional custom template directory
    """
    # Determine template path
    if template_dir:
        template_path = Path(template_dir) / GUIDE_TYPES[guide_type]
    else:
        # Assume templates are in ../assets/templates relative to this script
        script_dir = Path(__file__).parent
        template_path = script_dir.parent / "assets" / "templates" / GUIDE_TYPES[guide_type]
    
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    # Read template
    if template_path.exists():
        template_content = template_path.read_text(encoding='utf-8')
    else:
        # Fallback: create minimal template
        template_content = _create_minimal_template(guide_type)
    
    # Replace placeholders
    today = datetime.now().strftime("%Y-%m-%d")
    content = template_content.replace("{target}", target)
    content = content.replace("{goal}", goal)
    content = content.replace("{date}", today)
    
    # Write to output
    output_file.write_text(content, encoding='utf-8')
    
    print("\n" + "="*60)
    print("🚀 GUIDE INITIALIZED")
    print("="*60)
    print(f"\n📄 File: {output_file}")
    print(f"🎯 Target: {target}")
    print(f"📝 Goal: {goal}")
    print(f"📋 Type: {guide_type}")
    print(f"\n✅ Guide initialized successfully!")
    print("\nNext steps:")
    print("1. Fill in the TODO sections")
    print("2. Add code examples")
    print("3. Add testing checklist")
    print("4. Run validation:")
    print("   python ~/.claude/skills/implementation-guide-creator/scripts/validate_guide.py <path>")
    print("="*60 + "\n")


def _create_minimal_template(guide_type: str) -> str:
    """Create a minimal template if template file doesn't exist."""
    
    base_template = """# {goal} - {target} Guide

## Context
- **Goal:** {goal}
- **Target:** {target}
- **Last Updated:** {date}
- **Version:** TODO

## Installation

TODO: Add installation steps

```bash
# Installation command
```

## Configuration

TODO: Add configuration steps

## Implementation

### Feature 1: TODO

TODO: Describe and implement feature

```typescript
// TODO: Add code example
```

### Feature 2: TODO

TODO: Describe and implement feature

## Integration: Putting It All Together

TODO: Show how features work together

```typescript
// TODO: Complete working example
```

## Testing Checklist

- [ ] TODO: Add test item 1
- [ ] TODO: Add test item 2
- [ ] TODO: Add test item 3

## Common Issues

### Issue 1: TODO
**Symptom:** TODO
**Solution:** TODO

## References

- [Official Docs](TODO)
"""
    
    return base_template


def main():
    parser = argparse.ArgumentParser(
        description="Initialize a new implementation guide"
    )
    parser.add_argument("--target", required=True, 
                       help="Target framework/library/service")
    parser.add_argument("--goal", required=True,
                       help="Implementation goal")
    parser.add_argument("--type", required=True, choices=GUIDE_TYPES.keys(),
                       help="Guide type: framework, library, or service")
    parser.add_argument("--output", required=True,
                       help="Output file path")
    parser.add_argument("--template-dir", 
                       help="Custom template directory (optional)")
    
    args = parser.parse_args()
    
    init_guide(
        target=args.target,
        goal=args.goal,
        guide_type=args.type,
        output_path=args.output,
        template_dir=args.template_dir
    )
    
    return 0


if __name__ == "__main__":
    sys.exit(main())

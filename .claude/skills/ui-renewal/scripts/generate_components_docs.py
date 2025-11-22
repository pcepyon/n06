#!/usr/bin/env python3
"""
Component Registry Documentation Generator

이 스크립트는 Component Registry SSOT(Single Source of Truth) 패턴을 구현합니다.
registry.json을 유일한 진실의 원천(SSOT)으로 사용하여 다음 문서들을 자동 생성합니다:

1. component-library/COMPONENTS.md - 사람이 읽을 수 있는 상세 문서
2. Design System Section 7 - 디자인 시스템 아티팩트에 삽입할 컴포넌트 요약

사용 예시:
    # COMPONENTS.md 생성
    python scripts/generate_components_docs.py --output-components-md

    # Design System Section 7 생성
    python scripts/generate_components_docs.py --output-design-system-section

    # 둘 다 생성
    python scripts/generate_components_docs.py --output-components-md --output-design-system-section

원칙:
    - ✅ registry.json만 수동으로 편집
    - ❌ COMPONENTS.md를 수동으로 편집하지 않음 (자동 생성됨)
    - ❌ Design System Section 7을 직접 편집하지 않음 (생성된 파일에서 복사)

의존성:
    - Python 3.7+
    - 표준 라이브러리만 사용 (json, argparse, pathlib)
"""

import json
import argparse
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime


class ComponentDocsGenerator:
    """Component Registry에서 문서를 생성하는 클래스"""

    def __init__(self, registry_path: Path):
        """
        Args:
            registry_path: registry.json 파일 경로
        """
        self.registry_path = registry_path
        self.registry_data = self._load_registry()
        self.components = self.registry_data.get('components', [])
        self.metadata = self.registry_data.get('metadata', {})

    def _load_registry(self) -> Dict[str, Any]:
        """registry.json 로드"""
        if not self.registry_path.exists():
            raise FileNotFoundError(f"Registry not found: {self.registry_path}")

        with open(self.registry_path, 'r', encoding='utf-8') as f:
            return json.load(f)

    def generate_components_md(self, output_path: Path) -> None:
        """
        COMPONENTS.md 생성

        Args:
            output_path: 출력 파일 경로
        """
        content = self._build_components_md()

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"✅ Generated: {output_path}")

    def generate_design_system_section(self, output_path: Path) -> None:
        """
        Design System Section 7 생성

        Args:
            output_path: 출력 파일 경로
        """
        content = self._build_design_system_section()

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"✅ Generated: {output_path}")
        print(f"📝 Copy this section into your Design System artifact (Section 7)")

    def _build_components_md(self) -> str:
        """COMPONENTS.md 콘텐츠 빌드"""
        lines = []

        # 자동 생성 경고 헤더
        lines.append("<!-- ")
        lines.append("  ⚠️ AUTO-GENERATED FILE - DO NOT EDIT MANUALLY")
        lines.append("  ")
        lines.append("  This file is generated from component-library/registry.json")
        lines.append("  To update: Edit registry.json, then run:")
        lines.append("  ")
        lines.append("  python scripts/generate_components_docs.py --output-components-md")
        lines.append("-->")
        lines.append("")

        # 타이틀 및 소개
        lines.append("# Gabium UI Component Library")
        lines.append("")
        lines.append("This library contains reusable UI components extracted from the email signup screen redesign, following the Gabium Design System.")
        lines.append("")

        # Component Registry 테이블
        lines.append("## Component Registry")
        lines.append("")
        lines.append("| Component | Created Date | Used In | Framework | File Location | Notes |")
        lines.append("|-----------|--------------|---------|-----------|---------------|-------|")

        for comp in self.components:
            name = comp.get('name', 'N/A')
            created = comp.get('createdDate', 'N/A')
            used_in = ', '.join(comp.get('usedIn', [])[:2])  # 처음 2개만
            if len(comp.get('usedIn', [])) > 2:
                used_in += f" + {len(comp.get('usedIn', [])) - 2} more"
            framework = comp.get('framework', 'N/A')
            file_loc = comp.get('file', 'N/A')
            desc = comp.get('description', 'N/A')[:100]  # 100자 제한

            lines.append(f"| {name} | {created} | {used_in} | {framework} | `{file_loc}` | {desc} |")

        lines.append("")
        lines.append("---")
        lines.append("")

        # Component Specifications
        lines.append("## Component Specifications")
        lines.append("")

        for comp in self.components:
            lines.extend(self._build_component_spec(comp))
            lines.append("---")
            lines.append("")

        # Design System Reference
        lines.append("## Design System Reference")
        lines.append("")
        lines.append("All components follow the Gabium Design System tokens:")
        lines.append("")
        lines.append("**Colors:**")
        lines.append("- Primary: `#4ADE80`")
        lines.append("- Neutral-50: `#F8FAFC`")
        lines.append("- Neutral-200: `#E2E8F0`")
        lines.append("- Neutral-300: `#CBD5E1`")
        lines.append("- Neutral-400: `#94A3B8`")
        lines.append("- Neutral-500: `#64748B`")
        lines.append("- Neutral-600: `#475569`")
        lines.append("- Neutral-700: `#334155`")
        lines.append("- Neutral-800: `#1E293B`")
        lines.append("- Error: `#EF4444`")
        lines.append("- Warning: `#F59E0B`")
        lines.append("- Success: `#10B981`")
        lines.append("")
        lines.append("**Typography Scale:**")
        lines.append("- xs: 12px")
        lines.append("- sm: 14px")
        lines.append("- base: 16px")
        lines.append("- lg: 18px")
        lines.append("- xl: 20px")
        lines.append("- 2xl: 24px")
        lines.append("- 3xl: 28px")
        lines.append("")
        lines.append("**Font Weights:**")
        lines.append("- Regular: 400")
        lines.append("- Medium: 500")
        lines.append("- Semibold: 600")
        lines.append("- Bold: 700")
        lines.append("")
        lines.append("**Spacing Scale (8px-based):**")
        lines.append("- xs: 4px")
        lines.append("- sm: 8px")
        lines.append("- md: 16px")
        lines.append("- lg: 24px")
        lines.append("- xl: 32px")
        lines.append("- 2xl: 48px")
        lines.append("")
        lines.append("**Border Radius:**")
        lines.append("- sm: 8px")
        lines.append("- md: 12px")
        lines.append("- lg: 16px")
        lines.append("- full: 999px")
        lines.append("")
        lines.append("**Shadows:**")
        lines.append("- xs: 0 1px 2px rgba(15, 23, 42, 0.04)")
        lines.append("- sm: 0 2px 4px rgba(15, 23, 42, 0.06)")
        lines.append("- md: 0 4px 8px rgba(15, 23, 42, 0.08)")
        lines.append("- lg: 0 8px 16px rgba(15, 23, 42, 0.10)")
        lines.append("")
        lines.append("---")
        lines.append("")

        # Usage Guidelines
        lines.append("## Usage Guidelines")
        lines.append("")
        lines.append("### Import Components")
        lines.append("")
        lines.append("```dart")
        for comp in self.components:
            project_file = comp.get('projectFile', '')
            if project_file:
                lines.append(f"import 'package:n06/{project_file}';")
        lines.append("```")
        lines.append("")
        lines.append("### Consistency Checklist")
        lines.append("")
        lines.append("When using these components:")
        lines.append("- ✅ Use exact Design System tokens (no custom colors/spacing)")
        lines.append("- ✅ Follow accessibility guidelines (contrast, touch targets, keyboard nav)")
        lines.append("- ✅ Maintain component API (don't modify props without updating this registry)")
        lines.append("- ✅ Test all interactive states (default, hover, active, disabled, focus)")
        lines.append("- ✅ Ensure Korean text for all user-facing strings")
        lines.append("")
        lines.append("### Future Components")
        lines.append("")
        lines.append("Components planned for extraction:")
        lines.append("- **Secondary Button** (from future screens)")
        lines.append("- **Tertiary Button** (from future screens)")
        lines.append("- **Card Container** (reusable card wrapper)")
        lines.append("- **Form Section** (grouped form fields with title)")
        lines.append("- **Error Message** (standalone error display)")
        lines.append("")
        lines.append("---")
        lines.append("")

        # Maintenance
        last_updated = self.registry_data.get('lastUpdated', datetime.now().strftime('%Y-%m-%d'))
        total_comps = self.metadata.get('totalComponents', len(self.components))
        design_sys = self.registry_data.get('designSystem', 'Gabium Design System')

        lines.append("## Maintenance")
        lines.append("")
        lines.append(f"**Last Updated:** {last_updated}")
        lines.append(f"**Component Count:** {total_comps} Flutter components")
        lines.append(f"**Design System Version:** {design_sys}")
        lines.append("")
        lines.append("For questions or updates, refer to:")
        lines.append("- Implementation Guide: `.claude/skills/ui-renewal/implementation-guides/email-signup-screen-implementation-guide.md`")
        lines.append("- Design System: `.claude/skills/ui-renewal/design-system/gabium-design-system.md`")
        lines.append("- Improvement Proposal: `.claude/skills/ui-renewal/proposals/email-signup-screen-improvement-proposal.md`")
        lines.append("")

        return '\n'.join(lines)

    def _build_component_spec(self, comp: Dict[str, Any]) -> List[str]:
        """개별 컴포넌트 사양 빌드"""
        lines = []

        name = comp.get('name', 'Unknown')
        description = comp.get('description', 'No description')
        props = comp.get('props', {})
        tokens = comp.get('designTokens', {})

        lines.append(f"### {name}")
        lines.append("")
        lines.append(f"**Purpose:** {description}")
        lines.append("")

        # Design Tokens
        if tokens:
            lines.append("**Design Tokens:**")
            for key, value in tokens.items():
                formatted_key = key.replace('_', ' ').title()
                lines.append(f"- {formatted_key}: {value}")
            lines.append("")

        # Props
        if props:
            lines.append("**Props:**")
            lines.append("```dart")
            lines.append(f"{name}({{")
            for prop_name, prop_type in props.items():
                lines.append(f"  {prop_type} {prop_name},")
            lines.append("})")
            lines.append("```")
            lines.append("")

        # Usage Example (generic)
        lines.append("**Usage Example:**")
        lines.append("```dart")
        lines.append(f"{name}(")
        lines.append("  // Set required properties")
        lines.append(")")
        lines.append("```")
        lines.append("")

        return lines

    def _build_design_system_section(self) -> str:
        """Design System Section 7 콘텐츠 빌드"""
        lines = []

        lines.append("# Section 7: Component Library")
        lines.append("")
        lines.append("## 7.1 Overview")
        lines.append("")
        lines.append(f"Total Components: {self.metadata.get('totalComponents', len(self.components))}")
        lines.append(f"Frameworks: {', '.join(self.metadata.get('frameworks', ['Flutter']))}")
        lines.append(f"Categories: {', '.join(self.metadata.get('categories', []))}")
        lines.append("")
        lines.append("## 7.2 Component Registry")
        lines.append("")

        # 카테고리별로 그룹핑
        by_category = {}
        for comp in self.components:
            category = comp.get('category', 'Uncategorized')
            if category not in by_category:
                by_category[category] = []
            by_category[category].append(comp)

        for category, comps in sorted(by_category.items()):
            lines.append(f"### {category}")
            lines.append("")

            for comp in comps:
                name = comp.get('name', 'Unknown')
                desc = comp.get('description', 'No description')
                lines.append(f"**{name}**")
                lines.append(f"- Description: {desc}")
                lines.append(f"- File: `{comp.get('file', 'N/A')}`")
                lines.append(f"- Used in: {', '.join(comp.get('usedIn', ['N/A'])[:3])}")
                lines.append("")

        lines.append("---")
        lines.append("")
        lines.append("## 7.3 Usage Notes")
        lines.append("")
        lines.append("- All components follow Gabium Design System tokens")
        lines.append("- Accessibility standards: WCAG 2.1 AA compliance")
        lines.append("- Touch targets: Minimum 44x44px")
        lines.append("- Color contrast: Minimum 4.5:1 for normal text, 3:1 for large text")
        lines.append("")
        lines.append("For detailed component specifications, see:")
        lines.append("`component-library/COMPONENTS.md`")
        lines.append("")

        return '\n'.join(lines)


def main():
    """메인 실행 함수"""
    parser = argparse.ArgumentParser(
        description='Generate component documentation from registry.json (SSOT)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate COMPONENTS.md
  python scripts/generate_components_docs.py --output-components-md

  # Generate Design System Section 7
  python scripts/generate_components_docs.py --output-design-system-section

  # Generate both
  python scripts/generate_components_docs.py --output-components-md --output-design-system-section

IMPORTANT:
  - registry.json is the Single Source of Truth (SSOT)
  - ONLY edit registry.json manually or via scripts
  - DO NOT edit generated files (COMPONENTS.md, design-system-section-7.md) directly
        """
    )

    parser.add_argument(
        '--registry',
        type=Path,
        default=Path('.claude/skills/ui-renewal/component-library/registry.json'),
        help='Path to registry.json (default: .claude/skills/ui-renewal/component-library/registry.json)'
    )

    parser.add_argument(
        '--output-components-md',
        action='store_true',
        help='Generate COMPONENTS.md'
    )

    parser.add_argument(
        '--output-design-system-section',
        action='store_true',
        help='Generate Design System Section 7'
    )

    args = parser.parse_args()

    # 최소 하나의 출력 옵션 필요
    if not args.output_components_md and not args.output_design_system_section:
        parser.error('At least one output option is required (--output-components-md or --output-design-system-section)')

    # 프로젝트 루트 찾기
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent.parent.parent

    # registry.json 경로 (절대 경로 또는 상대 경로)
    if args.registry.is_absolute():
        registry_path = args.registry
    else:
        registry_path = project_root / args.registry

    # Generator 초기화
    try:
        generator = ComponentDocsGenerator(registry_path)
    except FileNotFoundError as e:
        print(f"❌ Error: {e}")
        return 1
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing registry.json: {e}")
        return 1

    # COMPONENTS.md 생성
    if args.output_components_md:
        components_md_path = registry_path.parent / 'COMPONENTS.md'
        try:
            generator.generate_components_md(components_md_path)
        except Exception as e:
            print(f"❌ Error generating COMPONENTS.md: {e}")
            return 1

    # Design System Section 7 생성
    if args.output_design_system_section:
        design_section_path = registry_path.parent / 'design-system-section-7.md'
        try:
            generator.generate_design_system_section(design_section_path)
        except Exception as e:
            print(f"❌ Error generating Design System Section 7: {e}")
            return 1

    print("")
    print("✅ All documentation generated successfully!")
    print("")
    print("Next steps:")
    print("1. Review generated files")
    print("2. If needed, copy design-system-section-7.md into your Design System artifact")
    print("3. Commit changes to version control")

    return 0


if __name__ == '__main__':
    exit(main())

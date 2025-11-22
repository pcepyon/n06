#!/usr/bin/env python3
"""
Generate projects/INDEX.md from all metadata.json files

Usage:
    python generate_project_index.py
"""

import json
from pathlib import Path
from datetime import datetime

def load_metadata(project_dir):
    """Load metadata.json from project directory"""
    metadata_path = project_dir / "metadata.json"
    if not metadata_path.exists():
        return None

    with open(metadata_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

        # Backward compatibility: use 'phase' if 'current_phase' missing
        if 'current_phase' not in data and 'phase' in data:
            data['current_phase'] = data['phase']

        return data


def generate_index():
    """Generate INDEX.md from all projects"""
    base_path = Path(__file__).parent.parent
    projects_path = base_path / "projects"

    if not projects_path.exists():
        print("❌ projects/ directory not found")
        return

    # Collect all projects
    completed_projects = []
    planned_projects = []

    for project_dir in sorted(projects_path.iterdir()):
        if not project_dir.is_dir() or project_dir.name == '.git':
            continue

        metadata = load_metadata(project_dir)
        if not metadata:
            continue

        if metadata.get('status') == 'completed':
            completed_projects.append((project_dir.name, metadata))
        else:
            planned_projects.append((project_dir.name, metadata))

    # Generate INDEX.md content
    index_content = f"""# UI Renewal Projects Index

**Last Updated**: {datetime.now().strftime("%Y-%m-%d")}

---

## Active Projects

| Screen/Feature | Framework | Status | Last Updated | Documents | Components |
|---------------|-----------|--------|--------------|-----------|------------|
"""

    for project_name, metadata in completed_projects:
        # Build documents links from versions
        doc_links = []
        versions = metadata.get('versions', {})

        if 'proposal' in versions:
            doc_links.append(f"[Proposal]({project_name}/<date>-proposal-v{versions['proposal']}.md)")
        if 'implementation' in versions:
            doc_links.append(f"[Implementation]({project_name}/<date>-implementation-v{versions['implementation']}.md)")
        if 'implementation_log' in versions:
            doc_links.append(f"[Log]({project_name}/<date>-implementation-log-v{versions['implementation_log']}.md)")
        if 'verification' in versions:
            doc_links.append(f"[Verification]({project_name}/<date>-verification-v{versions['verification']}.md)")

        docs_str = ", ".join(doc_links) if doc_links else "No docs"

        # Build components list (support both old 'components' and new 'components_created')
        components = metadata.get('components_created', metadata.get('components', []))
        components_str = f"{len(components)} ({', '.join(components[:3])}{'...' if len(components) > 3 else ''})" if components else "0"

        # Get retry count if > 0
        retry_count = metadata.get('retry_count', 0)
        retry_indicator = f" (retry: {retry_count})" if retry_count > 0 else ""

        # Status display
        status = metadata.get('status', 'Unknown')
        status_emoji = "✅" if status == 'completed' else "❌" if status == 'failed' else "🔄"
        status_str = f"{status_emoji} {status.title()}{retry_indicator}"

        # Handle both old 'screenName' and new 'project_name'
        project_display = metadata.get('project_name', metadata.get('screenName', project_name)).replace('-', ' ').title()

        # Last updated
        last_updated = metadata.get('last_updated', metadata.get('lastUpdated', 'N/A'))

        index_content += f"| {project_display} | {metadata.get('framework', 'Unknown')} | {status_str} | {last_updated} | {docs_str} | {components_str} |\n"

    index_content += """
---

## Planned Projects

| Screen/Feature | Priority | Framework | Notes | Reusable Components |
|---------------|----------|-----------|-------|---------------------|
| Password Reset Screen | High | Flutter | 기존 컴포넌트 재사용 가능 | AuthHeroSection, GabiumTextField, GabiumButton, GabiumToast |
| Onboarding Screen | Medium | Flutter | 새로운 컴포넌트 필요 가능성 | GabiumButton, GabiumTextField |
| Home Dashboard | High | Flutter | 데이터 시각화 컴포넌트 신규 필요 | - |

---

## Summary Statistics

- **Total Completed Projects**: {len(completed_projects)}
- **Total Frameworks**: {len(set(m.get('framework', 'Unknown') for _, m in completed_projects))}
- **Design System Version**: Gabium Design System v1.0
- **Projects with Retries**: {sum(1 for _, m in completed_projects if m.get('retry_count', 0) > 0)}
- **Failed Projects**: {sum(1 for _, m in completed_projects if m.get('status') == 'failed')}

---

## Component Reusability Matrix

"""

    # Build component reusability matrix
    component_usage = {}
    for project_name, metadata in completed_projects:
        # Support both old 'components' and new 'components_created'
        components = metadata.get('components_created', metadata.get('components', []))
        for component in components:
            if component not in component_usage:
                component_usage[component] = {
                    'created_in': project_name,
                    'used_in': []
                }
            component_usage[component]['used_in'].append(project_name)

    if component_usage:
        index_content += "| Component | Created In | Also Used In | Reuse Count |\n"
        index_content += "|-----------|-----------|--------------|-------------|\n"

        for component, usage in sorted(component_usage.items()):
            created_in = usage['created_in'].replace('-', ' ').title()
            used_in = usage['used_in']
            also_used = [p.replace('-', ' ').title() for p in used_in if p != usage['created_in']]
            reuse_count = len(used_in)

            index_content += f"| {component} | {created_in} | {', '.join(also_used) or '-'} | {reuse_count} |\n"

    index_content += """
---

## Next Steps

1. **Continue UI Renewal**: Start Phase 2A for next screen
2. **Expand Component Library**: Create new components as needed
3. **Update Design System**: Add new patterns/tokens as project evolves
4. **Export Design Tokens**: Generate Flutter ThemeData, JSON, CSS for development

---

**For New Projects**:
1. Create new directory under `projects/`
2. Start with Phase 2A (Analysis)
3. Follow document naming convention: `{YYYYMMDD}-{type}-v{N}.md`
4. Update this INDEX.md when project completes
"""

    # Write INDEX.md
    index_path = projects_path / "INDEX.md"
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(index_content)

    print(f"✅ Generated INDEX.md: {index_path}")
    print(f"   - {len(completed_projects)} completed projects")
    print(f"   - {len(component_usage)} unique components")


if __name__ == '__main__':
    generate_index()

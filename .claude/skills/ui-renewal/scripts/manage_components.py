#!/usr/bin/env python3
"""
Component Library Manager

Manages reusable UI components created during Phase 2B.
Saves component code to organized library structure for future reuse.

Usage:
    python manage_components.py add <component-name> <framework> <code-file>
    python manage_components.py list [framework]
    python manage_components.py get <component-name> [framework]
"""

import os
import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional


class ComponentLibrary:
    """Manages UI component library."""
    
    def __init__(self, library_path: str = "./component-library"):
        self.library_path = Path(library_path)
        self.registry_file = self.library_path / "registry.json"
        self._ensure_structure()
    
    def _ensure_structure(self):
        """Create library directory structure if not exists."""
        # Main directories
        (self.library_path / "components").mkdir(parents=True, exist_ok=True)
        (self.library_path / "react").mkdir(parents=True, exist_ok=True)
        (self.library_path / "flutter").mkdir(parents=True, exist_ok=True)
        (self.library_path / "vue").mkdir(parents=True, exist_ok=True)
        
        # Create registry if not exists
        if not self.registry_file.exists():
            self._save_registry({
                "version": "1.0",
                "components": {}
            })
    
    def _load_registry(self) -> Dict:
        """Load component registry."""
        with open(self.registry_file, 'r') as f:
            return json.load(f)
    
    def _save_registry(self, registry: Dict):
        """Save component registry."""
        with open(self.registry_file, 'w') as f:
            json.dump(registry, f, indent=2, ensure_ascii=False)
    
    def add_component(self, name: str, framework: str, code: str, 
                     specs: Dict, used_in: str = "", notes: str = ""):
        """
        Add a component to the library.
        
        Args:
            name: Component name (e.g., "PrimaryButton", "LoginForm")
            framework: Framework (react, flutter, vue)
            code: Component code
            specs: Component specifications (dict with tokens, props, etc.)
            used_in: Where this component is used
            notes: Additional notes
        """
        framework = framework.lower()
        registry = self._load_registry()
        
        # Create component entry if not exists
        if name not in registry["components"]:
            registry["components"][name] = {
                "created": datetime.now().isoformat(),
                "frameworks": {},
                "specs": specs,
                "used_in": [],
                "notes": notes
            }
        
        component = registry["components"][name]
        
        # Add framework implementation
        file_ext = {
            "react": "jsx",
            "flutter": "dart",
            "vue": "vue"
        }.get(framework, "txt")
        
        filename = f"{name}.{file_ext}"
        filepath = self.library_path / framework / filename
        
        # Save code file
        with open(filepath, 'w') as f:
            f.write(code)
        
        # Update registry
        component["frameworks"][framework] = {
            "file": str(filepath.relative_to(self.library_path)),
            "updated": datetime.now().isoformat()
        }
        
        if used_in and used_in not in component["used_in"]:
            component["used_in"].append(used_in)
        
        self._save_registry(registry)
        
        print(f"✅ Added {name} ({framework}) to library")
        print(f"   File: {filepath}")
    
    def get_component(self, name: str, framework: Optional[str] = None) -> Dict:
        """
        Get component information.
        
        Args:
            name: Component name
            framework: Optional framework filter
            
        Returns:
            Component information dict
        """
        registry = self._load_registry()
        
        if name not in registry["components"]:
            return None
        
        component = registry["components"][name]
        
        if framework:
            framework = framework.lower()
            if framework not in component["frameworks"]:
                return None
            
            # Read code file
            file_path = self.library_path / component["frameworks"][framework]["file"]
            with open(file_path, 'r') as f:
                code = f.read()
            
            return {
                "name": name,
                "framework": framework,
                "code": code,
                "specs": component["specs"],
                "used_in": component["used_in"],
                "notes": component["notes"]
            }
        
        return {
            "name": name,
            "frameworks": list(component["frameworks"].keys()),
            "specs": component["specs"],
            "used_in": component["used_in"],
            "notes": component["notes"]
        }
    
    def list_components(self, framework: Optional[str] = None) -> List[Dict]:
        """
        List all components.
        
        Args:
            framework: Optional framework filter
            
        Returns:
            List of component summaries
        """
        registry = self._load_registry()
        components = []
        
        for name, data in registry["components"].items():
            if framework:
                framework = framework.lower()
                if framework not in data["frameworks"]:
                    continue
            
            components.append({
                "name": name,
                "frameworks": list(data["frameworks"].keys()),
                "used_in": data["used_in"],
                "created": data["created"]
            })
        
        return components
    
    def export_registry_markdown(self, output_file: str = "COMPONENTS.md"):
        """Export component registry as markdown documentation."""
        registry = self._load_registry()
        output_path = self.library_path / output_file
        
        lines = [
            "# Component Library",
            "",
            f"**Version:** {registry['version']}  ",
            f"**Total Components:** {len(registry['components'])}",
            "",
            "---",
            ""
        ]
        
        for name, data in sorted(registry["components"].items()):
            lines.append(f"## {name}")
            lines.append("")
            lines.append(f"**Created:** {data['created']}")
            lines.append(f"**Frameworks:** {', '.join(data['frameworks'].keys())}")
            lines.append(f"**Used In:** {', '.join(data['used_in']) if data['used_in'] else 'N/A'}")
            
            if data.get("notes"):
                lines.append(f"**Notes:** {data['notes']}")
            
            lines.append("")
            lines.append("### Specifications")
            lines.append("```json")
            lines.append(json.dumps(data["specs"], indent=2))
            lines.append("```")
            lines.append("")
            
            for fw, fw_data in data["frameworks"].items():
                lines.append(f"### {fw.capitalize()} Implementation")
                lines.append(f"**File:** `{fw_data['file']}`  ")
                lines.append(f"**Updated:** {fw_data['updated']}")
                lines.append("")
            
            lines.append("---")
            lines.append("")
        
        with open(output_path, 'w') as f:
            f.write('\n'.join(lines))
        
        print(f"✅ Exported registry to {output_path}")


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python manage_components.py add <name> <framework> <code-file> [used-in] [notes]")
        print("  python manage_components.py list [framework]")
        print("  python manage_components.py get <name> [framework]")
        print("  python manage_components.py export")
        sys.exit(1)
    
    library = ComponentLibrary()
    command = sys.argv[1].lower()
    
    if command == "add":
        if len(sys.argv) < 5:
            print("❌ Error: add requires <name> <framework> <code-file>")
            sys.exit(1)
        
        name = sys.argv[2]
        framework = sys.argv[3]
        code_file = sys.argv[4]
        used_in = sys.argv[5] if len(sys.argv) > 5 else ""
        notes = sys.argv[6] if len(sys.argv) > 6 else ""
        
        if not os.path.exists(code_file):
            print(f"❌ Error: File not found: {code_file}")
            sys.exit(1)
        
        with open(code_file, 'r') as f:
            code = f.read()
        
        # Extract basic specs from code (simple extraction)
        specs = {
            "type": "component",
            "framework": framework
        }
        
        library.add_component(name, framework, code, specs, used_in, notes)
    
    elif command == "list":
        framework = sys.argv[2] if len(sys.argv) > 2 else None
        components = library.list_components(framework)
        
        if not components:
            print("No components found.")
            return
        
        print(f"\n📦 Component Library ({len(components)} components)")
        print("-" * 60)
        
        for comp in components:
            print(f"\n{comp['name']}")
            print(f"  Frameworks: {', '.join(comp['frameworks'])}")
            print(f"  Used in: {', '.join(comp['used_in']) if comp['used_in'] else 'N/A'}")
            print(f"  Created: {comp['created']}")
    
    elif command == "get":
        if len(sys.argv) < 3:
            print("❌ Error: get requires <name>")
            sys.exit(1)
        
        name = sys.argv[2]
        framework = sys.argv[3] if len(sys.argv) > 3 else None
        
        component = library.get_component(name, framework)
        
        if not component:
            print(f"❌ Component not found: {name}")
            sys.exit(1)
        
        if framework:
            print(f"\n📦 {component['name']} ({component['framework']})")
            print("-" * 60)
            print("\nCode:")
            print(component['code'])
            print("\nSpecifications:")
            print(json.dumps(component['specs'], indent=2))
        else:
            print(f"\n📦 {component['name']}")
            print("-" * 60)
            print(f"Frameworks: {', '.join(component['frameworks'])}")
            print(f"Used in: {', '.join(component['used_in']) if component['used_in'] else 'N/A'}")
            print("\nSpecifications:")
            print(json.dumps(component['specs'], indent=2))
    
    elif command == "export":
        library.export_registry_markdown()
    
    else:
        print(f"❌ Unknown command: {command}")
        sys.exit(1)


if __name__ == '__main__':
    main()

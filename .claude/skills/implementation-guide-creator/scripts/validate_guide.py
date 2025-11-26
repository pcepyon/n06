#!/usr/bin/env python3
"""
Validate implementation guide completeness.

Checks that guide includes all essential sections and information.
"""

import sys
import argparse
import re
from pathlib import Path
from typing import List, Tuple


class GuideValidator:
    """Validates implementation guide documents."""
    
    REQUIRED_SECTIONS = [
        "Context",
        "Installation",
        "Configuration",
        "Implementation",
        "Testing Checklist",
    ]
    
    REQUIRED_ELEMENTS = {
        "goal": r"(?i)(goal|목표)\s*[:：]",
        "stack": r"(?i)(stack|기술스택)\s*[:：]",
        "version": r"(?i)(version|버전)\s*[:：]",
        "last_updated": r"(?i)(last updated|업데이트)\s*[:：]",
    }
    
    def __init__(self, file_path: str):
        self.file_path = Path(file_path)
        self.content = ""
        self.errors = []
        self.warnings = []
        
    def validate(self) -> bool:
        """Run all validations. Returns True if valid."""
        if not self._load_file():
            return False
            
        self._check_required_sections()
        self._check_context_elements()
        self._check_code_examples()
        self._check_links()
        self._check_checklist()
        
        return len(self.errors) == 0
    
    def _load_file(self) -> bool:
        """Load and read the guide file."""
        if not self.file_path.exists():
            self.errors.append(f"File not found: {self.file_path}")
            return False
        
        try:
            self.content = self.file_path.read_text(encoding='utf-8')
            return True
        except Exception as e:
            self.errors.append(f"Failed to read file: {e}")
            return False
    
    def _check_required_sections(self):
        """Check for required sections."""
        for section in self.REQUIRED_SECTIONS:
            # Match both markdown headers (# ## ###) and plain text
            pattern = rf"(?i)(?:^#+\s*{re.escape(section)}|^{re.escape(section)}\s*$)"
            if not re.search(pattern, self.content, re.MULTILINE):
                self.errors.append(f"Missing required section: {section}")
    
    def _check_context_elements(self):
        """Check for required context elements."""
        for element, pattern in self.REQUIRED_ELEMENTS.items():
            if not re.search(pattern, self.content):
                self.errors.append(f"Missing context element: {element}")
    
    def _check_code_examples(self):
        """Check for code examples."""
        code_blocks = re.findall(r"```[\s\S]*?```", self.content)
        
        if len(code_blocks) < 2:
            self.errors.append(
                f"Insufficient code examples (found {len(code_blocks)}, need at least 2)"
            )
        
        # Check for integration example
        if not re.search(r"(?i)(integration|putting it together|통합)", self.content):
            self.warnings.append("No integration section found")
    
    def _check_links(self):
        """Check for reference links."""
        # Find markdown links
        links = re.findall(r'\[([^\]]+)\]\(([^\)]+)\)', self.content)
        
        if len(links) == 0:
            self.warnings.append("No reference links found (consider adding official docs)")
        
        # Check for official docs link
        has_official = any(
            "official" in text.lower() or "공식" in text.lower() 
            for text, url in links
        )
        if not has_official and len(links) > 0:
            self.warnings.append("No official documentation link found")
    
    def _check_checklist(self):
        """Check for testing checklist items."""
        checklist_items = re.findall(r'- \[[ x]\]', self.content)
        
        if len(checklist_items) < 3:
            self.errors.append(
                f"Testing checklist too short (found {len(checklist_items)} items, need at least 3)"
            )
    
    def print_report(self):
        """Print validation report."""
        print("\n" + "="*60)
        print("📋 GUIDE VALIDATION REPORT")
        print("="*60)
        print(f"\n📄 File: {self.file_path}")
        
        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for i, error in enumerate(self.errors, 1):
                print(f"   {i}. {error}")
        
        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for i, warning in enumerate(self.warnings, 1):
                print(f"   {i}. {warning}")
        
        if not self.errors and not self.warnings:
            print("\n✅ All checks passed! Guide is valid.")
        elif not self.errors:
            print("\n✅ No critical errors. Review warnings if applicable.")
        else:
            print(f"\n❌ Validation failed with {len(self.errors)} error(s).")
        
        print("="*60 + "\n")


def main():
    parser = argparse.ArgumentParser(
        description="Validate implementation guide completeness"
    )
    parser.add_argument("guide_path", help="Path to guide markdown file")
    parser.add_argument("--strict", action="store_true", 
                       help="Treat warnings as errors")
    
    args = parser.parse_args()
    
    validator = GuideValidator(args.guide_path)
    is_valid = validator.validate()
    validator.print_report()
    
    # Exit with error code if validation failed
    if not is_valid or (args.strict and validator.warnings):
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())

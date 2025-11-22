#!/usr/bin/env python3
"""
Design Token Export Script

Converts Design System markdown document to various formats:
- JSON (universal format)
- CSS Variables
- Tailwind Config
- Flutter Theme

Usage:
    python export_design_tokens.py <design-system.md> --format <json|css|tailwind|flutter>
"""

import re
import json
import sys
from pathlib import Path
from typing import Dict, List, Any


def parse_color_table(section: str) -> Dict[str, str]:
    """Parse markdown table with color definitions."""
    colors = {}
    # Match table rows: | 50 | #FAFAFA | ... |
    pattern = r'\|\s*(\w+)\s*\|\s*(#[0-9A-Fa-f]{6})\s*\|'
    matches = re.findall(pattern, section)
    for name, hex_value in matches:
        colors[name] = hex_value
    return colors


def parse_simple_colors(section: str) -> Dict[str, str]:
    """Parse simple color definitions like **Color:** `#000000`"""
    colors = {}
    # Match: **Color:** `#HEX` or - **Color:** `#HEX`
    pattern = r'(?:\*\*|-)?\s*\*\*Color:\*\*\s*`(#[0-9A-Fa-f]{6})`'
    matches = re.findall(pattern, section)
    return matches[0] if matches else None


def parse_typography_table(section: str) -> Dict[str, Dict[str, str]]:
    """Parse typography scale table."""
    typography = {}
    # Match table rows
    lines = section.split('\n')
    for line in lines:
        if '|' in line and not line.strip().startswith('|---'):
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 5 and parts[1] and parts[1] not in ['Name', '']:
                name = parts[1]
                typography[name] = {
                    'size': parts[2],
                    'weight': parts[3],
                    'lineHeight': parts[4]
                }
    return typography


def parse_spacing_table(section: str) -> Dict[str, str]:
    """Parse spacing scale table."""
    spacing = {}
    pattern = r'\|\s*(\w+)\s*\|\s*(\d+px)\s*\|'
    matches = re.findall(pattern, section)
    for name, value in matches:
        spacing[name] = value
    return spacing


def extract_design_tokens(md_content: str) -> Dict[str, Any]:
    """Extract design tokens from Design System markdown."""
    tokens = {
        'colors': {},
        'typography': {},
        'spacing': {},
        'borderRadius': {},
        'shadows': {}
    }
    
    # Extract colors
    # Neutral scale
    neutral_section = re.search(r'### Neutral Scale\s+(.*?)(?=###|\Z)', md_content, re.DOTALL)
    if neutral_section:
        tokens['colors']['neutral'] = parse_color_table(neutral_section.group(1))
    
    # Brand colors
    primary_match = re.search(r'#### Primary.*?- \*\*Color:\*\* `(#[0-9A-Fa-f]{6})`', md_content, re.DOTALL)
    if primary_match:
        tokens['colors']['primary'] = primary_match.group(1)
    
    secondary_match = re.search(r'#### Secondary.*?- \*\*Color:\*\* `(#[0-9A-Fa-f]{6})`', md_content, re.DOTALL)
    if secondary_match:
        tokens['colors']['secondary'] = secondary_match.group(1)
    
    # Semantic colors
    for semantic in ['Success', 'Error', 'Warning', 'Info']:
        pattern = f'#### {semantic}.*?- \\*\\*Color:\\*\\* `(#[0-9A-Fa-f]{{6}})`'
        match = re.search(pattern, md_content, re.DOTALL)
        if match:
            tokens['colors'][semantic.lower()] = match.group(1)
    
    # Typography
    typo_section = re.search(r'### Type Scale\s+(.*?)(?=###|\Z)', md_content, re.DOTALL)
    if typo_section:
        tokens['typography'] = parse_typography_table(typo_section.group(1))
    
    # Font family
    font_match = re.search(r'- \*\*Primary:\*\* ([^,\n]+)', md_content)
    if font_match:
        tokens['typography']['fontFamily'] = font_match.group(1).strip()
    
    # Spacing
    spacing_section = re.search(r'### Spacing Scale.*?\n\|(.*?)(?=###|\Z)', md_content, re.DOTALL)
    if spacing_section:
        tokens['spacing'] = parse_spacing_table(spacing_section.group(0))
    
    # Border radius
    radius_section = re.search(r'### Border Radius.*?\n\|(.*?)(?=###|\Z)', md_content, re.DOTALL)
    if radius_section:
        tokens['borderRadius'] = parse_spacing_table(radius_section.group(0))
    
    # Shadows
    shadow_section = re.search(r'### Shadow Levels.*?\n\|(.*?)(?=###|\Z)', md_content, re.DOTALL)
    if shadow_section:
        lines = shadow_section.group(0).split('\n')
        for line in lines:
            if '|' in line and not line.strip().startswith('|---'):
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 3 and parts[1] and parts[1] not in ['Level', '']:
                    tokens['shadows'][parts[1]] = parts[2]
    
    return tokens


def export_to_json(tokens: Dict[str, Any], output_path: Path):
    """Export tokens to JSON format."""
    with open(output_path, 'w') as f:
        json.dump(tokens, f, indent=2)
    print(f"✅ Exported to JSON: {output_path}")


def export_to_css(tokens: Dict[str, Any], output_path: Path):
    """Export tokens to CSS Variables."""
    css_lines = [":root {"]
    
    # Colors
    if 'primary' in tokens['colors']:
        css_lines.append(f"  --color-primary: {tokens['colors']['primary']};")
    if 'secondary' in tokens['colors']:
        css_lines.append(f"  --color-secondary: {tokens['colors']['secondary']};")
    
    for semantic in ['success', 'error', 'warning', 'info']:
        if semantic in tokens['colors']:
            css_lines.append(f"  --color-{semantic}: {tokens['colors'][semantic]};")
    
    if 'neutral' in tokens['colors']:
        for level, color in tokens['colors']['neutral'].items():
            css_lines.append(f"  --color-neutral-{level}: {color};")
    
    # Typography
    if 'fontFamily' in tokens['typography']:
        css_lines.append(f"  --font-family: {tokens['typography']['fontFamily']};")
    
    for name, values in tokens['typography'].items():
        if name != 'fontFamily' and isinstance(values, dict):
            css_lines.append(f"  --font-size-{name}: {values.get('size', '')};")
            css_lines.append(f"  --font-weight-{name}: {values.get('weight', '')};")
            css_lines.append(f"  --line-height-{name}: {values.get('lineHeight', '')};")
    
    # Spacing
    for name, value in tokens['spacing'].items():
        css_lines.append(f"  --spacing-{name}: {value};")
    
    # Border radius
    for name, value in tokens['borderRadius'].items():
        css_lines.append(f"  --radius-{name}: {value};")
    
    # Shadows
    for name, value in tokens['shadows'].items():
        css_lines.append(f"  --shadow-{name}: {value};")
    
    css_lines.append("}")
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(css_lines))
    
    print(f"✅ Exported to CSS: {output_path}")


def export_to_tailwind(tokens: Dict[str, Any], output_path: Path):
    """Export tokens to Tailwind config format."""
    config = {
        "theme": {
            "extend": {
                "colors": {},
                "fontSize": {},
                "spacing": {},
                "borderRadius": {},
                "boxShadow": {}
            }
        }
    }
    
    # Colors
    if 'primary' in tokens['colors']:
        config['theme']['extend']['colors']['primary'] = tokens['colors']['primary']
    if 'secondary' in tokens['colors']:
        config['theme']['extend']['colors']['secondary'] = tokens['colors']['secondary']
    
    for semantic in ['success', 'error', 'warning', 'info']:
        if semantic in tokens['colors']:
            config['theme']['extend']['colors'][semantic] = tokens['colors'][semantic]
    
    if 'neutral' in tokens['colors']:
        config['theme']['extend']['colors']['neutral'] = tokens['colors']['neutral']
    
    # Typography
    for name, values in tokens['typography'].items():
        if name != 'fontFamily' and isinstance(values, dict):
            size = values.get('size', '')
            lineHeight = values.get('lineHeight', '')
            if size and lineHeight:
                config['theme']['extend']['fontSize'][name] = [size, lineHeight]
    
    # Spacing
    for name, value in tokens['spacing'].items():
        config['theme']['extend']['spacing'][name] = value
    
    # Border radius
    for name, value in tokens['borderRadius'].items():
        config['theme']['extend']['borderRadius'][name] = value
    
    # Shadows
    for name, value in tokens['shadows'].items():
        config['theme']['extend']['boxShadow'][name] = value
    
    with open(output_path, 'w') as f:
        f.write("module.exports = ")
        json.dump(config, f, indent=2)
    
    print(f"✅ Exported to Tailwind config: {output_path}")


def export_to_flutter(tokens: Dict[str, Any], output_path: Path):
    """Export tokens to Flutter theme format (Dart)."""
    lines = [
        "import 'package:flutter/material.dart';",
        "",
        "class AppTheme {",
        "  // Colors"
    ]
    
    # Colors
    if 'primary' in tokens['colors']:
        hex_val = tokens['colors']['primary'].replace('#', '0xFF')
        lines.append(f"  static const Color primaryColor = Color({hex_val});")
    
    if 'secondary' in tokens['colors']:
        hex_val = tokens['colors']['secondary'].replace('#', '0xFF')
        lines.append(f"  static const Color secondaryColor = Color({hex_val});")
    
    for semantic in ['success', 'error', 'warning', 'info']:
        if semantic in tokens['colors']:
            hex_val = tokens['colors'][semantic].replace('#', '0xFF')
            lines.append(f"  static const Color {semantic}Color = Color({hex_val});")
    
    if 'neutral' in tokens['colors']:
        lines.append("")
        lines.append("  // Neutral colors")
        for level, color in tokens['colors']['neutral'].items():
            hex_val = color.replace('#', '0xFF')
            lines.append(f"  static const Color neutral{level} = Color({hex_val});")
    
    # Typography
    lines.append("")
    lines.append("  // Typography")
    if 'fontFamily' in tokens['typography']:
        lines.append(f"  static const String fontFamily = '{tokens['typography']['fontFamily']}';")
    
    # Spacing
    lines.append("")
    lines.append("  // Spacing")
    for name, value in tokens['spacing'].items():
        px_value = value.replace('px', '.0')
        lines.append(f"  static const double spacing{name.capitalize()} = {px_value};")
    
    # Border radius
    lines.append("")
    lines.append("  // Border radius")
    for name, value in tokens['borderRadius'].items():
        if value == '999px':
            lines.append(f"  static const double radius{name.capitalize()} = 999.0;")
        else:
            px_value = value.replace('px', '.0')
            lines.append(f"  static const double radius{name.capitalize()} = {px_value};")
    
    lines.append("}")
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(lines))
    
    print(f"✅ Exported to Flutter theme: {output_path}")


def main():
    if len(sys.argv) < 3:
        print("Usage: python export_design_tokens.py <design-system.md> --format <json|css|tailwind|flutter>")
        sys.exit(1)
    
    input_file = Path(sys.argv[1])
    if not input_file.exists():
        print(f"❌ Error: File not found: {input_file}")
        sys.exit(1)
    
    format_arg = None
    for i, arg in enumerate(sys.argv):
        if arg == '--format' and i + 1 < len(sys.argv):
            format_arg = sys.argv[i + 1].lower()
            break
    
    if not format_arg or format_arg not in ['json', 'css', 'tailwind', 'flutter']:
        print("❌ Error: Invalid format. Use: json, css, tailwind, or flutter")
        sys.exit(1)
    
    # Read input file
    with open(input_file, 'r') as f:
        md_content = f.read()
    
    # Extract tokens
    print("📊 Extracting design tokens...")
    tokens = extract_design_tokens(md_content)
    
    # Determine output filename
    output_extensions = {
        'json': 'json',
        'css': 'css',
        'tailwind': 'tailwind.config.js',
        'flutter': 'app_theme.dart'
    }
    
    output_file = input_file.parent / f"design-tokens.{output_extensions[format_arg]}"
    
    # Export
    if format_arg == 'json':
        export_to_json(tokens, output_file)
    elif format_arg == 'css':
        export_to_css(tokens, output_file)
    elif format_arg == 'tailwind':
        export_to_tailwind(tokens, output_file)
    elif format_arg == 'flutter':
        export_to_flutter(tokens, output_file)


if __name__ == '__main__':
    main()

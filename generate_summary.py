#!/usr/bin/env python3
"""
Generate complete SUMMARY.md for GitBook reorganization.
This script creates the navigation structure for all 24 months.
"""

import os
import re
from pathlib import Path

# Month topics mapping
MONTH_TOPICS = {
    1: "Lox Lexer & Go Fundamentals",
    2: "Lox Parser & AST",
    3: "Lox Interpreter Complete",
    4: "Kubernetes Deep Dive",
    5: "Mini Compiler",
    6: "CKA Certification",
    7: "Konfiguru DSL Design",
    8: "Konfiguru Lexer Parser",
    9: "Semantic Analysis Type System",
    10: "Advanced K8s Codegen",
    11: "Dependency Resolution",
    12: "v0.5 Release AWS SAA",
    13: "Intermediate Representation",
    14: "Terraform Backend Foundation",
    15: "Terraform Backend Complete",
    16: "CloudFormation Backend",
    17: "Multi-Target CLI",
    18: "v0.8 Release Terraform Cert",
    19: "AI Integration Research",
    20: "AI Optimization Engine",
    21: "Smart Config Generation",
    22: "Production Hardening CKS Prep",
    23: "Web Playground CKS Cert",
    24: "v1.0 Launch",
}

# Phase structure
PHASES = {
    1: {
        "name": "Compiler Foundations",
        "months": [1, 2, 3],
        "level": "foundations",
        "part_name": "FOUNDATION LEVEL",
        "target": "Staff Engineer Path",
        "duration": "Months 1-6",
    },
    2: {
        "name": "Infrastructure Integration",
        "months": [4, 5, 6],
        "level": "foundations",
        "part_name": "FOUNDATION LEVEL",
        "target": "Staff Engineer Path",
        "duration": "Months 1-6",
    },
    3: {
        "name": "Core Konfiguru Compiler",
        "months": [7, 8, 9, 10, 11, 12],
        "level": "intermediate",
        "part_name": "INTERMEDIATE LEVEL",
        "target": "Senior Staff Engineer Path",
        "duration": "Months 7-12",
    },
    4: {
        "name": "Multi-Target Compiler",
        "months": [13, 14, 15, 16, 17, 18],
        "level": "advanced",
        "part_name": "ADVANCED LEVEL",
        "target": "Staff Architect Path",
        "duration": "Months 13-18",
    },
    5: {
        "name": "AI & Production",
        "months": [19, 20, 21, 22, 23, 24],
        "level": "expert",
        "part_name": "EXPERT LEVEL",
        "target": "Principal Engineer Path",
        "duration": "Months 19-24",
    },
}

def get_level_for_month(month_num):
    """Get the level directory for a given month."""
    if month_num <= 6:
        return "foundations"
    elif month_num <= 12:
        return "intermediate"
    elif month_num <= 18:
        return "advanced"
    else:
        return "expert"

def extract_day_title(file_path):
    """Extract the title from a day markdown file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            first_line = f.readline().strip()
            # Extract title from "# Day 001: Title Here"
            match = re.match(r'#\s*Day\s*\d+:\s*(.+)', first_line)
            if match:
                return match.group(1).strip()
            # Fallback: just return the first line without the #
            return first_line.replace('#', '').strip()
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}")
        return "Unknown Title"

def extract_week_title(file_path):
    """Extract the title from a week markdown file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            first_line = f.readline().strip()
            # Extract title from "# Week N: Title"
            match = re.match(r'#\s*Week\s*\d+:\s*(.+)', first_line)
            if match:
                return match.group(1).strip()
            # Fallback
            return first_line.replace('#', '').strip()
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}")
        return "Unknown Week"

def generate_month_section(month_num, base_path):
    """Generate the SUMMARY.md section for a single month."""
    level = get_level_for_month(month_num)
    month_dir = f"month-{month_num:02d}"
    month_topic = MONTH_TOPICS.get(month_num, f"Month {month_num}")

    lines = []
    lines.append(f"\n#### Month {month_num}: {month_topic}\n")

    # Month overview
    overview_path = os.path.join(base_path, level, month_dir, "overview.md")
    lines.append(f"* [Month {month_num} Overview]({level}/{month_dir}/overview.md)")

    # Process 4 weeks
    for week_num in range(1, 5):
        week_file = f"week-{week_num}.md"
        week_path = os.path.join(base_path, level, month_dir, week_file)

        if os.path.exists(week_path):
            week_title = extract_week_title(week_path)
            lines.append(f"* [Week {week_num}: {week_title}]({level}/{month_dir}/{week_file})")

            # Calculate day range for this week
            start_day = (week_num - 1) * 7 + 1
            if week_num == 4:
                # Week 4 has days 23-30 (8 days)
                end_day = 30
            else:
                end_day = start_day + 6

            # Add days for this week
            for day_num in range(start_day, end_day + 1):
                day_file = f"day-{day_num:03d}.md"
                day_path = os.path.join(base_path, level, month_dir, day_file)

                if os.path.exists(day_path):
                    day_title = extract_day_title(day_path)
                    lines.append(f"  * [Day {day_num}: {day_title}]({level}/{month_dir}/{day_file})")
                else:
                    print(f"Warning: Missing {day_path}")
        else:
            print(f"Warning: Missing {week_path}")

    return "\n".join(lines)

def generate_phase_section(phase_num, base_path):
    """Generate the SUMMARY.md section for a phase."""
    phase = PHASES[phase_num]
    level = phase["level"]

    lines = []
    lines.append(f"\n### Phase {phase_num}: {phase['name']}\n")
    lines.append(f"* [Phase {phase_num} Overview]({level}/phase-{phase_num}-overview.md)")
    lines.append(f"* [Phase {phase_num} Resources]({level}/phase-{phase_num}-resources.md)")

    # Add all months in this phase
    for month_num in phase["months"]:
        month_section = generate_month_section(month_num, base_path)
        lines.append(month_section)

    return "\n".join(lines)

def generate_summary(base_path):
    """Generate the complete SUMMARY.md content."""
    lines = []

    # Header
    lines.append("# Summary")
    lines.append("")

    # Getting Started
    lines.append("## Getting Started")
    lines.append("")
    lines.append("* [Welcome to Your Journey](README.md)")
    lines.append("* [How to Use This Guide](guides/how-to-use.md)")
    lines.append("* [Quick Start](guides/quick-start.md)")
    lines.append("* [Learning Path Overview](guides/learning-path-overview.md)")
    lines.append("")
    lines.append("---")
    lines.append("")

    # Part I: Foundation Level
    lines.append("## PART I: FOUNDATION LEVEL")
    lines.append("")
    lines.append("**Target:** Staff Engineer Path | **Duration:** Months 1-6")
    lines.append("")

    # Phase 1 & 2
    lines.append(generate_phase_section(1, base_path))
    lines.append(generate_phase_section(2, base_path))
    lines.append("")
    lines.append("---")
    lines.append("")

    # Part II: Intermediate Level
    lines.append("## PART II: INTERMEDIATE LEVEL")
    lines.append("")
    lines.append("**Target:** Senior Staff Engineer Path | **Duration:** Months 7-12")
    lines.append("")
    lines.append(generate_phase_section(3, base_path))
    lines.append("")
    lines.append("---")
    lines.append("")

    # Part III: Advanced Level
    lines.append("## PART III: ADVANCED LEVEL")
    lines.append("")
    lines.append("**Target:** Staff Architect Path | **Duration:** Months 13-18")
    lines.append("")
    lines.append(generate_phase_section(4, base_path))
    lines.append("")
    lines.append("---")
    lines.append("")

    # Part IV: Expert Level
    lines.append("## PART IV: EXPERT LEVEL")
    lines.append("")
    lines.append("**Target:** Principal Engineer Path | **Duration:** Months 19-24")
    lines.append("")
    lines.append(generate_phase_section(5, base_path))
    lines.append("")
    lines.append("---")
    lines.append("")

    # Reference Materials
    lines.append("## Reference Materials")
    lines.append("")
    lines.append("* [Compiler Theory](reference/compiler-theory/README.md)")
    lines.append("* [AI/ML Integration](reference/ai-ml/README.md)")
    lines.append("* [Infrastructure as Code](reference/iac/README.md)")
    lines.append("")

    # Certifications
    lines.append("## Certifications")
    lines.append("")
    lines.append("* [CKA - Certified Kubernetes Administrator](certifications/cka/README.md)")
    lines.append("* [AWS Solutions Architect Associate](certifications/aws-saa/README.md)")
    lines.append("* [Terraform Associate](certifications/terraform/README.md)")
    lines.append("* [CKS - Certified Kubernetes Security](certifications/cks/README.md)")
    lines.append("")

    # Career Development
    lines.append("## Career Development")
    lines.append("")
    lines.append("* [Interview Preparation](career/interview-prep.md)")
    lines.append("* [Portfolio Building](career/portfolio.md)")
    lines.append("* [Resume Guide](career/resume-guide.md)")
    lines.append("")
    lines.append("---")
    lines.append("")

    # Additional Resources
    lines.append("## Additional Resources")
    lines.append("")
    lines.append("* [Visual Roadmap](VISUAL-ROADMAP.md)")
    lines.append("* [Complete Documentation Index](COMPLETE-DOCUMENTATION-INDEX.md)")
    lines.append("* [GitBook Setup Guide](GITBOOK-SETUP.md)")

    return "\n".join(lines)

def verify_paths(base_path, summary_content):
    """Verify that all paths in SUMMARY.md actually exist."""
    missing_files = []
    link_count = 0

    # Extract all markdown links
    link_pattern = re.compile(r'\[([^\]]+)\]\(([^\)]+)\)')
    for match in link_pattern.finditer(summary_content):
        link_text = match.group(1)
        link_path = match.group(2)
        link_count += 1

        # Skip anchors and external links
        if link_path.startswith('#') or link_path.startswith('http'):
            continue

        # Check if file exists
        full_path = os.path.join(base_path, link_path)
        if not os.path.exists(full_path):
            missing_files.append((link_text, link_path))

    return link_count, missing_files

def main():
    # Get the base path (repository root)
    script_dir = Path(__file__).parent
    base_path = script_dir

    print("Generating SUMMARY.md...")
    print(f"Base path: {base_path}")
    print()

    # Generate the summary
    summary_content = generate_summary(base_path)

    # Write to file
    summary_path = base_path / "SUMMARY.md"
    with open(summary_path, 'w', encoding='utf-8') as f:
        f.write(summary_content)

    print(f"✓ SUMMARY.md written to: {summary_path}")
    print()

    # Verify paths
    print("Verifying file paths...")
    link_count, missing_files = verify_paths(base_path, summary_content)

    print(f"✓ Total links in SUMMARY.md: {link_count}")
    print()

    if missing_files:
        print(f"⚠ Warning: {len(missing_files)} missing files:")
        for link_text, link_path in missing_files[:10]:  # Show first 10
            print(f"  - {link_path}")
        if len(missing_files) > 10:
            print(f"  ... and {len(missing_files) - 10} more")
    else:
        print("✓ All file paths verified!")

    print()
    print("Summary generation complete!")

if __name__ == "__main__":
    main()

#!/bin/bash

# GitBook Reorganization - Phase B & C Implementation
# This script migrates daily content and creates week overview files

set -e  # Exit on error

BASE_DIR="/home/bhargav/Documents/Side-Projects/konfiguruJourney"
SOURCE_DIR="$BASE_DIR/Problem Statements"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counters
DAYS_COPIED=0
OVERVIEWS_COPIED=0
WEEKS_CREATED=0
PHASE_RESOURCES_CREATED=0

echo -e "${BLUE}=== Phase B: Migrating Daily Content ===${NC}"

# Define month mappings: month_number -> (phase_dir, source_folder)
declare -A MONTH_MAP=(
    ["01"]="foundations|01-Lox-Lexer-Go-Fundamentals"
    ["02"]="foundations|02-Lox-Parser-AST"
    ["03"]="foundations|03-Lox-Interpreter-Complete"
    ["04"]="foundations|04-Kubernetes-Deep-Dive"
    ["05"]="foundations|05-Mini-Compiler"
    ["06"]="foundations|06-CKA-Certification"
    ["07"]="intermediate|07-Konfigura-DSL-Design"
    ["08"]="intermediate|08-Konfigura-Lexer-Parser"
    ["09"]="intermediate|09-Semantic-Analysis-Type-System"
    ["10"]="intermediate|10-Advanced-K8s-Codegen"
    ["11"]="intermediate|11-Dependency-Resolution"
    ["12"]="intermediate|12-v0.5-Release-AWS-SAA"
    ["13"]="advanced|13-Intermediate-Representation"
    ["14"]="advanced|14-Terraform-Backend-Foundation"
    ["15"]="advanced|15-Terraform-Backend-Complete"
    ["16"]="advanced|16-CloudFormation-Backend"
    ["17"]="advanced|17-Multi-Target-CLI"
    ["18"]="advanced|18-v0.8-Release-Terraform-Cert"
    ["19"]="expert|19-AI-Integration-Research"
    ["20"]="expert|20-AI-Optimization-Engine"
    ["21"]="expert|21-Smart-Config-Generation"
    ["22"]="expert|22-Production-Hardening-CKS-Prep"
    ["23"]="expert|23-Web-Playground-CKS-Cert"
    ["24"]="expert|24-v1.0-Launch"
)

# Phase B: Copy daily files and month overviews
for month in {01..24}; do
    mapping="${MONTH_MAP[$month]}"
    phase_dir=$(echo $mapping | cut -d'|' -f1)
    source_folder=$(echo $mapping | cut -d'|' -f2)

    src="$SOURCE_DIR/$source_folder"
    dest="$BASE_DIR/$phase_dir/month-$month"

    echo -e "${GREEN}Processing Month $month: $source_folder${NC}"

    # Copy daily files (Day-001.md through Day-030.md)
    for day in {001..030}; do
        src_file="$src/Day-$day.md"
        dest_file="$dest/day-$day.md"

        if [ -f "$src_file" ]; then
            cp "$src_file" "$dest_file"
            DAYS_COPIED=$((DAYS_COPIED + 1))
        else
            echo -e "${RED}Warning: $src_file not found${NC}"
        fi
    done

    # Copy month README to overview.md
    if [ -f "$src/README.md" ]; then
        cp "$src/README.md" "$dest/overview.md"
        OVERVIEWS_COPIED=$((OVERVIEWS_COPIED + 1))
        echo "  - Copied README.md to overview.md"
    else
        echo -e "${RED}Warning: README.md not found in $src${NC}"
    fi

    echo "  - Copied 30 daily files to $dest"
done

echo -e "\n${BLUE}=== Phase C: Creating New Content ===${NC}"

# Phase C.1: Create phase resource files
echo -e "${GREEN}Creating phase resource files...${NC}"

create_phase_resources() {
    local phase_num=$1
    local phase_dir=$2
    local phase_name=$3

    local file="$BASE_DIR/$phase_dir/phase-$phase_num-resources.md"

    cat > "$file" <<EOF
# Phase $phase_num Resources: $phase_name

## Related Reference Materials

*This section will link to relevant content in the reference/ directory.*

- [Compiler Theory Basics](../reference/compiler-theory/README.md)
- [Infrastructure as Code](../reference/iac/README.md)

## Certifications

*Relevant certifications for this phase will be linked here.*

## External Resources

### Documentation
- Official documentation links
- Tutorial resources
- Community guides

### Tools & Prerequisites

#### Required Software
- List of required tools
- Installation guides
- Version requirements

#### Recommended Reading
- Books and articles
- Video courses
- Practice exercises

## Phase Learning Objectives

*This section outlines what you should achieve by completing this phase.*

### Skills You'll Gain
- Skill 1
- Skill 2
- Skill 3

### Projects You'll Build
- Project 1
- Project 2

## Next Steps

After completing this phase, you'll be ready to move on to the next phase of your journey.
EOF

    echo "  - Created $file"
    PHASE_RESOURCES_CREATED=$((PHASE_RESOURCES_CREATED + 1))
}

create_phase_resources "1" "foundations" "Compiler Foundations"
create_phase_resources "2" "foundations" "Infrastructure Integration"
create_phase_resources "3" "intermediate" "Core Konfiguru Compiler"
create_phase_resources "4" "advanced" "Multi-Target Compiler"
create_phase_resources "5" "expert" "AI & Production"

# Phase C.2: Create week overview files
echo -e "\n${GREEN}Creating week overview files...${NC}"

create_week_overview() {
    local month=$1
    local week=$2
    local phase_dir=$3
    local week_theme=$4

    local file="$BASE_DIR/$phase_dir/month-$month/week-$week.md"

    # Calculate day range for this week
    local start_day=$(( (week - 1) * 7 + 1 ))
    local end_day=$(( week * 7 ))
    if [ $week -eq 4 ]; then
        end_day=30  # Week 4 has 9 days (23-30)
    fi

    cat > "$file" <<EOF
# Week $week: $week_theme

## This Week's Focus

This week focuses on $week_theme. You will work through Days $start_day-$end_day of this month's learning path.

## Daily Breakdown

EOF

    # Add day links
    for day in $(seq $start_day $end_day); do
        day_padded=$(printf "%03d" $day)
        echo "- [Day $day: Topic TBD](./day-$day_padded.md)" >> "$file"
    done

    cat >> "$file" <<EOF

## Learning Objectives

- Master key concepts introduced this week
- Complete hands-on exercises and projects
- Build upon previous week's foundation

## Resources

- Review relevant reference materials
- Practice exercises
- Additional reading

## Week Summary

By the end of this week, you should be able to:
- Objective 1
- Objective 2
- Objective 3
EOF

    echo "  - Created week $week for month $month"
    WEEKS_CREATED=$((WEEKS_CREATED + 1))
}

# Create week overviews for all 24 months
for month in {01..24}; do
    mapping="${MONTH_MAP[$month]}"
    phase_dir=$(echo $mapping | cut -d'|' -f1)

    echo "Creating weeks for Month $month ($phase_dir)..."

    create_week_overview "$month" "1" "$phase_dir" "Foundation Setup"
    create_week_overview "$month" "2" "$phase_dir" "Core Implementation"
    create_week_overview "$month" "3" "$phase_dir" "Advanced Features"
    create_week_overview "$month" "4" "$phase_dir" "Integration & Testing"
done

echo -e "\n${BLUE}=== Migration Summary ===${NC}"
echo -e "${GREEN}Daily files copied: $DAYS_COPIED${NC}"
echo -e "${GREEN}Month overviews copied: $OVERVIEWS_COPIED${NC}"
echo -e "${GREEN}Week files created: $WEEKS_CREATED${NC}"
echo -e "${GREEN}Phase resource files created: $PHASE_RESOURCES_CREATED${NC}"
echo -e "\n${BLUE}Total files processed: $((DAYS_COPIED + OVERVIEWS_COPIED + WEEKS_CREATED + PHASE_RESOURCES_CREATED))${NC}"

echo -e "\n${GREEN}Phase B & C Complete!${NC}"

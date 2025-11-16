#!/bin/bash

# Migration Verification Script
# Verifies that Phase B & C completed successfully

BASE_DIR="/home/bhargav/Documents/Side-Projects/konfiguruJourney"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== GitBook Migration Verification ===${NC}\n"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function
test_result() {
    local test_name=$1
    local expected=$2
    local actual=$3

    if [ "$expected" -eq "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name: $actual/$expected"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name: $actual/$expected (MISMATCH)"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Total day files
actual=$(find "$BASE_DIR" -name "day-*.md" -path "*/month-*/*" | wc -l)
test_result "Daily files copied" 720 $actual

# Test 2: Month overview files
actual=$(find "$BASE_DIR" -name "overview.md" -path "*/month-*/*" | wc -l)
test_result "Month overviews" 24 $actual

# Test 3: Week files
actual=$(find "$BASE_DIR" -name "week-*.md" | wc -l)
test_result "Week files created" 96 $actual

# Test 4: Phase resource files
actual=$(find "$BASE_DIR" -name "phase-*-resources.md" | wc -l)
test_result "Phase resource files" 5 $actual

# Test 5: Month directories
actual=$(find "$BASE_DIR" -type d -name "month-*" | wc -l)
test_result "Month directories" 24 $actual

# Test 6: Sample file content verification
echo -e "\n${BLUE}Content Integrity Checks:${NC}"

# Check that day files are not empty
empty_days=$(find "$BASE_DIR" -name "day-*.md" -path "*/month-*/*" -empty | wc -l)
if [ "$empty_days" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All day files have content"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Found $empty_days empty day files"
    ((TESTS_FAILED++))
fi

# Check that overview files are not empty
empty_overviews=$(find "$BASE_DIR" -name "overview.md" -path "*/month-*/*" -empty | wc -l)
if [ "$empty_overviews" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All overview files have content"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Found $empty_overviews empty overview files"
    ((TESTS_FAILED++))
fi

# Test specific samples
echo -e "\n${BLUE}Sample File Checks:${NC}"

sample_files=(
    "foundations/month-01/day-001.md"
    "foundations/month-01/overview.md"
    "foundations/month-01/week-1.md"
    "intermediate/month-07/day-015.md"
    "advanced/month-15/day-020.md"
    "expert/month-24/day-030.md"
    "foundations/phase-1-resources.md"
    "intermediate/phase-3-resources.md"
)

for file in "${sample_files[@]}"; do
    full_path="$BASE_DIR/$file"
    if [ -f "$full_path" ] && [ -s "$full_path" ]; then
        lines=$(wc -l < "$full_path")
        echo -e "${GREEN}✓${NC} $file ($lines lines)"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $file (missing or empty)"
        ((TESTS_FAILED++))
    fi
done

# Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "\n${GREEN}✓ All verification tests passed!${NC}"
    echo -e "${GREEN}Phase B & C migration completed successfully.${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed. Please review the migration.${NC}"
    exit 1
fi

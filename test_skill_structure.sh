#!/bin/bash

echo "🧪 Testing SKILL.md Structure and Content"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# Test 1: Check file exists and is readable
echo "Test 1: File accessibility"
if [ -f "SKILL.md" ] && [ -r "SKILL.md" ]; then
    echo "✅ SKILL.md exists and is readable"
else
    echo "❌ SKILL.md not found or not readable"
    ((ERRORS++))
fi
echo ""

# Test 2: Check for frontmatter
echo "Test 2: Frontmatter presence"
if head -1 SKILL.md | grep -q "^---$"; then
    echo "✅ Frontmatter opening found"
else
    echo "❌ Frontmatter opening not found"
    ((ERRORS++))
fi
echo ""

# Test 3: Check for required sections
echo "Test 3: Required sections"
SECTIONS=(
    "Critical Red Flags"
    "NEVER Do These Things"
    "ALWAYS Do These Things"
    "Announcement (REQUIRED)"
    "Core Capabilities"
    "Initialization Steps"
    "References"
)

for section in "${SECTIONS[@]}"; do
    if grep -q "$section" SKILL.md; then
        echo "✅ Section found: $section"
    else
        echo "❌ Section missing: $section"
        ((ERRORS++))
    fi
done
echo ""

# Test 4: Check for hardcoded paths
echo "Test 4: No hardcoded paths"
HARDCODED_PATTERNS=(
    "/tmp/nearest-nice-weather"
    "/home/"
    "^/"
)

FOUND_HARDCODED=0
for pattern in "${HARDCODED_PATTERNS[@]}"; do
    if grep -E "$pattern" SKILL.md | grep -v "{baseDir}" | grep -v "^#" | grep -v "Example:" | grep -v "```" >/dev/null 2>&1; then
        echo "⚠️  Found potential hardcoded path with pattern: $pattern"
        grep -n -E "$pattern" SKILL.md | grep -v "{baseDir}" | head -3
        ((WARNINGS++))
        FOUND_HARDCODED=1
    fi
done

if [ $FOUND_HARDCODED -eq 0 ]; then
    echo "✅ No hardcoded paths found"
fi
echo ""

# Test 5: Check for {baseDir} usage
echo "Test 5: {baseDir} placeholder usage"
BASEDIR_COUNT=$(grep -c "{baseDir}" SKILL.md)
if [ $BASEDIR_COUNT -gt 0 ]; then
    echo "✅ {baseDir} placeholder used: $BASEDIR_COUNT occurrences"
else
    echo "⚠️  No {baseDir} placeholders found"
    ((WARNINGS++))
fi
echo ""

# Test 6: Check version
echo "Test 6: Version updated"
if grep -q "version: 2.0.0" SKILL.md; then
    echo "✅ Version 2.0.0 found in frontmatter"
else
    echo "❌ Version 2.0.0 not found"
    ((ERRORS++))
fi

if grep -q "Skill Version.*2.0.0" SKILL.md; then
    echo "✅ Version 2.0.0 found in footer"
else
    echo "⚠️  Version 2.0.0 not found in footer"
    ((WARNINGS++))
fi
echo ""

# Test 7: Check tool permissions
echo "Test 7: Tool permissions defined"
if grep -q "allowed-tools:" SKILL.md; then
    echo "✅ allowed-tools field present"
    TOOLS=$(grep "allowed-tools:" SKILL.md | head -1)
    echo "   Tools: ${TOOLS#*: }"
else
    echo "❌ allowed-tools field missing"
    ((ERRORS++))
fi
echo ""

# Test 8: Check announcement pattern
echo "Test 8: Announcement pattern"
if grep -q "I'm using the \*\*GitHub Operations\*\* skill" SKILL.md; then
    echo "✅ Announcement pattern example found"
else
    echo "❌ Announcement pattern missing"
    ((ERRORS++))
fi
echo ""

# Test 9: File size check
echo "Test 9: File size reasonable"
SIZE=$(wc -c < SKILL.md)
LINES=$(wc -l < SKILL.md)
echo "   File size: $SIZE bytes"
echo "   Line count: $LINES lines"

if [ $LINES -gt 1000 ]; then
    echo "⚠️  File is quite long (>1000 lines) - consider progressive disclosure"
    ((WARNINGS++))
else
    echo "✅ File size reasonable"
fi
echo ""

# Summary
echo "=========================================="
echo "Test Summary:"
echo "✅ Passed: $((9 - ERRORS))"
if [ $WARNINGS -gt 0 ]; then
    echo "⚠️  Warnings: $WARNINGS"
fi
if [ $ERRORS -gt 0 ]; then
    echo "❌ Errors: $ERRORS"
    exit 1
else
    echo "🎉 All critical tests passed!"
    exit 0
fi

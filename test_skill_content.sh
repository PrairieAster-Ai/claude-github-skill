#!/bin/bash

echo "🧪 Testing SKILL.md Content Quality"
echo "====================================="
echo ""

# Test announcement examples
echo "Test 1: Announcement examples"
ANNOUNCEMENT_COUNT=$(grep -c "I'm using the.*GitHub Operations.*skill" SKILL.md)
if [ $ANNOUNCEMENT_COUNT -ge 3 ]; then
    echo "✅ Found $ANNOUNCEMENT_COUNT announcement examples"
else
    echo "⚠️  Only $ANNOUNCEMENT_COUNT announcement examples (expected 3+)"
fi
echo ""

# Test Red Flags count
echo "Test 2: Red Flags completeness"
NEVER_COUNT=$(grep -c "^- ❌" SKILL.md)
ALWAYS_COUNT=$(grep -c "^- ✅" SKILL.md)
echo "   NEVER items: $NEVER_COUNT"
echo "   ALWAYS items: $ALWAYS_COUNT"
if [ $NEVER_COUNT -ge 5 ] && [ $ALWAYS_COUNT -ge 6 ]; then
    echo "✅ Red Flags complete (5 NEVER, 6 ALWAYS)"
else
    echo "⚠️  Red Flags may be incomplete"
fi
echo ""

# Test Quick Checklist
echo "Test 3: Quick Checklist"
if grep -q "Quick Error Prevention Checklist" SKILL.md; then
    CHECKLIST_ITEMS=$(grep -c "^\[ \]" SKILL.md)
    echo "✅ Quick Checklist found with $CHECKLIST_ITEMS items"
else
    echo "⚠️  Quick Checklist not found"
fi
echo ""

# Test Best Used With section
echo "Test 4: Skill composition hints"
if grep -q "Best Used With:" SKILL.md; then
    echo "✅ Skill composition section present"
else
    echo "⚠️  No skill composition hints"
fi
echo ""

# Test References section
echo "Test 5: References to documentation"
REF_COUNT=$(grep -c "\.claude/skills/github/" SKILL.md)
echo "✅ Found $REF_COUNT references to skill directory"
echo ""

# Test for skill-directory (should be replaced)
echo "Test 6: Old placeholders removed"
if grep -q "\[skill-directory\]" SKILL.md; then
    echo "❌ Found old [skill-directory] placeholders"
    grep -n "\[skill-directory\]" SKILL.md | head -3
else
    echo "✅ No old placeholders remain"
fi
echo ""

# Test file size
echo "Test 7: File metrics"
LINES=$(wc -l < SKILL.md)
WORDS=$(wc -w < SKILL.md)
CHARS=$(wc -c < SKILL.md)
echo "   Lines: $LINES"
echo "   Words: $WORDS"
echo "   Chars: $CHARS"

if [ $WORDS -lt 5000 ]; then
    echo "✅ File size manageable (under 5000 words)"
else
    echo "⚠️  File may be too long for optimal token usage"
fi
echo ""

echo "====================================="
echo "🎉 Content quality checks complete!"

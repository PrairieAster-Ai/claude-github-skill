#!/bin/bash

# Wiki Validation Script
# Validates Wiki content for common issues before publishing

set -e

WIKI_DIR="${1:-.}"
ERRORS=0

echo "🔍 Validating Wiki content in: $WIKI_DIR"
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check 1: Hardcoded database counts
echo "📊 Checking for hardcoded database counts..."
if grep -rn "138 POI\|169 locations\|[0-9]\+ POI locations" "$WIKI_DIR" --include="*.md" 2>/dev/null; then
    echo -e "${RED}❌ Found hardcoded database counts${NC}"
    echo "   Use generic terms like 'Minnesota POI database (verified: DATE)'"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ No hardcoded database counts found${NC}"
fi
echo ""

# Check 2: Deprecated technology references
echo "🔧 Checking for deprecated technology references..."
DEPRECATED_TECH=("FastAPI" "Directus" "PostGIS" "Docker Compose")
for tech in "${DEPRECATED_TECH[@]}"; do
    if grep -rn "$tech" "$WIKI_DIR" --include="*.md" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Found references to potentially deprecated: $tech${NC}"
        echo "   Verify if these should be updated or deprecated"
        ((ERRORS++))
    fi
done
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ No deprecated technology references found${NC}"
fi
echo ""

# Check 3: Business model consistency
echo "💼 Checking for business model consistency..."
B2C_COUNT=$(grep -rn "B2C" "$WIKI_DIR" --include="*.md" 2>/dev/null | wc -l)
B2B_COUNT=$(grep -rn "B2B" "$WIKI_DIR" --include="*.md" 2>/dev/null | wc -l)

echo "   B2C mentions: $B2C_COUNT"
echo "   B2B mentions: $B2B_COUNT"

if [ $B2B_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found B2B references - verify these are clearly marked as not current focus${NC}"
    grep -rn "B2B" "$WIKI_DIR" --include="*.md" 2>/dev/null | head -5
fi
echo ""

# Check 4: Broken internal links
echo "🔗 Checking for broken internal links..."
if grep -rn "\[.*\](\s*)" "$WIKI_DIR" --include="*.md" 2>/dev/null; then
    echo -e "${RED}❌ Found empty links${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ No empty links found${NC}"
fi
echo ""

# Check 5: TODO/FIXME markers
echo "📝 Checking for TODO/FIXME markers..."
if grep -rn "TODO\|FIXME\|XXX\|HACK" "$WIKI_DIR" --include="*.md" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Found TODO/FIXME markers - resolve before publishing${NC}"
fi
echo ""

# Check 6: Inconsistent headers
echo "📋 Checking for business model headers in investor docs..."
INVESTOR_DOCS=("Investment" "Executive" "Financial" "Business" "Strategy")
for doc_type in "${INVESTOR_DOCS[@]}"; do
    if find "$WIKI_DIR" -name "*$doc_type*.md" -type f 2>/dev/null | grep -q .; then
        echo "   Found investor docs matching: $doc_type"
        if ! grep -rn "## Business Model" "$WIKI_DIR" --include="*$doc_type*.md" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Investor doc missing 'Business Model' header${NC}"
        fi
    fi
done
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All validation checks passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Found $ERRORS potential issues${NC}"
    echo "Review warnings above before publishing"
    exit 1
fi

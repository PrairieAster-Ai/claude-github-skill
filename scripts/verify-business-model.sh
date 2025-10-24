#!/bin/bash

# Business Model Validation Script
# Ensures consistent business model messaging across investor-facing documentation

set -e

WIKI_DIR="${1:-.}"
ERRORS=0

echo "💼 Validating business model consistency in: $WIKI_DIR"
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Load business context from memory-bank if available
BUSINESS_FOCUS=""
if [ -f "memory-bank/quick-reference.json" ]; then
    echo "📚 Loading business context from memory-bank"
    BUSINESS_FOCUS=$(jq -r '.businessFocus // empty' memory-bank/quick-reference.json 2>/dev/null)
    if [ -n "$BUSINESS_FOCUS" ]; then
        echo "   Current focus: $BUSINESS_FOCUS"
    fi
    echo ""
fi

# Check 1: B2C vs B2B consistency
echo "📊 Checking B2C/B2B consistency..."
B2C_COUNT=$(grep -rn "B2C" "$WIKI_DIR" --include="*.md" 2>/dev/null | wc -l)
B2B_COUNT=$(grep -rn "B2B" "$WIKI_DIR" --include="*.md" 2>/dev/null | wc -l)

echo "   B2C mentions: $B2C_COUNT"
echo "   B2B mentions: $B2B_COUNT"

if [ $B2B_COUNT -gt 0 ] && [ $B2C_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found both B2C and B2B references${NC}"
    echo "   Verify these are clearly distinguished (current focus vs future possibilities)"
    echo ""
    echo "B2B references found in:"
    grep -rn "B2B" "$WIKI_DIR" --include="*.md" 2>/dev/null | head -5
    ((ERRORS++))
fi
echo ""

# Check 2: Investor-facing documents have business model headers
echo "📋 Checking for business model headers in investor docs..."
INVESTOR_DOCS=(
    "Investment"
    "Executive"
    "Financial"
    "Business"
    "Strategy"
    "Pitch"
    "Deck"
)

MISSING_HEADERS=0
for doc_type in "${INVESTOR_DOCS[@]}"; do
    if find "$WIKI_DIR" -name "*$doc_type*.md" -type f 2>/dev/null | grep -q .; then
        echo "   Found investor doc type: $doc_type"

        for file in $(find "$WIKI_DIR" -name "*$doc_type*.md" -type f 2>/dev/null); do
            if ! grep -q "## Business Model" "$file" 2>/dev/null; then
                echo -e "${YELLOW}⚠️  Missing 'Business Model' header: $(basename "$file")${NC}"
                ((MISSING_HEADERS++))
            fi
        done
    fi
done

if [ $MISSING_HEADERS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  $MISSING_HEADERS investor documents missing business model headers${NC}"
    echo "   Add business model section using templates/business-model-header.md"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ All investor documents have business model headers${NC}"
fi
echo ""

# Check 3: Contradictory claims
echo "🔍 Checking for contradictory claims..."
CONTRADICTIONS=0

# Check for "not pursuing" language
NOT_PURSUING=$(grep -rn "NOT Pursuing\|not pursuing\|are not in current" "$WIKI_DIR" --include="*.md" 2>/dev/null)
if [ -n "$NOT_PURSUING" ]; then
    echo "Found explicit exclusions:"
    echo "$NOT_PURSUING" | head -5
    echo ""
fi

# Check if excluded items are mentioned elsewhere positively
if echo "$NOT_PURSUING" | grep -q "B2B"; then
    if grep -rn "B2B.*feature\|B2B.*capability\|developing.*B2B" "$WIKI_DIR" --include="*.md" 2>/dev/null | grep -v "NOT Pursuing"; then
        echo -e "${RED}❌ Found contradictory B2B claims${NC}"
        echo "   Document says 'NOT Pursuing B2B' but also mentions developing B2B features"
        ((CONTRADICTIONS++))
    fi
fi

if [ $CONTRADICTIONS -gt 0 ]; then
    ((ERRORS++))
else
    echo -e "${GREEN}✅ No contradictory claims found${NC}"
fi
echo ""

# Check 4: Revenue model consistency
echo "💰 Checking revenue model consistency..."
REVENUE_MODELS=$(grep -roh "ad-supported\|subscription\|SaaS\|transaction fee\|marketplace\|freemium" "$WIKI_DIR" --include="*.md" -i 2>/dev/null | sort | uniq -c | sort -rn)

if [ -n "$REVENUE_MODELS" ]; then
    echo "Revenue model mentions:"
    echo "$REVENUE_MODELS"
    echo ""

    MODEL_COUNT=$(echo "$REVENUE_MODELS" | wc -l)
    if [ $MODEL_COUNT -gt 2 ]; then
        echo -e "${YELLOW}⚠️  Multiple revenue models mentioned${NC}"
        echo "   Clarify which is primary vs future possibilities"
        ((ERRORS++))
    fi
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Business model validation passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Found $ERRORS business model consistency issues${NC}"
    echo "Review warnings above and update documentation for clarity"
    exit 1
fi

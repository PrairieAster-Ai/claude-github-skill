#!/bin/bash

# Technology Stack Validation Script
# Checks Wiki content for outdated or deprecated technology references

set -e

WIKI_DIR="${1:-.}"
ERRORS=0

echo "🔧 Checking technology stack references in: $WIKI_DIR"
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Load project's tech stack if available
if [ -f "memory-bank/quick-reference.json" ]; then
    echo "📚 Loading tech stack from memory-bank/quick-reference.json"
    CURRENT_STACK=$(jq -r '.techStack // empty' memory-bank/quick-reference.json 2>/dev/null)
    if [ -n "$CURRENT_STACK" ]; then
        echo "   Current stack: $CURRENT_STACK"
    fi
    echo ""
fi

# Common deprecated technologies to check
DEPRECATED_TECH=(
    "FastAPI"
    "Directus"
    "PostGIS"
    "Docker Compose"
    "Flask"
    "Django"
    "Express.js:localhost"
)

echo "🔍 Scanning for technology references..."
echo ""

for tech in "${DEPRECATED_TECH[@]}"; do
    TECH_NAME="${tech%%:*}"
    CONTEXT="${tech#*:}"

    if grep -rn "$TECH_NAME" "$WIKI_DIR" --include="*.md" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Found references to: $TECH_NAME${NC}"

        if [ "$CONTEXT" != "$TECH_NAME" ]; then
            echo "   Context: $CONTEXT"
        fi

        echo "   Action: Verify if these references are current or should be deprecated"
        ((ERRORS++))
    fi
done

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ No deprecated technology references found${NC}"
fi
echo ""

# Check for consistency across Wiki pages
echo "🔄 Checking for technology consistency..."
TECH_MENTIONS=$(grep -roh "\(FastAPI\|Vercel\|Neon\|PostgreSQL\|React\|Next\.js\|Vite\)" "$WIKI_DIR" --include="*.md" 2>/dev/null | sort | uniq -c | sort -rn)

if [ -n "$TECH_MENTIONS" ]; then
    echo "Technology mention counts:"
    echo "$TECH_MENTIONS"
    echo ""
    echo "Review: Ensure consistent terminology across all Wiki pages"
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Technology stack validation passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Found $ERRORS technology references to review${NC}"
    echo "Check if these technologies are still in use or need deprecation warnings"
    exit 1
fi

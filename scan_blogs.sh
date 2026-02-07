#!/bin/bash
################################################################################
# Blog Scanner for Docker cagent
################################################################################
# Quick script to scan GitHub for the latest blog posts and articles about
# Docker cagent. This is a convenience wrapper around scan_github_tools.py
# that highlights blog findings.
#
# Usage:
#   export GITHUB_TOKEN=your_github_token  # Recommended
#   ./scan_blogs.sh
#
# Output:
#   - Displays scan results on console
#   - Saves results to new_tools_found.md
################################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Docker cagent - Blog & Article Scanner${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠ Warning: GITHUB_TOKEN not set${NC}"
    echo -e "${YELLOW}  API rate limits will be very restrictive (60 requests/hour)${NC}"
    echo -e "${YELLOW}  Set it with: export GITHUB_TOKEN=your_token${NC}"
    echo ""
    echo -e "Continue anyway? (y/n) "
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        echo "Exiting..."
        exit 0
    fi
    echo ""
fi

# Check if dependencies are installed
echo -e "${BLUE}→${NC} Checking dependencies..."
if ! python3 -c "import github" 2>/dev/null; then
    echo -e "${YELLOW}  PyGithub not installed. Installing dependencies...${NC}"
    pip install -r requirements.txt
fi
echo -e "${GREEN}✓${NC} Dependencies ready"
echo ""

# Run the scanner
echo -e "${BLUE}→${NC} Scanning GitHub for cagent blogs and articles..."
echo ""
python3 scan_github_tools.py

# Check if results were found
if [ -f "new_tools_found.md" ]; then
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Scan Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check if blogs were found
    if grep -q "### Blogs & Articles" new_tools_found.md; then
        blog_count=$(grep -A 100 "### Blogs & Articles" new_tools_found.md | grep -c "^|" || echo "0")
        blog_count=$((blog_count - 2))  # Subtract header rows
        if [ "$blog_count" -gt 0 ]; then
            echo -e "${GREEN}Found $blog_count new blog(s)/article(s)!${NC}"
            echo ""
            echo -e "${BLUE}Preview of blogs found:${NC}"
            echo ""
            grep -A $((blog_count + 2)) "### Blogs & Articles" new_tools_found.md
            echo ""
        else
            echo -e "${YELLOW}No new blogs found (all may already be in the awesome list)${NC}"
        fi
    else
        echo -e "${YELLOW}No new blogs found${NC}"
    fi
    
    echo -e "${BLUE}→${NC} Full results saved to: ${GREEN}new_tools_found.md${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Review the results in new_tools_found.md"
    echo -e "  2. Verify blog quality and relevance"
    echo -e "  3. Add appropriate entries to README.md"
    echo ""
else
    echo -e "${RED}✗ Scanner did not produce output${NC}"
    exit 1
fi

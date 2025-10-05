#!/usr/bin/env bash

# Script to search and access Docker containers interactively
# Compatible with both bash and fish shells

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Check if search term is provided
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <search_term>${NC}"
    echo -e "${YELLOW}Example: $0 nginx${NC}"
    exit 1
fi

SEARCH_TERM="$1"

# Find containers matching the search term
echo -e "${CYAN}${BOLD}🔍 Searching for containers matching: ${YELLOW}$SEARCH_TERM${NC}"
CONTAINERS=$(docker ps --format "{{.ID}}\t{{.Names}}\t{{.Status}}" | grep -i "$SEARCH_TERM")

if [ -z "$CONTAINERS" ]; then
    echo -e "${RED}❌ No running containers found matching: $SEARCH_TERM${NC}"
    exit 1
fi

# Display found containers
echo -e "\n${GREEN}${BOLD}✓ Found containers:${NC}"
echo "$CONTAINERS" | nl -w2 -s'. ' | while IFS= read -r line; do
    echo -e "${BLUE}$line${NC}"
done
echo ""

# If only one container, use it automatically
CONTAINER_COUNT=$(echo "$CONTAINERS" | wc -l)
if [ "$CONTAINER_COUNT" -eq 1 ]; then
    CONTAINER_ID=$(echo "$CONTAINERS" | awk '{print $1}')
    echo -e "${MAGENTA}➜ Only one container found, using: ${CYAN}$CONTAINER_ID${NC}\n"
else
    # Let user select which container
    echo -n -e "${YELLOW}Select container number (1-$CONTAINER_COUNT): ${NC}"
    read SELECTION
    
    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$CONTAINER_COUNT" ]; then
        echo -e "${RED}❌ Invalid selection${NC}"
        exit 1
    fi
    
    CONTAINER_ID=$(echo "$CONTAINERS" | sed -n "${SELECTION}p" | awk '{print $1}')
fi

echo -e "${BLUE}${BOLD}🐳 Accessing container: ${CYAN}$CONTAINER_ID${NC}\n"

# Array of shells to try
SHELLS=("bash" "sh" "ash" "zsh" "fish")

# Try each shell until one works
for SHELL in "${SHELLS[@]}"; do
    echo -e "${YELLOW}⚡ Trying shell: ${BOLD}$SHELL${NC}"
    if docker exec "$CONTAINER_ID" which "$SHELL" > /dev/null 2>&1 || \
       docker exec "$CONTAINER_ID" test -x "/bin/$SHELL" 2>/dev/null || \
       docker exec "$CONTAINER_ID" test -x "/usr/bin/$SHELL" 2>/dev/null; then
        echo -e "${GREEN}${BOLD}✓ Shell $SHELL found! Connecting...${NC}\n"
        docker exec -it "$CONTAINER_ID" "$SHELL"
        echo -e "\n${MAGENTA}Session ended.${NC}"
        exit 0
    else
        echo -e "${RED}✗ Shell $SHELL not available, trying next...${NC}"
    fi
done

# If all shells fail, try default sh as last resort
echo -e "${YELLOW}${BOLD}⚠ No standard shell found, trying default /bin/sh as last resort${NC}"
docker exec -it "$CONTAINER_ID" /bin/sh
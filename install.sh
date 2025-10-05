#!/usr/bin/env bash

# Installation script for docker-interactive
# Detects current shell and installs accordingly

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}🚀 Docker Interactive Shell - Installation Script${NC}\n"

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
echo -e "${BLUE}📍 Detected shell: ${CYAN}${BOLD}$CURRENT_SHELL${NC}\n"

# Define script name and installation path
SCRIPT_NAME="dockerit"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# Check if dockerit.sh exists in current directory
if [ ! -f "dockerit.sh" ]; then
    echo -e "${RED}❌ Error: dockerit.sh not found in current directory${NC}"
    echo -e "${YELLOW}Please run this installer from the same directory as dockerit.sh${NC}"
    exit 1
fi

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}📁 Creating directory: $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Copy script to installation directory
echo -e "${BLUE}📋 Copying script to $SCRIPT_PATH${NC}"
cp dockerit.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Script installed successfully!${NC}\n"
else
    echo -e "${RED}❌ Error installing script${NC}"
    exit 1
fi

# Function to add PATH to shell config if not present
add_to_path() {
    local config_file=$1
    local shell_name=$2
    
    if [ -f "$config_file" ]; then
        # Check if PATH already contains .local/bin
        if grep -q ".local/bin" "$config_file"; then
            echo -e "${GREEN}✓ PATH already configured in $config_file${NC}"
        else
            echo -e "${YELLOW}📝 Adding $INSTALL_DIR to PATH in $config_file${NC}"
            echo "" >> "$config_file"
            echo "# Added by docker-interactive installer" >> "$config_file"
            if [ "$shell_name" = "fish" ]; then
                echo "set -gx PATH \$PATH $INSTALL_DIR" >> "$config_file"
            else
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$config_file"
            fi
            echo -e "${GREEN}✓ PATH updated in $config_file${NC}"
            return 0
        fi
    else
        echo -e "${YELLOW}⚠ Creating $config_file${NC}"
        if [ "$shell_name" = "fish" ]; then
            mkdir -p "$(dirname "$config_file")"
            echo "# Added by docker-interactive installer" > "$config_file"
            echo "set -gx PATH \$PATH $INSTALL_DIR" >> "$config_file"
        else
            echo "# Added by docker-interactive installer" > "$config_file"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$config_file"
        fi
        echo -e "${GREEN}✓ Created $config_file and added PATH${NC}"
        return 0
    fi
    return 1
}

# Configure based on detected shell
PATH_UPDATED=false

case "$CURRENT_SHELL" in
    bash)
        echo -e "${MAGENTA}🐚 Configuring for Bash...${NC}"
        if [ -f "$HOME/.bashrc" ]; then
            add_to_path "$HOME/.bashrc" "bash" && PATH_UPDATED=true
        fi
        if [ -f "$HOME/.bash_profile" ]; then
            add_to_path "$HOME/.bash_profile" "bash"
        fi
        ;;
    
    zsh)
        echo -e "${MAGENTA}🐚 Configuring for Zsh...${NC}"
        add_to_path "$HOME/.zshrc" "zsh" && PATH_UPDATED=true
        ;;
    
    fish)
        echo -e "${MAGENTA}🐚 Configuring for Fish...${NC}"
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        add_to_path "$FISH_CONFIG" "fish" && PATH_UPDATED=true
        ;;
    
    *)
        echo -e "${YELLOW}⚠ Unknown shell: $CURRENT_SHELL${NC}"
        echo -e "${YELLOW}Please manually add $INSTALL_DIR to your PATH${NC}"
        ;;
esac

echo ""
echo -e "${GREEN}${BOLD}✅ Installation completed!${NC}\n"
echo -e "${CYAN}Usage:${NC}"
echo -e "  ${BOLD}$SCRIPT_NAME <search_term>${NC}"
echo -e "${CYAN}Example:${NC}"
echo -e "  ${BOLD}$SCRIPT_NAME nginx${NC}"
echo -e "  ${BOLD}$SCRIPT_NAME postgres${NC}\n"

if [ "$PATH_UPDATED" = true ]; then
    echo -e "${YELLOW}⚠ Please restart your terminal or run:${NC}"
    case "$CURRENT_SHELL" in
        bash)
            echo -e "  ${BOLD}source ~/.bashrc${NC}"
            ;;
        zsh)
            echo -e "  ${BOLD}source ~/.zshrc${NC}"
            ;;
        fish)
            echo -e "  ${BOLD}source ~/.config/fish/config.fish${NC}"
            ;;
    esac
    echo ""
else
    echo -e "${GREEN}You can use ${BOLD}$SCRIPT_NAME${NC}${GREEN} right away!${NC}\n"
fi
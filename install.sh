#!/bin/bash
# Dotfiles installation script for Mac

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}Dotfiles Installation for Mac${NC}"
echo -e "${GREEN}===================================${NC}"
echo ""

# List of dotfiles to symlink
DOTFILES=(
    ".zshrc"
    ".bash_profile"
    ".gitconfig"
    ".gitignore_global"
    ".vimrc"
)

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo -e "${YELLOW}Warning: $target already exists${NC}"
        read -p "Do you want to backup and replace it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy](es)?$ ]] || [[ $REPLY == "YES" ]]; then
            mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "${GREEN}Created backup${NC}"
        else
            echo -e "${YELLOW}Skipping $target${NC}"
            return
        fi
    fi
    
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Linked: $target -> $source${NC}"
}

# Create symlinks for each dotfile
echo "Creating symlinks..."
echo ""

for dotfile in "${DOTFILES[@]}"; do
    source_file="$DOTFILES_DIR/$dotfile"
    target_file="$HOME/$dotfile"
    
    if [ -f "$source_file" ]; then
        create_symlink "$source_file" "$target_file"
    else
        echo -e "${RED}Error: $source_file not found${NC}"
    fi
done

echo ""
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}===================================${NC}"
echo ""
echo "Next steps:"
echo "1. Edit ~/.gitconfig to set your name and email"
echo "2. Restart your terminal or run: source ~/.zshrc (or source ~/.bash_profile)"
echo ""
echo -e "${YELLOW}Note: Backed up files have the extension .backup.YYYYMMDD_HHMMSS${NC}"

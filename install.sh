#!/bin/bash

# Dotfiles installation script
# Creates symlinks from ~/.config to ~/projects/dotfiles/.config

set -e  # Exit on error

DOTFILES_DIR="$HOME/projects/dotfiles"
CONFIG_DIR="$HOME/.config"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Apps to symlink
APPS=("alacritty" "nvim" "opencode" "tmux")

echo "Setting up dotfiles..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Config directory: $CONFIG_DIR"
echo ""

# Create .config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Loop through each app
for app in "${APPS[@]}"; do
    SOURCE="$DOTFILES_DIR/.config/$app"
    TARGET="$CONFIG_DIR/$app"

                # Check if source exists
                if [ ! -e "$SOURCE" ]; then
                    echo -e "${YELLOW}Warning: $SOURCE does not exist, skipping...${NC}"
                    continue
                fi

                                                # Handle existing target
                                                if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
                                                    if [ -L "$TARGET" ]; then
                                                        echo "Removing existing symlink: $TARGET"
                                                        rm "$TARGET"
                                                    else
                                                        BACKUP="$TARGET.backup.$(date +%Y%m%d_%H%M%S)"
                                                        echo "Backing up existing config: $TARGET -> $BACKUP"
                                                        mv "$TARGET" "$BACKUP"
                                                    fi
                                                fi

                                                                                                                                                    # Create symlink
                                                                                                                                                    ln -s "$SOURCE" "$TARGET"
                                                                                                                                                    echo -e "${GREEN}✓${NC} Linked $app"
                                                                                                                                                done

                                                                                                                                                echo ""
                                                                                                                                                echo -e "${GREEN}Done!${NC} Dotfiles installed successfully."

#!/bin/bash

echo "================================"
echo "bashrc-run-command Installer"
echo "================================"
echo ""

BASE_URL="https://raw.githubusercontent.com/Tim-Dieters/bashrc-run-command/refs/heads/main"
BASHRC_DIR="$HOME/.bashrc.d"

FILES=(
  ".bashrc.d/utils.sh"
  ".bashrc.d/frontend.sh"
  ".bashrc.d/backend.sh"
  ".bashrc.d/update.sh"
)

REMOTE_BASHRC="bashrc"     # File in repo
LOCAL_BASHRC=".bashrc"     # File name to install locally

echo "This will install the bashrc-run-command system to your home directory."
echo "Installation directory: $HOME"
echo ""

# Check if .bashrc already exists
if [[ -f "$HOME/$LOCAL_BASHRC" ]]; then
  read -p ".bashrc already exists. Do you want to backup and replace it? (y/n) " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/$LOCAL_BASHRC" "$backup_file"
    echo "Backed up existing .bashrc to: $backup_file"
  else
    echo "Installation cancelled."
    exit 1
  fi
fi

# Create .bashrc.d directory if it doesn't exist
echo "Creating directory: $BASHRC_DIR"
mkdir -p "$BASHRC_DIR"

# Download all modular scripts
echo ""
echo "Downloading modular scripts..."
for file in "${FILES[@]}"; do
  local_file="$HOME/$file"
  remote_url="$BASE_URL/$file"
  
  echo "  - Downloading $(basename "$file")..."
  if curl -sS -f "$remote_url" -o "$local_file"; then
    chmod +x "$local_file"
    echo "    ✓ Successfully downloaded"
  else
    echo "    ✗ Failed to download $file"
    exit 1
  fi
done

# Download main .bashrc file
echo ""
echo "Downloading main .bashrc file..."
if curl -sS -f "$BASE_URL/$REMOTE_BASHRC" -o "$HOME/$LOCAL_BASHRC"; then
  echo "  ✓ Successfully downloaded .bashrc"
else
  echo "  ✗ Failed to download .bashrc"
  exit 1
fi

echo ""
echo "================================"
echo "Installation complete!"
echo "================================"
echo ""
echo "To start using the commands, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or simply restart your terminal."
echo ""
echo "Type 'run help' to see available commands."
echo ""

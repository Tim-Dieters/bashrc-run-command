#!/bin/bash

echo "================================"
echo "bashrc-run-command Installer"
echo "================================"
echo ""

BASE_URL="https://raw.githubusercontent.com/Tim-Dieters/bashrc-run-command/refs/heads/main"
BASHRC_DIR="$HOME/.bashrc.d"
BASHRC_FILE=".bashrc"

echo "This will install the bashrc-run-command system to your home directory."
echo "Installation directory: $HOME"
echo ""

# Check if .bashrc already exists
if [[ -f "$HOME/$BASHRC_FILE" ]]; then
  read -p ".bashrc already exists. Do you want to backup and replace it? (y/n) " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/$BASHRC_FILE" "$backup_file"
    echo "Backed up existing .bashrc to: $backup_file"
  else
    echo "Installation cancelled."
    exit 1
  fi
fi

# Create .bashrc.d directory if it doesn't exist
echo "Creating directory: $BASHRC_DIR"
mkdir -p "$BASHRC_DIR"

# Download index.json to determine which files to install
echo ""
echo "Fetching installation index..."
INDEX_URL="$BASE_URL/.bashrc.d/index.json"
LOCAL_INDEX="$BASHRC_DIR/index.json"

if curl -sS -f "$INDEX_URL" -o "$LOCAL_INDEX"; then
  echo "  ✓ Retrieved index.json"
else
  echo "  ✗ Failed to download index.json"
  exit 1
fi

# Parse JSON to get file list (using basic grep/sed since jq might not be available)
FILES=()
while IFS= read -r line; do
  if [[ "$line" =~ \"([^\"]+\.sh)\" ]]; then
    FILES+=("${BASH_REMATCH[1]}")
  fi
done < "$LOCAL_INDEX"

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "  ✗ No files found in index.json"
  exit 1
fi

echo "  Found ${#FILES[@]} module(s) to install"

# Download all modular scripts
echo ""
echo "Downloading modular scripts..."
for file in "${FILES[@]}"; do
  local_file="$BASHRC_DIR/$file"
  remote_url="$BASE_URL/.bashrc.d/$file"
  
  echo "  - Downloading $file..."
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
if curl -sS -f "$BASE_URL/$BASHRC_FILE" -o "$HOME/$BASHRC_FILE"; then
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
echo "Reloading .bashrc..."
source "$HOME/.bashrc"
echo "✓ .bashrc loaded successfully!"
echo ""
echo "Type 'run help' to see available commands."
echo ""
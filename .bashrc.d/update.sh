# update functions
run_update() {
  echo "Checking for updates..."
  
  local base_url="https://raw.githubusercontent.com/Tim-Dieters/bashrc-run-command/refs/heads/main"
  local files=(
    ".bashrc"
    ".bashrc.d/utils.sh"
    ".bashrc.d/frontend.sh"
    ".bashrc.d/backend.sh"
    ".bashrc.d/update.sh"
  )
  
  local temp_dir=$(mktemp -d)
  local has_updates=false
  local update_list=()
  
  # Check each file for updates
  for file in "${files[@]}"; do
    local remote_url="$base_url/$file"
    local local_file="$HOME/$file"
    local temp_file="$temp_dir/$(basename "$file")"
    
    if curl -sS "$remote_url" -o "$temp_file" 2>/dev/null; then
      if [[ -f "$local_file" ]]; then
        if ! diff -q "$local_file" "$temp_file" >/dev/null 2>&1; then
          has_updates=true
          update_list+=("$file")
        fi
      else
        has_updates=true
        update_list+=("$file (new)")
      fi
    fi
  done
  
  if [[ "$has_updates" == false ]]; then
    echo "Already up to date!"
    rm -rf "$temp_dir"
    return 0
  fi
  
  echo "Updates available for:"
  for item in "${update_list[@]}"; do
    echo "  - $item"
  done
  echo ""
  
  read -p "Do you want to update? (y/n) " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Apply updates
    for file in "${files[@]}"; do
      local remote_url="$base_url/$file"
      local local_file="$HOME/$file"
      local temp_file="$temp_dir/$(basename "$file")"
      
      if [[ -f "$temp_file" ]]; then
        # Create directory if needed
        local file_dir=$(dirname "$local_file")
        mkdir -p "$file_dir"
        
        cp "$temp_file" "$local_file"
        echo "Updated: $file"
      fi
    done
    
    rm -rf "$temp_dir"
    echo "Update complete! Reloading .bashrc..."
    source "$HOME/.bashrc"
    echo "All updates applied successfully!"
  else
    rm -rf "$temp_dir"
    echo "Update cancelled."
  fi
}

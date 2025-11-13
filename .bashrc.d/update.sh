# update functions
run_update() {
  echo "Checking for updates..."
  
  local base_url="https://raw.githubusercontent.com/Tim-Dieters/bashrc-run-command/refs/heads/main"
  
  # Fetch the index.json to get the list of files
  local index_url="$base_url/.bashrc.d/index.json"
  local local_index="$HOME/.bashrc.d/index.json"
  
  if ! curl -sS -f "$index_url" -o "$local_index" 2>/dev/null; then
    echo "Error: Could not fetch index.json from repository"
    return 1
  fi
  
  # Parse JSON to get file list (using basic grep/sed since jq might not be available)
  local module_files=()
  while IFS= read -r line; do
    if [[ "$line" =~ \"([^\"]+\.sh)\" ]]; then
      module_files+=(".bashrc.d/${BASH_REMATCH[1]}")
    fi
  done < "$local_index"
  
  # Add .bashrc to the files list
  local files=(
    ".bashrc"
    "${module_files[@]}"
  )
  
  local temp_dir=$(mktemp -d)
  local has_updates=false
  local update_list=()
  local downloaded_files=()
  local files_to_remove=()
  
  # Get list of currently installed module files
  local installed_modules=()
  if [[ -d "$HOME/.bashrc.d" ]]; then
    for local_sh in "$HOME/.bashrc.d"/*.sh; do
      if [[ -f "$local_sh" ]]; then
        local basename_file=$(basename "$local_sh")
        installed_modules+=(".bashrc.d/$basename_file")
      fi
    done
  fi
  
  # Check for files that exist locally but not in remote index (removed from repo)
  for installed in "${installed_modules[@]}"; do
    local found=false
    for remote in "${files[@]}"; do
      if [[ "$installed" == "$remote" ]]; then
        found=true
        break
      fi
    done
    if [[ "$found" == false ]]; then
      has_updates=true
      files_to_remove+=("$installed")
      update_list+=("$installed (will be removed)")
    fi
  done
  
  # Check each file for updates
  for file in "${files[@]}"; do
    local remote_url="$base_url/$file"
    local local_file="$HOME/$file"
    local temp_file="$temp_dir/$(basename "$file")-${file//\//_}"
    
    if curl -sS -f "$remote_url" -o "$temp_file" 2>/dev/null; then
      downloaded_files+=("$file:$temp_file")
      if [[ -f "$local_file" ]]; then
        if ! diff -q "$local_file" "$temp_file" >/dev/null 2>&1; then
          has_updates=true
          update_list+=("$file (modified)")
        fi
      else
        has_updates=true
        update_list+=("$file (new)")
      fi
    else
      echo "Warning: Could not fetch $file from GitHub (may not exist in repository yet)"
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
    # Remove files that are no longer in the index
    for file in "${files_to_remove[@]}"; do
      local local_file="$HOME/$file"
      if [[ -f "$local_file" ]]; then
        rm "$local_file"
        echo "Removed: $file"
      fi
    done
    
    # Apply updates
    for entry in "${downloaded_files[@]}"; do
      local file="${entry%%:*}"
      local temp_file="${entry#*:}"
      local local_file="$HOME/$file"
      
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

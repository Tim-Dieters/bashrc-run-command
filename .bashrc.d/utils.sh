# browser functions
open_browser() {
  local url="$1"

  if [[ -z "$url" ]]; then
    echo "No URL provided"
    return 1
  fi

  # Check if NO_BROWSER is set
  if [[ "$NO_BROWSER" == "1" ]]; then
    return 0
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url"
  elif command -v open >/dev/null 2>&1; then
    open "$url"
  elif command -v start >/dev/null 2>&1; then
    start "$url"
  else
    echo "Cannot open browser: no known command found"
    return 1
  fi
}



# file and directory functions
has_file() {
  local filename="$1"
  [[ -f "$filename" ]]
}

find_child_with() {
  local filename="$1"
  for dir in */; do
    if [[ -f "$dir/$filename" ]]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

change_dir_if_needed() {
  local target_dir="$1"
  if [[ -n "$target_dir" ]]; then
    cd "$target_dir" || exit 1
  fi
}

run_project() {
  local filename="$1"
  local run_command="$2"

  if has_file "$filename"; then
    "$run_command"
    return
  fi

  local dir
  dir=$(find_child_with "$filename")
  if [[ -n "$dir" ]]; then
    read -p "Use $dir? (y/[Enter]=yes, n=stop) " input
    if [[ -z "$input" || "$input" == "y" ]]; then
      "$run_command" "$dir"
      return
    else
      echo "Stopped"
      return 1
    fi
  fi

  echo "No $filename found in current or child directories."
  return 1
}

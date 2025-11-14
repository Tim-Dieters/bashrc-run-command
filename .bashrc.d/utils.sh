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
    local dir_name=$(basename "$dir")
    if confirm_action "Run project in child folder $dir_name?"; then
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



# project setup functions
get_project_name() {
  local prompt_text="${1:-Enter project name}"
  local project_name
  
  read -p "$prompt_text: " project_name
  if [[ -z "$project_name" ]]; then
    echo "Project name cannot be empty. Aborting." >&2
    return 1
  fi

  if [[ -d "$project_name" ]]; then
    echo "Error: Directory '$project_name' already exists." >&2
    return 1
  fi

  echo "$project_name"
}

download_github_file() {
  local url="$1"
  local output="$2"
  local fail_on_error="${3:-true}"

  if curl -sS -f "$url" -o "$output" 2>/dev/null; then
    return 0
  else
    if [[ "$fail_on_error" == "true" ]]; then
      echo "Error: Could not download file from $url" >&2
      return 1
    fi
    return 1
  fi
}

update_env_variable() {
  local env_file="${1:-.env}"
  local variable_name="$2"
  local variable_value="$3"

  if [[ ! -f "$env_file" ]]; then
    echo "Error: $env_file not found" >&2
    return 1
  fi

  if grep -q "^$variable_name=" "$env_file"; then
    sed -i "s|^$variable_name=.*|$variable_name=\"$variable_value\"|" "$env_file"
  else
    echo "" >> "$env_file"
    echo "# $variable_name" >> "$env_file"
    echo "$variable_name=\"$variable_value\"" >> "$env_file"
  fi
}

confirm_action() {
  local prompt="${1:-Continue?}"
  local selected=0
  
  trap 'echo -ne "\r\033[K$prompt \033[31mNo\033[0m\n"; tput cnorm; trap - INT; return 1' INT
  
  tput civis
  
  while true; do
    echo -ne "\r\033[K$prompt "

    if [[ $selected -eq 0 ]]; then
      echo -ne "\033[7m Yes \033[0m / No"
    else
      echo -ne "Yes / \033[7m No \033[0m"
    fi
    
    read -rsn1 key
    
    case "$key" in
      $'\x1b')
        read -rsn2 -t 0.1 key
        if [[ -z "$key" ]]; then
          selected=1
          break
        fi
        case "$key" in
          '[A'|'[D')
            selected=0
            ;;
          '[B'|'[C')
            selected=1
            ;;
        esac
        ;;
      'y'|'Y')
        selected=0
        break
        ;;
      'n'|'N')
        selected=1
        break
        ;;
      '')
        break
        ;;
    esac
  done
  
  echo -ne "\r\033[K$prompt "
  if [[ $selected -eq 0 ]]; then
    echo -e "\033[32mYes\033[0m"
  else
    echo -e "\033[31mNo\033[0m"
  fi
  
  tput cnorm
  trap - INT
  
  return $selected
}

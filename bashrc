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



# frontend functions
run_npm() {
  change_dir_if_needed "$1"

  open_browser "http://localhost:5173"
  npm run dev
}



# backend functions
ensure_project_name() {
  if [[ ! -f .my-nano-config ]]; then
    read -p "Enter a project name: " pname
    if [[ -z "$pname" ]]; then
      echo "Project name cannot be empty. Aborting." >&2
      return 1
    fi
    echo "$pname" > .my-nano-config
    echo "Saved project name to .my-nano-config: '$pname'" >&2
  fi
  project_naam=$(<.my-nano-config)
  echo "$project_naam"
}

check_docker() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  echo "Docker is not running. Attempting to start Docker..."
  
  # Common Docker Desktop paths
  local docker_paths=(
    "/c/Program Files/Docker/Docker/Docker Desktop.exe"
    "C:/Program Files/Docker/Docker/Docker Desktop.exe"
    "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
  )

  local docker_found=false
  for docker_path in "${docker_paths[@]}"; do
    if [[ -f "$docker_path" ]]; then
      echo "Found Docker at: $docker_path"
      "$docker_path" &
      docker_found=true
      break
    fi
  done

  if [[ "$docker_found" == false ]]; then
    echo "Error: Docker Desktop not found. Please install Docker or start it manually."
    echo "Run Docker before use."
    return 1
  fi

  echo "Waiting for Docker to start..."
  local max_wait=60
  local waited=0
  while ! docker info >/dev/null 2>&1; do
    if [[ $waited -ge $max_wait ]]; then
      echo "Error: Docker failed to start within ${max_wait} seconds."
      echo "Please start Docker manually and try again."
      return 1
    fi
    sleep 2
    waited=$((waited + 2))
    echo -n "."
  done
  echo ""
  echo "Docker is now running!"
  return 0
}

run_symfony() {
  change_dir_if_needed "$1"

  if ! check_docker; then
    return 1
  fi

  project_naam=$(ensure_project_name) || return 1

  docker-compose -p "$project_naam" down
  docker-compose -p "$project_naam" up -d

  echo "Waiting for Docker services to start..."
  sleep 1

  open_browser "http://localhost:8080/index.php?route=/database/structure&db=app"
  open_browser "http://localhost:8000/_profiler"

  symfony server:stop
  symfony serve
}

stop_symfony() {
  change_dir_if_needed "$1"

  project_naam=$(ensure_project_name) || return 1

  symfony server:stop
  docker-compose -p "$project_naam" down
  echo "Stopped"
}


# commands
alias    c="php bin/console"
run()    { _run_body "$@"; }
r()      { _run_body "$@"; }
runrun() { NO_BROWSER=1 _run_body "$@"; }
rr()     { NO_BROWSER=1 _run_body "$@"; }

_run_body() {
  if [[ -z "$1" ]]; then
    echo "No command provided. Run 'run help' for a list of commands."
    return 1
  fi

  case "$1" in
    help|h)
      echo "Available commands:"
      echo ""
      echo "Main aliases:"
      echo "  run   | r      - Execute commands (opens browser when applicable)"
      echo "  runrun| rr     - Execute commands without opening browser"
      echo ""
      echo "Commands:"
      echo "  config  | c    - Edit .bashrc configuration file"
      echo "  reload  | r    - Reload .bashrc to apply changes"
      echo "  update  | u    - Check for and install updates from GitHub"
      echo "  frontend| f    - Start frontend development server (port 5173)"
      echo "  backend | b    - Start backend with Docker and Symfony server (Automatically checks and starts Docker if needed)"
      echo "  stop    | s    - Stop services:"
      echo "                   - 'stop backend' or 's b' - Stop backend and Docker"
      echo "  credits | c    - Visit credits page"
      echo "  help    | h    - Show this help message"
      ;;

    config|c)
      code "$HOME/.bashrc"
      ;;

    reload|r)
      source ~/.bashrc
      echo "Reloaded .bashrc"
      ;;

    goat|g)
      open_browser "https://www.youtube.com/watch?v=Qy0beYgk1Ds&t=2s"
      ;;

    credits|c)
      open_browser "https://timdieters.nl"
      ;;

    update|u)
      echo "Checking for updates..."
      local remote_url="https://raw.githubusercontent.com/Tim-Dieters/bashrc-run-command/refs/heads/main/bashrc"
      local temp_file=$(mktemp)
      
      if curl -sS "$remote_url" -o "$temp_file"; then
        if diff -q "$HOME/.bashrc" "$temp_file" >/dev/null 2>&1; then
          echo "Already up to date!"
          rm "$temp_file"
        else
          echo "Update available. Differences found:"
          diff "$HOME/.bashrc" "$temp_file" || true
          echo ""
          read -p "Do you want to update? (y/n) " confirm
          if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            cp "$temp_file" "$HOME/.bashrc"
            rm "$temp_file"
            echo "Updated successfully! Reloading .bashrc..."
            source "$HOME/.bashrc"
            echo "Update complete!"
          else
            rm "$temp_file"
            echo "Update cancelled."
          fi
        fi
      else
        rm "$temp_file" 2>/dev/null || true
        echo "Error: Failed to fetch update from GitHub."
        return 1
      fi
      ;;

    frontend|f)
      run_project "package.json" run_npm
      ;;

    backend|b)
      run_project "composer.json" run_symfony
      ;;

    stop|s)
      case "$2" in
        backend|b)
          run_project "composer.json" stop_symfony
          ;;
        *)
          echo "Unknown stop target: $2"
          return 1
          ;;
      esac
      ;;

    *)
      echo "Not a valid command: $1"
      echo "Run 'run help' for a list of commands."
      return 1
      ;;
  esac
}

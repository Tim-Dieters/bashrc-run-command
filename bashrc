# browser functions
open_browser() {
  local url="$1"

  if [[ -z "$url" ]]; then
    echo "No URL provided"
    return 1
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
    read -p "Voer projectnaam in: " pname
    if [[ -z "$pname" ]]; then
      echo "Geen projectnaam opgegeven. Gestopt."
      return 1
    fi
    echo "$pname" > .my-nano-config
    echo "Projectnaam ingesteld op '$pname'"
  fi
  project_naam=$(<.my-nano-config)
  echo "$project_naam"
}

run_symfony() {
  change_dir_if_needed "$1"

  project_naam=$(ensure_project_name) || return 1

  docker-compose -p "$project_naam" down
  docker-compose -p "$project_naam" up -d

  open_browser "http://localhost:8080"
  open_browser "http://localhost:8000/_profiler"

  symfony server:stop
  symfony serve
}

stop_symfony() {
  change_dir_if_needed "$1"

  project_naam=$(ensure_project_name) || return 1

  echo "Stopping Symfony server and Docker..."
  symfony server:stop
  docker-compose -p "$project_naam" down
  echo "Stopped"
}


# commands
alias c="php bin/console"

run() {
  case "$1" in
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
      return 1
      ;;
  esac
}


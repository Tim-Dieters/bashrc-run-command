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

# frontend functions
run_npm() {
  change_dir_if_needed "$1"

  open_browser "http://localhost:5173"
  npm run dev
}

create_vite_project() {
  read -p "Enter project name: " project_name
  if [[ -z "$project_name" ]]; then
    echo "Project name cannot be empty. Aborting." >&2
    return 1
  fi

  if [[ -d "$project_name" ]]; then
    echo "Error: Directory '$project_name' already exists." >&2
    return 1
  fi

  echo "Creating Vite + React + TypeScript project: $project_name"
  echo ""
  echo "========================================================================================================================"
  echo -e "\033[0;31mVite may ask you to preform additional steps during setup, we reccommend skipping them to avoid issues with our process.\033[0m"
  echo "The installation will continue automatically in 5 seconds."
  echo "========================================================================================================================"
  sleep 5

  npm create vite@latest "$project_name" -- --template react-ts

  if [[ $? -eq 0 ]]; then
    echo "Project created successfully!"
    cd "$project_name" || return 1
    
    echo "Removing default Vite files..."
    rm -rf public/
    rm -rf src/
    rm -f vite.config.ts
    rm -f index.html
    rm -f .env

    echo "Downloading custom template files from GitHub..."
    local base_url="https://raw.githubusercontent.com/Tim-Dieters/bashrc-run-command/refs/heads/main/templates/frontend-template"
    
    # Create directories
    mkdir -p src/Pages/Main
    mkdir -p src/Redux/Api/TestCall
    mkdir -p src/Redux/Slices
    mkdir -p public
    
    # Download root files
    curl -sS -f "$base_url/.env" -o ".env"
    curl -sS -f "$base_url/index.html" -o "index.html"
    curl -sS -f "$base_url/vite.config.ts" -o "vite.config.ts"
    
    # Download src files
    curl -sS -f "$base_url/src/main.tsx" -o "src/main.tsx"
    curl -sS -f "$base_url/src/App.tsx" -o "src/App.tsx"
    curl -sS -f "$base_url/src/index.css" -o "src/index.css"
    curl -sS -f "$base_url/src/vite-env.d.ts" -o "src/vite-env.d.ts"
    
    # Download Pages
    curl -sS -f "$base_url/src/Pages/PageWrapper.tsx" -o "src/Pages/PageWrapper.tsx"
    curl -sS -f "$base_url/src/Pages/Main/MainPage.tsx" -o "src/Pages/Main/MainPage.tsx"
    curl -sS -f "$base_url/src/Pages/Main/Page404.tsx" -o "src/Pages/Main/Page404.tsx"
    
    # Download Redux files
    curl -sS -f "$base_url/src/Redux/Store.ts" -o "src/Redux/Store.ts"
    curl -sS -f "$base_url/src/Redux/Api/Api.ts" -o "src/Redux/Api/Api.ts"
    curl -sS -f "$base_url/src/Redux/Api/TestCall/TestCall.ts" -o "src/Redux/Api/TestCall/TestCall.ts"
    curl -sS -f "$base_url/src/Redux/Api/TestCall/Types.ts" -o "src/Redux/Api/TestCall/Types.ts"
    curl -sS -f "$base_url/src/Redux/Slices/Test.ts" -o "src/Redux/Slices/Test.ts"
    
    # Download public files
    curl -sS -f "$base_url/public/_redirects" -o "public/_redirects"
    curl -sS -f "$base_url/public/robots.txt" -o "public/robots.txt"
    
    echo "Template files downloaded successfully!"
    
    echo "Installing dependencies..."
    npm install tailwindcss @tailwindcss/vite
    npm install framer-motion
    npm install react-redux @reduxjs/toolkit
    npm install react-router-dom
    
    echo ""
    echo "✓ Project setup complete!"
    echo "Starting dev server..."
    echo ""
    open_browser "http://localhost:5173"
    npm run dev
  else
    echo "Error: Failed to create project." >&2
    return 1
  fi
}

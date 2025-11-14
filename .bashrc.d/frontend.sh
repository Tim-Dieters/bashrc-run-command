# frontend functions
run_npm() {
  change_dir_if_needed "$1"

  open_browser "http://localhost:5173"
  npm run dev
}

create_vite_project() {
  local project_name
  project_name=$(get_project_name "Enter project name") || return 1

  echo "Creating Vite + React + TypeScript project: $project_name"
  echo ""
  echo "========================================================================================================================"
  echo -e "\033[0;33mVite may ask you to preform additional steps during setup, we reccommend skipping them to avoid issues with our process.\033[0m"
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
    download_github_file "$base_url/.env" ".env" || return 1
    download_github_file "$base_url/index.html" "index.html" || return 1
    download_github_file "$base_url/vite.config.ts" "vite.config.ts" || return 1
    
    # Download src files
    download_github_file "$base_url/src/main.tsx" "src/main.tsx" || return 1
    download_github_file "$base_url/src/App.tsx" "src/App.tsx" || return 1
    download_github_file "$base_url/src/index.css" "src/index.css" || return 1
    download_github_file "$base_url/src/vite-env.d.ts" "src/vite-env.d.ts" || return 1
    
    # Download Pages
    download_github_file "$base_url/src/Pages/PageWrapper.tsx" "src/Pages/PageWrapper.tsx" || return 1
    download_github_file "$base_url/src/Pages/Main/MainPage.tsx" "src/Pages/Main/MainPage.tsx" || return 1
    download_github_file "$base_url/src/Pages/Main/Page404.tsx" "src/Pages/Main/Page404.tsx" || return 1
    
    # Download Redux files
    download_github_file "$base_url/src/Redux/Store.ts" "src/Redux/Store.ts" || return 1
    download_github_file "$base_url/src/Redux/Api/Api.ts" "src/Redux/Api/Api.ts" || return 1
    download_github_file "$base_url/src/Redux/Api/TestCall/TestCall.ts" "src/Redux/Api/TestCall/TestCall.ts" || return 1
    download_github_file "$base_url/src/Redux/Api/TestCall/Types.ts" "src/Redux/Api/TestCall/Types.ts" || return 1
    download_github_file "$base_url/src/Redux/Slices/Test.ts" "src/Redux/Slices/Test.ts" || return 1
    
    # Download public files
    download_github_file "$base_url/public/_redirects" "public/_redirects" || return 1
    download_github_file "$base_url/public/robots.txt" "public/robots.txt" || return 1
    
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

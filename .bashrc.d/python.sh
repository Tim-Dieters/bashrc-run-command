# Python functions
setup_project() {
  read -p "Enter the main Python script to run (e.g., app.py): " script_name
  if [[ -z "$script_name" ]]; then
    echo "No script name provided."
    return 1
  fi
  echo "$script_name" > .my-nano-config
  echo "Saved '$script_name' to .my-nano-config"
}

run_project_python() {
  if [[ ! -f .my-nano-config ]]; then
    echo ".my-nano-config not found. Run 'py s' to set up first."
    return 1
  fi
  script_name=$(cat .my-nano-config)
  if [[ ! -f "$script_name" ]]; then
    echo "Script file '$script_name' not found."
    return 1
  fi
  python "$script_name"
}

install_project() {
  spec_file=$(find . -maxdepth 1 -name "*.spec" -type f | head -1)
  if [[ -z "$spec_file" ]]; then
    echo "No .spec file found in current directory."
    return 1
  fi
  pyinstaller "$spec_file"
}

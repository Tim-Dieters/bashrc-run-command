# frontend functions
run_npm() {
  change_dir_if_needed "$1"

  open_browser "http://localhost:5173"
  npm run dev
}

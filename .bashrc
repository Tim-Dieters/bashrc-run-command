# Load modular scripts
BASHRC_DIR="$HOME/.bashrc.d"
if [[ -d "$BASHRC_DIR" ]]; then
  for script in "$BASHRC_DIR"/*.sh; do
    if [[ -f "$script" ]]; then
      source "$script"
    fi
  done
fi


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
      echo "  credits | c    - Open the creator's site"
      echo "  help    | h    - Show this help message"
      ;;



    config|c)
      code "$HOME/.bashrc.d"
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
      run_update
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

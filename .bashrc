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
run()      { _run_body "$@"; }
r()        { _run_body "$@"; }
runclean() { NO_BROWSER=1 _run_body "$@"; }
rc()       { NO_BROWSER=1 _run_body "$@"; }

alias      c="php bin/console"
py()       { _python_body "$@"; }

_run_body() {
  if [[ -z "$1" ]]; then
    echo "No command provided. Run 'run help' for a list of commands."
    return 1
  fi

  case "$1" in
    help)
      echo "Available commands:"
      echo ""
      echo "Main aliases:"
      echo "  run      | r    - Execute commands (opens browser)"
      echo "  runclean | rc   - Execute commands without opening browser"
      echo ""
      echo "Run commands:"
      echo "  config          - Edit .bashrc configuration file"
      echo "  reload          - Reload .bashrc to apply changes"
      echo "  update          - Check for and install updates from GitHub"
      echo "  frontend | f    - Start frontend development server (port 5173)"
      echo "  backend  | b    - Start backend with Docker and Symfony server (Automatically checks and starts Docker if needed)"
      echo "  create   | c    - Create new projects:"
      echo "                    - frontend | f    - Create Vite + React + TypeScript project"
      echo "                    - backend  | b    - Create Symfony project"
      echo "  stop     | s    - Stop services:"
      echo "                    - backend  | b    - Stop backend and Docker"
      echo "  credits         - Open the creator's site"
      echo "  help            - Show this help message"
      echo ""
      echo ""
      echo ""
      echo "Secondary aliases:"
      echo "  php bin/console | c               - Alias for 'php bin/console'"
      echo "  python          | py              - Python commands:"
      echo "                                      - setup   | s    - Save your main Python script to config"
      echo "                                      - run     | r    - Execute the saved Python script"
      echo "                                      - install | i    - Run pyinstaller with found .spec file"
      ;;



    config)
      code "$HOME/.bashrc.d"
      code "$HOME/.bashrc"
      ;;

    reload)
      source ~/.bashrc
      echo "Reloaded .bashrc"
      ;;

    update)
      run_update
      ;;

    frontend|f)
      run_project "package.json" run_npm
      ;;

    backend|b)
      run_project "composer.json" run_symfony
      ;;

    create|c)
      case "$2" in
        frontend|f)
          create_vite_project
          ;;
        backend|b)
          create_symfony_project
          ;;
        *)
          echo "Unknown create target: $2"
          return 1
          ;;
      esac
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

    goat)
      open_browser "https://www.youtube.com/watch?v=Qy0beYgk1Ds&t=2s"
      ;;

    credits)
      open_browser "https://timdieters.nl"
      ;;

    *)
      echo "Not a valid command: $1"
      echo "Run 'run help' for a list of commands."
      return 1
      ;;
  esac
}

_python_body() {
  case "$1" in
    setup|s)
      setup_project
      ;;
    run|r)
      run_project_python
      ;;
    install|i)
      install_project
      ;;
    *)
      python "$@"
      ;;
  esac
}

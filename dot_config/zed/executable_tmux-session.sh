#!/bin/zsh

SESSION_NAME="main"

# Default variable values
verbose_mode=false
output_file=""

# Function to display script usage
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help      Display this help message"
 echo " -v, --verbose   Enable verbose mode"
 echo " -n, --name      NAME Specify the session name. Defaults to \"main\""
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -v | --verbose)
        verbose_mode=true
        ;;
      -n | --name*)
        if ! has_argument $@; then
          echo "Session not specified. Defaulting to ${SESSION_NAME}" >&2
        else
          SESSION_NAME=$(extract_argument $@)
          shift
        fi

        ;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"
# Check if the session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? -eq 0 ]; then
  # If the session exists, reattach to it
  tmux attach-session -t $SESSION_NAME
else
  # If the session doesn't exist, start a new one
  tmux new-session -s $SESSION_NAME -d
  tmux attach-session -t $SESSION_NAME
fi

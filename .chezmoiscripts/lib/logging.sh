#!/bin/bash

LOG_DIR="$HOME/.local/share/chezmoi/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/$(date +%F_%H-%M-%S).log"

LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR

# Numeric levels for filtering
declare -A LOG_LEVELS=(
  [DEBUG]=0
  [INFO]=1
  [WARN]=2
  [ERROR]=3
)

log_msg() {
  local level=$1
  shift
  local msg="$*"

  # Skip if below current log level
  if (( LOG_LEVELS[$level] < LOG_LEVELS[$LOG_LEVEL] )); then
    return
  fi

  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  local formatted="[$timestamp] [$level] $msg"

  # Console output (pretty)
  case "$level" in
    DEBUG) echo -e "\e[36m$formatted\e[0m" ;; # Cyan
    INFO)  echo -e "\e[32m$formatted\e[0m" ;; # Green
    WARN)  echo -e "\e[33m$formatted\e[0m" ;; # Yellow
    ERROR) echo -e "\e[31m$formatted\e[0m" ;; # Red
  esac

  # File output (no colors)
  echo "$formatted" >> "$LOG_FILE"
}

log_debug() { log_msg DEBUG "$*"; }
log_info()  { log_msg INFO "$*"; }
log_warn()  { log_msg WARN "$*"; }
log_error() { log_msg ERROR "$*"; }
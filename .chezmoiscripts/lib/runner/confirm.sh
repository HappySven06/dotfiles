#!/bin/bash
# Confirmation script - handles user confirmation before execution
# Arguments: $YES flag (from environment)
# Exit codes: 0 = confirmed, 1 = declined or dry-run mode

set -euo pipefail

# Ensure logging is available
if ! type log_info &>/dev/null; then
  echo "Error: logging.sh must be sourced before calling this script" >&2
  exit 1
fi

# Check for dry-run mode
if [[ "${DRY_RUN:-false}" == "true" ]]; then
  log_info "Dry run enabled. Exiting."
  exit 1
fi

# Skip confirmation if YES flag is set
if [[ "${YES:-false}" == "true" ]]; then
  log_info "Auto-confirmed via --yes flag"
  exit 0
fi

# Request user confirmation
log_debug "Awaiting user confirmation..."
read -rp "Continue? [y/N]: " confirm

if [[ "$confirm" != "y" ]]; then
  log_info "User declined execution"
  exit 1
fi

log_info "User confirmed execution"
exit 0
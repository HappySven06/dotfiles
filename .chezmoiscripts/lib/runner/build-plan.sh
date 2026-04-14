#!/bin/bash
# Plan display script - builds and displays the execution plan
# Arguments: $PROFILE, $CONFIG_FILE (from environment)

set -euo pipefail

# Ensure logging is available
if ! type log_info &>/dev/null; then
  echo "Error: logging.sh must be sourced before calling this script" >&2
  exit 1
fi

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/resolution.sh"
source "$SCRIPT_DIR/lib/plan-builder.sh"

# Build the execution plan
FINAL_MODULES=($(build_execution_plan "$PROFILE" "$CONFIG_FILE"))

# Display the plan
log_info "Displaying execution plan"
echo "========== PLAN =========="
for m in "${FINAL_MODULES[@]}"; do
  desc=$(yq ".modules.${m}.description" "$CONFIG_FILE" 2>/dev/null || echo "No description")
  printf "%-15s - %s\n" "$m" "$desc"
done
echo "=========================="

# Export for use by caller or subsequent scripts
export FINAL_MODULES

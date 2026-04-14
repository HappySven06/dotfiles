#!/bin/bash
# Plan builder library - handles execution plan construction and deduplication

# BUILD EXECUTION PLAN - builds ordered, deduplicated module list from profile
# Arguments: $1 = profile name, $2 = config file path
# Returns: space-separated list of modules in execution order
build_execution_plan() {
  local profile=$1
  local config_file=$2
  
  log_info "Building execution plan for profile: $profile"
  
  # Reset arrays
  ORDERED_MODULES=()
  declare -gA SEEN_MODULES=()
  
  # Source resolution library if not already sourced
  if ! type resolve_profiles &>/dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/resolution.sh"
  fi
  
  # Resolve profile hierarchy
  local profiles
  profiles=$(resolve_profiles "$profile" "$config_file")
  
  # For each profile, resolve its modules and their dependencies
  for p in $profiles; do
    local modules
    modules=$(get_profile_modules "$p" "$config_file")
    for m in $modules; do
      resolve_modules "$m" "$config_file"
    done
  done
  
  # Deduplicate while preserving order
  local final_modules=()
  declare -A seen=()
  
  for m in "${ORDERED_MODULES[@]}"; do
    if [[ -z "${seen[$m]:-}" ]]; then
      final_modules+=("$m")
      seen[$m]=1
    fi
  done
  
  log_debug "Resolved ${#final_modules[@]} modules after deduplication"
  
  # Return as space-separated string
  printf "%s\n" "${final_modules[@]}"
}

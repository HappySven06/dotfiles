#!/bin/bash
# Resolution library - handles profile and module dependency resolution

# RESOLVE PROFILES - recursively resolves profile dependencies
# Arguments: $1 = profile name, $2 = config file path
# Returns: ordered list of profiles (with dependencies resolved)
resolve_profiles() {
  local profile=$1
  local config_file=$2
  
  log_debug "Resolving profile: $profile"

  local deps
  deps=$(yq ".profiles.${profile}.depends_on[]" "$config_file" 2>/dev/null || true)

  for dep in $deps; do
    log_debug "  Profile '$profile' depends on '$dep'"
    resolve_profiles "$dep" "$config_file"
  done

  echo "$profile"
}

# GET MODULES FROM PROFILE - retrieves all modules for a given profile
# Arguments: $1 = profile name, $2 = config file path
# Returns: list of module names
get_profile_modules() {
  local profile=$1
  local config_file=$2
  
  log_debug "Retrieving modules for profile: $profile"
  yq ".profiles.${profile}.modules[]" "$config_file" 2>/dev/null || true
}

# RESOLVE MODULES - recursively resolves module dependencies
# Arguments: $1 = module name, $2 = config file path, $3 = reference to ORDERED_MODULES array, $4 = reference to SEEN_MODULES array
# Side effects: modifies ORDERED_MODULES and SEEN_MODULES arrays in caller's scope
resolve_modules() {
  local module=$1
  local config_file=$2
  
  log_debug "Resolving module: $module"

  # Check if already seen
  eval "local seen_check=\${SEEN_MODULES[$module]:-}"
  if [[ -n "$seen_check" ]]; then
    log_debug "  Module '$module' already processed, skipping"
    return
  fi
  
  eval "SEEN_MODULES[$module]=1"

  local deps
  deps=$(yq ".modules.${module}.depends_on[]" "$config_file" 2>/dev/null || true)

  for dep in $deps; do
    log_debug "  Module '$module' depends on '$dep'"
    resolve_modules "$dep" "$config_file"
  done

  ORDERED_MODULES+=("$module")
  log_debug "  Added '$module' to execution order"
}

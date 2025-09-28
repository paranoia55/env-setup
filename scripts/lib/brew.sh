#!/bin/bash
# Homebrew-specific functions

# Only set strict mode if not already set
if [ -z "${BASH_STRICT_MODE:-}" ]; then
    set -euo pipefail
    BASH_STRICT_MODE=1
fi

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Homebrew if not present
install_homebrew() {
    if command_exists brew; then
        log "INFO" "Homebrew already installed: $(brew --version | head -n1)"
        return 0
    fi
    
    log "INFO" "Installing Homebrew..."
    
    # Install Xcode Command Line Tools first
    if ! xcode-select -p >/dev/null 2>&1; then
        log "INFO" "Installing Xcode Command Line Tools..."
        xcode-select --install
        log "INFO" "Please complete the Xcode installation and run the script again"
        return 1
    fi
    
    # Install Homebrew
    local install_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        /bin/bash -c "$(curl -fsSL $install_url)"; then
        log "SUCCESS" "Homebrew installed successfully"
        
        # Add to PATH for Apple Silicon
        if is_apple_silicon; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        return 0
    else
        error_exit "Failed to install Homebrew"
    fi
}

# Update Homebrew
update_homebrew() {
    if ! command_exists brew; then
        log "WARN" "Homebrew not installed, skipping update"
        return 0
    fi
    
    log "INFO" "Updating Homebrew..."
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" brew update; then
        log "SUCCESS" "Homebrew updated"
    else
        log "WARN" "Homebrew update failed, continuing..."
    fi
}

# Install packages from category
install_category() {
    local category="$1"
    local dry_run="${2:-false}"
    
    if ! is_category_enabled "$category"; then
        log "INFO" "Category '$category' is disabled, skipping"
        return 0
    fi
    
    log "INFO" "Installing packages for category: $category"
    
    # Get brew packages
    local brew_packages_str
    brew_packages_str=$(get_packages "$category" "brew")
    if [ -n "$brew_packages_str" ]; then
        mapfile -t brew_packages <<< "$brew_packages_str"
        log "INFO" "Installing brew packages: ${brew_packages[*]}"
        
        if [ "$dry_run" = "true" ]; then
            log "INFO" "DRY RUN: Would install brew packages: ${brew_packages[*]}"
        else
            install_brew_packages "${brew_packages[@]}"
        fi
    fi
    
    # Get cask packages
    local cask_packages_str
    cask_packages_str=$(get_packages "$category" "cask")
    if [ -n "$cask_packages_str" ]; then
        mapfile -t cask_packages <<< "$cask_packages_str"
        log "INFO" "Installing cask packages: ${cask_packages[*]}"
        
        if [ "$dry_run" = "true" ]; then
            log "INFO" "DRY RUN: Would install cask packages: ${cask_packages[*]}"
        else
            install_cask_packages "${cask_packages[@]}"
        fi
    fi
}

# Install brew packages
install_brew_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi
    
    log "INFO" "Installing brew packages: ${packages[*]}"
    
    # Install packages in parallel with job control
    local pids=()
    local max_jobs="${PARALLEL_JOBS:-3}"
    local job_count=0
    
    for package in "${packages[@]}"; do
        # Wait if we've hit the job limit
        while [ "$job_count" -ge "$max_jobs" ]; do
            wait_for_jobs pids
            job_count=${#pids[@]}
        done
        
        # Start background job
        install_single_brew_package "$package" &
        pids+=($!)
        job_count=$((job_count + 1))
    done
    
    # Wait for all jobs to complete
    wait_for_jobs pids
    
    log "SUCCESS" "All brew packages installed"
}

# Install single brew package
install_single_brew_package() {
    local package="$1"
    
    if brew list "$package" >/dev/null 2>&1; then
        log "INFO" "$package: already installed"
        return 0
    fi
    
    log "INFO" "Installing $package..."
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        brew install "$package"; then
        log "SUCCESS" "$package: installed"
    else
        log "ERROR" "$package: installation failed"
        return 1
    fi
}

# Install cask packages
install_cask_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi
    
    log "INFO" "Installing cask packages: ${packages[*]}"
    
    # Install packages in parallel with job control
    local pids=()
    local max_jobs="${PARALLEL_JOBS:-3}"
    local job_count=0
    
    for package in "${packages[@]}"; do
        # Wait if we've hit the job limit
        while [ "$job_count" -ge "$max_jobs" ]; do
            wait_for_jobs pids
            job_count=${#pids[@]}
        done
        
        # Start background job
        install_single_cask_package "$package" &
        pids+=($!)
        job_count=$((job_count + 1))
    done
    
    # Wait for all jobs to complete
    wait_for_jobs pids
    
    log "SUCCESS" "All cask packages installed"
}

# Install single cask package
install_single_cask_package() {
    local package="$1"
    
    if brew list --cask "$package" >/dev/null 2>&1; then
        log "INFO" "$package: already installed"
        return 0
    fi
    
    log "INFO" "Installing $package..."
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        brew install --cask "$package"; then
        log "SUCCESS" "$package: installed"
    else
        log "ERROR" "$package: installation failed"
        return 1
    fi
}

# Wait for background jobs
wait_for_jobs() {
    local -n pids_ref="$1"
    local failed=0
    
    for pid in "${pids_ref[@]}"; do
        if ! wait "$pid"; then
            failed=$((failed + 1))
        fi
    done
    
    pids_ref=()
    
    if [ $failed -gt 0 ]; then
        log "WARN" "$failed background jobs failed"
        return 1
    fi
}

# Create Brewfile from config
create_brewfile() {
    local category="$1"
    local output_file="$2"
    
    log "INFO" "Creating Brewfile for category: $category"
    
    {
        echo "# Brewfile for $category"
        echo "# Generated from config.yaml"
        echo ""
        
        # Add brew packages
        IFS=$'\n' read -d '' -r -a brew_packages < <(get_packages "$category" "brew")
        for package in "${brew_packages[@]}"; do
            echo "brew '$package'"
        done
        
        # Add cask packages
        IFS=$'\n' read -d '' -r -a cask_packages < <(get_packages "$category" "cask")
        for package in "${cask_packages[@]}"; do
            echo "cask '$package'"
        done
        
    } > "$output_file"
    
    log "SUCCESS" "Brewfile created: $output_file"
}

# Install from Brewfile with lock
install_from_brewfile() {
    local brewfile="$1"
    local dry_run="${2:-false}"
    local sync_mode="${3:-false}"
    
    if [ ! -f "$brewfile" ]; then
        log "WARN" "Brewfile not found: $brewfile"
        return 1
    fi
    
    log "INFO" "Installing from Brewfile: $brewfile"
    
    if [ "$dry_run" = "true" ]; then
        log "INFO" "DRY RUN: Would install from $brewfile"
        return 0
    fi
    
    # Create lockfile
    local lockfile="${brewfile}.lock"
    local brew_args="--file=$brewfile --lockfile=$lockfile"
    
    # Add sync mode if requested
    if [ "$sync_mode" = "true" ]; then
        brew_args="$brew_args --no-upgrade"
        log "INFO" "Using sync mode (no upgrades)"
    fi
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        brew bundle install "$brew_args"; then
        log "SUCCESS" "Brewfile installation completed"
    else
        log "ERROR" "Brewfile installation failed"
        return 1
    fi
}

# Sync Brewfile (install only missing packages)
sync_brewfile() {
    local brewfile="$1"
    local dry_run="${2:-false}"
    
    install_from_brewfile "$brewfile" "$dry_run" "true"
}

# Verify Brewfile integrity
verify_brewfile() {
    local brewfile="$1"
    
    if [ ! -f "$brewfile" ]; then
        log "ERROR" "Brewfile not found: $brewfile"
        return 1
    fi
    
    log "INFO" "Verifying Brewfile: $brewfile"
    
    # Check syntax
    if ! brew bundle check --file="$brewfile" 2>/dev/null; then
        log "ERROR" "Brewfile syntax error: $brewfile"
        return 1
    fi
    
    # Check for conflicts
    local conflicts
    conflicts=$(brew bundle check --file="$brewfile" 2>&1 | grep -i conflict || true)
    if [ -n "$conflicts" ]; then
        log "WARN" "Potential conflicts in $brewfile: $conflicts"
    fi
    
    log "SUCCESS" "Brewfile verification passed"
    return 0
}

# Check for port conflicts
check_port_conflicts() {
    local ports=("${LM_STUDIO_PORT:-1234}" "${OPEN_WEBUI_PORT:-3000}")
    local conflicts=()
    
    for port in "${ports[@]}"; do
        if port_in_use "$port"; then
            conflicts+=("$port")
        fi
    done
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        log "WARN" "Port conflicts detected: ${conflicts[*]}"
        log "INFO" "Consider stopping conflicting services or changing ports in config.yaml"
        return 1
    fi
    
    log "SUCCESS" "No port conflicts detected"
    return 0
}

# Cleanup failed installations
cleanup_failed_installs() {
    log "INFO" "Cleaning up failed installations..."
    
    # Remove broken symlinks
    find /usr/local/bin -type l ! -exec test -e {} \; -delete 2>/dev/null || true
    find /opt/homebrew/bin -type l ! -exec test -e {} \; -delete 2>/dev/null || true
    
    # Clean up Homebrew
    if command_exists brew; then
        brew cleanup --prune=all 2>/dev/null || true
        brew doctor 2>/dev/null || true
    fi
    
    log "SUCCESS" "Cleanup completed"
}

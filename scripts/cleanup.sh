#!/bin/bash
# Cleanup script for safe removal of installed components

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Configuration
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT
CONFIG_FILE="${CONFIG_FILE:-$PROJECT_ROOT/config.yaml}"

# Parse arguments
DRY_RUN=false
FORCE=false
KEEP_CONFIG=false

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --keep-config)
                KEEP_CONFIG=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Cleanup Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --dry-run       Show what would be removed without removing
    --force         Skip confirmation prompts
    --keep-config   Keep configuration files
    --help          Show this help message

This script will safely remove:
• Homebrew packages and casks
• VS Code extensions
• AI models and services
• Configuration files (unless --keep-config)
• Log files
• Lock files

WARNING: This will remove all installed components!
EOF
}

# Confirm removal
confirm_removal() {
    if [ "$FORCE" = "true" ]; then
        return 0
    fi
    
    echo
    log "WARN" "This will remove all installed components!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "INFO" "Cleanup cancelled"
        exit 0
    fi
}

# Remove Homebrew packages
remove_homebrew_packages() {
    log "INFO" "Removing Homebrew packages..."
    
    if ! command_exists brew; then
        log "WARN" "Homebrew not found, skipping package removal"
        return 0
    fi
    
    # Get all installed packages from config
    local all_packages=()
    local categories=("core" "frontend" "backend" "business")
    
    for category in "${categories[@]}"; do
        IFS=$'\n' read -d '' -r -a brew_packages < <(get_packages "$category" "brew")
        all_packages+=("${brew_packages[@]}")
        
        IFS=$'\n' read -d '' -r -a cask_packages < <(get_packages "$category" "cask")
        all_packages+=("${cask_packages[@]}")
    done
    
    # Remove duplicates
    IFS=$'\n' read -d '' -r -a unique_packages < <(printf '%s\n' "${all_packages[@]}" | sort -u)
    
    for package in "${unique_packages[@]}"; do
        if [ -n "$package" ]; then
            if [ "$DRY_RUN" = "true" ]; then
                log "INFO" "DRY RUN: Would remove $package"
            else
                if brew list "$package" >/dev/null 2>&1; then
                    log "INFO" "Removing $package..."
                    brew uninstall "$package" 2>/dev/null || log "WARN" "Failed to remove $package"
                elif brew list --cask "$package" >/dev/null 2>&1; then
                    log "INFO" "Removing cask $package..."
                    brew uninstall --cask "$package" 2>/dev/null || log "WARN" "Failed to remove cask $package"
                fi
            fi
        fi
    done
    
    log "SUCCESS" "Homebrew packages removed"
}

# Remove VS Code extensions
remove_vscode_extensions() {
    log "INFO" "Removing VS Code extensions..."
    
    local editors=("code" "cursor" "void")
    
    for editor in "${editors[@]}"; do
        if ! command_exists "$editor"; then
            continue
        fi
        
        log "INFO" "Removing extensions for $editor..."
        
        # Get installed extensions
        IFS=$'\n' read -d '' -r -a extensions < <("$editor" --list-extensions 2>/dev/null || true)
        
        for ext in "${extensions[@]}"; do
            if [ -n "$ext" ]; then
                if [ "$DRY_RUN" = "true" ]; then
                    log "INFO" "DRY RUN: Would remove $ext from $editor"
                else
                    "$editor" --uninstall-extension "$ext" 2>/dev/null || log "WARN" "Failed to remove $ext from $editor"
                fi
            fi
        done
    done
    
    log "SUCCESS" "VS Code extensions removed"
}

# Remove AI models and services
remove_ai_components() {
    log "INFO" "Removing AI components..."
    
    # Stop and remove Ollama models
    if command_exists ollama; then
        if [ "$DRY_RUN" = "true" ]; then
            log "INFO" "DRY RUN: Would remove Ollama models"
        else
            # Stop Ollama service
            pkill -f "ollama serve" 2>/dev/null || true
            
            # Remove models
            IFS=$'\n' read -d '' -r -a models < <(ollama list 2>/dev/null | awk 'NR>1 {print $1}' || true)
            for model in "${models[@]}"; do
                if [ -n "$model" ]; then
                    log "INFO" "Removing model $model..."
                    ollama rm "$model" 2>/dev/null || log "WARN" "Failed to remove model $model"
                fi
            done
        fi
    fi
    
    # Stop and remove Open WebUI container
    if command_exists docker; then
        if [ "$DRY_RUN" = "true" ]; then
            log "INFO" "DRY RUN: Would remove Open WebUI container"
        else
            if docker ps --format "table {{.Names}}" | grep -q "open-webui"; then
                log "INFO" "Stopping Open WebUI container..."
                docker stop open-webui 2>/dev/null || true
                docker rm open-webui 2>/dev/null || true
            fi
        fi
    fi
    
    # Remove OpenAI CLI
    if command_exists pipx && command_exists openai; then
        if [ "$DRY_RUN" = "true" ]; then
            log "INFO" "DRY RUN: Would remove OpenAI CLI"
        else
            log "INFO" "Removing OpenAI CLI..."
            pipx uninstall openai 2>/dev/null || log "WARN" "Failed to remove OpenAI CLI"
        fi
    fi
    
    log "SUCCESS" "AI components removed"
}

# Remove configuration files
remove_config_files() {
    if [ "$KEEP_CONFIG" = "true" ]; then
        log "INFO" "Keeping configuration files (--keep-config)"
        return 0
    fi
    
    log "INFO" "Removing configuration files..."
    
    local config_files=(
        "$HOME/.env-setup-github-user"
        "$HOME/Library/Application Support/void/User/settings.json"
        "$PROJECT_ROOT/.setup.lock"
    )
    
    for file in "${config_files[@]}"; do
        if [ -f "$file" ]; then
            if [ "$DRY_RUN" = "true" ]; then
                log "INFO" "DRY RUN: Would remove $file"
            else
                rm -f "$file"
                log "INFO" "Removed $file"
            fi
        fi
    done
    
    log "SUCCESS" "Configuration files removed"
}

# Remove log files
remove_log_files() {
    log "INFO" "Removing log files..."
    
    local log_dir="$PROJECT_ROOT/logs"
    
    if [ -d "$log_dir" ]; then
        if [ "$DRY_RUN" = "true" ]; then
            log "INFO" "DRY RUN: Would remove $log_dir"
        else
            rm -rf "$log_dir"
            log "INFO" "Removed $log_dir"
        fi
    fi
    
    log "SUCCESS" "Log files removed"
}

# Clean up Homebrew
cleanup_homebrew() {
    if ! command_exists brew; then
        return 0
    fi
    
    log "INFO" "Cleaning up Homebrew..."
    
    if [ "$DRY_RUN" = "true" ]; then
        log "INFO" "DRY RUN: Would cleanup Homebrew"
    else
        brew cleanup --prune=all 2>/dev/null || true
        brew doctor 2>/dev/null || true
    fi
    
    log "SUCCESS" "Homebrew cleaned up"
}

# Main cleanup function
main() {
    log "INFO" "Starting cleanup process"
    
    # Parse arguments
    parse_args "$@"
    
    # Confirm removal
    confirm_removal
    
    # Remove components
    remove_homebrew_packages
    remove_vscode_extensions
    remove_ai_components
    remove_config_files
    remove_log_files
    cleanup_homebrew
    
    log "SUCCESS" "Cleanup completed successfully!"
    
    if [ "$DRY_RUN" = "true" ]; then
        log "INFO" "This was a dry run. No changes were made."
    else
        log "INFO" "All components have been removed."
    fi
}

# Run main function
main "$@"










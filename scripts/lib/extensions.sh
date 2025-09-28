#!/bin/bash
# VS Code extension management functions

# Only set strict mode if not already set
if [ -z "${BASH_STRICT_MODE:-}" ]; then
    set -euo pipefail
    BASH_STRICT_MODE=1
fi

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install extensions for all supported editors
install_extensions() {
    local role="${1:-core}"
    local dry_run="${2:-false}"
    
    log "INFO" "Installing VS Code extensions for role: $role"
    
    IFS=$'\n' read -d '' -r -a extensions < <(get_extensions "$role")
    if [ ${#extensions[@]} -eq 0 ]; then
        log "WARN" "No extensions found for role: $role"
        return 0
    fi
    
    # Supported editors
    local editors=("code" "cursor" "void")
    
    for editor in "${editors[@]}"; do
        if command_exists "$editor"; then
            install_extensions_for_editor "$editor" "${extensions[@]}" "$dry_run"
        else
            log "WARN" "$editor command not found, skipping"
        fi
    done
}

# Install extensions for specific editor
install_extensions_for_editor() {
    local editor="$1"
    shift
    local extensions=("$@")
    local dry_run="${*: -1}"
    
    log "INFO" "Installing extensions for $editor..."
    
    # Kill existing processes to avoid crashes
    pkill -f "$editor" 2>/dev/null || true
    sleep 2
    
    local installed_count=0
    local failed_count=0
    
    for ext in "${extensions[@]}"; do
        if [ "$dry_run" = "true" ]; then
            log "INFO" "DRY RUN: Would install $ext for $editor"
            continue
        fi
        
        if is_extension_installed "$editor" "$ext"; then
            log "INFO" "$ext: already installed for $editor"
            continue
        fi
        
        log "INFO" "Installing $ext for $editor..."
        
        if install_single_extension "$editor" "$ext"; then
            installed_count=$((installed_count + 1))
        else
            failed_count=$((failed_count + 1))
        fi
    done
    
    log "SUCCESS" "$editor: $installed_count installed, $failed_count failed"
}

# Check if extension is installed
is_extension_installed() {
    local editor="$1"
    local extension="$2"
    
    "$editor" --list-extensions 2>/dev/null | grep -q "^$extension$"
}

# Install single extension
install_single_extension() {
    local editor="$1"
    local extension="$2"
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        "$editor" --install-extension "$extension" 2>/dev/null; then
        log "SUCCESS" "$extension: installed for $editor"
        return 0
    else
        log "ERROR" "$extension: failed to install for $editor"
        return 1
    fi
}

# List installed extensions
list_installed_extensions() {
    local editor="${1:-code}"
    
    if ! command_exists "$editor"; then
        log "WARN" "$editor command not found"
        return 1
    fi
    
    log "INFO" "Installed extensions for $editor:"
    "$editor" --list-extensions 2>/dev/null | sort
}

# Uninstall extension
uninstall_extension() {
    local editor="$1"
    local extension="$2"
    
    if ! command_exists "$editor"; then
        log "WARN" "$editor command not found"
        return 1
    fi
    
    if ! is_extension_installed "$editor" "$extension"; then
        log "WARN" "$extension not installed for $editor"
        return 0
    fi
    
    log "INFO" "Uninstalling $extension from $editor..."
    
    if "$editor" --uninstall-extension "$extension" 2>/dev/null; then
        log "SUCCESS" "$extension: uninstalled from $editor"
    else
        log "ERROR" "$extension: failed to uninstall from $editor"
        return 1
    fi
}

# Backup extension list
backup_extensions() {
    local editor="${1:-code}"
    local backup_dir="backups/extensions"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="$backup_dir/${editor}-extensions-$timestamp.txt"
    
    if ! command_exists "$editor"; then
        log "WARN" "$editor command not found"
        return 1
    fi
    
    mkdir -p "$backup_dir"
    
    "$editor" --list-extensions > "$backup_file" 2>/dev/null || {
        log "ERROR" "Failed to backup extensions for $editor"
        return 1
    }
    
    log "SUCCESS" "Extensions backed up to $backup_file"
}

# Restore extensions from backup
restore_extensions() {
    local editor="$1"
    local backup_file="$2"
    
    if [ ! -f "$backup_file" ]; then
        log "ERROR" "Backup file not found: $backup_file"
        return 1
    fi
    
    if ! command_exists "$editor"; then
        log "WARN" "$editor command not found"
        return 1
    fi
    
    log "INFO" "Restoring extensions for $editor from $backup_file..."
    
    local restored_count=0
    local failed_count=0
    
    while IFS= read -r extension; do
        [ -z "$extension" ] && continue
        
        if install_single_extension "$editor" "$extension"; then
            restored_count=$((restored_count + 1))
        else
            failed_count=$((failed_count + 1))
        fi
    done < "$backup_file"
    
    log "SUCCESS" "$editor: $restored_count restored, $failed_count failed"
}

# Generate extension report
generate_extension_report() {
    local output_file="${1:-logs/extension-report-$(date +%Y%m%d-%H%M%S).txt}"
    
    mkdir -p "$(dirname "$output_file")"
    
    {
        echo "=== Extension Installation Report ==="
        echo "Date: $(date)"
        echo ""
        
        local editors=("code" "cursor" "void")
        
        for editor in "${editors[@]}"; do
            if command_exists "$editor"; then
                echo "=== $editor ==="
                list_installed_extensions "$editor"
                echo ""
            else
                echo "=== $editor ==="
                echo "Not installed"
                echo ""
            fi
        done
        
    } > "$output_file"
    
    log "SUCCESS" "Extension report saved to $output_file"
}







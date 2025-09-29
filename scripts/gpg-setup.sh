#!/bin/bash
# GPG Key Setup Script for GitHub Git Signing
# This script generates a GPG key and configures it for Git signing

# Only set strict mode if not already set
if [ -z "${BASH_STRICT_MODE:-}" ]; then
    set -euo pipefail
    BASH_STRICT_MODE=1
fi

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source common functions
source "$LIB_DIR/common.sh"

# Source dotfiles functions
source "$LIB_DIR/dotfiles.sh"

# Main function
main() {
    log "INFO" "Starting GPG key setup for GitHub Git signing..."
    echo ""
    
    # Check if GPG is installed
    if ! command -v gpg >/dev/null 2>&1; then
        log "ERROR" "GPG is not installed"
        echo ""
        log "INFO" "Please install GPG first:"
        log "INFO" "  brew install gnupg"
        echo ""
        log "INFO" "Then run this script again"
        exit 1
    fi
    
    # Check if Git is configured
    local git_name git_email
    git_name=$(git config user.name 2>/dev/null || echo "")
    git_email=$(git config user.email 2>/dev/null || echo "")
    
    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        log "WARN" "Git user information not configured"
        echo ""
        log "INFO" "Please configure Git first:"
        echo ""
        read -p "Enter your full name: " git_name
        read -p "Enter your email address: " git_email
        
        if [ -z "$git_name" ] || [ -z "$git_email" ]; then
            log "ERROR" "Name and email are required"
            exit 1
        fi
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        
        log "SUCCESS" "Git configured with: $git_name <$git_email>"
        echo ""
    else
        log "INFO" "Git configured with: $git_name <$git_email>"
        echo ""
    fi
    
    # Run GPG configuration
    configure_gpg_complete
    
    echo ""
    log "SUCCESS" "GPG setup completed!"
    log "INFO" "Your commits will now be signed with GPG"
    echo ""
    log "INFO" "To test GPG signing, run:"
    log "INFO" "  git commit --allow-empty -m 'Test GPG signing'"
    echo ""
    log "INFO" "To verify a signed commit, run:"
    log "INFO" "  git log --show-signature"
}

# Run main function
main "$@"

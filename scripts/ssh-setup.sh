#!/bin/bash
# SSH Key Setup and GitHub Upload Script

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Show help
show_help() {
    echo "SSH Key Setup and GitHub Upload"
    echo ""
    echo "USAGE:"
    echo "  ./scripts/ssh-setup.sh [OPTION]"
    echo ""
    echo "OPTIONS:"
    echo "  setup       Generate SSH key and configure SSH"
    echo "  upload      Upload existing SSH key to GitHub"
    echo "  auth        Authenticate with GitHub CLI and upload key"
    echo "  test        Test SSH connection to GitHub"
    echo "  help        Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  ./scripts/ssh-setup.sh setup    # Generate and configure SSH key"
    echo "  ./scripts/ssh-setup.sh upload   # Upload key to GitHub"
    echo "  ./scripts/ssh-setup.sh auth     # Authenticate and upload key"
    echo "  ./scripts/ssh-setup.sh test     # Test GitHub SSH connection"
}

# Generate SSH key
generate_ssh_key() {
    log "INFO" "Generating SSH key..."
    
    # Create .ssh directory
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # Generate key if it doesn't exist
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
        log "SUCCESS" "SSH key generated: ~/.ssh/id_ed25519"
    else
        log "INFO" "SSH key already exists: ~/.ssh/id_ed25519"
    fi
    
    # Add key to SSH agent
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    log "SUCCESS" "SSH key added to keychain"
    
    # Display public key
    log "INFO" "SSH public key:"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
}

# Upload SSH key to GitHub
upload_to_github() {
    if command -v gh >/dev/null 2>&1; then
        log "INFO" "GitHub CLI found, attempting to upload SSH key..."
        
        # Check if user is logged in
        if gh auth status >/dev/null 2>&1; then
            log "INFO" "GitHub CLI authenticated, attempting to upload SSH key..."
            
            # Try to upload the SSH key directly first
            if gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname) - $(date +%Y-%m-%d)" >/dev/null 2>&1; then
                log "SUCCESS" "SSH key uploaded to GitHub successfully!"
                log "INFO" "You can now use Git with SSH: git@github.com:username/repo.git"
                return 0
            else
                log "WARN" "Failed to upload SSH key via GitHub CLI"
                log "INFO" "This usually means you need to authenticate with the correct permissions"
                log "INFO" "Please run: gh auth login --web --scopes 'admin:public_key'"
                log "INFO" "Then try again with: ./scripts/ssh-setup.sh auth"
                return 1
            fi
        else
            log "INFO" "GitHub CLI not authenticated"
            echo ""
            log "INFO" "To upload your SSH key to GitHub automatically, we need to authenticate with GitHub CLI."
            echo ""
            read -p "Would you like to authenticate with GitHub CLI now? (y/N): " -n 1 -r
            echo ""
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log "INFO" "Starting GitHub CLI authentication..."
                echo ""
                log "INFO" "This will open a browser window for authentication."
                log "INFO" "Please follow the prompts to authenticate with GitHub."
                echo ""
                
                # Run GitHub CLI authentication
                if gh auth login --web --scopes "admin:public_key" 2>/dev/null; then
                    log "SUCCESS" "GitHub CLI authenticated successfully!"
                    echo ""
                    
                    # Now try to upload the SSH key
                    log "INFO" "Uploading SSH key to GitHub..."
                    if gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname) - $(date +%Y-%m-%d)" >/dev/null 2>&1; then
                        log "SUCCESS" "SSH key uploaded to GitHub successfully!"
                        log "INFO" "You can now use Git with SSH: git@github.com:username/repo.git"
                        return 0
                    else
                        log "WARN" "Failed to upload SSH key via GitHub CLI"
                        return 1
                    fi
                else
                    log "WARN" "GitHub CLI authentication failed or was cancelled"
                    log "INFO" "Please add the key manually at: https://github.com/settings/keys"
                    echo ""
                    log "INFO" "Your SSH public key:"
                    cat ~/.ssh/id_ed25519.pub
                    return 1
                fi
            else
                log "INFO" "Skipping GitHub CLI authentication"
                log "INFO" "Please add the key manually at: https://github.com/settings/keys"
                echo ""
                log "INFO" "Your SSH public key:"
                cat ~/.ssh/id_ed25519.pub
                return 1
            fi
        fi
    else
        log "INFO" "GitHub CLI not found"
        echo ""
        log "INFO" "To enable automatic SSH key upload, install GitHub CLI:"
        log "INFO" "  brew install gh"
        echo ""
        log "INFO" "Or add the key manually at: https://github.com/settings/keys"
        echo ""
        log "INFO" "Your SSH public key:"
        cat ~/.ssh/id_ed25519.pub
        return 1
    fi
}

# Test SSH connection to GitHub
test_github_ssh() {
    log "INFO" "Testing SSH connection to GitHub..."
    
    # Add GitHub to known_hosts to avoid interactive prompt
    if ! ssh-keygen -F github.com >/dev/null 2>&1; then
        log "INFO" "Adding GitHub to known_hosts..."
        ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null || true
    fi
    
    local ssh_output
    ssh_output=$(ssh -T git@github.com -o StrictHostKeyChecking=no -o ConnectTimeout=10 2>&1 || true)
    
    if echo "$ssh_output" | grep -q "successfully authenticated"; then
        log "SUCCESS" "SSH connection to GitHub working!"
        return 0
    else
        log "ERROR" "SSH connection to GitHub failed"
        log "INFO" "SSH output: $ssh_output"
        log "INFO" "Make sure your SSH key is added to GitHub:"
        log "INFO" "https://github.com/settings/keys"
        return 1
    fi
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "setup")
            generate_ssh_key
            log "INFO" "Next steps:"
            log "INFO" "1. Copy the public key above"
            log "INFO" "2. Go to: https://github.com/settings/keys"
            log "INFO" "3. Click 'New SSH key' and paste the key"
            log "INFO" "4. Or run: ./scripts/ssh-setup.sh upload"
            ;;
            
        "upload")
            if upload_to_github; then
                test_github_ssh
            else
                log "INFO" "Manual upload required:"
                log "INFO" "1. Go to: https://github.com/settings/keys"
                log "INFO" "2. Click 'New SSH key'"
                log "INFO" "3. Paste your public key:"
                cat ~/.ssh/id_ed25519.pub
            fi
            ;;
            
        "auth")
            log "INFO" "Authenticating with GitHub CLI and uploading SSH key..."
            if upload_to_github; then
                test_github_ssh
            else
                log "INFO" "Authentication or upload failed"
            fi
            ;;
            
        "test")
            test_github_ssh
            ;;
            
        "help"|"--help"|"-h")
            show_help
            ;;
            
        *)
            echo "❌ Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

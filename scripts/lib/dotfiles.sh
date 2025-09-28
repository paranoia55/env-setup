#!/bin/bash
# Dotfile and system configuration functions

# Only set strict mode if not already set
if [ -z "${BASH_STRICT_MODE:-}" ]; then
    set -euo pipefail
    BASH_STRICT_MODE=1
fi

# Source common functions
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    LIB_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source "$LIB_DIR/common.sh"

# Configure Git
configure_git() {
    log "INFO" "Configuring Git..."
    
    # Create .gitconfig if it doesn't exist
    if [ ! -f ~/.gitconfig ]; then
        touch ~/.gitconfig
    fi
    
    # Add Git configuration
    cat >> ~/.gitconfig << 'EOF'

# Environment Setup Configuration
[user]
    name = Your Name
    email = your.email@example.com

[core]
    editor = code --wait
    autocrlf = input
    safecrlf = true
    whitespace = trailing-space,space-before-tab
    precomposeunicode = true

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = simple
    autoSetupRemote = true

[alias]
    # Basic aliases
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    lg = log --oneline --decorate --graph --all
    lga = log --oneline --decorate --graph --all --branches --tags
    amend = commit --amend --no-edit
    undo = reset HEAD~1
    wip = commit -am "WIP"
    unwip = reset HEAD~1
    stash-all = stash push --include-untracked
    pop = stash pop
    apply = stash apply
    
    # Advanced aliases
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|develop' | xargs -n 1 git branch -d"
    uncommit = reset --soft HEAD~1
    recommit = commit -c ORIG_HEAD
    graph = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    root = rev-parse --show-toplevel
    files = diff --name-only
    diffc = diff --cached
    addp = add --patch
    unadd = reset HEAD
    staged = diff --cached
    unstaged = diff
    lasttag = describe --tags --abbrev=0
    lasttagdistance = describe --tags --abbrev=0 --long
    changelog = !git log --pretty=format:'* %s (%h)' --since='$(git lasttag)'
    
    # GitHub aliases
    pr = "!f() { git push -u origin HEAD && gh pr create --title \"$(git log -1 --pretty=%B)\" --body \"\" \"$@\"; }; f"
    prd = "!f() { git push -u origin HEAD && gh pr create --draft --title \"$(git log -1 --pretty=%B)\" --body \"\" \"$@\"; }; f"
    prr = "!f() { gh pr review --approve \"$@\"; }; f"
    prm = "!f() { gh pr merge --squash \"$@\"; }; f"
    prc = "!f() { gh pr close \"$@\"; }; f"
    prl = "!f() { gh pr list \"$@\"; }; f"
    prv = "!f() { gh pr view \"$@\"; }; f"

[color]
    ui = auto
    branch = auto
    diff = auto
    status = auto

[color "branch"]
    current = yellow reverse
    local = yellow
    remote = green

[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold

[color "status"]
    added = yellow
    changed = green
    untracked = cyan

[merge]
    conflictstyle = diff3

[rerere]
    enabled = true

[help]
    autocorrect = 1

[url "https://github.com/"]
    insteadOf = gh:

[url "https://"]
    insteadOf = git://

EOF

    log "SUCCESS" "Git configuration added to ~/.gitconfig"
    log "INFO" "Please update your name and email in ~/.gitconfig"
}

# Configure environment variables
configure_environment() {
    log "INFO" "Configuring environment variables..."
    
    # Add environment variables to .zshrc
    cat >> ~/.zshrc << 'EOF'

# Environment Variables
export EDITOR="code --wait"
export VISUAL="code --wait"
export PAGER="less"
export LESS="-R"

# Development paths
export DEV_HOME="$HOME/Development"
export PROJECTS="$DEV_HOME/projects"
export DOTFILES="$DEV_HOME/dotfiles"
export WORKSPACE="$DEV_HOME/workspace"

# Language-specific paths
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export VOLTA_HOME="$HOME/.volta"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$NVM_DIR:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"

# Node.js
export NODE_ENV="development"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export NPM_CONFIG_CACHE="$HOME/.npm"
export NPM_CONFIG_INIT_AUTHOR_NAME="$(git config user.name 2>/dev/null || echo 'Your Name')"
export NPM_CONFIG_INIT_AUTHOR_EMAIL="$(git config user.email 2>/dev/null || echo 'your.email@example.com')"
export NPM_CONFIG_INIT_LICENSE="MIT"

# Python
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_REQUIRE_VIRTUALENV=false

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Git
export GIT_EDITOR="code --wait"
export GIT_MERGE_AUTOEDIT=no

# Security
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

# AI Tools
export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LM_STUDIO_HOST="${LM_STUDIO_HOST:-127.0.0.1:1234}"
export OPEN_WEBUI_HOST="${OPEN_WEBUI_HOST:-127.0.0.1:3000}"

# Database defaults
export POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export POSTGRES_USER="${POSTGRES_USER:-postgres}"
export POSTGRES_DB="${POSTGRES_DB:-postgres}"
export MONGODB_URI="${MONGODB_URI:-mongodb://localhost:27017}"
export REDIS_URL="${REDIS_URL:-redis://localhost:6379}"

# Development tools
export BAT_THEME="${BAT_THEME:-DarkNeon}"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:---preview 'bat --color=always --style=header,grid --line-range :300 {}'}"
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:---preview 'eza --tree --color=always {}'}"

# Terminal tools
export EXA_COLORS="${EXA_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=46:cd=43:su=41:sg=46:tw=42:ow=43}"
export BAT_PAGER="less -R"
export DELTA_PAGER="less -R"

# Performance
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

# Create development directories
mkdir -p "$DEV_HOME" "$PROJECTS" "$DOTFILES" "$WORKSPACE" 2>/dev/null || true

# Create additional useful directories
mkdir -p "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" 2>/dev/null || true

# Development workflow variables
export GITHUB_USER="$(git config user.name 2>/dev/null || echo 'your-username')"
export GITHUB_TOKEN=""
export OPENAI_API_KEY=""
export ANTHROPIC_API_KEY=""

# Common development ports
export DEV_PORT="${DEV_PORT:-3000}"
export API_PORT="${API_PORT:-8000}"
export DB_PORT="${DB_PORT:-5432}"
export REDIS_PORT="${REDIS_PORT:-6379}"

# Editor and IDE settings
export VSCODE_EXTENSIONS_DIR="${VSCODE_EXTENSIONS_DIR:-$HOME/.vscode/extensions}"
export CURSOR_EXTENSIONS_DIR="${CURSOR_EXTENSIONS_DIR:-$HOME/.cursor/extensions}"

# Logging and debugging
export DEBUG=""
export LOG_LEVEL="info"
export NODE_OPTIONS="--max-old-space-size=4096"

# Testing
export CI="false"
export TEST_ENV="development"

# Build and deployment
export BUILD_ENV="development"
export DEPLOY_ENV="local"

# Tool-specific environment variables
# Ollama
export OLLAMA_MODELS="${OLLAMA_MODELS_PATH:-$HOME/.ollama/models}"
export OLLAMA_KEEP_ALIVE="${OLLAMA_KEEP_ALIVE:-5m}"

# LM Studio
export LM_STUDIO_MODELS="${LM_STUDIO_MODELS_PATH:-$HOME/.cache/lm-studio/models}"

# Open WebUI
export OPEN_WEBUI_DATABASE_URL="${OPEN_WEBUI_DATABASE_URL:-sqlite:///open-webui.db}"
export OPEN_WEBUI_JWT_SECRET_KEY="${OPEN_WEBUI_JWT_SECRET:-your-secret-key-here}"

# VS Code
export VSCODE_IPC_HOOK_CLI=""
export VSCODE_LOGS=""

# Cursor
export CURSOR_IPC_HOOK_CLI=""
export CURSOR_LOGS=""

# Docker
export DOCKER_CONFIG="$HOME/.docker"
export DOCKER_BUILDKIT_PROGRESS="plain"

# Kubernetes
export KUBECONFIG="$HOME/.kube/config"
export KUBE_EDITOR="code --wait"

# Terraform
export TF_VAR_environment="development"
export TF_LOG=""

# AWS (if using)
export AWS_PROFILE="default"
export AWS_REGION="us-east-1"

# Google Cloud (if using)
export GOOGLE_APPLICATION_CREDENTIALS=""
export GOOGLE_CLOUD_PROJECT=""

# Azure (if using)
export AZURE_SUBSCRIPTION_ID=""
export AZURE_TENANT_ID=""

# Common development environment variables
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export TZ="${TZ:-America/New_York}"

# Shell options
export HISTSIZE="${HISTSIZE:-10000}"
export SAVEHIST="${SAVEHIST:-10000}"
export HISTFILE="$HOME/.zsh_history"

# Less options
export LESS="-R -X -F"

# Grep options
export GREP_OPTIONS="--color=auto"
export GREP_COLOR="1;32"

# Timeout for long-running commands
export TIMEOUT="${TIMEOUT:-300}"

# Default umask
umask ${UMASK:-022}

EOF

    log "SUCCESS" "Environment variables configured"
}

# Configure SSH
configure_ssh() {
    log "INFO" "Configuring SSH..."
    
    # Create .ssh directory
    mkdir -p "$HOME/.ssh"
    chmod "${SSH_DIR_PERMISSIONS:-700}" "$HOME/.ssh"
    
    # Create SSH config
    cat > "$HOME/.ssh/config" << 'EOF'
# SSH Configuration
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# Bitbucket
Host bitbucket.org
    HostName bitbucket.org
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

EOF

    chmod "${SSH_CONFIG_PERMISSIONS:-600}" "$HOME/.ssh/config"
    
    # Generate SSH key if it doesn't exist
    local ssh_key_file="${SSH_KEY_FILE:-$HOME/.ssh/id_ed25519}"
    # Expand the path properly - handle both ~ and $HOME
    ssh_key_file="${ssh_key_file/#\~/$HOME}"
    ssh_key_file="${ssh_key_file/\$HOME/$HOME}"
    local ssh_key_type="${SSH_KEY_TYPE:-ed25519}"
    local ssh_key_comment="${SSH_KEY_COMMENT_FORMAT:-$(whoami)@$(hostname)}"
    
    if [ ! -f "$ssh_key_file" ]; then
        log "INFO" "Generating SSH key..."
        # Ensure .ssh directory exists
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        # Use eval to properly expand the path
        eval "ssh-keygen -t $ssh_key_type -C $ssh_key_comment -f $ssh_key_file -N ''"
        log "SUCCESS" "SSH key generated: $ssh_key_file"
    else
        log "INFO" "SSH key already exists: $ssh_key_file"
    fi
    
    # Add key to SSH agent
    if [ "${USE_KEYCHAIN:-true}" = "true" ]; then
        ssh-add --apple-use-keychain "$ssh_key_file"
    else
        ssh-add "$ssh_key_file"
    fi
    log "SUCCESS" "SSH key added to keychain"
    
    # Display public key and instructions
    log "INFO" "SSH public key (copy this to GitHub):"
    echo ""
    cat "${ssh_key_file}.pub"
    echo ""
    log "INFO" "To add this key to GitHub:"
    echo "  1. Go to: https://github.com/settings/keys"
    echo "  2. Click 'New SSH key'"
    echo "  3. Paste the key above"
    echo "  4. Give it a title like '$(hostname) - $(date +%Y-%m-%d)'"
    echo ""
    log "INFO" "Or use GitHub CLI (if installed):"
    echo "  gh auth login --with-token < ${ssh_key_file}.pub"
    
    # Try to open GitHub settings in browser
    if command -v open >/dev/null 2>&1; then
        log "INFO" "Opening GitHub SSH settings in browser..."
        open "https://github.com/settings/keys"
    fi
    
    log "SUCCESS" "SSH configuration completed"
}

# Upload SSH key to GitHub (if GitHub CLI is available)
upload_ssh_to_github() {
    if command -v gh >/dev/null 2>&1; then
        log "INFO" "GitHub CLI found, attempting to upload SSH key..."
        
                # Check if user is logged in to GitHub CLI
                if gh auth status >/dev/null 2>&1; then
                    log "INFO" "GitHub CLI authenticated, checking permissions..."
                    
                    # Upload the SSH key
                    local ssh_key_file="${SSH_KEY_FILE:-~/.ssh/id_ed25519}"
                    if gh ssh-key add "${ssh_key_file}.pub" --title "$(hostname) - $(date +%Y-%m-%d)" >/dev/null 2>&1; then
                        log "SUCCESS" "SSH key uploaded to GitHub successfully!"
                        log "INFO" "You can now use Git with SSH: git@github.com:username/repo.git"
                    else
                        log "WARN" "Failed to upload SSH key via GitHub CLI"
                        log "INFO" "This usually means you need to authenticate with the correct permissions"
                        log "INFO" "Please run: gh auth login --web --scopes 'admin:public_key'"
                        log "INFO" "Then try again with: ./scripts/ssh-setup.sh auth"
                        log "INFO" "Or add the key manually at: https://github.com/settings/keys"
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
                    local ssh_key_file="${SSH_KEY_FILE:-~/.ssh/id_ed25519}"
                    if gh ssh-key add "${ssh_key_file}.pub" --title "$(hostname) - $(date +%Y-%m-%d)" >/dev/null 2>&1; then
                        log "SUCCESS" "SSH key uploaded to GitHub successfully!"
                        log "INFO" "You can now use Git with SSH: git@github.com:username/repo.git"
                    else
                        log "WARN" "Failed to upload SSH key via GitHub CLI"
                        log "INFO" "Please add the key manually at: https://github.com/settings/keys"
                    fi
                else
                    log "WARN" "GitHub CLI authentication failed or was cancelled"
                    log "INFO" "Please add the key manually at: https://github.com/settings/keys"
                    echo ""
                    log "INFO" "Your SSH public key:"
                    local ssh_key_file="${SSH_KEY_FILE:-~/.ssh/id_ed25519}"
                    cat "${ssh_key_file}.pub"
                fi
            else
                log "INFO" "Skipping GitHub CLI authentication"
                log "INFO" "Please add the key manually at: https://github.com/settings/keys"
                echo ""
                log "INFO" "Your SSH public key:"
                local ssh_key_file="${SSH_KEY_FILE:-~/.ssh/id_ed25519}"
                cat "${ssh_key_file}.pub"
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
        local ssh_key_file="${SSH_KEY_FILE:-~/.ssh/id_ed25519}"
        cat "${ssh_key_file}.pub"
    fi
}

# Configure macOS preferences
configure_macos() {
    log "INFO" "Configuring macOS preferences..."
    
    # Dock preferences
    defaults write com.apple.dock tilesize -int 48
    defaults write com.apple.dock magnification -bool false
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # Finder preferences
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    
    # Keyboard preferences
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Trackpad preferences
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Screen preferences
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    # System preferences
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Restart affected apps
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    
    log "SUCCESS" "macOS preferences configured"
}

# Configure editors
configure_editors() {
    log "INFO" "Configuring editors..."
    
    # Vim configuration
    mkdir -p ~/.vim
    cat > ~/.vimrc << 'EOF'
" Vim configuration for env-setup
set nocompatible
filetype off

" Vundle plugin manager
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'junegunn/fzf.vim'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }

call vundle#end()
filetype plugin indent on

" Basic settings
set number
set relativenumber
set cursorline
set showmatch
set incsearch
set hlsearch
set ignorecase
set smartcase
set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set backspace=indent,eol,start
set laststatus=2
set ruler
set wildmenu
set wildmode=longest:full,full
set undofile
set undodir=~/.vim/undodir
set backupdir=~/.vim/backup
set directory=~/.vim/swap

" Key mappings
let mapleader = " "
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>t :Tags<CR>
nnoremap <leader>c :Commits<CR>
nnoremap <leader>B :BCommits<CR>

" Airline theme
let g:airline_theme='dark'
let g:airline_powerline_fonts=1

" NERDTree settings
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.DS_Store$']

" GitGutter settings
let g:gitgutter_enabled=1
let g:gitgutter_map_keys=0

" FZF settings
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_preview_window = 'right:60%'

" Colors
syntax enable
set background=dark
colorscheme default

EOF

    # Neovim configuration
    mkdir -p ~/.config/nvim
    cat > ~/.config/nvim/init.vim << 'EOF'
" Neovim configuration for env-setup
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
EOF

    # Python configuration
    cat > ~/.pythonrc << 'EOF'
# Python configuration for env-setup
import os
import sys

# Add current directory to path
sys.path.insert(0, os.getcwd())

# Enable tab completion
try:
    import readline
    import rlcompleter
    if 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")
except ImportError:
    pass

# History
import atexit
import os
histfile = os.path.join(os.path.expanduser("~"), ".python_history")
try:
    readline.read_history_file(histfile)
    readline.set_history_length(1000)
except FileNotFoundError:
    pass
atexit.register(readline.write_history_file, histfile)

EOF

    log "SUCCESS" "Editor configurations created"
}

# Configure Chezmoi
configure_chezmoi() {
    log "INFO" "Configuring Chezmoi dotfile management..."
    
    if command -v chezmoi >/dev/null 2>&1; then
        # Initialize chezmoi if not already done
        if [ ! -d ~/.local/share/chezmoi ]; then
            chezmoi init --apply
            log "SUCCESS" "Chezmoi initialized"
        else
            log "INFO" "Chezmoi already initialized"
        fi
        
        # Add chezmoi to shell
        cat >> ~/.zshrc << 'EOF'

# Chezmoi
if command -v chezmoi >/dev/null 2>&1; then
    eval "$(chezmoi completion zsh)"
fi

EOF
        
        log "SUCCESS" "Chezmoi configured"
    else
        log "WARN" "Chezmoi not found, skipping configuration"
    fi
}

# Configure development tools
configure_dev_tools() {
    log "INFO" "Configuring development tools..."
    
    # Create .envrc template
    cat > ~/.envrc.template << 'EOF'
# .envrc template for direnv
# Copy this to your project directories and customize

# Node.js
export NODE_ENV=development
export NPM_CONFIG_PREFIX=~/.npm-global

# Python
export PYTHONPATH=$PWD:$PYTHONPATH

# Database
export DATABASE_URL="postgresql://localhost:5432/myapp_development"

# API Keys (add your own)
# export OPENAI_API_KEY="your-key-here"
# export GITHUB_TOKEN="your-token-here"

# Project-specific
# export PROJECT_NAME="my-project"
# export PROJECT_PORT=3000
EOF

    # Create .gitignore template
    cat > ~/.gitignore.template << 'EOF'
# .gitignore template

# Dependencies
node_modules/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build
dist/
build/
*.tgz
*.tar.gz

# Database
*.sqlite
*.db

# Temporary
tmp/
temp/
EOF

    log "SUCCESS" "Development tool configurations created"
}

# Main configuration function
configure_dotfiles() {
    log "INFO" "Configuring dotfiles and system settings..."
    
    configure_git
    configure_environment
    configure_ssh
    upload_ssh_to_github
    configure_macos
    configure_editors
    configure_chezmoi
    configure_dev_tools
    
    log "SUCCESS" "Dotfile configuration completed"
    log "INFO" "Please review and customize the generated configuration files"
}

#!/bin/bash
# Shell & Terminal Enhancement Script v4.0
# Comprehensive shell configuration with multiple plugin managers and themes

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

# Configuration variables
SHELL_PLUGIN_MANAGER="${SHELL_PLUGIN_MANAGER:-zinit}"  # zinit, oh-my-zsh, prezto
SHELL_THEME="${SHELL_THEME:-powerlevel10k}"  # powerlevel10k, spaceship, pure
ENABLE_TMUX="${ENABLE_TMUX:-true}"
ENABLE_SCREEN="${ENABLE_SCREEN:-false}"
ENABLE_HISTORY_SYNC="${ENABLE_HISTORY_SYNC:-true}"
ENABLE_FUZZY_SEARCH="${ENABLE_FUZZY_SEARCH:-true}"

# Install Oh My Zsh
install_oh_my_zsh() {
    log "INFO" "Installing Oh My Zsh..."
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log "SUCCESS" "Oh My Zsh installed"
    else
        log "INFO" "Oh My Zsh already installed"
    fi
}

# Install Prezto
install_prezto() {
    log "INFO" "Installing Prezto..."
    
    if [ ! -d "$HOME/.zprezto" ]; then
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
        log "SUCCESS" "Prezto installed"
    else
        log "INFO" "Prezto already installed"
    fi
}

# Install Zinit
install_zinit() {
    log "INFO" "Installing Zinit plugin manager..."
    
    if [ ! -d "$HOME/.zinit" ]; then
        mkdir -p "$HOME/.zinit/bin"
        git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
        log "SUCCESS" "Zinit installed"
    else
        log "INFO" "Zinit already installed"
    fi
}

# Install Powerlevel10k
install_powerlevel10k() {
    log "INFO" "Installing Powerlevel10k theme..."
    
    if [ ! -d "$HOME/.zinit/polaris" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.zinit/polaris"
        log "SUCCESS" "Powerlevel10k installed"
    else
        log "INFO" "Powerlevel10k already installed"
    fi
}

# Install Spaceship theme
install_spaceship() {
    log "INFO" "Installing Spaceship theme..."
    
    if [ ! -d "$HOME/.zinit/spaceship" ]; then
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.zinit/spaceship" --depth=1
        log "SUCCESS" "Spaceship theme installed"
    else
        log "INFO" "Spaceship theme already installed"
    fi
}

# Install Pure theme
install_pure() {
    log "INFO" "Installing Pure theme..."
    
    if [ ! -d "$HOME/.zinit/pure" ]; then
        git clone https://github.com/sindresorhus/pure.git "$HOME/.zinit/pure"
        log "SUCCESS" "Pure theme installed"
    else
        log "INFO" "Pure theme already installed"
    fi
}

# Install additional themes
install_additional_themes() {
    log "INFO" "Installing additional themes..."
    
    # Starship (cross-shell prompt)
    if command -v starship >/dev/null 2>&1; then
        log "INFO" "Starship already installed"
    else
        log "INFO" "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        log "SUCCESS" "Starship installed"
    fi
    
    # Additional Zsh themes
    local themes_dir="$HOME/.zinit/themes"
    mkdir -p "$themes_dir"
    
    # Install popular themes
    local themes=(
        "https://github.com/romkatv/powerlevel10k.git:powerlevel10k"
        "https://github.com/spaceship-prompt/spaceship-prompt.git:spaceship"
        "https://github.com/sindresorhus/pure.git:pure"
        "https://github.com/denysdovhan/spaceship-prompt.git:spaceship-alt"
        "https://github.com/agnoster/agnoster-zsh-theme.git:agnoster"
        "https://github.com/robbyrussell/oh-my-zsh.git:oh-my-zsh"
    )
    
    for theme_info in "${themes[@]}"; do
        local theme_url="${theme_info%:*}"
        local theme_name="${theme_info#*:}"
        local theme_path="$themes_dir/$theme_name"
        
        if [ ! -d "$theme_path" ]; then
            log "INFO" "Installing theme: $theme_name"
            git clone "$theme_url" "$theme_path" --depth=1
        fi
    done
    
    log "SUCCESS" "Additional themes installed"
}

# Configure Zsh with Zinit
configure_zsh() {
    log "INFO" "Configuring Zsh with Zinit..."
    
    # Create .zshrc if it doesn't exist
    if [ ! -f "$HOME/.zshrc" ]; then
        touch "$HOME/.zshrc"
    fi
    
    # Backup existing .zshrc
    if [ -f "$HOME/.zshrc" ] && ! grep -q "ZINIT_HOME" "$HOME/.zshrc"; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create Zinit configuration
    cat > "$HOME/.zshrc" << 'EOF'
# Zinit configuration
export ZINIT_HOME="$HOME/.zinit"
source "$ZINIT_HOME/bin/zinit.zsh"

# Powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Essential plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light agkozak/zsh-z
zinit light jeffreytse/zsh-vi-mode
zinit light hlissner/zsh-autopair
zinit light zsh-users/zsh-history-substring-search

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Key bindings for history search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R' history-incremental-search-backward

# FZF integration
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
    
    fzf-cd() {
        local dir
        dir=$(find . -type d | fzf) && cd "$dir"
    }
    
    fzf-history() {
        local cmd
        cmd=$(history | fzf | sed 's/^[ ]*[0-9]*[ ]*//' | tr -d '\n')
        if [ -n "$cmd" ]; then
            echo "$cmd" | pbcopy
            echo "Command copied to clipboard: $cmd"
        fi
    }
fi

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias gdf='git diff'
alias glog='git log --oneline'

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Environment variables
export EDITOR="code"
export VISUAL="code"
export PAGER="less"
export LESS="-R"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.volta/bin:$PATH"

# Initialize Powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    log "SUCCESS" "Zsh configured with Zinit and Powerlevel10k"
}

# Configure Tmux
configure_tmux() {
    if [ "$ENABLE_TMUX" = "true" ]; then
        log "INFO" "Configuring Tmux..."
        
        # Create tmux config
        cat > "$HOME/.tmux.conf" << 'EOF'
# Tmux configuration for env-setup

# Basic settings
set -g default-terminal "screen-256color"
set -g terminal-overrides ",xterm-256color:RGB"
set -g mouse on
set -g history-limit 10000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Key bindings
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Window navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Window splitting
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Copy mode
setw -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'
bind -T copy-mode-vi r send-keys -X rectangle-toggle

# Status bar
set -g status-position bottom
set -g status-bg colour235
set -g status-fg colour136
set -g status-left-length 40
set -g status-left '#[fg=green]#S #[fg=blue]#I #[fg=cyan]#P'
set -g status-right '#[fg=blue]#H #[fg=cyan]%Y-%m-%d %H:%M'
set -g status-justify centre

# Window status
setw -g window-status-current-style 'fg=colour166 bg=colour235 bold'
setw -g window-status-style 'fg=colour245 bg=colour235'

# Pane border
set -g pane-border-style 'fg=colour235'
set -g pane-active-border-style 'fg=colour166'

# Message text
set -g message-style 'fg=colour232 bg=colour166 bold'

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Plugin settings
set -g @resurrect-capture-pane-contents 'on'
set -g @continuum-restore 'on'

# Initialize TPM (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

        # Install TPM if not exists
        if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
            git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        fi
        
        log "SUCCESS" "Tmux configured"
    fi
}

# Configure Screen
configure_screen() {
    if [ "$ENABLE_SCREEN" = "true" ]; then
        log "INFO" "Configuring Screen..."
        
        cat > "$HOME/.screenrc" << 'EOF'
# Screen configuration for env-setup

# Basic settings
defscrollback 10000
startup_message off
vbell off
autodetach on

# Key bindings
bindkey -k k1 select 0
bindkey -k k2 select 1
bindkey -k k3 select 2
bindkey -k k4 select 3
bindkey -k k5 select 4
bindkey -k k6 select 5
bindkey -k k7 select 6
bindkey -k k8 select 7
bindkey -k k9 select 8
bindkey -k k0 select 9

# Status line
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %m-%d %{W}%c %{g}]'

# Colors
term screen-256color
EOF
        
        log "SUCCESS" "Screen configured"
    fi
}

# Configure enhanced command-line tools
configure_command_line_tools() {
    log "INFO" "Configuring enhanced command-line tools..."
    
    # Add comprehensive aliases
    cat >> "$HOME/.zshrc" << 'EOF'

# Enhanced Aliases
# File operations
alias ll='eza -la --git --icons'
alias la='eza -A --git --icons'
alias l='eza -CF --git --icons'
alias lt='eza --tree --level=2 --git --icons'
alias lta='eza --tree --level=3 --git --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias gdf='git diff'
alias glog='git log --oneline --graph --decorate'
alias gaa='git add .'
alias gac='git add . && git commit -m'
alias gpu='git push -u origin HEAD'
alias gpr='git pull --rebase'
alias gstash='git stash'
alias gpop='git stash pop'
alias gapply='git stash apply'
alias gclean='git clean -fd'
alias greset='git reset --hard HEAD'
alias gundo='git reset --soft HEAD~1'

# Development aliases
alias dev='cd ~/Development'
alias proj='cd ~/Development/projects'
alias dot='cd ~/Development/dotfiles'
alias ws='cd ~/Development/workspace'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dlogs='docker logs'
alias dexec='docker exec -it'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'

# System aliases
alias top='htop'
alias ps='procs'
alias du='dust'
alias df='dust'
alias free='htop'
alias ping='gping'
alias traceroute='mtr'

# Network aliases
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s https://ipinfo.io/ip'
alias localip='ifconfig | grep "inet " | grep -v 127.0.0.1'

# Utility aliases
alias c='clear'
alias h='history'
alias j='jobs'
alias f='fg'
alias b='bg'
alias e='exit'
alias q='exit'
alias x='exit'
alias cls='clear'
alias reload='source ~/.zshrc'
alias refresh='source ~/.zshrc'

# Editor aliases
alias v='code'
alias nv='nvim'
alias vim='nvim'
alias vi='nvim'

# Package manager aliases
alias bi='brew install'
alias bu='brew uninstall'
alias bs='brew search'
alias bup='brew update && brew upgrade'
alias bcl='brew cleanup'
alias ni='npm install'
alias nu='npm uninstall'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nd='npm run dev'
alias pi='pnpm install'
alias pu='pnpm uninstall'
alias ps='pnpm start'
alias pt='pnpm test'
alias pb='pnpm run build'
alias pd='pnpm run dev'

EOF

    # Add comprehensive functions
    cat >> "$HOME/.zshrc" << 'EOF'

# Enhanced Functions
# Directory navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick directory creation and navigation
take() {
    mkdir -p "$1" && cd "$1"
}

# Find and cd to directory
fcd() {
    local dir
    dir=$(find . -type d | fzf) && cd "$dir"
}

# Find and open file
fopen() {
    local file
    file=$(find . -type f | fzf) && code "$file"
}

# Git functions
gnew() {
    git checkout -b "$1"
}

gswitch() {
    git checkout "$1"
}

gmerge() {
    git merge "$1"
}

gdelete() {
    git branch -d "$1"
}

gforce() {
    git push --force-with-lease
}

# Docker functions
drun() {
    docker run -it --rm "$@"
}

dbuild() {
    docker build -t "$1" .
}

dclean() {
    docker system prune -f
}

dcleanall() {
    docker system prune -af
}

# Development functions
newproject() {
    local project_name="$1"
    local project_path="$HOME/Development/projects/$project_name"
    mkdir -p "$project_path"
    cd "$project_path"
    git init
    echo "# $project_name" > README.md
    echo "node_modules/" > .gitignore
    echo "*.log" >> .gitignore
    echo ".env" >> .gitignore
    echo ".DS_Store" >> .gitignore
    git add .
    git commit -m "Initial commit"
    echo "Project '$project_name' created at $project_path"
}

# System functions
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Network functions
port() {
    lsof -i :"$1"
}

killport() {
    lsof -ti :"$1" | xargs kill -9
}

# Utility functions
weather() {
    curl -s "wttr.in/$1"
}

cheat() {
    curl -s "cheat.sh/$1"
}

# AI functions
ask() {
    local question="$*"
    if command -v ollama >/dev/null 2>&1; then
        ollama run llama2 "$question"
    else
        echo "Ollama not installed. Install with: brew install ollama"
    fi
}

# Quick edit functions
zshrc() {
    code ~/.zshrc
}

vimrc() {
    code ~/.vimrc
}

tmuxconf() {
    code ~/.tmux.conf
}

# History functions
h() {
    history | fzf | sed 's/^[ ]*[0-9]*[ ]*//' | tr -d '\n' | pbcopy
    echo "Command copied to clipboard"
}

# Process functions
pkill() {
    ps aux | fzf | awk '{print $2}' | xargs kill -9
}

# File functions
fzf-cd() {
    local dir
    dir=$(find . -type d | fzf) && cd "$dir"
}

fzf-history() {
    local cmd
    cmd=$(history | fzf | sed 's/^[ ]*[0-9]*[ ]*//' | tr -d '\n')
    if [ -n "$cmd" ]; then
        echo "$cmd" | pbcopy
        echo "Command copied to clipboard: $cmd"
    fi
}

# Git workflow functions
gpr() {
    git push -u origin HEAD && gh pr create --title "$(git log -1 --pretty=%B)" --body ""
}

gprd() {
    git push -u origin HEAD && gh pr create --draft --title "$(git log -1 --pretty=%B)" --body ""
}

EOF

    log "SUCCESS" "Enhanced command-line tools configured"
}

# Configure advanced history management
configure_history_management() {
    if [ "$ENABLE_HISTORY_SYNC" = "true" ]; then
        log "INFO" "Configuring advanced history management..."
        
        cat >> "$HOME/.zshrc" << 'EOF'

# Advanced History Management
# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# History options
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file
setopt HIST_VERIFY               # Show command with history expansion to user before running it
setopt SHARE_HISTORY             # Share history between all sessions
setopt APPEND_HISTORY            # Append to history file, don't overwrite it
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt HIST_BEEP                 # Beep when accessing non-existent history

# History search functions
history-search-backward() {
    local line
    line=$(history | fzf --query="$BUFFER" --reverse --height=40% --border)
    if [ -n "$line" ]; then
        BUFFER=$(echo "$line" | sed 's/^[ ]*[0-9]*[ ]*//')
        CURSOR=$#BUFFER
    fi
    zle redisplay
}

history-search-forward() {
    local line
    line=$(history | fzf --query="$BUFFER" --reverse --height=40% --border)
    if [ -n "$line" ]; then
        BUFFER=$(echo "$line" | sed 's/^[ ]*[0-9]*[ ]*//')
        CURSOR=$#BUFFER
    fi
    zle redisplay
}

# Bind history search functions
zle -N history-search-backward
zle -N history-search-forward
bindkey '^R' history-search-backward
bindkey '^S' history-search-forward

# History deduplication function
dedupe_history() {
    local temp_file=$(mktemp)
    local original_file="$HISTFILE"
    
    if [ -f "$original_file" ]; then
        # Remove duplicates while preserving order
        awk '!seen[$0]++' "$original_file" > "$temp_file"
        mv "$temp_file" "$original_file"
        echo "History deduplicated"
    else
        echo "No history file found"
    fi
}

# History sync function (for multiple terminals)
sync_history() {
    # This would sync history across multiple terminals
    # Implementation depends on your setup (e.g., using a shared history file)
    echo "History sync not implemented yet"
}

# History statistics
history_stats() {
    echo "History Statistics:"
    echo "Total commands: $(wc -l < "$HISTFILE")"
    echo "Unique commands: $(sort "$HISTFILE" | uniq | wc -l)"
    echo "Most used commands:"
    sort "$HISTFILE" | uniq -c | sort -nr | head -10
}

# Clean history
clean_history() {
    local temp_file=$(mktemp)
    local original_file="$HISTFILE"
    
    if [ -f "$original_file" ]; then
        # Remove empty lines and lines starting with space
        grep -v '^[[:space:]]*$' "$original_file" | grep -v '^[[:space:]]' > "$temp_file"
        mv "$temp_file" "$original_file"
        echo "History cleaned"
    else
        echo "No history file found"
    fi
}

EOF

        log "SUCCESS" "Advanced history management configured"
    fi
}

# Configure terminals
configure_terminals() {
    log "INFO" "Configuring terminal applications..."
    
    # Configure Warp terminal
    if [ -d "/Applications/Warp.app" ]; then
        log "INFO" "Configuring Warp terminal..."
        # Warp configuration would go here
        # Warp uses its own configuration system
    fi
    
    # Configure iTerm2
    if [ -d "/Applications/iTerm.app" ]; then
        log "INFO" "Configuring iTerm2..."
        # iTerm2 configuration would go here
        # iTerm2 uses plist files for configuration
    fi
    
    # Configure Alacritty
    if command -v alacritty >/dev/null 2>&1; then
        log "INFO" "Configuring Alacritty..."
        mkdir -p "$HOME/.config/alacritty"
        cat > "$HOME/.config/alacritty/alacritty.yml" << 'EOF'
# Alacritty configuration for env-setup
font:
  normal:
    family: "SF Mono"
    style: Regular
  bold:
    family: "SF Mono"
    style: Bold
  italic:
    family: "SF Mono"
    style: Italic
  bold_italic:
    family: "SF Mono"
    style: Bold Italic
  size: 14.0

window:
  opacity: 0.95
  padding:
    x: 10
    y: 10
  decorations: full

colors:
  primary:
    background: '#1e1e1e'
    foreground: '#d4d4d4'
  cursor:
    text: '#1e1e1e'
    cursor: '#d4d4d4'
  normal:
    black: '#1e1e1e'
    red: '#f44747'
    green: '#608b4e'
    yellow: '#dcdcaa'
    blue: '#569cd6'
    magenta: '#c586c0'
    cyan: '#4ec9b0'
    white: '#d4d4d4'
  bright:
    black: '#808080'
    red: '#f44747'
    green: '#608b4e'
    yellow: '#dcdcaa'
    blue: '#569cd6'
    magenta: '#c586c0'
    cyan: '#4ec9b0'
    white: '#ffffff'

selection:
  text: '#1e1e1e'
  background: '#d4d4d4'

scrolling:
  history: 10000
  multiplier: 3

mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }

key_bindings:
  - { key: V, mods: Command, action: Paste }
  - { key: C, mods: Command, action: Copy }
  - { key: Plus, mods: Command, action: IncreaseFontSize }
  - { key: Minus, mods: Command, action: DecreaseFontSize }
  - { key: Key0, mods: Command, action: ResetFontSize }
EOF
        log "SUCCESS" "Alacritty configured"
    fi
    
    # Configure WezTerm
    if command -v wezterm >/dev/null 2>&1; then
        log "INFO" "Configuring WezTerm..."
        mkdir -p "$HOME/.config/wezterm"
        cat > "$HOME/.config/wezterm/wezterm.lua" << 'EOF'
-- WezTerm configuration for env-setup
local wezterm = require 'wezterm'

return {
  font = wezterm.font('SF Mono'),
  font_size = 14.0,
  color_scheme = 'Dark+ (default dark)',
  window_background_opacity = 0.95,
  window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  },
  window_decorations = "TITLE | RESIZE",
  scrollback_lines = 10000,
  enable_scroll_bar = true,
  use_fancy_tab_bar = true,
  tab_bar_at_bottom = true,
  show_tab_index_in_tab_bar = true,
  show_new_tab_button_in_tab_bar = true,
  window_close_confirmation = "NeverPrompt",
  keys = {
    {
      key = 'c',
      mods = 'CMD',
      action = wezterm.action.CopyTo 'Clipboard',
    },
    {
      key = 'v',
      mods = 'CMD',
      action = wezterm.action.PasteFrom 'Clipboard',
    },
    {
      key = '=',
      mods = 'CMD',
      action = wezterm.action.IncreaseFontSize,
    },
    {
      key = '-',
      mods = 'CMD',
      action = wezterm.action.DecreaseFontSize,
    },
    {
      key = '0',
      mods = 'CMD',
      action = wezterm.action.ResetFontSize,
    },
  },
}
EOF
        log "SUCCESS" "WezTerm configured"
    fi
    
    # Configure Kitty
    if command -v kitty >/dev/null 2>&1; then
        log "INFO" "Configuring Kitty..."
        mkdir -p "$HOME/.config/kitty"
        cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
# Kitty configuration for env-setup
font_family SF Mono
font_size 14.0
bold_font auto
italic_font auto
bold_italic_font auto

# Window settings
window_padding_width 10
window_padding_height 10
window_margin_width 0
window_margin_height 0
window_border_width 0
window_round_corners 0
window_opacity 0.95
window_decorations titlebar

# Colors
background #1e1e1e
foreground #d4d4d4
cursor #d4d4d4
cursor_text_color #1e1e1e
selection_background #d4d4d4
selection_foreground #1e1e1e

# Tab bar
tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted
tab_title_template " {title} "
active_tab_title_template " {title} "

# Scrolling
scrollback_lines 10000
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
scrollback_pager_history_size 0

# Mouse
mouse_hide_wait 3.0
url_color #569cd6
url_style curly

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Terminal
term xterm-256color
shell_integration enabled
EOF
        log "SUCCESS" "Kitty configured"
    fi
    
    log "SUCCESS" "Terminal applications configured"
}

# Test terminal configuration
test_terminal_config() {
    log "INFO" "Testing terminal configuration..."
    
    # Test if zsh is working
    if command -v zsh >/dev/null 2>&1; then
        log "SUCCESS" "Zsh is available"
    else
        log "WARN" "Zsh not found"
    fi
    
    # Test if tmux is working
    if command -v tmux >/dev/null 2>&1; then
        log "SUCCESS" "Tmux is available"
    else
        log "WARN" "Tmux not found"
    fi
    
    # Test if fzf is working
    if command -v fzf >/dev/null 2>&1; then
        log "SUCCESS" "FZF is available"
    else
        log "WARN" "FZF not found"
    fi
    
    # Test if starship is working
    if command -v starship >/dev/null 2>&1; then
        log "SUCCESS" "Starship is available"
    else
        log "WARN" "Starship not found"
    fi
    
    log "SUCCESS" "Terminal configuration test completed"
}

# Main function to configure shell
configure_shell() {
    log "INFO" "Configuring shell and terminal enhancements..."
    
    # Install plugin managers and themes based on configuration
    case "$SHELL_PLUGIN_MANAGER" in
        "oh-my-zsh")
            install_oh_my_zsh
            ;;
        "prezto")
            install_prezto
            ;;
        "zinit"|*)
            install_zinit
            ;;
    esac
    
    # Install themes based on configuration
    case "$SHELL_THEME" in
        "spaceship")
            install_spaceship
            ;;
        "pure")
            install_pure
            ;;
        "powerlevel10k"|*)
            install_powerlevel10k
            ;;
    esac
    
    # Install additional themes
    install_additional_themes
    
    # Configure Zsh
    configure_zsh
    
    # Configure terminal multiplexers
    configure_tmux
    configure_screen
    
    # Configure enhanced command-line tools
    configure_command_line_tools
    
    # Configure history management
    configure_history_management
    
    # Configure terminals
    configure_terminals
    
    # Test terminal configuration
    test_terminal_config
    
    log "SUCCESS" "Shell and terminal enhancements configured"
    log "INFO" "Please restart your terminal or run: source ~/.zshrc"
}

# Main execution block
main() {
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" = "${0}" ]; then
        load_config "${CONFIG_FILE:-config.yaml}"
        configure_shell
    fi
}

main "$@"
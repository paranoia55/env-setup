# Complete Setup Guide

Comprehensive guide to the development environment setup.

## Table of Contents

- [Overview](#overview)
- [Configuration](#configuration)
- [Installation Options](#installation-options)
- [Categories](#categories)
- [AI Tools Setup](#ai-tools-setup)
- [Comprehensive Documentation](#comprehensive-documentation)
- [Customization](#customization)
- [Maintenance](#maintenance)

## Overview

This setup provides a complete development environment for full-stack JavaScript/TypeScript development with AI tools. It's designed to be:

- **Idempotent**: Safe to run multiple times
- **Modular**: Install only what you need
- **Configurable**: Driven by `config.yaml`
- **Well-documented**: Self-documenting and maintainable

## Configuration

The entire setup is driven by `config.yaml`, which serves as the single source of truth for:

- Package lists by category
- VS Code extensions by role
- AI model configuration
- Service port settings
- Tool descriptions and documentation links

### Configuration Structure

```yaml
metadata:
  name: "MacBook Pro Full-Stack JS/TS Setup"
  version: "4.0.0"

config:
  log_level: "info"
  parallel_jobs: 3
  retry_attempts: 3

categories:
  core:
    name: "Core Development Tools"
    enabled: true

packages:
  core:
    brew: ["git", "node", "docker"]
    cask: []

extensions:
  core: ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"]
```

## Installation Options

### Basic Installation

```bash
# Full installation
./scripts/setup-env.sh

# Dry run (preview only)
./scripts/setup-env.sh --dry-run
```

### Category-Specific Installation

```bash
# Install only core tools
./scripts/setup-env.sh --only core

# Install only frontend tools
./scripts/setup-env.sh --only frontend

# Install only backend tools
./scripts/setup-env.sh --only backend

# Install only business/productivity tools
./scripts/setup-env.sh --only business
```

### Advanced Options

```bash
# Skip AI model downloads
./scripts/setup-env.sh --skip-models

# Skip web UI setup
./scripts/setup-env.sh --skip-webui

# Use custom config
./scripts/setup-env.sh --config my-config.yaml

# Verbose logging
./scripts/setup-env.sh --verbose
```

## Categories

### Core Development Tools

Essential CLI tools and development platforms:

- **Version Control**: Git, GitHub CLI
- **Runtimes**: Node.js, Bun
- **Package Managers**: pnpm, Yarn
- **Containers**: Docker, Colima
- **Databases**: PostgreSQL, Redis, SQLite
- **Terminal Tools**: Starship, eza, bat, fzf, ripgrep
- **Development**: Pre-commit, ShellCheck, direnv

### Frontend & IDE Tools

Code editors, package managers, and frontend tooling:

- **Editors**: VS Code, Cursor, Void IDE
- **Package Managers**: Yarn
- **Extensions**: ESLint, Prettier, TypeScript, GitLens, and more

### Backend & Databases

Databases, message brokers, and backend services:

- **Databases**: PostgreSQL, MongoDB, Redis, SQLite, ClickHouse, DuckDB, OpenSearch
- **Message Brokers**: Kafka, RabbitMQ
- **Storage**: MinIO
- **Management**: TablePlus, DBeaver

### Business & Productivity

AI tools, productivity apps, and optional GUI applications:

- **AI Tools**: Ollama, LM Studio, OpenAI CLI
- **Communication**: WhatsApp, Signal, Telegram, Slack, Discord
- **Productivity**: Notion, Obsidian, Raycast, Rectangle
- **Media**: VLC, HandBrake, Spotify
- **Utilities**: Keka, AppCleaner, Hidden Bar, MonitorControl

## AI Tools Setup

### Ollama

Local LLM runtime:

```bash
# Check status
ollama list
ollama ps

# Install additional models
ollama pull llama2
ollama pull codellama

# Run a model
ollama run llama2
```

### LM Studio

Desktop app for model management:

1. Open LM Studio
2. Download DeepSeek Coder 33B
3. Start the local server on port 1234
4. Void IDE will automatically connect

### Void IDE

AI-powered code editor:

- Pre-configured to use LM Studio
- DeepSeek Coder 33B model
- OpenAI-compatible API at `http://localhost:1234/v1`

### Open WebUI

Web interface for local LLMs:

```bash
# Start Open WebUI
docker run -d --name open-webui -p 3000:8080 ghcr.io/open-webui/open-webui:main

# Access at http://localhost:3000
```

## Comprehensive Documentation

The setup automatically generates comprehensive documentation that shows everything installed and configured:

### Auto-Generated Documentation

After running the setup, you'll find:

- **`docs/ENVIRONMENT_SETUP_COMPLETE.md`** - Complete Markdown documentation
- **`docs/ENVIRONMENT_SETUP_COMPLETE.html`** - Interactive HTML documentation

### What's Documented

The comprehensive documentation includes:

#### 📦 Installed Packages (113+ tools)
- Complete table with categories, descriptions, and status
- Sortable columns for easy navigation
- Links to official documentation

#### 🔌 VS Code Extensions (20+ extensions)
- Detailed table with descriptions and categories
- Covers Core, Database, Frontend, Git, AI, DevOps tools

#### 📁 Configuration Files (Dotfiles)
- **Shell Configuration** - ~/.zshrc with all modern tools
- **Git Configuration** - ~/.gitconfig with comprehensive aliases
- **SSH Configuration** - ~/.ssh/config with key management
- **Editor Configurations** - Vim, Neovim, Python startup
- **Terminal Configurations** - Alacritty, WezTerm, Kitty configs

#### 🌍 Environment Variables (50+ variables)
- **Development Paths** - DEV_HOME, PROJECTS, DOTFILES, WORKSPACE
- **Language-Specific** - Go, Python, Node.js, Rust paths
- **AI Tools Configuration** - Ollama, LM Studio, Open WebUI
- **Database Defaults** - PostgreSQL, MongoDB, Redis settings
- **Development Tools** - FZF, Bat, Exa, Delta configurations

#### 🚀 Services & Ports
- **Database Services** - PostgreSQL, MongoDB, Redis, MySQL
- **AI Services** - Ollama, LM Studio, Open WebUI
- **Development Services** - MinIO, Grafana, Prometheus

#### 🤖 AI Tools & Models
- **Local LLM Runtime** - Ollama with model management
- **AI Development Tools** - LM Studio, Open WebUI
- **AI-Powered Editors** - Cursor, Void IDE

#### 💻 Terminal Applications
- **AI-Powered Terminal** - Warp with AI features
- **Traditional Terminals** - iTerm2, Alacritty, WezTerm, Kitty
- **Terminal Tools** - Starship, eza, bat, fd, ripgrep, fzf, zoxide

#### 🖥️ macOS System Preferences
- **Dock Configuration** - Size, auto-hide, magnification, position
- **Finder Settings** - Path bar, status bar, file extensions, hidden files
- **Keyboard & Trackpad** - Key repeat, tap to click, natural scrolling
- **Display Settings** - Night Shift, True Tone, auto-brightness
- **Accessibility** - Motion, transparency, contrast settings
- **Date & Time** - Auto timezone, menu bar display, time format
- **Sound & Energy** - Volume controls, sleep settings, network wake
- **Security** - Password requirements, app sources, FileVault

### Viewing the Documentation

The documentation opens automatically after setup:

1. **HTML Version** - Opens in your default browser with interactive tables
2. **Markdown Version** - Opens in VS Code for editing

### Regenerating Documentation

To update the documentation after changes:

```bash
# Regenerate comprehensive documentation
./scripts/generate-csv-readme.sh

# Or use make
make docs
```

## macOS System Preferences Configuration

The setup automatically configures macOS system preferences for an optimal development experience. All settings are configurable via `config.yaml`.

### Customizing macOS Settings

Edit the `macos` section in `config.yaml`:

```yaml
macos:
  dock:
    tilesize: 48              # Dock size (16-128)
    autohide: true            # Auto-hide dock
    show_recents: false       # Show recent apps
    magnification: false      # Dock magnification
    position: "bottom"        # bottom, left, right
  
  finder:
    show_pathbar: true        # Show path bar
    show_statusbar: true      # Show status bar
    show_all_extensions: true # Show file extensions
    show_hidden_files: true   # Show hidden files
    default_search_scope: "SCcf"  # Search scope
  
  keyboard:
    key_repeat: 1             # Key repeat rate (0-2)
    initial_key_repeat: 15    # Initial delay (10-30)
    press_and_hold_disabled: true  # Disable press and hold
  
  trackpad:
    tap_to_click: true        # Tap to click
    three_finger_drag: true   # Three-finger drag
    natural_scrolling: true   # Natural scrolling
  
  display:
    night_shift: "auto"       # auto, on, off
    true_tone: "auto"         # auto, on, off
    auto_brightness: true     # Auto-brightness
  
  accessibility:
    reduce_motion: false      # Reduce motion effects
    reduce_transparency: false # Reduce transparency
    increase_contrast: false  # Increase contrast
  
  date_time:
    set_timezone_automatically: true  # Auto timezone
    show_in_menubar: true     # Show in menu bar
    use_24_hour_format: false # 24-hour format
  
  sound:
    show_volume_in_menubar: true  # Volume in menu bar
    play_sound_effects: true  # Sound effects
    play_volume_feedback: true  # Volume feedback
  
  energy_saver:
    prevent_sleep_when_display_off: false  # Prevent sleep
    put_hard_disks_to_sleep: true  # Disk sleep
    wake_for_network_access: true  # Network wake
  
  security:
    require_password_immediately: true  # Password after sleep
    allow_apps_from: "AppStoreAndIdentifiedDevelopers"  # App sources
    enable_filevault: "ask_user"  # FileVault (true, false, ask_user)
```

### Reconfiguring macOS Settings

To apply new macOS settings:

```bash
# Reconfigure macOS settings only
./scripts/lib/macos.sh

# Or run the full setup
./setup-env.sh
```

### Manual Configuration

Some settings may require manual configuration:

- **FileVault**: Requires admin privileges and user interaction
- **Accessibility settings**: May require accessibility permissions
- **Security settings**: Some require admin privileges

The setup will guide you through any manual steps required.

## Customization

### Adding New Tools

1. Edit `config.yaml`:
   ```yaml
   packages:
     core:
       brew: ["new-tool"]
   ```

2. Add tool information:
   ```yaml
   tool_info:
     new-tool:
       description: "Description of the tool"
       docs: "https://example.com/docs"
       category: "Core Dev"
   ```

3. Regenerate comprehensive documentation:
   ```bash
   ./scripts/generate-csv-readme.sh
   ```

### Custom Categories

Create custom installation categories:

```yaml
categories:
  my-category:
    name: "My Custom Tools"
    description: "Tools for my specific workflow"
    enabled: true

packages:
  my-category:
    brew: ["tool1", "tool2"]
    cask: ["app1", "app2"]
```

### Custom Extensions

Add VS Code extensions by role:

```yaml
extensions:
  my-role:
    - "publisher.extension-id"
    - "another.extension"
```

## Maintenance

### Updating Tools

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update VS Code extensions
code --list-extensions | xargs -n 1 code --install-extension

# Update AI models
ollama pull llama2
```

### Health Checks

```bash
# Run all health checks
./scripts/setup-env.sh --dry-run

# Check specific services
brew services list
docker ps
ollama list
```

### Cleanup

```bash
# Remove all installed components
./scripts/cleanup.sh

# Dry run cleanup
./scripts/cleanup.sh --dry-run

# Keep configuration files
./scripts/cleanup.sh --keep-config
```

### Logs

Check installation logs:

```bash
# List all logs
ls -la logs/

# View latest log
tail -f logs/setup-*.log

# Search for errors
grep -i error logs/setup-*.log
```

## Troubleshooting

See [Troubleshooting Guide](../troubleshooting/README.md) for common issues and solutions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Update `config.yaml` if adding new tools
5. Run tests: `pre-commit run --all-files`
6. Submit a pull request

## Support

- [GitHub Issues](https://github.com/your-username/env-setup/issues)
- [Discussions](https://github.com/your-username/env-setup/discussions)
- [Documentation](https://github.com/your-username/env-setup/tree/main/docs)










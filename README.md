# Environment Setup v1.0

A comprehensive, production-ready development environment setup for macOS with AI tools, designed for full-stack JavaScript/TypeScript development.

## ✨ Features

- **🚀 One-command setup**: Install everything with a single script
- **🔄 Idempotent**: Safe to run multiple times without side effects
- **🧩 Modular**: Install only what you need by category
- **🤖 AI-powered**: Local LLMs, AI coding tools, and intelligent editors
- **📚 Comprehensive documentation**: Auto-generated complete setup documentation
- **🛡️ Production-ready**: CI/CD, linting, security scanning, and error handling
- **⚙️ Highly configurable**: YAML-driven configuration system
- **🌍 Complete environment**: 50+ environment variables for seamless development
- **📁 Full dotfile management**: Shell, Git, SSH, and editor configurations
- **🔌 VS Code extensions**: 20+ essential extensions automatically installed
- **💻 Modern terminals**: AI-powered Warp, iTerm2, Alacritty, WezTerm, Kitty
- **🚀 Services management**: Database, AI, and development services with ports
- **🖥️ macOS optimization**: Automatic system preferences configuration for optimal development experience

## 🚀 Quick Start

```bash
# Clone and run
git clone https://github.com/your-username/env-setup.git
cd env-setup

# Simple setup script (recommended)
./setup-env.sh install

# Or preview first
./setup-env.sh preview

# Or use other methods
make install
./scripts/setup.sh
```

## 📦 What's Included

### Core Development Tools
- **Version Control**: Git, GitHub CLI
- **Runtimes**: Node.js, Bun, Python
- **Package Managers**: pnpm, Yarn, pipx
- **Containers**: Docker, Colima
- **Databases**: PostgreSQL, MongoDB, Redis, SQLite, ClickHouse, DuckDB, OpenSearch
- **Terminal Tools**: Starship, eza, bat, fzf, ripgrep, fd, zoxide
- **Terminal Apps**: Warp (AI-powered), iTerm2, Alacritty, WezTerm, Kitty
- **Development**: Pre-commit, ShellCheck, direnv, git-delta, gitleaks

### AI Tools & Models
- **Local LLMs**: Ollama with Llama2 and DeepSeek Coder 33B
- **Model Management**: LM Studio for GUI model management
- **AI Editors**: Void IDE, Cursor IDE with AI capabilities
- **APIs**: OpenAI CLI for cloud AI access
- **Web UI**: Open WebUI for local model interaction

### Code Editors & Extensions
- **Editors**: VS Code, Cursor, Void IDE
- **Terminals**: Warp (AI-powered), iTerm2, Alacritty, WezTerm, Kitty
- **Extensions**: 30+ essential extensions for TypeScript, React, Vue, Docker, Kubernetes, and more
- **AI Integration**: GitHub Copilot, AI-powered code completion

### Productivity & Business Apps
- **Communication**: WhatsApp, Signal, Telegram, Slack, Discord
- **Note-taking**: Notion, Obsidian
- **Productivity**: Raycast, Rectangle, MeetingBar, AltTab
- **Media**: VLC, HandBrake, Spotify
- **Utilities**: Keka, AppCleaner, Hidden Bar, MonitorControl, Stats

## 🎯 Installation Options

### Using Setup Script (Easiest)
```bash
# Full installation
./setup-env.sh install

# Preview installation
./setup-env.sh preview

# Install specific categories
./setup-env.sh core        # Core development tools
./setup-env.sh frontend    # Frontend tools and editors
./setup-env.sh backend     # Backend tools and databases
./setup-env.sh business    # Productivity and business apps
./setup-env.sh ai          # AI tools and models

# Cleanup
./setup-env.sh cleanup

# Help
./setup-env.sh help
```

### Using Make (Advanced)
```bash
# Full installation
make install

# Preview installation
make setup-dry-run

# Category-specific installation
make setup-core      # Core development tools
make setup-frontend  # Frontend tools and editors
make setup-backend   # Backend tools and databases
make setup-business  # Productivity and business apps
make setup-ai        # AI tools and models
make setup-webui     # Web interfaces

# Quick setups
make setup-minimal   # Minimal setup (core only)
make setup-dev       # Developer setup (core + frontend + backend)
make setup-ai-focused # AI-focused setup
```

### Using Scripts Directly
```bash
# Full installation
./scripts/setup-env.sh

# Dry run (preview only)
./scripts/setup-env.sh --dry-run

# Install specific categories
./scripts/setup-env.sh --only core
./scripts/setup-env.sh --only frontend
./scripts/setup-env.sh --only backend
./scripts/setup-env.sh --only business

# Advanced options
./scripts/setup-env.sh --skip-models    # Skip AI model downloads
./scripts/setup-env.sh --skip-webui     # Skip web UI setup
./scripts/setup-env.sh --config my-config.yaml  # Use custom config
```

## ⚙️ Configuration

The entire setup is driven by `config.yaml`, which serves as the single source of truth for:

- Package lists by category
- VS Code extensions by role
- AI model configuration
- Service port settings
- Tool descriptions and documentation links

```yaml
# Example configuration
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

## 📚 Documentation

- **[Quick Start Guide](docs/quickstart/README.md)** - Get up and running in 5 minutes
- **[Complete Setup Guide](docs/guide/README.md)** - Comprehensive documentation
- **[Troubleshooting](docs/troubleshooting/README.md)** - Common issues and solutions
- **[Environment Setup Complete](docs/ENVIRONMENT_SETUP_COMPLETE.md)** - Auto-generated comprehensive documentation

### What's in the Complete Documentation
- **113+ Packages** - Complete list with descriptions and status
- **20+ VS Code Extensions** - Essential development extensions
- **Complete Dotfiles** - Shell, Git, SSH, and editor configurations
- **50+ Environment Variables** - Development environment setup
- **AI Tools & Models** - Local LLMs and AI development tools
- **Terminal Applications** - Modern terminals with configurations
- **Services & Ports** - Database, AI, and development services
- **macOS System Preferences** - Automatic configuration of Dock, Finder, Keyboard, Trackpad, Display, and more

## 🛠️ Maintenance

### Using Make
```bash
# Update packages
make update

# Run health checks
make health-check

# Clean up (remove everything)
make clean

# Preview cleanup
make clean-dry-run

# Check service status
make services-status
make ai-status
make db-status
```

### Using Scripts
```bash
# Health checks
./scripts/setup.sh --dry-run

# Cleanup
./scripts/cleanup.sh

# Generate comprehensive documentation
./scripts/generate-csv-readme.sh
```

## 🔧 Development

### Prerequisites
- macOS (Intel or Apple Silicon)
- Internet connection
- Administrator access
- At least 10GB free disk space

### Development Workflow
```bash
# Install development dependencies
make install

# Run tests and linting
make test
make lint

# Generate comprehensive documentation
make docs

# Run pre-commit hooks
make pre-commit
```

### CI/CD
- **GitHub Actions**: Automated testing, linting, and security scanning
- **Pre-commit hooks**: Code quality and security checks
- **Automated releases**: Tag-based releases with changelog generation

## 🏗️ Architecture

### Modular Design
- **`config.yaml`**: Single source of truth for all configuration
- **`scripts/lib/`**: Reusable library functions
- **`scripts/setup-env.sh`**: Main setup script with CLI flags
- **`scripts/cleanup.sh`**: Safe removal of all components
- **`Makefile`**: Common tasks and shortcuts

### Safety Features
- **Idempotent operations**: Safe to run multiple times
- **Dry run mode**: Preview changes before applying
- **Lock file protection**: Prevent concurrent executions
- **Comprehensive logging**: Detailed logs for troubleshooting
- **Health checks**: Pre and post-installation validation
- **Error handling**: Robust error handling with retries

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Update `config.yaml` if adding new tools
5. Run tests: `make test`
6. Run linting: `make lint`
7. Commit your changes: `git commit -m 'Add amazing feature'`
8. Push to the branch: `git push origin feature/amazing-feature`
9. Open a Pull Request

### Development Guidelines
- Follow shell scripting best practices
- Add comprehensive error handling
- Update documentation for new features
- Include tests for new functionality
- Use semantic commit messages

## 📊 Project Status

- **Version**: 4.0.0
- **Status**: Production Ready
- **CI/CD**: ✅ GitHub Actions
- **Security**: ✅ Gitleaks, ShellCheck, Pre-commit
- **Documentation**: ✅ Comprehensive auto-generated documentation
- **Testing**: ✅ Dry-run validation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) for package management
- [Ollama](https://ollama.ai/) for local LLM runtime
- [LM Studio](https://lmstudio.ai/) for model management
- [Void IDE](https://voideditor.com/) for AI-powered editing
- [VS Code](https://code.visualstudio.com/) for the base editor
- All the amazing open-source tools and libraries that make this possible
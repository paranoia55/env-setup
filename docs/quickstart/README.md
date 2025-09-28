# Quick Start Guide

Get up and running with the development environment in 5 minutes.

## Prerequisites

- macOS (Intel or Apple Silicon)
- Internet connection
- Administrator access
- At least 10GB free disk space

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/env-setup.git
   cd env-setup
   ```

2. **Run the setup**
   ```bash
   ./scripts/setup-env.sh
   ```

3. **Restart your terminal**
   ```bash
   source ~/.zshrc
   ```

That's it! The setup will install and configure everything automatically.

## What Gets Installed

- **113+ Packages**: Homebrew packages and applications
- **20+ VS Code Extensions**: Essential development extensions
- **Complete Dotfiles**: Shell, Git, SSH, and editor configurations
- **50+ Environment Variables**: Seamless development environment
- **AI Tools**: Local LLMs, AI editors, and development assistants
- **Modern Terminals**: Warp (AI-powered), iTerm2, Alacritty, WezTerm, Kitty
- **Database Services**: PostgreSQL, MongoDB, Redis, and more
- **Development Services**: Monitoring, object storage, and APIs
- **macOS System Preferences**: Automatic configuration for optimal development experience

📚 **For a complete list of everything installed and configured, see [Environment Setup Complete](../ENVIRONMENT_SETUP_COMPLETE.md)**

## Next Steps

1. **Start services** (if needed):
   ```bash
   brew services start postgresql
   brew services start redis
   ```

2. **Configure AI tools**:
   - Open LM Studio and download DeepSeek Coder 33B
   - Void IDE is already configured to use LM Studio

3. **Check status**:
   ```bash
   brew services list
   ollama list
   ```

## Troubleshooting

If something goes wrong:

1. Check the logs: `ls -la logs/`
2. Run health checks: `./scripts/setup-env.sh --dry-run`
3. See [Troubleshooting Guide](../troubleshooting/README.md)

## Customization

Edit `config.yaml` to customize what gets installed:

```yaml
categories:
  business:
    enabled: false  # Skip productivity apps
```

Then run: `./scripts/setup-env.sh --config config.yaml`










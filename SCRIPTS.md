# Scripts Overview

This document explains the purpose of each script in the `scripts/` directory.

## Main Scripts

### `setup.sh`
**Main setup script** - The primary script for installing the development environment.
- **Usage**: `./scripts/setup.sh [--dry-run] [--only CATEGORY]`
- **Purpose**: Installs packages from config.yaml based on category
- **Categories**: core, frontend, backend, business

### `cleanup.sh`
**Cleanup script** - Safely removes all installed components.
- **Usage**: `./scripts/cleanup.sh [--dry-run] [--force] [--keep-config]`
- **Purpose**: Uninstalls packages, removes extensions, cleans up AI models

### `test.sh`
**Test script** - Runs comprehensive tests on the setup.
- **Usage**: `./scripts/test.sh`
- **Purpose**: Validates config, tests scripts, checks syntax

## Documentation Scripts

### `generate-csv-readme.sh`
**Comprehensive documentation generator** - Creates complete setup documentation from config.yaml.
- **Usage**: `./scripts/generate-csv-readme.sh`
- **Purpose**: Generates ENVIRONMENT_SETUP_COMPLETE.md with 113+ packages, VS Code extensions, dotfiles, environment variables, and services

### `generate-diagram.sh`
**Diagram generator** - Creates visual diagrams of the setup.
- **Usage**: `./scripts/generate-diagram.sh`
- **Purpose**: Generates DOT files for setup visualization


## Library Scripts (`lib/`)

### `common.sh`
**Common utilities** - Shared functions for logging, error handling, config loading.

### `brew.sh`
**Homebrew functions** - Package installation, management, and verification.

### `extensions.sh`
**VS Code extensions** - Extension installation and management for multiple editors.

### `ai.sh`
**AI tools** - Ollama, LM Studio, OpenAI CLI setup and configuration.

### `shell.sh`
**Shell configuration** - Starship prompt, aliases, terminal configurations, and environment variables.

### `dotfiles.sh`
**Dotfile management** - Git, SSH, editor configurations, macOS settings, and comprehensive environment setup.

### `ssh-setup.sh`
**SSH key management** - SSH key generation, GitHub upload, and connection testing.

### `macos.sh`
**macOS system preferences** - Automatic configuration of Dock, Finder, Keyboard, Trackpad, Display, Accessibility, Date & Time, Sound, Energy Saver, and Security settings.

## Quick Reference

```bash
# Main entry point
./start.sh install

# Direct script usage
./scripts/setup.sh --dry-run --only core
./scripts/cleanup.sh --dry-run
./scripts/test.sh

# Documentation
./scripts/generate-csv-readme.sh
./scripts/generate-diagram.sh

# Make commands
make install
make clean
make test
make docs
```

## File Naming Convention

- **Main scripts**: Simple, descriptive names (`setup.sh`, `cleanup.sh`)
- **Utility scripts**: Action-based names (`generate-csv-readme.sh`, `test.sh`)
- **Library scripts**: Located in `lib/` directory with descriptive names

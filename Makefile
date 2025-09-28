# Environment Setup Makefile

.PHONY: help install clean test lint docs setup-dry-run setup-core setup-frontend setup-backend setup-business setup-ai setup-webui

# Default target
help:
	@echo "Environment Setup - Available Commands:"
	@echo ""
	@echo "Installation:"
	@echo "  install          Full installation"
	@echo "  setup-dry-run    Preview installation without installing"
	@echo "  setup-core       Install only core tools"
	@echo "  setup-frontend   Install only frontend tools"
	@echo "  setup-backend    Install only backend tools"
	@echo "  setup-business   Install only business/productivity tools"
	@echo "  setup-ai         Install only AI tools"
	@echo "  setup-webui      Install only web UI tools"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean            Remove all installed components"
	@echo "  clean-dry-run    Preview cleanup without removing"
	@echo "  update           Update installed packages"
	@echo "  health-check     Run health checks"
	@echo ""
	@echo "Development:"
	@echo "  test             Run all tests"
	@echo "  lint             Run linting and formatting"
	@echo "  docs             Generate documentation"
	@echo "  pre-commit       Run pre-commit hooks"
	@echo ""
	@echo "Configuration:"
	@echo "  config-validate  Validate config.yaml"
	@echo "  config-edit      Edit config.yaml"
	@echo "  config-show      Show current configuration"

# Installation targets
install:
	@echo "🚀 Starting full installation..."
	./scripts/setup.sh

setup-dry-run:
	@echo "🔍 Previewing installation..."
	./scripts/setup.sh --dry-run

setup-core:
	@echo "🔧 Installing core tools..."
	./scripts/setup.sh --only core

setup-frontend:
	@echo "🎨 Installing frontend tools..."
	./scripts/setup.sh --only frontend

setup-backend:
	@echo "🗄️ Installing backend tools..."
	./scripts/setup.sh --only backend

setup-business:
	@echo "💼 Installing business/productivity tools..."
	./scripts/setup.sh --only business

setup-ai:
	@echo "🤖 Installing AI tools..."
	./scripts/setup.sh --only ai

setup-webui:
	@echo "🌐 Installing web UI tools..."
	./scripts/setup.sh --only webui

# Maintenance targets
clean:
	@echo "🧹 Cleaning up installed components..."
	./scripts/cleanup.sh

clean-dry-run:
	@echo "🔍 Previewing cleanup..."
	./scripts/cleanup.sh --dry-run

update:
	@echo "🔄 Updating installed packages..."
	brew update && brew upgrade
	code --list-extensions | xargs -n 1 code --install-extension

health-check:
	@echo "🏥 Running health checks..."
	./scripts/setup.sh --dry-run

# Development targets
test:
	@echo "🧪 Running tests..."
	./scripts/setup.sh --dry-run
	./scripts/cleanup.sh --dry-run

lint:
	@echo "🔍 Running linting and formatting..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find scripts/ -name "*.sh" -exec shellcheck {} \; ; \
	else \
		echo "⚠️ shellcheck not installed, skipping shell linting"; \
	fi
	@if command -v shfmt >/dev/null 2>&1; then \
		shfmt -d scripts/ ; \
	else \
		echo "⚠️ shfmt not installed, skipping shell formatting"; \
	fi
	@if command -v yamllint >/dev/null 2>&1; then \
		yamllint config.yaml ; \
	else \
		echo "⚠️ yamllint not installed, skipping YAML linting"; \
	fi

docs:
	@echo "📚 Generating documentation..."
	./scripts/generate-csv-readme.sh

pre-commit:
	@echo "🔧 Running pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files ; \
	else \
		echo "⚠️ pre-commit not installed, skipping hooks"; \
	fi

# Configuration targets
config-validate:
	@echo "✅ Validating config.yaml..."
	@if command -v yq >/dev/null 2>&1; then \
		yq eval '.' config.yaml > /dev/null && echo "✅ config.yaml is valid" ; \
	else \
		echo "⚠️ yq not installed, cannot validate YAML"; \
	fi

config-edit:
	@echo "✏️ Opening config.yaml for editing..."
	@if command -v code >/dev/null 2>&1; then \
		code config.yaml ; \
	elif command -v vim >/dev/null 2>&1; then \
		vim config.yaml ; \
	else \
		open config.yaml ; \
	fi

config-show:
	@echo "📋 Current configuration:"
	@if command -v yq >/dev/null 2>&1; then \
		yq eval '.metadata' config.yaml ; \
		yq eval '.config' config.yaml ; \
	else \
		echo "⚠️ yq not installed, cannot show configuration"; \
	fi

# Service management
services-start:
	@echo "🚀 Starting services..."
	brew services start postgresql
	brew services start redis
	@if command -v ollama >/dev/null 2>&1; then \
		ollama serve > /dev/null 2>&1 & ; \
	fi

services-stop:
	@echo "🛑 Stopping services..."
	brew services stop postgresql
	brew services stop redis
	@if command -v ollama >/dev/null 2>&1; then \
		pkill -f "ollama serve" ; \
	fi

services-status:
	@echo "📊 Service status:"
	brew services list
	@if command -v ollama >/dev/null 2>&1; then \
		echo "Ollama models:" ; \
		ollama list ; \
	fi

# AI tools
ai-status:
	@echo "🤖 AI tools status:"
	@if command -v ollama >/dev/null 2>&1; then \
		echo "Ollama:" ; \
		ollama list ; \
	else \
		echo "Ollama: not installed" ; \
	fi
	@if lsof -i :1234 >/dev/null 2>&1; then \
		echo "LM Studio: running on port 1234" ; \
	else \
		echo "LM Studio: not running" ; \
	fi
	@if lsof -i :3000 >/dev/null 2>&1; then \
		echo "Open WebUI: running on port 3000" ; \
	else \
		echo "Open WebUI: not running" ; \
	fi

# Database tools
db-status:
	@echo "🗄️ Database status:"
	@if command -v psql >/dev/null 2>&1; then \
		echo "PostgreSQL: $(psql --version)" ; \
	else \
		echo "PostgreSQL: not installed" ; \
	fi
	@if command -v redis-cli >/dev/null 2>&1; then \
		echo "Redis: $(redis-cli --version)" ; \
	else \
		echo "Redis: not installed" ; \
	fi
	@if command -v mongosh >/dev/null 2>&1; then \
		echo "MongoDB: $(mongosh --version)" ; \
	else \
		echo "MongoDB: not installed" ; \
	fi

# Quick setup for different use cases
setup-minimal:
	@echo "⚡ Minimal setup (core tools only)..."
	./scripts/setup.sh --only core

setup-full:
	@echo "🚀 Full setup (everything)..."
	./scripts/setup.sh

setup-dev:
	@echo "👨‍💻 Developer setup (core + frontend + backend)..."
	./scripts/setup.sh --only core
	./scripts/setup.sh --only frontend
	./scripts/setup.sh --only backend

setup-ai-focused:
	@echo "🤖 AI-focused setup..."
	./scripts/setup.sh --only core
	./scripts/setup.sh --only ai










#!/bin/bash
# AI tools and model management functions

# Only set strict mode if not already set
if [ -z "${BASH_STRICT_MODE:-}" ]; then
    set -euo pipefail
    BASH_STRICT_MODE=1
fi

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install and configure Ollama
setup_ollama() {
    local dry_run="${1:-false}"
    
    if ! command_exists ollama; then
        log "ERROR" "Ollama not installed. Please install it first."
        return 1
    fi
    
    log "INFO" "Setting up Ollama..."
    
    # Start Ollama service if not running
    if ! pgrep -f "ollama serve" >/dev/null; then
        log "INFO" "Starting Ollama service..."
        if [ "$dry_run" = "true" ]; then
            log "INFO" "DRY RUN: Would start Ollama service"
        else
            ollama serve >/dev/null 2>&1 &
            sleep 3
        fi
    else
        log "INFO" "Ollama service already running"
    fi
    
    # Install models
    IFS=$'\n' read -d '' -r -a models < <(yq eval '.config.ollama_models[] // []' "${CONFIG_FILE:-config.yaml}" 2>/dev/null)
    for model in "${models[@]}"; do
        install_ollama_model "$model" "$dry_run"
    done
    
    log "SUCCESS" "Ollama setup completed"
}

# Install AI CLI tools (npm/npx based)
setup_ai_cli_tools() {
    local dry_run="${1:-false}"
    
    log "INFO" "Setting up AI CLI tools..."
    
    # Check if Node.js is available
    if ! command_exists node; then
        log "WARN" "Node.js not found. Skipping AI CLI tools installation."
        return 0
    fi
    
    # Get AI CLI tools from config
    IFS=$'\n' read -d '' -r -a cli_tools < <(yq eval '.config.ai_cli_tools[] // []' "${CONFIG_FILE:-config.yaml}" 2>/dev/null)
    
    for tool in "${cli_tools[@]}"; do
        if [ -n "$tool" ]; then
            install_ai_cli_tool "$tool" "$dry_run"
        fi
    done
    
    log "SUCCESS" "AI CLI tools setup completed"
}

# Install AI Python packages (via pipx)
setup_ai_python_packages() {
    local dry_run="${1:-false}"
    
    log "INFO" "Setting up AI Python packages..."
    
    # Check if pipx is available
    if ! command_exists pipx; then
        log "WARN" "pipx not found. Skipping AI Python packages installation."
        return 0
    fi
    
    # Get AI Python packages from config
    IFS=$'\n' read -d '' -r -a python_packages < <(yq eval '.config.ai_python_packages[] // []' "${CONFIG_FILE:-config.yaml}" 2>/dev/null)
    
    for package in "${python_packages[@]}"; do
        if [ -n "$package" ]; then
            install_ai_python_package "$package" "$dry_run"
        fi
    done
    
    log "SUCCESS" "AI Python packages setup completed"
}

# Install individual AI Python package
install_ai_python_package() {
    local package="$1"
    local dry_run="${2:-false}"
    
    if [ "$dry_run" = "true" ]; then
        log "INFO" "DRY RUN: Would install Python package: $package"
        return 0
    fi
    
    log "INFO" "Installing Python package: $package"
    
    # Check if package is already installed
    if pipx list | grep -q "$package"; then
        log "SUCCESS" "$package: already installed"
    else
        if pipx install "$package" >/dev/null 2>&1; then
            log "SUCCESS" "$package installed"
        else
            log "WARN" "$package installation failed"
        fi
    fi
}

# Install individual AI CLI tool
install_ai_cli_tool() {
    local tool="$1"
    local dry_run="${2:-false}"
    
    case "$tool" in
        "gemini-cli")
            if [ "$dry_run" = "true" ]; then
                log "INFO" "DRY RUN: Would install Gemini CLI via npx"
            else
                log "INFO" "Installing Gemini CLI..."
                if npx @google/gemini-cli --version >/dev/null 2>&1; then
                    log "SUCCESS" "Gemini CLI already available via npx"
                else
                    log "INFO" "Gemini CLI will be available via 'npx @google/gemini-cli'"
                fi
            fi
            ;;
        *)
            log "WARN" "Unknown AI CLI tool: $tool"
            ;;
    esac
}

# Install Ollama model
install_ollama_model() {
    local model="$1"
    local dry_run="${2:-false}"
    
    if [ "$dry_run" = "true" ]; then
        log "INFO" "DRY RUN: Would install Ollama model: $model"
        return 0
    fi
    
    # Check if model is already installed
    if ollama list 2>/dev/null | grep -q "$model"; then
        log "INFO" "Model $model already installed"
        return 0
    fi
    
    log "INFO" "Installing Ollama model: $model"
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        ollama pull "$model"; then
        log "SUCCESS" "Model $model installed"
    else
        log "ERROR" "Failed to install model $model"
        return 1
    fi
}

# Configure Void IDE for LM Studio
configure_void_ide() {
    local dry_run="${1:-false}"
    
    if ! command_exists void; then
        log "WARN" "Void IDE not installed, skipping configuration"
        return 0
    fi
    
    log "INFO" "Configuring Void IDE for DeepSeek Coder via LM Studio..."
    
    local void_settings_dir="$HOME/Library/Application Support/void/User"
    local void_settings_file="$void_settings_dir/settings.json"
    
    if [ "$dry_run" = "true" ]; then
        log "INFO" "DRY RUN: Would configure Void IDE settings"
        return 0
    fi
    
    mkdir -p "$void_settings_dir"
    
    # Ensure settings.json exists and is valid JSON
    if [ ! -f "$void_settings_file" ] || ! jq . "$void_settings_file" >/dev/null 2>&1; then
        echo "{}" > "$void_settings_file"
    fi
    
    # Configure Void IDE settings
    local deepseek_model="${DEEPSEEK_MODEL:-deepseek-coder-33b}"
    local lm_studio_port="${LM_STUDIO_PORT:-1234}"
    
    jq --arg base_url "http://localhost:$lm_studio_port/v1" \
       --arg api_key "lm-studio" \
       --arg model "$deepseek_model" '
    .["llm.defaultProvider"] = "openai-compatible" |
    .["llm.providers.openai-compatible.baseUrl"] = $base_url |
    .["llm.providers.openai-compatible.apiKey"] = $api_key |
    .["llm.defaultModel"] = $model |
    .["llm.agentMode.enabled"] = true
    ' "$void_settings_file" > "$void_settings_file.tmp" && mv "$void_settings_file.tmp" "$void_settings_file"
    
    log "SUCCESS" "Void IDE configured for $deepseek_model via LM Studio"
}

# Setup Open WebUI with Docker
setup_open_webui() {
    local dry_run="${1:-false}"
    
    if ! command_exists docker; then
        log "WARN" "Docker not installed, skipping Open WebUI setup"
        return 0
    fi
    
    log "INFO" "Setting up Open WebUI..."
    
    if [ "$dry_run" = "true" ]; then
        log "INFO" "DRY RUN: Would setup Open WebUI with Docker"
        return 0
    fi
    
    # Check if Open WebUI is already running
    if docker ps --format "table {{.Names}}" | grep -q "open-webui"; then
        log "INFO" "Open WebUI already running"
        return 0
    fi
    
    # Start Open WebUI container
    local webui_port="${OPEN_WEBUI_PORT:-3000}"
    
    if docker run -d \
        --name open-webui \
        -p "$webui_port:8080" \
        -v open-webui:/app/backend/data \
        --restart always \
        ghcr.io/open-webui/open-webui:main; then
        log "SUCCESS" "Open WebUI started on port $webui_port"
    else
        log "ERROR" "Failed to start Open WebUI"
        return 1
    fi
}

# Install OpenAI CLI via pipx
install_openai_cli() {
    local dry_run="${1:-false}"
    
    if ! command_exists pipx; then
        log "WARN" "pipx not installed, skipping OpenAI CLI installation"
        return 0
    fi
    
    if command_exists openai; then
        log "INFO" "OpenAI CLI already installed"
        return 0
    fi
    
    log "INFO" "Installing OpenAI CLI via pipx..."
    
    if [ "$dry_run" = "true" ]; then
        log "INFO" "DRY RUN: Would install OpenAI CLI"
        return 0
    fi
    
    if retry "${RETRY_ATTEMPTS:-3}" "${RETRY_DELAY:-2}" \
        pipx install openai; then
        log "SUCCESS" "OpenAI CLI installed"
    else
        log "ERROR" "Failed to install OpenAI CLI"
        return 1
    fi
}

# Check AI services status
check_ai_services() {
    log "INFO" "Checking AI services status..."
    
    local services_ok=0
    
    # Check Ollama
    if command_exists ollama; then
        if pgrep -f "ollama serve" >/dev/null; then
            local model_count
            model_count=$(ollama list 2>/dev/null | wc -l | tr -d ' ')
            log "SUCCESS" "Ollama: running with $model_count models"
        else
            log "WARN" "Ollama: installed but not running"
        fi
    else
        log "WARN" "Ollama: not installed"
        services_ok=$((services_ok + 1))
    fi
    
    # Check LM Studio port
    local lm_port="${LM_STUDIO_PORT:-1234}"
    if port_in_use "$lm_port"; then
        log "SUCCESS" "LM Studio: running on port $lm_port"
    else
        log "WARN" "LM Studio: not running on port $lm_port"
        services_ok=$((services_ok + 1))
    fi
    
    # Check Open WebUI
    local webui_port="${OPEN_WEBUI_PORT:-3000}"
    if port_in_use "$webui_port"; then
        log "SUCCESS" "Open WebUI: running on port $webui_port"
    else
        log "WARN" "Open WebUI: not running on port $webui_port"
        services_ok=$((services_ok + 1))
    fi
    
    # Check Void IDE
    if command_exists void; then
        log "SUCCESS" "Void IDE: installed"
    else
        log "WARN" "Void IDE: not installed"
        services_ok=$((services_ok + 1))
    fi
    
    # Check Cursor IDE
    if command_exists cursor; then
        log "SUCCESS" "Cursor IDE: installed"
    else
        log "WARN" "Cursor IDE: not installed"
        services_ok=$((services_ok + 1))
    fi
    
    if [ $services_ok -gt 0 ]; then
        log "WARN" "$services_ok AI services not available"
        return 1
    else
        log "SUCCESS" "All AI services available"
        return 0
    fi
}

# Generate AI tools report
generate_ai_report() {
    local output_file="${1:-logs/ai-report-$(date +%Y%m%d-%H%M%S).txt}"
    
    mkdir -p "$(dirname "$output_file")"
    
    {
        echo "=== AI Tools Report ==="
        echo "Date: $(date)"
        echo ""
        
        # Ollama status
        echo "=== Ollama ==="
        if command_exists ollama; then
            echo "Installed: Yes"
            echo "Running: $(pgrep -f 'ollama serve' >/dev/null && echo 'Yes' || echo 'No')"
            echo "Models:"
            ollama list 2>/dev/null | sed 's/^/  /' || echo "  No models installed"
        else
            echo "Installed: No"
        fi
        echo ""
        
        # LM Studio status
        echo "=== LM Studio ==="
        local lm_port="${LM_STUDIO_PORT:-1234}"
        echo "Port: $lm_port"
        echo "Running: $(port_in_use "$lm_port" && echo 'Yes' || echo 'No')"
        echo ""
        
        # Open WebUI status
        echo "=== Open WebUI ==="
        local webui_port="${OPEN_WEBUI_PORT:-3000}"
        echo "Port: $webui_port"
        echo "Running: $(port_in_use "$webui_port" && echo 'Yes' || echo 'No')"
        if command_exists docker; then
            echo "Container: $(docker ps --format 'table {{.Names}}' | grep -q 'open-webui' && echo 'Running' || echo 'Not running')"
        fi
        echo ""
        
        # IDE status
        echo "=== AI IDEs ==="
        echo "Void IDE: $(command_exists void && echo 'Installed' || echo 'Not installed')"
        echo "Cursor IDE: $(command_exists cursor && echo 'Installed' || echo 'Not installed')"
        echo ""
        
        # CLI tools
        echo "=== AI CLI Tools ==="
        echo "OpenAI CLI: $(command_exists openai && echo 'Installed' || echo 'Not installed')"
        
    } > "$output_file"
    
    log "SUCCESS" "AI report saved to $output_file"
}







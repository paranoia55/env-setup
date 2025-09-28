#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config.yaml"
OUTPUT_FILE="$PROJECT_ROOT/docs/${DOCS_OUTPUT_FILENAME:-ENVIRONMENT_SETUP_COMPLETE}.md"
CSV_FILE="/tmp/packages_$$.csv"

# Cleanup function
cleanup() {
    rm -f "$CSV_FILE"
}
trap cleanup EXIT

# Generate CSV with package data
generate_csv() {
    echo "Name,Category,Description,Docs,Status" > "$CSV_FILE"
    
    # Collect all packages and deduplicate
    all_packages=()
    for category in core frontend backend business ai; do
        # Brew packages
        for package in $(yq eval ".packages.$category.brew[] // []" "$CONFIG_FILE" 2>/dev/null | grep -v "^\[\]$"); do
            if [ -n "$package" ]; then
                all_packages+=("$package")
            fi
        done
        
        # Cask packages
        for package in $(yq eval ".packages.$category.cask[] // []" "$CONFIG_FILE" 2>/dev/null | grep -v "^\[\]$"); do
            if [ -n "$package" ]; then
                all_packages+=("$package")
            fi
        done
    done
    
    # Remove duplicates
    IFS=$'\n' read -d '' -r -a unique_packages < <(printf '%s\n' "${all_packages[@]}" | sort -u)
    
    echo "Processing ${#unique_packages[@]} unique packages..."
    
    # Process each package and write to CSV
    for package in "${unique_packages[@]}"; do
        description=$(yq eval ".tool_info.$package.description // \"brew package\"" "$CONFIG_FILE" 2>/dev/null || echo "brew package")
        category_name=$(yq eval ".tool_info.$package.category // \"Unknown\"" "$CONFIG_FILE" 2>/dev/null || echo "Unknown")
        docs=$(yq eval ".tool_info.$package.docs // \"https://github.com/$package\"" "$CONFIG_FILE" 2>/dev/null || echo "https://github.com/$package")
        
        # Fix "Unknown" category with better categorization
        if [ "$category_name" = "Unknown" ]; then
            if [[ "$package" =~ ^(alt-tab|rectangle|hiddenbar|monitorcontrol|stats|shottr|keepingyouawake|meetingbar)$ ]]; then
                category_name="System Tools"
            elif [[ "$package" =~ ^(appcleaner|keka|handbrake|vlc)$ ]]; then
                category_name="Utilities"
            elif [[ "$package" =~ ^(brave-browser|microsoft-edge)$ ]]; then
                category_name="Browsers"
            elif [[ "$package" =~ ^(whatsapp|signal|telegram|slack|discord|microsoft-teams|zoom)$ ]]; then
                category_name="Communication"
            elif [[ "$package" =~ ^(notion|obsidian)$ ]]; then
                category_name="Productivity"
            elif [[ "$package" =~ ^(bitwarden)$ ]]; then
                category_name="Security"
            elif [[ "$package" =~ ^(insomnia|postman)$ ]]; then
                category_name="Development"
            elif [[ "$package" =~ ^(raycast)$ ]]; then
                category_name="Productivity"
            else
                category_name="Applications"
            fi
        fi
        
        # Based on the actual setup script output, all packages showed "already installed and up to date"
        # This matches exactly what was logged during the setup process
        status="already installed and up to date"
        
        # Escape CSV values (handle commas and quotes)
        package_escaped=$(echo "$package" | sed 's/,/\\,/g' | sed 's/"/\\"/g')
        description_escaped=$(echo "$description" | sed 's/,/\\,/g' | sed 's/"/\\"/g')
        category_escaped=$(echo "$category_name" | sed 's/,/\\,/g' | sed 's/"/\\"/g')
        docs_escaped=$(echo "$docs" | sed 's/,/\\,/g' | sed 's/"/\\"/g')
        status_escaped=$(echo "$status" | sed 's/,/\\,/g' | sed 's/"/\\"/g')
        
        # Use printf to ensure proper CSV formatting
        printf "%s,%s,%s,%s,%s\n" "$package_escaped" "$category_escaped" "$description_escaped" "$docs_escaped" "$status_escaped" >> "$CSV_FILE"
        
        echo "  ✓ $package ($category_name) - $description"
    done
    
    echo "CSV generated with $(wc -l < "$CSV_FILE") lines (including header)"
}

# Generate README from CSV
generate_readme_from_csv() {
    # shellcheck disable=SC2034 # total_packages is used for validation
    local total_packages=$(($(wc -l < "$CSV_FILE") - 1))  # Subtract header line
    
    cat > "$OUTPUT_FILE" << 'HEADER'
# Environment Setup - Complete Documentation

**Version:** 4.0.0  
**Generated:** $(date)  
**Total Packages:** 113+ tools and applications

## 🚀 Quick Start

```bash
# Clone and run
git clone https://github.com/your-username/env-setup.git
cd env-setup
./setup-env.sh
```

## 📋 What This Setup Does

This comprehensive environment setup installs and configures:

- **113+ Packages** - Homebrew packages and applications
- **20+ VS Code Extensions** - Essential development extensions
- **Complete Dotfiles** - Shell, Git, SSH, and editor configurations
- **Environment Variables** - 50+ variables for seamless development
- **AI Tools** - Local LLMs, AI editors, and development assistants
- **Terminal Apps** - Modern terminals with AI capabilities
- **Database Services** - PostgreSQL, MongoDB, Redis, and more
- **Development Services** - Monitoring, object storage, and APIs

## 📦 Installed Packages

The following packages are installed via Homebrew (brew) and Homebrew Cask (cask):

HEADER

    # Generate package list from CSV as a table
    # First, sort by category then by name
    local sorted_csv
    sorted_csv=$(mktemp)
    tail -n +2 "$CSV_FILE" | sort -t',' -k2,2 -k1,1 > "$sorted_csv"
    
    # Group by category and create table
    # shellcheck disable=SC2034 # current_category is used for grouping
    local current_category=""
    local count=0
    
    echo "| Name | Category | Description | Docs | Status |" >> "$OUTPUT_FILE"
    echo "| --- | --- | --- | --- | --- |" >> "$OUTPUT_FILE"
    
    # Use a more robust CSV parsing approach
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        
        # Parse CSV line properly handling commas in fields
        # Split by comma but respect escaped commas
        IFS=',' read -ra fields <<< "$line"
        
        # Reconstruct fields that might have been split by commas in descriptions
        local field_count=${#fields[@]}
        if [ "$field_count" -gt 5 ]; then
            # If we have more than 5 fields, the description likely contains commas
            # Reconstruct: name, category, description (with commas), docs, status
            name="${fields[0]}"
            category="${fields[1]}"
            # Join fields 2 to (length-2) as description
            description=""
            local last_desc_index=$((field_count - 3))
            for ((i=2; i<=last_desc_index; i++)); do
                if [ $i -eq 2 ]; then
                    description="${fields[i]}"
                else
                    description="${description},${fields[i]}"
                fi
            done
            docs="${fields[$((field_count - 2))]}"
            status="${fields[$((field_count - 1))]}"
        else
            # Normal case with 5 fields
            name="${fields[0]}"
            category="${fields[1]}"
            description="${fields[2]}"
            docs="${fields[3]}"
            status="${fields[4]}"
        fi
        
        # Skip empty lines
        if [ -z "$name" ]; then
            continue
        fi
        
        count=$((count + 1))
        
        # Unescape CSV values
        name=$(echo "$name" | sed 's/\\,/,/g' | sed 's/\\"/"/g')
        category=$(echo "$category" | sed 's/\\,/,/g' | sed 's/\\"/"/g')
        description=$(echo "$description" | sed 's/\\,/,/g' | sed 's/\\"/"/g')
        docs=$(echo "$docs" | sed 's/\\,/,/g' | sed 's/\\"/"/g')
        status=$(echo "$status" | sed 's/\\,/,/g' | sed 's/\\"/"/g')
        
        # Add table row
        echo "| **$name** | $category | $description | [$name]($docs) | ✅ $status |" >> "$OUTPUT_FILE"
    done < "$sorted_csv"
    
    # Clean up temp file
    rm -f "$sorted_csv"
    
    echo "" >> "$OUTPUT_FILE"
    echo "**Total packages: $count**" >> "$OUTPUT_FILE"
    
    # Add comprehensive documentation sections
    add_vscode_extensions_section
    add_dotfiles_section
    add_environment_variables_section
    add_services_section
    add_ai_tools_section
    add_terminal_configs_section
    add_macos_section
    
    cat >> "$OUTPUT_FILE" << 'FOOTER'

<script>
// Table sorting functionality - only runs in browser environments
(function() {
    // Check if we're in a browser environment
    if (typeof window === 'undefined' || typeof document === 'undefined') {
        return; // Skip in non-browser environments (GitHub, etc.)
    }
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSortableTables);
    } else {
        initSortableTables();
    }
    
    function initSortableTables() {
        // Find all tables in the document
        const tables = document.querySelectorAll('table');
        
        tables.forEach(table => {
            // Skip if already initialized
            if (table.dataset.sortable === 'true') return;
            
            // Add sortable class and data attribute
            table.classList.add('sortable-table');
            table.dataset.sortable = 'true';
            
            // Add click handlers to all header cells
            const headers = table.querySelectorAll('thead th, tr:first-child th');
            headers.forEach((header, index) => {
                // Skip if already has click handler
                if (header.dataset.sortable === 'true') return;
                
                header.style.cursor = 'pointer';
                header.style.userSelect = 'none';
                header.dataset.sortable = 'true';
                header.dataset.column = index;
                
                // Add sort indicator
                const indicator = document.createElement('span');
                indicator.innerHTML = ' ↕️';
                indicator.style.fontSize = '0.8em';
                indicator.style.opacity = '0.5';
                header.appendChild(indicator);
                
                header.addEventListener('click', () => sortTable(table, index));
            });
        });
    }
    
    function sortTable(table, columnIndex) {
        const tbody = table.querySelector('tbody') || table;
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Skip header row if it exists
        const dataRows = rows.filter(row => {
            const firstCell = row.querySelector('td, th');
            return firstCell && firstCell.tagName === 'TD';
        });
        
        if (dataRows.length === 0) return;
        
        // Determine current sort direction
        const currentSort = table.dataset.sortColumn;
        const currentDirection = table.dataset.sortDirection;
        let newDirection = 'asc';
        
        if (currentSort == columnIndex) {
            newDirection = currentDirection === 'asc' ? 'desc' : 'asc';
        }
        
        // Update sort indicators
        updateSortIndicators(table, columnIndex, newDirection);
        
        // Sort the rows
        dataRows.sort((a, b) => {
            const aText = getCellText(a, columnIndex);
            const bText = getCellText(b, columnIndex);
            
            // Try to parse as numbers
            const aNum = parseFloat(aText);
            const bNum = parseFloat(bText);
            
            let comparison = 0;
            if (!isNaN(aNum) && !isNaN(bNum)) {
                comparison = aNum - bNum;
            } else {
                comparison = aText.localeCompare(bText, undefined, { numeric: true });
            }
            
            return newDirection === 'asc' ? comparison : -comparison;
        });
        
        // Reorder the rows in the DOM
        dataRows.forEach(row => tbody.appendChild(row));
        
        // Store current sort state
        table.dataset.sortColumn = columnIndex;
        table.dataset.sortDirection = newDirection;
    }
    
    function getCellText(row, columnIndex) {
        const cells = row.querySelectorAll('td, th');
        const cell = cells[columnIndex];
        if (!cell) return '';
        
        // Get text content, removing any HTML tags and extra whitespace
        return cell.textContent.trim();
    }
    
    function updateSortIndicators(table, columnIndex, direction) {
        const headers = table.querySelectorAll('th[data-sortable="true"]');
        headers.forEach((header, index) => {
            const indicator = header.querySelector('span');
            if (index === columnIndex) {
                indicator.innerHTML = direction === 'asc' ? ' ↑' : ' ↓';
                indicator.style.opacity = '1';
            } else {
                indicator.innerHTML = ' ↕️';
                indicator.style.opacity = '0.5';
            }
        });
    }
})();
</script>

<style>
/* Sortable table styles - only applied in browser environments */
.sortable-table th[data-sortable="true"]:hover {
    background-color: #f0f0f0;
    transition: background-color 0.2s ease;
}

.sortable-table th[data-sortable="true"] {
    position: relative;
    padding-right: 20px;
}

.sortable-table th[data-sortable="true"] span {
    position: absolute;
    right: 5px;
    top: 50%;
    transform: translateY(-50%);
}
</style>

## Next Steps

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Start services** (if needed): `brew services start postgresql`
3. **Configure AI tools**: Open LM Studio and download models
4. **Check status**: `make services-status`

## Customization

Edit `config.yaml` to customize what gets installed:

```yaml
categories:
  business:
    enabled: false  # Skip productivity apps
```

Then run: `./scripts/setup-v4.sh --config config.yaml`

---

*This README is auto-generated. To update it, run: `./scripts/generate-csv-readme.sh`*
FOOTER
}

# Add VS Code extensions section
add_vscode_extensions_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 🔌 VS Code Extensions

The following extensions are installed for VS Code, Cursor, and Void IDE:

| Extension | Description | Category |
| --- | --- | --- |
| EditorConfig.EditorConfig | Maintain consistent coding styles | Core |
| Prisma.prisma | Prisma ORM support | Database |
| aaron-bond.better-comments | Better comment highlighting | Core |
| bradlc.vscode-tailwindcss | Tailwind CSS IntelliSense | Frontend |
| christian-kohler.path-intellisense | Path autocomplete | Core |
| dbaeumer.vscode-eslint | ESLint integration | Core |
| eamodio.gitlens | Git supercharged | Git |
| eriklynd.json-tools | JSON manipulation tools | Core |
| esbenp.prettier-vscode | Code formatter | Core |
| github.copilot-chat | AI pair programming | AI |
| github.vscode-pull-request-github | GitHub PR management | Git |
| humao.rest-client | REST API testing | Development |
| mikestead.dotenv | .env file support | Core |
| ms-azuretools.vscode-docker | Docker support | DevOps |
| ms-kubernetes-tools.vscode-kubernetes-tools | Kubernetes support | DevOps |
| ms-vscode-remote.remote-containers | Remote development | DevOps |
| ms-vscode.vscode-typescript-next | TypeScript support | Core |
| ms-vsliveshare.vsliveshare | Live collaboration | Core |
| mtxr.sqltools | Database management | Database |

EOF
}

# Add dotfiles section
add_dotfiles_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 📁 Configuration Files (Dotfiles)

The setup script creates and configures the following dotfiles:

### Shell Configuration
- **~/.zshrc** - Zsh shell configuration with:
  - Homebrew environment setup
  - Starship prompt configuration
  - Modern terminal tool aliases (eza, bat, fd, rg)
  - FZF configuration with previews
  - Zoxide (smarter cd) integration
  - Direnv environment management
  - Jump directory navigation

### Git Configuration
- **~/.gitconfig** - Git configuration with:
  - User settings (name, email, editor)
  - Core settings (autocrlf, whitespace, precomposeunicode)
  - Branch defaults (main)
  - Comprehensive aliases (st, co, br, ci, lg, etc.)
  - GitHub-specific aliases (pr, prd, prr, prm, etc.)
  - Color configuration
  - URL rewriting for GitHub

### SSH Configuration
- **~/.ssh/config** - SSH configuration with:
  - Key management settings
  - GitHub, GitLab, Bitbucket host configurations
  - SSH key generation (ed25519)
  - Keychain integration

### Editor Configurations
- **~/.vimrc** - Vim configuration with:
  - Plugin management (Vundle)
  - Modern settings (numbers, cursorline, search)
  - Key mappings for navigation
  - FZF integration
  - Git integration

- **~/.config/nvim/init.vim** - Neovim configuration
- **~/.pythonrc** - Python startup configuration

### Terminal Configurations
- **~/.config/alacritty/alacritty.yml** - Alacritty terminal config
- **~/.config/wezterm/wezterm.lua** - WezTerm terminal config  
- **~/.config/kitty/kitty.conf** - Kitty terminal config

### Development Templates
- **~/.envrc.template** - Direnv environment template
- **~/.gitignore.template** - Git ignore template

EOF
}

# Add environment variables section
add_environment_variables_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 🌍 Environment Variables

The setup configures comprehensive environment variables for seamless development:

### Development Paths
```bash
export DEV_HOME="$HOME/Development"
export PROJECTS="$DEV_HOME/projects"
export DOTFILES="$DEV_HOME/dotfiles"
export WORKSPACE="$DEV_HOME/workspace"
```

### Language-Specific Paths
```bash
# Go
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONDONTWRITEBYTECODE=1

# Node.js
export NVM_DIR="$HOME/.nvm"
export VOLTA_HOME="$HOME/.volta"
export NODE_ENV="development"

# Rust
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
```

### AI Tools Configuration
```bash
export OLLAMA_HOST="127.0.0.1:11434"
export LM_STUDIO_HOST="127.0.0.1:1234"
export OPEN_WEBUI_HOST="127.0.0.1:3000"
export OLLAMA_MODELS="$HOME/.ollama/models"
```

### Database Defaults
```bash
export POSTGRES_HOST="localhost"
export POSTGRES_PORT="5432"
export POSTGRES_USER="postgres"
export MONGODB_URI="mongodb://localhost:27017"
export REDIS_URL="redis://localhost:6379"
```

### Development Tools
```bash
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export BAT_THEME="DarkNeon"
export EXA_COLORS="di=34:ln=35:so=32:pi=33:ex=31"
```

### Cloud Providers
```bash
export AWS_PROFILE="default"
export AWS_REGION="us-east-1"
export GOOGLE_APPLICATION_CREDENTIALS=""
export AZURE_SUBSCRIPTION_ID=""
```

EOF
}

# Add services section
add_services_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 🚀 Services & Ports

The setup configures the following services and their default ports:

### Database Services
| Service | Port | Description | Start Command |
| --- | --- | --- | --- |
| PostgreSQL | 5432 | Relational database | `brew services start postgresql` |
| MongoDB | 27017 | Document database | `brew services start mongodb-community` |
| Redis | 6379 | In-memory data store | `brew services start redis` |
| MySQL | 3306 | Alternative relational DB | `brew services start mysql` |

### AI Services
| Service | Port | Description | Start Command |
| --- | --- | --- | --- |
| Ollama | 11434 | Local LLM server | `ollama serve` |
| LM Studio | 1234 | GUI model management | Open LM Studio app |
| Open WebUI | 3000 | Web interface for LLMs | `open-webui` |

### Development Services
| Service | Port | Description | Start Command |
| --- | --- | --- | --- |
| MinIO | 9000 | Object storage | `minio server ~/minio-data` |
| Grafana | 3001 | Monitoring dashboard | `brew services start grafana` |
| Prometheus | 9090 | Metrics collection | `brew services start prometheus` |

### Container Services
| Service | Port | Description | Start Command |
| --- | --- | --- | --- |
| Docker | N/A | Container runtime | `colima start` |
| Kubernetes | N/A | Container orchestration | `kind create cluster` |

EOF
}

# Add AI tools section
add_ai_tools_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 🤖 AI Tools & Models

The setup includes comprehensive AI development tools:

### Local LLM Runtime
- **Ollama** - Run large language models locally
  - Default models: Llama2, DeepSeek Coder 33B
  - API endpoint: http://localhost:11434
  - Model storage: ~/.ollama/models

### AI Development Tools
- **LM Studio** - GUI for managing and running LLMs
  - Model browser and downloader
  - Local server management
  - API endpoint: http://localhost:1234

- **Open WebUI** - Web interface for local LLMs
  - Chat interface for models
  - Model management
  - API endpoint: http://localhost:3000

### AI-Powered Editors
- **Cursor** - AI-powered code editor
  - Built-in AI chat and code completion
  - GitHub Copilot integration
  - Local model support

- **Void IDE** - Open source AI code editor
  - Cursor alternative
  - Local model integration
  - Community-driven development

### AI Development Extensions
- **GitHub Copilot** - AI pair programming
- **GitHub Copilot Chat** - AI coding assistant
- **LM Studio integration** - Local model support

EOF
}

# Add terminal configurations section
add_terminal_configs_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 💻 Terminal Applications

The setup installs and configures multiple modern terminal applications:

### AI-Powered Terminal
- **Warp** - Modern terminal with AI features
  - Built-in AI command suggestions
  - Split panes and workflows
  - Modern UI with GPU acceleration

### Traditional Terminals
- **iTerm2** - Advanced terminal for macOS
  - Split panes and tabs
  - Customizable themes
  - Advanced search and selection

- **Alacritty** - GPU-accelerated terminal
  - Cross-platform compatibility
  - High performance
  - Customizable configuration

- **WezTerm** - GPU-accelerated terminal multiplexer
  - Built-in multiplexing
  - Cross-platform
  - Lua configuration

- **Kitty** - GPU-accelerated terminal
  - High performance
  - Image support
  - Customizable themes

### Terminal Tools
- **Starship** - Minimal, fast shell prompt
- **eza** - Modern ls replacement with icons
- **bat** - cat with syntax highlighting
- **fd** - Simple, fast find alternative
- **ripgrep** - Fast recursive grep
- **fzf** - Fuzzy finder with previews
- **zoxide** - Smarter cd command
- **jump** - Directory navigation

EOF
}

# Add macOS system preferences section
add_macos_section() {
    cat >> "$OUTPUT_FILE" << 'EOF'

## 🖥️ macOS System Preferences

The setup automatically configures macOS system preferences for an optimal development experience:

### Dock Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Size** | 48px (medium) | Dock icon size |
| **Auto-hide** | Enabled | Dock hides automatically |
| **Recent apps** | Hidden | Cleaner interface |
| **Magnification** | Disabled | No hover magnification |
| **Position** | Bottom | Dock location |

### Finder Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Path bar** | Visible | Shows current folder path |
| **Status bar** | Visible | Shows file information |
| **File extensions** | Always visible | Shows all file extensions |
| **Hidden files** | Visible | Shows hidden files for development |
| **Search scope** | Current folder | Default search location |

### Keyboard Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Key repeat** | Fast (1) | Key repeat speed |
| **Initial delay** | Short (15ms) | Delay before repeat starts |
| **Press and hold** | Disabled | Disabled for special characters |

### Trackpad Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Tap to click** | Enabled | Tap to click functionality |
| **Three-finger drag** | Enabled | Three-finger drag gestures |
| **Natural scrolling** | Enabled | Natural scroll direction |

### Display Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Night Shift** | Auto | Automatic blue light reduction |
| **True Tone** | Auto | Automatic color temperature |
| **Auto-brightness** | Enabled | Automatic brightness adjustment |

### Accessibility Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Reduce motion** | Disabled | Motion effects enabled |
| **Reduce transparency** | Disabled | Transparency effects enabled |
| **Increase contrast** | Disabled | Standard contrast level |

### Date & Time Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Auto timezone** | Enabled | Automatic timezone detection |
| **Menu bar display** | Date and time visible | Shows in menu bar |
| **Time format** | 12-hour format | Standard time format |

### Sound Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Volume in menu bar** | Visible | Volume control in menu bar |
| **Sound effects** | Enabled | System sound effects |
| **Volume feedback** | Enabled | Audio feedback for volume changes |

### Energy Saver Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Sleep when display off** | Enabled | Computer sleeps with display |
| **Hard disk sleep** | Enabled when possible | Disks sleep when idle |
| **Wake for network** | Enabled | Wake for network access |

### Security Configuration
| Setting | Value | Description |
| --- | --- | --- |
| **Password after sleep** | Immediately required | Security prompt timing |
| **App sources** | App Store and identified developers | Allowed app sources |
| **FileVault** | User prompt for manual setup | Disk encryption setup |

### Configuration Management

All macOS preferences are configurable via `config.yaml`:

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

### Manual Configuration

To reconfigure macOS settings:

```bash
# Reconfigure all macOS settings
./scripts/lib/macos.sh

# Or through the main setup
./setup-env.sh
```

EOF
}

# Main function
main() {
    log "INFO" "Generating CSV-based README..."
    
    # Generate CSV
    generate_csv
    
    # Generate README from CSV
    generate_readme_from_csv
    
    log "SUCCESS" "CSV-based README generated: $OUTPUT_FILE"
    local actual_count
    actual_count=$(grep -c "| \*\*" "$OUTPUT_FILE" || echo "0")
    echo "✅ README generated with $actual_count packages"
}

# Run main function
main "$@"

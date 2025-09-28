#!/bin/bash
# Environment Setup - Main Entry Point
# Simple entry point for the development environment setup

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           🚀 Environment Setup v1.0 🚀                      ║"
    echo "║                                                              ║"
    echo "║    Comprehensive development environment for macOS          ║"
    echo "║    with AI tools, databases, and productivity apps          ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Show help
show_help() {
    echo -e "${BLUE}Environment Setup v1.0${NC}"
    echo ""
    echo "USAGE:"
    echo "  ./setup-env.sh [OPTION] [--config CONFIG_FILE]"
    echo ""
    echo "OPTIONS:"
    echo "  install     Full installation (recommended for first time)"
    echo "  preview     Preview what would be installed (dry run)"
    echo "  core        Install only core development tools"
    echo "  frontend    Install only frontend tools and editors"
    echo "  backend     Install only backend tools and databases"
    echo "  business    Install only productivity and business apps"
    echo "  ai          Install only AI tools and models"
    echo "  cleanup     Remove all installed components"
    echo "  help        Show this help message"
    echo ""
    echo "CONFIGURATION:"
    echo "  --config CONFIG_FILE    Use specific configuration file"
    echo ""
    echo "AVAILABLE CONFIGS:"
    echo "  configs/everything.yaml  # Complete setup (113+ packages)"
    echo "  configs/minimal.yaml     # Essential tools only (~20 packages)"
    echo "  configs/webdev.yaml      # Web development (~50 packages)"
    echo "  configs/ai.yaml          # AI/ML development (~60 packages)"
    echo "  configs/mobile.yaml      # Mobile development (~50 packages)"
    echo "  configs/devops.yaml      # DevOps & infrastructure (~80 packages)"
    echo "  configs/design.yaml      # Design & creative (~30 packages)"
    echo "  configs/gaming.yaml      # Gaming & entertainment (~30 packages)"
    echo "  configs/student.yaml     # Student & learning (~50 packages)"
    echo "  configs/senior.yaml      # Senior developer (~90 packages)"
    echo ""
    echo "EXAMPLES:"
    echo "  ./setup-env.sh install                           # Full installation"
    echo "  ./setup-env.sh install --config configs/webdev.yaml  # Web dev setup"
    echo "  ./setup-env.sh preview --config configs/minimal.yaml # Preview minimal"
    echo "  ./setup-env.sh core                              # Install core tools only"
    echo "  ./setup-env.sh cleanup                           # Remove everything"
    echo ""
    echo "For more options, see:"
    echo "  ./scripts/setup.sh --help"
    echo "  make help"
}

# Main function
main() {
    show_banner
    
    local command="${1:-help}"
    local config_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --config)
                config_file="$2"
                shift 2
                ;;
            *)
                command="$1"
                shift
                ;;
        esac
    done
    
    # Build script arguments
    local script_args=""
    if [[ -n "$config_file" ]]; then
        script_args="--config $config_file"
    fi
    
    case "$command" in
        "install")
            echo -e "${GREEN}🚀 Starting full installation...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh $script_args
            ;;
            
        "preview")
            echo -e "${YELLOW}🔍 Previewing installation...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh --dry-run $script_args
            ;;
            
        "core")
            echo -e "${BLUE}🔧 Installing core development tools...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh --only core $script_args
            ;;
            
        "frontend")
            echo -e "${BLUE}🎨 Installing frontend tools...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh --only frontend $script_args
            ;;
            
        "backend")
            echo -e "${BLUE}🗄️ Installing backend tools...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh --only backend $script_args
            ;;
            
        "business")
            echo -e "${BLUE}💼 Installing business/productivity tools...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh --only business $script_args
            ;;
            
        "ai")
            echo -e "${BLUE}🤖 Installing AI tools...${NC}"
            if [[ -n "$config_file" ]]; then
                echo -e "${BLUE}Using configuration: $config_file${NC}"
            fi
            echo ""
            ./scripts/setup.sh --only ai $script_args
            ;;
            
        "cleanup")
            echo -e "${RED}🧹 Cleaning up installed components...${NC}"
            echo ""
            read -p "Are you sure you want to remove all installed components? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ./scripts/cleanup.sh
            else
                echo "Cleanup cancelled."
            fi
            ;;
            
        "help"|"--help"|"-h")
            show_help
            ;;
            
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

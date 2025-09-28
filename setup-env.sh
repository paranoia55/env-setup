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
    echo "║           🚀 Environment Setup v4.0 🚀                      ║"
    echo "║                                                              ║"
    echo "║    Comprehensive development environment for macOS          ║"
    echo "║    with AI tools, databases, and productivity apps          ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Show help
show_help() {
    echo -e "${BLUE}Environment Setup v4.0${NC}"
    echo ""
    echo "USAGE:"
    echo "  ./setup-env.sh [OPTION]"
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
    echo "EXAMPLES:"
    echo "  ./setup-env.sh install     # Full installation"
    echo "  ./setup-env.sh preview     # See what would be installed"
    echo "  ./setup-env.sh core        # Install core tools only"
    echo "  ./setup-env.sh cleanup     # Remove everything"
    echo ""
    echo "For more options, see:"
    echo "  ./scripts/setup.sh --help"
    echo "  make help"
}

# Main function
main() {
    show_banner
    
    local command="${1:-help}"
    
    case "$command" in
        "install")
            echo -e "${GREEN}🚀 Starting full installation...${NC}"
            echo ""
            ./scripts/setup.sh
            ;;
            
        "preview")
            echo -e "${YELLOW}🔍 Previewing installation...${NC}"
            echo ""
            ./scripts/setup.sh --dry-run
            ;;
            
        "core")
            echo -e "${BLUE}🔧 Installing core development tools...${NC}"
            echo ""
            ./scripts/setup.sh --only core
            ;;
            
        "frontend")
            echo -e "${BLUE}🎨 Installing frontend tools...${NC}"
            echo ""
            ./scripts/setup.sh --only frontend
            ;;
            
        "backend")
            echo -e "${BLUE}🗄️ Installing backend tools...${NC}"
            echo ""
            ./scripts/setup.sh --only backend
            ;;
            
        "business")
            echo -e "${BLUE}💼 Installing business/productivity tools...${NC}"
            echo ""
            ./scripts/setup.sh --only business
            ;;
            
        "ai")
            echo -e "${BLUE}🤖 Installing AI tools...${NC}"
            echo ""
            ./scripts/setup.sh --only ai
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

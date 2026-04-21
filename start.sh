#!/bin/bash

# NexusForever Linux Installer - Dual-Mode Entry Point
# Mode 1: Root user - Setup service user and create command
# Mode 2: Service user - Run normal installer

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Colors for output (defined locally since needed before config loading)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

print_error() { echo -e "${RED}ERROR: $1${NC}"; }
print_status() { echo -e "${GREEN}STATUS: $1${NC}"; }
print_warning() { echo -e "${YELLOW}WARNING: $1${NC}"; }
print_header() { echo -e "${BLUE}=== $1 ===${NC}"; }

# Function to show directory missing error
show_directory_error() {
    local dir_name="$1"
    local dir_path="${SCRIPT_DIR}/${dir_name}"
    
    echo -e "${RED}ERROR: ${dir_name} directory not found: ${dir_path}${NC}"
    echo ""
    echo -e "${RED}ERROR: This usually means:${NC}"
    echo "  • The installer files were not downloaded completely"
    echo "  • You're running the script from the wrong location"
    echo "  • The files were extracted incorrectly"
    echo ""
    echo -e "${GREEN}STATUS: Please ensure you have all the required files:${NC}"
    echo -e "${GREEN}STATUS:   • scripts/ directory with all installation scripts${NC}"
    echo -e "${GREEN}STATUS:   • configs/ directory with configuration files${NC}"
    echo -e "${GREEN}STATUS:   • wrappers/ directory with service executables${NC}"
    echo ""
    echo -e "${GREEN}STATUS: Current location: ${SCRIPT_DIR}${NC}"
    echo -e "${GREEN}STATUS: Make sure you're running ./start.sh from the installer directory${NC}"
    exit 1
}

start_load_files() {
    # Check if essential directories exist
    [[ ! -d "${SCRIPT_DIR}/scripts" ]] && show_directory_error "scripts"
    [[ ! -d "${SCRIPT_DIR}/configs" ]] && show_directory_error "configs"
    [[ ! -d "${SCRIPT_DIR}/wrappers" ]] && show_directory_error "wrappers"
    
    # Load all scripts recursively (excluding wrappers)
    if [[ -d "${SCRIPT_DIR}/scripts" ]]; then
        while IFS= read -r -d '' file; do
            if ! source "$file" 2>/dev/null; then
                print_error "Failed to load script: $file"
                exit 1
            fi
        done < <(find "${SCRIPT_DIR}/scripts" -name "*.sh" -print0 2>/dev/null)
    else
        show_directory_error "scripts"
    fi

    # Load all configs in specific order to ensure dependencies are met
    local load_config_files=(
        "${SCRIPT_DIR}/configs/services.conf"
        "${SCRIPT_DIR}/configs/general.conf"
        "${SCRIPT_DIR}/configs/patcher.conf"
        "${SCRIPT_DIR}/configs/world.conf"
        "${SCRIPT_DIR}/configs/git.conf"
        "${SCRIPT_DIR}/configs/database.conf"
        "${SCRIPT_DIR}/configs/broker.conf"
        "${SCRIPT_DIR}/configs/network.conf"
        "${SCRIPT_DIR}/configs/misc.conf"
    )
    
    for config_file in "${load_config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            if ! source "$config_file" 2>/dev/null; then
                print_error "Failed to load config: $config_file"
                exit 1
            fi
        fi
    done
}

# Main entry point
start_load_script() {
    # Check if user is the service user first (highest priority)
    if [[ "$(whoami)" == "$SERVICE_USER" ]]; then
        # Randomize passwords on first run as service user
        util_randomize_config_passwords
        
        # MODE 1: Service user - Run normal installer
        # Check if CLI parameters are provided first
        if [[ $# -gt 0 ]]; then
            # CLI mode - pass to cli_start function
            cli_start "$@"
        else
            # Menu mode - only for service user
            main_menu
        fi
    # Check if user has sudo/root privileges
    elif [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
        # MODE 2: User with sudo access - Setup service user
        print_header "NexusForever Installer"
        echo ""
        
        # Check for unattended mode flag
        if [[ "$1" == "unattended" ]]; then
            echo "🔧 Unattended Setup Mode Detected"
            echo "   User: $(whoami) (has sudo privileges)"
            echo "   Action: Create '$SERVICE_USER' user and install 'nexusforever' command"
            echo ""
            echo "This will:"
            echo "  ✓ Create the '$SERVICE_USER' service user"
            echo "  ✓ Create the 'nexusforever' command for easy access"
            echo "  ✓ Set up proper file permissions"
            echo ""
            print_status "Starting unattended setup..."
            install_service_user
            install_manager
            
            print_header "Setup Complete"
            echo -e "${GREEN}✓ You can now run ${NC}'${WHITE}nexusforever${NC}'${GREEN} as the $SERVICE_USER user to access the CLI${NC}"
            echo ""
            exit 0
        else
            echo "🔧 Setup Mode Detected"
            echo "   User: $(whoami) (has sudo privileges)"
            echo "   Action: Create '$SERVICE_USER' user and install 'nexusforever' command"
            echo ""
            echo "This will:"
            echo "  ✓ Create '$SERVICE_USER' service user"
            echo "  ✓ Create 'nexusforever' command for easy access"
            echo "  ✓ Set up proper file permissions"
            echo ""
            read -p "Continue with setup? [Y/n]: " choice
            
            if [[ ! "$choice" =~ ^[Yy]$ ]]; then
                print_status "Setup cancelled"
                exit 0
            fi
            
            print_status "Starting setup..."
            install_service_user
            install_manager
            
            print_header "Setup Complete"
            echo -e "${GREEN}✓ You can now run ${NC}'${WHITE}nexusforever${NC}'${GREEN} as the $SERVICE_USER user to access the CLI${NC}"
            echo ""
        fi
        echo -e "${BLUE}✓ To access the commands as the $SERVICE_USER user: ${NC}"
        echo -e "       ${BLUE}${WHITE}sudo su nexusforever${NC}"
        echo ""
    else
        # MODE 3: No permissions - Show error
        print_header "NexusForever Installer - Access Error"
        echo ""
        echo "❌ Insufficient permissions detected"
        echo ""
        echo "Current user: $(whoami)"
        echo "Required user: $SERVICE_USER (or any user with sudo)"
        echo ""
        echo "To fix this, run one of these commands:"
        echo ""
        echo "  🚀 First-time setup:"
        echo "     sudo ./start.sh"
        echo ""
        echo "  🎮 Normal usage (after setup):"
        echo "     nexusforever"
        echo ""
        print_header "CLI Commands"
        echo "  nexusforever install <component>    Install components"
        echo "  nexusforever config <action>      Manage configuration"
        echo "  nexusforever update <component>    Update components"
        echo ""
        echo "Examples:"
        echo "  nexusforever install all"
        echo "  nexusforever config show"
        echo ""
        exit 1
    fi
}

start_load_files;
start_load_script "$@";

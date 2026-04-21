#!/bin/bash

# NexusForever Linux Installer - Service User Setup Function

# Setup service user
install_service_user() {
    echo ""
    print_header "Setting Up Service User"
    
    # Check if running on Debian/Ubuntu
    if [[ ! -f /etc/debian_version ]] && [[ ! -f /etc/lsb-release ]]; then
        print_error "This installer is designed for Debian/Ubuntu systems only"
        exit 1
    fi
    
    echo "Detected Debian/Ubuntu system"
    echo ""
    
    # Check if service user exists
    check_service_user() {
        id "$SERVICE_USER" &>/dev/null
    }

    # Create service user if doesn't exist
    if ! check_service_user; then
        print_status "Creating service user '$SERVICE_USER'..."
        useradd -m -s /bin/bash "$SERVICE_USER"
        
        if [[ $? -eq 0 ]]; then
            print_status "Service user '$SERVICE_USER' created successfully"
        else
            print_error "Failed to create service user '$SERVICE_USER'"
            exit 1
        fi
    else
        print_status "Service user '$SERVICE_USER' already exists"
    fi
    
    # Set up password-less sudo for service user
    echo ""
    print_status "Setting up sudo permissions for service user..."
    
    # Check if sudoers file already exists and has correct content
    local sudoers_file="/etc/sudoers.d/nexusforever"
    local sudoers_content="$SERVICE_USER ALL=(ALL) NOPASSWD: ALL"
    
    if [[ -f "$sudoers_file" ]] && grep -q "$sudoers_content" "$sudoers_file"; then
        print_status "Sudo permissions already configured"
    else
        echo "$sudoers_content" | tee "$sudoers_file" >/dev/null
        chmod 0440 "$sudoers_file"
        print_status "Sudo permissions configured"
    fi
    
    # Create nexusforever command
    echo ""
    print_status "Creating 'nexusforever' command..."
    
    local nexusforever_cmd="/usr/local/bin/nexusforever"
    local expected_content=$(cat << 'EOF'
#!/bin/bash
# NexusForever CLI Command
# Routes to the integrated CLI system

# Check if running as the correct service user
if [[ "$(whoami)" != "SERVICE_USER_PLACEHOLDER" ]]; then
    echo ""
    echo "ERROR: This command must be run as the 'SERVICE_USER_PLACEHOLDER' user"
    if [[ "$(whoami)" == "root" ]]; then
        echo "Run the following command: su SERVICE_USER_PLACEHOLDER && nexusforever"
    else
        echo "Run the following command: sudo su SERVICE_USER_PLACEHOLDER && nexusforever"
    fi
    echo ""
    exit 1
fi

# Find the installer directory (using MANAGER_DIR from config)
INSTALLER_DIR="MANAGER_DIR_PLACEHOLDER"

# Check if installer exists
if [[ ! -d "$INSTALLER_DIR" ]]; then
    echo "ERROR: NexusForever installer not found at $INSTALLER_DIR"
    echo "Please run the service user setup first."
    exit 1
fi

# Change to installer directory and run start.sh with all arguments
cd "$INSTALLER_DIR" || {
    echo "ERROR: Cannot change to installer directory: $INSTALLER_DIR"
    exit 1
}
exec ./start.sh "$@"
EOF
)
    
    # Replace placeholders with actual values
    expected_content="${expected_content//SERVICE_USER_PLACEHOLDER/$SERVICE_USER}"
    expected_content="${expected_content//MANAGER_DIR_PLACEHOLDER/$MANAGER_DIR}"
    
    if [[ -f "$nexusforever_cmd" ]]; then
        # Check if content is the same
        if diff <(echo "$expected_content") "$nexusforever_cmd" >/dev/null 2>&1; then
            print_status "'nexusforever' command already exists and is up to date"
        else
            print_status "Updating 'nexusforever' command..."
            echo "$expected_content" > "$nexusforever_cmd"
            chmod +x "$nexusforever_cmd"
            print_status "'nexusforever' command updated"
        fi
    else
        print_status "Creating 'nexusforever' command..."
        echo "$expected_content" > "$nexusforever_cmd"
        chmod +x "$nexusforever_cmd"
        print_status "'nexusforever' command created"
    fi
    
    print_status "Service user setup completed successfully"
}

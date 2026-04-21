#!/bin/bash

# NexusForever Linux Installer - Manager Setup Function

# Copy installer files to manager directory
install_manager() {
    echo ""
    print_header "Setting Up Manager Directory"
    
    # Validate essential directories exist
    local missing_dirs=()
    
    if [[ ! -d "$SCRIPT_DIR/configs" ]]; then
        missing_dirs+=("configs")
    fi
    
    if [[ ! -d "$SCRIPT_DIR/scripts" ]]; then
        missing_dirs+=("scripts")
    fi
    
    if [[ ! -d "$SCRIPT_DIR/wrappers" ]]; then
        missing_dirs+=("wrappers")
    fi
    
    # Stop if essential directories are missing
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        print_error "Essential directories missing: ${missing_dirs[*]}"
        print_error "Cannot proceed with manager setup"
        return 1
    fi
    
    # Create manager directory if it doesn't exist
    mkdir -p "$MANAGER_DIR"
    
    # Copy all files except configs and wrappers first
    print_status "Copying files to manager directory..."
    find "$SCRIPT_DIR" -maxdepth 1 -not -name "configs" -not -name "wrappers" -not -name "." -exec cp -r {} "$MANAGER_DIR/" \;
    
    # Handle configs directory - copy but don't overwrite existing files
    mkdir -p "$MANAGER_DIR/configs"
    print_status "Copying config files (preserving existing)..."
    find "$SCRIPT_DIR/configs" -type f -exec cp --update=none {} "$MANAGER_DIR/configs/" \;
    
    # Copy scripts directory (overwrite these)
    cp -rf "$SCRIPT_DIR/scripts" "$MANAGER_DIR/"
    
    # Copy wrappers directory (these are executables)
    cp -rf "$SCRIPT_DIR/wrappers" "$MANAGER_DIR/"
    
    # Set proper ownership
    chown -R "$SERVICE_USER:$SERVICE_USER" "$MANAGER_DIR"
    
    print_status "Manager directory setup completed!"
    echo ""
    print_status "Manager location: $MANAGER_DIR"
    print_status "Files copied from: $SCRIPT_DIR"
    print_status "Config files preserved if they existed"
    echo ""
}

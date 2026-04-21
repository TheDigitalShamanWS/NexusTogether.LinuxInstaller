#!/bin/bash

# NexusForever Linux Installer - Backup Utility Function

# Backup configuration
backup_configuration() {
    print_header "Backup Configuration"
    
    local backup_dir="${BACKUP_DIR}/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    if [[ -d "$SERVER_DIR/Source" ]]; then
        print_status "Backing up configuration files..."
        cp -r "$SERVER_DIR/Source" "$backup_dir/"
        print_status "Configuration backed up to: $backup_dir"
    else
        print_error "NexusForever directory not found"
        return 1
    fi
    
    return 0
}

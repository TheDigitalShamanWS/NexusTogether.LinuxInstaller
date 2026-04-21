#!/bin/bash

# NexusForever Linux Installer - Directory Utility Function

# Create directory with proper permissions
create_directory() {
    local dir="$1"
    local owner="${2:-$USER}"
    
    if [[ ! -d "$dir" ]]; then
        sudo mkdir -p "$dir"
        sudo chown "$owner:$owner" "$dir"
        print_status "Created directory: $dir"
    fi
}

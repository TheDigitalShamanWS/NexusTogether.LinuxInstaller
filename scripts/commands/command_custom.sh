#!/bin/bash

# NexusForever Linux Installer - Custom Command Function

# Custom command input
command_custom() {
    local service_key="$1"
    echo ""
    read -p "Enter custom command: " custom_command
    
    if [[ -n "$custom_command" ]]; then
        manage_send_command "$service_key" "$custom_command"
    else
        print_error "No command entered"
    fi
}

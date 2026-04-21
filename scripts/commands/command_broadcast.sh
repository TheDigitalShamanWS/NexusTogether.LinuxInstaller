#!/bin/bash

# NexusForever Linux Installer - Broadcast Command Function

# Broadcast message command
command_broadcast() {
    local service_key="$1"
    echo ""
    read -p "Enter broadcast message: " message
    
    if [[ -n "$message" ]]; then
        manage_send_command "$service_key" "broadcast '$message'"
    else
        print_error "No message entered"
    fi
}

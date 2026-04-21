#!/bin/bash

# NexusForever Linux Installer - Unban Command Function

# Unban player command
command_unban() {
    local service_key="$1"
    echo ""
    read -p "Enter player name to unban: " player_name
    
    if [[ -n "$player_name" ]]; then
        manage_send_command "$service_key" "unban '$player_name'"
    else
        print_error "No player name entered"
    fi
}

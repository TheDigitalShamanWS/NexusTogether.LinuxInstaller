#!/bin/bash

# NexusForever Linux Installer - Kick Command Function

# Kick player command
command_kick() {
    local service_key="$1"
    echo ""
    read -p "Enter player name to kick: " player_name
    
    if [[ -n "$player_name" ]]; then
        manage_send_command "$service_key" "kick '$player_name'"
    else
        print_error "No player name entered"
    fi
}

#!/bin/bash

# NexusForever Linux Installer - Ban Command Function

# Ban player command
command_ban() {
    local service_key="$1"
    echo ""
    read -p "Enter player name to ban: " player_name
    read -p "Enter ban reason (optional): " reason
    
    if [[ -n "$player_name" ]]; then
        if [[ -n "$reason" ]]; then
            manage_send_command "$service_key" "ban '$player_name' '$reason'"
        else
            manage_send_command "$service_key" "ban '$player_name'"
        fi
    else
        print_error "No player name entered"
    fi
}

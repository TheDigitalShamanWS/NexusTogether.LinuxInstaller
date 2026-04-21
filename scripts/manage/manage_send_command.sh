#!/bin/bash

# NexusForever Linux Installer - Send Command to Service

# Send command to service screen session
manage_send_command() {
    local service_choice="$1"
    local command="$2"
    
    if [[ "$SERVICE_MODE" != "screen" ]]; then
        print_error "Screen mode not enabled. Set SERVICE_MODE='screen' in services.conf"
        return
    fi
    
    if [[ -z "$command" ]]; then
        # Show help if no command provided
        manage_show_service_help "$service_choice"
        return
    fi
    
    # Find the service
    for service_def in "${NEXUS_SERVICES[@]}"; do
        IFS=':' read -r service_key service_name display_name <<< "$service_def"
        if [[ "$service_key" == "$service_choice" ]]; then
            if screen -list | grep -q "nexus_$service_key"; then
                # Send command to screen session
                screen -S "nexus_$service_key" -p 0 -X stuff "$command^M"
                print_status "Command '$command' sent to $display_name"
            else
                print_error "$display_name screen session not found"
            fi
            return
        fi
    done
    print_error "Unknown service: $service_choice"
}

# Show available commands for specific service
manage_show_service_help() {
    local service_key="$1"
    
    case "$service_key" in
        "world")
            print_header "World Server Commands"
            echo ""
            echo "Available commands for World Server:"
            echo ""
            echo "1. help                    - Show this help message"
            echo "2. status                 - Show server status and information"
            echo "3. players                - List all connected players"
            echo "4. save                   - Save world state"
            echo "5. shutdown                - Gracefully shutdown the server"
            echo "6. restart                - Restart the server"
            echo "7. broadcast <message>     - Send message to all players"
            echo "8. kick <player>          - Kick a player from server"
            echo "9. ban <player> [reason]  - Ban a player from server"
            echo "10. unban <player>         - Unban a player from server"
            echo ""
            echo "Usage: manage_send_command world <command> [arguments]"
            echo "Example: manage_send_command world players"
            echo "Example: manage_send_command world broadcast 'Server restart in 5 minutes'"
            echo "Example: manage_send_command world kick 'PlayerName'"
            echo ""
            echo "For full documentation: $COMMAND_DOCS_URL"
            ;;
        *)
            print_status "Help available for world server. Use 'manage_send_command world help' for command list."
            print_status "For full documentation: $COMMAND_DOCS_URL"
            ;;
    esac
}

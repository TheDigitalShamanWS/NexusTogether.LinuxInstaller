#!/bin/bash

# NexusForever Linux Installer - Command Menu System

# Interactive command menu for services
manage_command_menu() {
    if [[ "$SERVICE_MODE" != "screen" ]]; then
        print_error "Screen mode not enabled. Set SERVICE_MODE='screen' in services.conf"
        return
    fi
    
    while true; do
        clear
        print_header "Service Command Menu"
        echo ""
        
        # List available services
        echo "Select a service to send commands to:"
        local index=1
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            echo "$index. $display_name"
            ((index++))
        done
        
        echo ""
        echo "$index. Back to Management Menu"
        echo ""
        echo "q. Quit"
        echo ""
        read -p "Enter your choice [1-$index, q]: " choice
        
        if [[ "$choice" == "q" ]]; then
            break
        elif [[ "$choice" == "$index" ]]; then
            break
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -lt "$index" ]]; then
            local service_index=$((choice - 1))
            local service_def="${NEXUS_SERVICES[$service_index]}"
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            command_service_menu "$service_key" "$display_name"
        else
            print_error "Invalid choice"
            read -p "Press Enter to continue..."
        fi
    done
}

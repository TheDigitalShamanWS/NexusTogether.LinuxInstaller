#!/bin/bash

# NexusForever Linux Installer - Attach to Service Screen

# Attach to service screen session
manage_attach_service() {
    local service_choice="$1"
    
    if [[ "$SERVICE_MODE" != "screen" ]]; then
        print_error "Screen mode not enabled. Set SERVICE_MODE='screen' in services.conf"
        return
    fi
    
    # Find the service
    for service_def in "${NEXUS_SERVICES[@]}"; do
        IFS=':' read -r service_key service_name display_name <<< "$service_def"
        if [[ "$service_key" == "$service_choice" ]]; then
            if screen -list | grep -q "nexus_$service_key"; then
                print_status "Attaching to $display_name screen session..."
                print_status "Use Ctrl+A, D to detach without stopping"
                sleep 2
                screen -r "nexus_$service_key"
            else
                print_error "$display_name screen session not found"
                print_status "Start the service first with manage_start_service"
            fi
            return
        fi
    done
    print_error "Unknown service: $service_choice"
}

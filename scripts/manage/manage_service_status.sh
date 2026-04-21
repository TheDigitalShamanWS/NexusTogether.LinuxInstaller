#!/bin/bash

# NexusForever Linux Installer - Service Status Function

# Check status of all services
manage_service_status() {
    print_header "NexusForever Service Status"
    echo "Mode: $SERVICE_MODE"
    echo ""
    
    local running_count=0
    local total_count=${#NEXUS_SERVICES[@]}
    
    for service_def in "${NEXUS_SERVICES[@]}"; do
        IFS=':' read -r service_key service_name display_name <<< "$service_def"
        if [[ "$SERVICE_MODE" == "screen" ]]; then
            # Check screen session status
            if screen -list | grep -q "nexus-$service_key"; then
                echo "✅ $display_name - SCREEN RUNNING"
                ((running_count++))
            else
                echo "❌ $display_name - SCREEN STOPPED"
            fi
        else
            # Direct mode (original)
            if pgrep -f "$service_name" > /dev/null; then
                echo "✅ $display_name - RUNNING"
                ((running_count++))
            else
                echo "❌ $display_name - STOPPED"
            fi
        fi
    done
    
    echo ""
    print_status "$running_count/$total_count services running"
}

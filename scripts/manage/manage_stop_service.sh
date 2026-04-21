#!/bin/bash

# NexusForever Linux Installer - Stop Service Function

# Stop specific service or all services
manage_stop_service() {
    local service_choice="$1"
    
    print_header "Stopping NexusForever Services"
    
    if [[ "$service_choice" == "all" ]]; then
        local stopped_count=0
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            if [[ "$SERVICE_MODE" == "screen" ]]; then
                # Stop screen session
                if screen -list | grep -q "nexus_$service_key"; then
                    screen -S "nexus_$service_key" -p 0 -X stuff "^C"  # Send Ctrl+C
                    sleep 2
                    screen -S "nexus_$service_key" -p 0 -X stuff "exit^M"  # Send exit
                    sleep 1
                    screen -S "nexus_$service_key" -X quit  # Force quit screen
                    print_status "$display_name screen session stopped"
                    ((stopped_count++))
                else
                    print_warning "$display_name screen session not found"
                fi
            else
                # Direct mode (original)
                if pgrep -f "$service_name" > /dev/null; then
                    pkill -f "$service_name"
                    print_status "$display_name stopped"
                    ((stopped_count++))
                else
                    print_warning "$display_name is not running"
                fi
            fi
        done
        print_status "Stopped $stopped_count services"
    else
        # Stop specific service
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            if [[ "$service_key" == "$service_choice" ]]; then
                if [[ "$SERVICE_MODE" == "screen" ]]; then
                    if screen -list | grep -q "nexus_$service_key"; then
                        screen -S "nexus_$service_key" -p 0 -X stuff "^C"
                        sleep 2
                        screen -S "nexus_$service_key" -p 0 -X stuff "exit^M"
                        sleep 1
                        screen -S "nexus_$service_key" -X quit
                        print_status "$display_name screen session stopped"
                    else
                        print_warning "$display_name screen session not found"
                    fi
                else
                    if pgrep -f "$service_name" > /dev/null; then
                        pkill -f "$service_name"
                        print_status "$display_name stopped"
                    else
                        print_warning "$display_name is not running"
                    fi
                fi
                return
            fi
        done
        print_error "Unknown service: $service_choice"
    fi
}

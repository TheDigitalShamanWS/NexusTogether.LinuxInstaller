#!/bin/bash

# NexusForever Linux Installer - Start Service Function

# Start specific service or all services
manage_start_service() {
    local service_choice="$1"
    
    print_header "Starting NexusForever Services"
    
    if [[ "$service_choice" == "all" ]]; then
        local started_count=0
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            if [[ "$SERVICE_MODE" == "screen" ]]; then
                # Start service in screen session (same as crontab)
                local service_script="$SERVICES_DIR/nexus-${service_key}.sh"
                
                if [[ ! -f "$service_script" ]]; then
                    print_error "Service script not found: $service_script"
                    continue
                fi
                
                # Check if service is already running
                if screen -list | grep -q "nexus-$service_key"; then
                    print_warning "$display_name is already running"
                else
                    # Start the service script in screen session (same as crontab)
                    print_status "Starting $display_name..."
                    screen -dmS "nexus-$service_key" "$service_script"
                    
                    # Check if service started successfully
                    sleep 2
                    if screen -list | grep -q "nexus-$service_key"; then
                        print_status "$display_name started successfully"
                        ((started_count++))
                    else
                        print_error "Failed to start $display_name"
                    fi
                fi
            else
                # Direct mode (original)
                cd "$SERVER_DIR/Source"
                export TERM=vt100
                if ! pgrep -f "$service_name" > /dev/null; then
                    cd "$service_name"
                    sudo -u "$SERVICE_USER" bash -c "export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && dotnet run" &
                    cd ..
                    print_status "$display_name started"
                    ((started_count++))
                else
                    print_warning "$display_name is already running"
                fi
            fi
        done
        print_status "Started $started_count services"
    else
        # Start specific service
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            if [[ "$service_key" == "$service_choice" ]]; then
                if [[ "$SERVICE_MODE" == "screen" ]]; then
                    local service_script="$SERVICES_DIR/nexus-${service_key}.sh"
                    
                    if [[ ! -f "$service_script" ]]; then
                        print_error "Service script not found: $service_script"
                        return
                    fi
                    
                    # Check if service is already running
                    if screen -list | grep -q "nexus-$service_key"; then
                        print_warning "$display_name is already running"
                    else
                        # Start the service script in screen session (same as crontab)
                        print_status "Starting $display_name..."
                        screen -dmS "nexus-$service_key" "$service_script"
                        
                        # Check if service started successfully
                        sleep 2
                        if screen -list | grep -q "nexus-$service_key"; then
                            print_status "$display_name started successfully"
                        else
                            print_error "Failed to start $display_name"
                        fi
                    fi
                else
                    cd "$SERVER_DIR/Source"
                    export TERM=vt100
                    if ! pgrep -f "$service_name" > /dev/null; then
                        cd "$service_name"
                        sudo -u "$SERVICE_USER" bash -c "export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && dotnet run" &
                        cd ..
                        print_status "$display_name started"
                    else
                        print_warning "$display_name is already running"
                    fi
                fi
                return
            fi
        done
        print_error "Unknown service: $service_choice"
    fi
}

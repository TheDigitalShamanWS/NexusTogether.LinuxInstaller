#!/bin/bash

# NexusForever Linux Installer - Services Setup Function

# Install services (supports both systemd and screen modes) - IDEMPOTENT
install_services() {
    print_header "Setup NexusForever Services"
    
    print_status "Service mode: $SERVICE_MODE"
    echo ""

    ######################################
    # SYSTEMD MODE
    ######################################
    if [[ "$SERVICE_MODE" == "systemd" ]]; then
        print_status "Setting up systemd services..."
        
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            
            local service_file="/etc/systemd/system/${SERVICE_PREFIX}.${service_key}.service"
            
            # Check if service file already exists
            if [[ -f "$service_file" ]]; then
                print_status "Updating existing ${service_file}..."
                
                # Backup existing service file
                local backup_file="${service_file}.backup.$(date +%Y%m%d_%H%M%S)"
                sudo cp "$service_file" "$backup_file"
                print_status "Backed up existing service file to ${backup_file}"
            else
                print_status "Creating new ${service_file}..."
            fi
            
            # Determine service path and working directory
            local service_working_dir="$SERVER_DIR"
            local service_exec_cmd="/usr/bin/dotnet ${service_name}.dll"
            
            # Special handling for patcher service
            if [[ "$service_key" == "patcher" ]]; then
                service_working_dir="$PATCHER_DIR/Source/Nexus.Patch.Server/bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
                service_exec_cmd="/usr/bin/dotnet ${service_name}.dll"
            fi
            
            # Create/update service file
            sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=NexusForever ${display_name}
After=network.target

[Service]
Type=simple
User=${SERVICE_USER}
Group=${SERVICE_USER}
WorkingDirectory=${service_working_dir}
ExecStart=${service_exec_cmd}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
            
            if [[ $? -eq 0 ]]; then
                print_status "Successfully updated ${service_file}"
            else
                print_error "Failed to create/update ${service_file}"
                return 1
            fi
        done
        
        print_status "Reloading systemd daemon..."
        sudo systemctl daemon-reload
        
        # Check if services need to be restarted due to changes
        print_status "Checking for running services that may need restart..."
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            
            if systemctl is-active --quiet "${SERVICE_PREFIX}.${service_key}"; then
                print_status "Service ${display_name} is running - consider restarting to apply changes"
                print_status "  Run: sudo systemctl restart ${SERVICE_PREFIX}.${service_key}"
            fi
        done
        
        print_status "Systemd services setup completed successfully"
    
    ######################################
    # SCREEN MODE
    ######################################
    elif [[ "$SERVICE_MODE" == "screen" ]]; then
        print_status "Setting up screen services environment..."
        
        # Clean up existing services first (idempotent behavior)
        print_status "Cleaning up existing services..."
        
        # Stop all running screen sessions
        local stopped_count=0
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            if screen -list | grep -q "nexus-$service_key"; then
                screen -S "nexus-$service_key" -X quit
                ((stopped_count++))
            fi
        done
        
        if [[ $stopped_count -gt 0 ]]; then
            print_status "Stopped $stopped_count running services"
        else
            print_status "No running services to stop"
        fi
        
        # Clear existing crontab entries for nexusforever services
        print_status "Clearing existing crontab entries..."
        local current_crontab=$(crontab -l 2>/dev/null || echo "")
        local cleaned_crontab=""
        
        # Remove any existing nexusforever service entries
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            current_crontab=$(echo "$current_crontab" | grep -v "@reboot screen -dmS nexus-$service_key $SERVICES_DIR/nexus-${service_key}.sh")
        done
        
        # Update crontab with cleaned version
        echo "$current_crontab" | crontab -
        print_status "Cleared existing crontab entries"
        
        # Create services directory
        if [[ -d "$SERVICES_DIR" ]]; then
            print_status "Services directory already exists: $SERVICES_DIR"
            print_status "Ensuring proper ownership..."
            sudo chown -R ${SERVICE_USER}:${SERVICE_USER} "$SERVICES_DIR"
        else
            print_status "Creating services directory: $SERVICES_DIR"
            sudo mkdir -p "$SERVICES_DIR"
            sudo chown ${SERVICE_USER}:${SERVICE_USER} "$SERVICES_DIR"
        fi
        
        # Create individual service scripts from wrapper template
        print_status "Creating individual service scripts..."
        
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            
            local service_script="$SERVICES_DIR/nexus-${service_key}.sh"
            local service_path="$SERVER_DIR/Source/$service_name/bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
            
            # Special handling for patcher service
            if [[ "$service_key" == "patcher" ]]; then
                service_path="$PATCHER_DIR/Source/Nexus.Patch.Server/bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
            fi
            
            # Copy wrapper script to services directory with service name
            cp "${MANAGER_DIR}/wrappers/wrapper_service.sh" "$service_script"
            
            # Update the wrapper script to use correct service path and screen name
            sed -i "s|SERVICE_NAME=\"\\\$1\"|SERVICE_NAME=\"$service_key\"|g" "$service_script"
            sed -i "s|SERVICE_PATH=\"\\\$2\"|SERVICE_PATH=\"$service_path\"|g" "$service_script"
            sed -i "s|SERVICE_PROJECT_NAME=\"\\\$3\"|SERVICE_PROJECT_NAME=\"$service_name\"|g" "$service_script"
            
            # Update screen session name in wrapper
            sed -i "s|nexus_\\\$SERVICE_NAME|nexus-$service_key|g" "$service_script"
            
            # Update service work directory path (use main services directory)
            sed -i "s|SERVICE_WORK_DIR=\"\\\$SERVICES_DIR/\\\$SERVICE_NAME\"|SERVICE_WORK_DIR=\"$SERVICES_DIR\"|g" "$service_script"
            sed -i "s|LOG_FILE=\"\\\$SERVICE_WORK_DIR/service.log\"|LOG_FILE=\"$SERVICES_DIR/nexus-${service_key}.log\"|g" "$service_script"
            
            # Replace ALL remaining variable references with hardcoded values
            sed -i "s|\\\$SERVICES_DIR|$SERVICES_DIR|g" "$service_script"
            sed -i "s|\\\$SERVICE_USER|$SERVICE_USER|g" "$service_script"
            sed -i "s|\\\$SERVICE_NAME|$service_key|g" "$service_script"
            sed -i "s|\\\$SERVICE_PATH|$service_path|g" "$service_script"
            sed -i "s|\\\$SERVICE_WORK_DIR|$SERVICES_DIR|g" "$service_script"
            sed -i "s|\\\$LOG_FILE|$SERVICES_DIR/nexus-${service_key}.log|g" "$service_script"
            
            # Make service script executable
            chmod +x "$service_script"
            chown ${SERVICE_USER}:${SERVICE_USER} "$service_script"
            
            print_status "Created service script: nexus-${service_key}.sh"
        done
        
        print_status "Individual service scripts created successfully"
        
        # Setup crontab entries for auto-startup
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            new_crontab+=$'\n'
            new_crontab+="@reboot screen -dmS nexus-$service_key $SERVICES_DIR/nexus-${service_key}.sh"
        done
        
        # Update crontab
        echo "$new_crontab" | crontab -
        
        # Start services after crontab setup
        print_status "Starting all services..."
        local started_count=0
        
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            local service_script="$SERVICES_DIR/nexus-${service_key}.sh"
            
            if [[ -f "$service_script" ]]; then
                # Check if service is already running
                if screen -list | grep -q "nexus-$service_key"; then
                    print_warning "$display_name is already running"
                    ((started_count++))  # Count already running services
                else
                    # Start the service script in screen session (same as crontab)
                    print_status "Starting $display_name..."
                    screen -dmS "nexus-$service_key" "$service_script"
                    
                    # Check if screen session was created successfully (immediate check)
                    sleep 1
                    if screen -list | grep -q "nexus-$service_key"; then
                        print_status "$display_name screen session created successfully"
                        ((started_count++))
                        print_status "  Note: Application health can be checked with 'nexusforever service status'"
                    else
                        print_error "Failed to create screen session for $display_name"
                        print_error "  Check the service log: $SERVICES_DIR/nexus-${service_key}.log"
                    fi
                fi
            else
                print_error "Service script not found: $service_script"
            fi
        done
        
        print_status "Started $started_count services successfully"
        
        echo ""
        print_status "=== SERVICE SETUP STATUS ==="
        print_status "Service Mode: $SERVICE_MODE"
        print_status "Services Directory: $SERVICES_DIR"
        print_status "Service User: $SERVICE_USER"
        
        # Check for running screen sessions
        local running_services=()
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            
            # Check if service screen session is running
            if screen -list | grep -q "nexus-$service_key"; then
                running_services+=("$display_name")
                print_status "  ✓ $display_name is running"
            else
                print_status "  ○ $display_name is stopped"
            fi
        done
        
        if [[ ${#running_services[@]} -gt 0 ]]; then
            print_status "Active Services: ${#running_services[@]}/${#NEXUS_SERVICES[@]}"
        else
            print_status "Active Services: 0/${#NEXUS_SERVICES[@]}"
        fi
        
        print_status "Use individual service scripts or 'manage' menu to start/stop services"
        print_status "Screen session names: nexus-sts, nexus-auth, nexus-world, nexus-chat, nexus-group, nexus-api, nexus-patcher"
        
    else
        print_error "Unknown service mode: $SERVICE_MODE"
        print_status "Available modes: systemd, screen"
        return 1
    fi
    
    print_status "Services setup completed successfully"
    return 0
}

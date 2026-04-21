#!/bin/bash

# NexusForever Service CLI Commands
# Handles service management commands: start, stop, restart, logs, status

cli_service() {
    local action="$1"
    local service_name="$2"
    
    if [[ -z "$action" ]]; then
        echo "Usage: nexusforever service <action> [service_name]"
        echo ""
        echo "Actions:"
        echo "  start <service>     - Start specific service"
        echo "  stop <service>      - Stop specific service"
        echo "  restart <service>   - Restart specific service"
        echo "  attach <service>    - Attach to running service screen session"
        echo "  logs <service>      - Show service logs"
        echo "  status             - Show all service status"
        echo "  start all          - Start all services"
        echo "  stop all           - Stop all services"
        echo "  restart all        - Restart all services"
        echo ""
        echo "Services: sts, auth, world, chat, group, api, patcher"
        echo ""
        echo "Examples:"
        echo "  nexusforever service start sts"
        echo "  nexusforever service attach api"
        echo "  nexusforever service logs world"
        echo "  nexusforever service status"
        echo "  nexusforever service start all"
        exit 1
    fi
    
    # Check if screen mode is enabled
    if [[ "$SERVICE_MODE" != "screen" ]]; then
        echo "ERROR: Screen mode not enabled. Set SERVICE_MODE='screen' in services.conf"
        exit 1
    fi
    
    case "$action" in
        "start all")
            echo "Starting all services..."
            local started_count=0
            for service_def in "${NEXUS_SERVICES[@]}"; do
                IFS=':' read -r service_key service_name display_name <<< "$service_def"
                if screen -list | grep -q "nexus-$service_key"; then
                    echo "⚠️  $display_name is already running"
                else
                    screen -dmS "nexus-$service_key" "$SERVICES_DIR/nexus-${service_key}.sh"
                    sleep 1
                    if screen -list | grep -q "nexus-$service_key"; then
                        echo "✅ $display_name started successfully"
                        ((started_count++))
                    else
                        echo "❌ Failed to start $display_name"
                    fi
                fi
            done
            echo "Started $started_count services successfully"
            ;;
        "stop all")
            echo "Stopping all services..."
            local stopped_count=0
            for service_def in "${NEXUS_SERVICES[@]}"; do
                IFS=':' read -r service_key service_name display_name <<< "$service_def"
                if screen -list | grep -q "nexus-$service_key"; then
                    screen -S "nexus-$service_key" -X quit
                    echo "✅ $display_name stopped"
                    ((stopped_count++))
                fi
            done
            echo "Stopped $stopped_count services successfully"
            ;;
        "restart all")
            echo "Restarting all services..."
            local restarted_count=0
            for service_def in "${NEXUS_SERVICES[@]}"; do
                IFS=':' read -r service_key service_name display_name <<< "$service_def"
                if screen -list | grep -q "nexus-$service_key"; then
                    screen -S "nexus-$service_key" -X quit
                    sleep 2
                fi
                screen -dmS "nexus-$service_key" "$SERVICES_DIR/nexus-${service_key}.sh"
                sleep 1
                if screen -list | grep -q "nexus-$service_key"; then
                    echo "✅ $display_name restarted successfully"
                    ((restarted_count++))
                else
                    echo "❌ Failed to restart $display_name"
                fi
            done
            echo "Restarted $restarted_count services successfully"
            ;;
        start|stop|restart|attach)
            # Handle case where service_name is "all" (not applicable for attach)
            if [[ "$service_name" == "all" ]]; then
                if [[ "$action" == "attach" ]]; then
                    echo "ERROR: 'attach' command requires a specific service name"
                    echo "Available services: sts, auth, world, chat, group, api, patcher"
                    exit 1
                fi
                
                # Handle bulk operations
                case "$action" in
                    start)
                        echo "Starting all services..."
                        local started_count=0
                        for service_def in "${NEXUS_SERVICES[@]}"; do
                            IFS=':' read -r service_key service_name display_name <<< "$service_def"
                            if screen -list | grep -q "nexus-$service_key"; then
                                echo "⚠️  $display_name is already running"
                            else
                                screen -dmS "nexus-$service_key" "$SERVICES_DIR/nexus-${service_key}.sh"
                                sleep 1
                                if screen -list | grep -q "nexus-$service_key"; then
                                    echo "✅ $display_name started successfully"
                                    ((started_count++))
                                else
                                    echo "❌ Failed to start $display_name"
                                fi
                            fi
                        done
                        echo "Started $started_count services successfully"
                        ;;
                    stop)
                        echo "Stopping all services..."
                        local stopped_count=0
                        for service_def in "${NEXUS_SERVICES[@]}"; do
                            IFS=':' read -r service_key service_name display_name <<< "$service_def"
                            if screen -list | grep -q "nexus-$service_key"; then
                                screen -S "nexus-$service_key" -X quit
                                echo "✅ $display_name stopped"
                                ((stopped_count++))
                            fi
                        done
                        echo "Stopped $stopped_count services successfully"
                        ;;
                    restart)
                        echo "Restarting all services..."
                        local restarted_count=0
                        for service_def in "${NEXUS_SERVICES[@]}"; do
                            IFS=':' read -r service_key service_name display_name <<< "$service_def"
                            if screen -list | grep -q "nexus-$service_key"; then
                                screen -S "nexus-$service_key" -X quit
                                sleep 2
                            fi
                            screen -dmS "nexus-$service_key" "$SERVICES_DIR/nexus-${service_key}.sh"
                            sleep 1
                            if screen -list | grep -q "nexus-$service_key"; then
                                echo "✅ $display_name restarted successfully"
                                ((restarted_count++))
                            else
                                echo "❌ Failed to restart $display_name"
                            fi
                        done
                        echo "Restarted $restarted_count services successfully"
                        ;;
                esac
                exit 0
            fi
            
            if [[ -z "$service_name" ]]; then
                echo "ERROR: Service name required for $action"
                echo "Available services: sts, auth, world, chat, group, api, patcher"
                exit 1
            fi
            
            # Convert service name to service key
            local service_key=""
            for service_def in "${NEXUS_SERVICES[@]}"; do
                IFS=':' read -r key name display <<< "$service_def"
                if [[ "$service_name" == "$key" ]] || [[ "$service_name" == "$display_name" ]]; then
                    service_key="$key"
                    service_display="$display"
                    break
                fi
            done
            
            if [[ -z "$service_key" ]]; then
                echo "ERROR: Unknown service: $service_name"
                echo "Available services: sts, auth, world, chat, group, api, patcher"
                exit 1
            fi
            
            case "$action" in
                attach)
                    echo "Attaching to $service_display..."
                    if screen -list | grep -q "nexus-$service_key"; then
                        echo "Use Ctrl+A, D to detach from screen session"
                        echo "Attaching to nexus-$service_key..."
                        sleep 2
                        screen -r "nexus-$service_key"
                    else
                        echo "ERROR: $service_display is not running"
                        echo "Start it first: nexusforever service start $service_key"
                        exit 1
                    fi
                    ;;
                start)
                    echo "Starting $service_display..."
                    if screen -list | grep -q "nexus-$service_key"; then
                        echo "WARNING: $service_display is already running"
                    else
                        screen -dmS "nexus-$service_key" "$SERVICES_DIR/nexus-${service_key}.sh"
                        sleep 2
                        if screen -list | grep -q "nexus-$service_key"; then
                            echo "✅ $service_display started successfully"
                        else
                            echo "❌ Failed to start $service_display"
                            exit 1
                        fi
                    fi
                    ;;
                stop)
                    echo "Stopping $service_display..."
                    if screen -list | grep -q "nexus-$service_key"; then
                        screen -S "nexus-$service_key" -X quit
                        echo "✅ $service_display stopped"
                    else
                        echo "WARNING: $service_display was not running"
                    fi
                    ;;
                restart)
                    echo "Restarting $service_display..."
                    if screen -list | grep -q "nexus-$service_key"; then
                        screen -S "nexus-$service_key" -X quit
                        sleep 2
                    fi
                    screen -dmS "nexus-$service_key" "$SERVICES_DIR/nexus-${service_key}.sh"
                    sleep 2
                    if screen -list | grep -q "nexus-$service_key"; then
                        echo "✅ $service_display restarted successfully"
                    else
                        echo "❌ Failed to restart $service_display"
                        exit 1
                    fi
                    ;;
            esac
            ;;
        logs)
            if [[ -z "$service_name" ]]; then
                echo "ERROR: Service name required for logs"
                echo "Available services: sts, auth, world, chat, group, api, patcher"
                exit 1
            fi
            
            # Convert service name to service key
            local service_key=""
            for service_def in "${NEXUS_SERVICES[@]}"; do
                IFS=':' read -r key name display <<< "$service_def"
                if [[ "$service_name" == "$key" ]] || [[ "$service_name" == "$display_name" ]]; then
                    service_key="$key"
                    service_display="$display"
                    break
                fi
            done
            
            if [[ -z "$service_key" ]]; then
                echo "ERROR: Unknown service: $service_name"
                echo "Available services: sts, auth, world, chat, group, api, patcher"
                exit 1
            fi
            
            local log_file="$SERVICES_DIR/nexus-${service_key}.log"
            if [[ -f "$log_file" ]]; then
                echo "Showing logs for $service_display (last 20 lines):"
                echo "--------------------------------------------------------"
                tail -20 "$log_file"
            else
                echo "ERROR: Log file not found: $log_file"
                exit 1
            fi
            ;;
        status)
            manage_service_status
            ;;
        *)
            echo "ERROR: Unknown action: $action"
            echo "Available actions: start, stop, restart, logs, status, start all, stop all, restart all"
            exit 1
            ;;
    esac
}

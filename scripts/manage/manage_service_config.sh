#!/bin/bash

# NexusForever Linux Installer - Service Configuration Menu

# View current service configurations
view_current_configs() {
    clear
    print_header "Current Service Configurations"
    echo ""
    
    print_menu_box "👁️ CURRENT CONFIGURATIONS"
    
    # Display database settings
    echo "🗄️ DATABASE SETTINGS:"
    echo "  Host: $DB_HOST"
    echo "  Port: $DB_PORT"
    echo "  User: $DB_USER"
    echo "  Auth DB: $DB_NAME_AUTH"
    echo "  Char DB: $DB_NAME_CHAR"
    echo "  World DB: $DB_NAME_WORLD"
    echo ""
    
    # Display service ports
    echo "🔧 SERVICE PORTS:"
    echo "  Auth Server: $AUTH_SERVER_PORT"
    echo "  World Server: $WORLD_SERVER_PORT"
    echo "  API Server: $API_SERVER_PORT"
    echo "  Chat Server: $CHAT_SERVER_PORT"
    echo "  Group Server: $GROUP_SERVER_PORT"
    echo ""
    
    # Display message broker settings
    echo "📨 MESSAGE BROKER:"
    echo "  Host: $BROKER_HOST"
    echo "  Port: $BROKER_PORT"
    echo "  User: $BROKER_USER"
    echo ""
    
    # Display service mode
    echo "⚙️ SERVICE MODE:"
    echo "  Mode: $SERVICE_MODE"
    echo "  User: $SERVICE_USER"
    echo ""
    
    print_menu_footer
    print_menu_separator
    
    print_menu_navigation "Back to Service Config"
    echo ""
    read -p "Press Enter to continue..."
}

# View JSON configuration files
view_json_files() {
    clear
    print_header "JSON Configuration Files"
    echo ""
    
    print_menu_box "📄 CONFIGURATION FILES"
    
    # Define config file paths
    local json_config_files=(
        "$SERVER_DIR/Source/NexusForever.AuthServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/AuthServer.json"
        "$SERVER_DIR/Source/NexusForever.StsServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/StsServer.json"
        "$SERVER_DIR/Source/NexusForever.WorldServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/WorldServer.json"
        "$SERVER_DIR/Source/NexusForever.Server.ChatServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/ChatServer.json"
        "$SERVER_DIR/Source/NexusForever.Server.GroupServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/GroupServer.json"
        "$SERVER_DIR/Source/NexusForever.API.Character/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/CharacterAPI.json"
    )
    
    local index=1
    for config_file in "${json_config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            local filename=$(basename "$config_file")
            echo "$index. 📄 $filename"
            ((index++))
        else
            local filename=$(basename "$config_file")
            echo "$index. ❌ $filename (not found)"
            ((index++))
        fi
    done
    
    print_menu_footer
    print_menu_separator
    
    # View selected file
    echo "Available files: 1-$((index - 1))"
    echo ""
    read -p "Enter file number to view (or 'a' for all, 'b' to back): " choice
    
    if [[ "$choice" == "b" ]]; then
        return
    elif [[ "$choice" == "a" ]]; then
        # View all files
        for config_file in "${json_config_files[@]}"; do
            if [[ -f "$config_file" ]]; then
                local filename=$(basename "$config_file")
                echo ""
                echo "📄 $filename"
                echo "────────────────────────────────────────────────"
                cat "$config_file" 2>/dev/null || echo "  (Error reading file)"
                echo "────────────────────────────────────────────────"
                echo ""
                read -p "Press Enter to continue..."
            fi
        done
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$index" ]]; then
        local selected_file="${json_config_files[$((choice - 1))]}"
        if [[ -f "$selected_file" ]]; then
            local filename=$(basename "$selected_file")
            echo ""
            echo "📄 $filename"
            echo "────────────────────────────────────────────────"
            cat "$selected_file" 2>/dev/null || echo "  (Error reading file)"
            echo "────────────────────────────────────────────────"
            echo ""
            read -p "Press Enter to continue..."
        else
            print_error "Selected file not found"
            read -p "Press Enter to continue..."
        fi
    else
        print_error "Invalid choice"
        read -p "Press Enter to continue..."
    fi
}

# Service configuration menu
manage_service_config() {
    while true; do
        clear
        print_header "Service Configuration"
        echo ""
        
        print_menu_box "⚙️ SERVICE CONFIGURATION"
        print_menu_option "1" "👁️" "View Current Configs"
        print_menu_option "2" "📄" "View JSON Files"
        print_menu_option "3" "🌐" "Edit Network Settings"
        print_menu_option "4" "🗄️" "Edit Database Settings"
        print_menu_option "5" "🔧" "Edit Service Ports"
        print_menu_option "6" "📨" "Edit Message Broker"
        print_menu_option "7" "🔄" "Reinstall Configs"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Management Menu"
        echo ""
        read -p "Enter your choice [1-7, b, q]: " choice
        
        case $choice in
            1)
                view_current_configs
                ;;
            2)
                view_json_files
                ;;
            3)
                menu_network_config
                ;;
            4)
                menu_database_config
                ;;
            5)
                menu_ports_config
                ;;
            6)
                menu_broker_config
                ;;
            7)
                print_status "Reinstalling all service configurations..."
                install_configs
                read -p "Press Enter to continue..."
                ;;
            b|B)
                break
                ;;
            q|Q)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Network configuration menu
menu_network_config() {
    while true; do
        clear
        print_header "Network Configuration"
        echo ""
        
        print_menu_box "🌐 NETWORK SETTINGS"
        print_menu_option "1" "🔗" "Edit Auth Server Port"
        print_menu_option "2" "🔗" "Edit World Server Port"
        print_menu_option "3" "🔗" "Edit API Server Port"
        print_menu_option "4" "🔗" "Edit Chat Server Port"
        print_menu_option "5" "🔗" "Edit Group Server Port"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Service Config"
        echo ""
        read -p "Enter your choice [1-5, b, q]: " choice
        
        case $choice in
            1)
                edit_service_port "AuthServer" "$AUTH_SERVER_PORT"
                ;;
            2)
                edit_service_port "WorldServer" "$WORLD_SERVER_PORT"
                ;;
            3)
                edit_service_port "API.Character" "$API_SERVER_PORT"
                ;;
            4)
                edit_service_port "ChatServer" "$CHAT_SERVER_PORT"
                ;;
            5)
                edit_service_port "GroupServer" "$GROUP_SERVER_PORT"
                ;;
            b|B)
                break
                ;;
            q|Q)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Edit individual service port
edit_service_port() {
    local service_name="$1"
    local current_port="$2"
    
    echo ""
    print_status "Current $service_name Port: $current_port"
    echo ""
    read -p "Enter new port (leave empty to keep $current_port): " new_port
    
    if [[ -n "$new_port" ]]; then
        # Update the configuration file
        local config_file="$SERVER_DIR/Source/NexusForever.$service_name/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/$service_name.json"
        if [[ -f "$config_file" ]]; then
            sudo sed -i "s/\"Port\": .*/\"Port\": $new_port,/" "$config_file"
            print_status "$service_name port updated to $new_port"
            
            # Update the variable in memory
            case "$service_name" in
                "AuthServer")
                    AUTH_SERVER_PORT="$new_port"
                    ;;
                "WorldServer")
                    WORLD_SERVER_PORT="$new_port"
                    ;;
                "API.Character")
                    API_SERVER_PORT="$new_port"
                    ;;
                "ChatServer")
                    CHAT_SERVER_PORT="$new_port"
                    ;;
                "GroupServer")
                    GROUP_SERVER_PORT="$new_port"
                    ;;
            esac
        else
            print_error "$service_name configuration file not found"
        fi
        read -p "Press Enter to continue..."
    else
        print_status "Port unchanged"
        read -p "Press Enter to continue..."
    fi
}

# Database configuration menu
menu_database_config() {
    while true; do
        clear
        print_header "Database Configuration"
        echo ""
        
        print_menu_box "🗄️ DATABASE SETTINGS"
        print_menu_option "1" "🔗" "Edit Auth Database"
        print_menu_option "2" "🔗" "Edit Character Database"
        print_menu_option "3" "🔗" "Edit World Database"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Service Config"
        echo ""
        read -p "Enter your choice [1-3, b, q]: " choice
        
        case $choice in
            1)
                edit_database_connection "auth" "$DB_HOST" "$DB_PORT" "$DB_USER" "$DB_PASS" "$DB_NAME_AUTH"
                ;;
            2)
                edit_database_connection "character" "$DB_HOST" "$DB_PORT" "$DB_USER" "$DB_PASS" "$DB_NAME_CHAR"
                ;;
            3)
                edit_database_connection "world" "$DB_HOST" "$DB_PORT" "$DB_USER" "$DB_PASS" "$DB_NAME_WORLD"
                ;;
            b|B)
                break
                ;;
            q|Q)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Edit database connection
edit_database_connection() {
    local db_type="$1"
    local host="$2"
    local port="$3"
    local user="$4"
    local pass="$5"
    local name="$6"
    
    echo ""
    print_status "Current $db_type Database Settings:"
    echo "  Host: $host"
    echo "  Port: $port"
    echo "  User: $user"
    echo "  Name: $name"
    echo ""
    read -p "Enter new host (leave empty to keep $host): " new_host
    
    if [[ -n "$new_host" ]]; then
        # Update all config files with new host
        local config_files=(
            "$SERVER_DIR/Source/NexusForever.AuthServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/AuthServer.json"
            "$SERVER_DIR/Source/NexusForever.StsServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/StsServer.json"
            "$SERVER_DIR/Source/NexusForever.WorldServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/WorldServer.json"
        )
        
        for config_file in "${config_files[@]}"; do
            if [[ -f "$config_file" ]]; then
                sudo sed -i "s/server=$host/server=$new_host/g" "$config_file"
            fi
        done
        print_status "Database host updated to $new_host"
        DB_HOST="$new_host"
    fi
    
    read -p "Press Enter to continue..."
}

# Message broker configuration menu
menu_broker_config() {
    while true; do
        clear
        print_header "Message Broker Configuration"
        echo ""
        
        print_menu_box "📨 MESSAGE BROKER SETTINGS"
        print_menu_option "1" "🔗" "Edit Broker Host"
        print_menu_option "2" "🔗" "Edit Broker Port"
        print_menu_option "3" "🔗" "Edit Broker User"
        print_menu_option "4" "🔗" "Edit Broker Password"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Service Config"
        echo ""
        read -p "Enter your choice [1-4, b, q]: " choice
        
        case $choice in
            1)
                edit_broker_setting "host" "$BROKER_HOST"
                ;;
            2)
                edit_broker_setting "port" "$BROKER_PORT"
                ;;
            3)
                edit_broker_setting "user" "$BROKER_USER"
                ;;
            4)
                edit_broker_setting "password" "$BROKER_PASS"
                ;;
            b|B)
                break
                ;;
            q|Q)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Edit individual broker setting
edit_broker_setting() {
    local setting="$1"
    local current_value="$2"
    
    echo ""
    print_status "Current Broker $setting: $current_value"
    echo ""
    read -p "Enter new broker $setting (leave empty to keep $current_value): " new_value
    
    if [[ -n "$new_value" ]]; then
        # Update all config files with new setting
        local config_files=(
            "$SERVER_DIR/Source/NexusForever.WorldServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION/WorldServer.json"
        )
        
        for config_file in "${config_files[@]}"; do
            if [[ -f "$config_file" ]]; then
                case "$setting" in
                    "host")
                        sudo sed -i "s|amqp://.*:|amqp://$BROKER_USER:$BROKER_PASS@|g" "$config_file"
                        sudo sed -i "s|@localhost:|@$new_value:|g" "$config_file"
                        ;;
                    "port")
                        sudo sed -i "s|:$BROKER_PORT\"|:$new_value\"|g" "$config_file"
                        ;;
                    "user")
                        sudo sed -i "s|$BROKER_USER:|$new_value:|g" "$config_file"
                        ;;
                    "password")
                        sudo sed -i "s|:$BROKER_PASS@|:$new_value@|g" "$config_file"
                        ;;
                esac
            fi
        done
        print_status "Broker $setting updated to $new_value"
        
        # Update the variable in memory
        case "$setting" in
            "host")
                BROKER_HOST="$new_value"
                ;;
            "port")
                BROKER_PORT="$new_value"
                ;;
            "user")
                BROKER_USER="$new_value"
                ;;
            "password")
                BROKER_PASS="$new_value"
                ;;
        esac
    fi
    
    read -p "Press Enter to continue..."
}

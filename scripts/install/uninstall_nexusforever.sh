#!/bin/bash

# NexusForever Linux Installer - Uninstall Function

# Complete uninstallation of NexusForever
uninstall_nexusforever() {
    clear
    print_header "NexusForever Uninstaller"
    echo ""
    
    print_menu_box "🗑️ UNINSTALL OPTIONS"
    print_menu_option "1" "🗑️" "Complete Uninstall (All Components)"
    print_menu_option "2" "🗑️" "Uninstall Services Only"
    print_menu_option "3" "🗑️" "Uninstall Database Only"
    print_menu_option "4" "🗑️" "Uninstall Files Only"
    print_menu_footer
    print_menu_separator
    
    print_menu_navigation "Back to Main Menu"
    echo ""
    read -p "Enter your choice [1-4, b, q]: " choice
    
    case $choice in
        1)
            complete_uninstall
            ;;
        2)
            uninstall_services_only
            ;;
        3)
            uninstall_database_only
            ;;
        4)
            uninstall_files_only
            ;;
        b|B)
            return
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
}

# Complete uninstallation
complete_uninstall() {
    clear
    print_header "Complete NexusForever Uninstallation"
    echo ""
    
    print_warning "This will completely remove NexusForever including:"
    echo "  🗑️  All services and screen sessions"
    echo "  🗑️  All databases and data"
    echo "  🗑️  All configuration files"
    echo "  🗑️  All source code and binaries"
    echo "  🗑️  All user accounts and groups"
    echo ""
    
    read -p "Are you sure you want to continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        return
    fi
    
    echo ""
    print_status "Starting complete uninstallation..."
    
    # Step 1: Stop all services
    print_status "Stopping all services..."
    stop_all_services
    
    # Step 2: Remove databases
    print_status "Removing databases..."
    remove_all_databases
    
    # Step 3: Remove files and directories
    print_status "Removing files and directories..."
    remove_all_files

    # Step 4: Remove systemd services
    print_status "Removing systemd services..."
    remove_systemd_services
    
    # Step 5: Remove firewall rules
    print_status "Removing firewall rules..."
    remove_firewall_rules
    
    # Step 6: Remove command alias
    print_status "Removing command alias..."
    remove_command_alias

    # Step 7: Remove user and groups
    print_status "User account removal notice..."
    remove_user_accounts
    
    print_status "Complete uninstallation finished"
    print_warning "NexusForever has been completely removed from your system"
    echo ""
    read -p "Press Enter to continue..."
}

# Uninstall services only
uninstall_services_only() {
    clear
    print_header "Uninstall Services Only"
    echo ""
    
    print_warning "This will remove:"
    echo "  🗑️  All services and screen sessions"
    echo "  🗑️  Service configuration files"
    echo ""
    
    read -p "Are you sure you want to continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        return
    fi
    
    echo ""
    print_status "Stopping and removing services..."
    
    # Stop all services
    stop_all_services
    
    # Remove service scripts
    if [[ -d "$SERVICES_DIR" ]]; then
        sudo rm -rf "$SERVICES_DIR"
        print_status "Service scripts removed"
    fi
    
    # Remove systemd services
    remove_systemd_services
    
    print_status "Services uninstallation completed"
    echo ""
    read -p "Press Enter to continue..."
}

# Uninstall database only
uninstall_database_only() {
    clear
    print_header "Uninstall Database Only"
    echo ""
    
    print_warning "This will remove:"
    echo "  🗑️  All databases and data"
    echo "  🗑️  Database user accounts"
    echo ""
    
    read -p "Are you sure you want to continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        return
    fi
    
    echo ""
    print_status "Removing databases..."
    remove_all_databases
    
    print_status "Database uninstallation completed"
    echo ""
    read -p "Press Enter to continue..."
}

# Uninstall files only
uninstall_files_only() {
    clear
    print_header "Uninstall Files Only"
    echo ""
    
    print_warning "This will remove:"
    echo "  🗑️  All source code and binaries"
    echo "  🗑️  All configuration files"
    echo "  🗑️  All log files"
    echo ""
    
    read -p "Are you sure you want to continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        return
    fi
    
    echo ""
    print_status "Removing files and directories..."
    remove_all_files
    
    print_status "Files uninstallation completed"
    echo ""
    read -p "Press Enter to continue..."
}

# Helper functions
stop_all_services() {
    # Stop all screen sessions
    if screen -list | grep -q "nexus-"; then
        for session in $(screen -list | grep "nexus-" | awk '{print $1}'); do
            screen -S "$session" -X quit 2>/dev/null
        done
        print_status "All screen sessions stopped"
    fi
    
    # Stop systemd services if they exist
    local services=("nexus-sts" "nexus-auth" "nexus-world" "nexus-chat" "nexus-group" "nexus-api" "nexus-patcher")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            sudo systemctl stop "$service"
            sudo systemctl disable "$service"
            print_status "Stopped $service service"
        fi
    done
}

remove_all_databases() {
    # Drop all NexusForever databases
    local databases=("nexusforever_auth" "nexusforever_char" "nexusforever_world" "nexusforever_chat" "nexusforever_group")
    
    for db in "${databases[@]}"; do
        if mysql -u root -p"$DB_PASS" -h "$DB_HOST" -e "DROP DATABASE IF EXISTS \`$db\`;" 2>/dev/null; then
            print_status "Dropped database: $db"
        fi
    done
    
    # Remove database user
    if mysql -u root -p"$DB_PASS" -h "$DB_HOST" -e "DROP USER IF EXISTS '$DB_USER';" 2>/dev/null; then
        print_status "Removed database user: $DB_USER"
    fi
}

remove_all_files() {
    # Remove source directory
    if [[ -d "$SERVER_DIR" ]]; then
        sudo rm -rf "$SERVER_DIR"
        print_status "Source directory removed"
    fi
    
    # Remove patcher directory
    if [[ -d "$PATCHER_DIR" ]]; then
        sudo rm -rf "$PATCHER_DIR"
        print_status "Patcher directory removed"
    fi
    
    # Remove configuration directory
    if [[ -d "$CONFIG_DIR" ]]; then
        sudo rm -rf "$CONFIG_DIR"
        print_status "Configuration directory removed"
    fi
    
    # Remove services directory
    if [[ -d "$SERVICES_DIR" ]]; then
        sudo rm -rf "$SERVICES_DIR"
        print_status "Services directory removed"
    fi
    
    # Remove database directory
    if [[ -d "$DATABASE_DIR" ]]; then
        sudo rm -rf "$DATABASE_DIR"
        print_status "Database directory removed"
    fi
    
    # Remove log files
    if [[ -d "/home/$SERVICE_USER/.nexusforever" ]]; then
        sudo rm -rf "/home/$SERVICE_USER/.nexusforever"
        print_status "Log files removed"
    fi
}

remove_systemd_services() {
    # Remove systemd service files using NEXUS_SERVICES array
    for service_def in "${NEXUS_SERVICES[@]}"; do
        IFS=':' read -r service_key service_name display_name <<< "$service_def"
        local service_file="/etc/systemd/system/${SERVICE_PREFIX}.${service_key}.service"
        
        if [[ -f "$service_file" ]]; then
            sudo systemctl stop "${SERVICE_PREFIX}.${service_key}" 2>/dev/null
            sudo systemctl disable "${SERVICE_PREFIX}.${service_key}" 2>/dev/null
            sudo rm "$service_file"
            print_status "Removed systemd service: ${SERVICE_PREFIX}.${service_key}"
        fi
    done
    
    # Reload systemd daemon
    sudo systemctl daemon-reload
    print_status "Systemd daemon reloaded"
}

remove_firewall_rules() {
    # Remove UFW rules for all NexusForever ports
    local ports=("$AUTH_SERVER_PORT" "$WORLD_SERVER_PORT" "$API_SERVER_PORT" "$CHAT_SERVER_PORT" "$GROUP_SERVER_PORT" "$PATCHER_SERVER_PORT")
    
    for port in "${ports[@]}"; do
        if sudo ufw status | grep -q "$port"; then
            sudo ufw delete allow "$port/tcp" 2>/dev/null
            print_status "Removed firewall rule for port: $port"
        fi
    done
    
    # Reload UFW if rules were removed
    if sudo ufw status | grep -q -E "(ALLOW|DENY)"; then
        sudo ufw reload 2>/dev/null
        print_status "Firewall rules reloaded"
    fi
}

remove_command_alias() {
    # Remove nexusforever command
    local nexusforever_cmd="/usr/local/bin/nexusforever"
    if [[ -f "$nexusforever_cmd" ]]; then
        sudo rm "$nexusforever_cmd"
        print_status "Command alias removed: $nexusforever_cmd"
    fi
}

remove_user_accounts() {
    # Remove database users automatically
    print_status "Removing database users..."
    
    # Remove database user
    if mysql -u root -p"$DB_PASS" -h "$DB_HOST" -e "DROP USER IF EXISTS '$DB_USER';" 2>/dev/null; then
        print_status "Database user removed: $DB_USER"
    else
        print_status "Database user '$DB_USER' not found or already removed"
    fi
    
    # Remove remote database user if exists
    if mysql -u root -p"$DB_PASS" -h "$DB_HOST" -e "DROP USER IF EXISTS '$REMOTE_DB_USER';" 2>/dev/null; then
        print_status "Remote database user removed: $REMOTE_DB_USER"
    else
        print_status "Remote database user '$REMOTE_DB_USER' not found or already removed"
    fi
    
    echo ""
    print_warning "Service user removal requires manual action:"
    echo ""
    echo "🔧 To remove the service user '$SERVICE_USER', run:"
    echo "   sudo userdel -r $SERVICE_USER"
    echo ""
    print_status "Note: Service user removal is manual to prevent accidental data loss"
    print_status "Only remove the service user after confirming all data is backed up if needed"
}
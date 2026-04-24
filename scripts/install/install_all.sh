#!/bin/bash

# NexusForever Linux Installer - Complete Installation Function

# Complete installation function (matches menu_install_full)
install_all() {
    local interactive_mode="${1:-false}"  # Pass true for menu mode, false for CLI
    
    print_header "Complete NexusForever Installation"
    echo ""
    
    print_warning "This will install ALL NexusForever components in order:"
    echo "  📦 1. System Requirements"
    echo "  ⚙️ 2. Server Core"
    echo "  🧩 3. Server Plugins"
    echo "  📋 4. Configuration Files"
    echo "  🎮 5. Client Data Files"
    echo "  🔌 6. MariaDB Server"
    echo "  🗄️ 7. Database Setup"
    echo "  📨 8. Message Broker"
    echo "  🚀 9. Services Setup"
    echo "  🔥 10. Firewall Configuration"
    echo ""
    
    print_status "Starting complete NexusForever installation..."
    echo ""
    
    # Step 1: System Requirements
    print_header "Step 1/10: Installing System Requirements"
    if install_requirements; then
        print_status "✅ System requirements installed successfully"
    else
        print_error "❌ Failed to install system requirements"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 2: Server Core (includes patcher)
    print_header "Step 2/10: Installing Server Core (includes patcher)"
    if install_server; then
        print_status "✅ Server core installed successfully"
    else
        print_error "❌ Failed to install server core"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 3: Server Plugins
    print_header "Step 3/10: Setting up Server Plugins"
    if install_plugins; then
        print_status "✅ Server plugins setup completed successfully"
    else
        print_error "❌ Failed to setup server plugins"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 4: Configuration Files
    print_header "Step 4/10: Installing Configuration Files"
    if install_configs; then
        print_status "✅ Configuration files installed successfully"
    else
        print_error "❌ Failed to install configuration files"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 5: Client Data Files
    print_header "Step 5/10: Installing Client Data Files"
    if install_client_data; then
        print_status "✅ Client data files installed successfully"
    else
        print_error "❌ Failed to install client data files"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 6: MariaDB Server
    print_header "Step 6/10: Installing MariaDB Server"
    if install_mariadb; then
        print_status "✅ MariaDB server installed successfully"
    else
        print_error "❌ Failed to install MariaDB server"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 7: Database Setup
    print_header "Step 7/10: Setting up Database"
    if install_database; then
        print_status "✅ Database setup completed successfully"
    else
        print_error "❌ Failed to setup database"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 8: Message Broker
    print_header "Step 8/10: Installing Message Broker"
    if install_broker; then
        print_status "✅ Message broker installed successfully"
    else
        print_error "❌ Failed to install message broker"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 9: Services Setup
    print_header "Step 9/10: Installing Services"
    if install_services; then
        print_status "✅ Services installed successfully"
    else
        print_error "❌ Failed to install services"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Step 10: Firewall Configuration
    print_header "Step 10/10: Configuring Firewall"
    if install_firewall; then
        print_status "✅ Firewall configured successfully"
    else
        print_error "❌ Failed to configure firewall"
        if [[ "$interactive_mode" == "true" ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
        return 1
    fi
    echo ""
    
    # Installation Complete
    print_header "🎉 Installation Complete!"
    echo ""
    print_status "NexusForever has been successfully installed with all components:"
    echo "  ✅ System Requirements"
    echo "  ✅ Server Core"
    echo "  ✅ Configuration Files"
    echo "  ✅ Client Data Files"
    echo "  ✅ Server Plugins"
    echo "  ✅ MariaDB Server"
    echo "  ✅ Database Setup"
    echo "  ✅ Message Broker"
    echo "  ✅ Services"
    echo "  ✅ Firewall"
    echo ""
    print_status "You can now start the services using:"
    echo "  nexusforever service start all"
    echo ""
    print_status "Or check service status with:"
    echo "  nexusforever service status"
    echo ""
    
    return 0
}

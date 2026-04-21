#!/bin/bash

# Service Ports Configuration Menu
menu_ports() {
    while true; do
        clear
        print_header "Service Ports Configuration"
        echo ""
        
        print_menu_box "🌐 CURRENT PORT CONFIGURATION"
        print_menu_option "1" "🔐" "Auth Server Port: $AUTH_SERVER_PORT"
        print_menu_option "2" "🌍" "World Server Port: $WORLD_SERVER_PORT"
        print_menu_option "3" "📡" "API Server Port: $API_SERVER_PORT"
        print_menu_option "4" "🔍" "Check Port Accessibility"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Configuration Menu"
        echo ""
        read -p "Enter your choice [1-4, b, q]: " choice
        
        case $choice in
            1)
                read -p "Enter Auth Server port (current: $AUTH_SERVER_PORT): " AUTH_SERVER_PORT
                print_status "Auth Server port set to: $AUTH_SERVER_PORT"
                ;;
            2)
                read -p "Enter World Server port (current: $WORLD_SERVER_PORT): " WORLD_SERVER_PORT
                print_status "World Server port set to: $WORLD_SERVER_PORT"
                ;;
            3)
                read -p "Enter API Server port (current: $API_SERVER_PORT): " API_SERVER_PORT
                print_status "API Server port set to: $API_SERVER_PORT"
                ;;
            4)
                firewall_check_port_accessibility
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
        read -p "Press Enter to continue..."
    done
}

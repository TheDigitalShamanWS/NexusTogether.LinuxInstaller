#!/bin/bash

# Manual Installation Menu
menu_install_manual() {
    while true; do
        clear
        print_header "Manual Installation - Choose Components"
        echo ""
        
        print_menu_box "🔧 SYSTEM & CORE"
        print_menu_option "1" "📦" "Install System Requirements"
        print_menu_option "2" "⚙️" "Install Server Core"
        print_menu_option "3" "📋" "Install Configuration Files"
        print_menu_option "4" "🎮" "Install Client Data Files"
        print_menu_footer
        print_menu_separator
        
        print_menu_box "🗄️ DATABASE & SERVICES"
        print_menu_option "5" "🗄️" "Install MariaDB Server"
        print_menu_option "6" "🗄️" "Install Database"
        print_menu_option "7" "📨" "Install Message Broker"
        print_menu_option "8" "🚀" "Install Services"
        print_menu_footer
        print_menu_separator
        
        print_menu_box "🔥 NETWORK & SECURITY"
        print_menu_option "9" "🔥" "Install Firewall"
        print_menu_footer
        print_menu_separator
        
        print_menu_box "🚪 NAVIGATION"
        print_menu_option "b" "⬅️" "Back to Install Menu"
        print_menu_option "q" "🚪" "Quit"
        print_menu_footer
        print_menu_separator
        read -p "Enter your choice [1-9, b, q]: " choice
        
        case $choice in
            1)
                install_requirements
                read -p "Press Enter to continue..."
                ;;
            2)
                install_server
                read -p "Press Enter to continue..."
                ;;
            3)
                install_configs
                read -p "Press Enter to continue..."
                ;;
            4)
                install_client_data
                read -p "Press Enter to continue..."
                ;;
            5)
                install_mariadb
                read -p "Press Enter to continue..."
                ;;
            6)
                install_database
                read -p "Press Enter to continue..."
                ;;
            7)
                install_broker
                read -p "Press Enter to continue..."
                ;;
            8)
                install_services
                read -p "Press Enter to continue..."
                ;;
            9)
                install_firewall
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

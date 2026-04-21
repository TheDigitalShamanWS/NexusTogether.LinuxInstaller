#!/bin/bash

# NexusForever Linux Installer - Main Menu Function

# Main Menu
main_menu() {
    while true; do
        clear
        print_header "NexusForever Linux Installer"
        echo ""
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ ⚙️ CONFIGURATION & INSTALLATION                          │"
        echo "├─────────────────────────────────────────────────────────┤"
        echo "│ 1. Configuration                                        │"
        echo "│ 2. Installation                                         │"
        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ 🖥️ MANAGEMENT                                            │"
        echo "├─────────────────────────────────────────────────────────┤"
        echo "│ 3. Manage Server                                        │"
        echo "│ 4. Manage Networking                                    │"
        echo "│ 5. Manage Backups                                       │"
        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ 🚪 EXIT                                                 │"
        echo "├─────────────────────────────────────────────────────────┤"
        echo "│ q. Quit                                                 │"
        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
        read -p "Enter your choice [1-5, q]: " choice
        
        case $choice in
            1)
                menu_config
                ;;
            2)
                menu_install
                ;;
            3)
                menu_manage
                ;;
            4)
                menu_ports
                ;;
            5)
                menu_backup
                ;;
            q|Q)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice"
                ;;
        esac
    done
}

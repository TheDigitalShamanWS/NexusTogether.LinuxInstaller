#!/bin/bash

# Main Menu
menu_install() {
    while true; do
        clear
        print_header "NexusForever Linux Installer"
        echo ""
        
        print_menu_box "🚀 INSTALLATION OPTIONS"
        print_menu_option "1" "🚀" "Complete Installation (All Components)"
        print_menu_option "2" "🔧" "Manual Installation (Choose Components)"
        print_menu_option "3" "🗑️" "Uninstall NexusForever"
        print_menu_footer
        print_menu_separator
        
        print_menu_box "🚪 NAVIGATION"
        print_menu_option "b" "⬅️" "Back to Main Menu"
        print_menu_option "q" "🚪" "Quit"
        print_menu_footer
        echo ""
        read -p "Enter your choice [1-3, b, q]: " choice
        
        case $choice in
            1)
                install_all true
                ;;
            2)
                menu_install_manual
                ;;
            3)
                uninstall_nexusforever
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

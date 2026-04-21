#!/bin/bash

# Backup Menu
menu_backup() {
    while true; do
        clear
        print_header "Backup Management"
        echo ""
        
        print_menu_box "💾 BACKUP MANAGEMENT"
        print_menu_option "1" "💾" "Backup Configuration"
        print_menu_option "2" "🧹" "Clean Old Backups"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Main Menu"
        echo ""
        read -p "Enter your choice [1-2, b, q]: " choice
        
        case $choice in
            1)
                backup_configuration
                read -p "Press Enter to continue..."
                ;;
            2)
                cleanup_old_backups
                read -p "Press Enter to continue..."
                ;;
            3)
                break
                ;;
            "q")
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

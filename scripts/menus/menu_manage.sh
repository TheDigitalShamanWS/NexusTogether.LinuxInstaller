#!/bin/bash

# Server Management Menu
menu_manage() {
    # Service action submenu (start/stop)
    menu_service_action() {
        local action="$1"
        
        clear
        print_header "$action Services"
        echo ""
        
        # Display service options
        echo "1. 🌐 All Services"
        local index=2
        for service_def in "${NEXUS_SERVICES[@]}"; do
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            echo "$index. 🚀 $display_name"
            ((index++))
        done
        
        echo ""
        echo "$((index)). ⬅️ Back to Management Menu"
        echo ""
        echo "q. 🚪 Quit"
        echo ""
        read -p "Enter your choice [1-$((index)), b, q]: " choice
        
        if [[ "$choice" == "q" ]]; then
            print_status "Goodbye!"
            exit 0
        elif [[ "$choice" == "b" ]]; then
            return
        elif [[ "$choice" == "1" ]]; then
            manage_${action}_service "all"
            read -p "Press Enter to continue..."
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 2 ]] && [[ "$choice" -lt "$index" ]]; then
            local service_index=$((choice - 2))
            local service_def="${NEXUS_SERVICES[$service_index]}"
            IFS=':' read -r service_key service_name display_name <<< "$service_def"
            manage_${action}_service "$service_key"
            read -p "Press Enter to continue..."
        else
            print_error "Invalid choice"
            read -p "Press Enter to continue..."
        fi
    }
    
    while true; do
        # Display server management menu
        clear
        manage_service_status
        
        print_menu_box "🖥️ SERVER MANAGEMENT"
        print_menu_option "1" "🚀" "Start Services"
        print_menu_option "2" "🛑" "Stop Services"
        print_menu_option "3" "📊" "Check Status"
        print_menu_option "4" "📨" "Send Commands"
        print_menu_option "5" "⚙️" "Edit Configs"
        print_menu_option "6" "📋" "View Logs"
        print_menu_footer
        print_menu_separator
        
        print_menu_navigation "Back to Main Menu"
        echo ""
        read -p "Enter your choice [1-6, b, q]: " choice
        
        case $choice in
            1)
                    menu_service_action "start"
                    ;;
            2)
                    menu_service_action "stop"
                    ;;
            3)
                    manage_service_status
                    read -p "Press Enter to continue..."
                    ;;
            4)
                    manage_command_menu
                    ;;
            5)
                    manage_service_config
                    ;;
            6)
                    manage_service_logs
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

#!/bin/bash

# NexusForever Linux Installer - Service Command Menu

# Command menu for specific service
menu_command_service() {
    local service_key="$1"
    local display_name="$2"
    
    while true; do
        clear
        print_header "$display_name Commands"
        echo ""
        
        case "$service_key" in
            "world")
                echo "1. Show Server Status"
                echo "2. List Connected Players"
                echo "3. Save World State"
                echo "4. Shutdown Server"
                echo "5. Restart Server"
                echo "6. Send Broadcast Message"
                echo "7. Kick Player"
                echo "8. Ban Player"
                echo "9. Unban Player"
                echo "10. Custom Command"
                ;;
            *)
                echo "1. Show Server Status"
                echo "2. Restart Service"
                echo "3. Custom Command"
                ;;
        esac
        
        echo ""
        echo "$((index + 1)). Back to Service Selection"
        echo ""
        echo "q. Quit"
        echo ""
        read -p "Enter your choice [1-$((index + 1)), q]: " choice
        
        if [[ "$choice" == "q" ]]; then
            print_status "Goodbye!"
            exit 0
        elif [[ "$choice" == "$((index + 1))" ]]; then
            break
        elif [[ "$choice" == "1" ]]; then
            manage_send_command "$service_key" "status"
            read -p "Press Enter to continue..."
        elif [[ "$choice" == "2" ]]; then
            if [[ "$service_key" == "world" ]]; then
                manage_send_command "$service_key" "players"
            else
                manage_send_command "$service_key" "restart"
            fi
            read -p "Press Enter to continue..."
        elif [[ "$choice" == "3" ]]; then
            if [[ "$service_key" == "world" ]]; then
                manage_send_command "$service_key" "save"
            else
                command_custom "$service_key"
            fi
            read -p "Press Enter to continue..."
        elif [[ "$choice" == "4" && "$service_key" == "world" ]]; then
            manage_send_command "$service_key" "shutdown"
            read -p "Press Enter to continue..."
        elif [[ "$choice" == "5" && "$service_key" == "world" ]]; then
            manage_send_command "$service_key" "restart"
            read -p "Press Enter to continue..."
        elif [[ "$choice" == "6" && "$service_key" == "world" ]]; then
            command_broadcast "$service_key"
        elif [[ "$choice" == "7" && "$service_key" == "world" ]]; then
            command_kick "$service_key"
        elif [[ "$choice" == "8" && "$service_key" == "world" ]]; then
            command_ban "$service_key"
        elif [[ "$choice" == "9" && "$service_key" == "world" ]]; then
            command_unban "$service_key"
        elif [[ "$choice" == "10" && "$service_key" == "world" ]]; then
            command_custom "$service_key"
        else
            print_error "Invalid choice"
            read -p "Press Enter to continue..."
        fi
    done
}

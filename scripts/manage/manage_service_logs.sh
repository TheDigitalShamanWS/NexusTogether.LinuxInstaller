#!/bin/bash

# NexusForever Linux Installer - Service Logs Management

# View service logs
manage_service_logs() {
    clear
    print_header "Service Logs"
    echo ""
    
    print_menu_box "📋 LOG FILES"
    
    # Define log file paths
    local log_files=(
        "$SERVICES_DIR/nexus-auth.log"
        "$SERVICES_DIR/nexus-sts.log"
        "$SERVICES_DIR/nexus-world.log"
        "$SERVICES_DIR/nexus-api.log"
        "$SERVICES_DIR/nexus-chat.log"
        "$SERVICES_DIR/nexus-group.log"
        "$SERVICES_DIR/nexus-patcher.log"
    )
    
    local index=1
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            local filename=$(basename "$log_file")
            local file_size=$(du -h "$log_file" | cut -f1)
            print_menu_option "$index. 📋 $filename ($file_size)"
            ((index++))
        else
            local filename=$(basename "$log_file")
            print_menu_option "$index. ❌ $filename (not found)"
            ((index++))
        fi
    done
    print_menu_footer
    print_menu_separator
    
    # View selected log file

    print_menu_navigation "Back to Main Menu"
    echo ""
    read -p "Enter file number to view (or 't' for tail, 'a' for all, 'b' to back): " choice
    
    if [[ "$choice" == "b" ]]; then
        return
    elif [[ "$choice" == "t" ]]; then
        # Tail all log files
        for log_file in "${log_files[@]}"; do
            if [[ -f "$log_file" ]]; then
                local filename=$(basename "$log_file")
                echo ""
                echo "📋 Tailing $filename (Ctrl+C to stop)..."
                echo "────────────────────────────────────────────────"
                tail -f "$log_file" 2>/dev/null || echo "  (Error tailing file)"
                echo "────────────────────────────────────────────────"
                echo ""
                read -p "Press Enter to continue..."
            fi
        done
    elif [[ "$choice" == "a" ]]; then
        # View all files
        for log_file in "${log_files[@]}"; do
            if [[ -f "$log_file" ]]; then
                local filename=$(basename "$log_file")
                echo ""
                echo "  $filename"
                echo "────────────────────────────────────────────────"
                # Show last 50 lines
                tail -n 50 "$log_file" 2>/dev/null || echo "  (Error reading file)"
                echo "────────────────────────────────────────────────"
                echo ""
                read -p "Press Enter to continue to next file..."
            fi
        done
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$index" ]]; then
        local selected_file="${log_files[$((choice - 1))]}"
        if [[ -f "$selected_file" ]]; then
            local filename=$(basename "$selected_file")
            echo ""
            echo "📋 $filename"
            echo "────────────────────────────────────────────────"
            # Show last 100 lines for individual file
            tail -n 100 "$selected_file" 2>/dev/null || echo "  (Error reading file)"
            echo "────────────────────────────────────────────────"
            echo ""
            read -p "Press Enter to continue..."
            # Loop back to file selection instead of exiting
            manage_service_logs
            return
        else
            print_error "Selected log file not found"
            read -p "Press Enter to continue..."
        fi
    else
        print_error "Invalid choice"
        read -p "Press Enter to continue..."
    fi
}

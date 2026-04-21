#!/bin/bash

# Configuration Menu - Combined View and Edit

# Main menu function
menu_config() {
    local menu_config_files=("$MANAGER_DIR/configs"/*.conf)
    local file_count=0

    # Get title with icon from config file
    get_config_title_with_icon() {
        local config_file="$1"
        local filename=$(basename "$config_file" .conf)
        local title=""
        local icon=""
        
        # Read the first line for Title tag
        if [[ -f "$config_file" ]]; then
            title=$(grep "^# Title:" "$config_file" | sed 's/^# Title: //')
        fi
        
        # Assign icons based on config type
        case "$filename" in
            "general")
                icon="⚙️ "
                ;;
            "network")
                icon="🌐 "
                ;;
            "misc")
                icon="🔧 "
                ;;
            "database")
                icon="🗄️ "
                ;;
            "broker")
                icon="📨 "
                ;;
            "services")
                icon="🚀 "
                ;;
            "configs")
                icon="📋 "
                ;;
            "git")
                icon="📦 "
                ;;
            "patcher")
                icon="🔧 "
                ;;
            "world")
                icon="🌍 "
                ;;
            *)
                icon="📄 "
                ;;
        esac
        
        echo "${icon}${title}"
    }

    # Get complexity from config file header
    get_config_complexity() {
        local config_file="$1"
        local complexity=""
        
        # Read the Complexity tag
        if [[ -f "$config_file" ]]; then
            complexity=$(grep "^# Complexity:" "$config_file" | sed 's/^# Complexity: //')
        fi
        
        # Default to Simple if not specified
        if [[ -z "$complexity" ]]; then
            complexity="Simple"
        fi
        
        echo "$complexity"
    }

    while true; do
        clear
        print_header "Configuration Menu"
        echo ""
        
        # Separate configs by complexity
        simple_configs=()
        advanced_configs=()
        
        for config_file in "${menu_config_files[@]}"; do
            if [[ -f "$config_file" ]]; then
                local complexity=$(get_config_complexity "$config_file")
                if [[ "$complexity" == "Advanced" ]]; then
                    advanced_configs+=("$config_file")
                else
                    simple_configs+=("$config_file")
                fi
            fi
        done
        
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ ⚙️ BASIC CONFIGURATION                                   │"
        echo "├─────────────────────────────────────────────────────────┤"
        option_num=1
        for config_file in "${simple_configs[@]}"; do
            if [[ -f "$config_file" ]]; then
                local title_with_icon=$(get_config_title_with_icon "$config_file")
                echo "│ $option_num. $title_with_icon"
                ((option_num++))
            fi
        done
        
        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ 🔧 ADVANCED CONFIGURATION                               │"
        echo "├─────────────────────────────────────────────────────────┤"
        
        for config_file in "${advanced_configs[@]}"; do
            if [[ -f "$config_file" ]]; then
                local title_with_icon=$(get_config_title_with_icon "$config_file")
                echo "│ $option_num. $title_with_icon"
                ((option_num++))
            fi
        done
        
        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ 🚪 NAVIGATION                                           │"
        echo "├─────────────────────────────────────────────────────────┤"
        echo "│ b. ⬅️ Back to Main Menu                                  │"
        echo "│ q. 🚪 Quit                                              │"
        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
        total_options=$((option_num - 1))
        read -p "Enter your choice [1-$total_options, b, q]: " choice
        
        if [[ "$choice" == "q" ]]; then
            print_status "Goodbye!"
            exit 0
        elif [[ "$choice" == "b" ]]; then
            break
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$total_options" ]]; then
            # Combine all configs to get the selected file
            all_configs=("${simple_configs[@]}" "${advanced_configs[@]}")
            selected_file="${all_configs[$((choice - 1))]}"
            
            # Open the selected config file
            "$TEXT_EDITOR" "$selected_file"
            print_status "Configuration file opened in $TEXT_EDITOR editor"
        else
            print_error "Invalid choice"
            read -p "Press Enter to continue..."
        fi
    done
}

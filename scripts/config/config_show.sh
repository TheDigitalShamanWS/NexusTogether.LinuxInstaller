#!/bin/bash

# NexusForever Linux Installer - Show Configuration Function

# Show current configuration from all config files
config_show_config() {
    print_header "Current Configuration"
    
    # Display all config files and their contents
    for config_file in "${SCRIPT_DIR}/../configs"/*.conf; do
        if [[ -f "$config_file" ]]; then
            echo ""
            echo "=== $(basename "$config_file") ==="
            while IFS= read -r line; do
                [[ "$line" =~ ^#.* ]] && continue
                if [[ "$line" =~ ^[[:space:]]*$ ]]; then
                    continue
                fi
                
                # Remove comments and extract variable name and value
                local var_name=$(echo "$line" | cut -d'=' -f1)
                local var_value=$(echo "$line" | cut -d'=' -f2-)
                
                # Handle password display (mask sensitive values)
                if [[ "$var_name" =~ .*PASS.* ]]; then
                    echo "$var_name=********"
                else
                    echo "$var_name=$var_value"
                fi
            done < "$config_file"
        fi
    done
    
    echo ""
    print_status "Configuration display complete"
}

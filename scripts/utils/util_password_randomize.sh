#!/bin/bash

# NexusForever Linux Installer - Password Randomization Utility

# Randomize passwords if they contain placeholder values
util_randomize_config_passwords() {
    local password_changed=false
    
    # Use SCRIPT_DIR if MANAGER_DIR is not set (for setup phase)
    local config_dir="${MANAGER_DIR:-$SCRIPT_DIR}/configs"
    
    # Process all config files
    for config_file in "${config_dir}"/*.conf; do
        if [[ -f "$config_file" ]]; then
            
            # Check for any RANDOM_PASSWORD_ placeholders (1-9)
            if grep -q "RANDOM_PASSWORD_" "$config_file"; then
                print_status "Randomizing passwords in: $(basename "$config_file")"
                
                # Replace each RANDOM_PASSWORD_1-9 with new random passwords
                for i in {1..9}; do
                    local new_pass=$(generate_password 16)
                    sed -i "s/RANDOM_PASSWORD_$i/$new_pass/g" "$config_file"
                done
                
                password_changed=true
                print_status "Generated new random passwords for $(basename "$config_file")"
            fi
        fi
    done
    
    if [[ "$password_changed" == "true" ]]; then
        print_status "Password randomization complete. All passwords have been updated."
    fi
}

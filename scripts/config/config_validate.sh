#!/bin/bash

# NexusForever Linux Installer - Dynamic Configuration Validation Function

# Validate all configuration files dynamically
config_validate_config() {
    local errors=0
    
    # Get all config files
    local validation_config_files=("$MANAGER_DIR/configs"/*.conf)
    
    # Define required variables and their validation patterns
    local required_vars=(
        "SERVICE_USER:string:Service user cannot be empty"
        "BASE_DIR:directory:Base directory cannot be empty"
        "MANAGER_DIR:directory:Manager directory cannot be empty"
        "SERVER_DIR:directory:Server directory cannot be empty"
        "DATABASE_DIR:directory:Database directory cannot be empty"
        "BACKUP_DIR:directory:Backup directory cannot be empty"
        "PATCHER_DIR:directory:Patcher directory cannot be empty"
        "SERVICES_DIR:directory:Services directory cannot be empty"
        "CONFIG_MODE:enum:Build mode must be 'Debug' or 'Release'"
        "FRAMEWORK_VERSION:string:Framework version cannot be empty"
        "DB_USER:string:Database user cannot be empty"
        "DB_PASS:string:Database password cannot be empty"
        "DB_HOST:string:Database host cannot be empty"
        "BROKER_USER:string:Broker user cannot be empty"
        "BROKER_PASS:string:Broker password cannot be empty"
        "BROKER_HOST:string:Broker host cannot be empty"
        "AUTH_SERVER_PORT:port:Auth server port must be 1-65535"
        "WORLD_SERVER_PORT:port:World server port must be 1-65535"
        "API_SERVER_PORT:port:API server port must be 1-65535"
        "SERVICE_MODE:enum:Service mode must be 'screen' or 'direct'"
        "SERVICE_PREFIX:string:Service prefix cannot be empty"
    )
    
    # Optional variables with validation
    local optional_vars=(
        "REMOTE_ACCESS_ENABLED:boolean:Remote access must be 'true' or 'false'"
        "REMOTE_DB_USER:string:Remote database user should be valid"
        "REMOTE_DB_PASS:string:Remote database password should be valid"
        "REMOTE_ACCESS_HOST:string:Remote access host should be valid"
        "BROKER_VHOST:string:Broker vhost should be valid"
        "BROKER_PERMISSIONS_CONF:string:Broker config permissions should be valid"
        "BROKER_PERMISSIONS_READ:string:Broker read permissions should be valid"
        "BROKER_PERMISSIONS_WRITE:string:Broker write permissions should be valid"
        "AUTH_SERVER_PUBLIC:boolean:Auth server public must be 'true' or 'false'"
        "WORLD_SERVER_PUBLIC:boolean:World server public must be 'true' or 'false'"
        "API_SERVER_PUBLIC:boolean:API server public must be 'true' or 'false'"
        "ENABLE_FIREWALL:boolean:Firewall must be 'true' or 'false'"
    )
    
    # Validate each config file
    for config_file in "${validation_config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            source "$config_file"
            
            echo "Validating $(basename "$config_file")..."
            
            # Validate required variables
            for var_def in "${required_vars[@]}"; do
                IFS=':' read -r var_name var_type validation_msg <<< "$var_def"
                
                if [[ -z "${!var_name}" ]]; then
                    print_error "$validation_msg"
                    ((errors++))
                fi
            done
            
            # Validate optional variables
            for var_def in "${optional_vars[@]}"; do
                IFS=':' read -r var_name var_type validation_msg <<< "$var_def"
                
                if [[ -n "${!var_name}" ]]; then
                    case "$var_type" in
                        "string")
                            if [[ -z "${!var_name}" ]]; then
                                print_warning "$var_name should not be empty"
                            fi
                            ;;
                        "ip")
                            if ! validate_ip "${!var_name}"; then
                                print_error "$validation_msg"
                                ((errors++))
                            fi
                            ;;
                        "port")
                            if ! validate_port "${!var_name}"; then
                                print_error "$validation_msg"
                                ((errors++))
                            fi
                            ;;
                        "enum")
                            if [[ ! "${!var_name}" =~ $validation_msg ]]; then
                                print_error "$validation_msg"
                                ((errors++))
                            fi
                            ;;
                        "boolean")
                            if [[ ! "${!var_name}" =~ ^(true|false)$ ]]; then
                                print_error "$validation_msg"
                                ((errors++))
                            fi
                            ;;
                        "integer")
                            if ! [[ "${!var_name}" =~ ^[0-9]+$ ]]; then
                                print_error "$validation_msg"
                                ((errors++))
                            fi
                            ;;
                    esac
                fi
            done
        fi
    done
    
    # Report validation results
    if [[ $errors -gt 0 ]]; then
        print_error "Configuration validation failed with $errors errors"
        return 1
    else
        print_status "Configuration validation passed"
        return 0
    fi
}

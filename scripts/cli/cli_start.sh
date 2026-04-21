#!/bin/bash

# NexusForever CLI Router
# Routes CLI commands to appropriate handler functions

cli_start() {
    local command="$1"
    
    # If no command provided, show default help
    if [[ -z "$command" ]]; then
        cli_default
        exit 0
    fi
    
    shift
    local args=("$@")
    
    case "$command" in
        "install")
            cli_install "${args[@]}"
            ;;
        "config")
            cli_config "${args[@]}"
            ;;
        "service")
            cli_service "${args[@]}"
            ;;
        "backup")
            echo "ERROR: Backup command not implemented yet"
            echo ""
            cli_default
            exit 1
            ;;
        "restore")
            echo "ERROR: Restore command not implemented yet"
            echo ""
            cli_default
            exit 1
            ;;
        "update")
            cli_update "${args[@]}"
            ;;
        "logs")
            echo "ERROR: Logs command not implemented yet"
            echo ""
            cli_default
            exit 1
            ;;
        *)
            echo "ERROR: Unknown command: $command"
            echo ""
            cli_default
            exit 1
            ;;
    esac
}

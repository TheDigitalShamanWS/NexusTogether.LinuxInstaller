#!/bin/bash

# NexusForever CLI Config Handler

cli_config() {
    local action="$1"
    
    cli_config_default() {
        print_header "NexusForever Config Commands"
        echo ""
        echo "Usage: start.sh config <action>"
        echo ""
        echo "Available actions:"
        echo "  show        Display current configuration"
        echo "  validate    Validate configuration files"
        echo ""
        echo "Examples:"
        echo "  start.sh config show"
        echo "  start.sh config validate"
        echo ""
    }
    
    # If no action specified, show available options
    if [[ -z "$action" ]]; then
        cli_config_default
        return 0
    fi
    
    case "$action" in
        "show")
            print_header "Configuration Display"
            echo ""
            config_show_config
            ;;
        "validate")
            print_header "Configuration Validation"
            echo ""
            config_validate_config
            ;;
        *)
            echo "ERROR: Unknown config action: $action"
            echo ""
            cli_config_default
            return 1
            ;;
    esac
}

#!/bin/bash

# NexusForever CLI Update Handler

cli_update() {
    local component="$1"
    
    cli_update_default() {
        print_header "NexusForever Update Commands"
        echo ""
        echo "Usage: start.sh update [component]"
        echo ""
        echo "Available components:"
        echo "  all         Update all components (default)"
        echo "  server      Update Server Core"
        echo "  database    Update World Database"
        echo "  broker      Update Message Broker"
        echo "  configs     Update Configuration Files"
        echo "  patcher     Update Patch Server"
        echo ""
        echo "Note: Update uses idempotent install scripts to safely refresh components"
        echo ""
        echo "Examples:"
        echo "  start.sh update"
        echo "  start.sh update all"
        echo "  start.sh update server"
        echo ""
    }
    
    # If no component specified, default to "all"
    if [[ -z "$component" ]]; then
        component="all"
    fi
    
    case "$component" in
        "all")
            print_header "Updating All Components"
            echo ""
            print_status "Running complete update using idempotent install scripts..."
            echo ""
            
            # Re-run the complete installation
            if install_all; then
                print_status "Update completed successfully!"
                print_status "All components have been refreshed."
            else
                print_error "Update failed. Please check logs."
                return 1
            fi
            ;;
        "server")
            print_header "Updating Server Core"
            echo ""
            print_status "Refreshing server installation..."
            install_server
            ;;
        "database")
            print_header "Updating Database"
            echo ""
            print_status "Refreshing database installation..."
            install_database
            ;;
        "broker")
            print_header "Updating Message Broker"
            echo ""
            print_status "Refreshing broker installation..."
            install_broker
            ;;
        "configs")
            print_header "Updating Configuration Files"
            echo ""
            print_status "Refreshing configuration files..."
            install_configs
            ;;
        "patcher")
            print_header "Updating Patch Server"
            echo ""
            print_status "Refreshing patcher installation..."
            install_patcher
            ;;
        *)
            echo "ERROR: Unknown update component: $component"
            echo ""
            cli_update_default
            return 1
            ;;
    esac
}

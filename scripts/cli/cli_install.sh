#!/bin/bash

# NexusForever CLI Install Handler

cli_install() {
    local component="$1"
    
    cli_install_default() {
        print_header "NexusForever Install Commands"
        echo ""
        echo "Usage: nexusforever install <component>"
        echo ""
        echo "Available components:"
        echo "  all         Complete installation (core + db + broker + configs + services + firewall)"
        echo "  server      Install Server Core (includes patcher)"
        echo "  mariadb     Install MariaDB Server"
        echo "  database    Install Database"
        echo "  broker      Install Message Broker"
        echo "  configs     Install Configuration Files"
        echo "  services    Install Services (Systemd/Screen)"
        echo "  firewall    Install Firewall"
        echo ""
        echo "Examples:"
        echo "  nexusforever install all"
        echo "  nexusforever install server"
        echo "  nexusforever install mariadb"
        echo ""
    }

    # If no component specified, show available options
    if [[ -z "$component" ]]; then
        cli_install_default
        return 0
    fi
    
    case "$component" in
        "all")
            install_all
            ;;
        "server")
            install_server
            ;;
        "mariadb")
            install_mariadb
            ;;
        "database")
            install_database
            ;;
        "broker")
            install_broker
            ;;
        "configs")
            install_configs
            ;;
        "services")
            install_services
            ;;
        "firewall")
            install_firewall
            ;;
        *)
            echo "ERROR: Unknown install component: $component"
            echo ""
            cli_install_default
            return 1
            ;;
        esac
}

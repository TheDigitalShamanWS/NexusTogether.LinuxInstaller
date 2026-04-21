#!/bin/bash

# NexusForever Linux Installer - Firewall Setup Function

# Setup firewall for NexusForever
install_firewall() {
    print_header "Setup Firewall"
    
    if [[ "$ENABLE_FIREWALL" != "true" ]]; then
        print_status "Firewall configuration is disabled"
        return 0
    fi
    
    # Check if UFW is installed
    if ! command -v ufw &> /dev/null; then
        print_error "UFW is not available for firewall management"
        print_status "Please install UFW: sudo apt install ufw"
        return 1
    fi
    
    # Enable UFW if not active
    local ufw_enabled=false
    if ! sudo ufw status | grep -q "Status: active"; then
        print_status "Enabling UFW..."
        if sudo ufw --force enable; then
            print_status "UFW enabled successfully"
            ufw_enabled=true
        else
            print_error "Failed to enable UFW"
            return 1
        fi
    else
        print_status "UFW is already active"
        ufw_enabled=true
    fi
    
    # Configure UFW rules for NexusForever ports
    local ports=("$AUTH_SERVER_PORT" "$WORLD_SERVER_PORT" "$API_SERVER_PORT" "$PATCHER_SERVER_PORT")
    local public_ports=()
    
    # Add ports that should be public
    if [[ "$AUTH_SERVER_PUBLIC" == "true" ]]; then
        public_ports+=("$AUTH_SERVER_PORT")
    fi
    if [[ "$WORLD_SERVER_PUBLIC" == "true" ]]; then
        public_ports+=("$WORLD_SERVER_PORT")
    fi
    if [[ "$API_SERVER_PUBLIC" == "true" ]]; then
        public_ports+=("$API_SERVER_PORT")
    fi
    if [[ "$PATCHER_SERVER_PUBLIC" == "true" ]]; then
        public_ports+=("$PATCHER_SERVER_PORT")
    fi
    
    local rules_updated=0
    local rules_added=0
    local rules_removed=0
    
    print_status "Configuring UFW rules for NexusForever ports..."
    
    # Handle bidirectional port management for all ports
    for port in "${ports[@]}"; do
        # Check current status
        local current_rule_exists=false
        if sudo ufw status verbose | grep -q "$port.*ALLOW.*Anywhere"; then
            current_rule_exists=true
        fi
        
        # Check if this port should be public
        local should_be_public=false
        for public_port in "${public_ports[@]}"; do
            if [[ "$port" == "$public_port" ]]; then
                should_be_public=true
                break
            fi
        done
        
        if [[ "$should_be_public" == "true" ]]; then
            # Port should be open
            if [[ "$current_rule_exists" == "true" ]]; then
                print_status "Port $port is already allowed in UFW"
            else
                print_status "Adding port $port to UFW..."
                if sudo ufw allow "$port/tcp"; then
                    print_status "Port $port opened in UFW"
                    ((rules_added++))
                else
                    print_error "Failed to open port $port in UFW"
                    return 1
                fi
            fi
        else
            # Port should be closed
            if [[ "$current_rule_exists" == "true" ]]; then
                print_status "Removing port $port from UFW (server set to private)..."
                if sudo ufw delete allow "$port/tcp"; then
                    print_status "Port $port removed from UFW"
                    ((rules_removed++))
                else
                    print_error "Failed to remove port $port from UFW"
                    return 1
                fi
            else
                print_status "Port $port is not in UFW rules (server is private)"
            fi
        fi
        ((rules_updated++))
    done
    
    # Reload UFW to apply changes
    if [[ $rules_added -gt 0 || $rules_removed -gt 0 ]]; then
        print_status "Reloading UFW daemon to apply new rules..."
        sudo ufw reload
        print_status "UFW reloaded successfully"
    fi
    
    # Summary
    print_status "Firewall configuration completed"
    print_status "UFW enabled: $ufw_enabled"
    print_status "Rules checked: $rules_updated"
    print_status "Rules added: $rules_added"
    print_status "Rules removed: $rules_removed"
    
    # Check UFW rules for each port
    echo ""
    print_status "Current UFW port status:"
    
    # Check all server ports
    for port in "$AUTH_SERVER_PORT" "$WORLD_SERVER_PORT" "$API_SERVER_PORT"; do
        local service_name="Unknown"
        case $port in
            "$AUTH_SERVER_PORT") service_name="Auth Server" ;;
            "$WORLD_SERVER_PORT") service_name="World Server" ;;
            "$API_SERVER_PORT") service_name="API Server" ;;
        esac
        
        if sudo ufw status verbose | grep -q "$port.*ALLOW.*Anywhere"; then
            echo -e "${GREEN}✓ OPEN${NC} - $service_name port $port is allowed in UFW"
        else
            echo -e "${RED}✗ CLOSED${NC} - $service_name port $port is not allowed in UFW"
        fi
    done
    
    # Check patcher port status
    if sudo ufw status verbose | grep -q "$PATCHER_SERVER_PORT.*ALLOW.*Anywhere"; then
        echo -e "${GREEN}✓ OPEN${NC} - Patcher Server port $PATCHER_SERVER_PORT is allowed in UFW"
    else
        echo -e "${RED}✗ CLOSED${NC} - Patcher Server port $PATCHER_SERVER_PORT is not allowed in UFW"
    fi
    
    echo ""
    print_status "Port accessibility check completed"
    print_status "Note: This checks UFW rules, not actual connectivity."
    
    return 0
}

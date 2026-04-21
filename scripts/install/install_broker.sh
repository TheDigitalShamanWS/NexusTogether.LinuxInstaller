#!/bin/bash

# NexusForever Linux Installer - Message Broker Setup Function

# Setup message broker
install_broker() {
    print_header "Setup Message Broker"
    
    local rabbitmq_installed=false
    local user_created=false
    local vhost_created=false
    local permissions_set=false
    
    # Check if RabbitMQ is installed
    if command -v rabbitmqctl &> /dev/null; then
        print_status "RabbitMQ is already installed"
        rabbitmq_installed=true
        
        # Ensure RabbitMQ is running
        if ! systemctl is-active --quiet rabbitmq-server; then
            print_status "Starting RabbitMQ service..."
            sudo systemctl start rabbitmq-server
            sudo systemctl enable rabbitmq-server
            print_status "RabbitMQ started and enabled"
        else
            print_status "RabbitMQ is already running"
        fi
    else
        print_status "Installing RabbitMQ..."
        sudo apt update
        sudo apt install -y rabbitmq-server
        
        # Start and enable RabbitMQ
        sudo systemctl start rabbitmq-server
        sudo systemctl enable rabbitmq-server
        
        print_status "RabbitMQ installed and started"
        rabbitmq_installed=true
    fi
    
    # Create or update user
    print_status "Checking RabbitMQ user..."
    if sudo rabbitmqctl list_users | grep -q "$BROKER_USER"; then
        print_status "User '$BROKER_USER' already exists, updating password..."
        if sudo rabbitmqctl change_password "$BROKER_USER" "$BROKER_PASS" 2>/dev/null; then
            print_status "User password updated successfully"
            user_created=true
        else
            print_error "Failed to update RabbitMQ user password"
            return 1
        fi
    else
        print_status "Creating RabbitMQ user..."
        if sudo rabbitmqctl add_user "$BROKER_USER" "$BROKER_PASS" 2>/dev/null; then
            print_status "User created successfully"
            user_created=true
        else
            print_error "Failed to create RabbitMQ user"
            return 1
        fi
    fi
    
    # Clean up old vhosts (environment switching)
    local old_vhosts=("nexusforever_dev" "nexusforever_prod")
    for vhost in "${old_vhosts[@]}"; do
        if [[ "$vhost" != "$BROKER_VHOST" ]]; then
            if sudo rabbitmqctl list_vhosts | grep -q "$vhost"; then
                print_status "Removing old vhost: $vhost"
                sudo rabbitmqctl delete_vhost "$vhost" 2>/dev/null
            fi
        fi
    done
    
    # Create virtual host if it doesn't exist
    print_status "Checking RabbitMQ virtual host..."
    if sudo rabbitmqctl list_vhosts | grep -q "$BROKER_VHOST"; then
        print_status "Virtual host '$BROKER_VHOST' already exists"
    else
        print_status "Creating RabbitMQ virtual host..."
        if sudo rabbitmqctl add_vhost "$BROKER_VHOST" 2>/dev/null; then
            print_status "Virtual host created successfully"
            vhost_created=true
        else
            print_error "Failed to create RabbitMQ virtual host"
            return 1
        fi
    fi
    
    # Set permissions
    print_status "Setting up RabbitMQ permissions..."
    if sudo rabbitmqctl set_permissions -p "$BROKER_VHOST" "$BROKER_USER" "$BROKER_PERMISSIONS_CONF" "$BROKER_PERMISSIONS_READ" "$BROKER_PERMISSIONS_WRITE" 2>/dev/null; then
        print_status "RabbitMQ permissions set successfully"
        permissions_set=true
    else
        print_error "Failed to set RabbitMQ permissions"
        return 1
    fi
    
    # Summary
    print_status "Message broker setup completed successfully"
    print_status "RabbitMQ installed: $rabbitmq_installed"
    print_status "User created: $user_created"
    print_status "Virtual host created: $vhost_created"
    print_status "Permissions set: $permissions_set"
    
    return 0
}

#!/bin/bash

# NexusForever Linux Installer - MariaDB Setup Function

# Setup MariaDB server
install_mariadb() {
    print_header "Setup Database Server"
    
    local mariadb_installed=false
    local db_created=false
    local user_created=false
    local remote_user_created=false
    
    # Check if MariaDB is installed
    if command -v mysql &> /dev/null; then
        print_status "MariaDB is already installed"
        mariadb_installed=true
        
        # Ensure MariaDB is running
        if ! systemctl is-active --quiet mariadb; then
            print_status "Starting MariaDB service..."
            sudo systemctl start mariadb
            sudo systemctl enable mariadb
            print_status "MariaDB started and enabled"
        else
            print_status "MariaDB is already running"
        fi
    else
        print_status "Installing MariaDB..."
        sudo apt update
        sudo apt install -y mariadb-server mariadb-client
        
        # Start and enable MariaDB
        sudo systemctl start mariadb
        sudo systemctl enable mariadb
        
        # Ensure unix_socket authentication is enabled (default on most systems)
        print_status "Configuring unix_socket authentication..."
        sudo mysql -e "UPDATE mysql.user SET plugin='unix_socket' WHERE User='root' AND Host='localhost';" 2>/dev/null
        sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null
        
        print_status "MariaDB installed and started with unix_socket authentication"
        mariadb_installed=true
    fi
    
    # Wait for MariaDB to be ready
    print_status "Waiting for MariaDB to be ready..."
    if command -v mysqladmin &> /dev/null; then
        while ! sudo mysqladmin ping -h"$DB_HOST" --silent 2>/dev/null; do
            sleep 1
        done
    else
        # Fallback if mysqladmin not available
        print_status "mysqladmin not found, using alternative check..."
        while ! sudo mysql -e "SELECT 1;" >/dev/null 2>&1; do
            sleep 1
        done
    fi
    
    # Create or update user (as per wiki)
    print_status "Checking database user..."
    if sudo mysql -e "SELECT User FROM mysql.user WHERE User = '$DB_USER';" 2>/dev/null | grep -q "$DB_USER"; then
        print_status "User '$DB_USER' already exists, updating password..."
        if sudo mysql -e "ALTER USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';" 2>/dev/null; then
            print_status "User password updated successfully"
            user_created=true
        else
            print_error "Failed to update database user password"
            return 1
        fi
    else
        print_status "Creating database user..."
        if sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';" 2>/dev/null; then
            print_status "User created successfully"
            user_created=true
        else
            print_error "Failed to create database user"
            return 1
        fi
    fi
    
    # Grant privileges - Grant access to all databases as per wiki
    print_status "Setting up database privileges..."
    if sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_HOST';" 2>/dev/null; then
        print_status "Database privileges granted successfully (all databases)"
    else
        print_error "Failed to grant database privileges"
        return 1
    fi
    
    # Create remote user if enabled
    if [[ "$REMOTE_ACCESS_ENABLED" == "true" ]]; then
        print_status "Setting up remote database access..."
        
        # Configure MariaDB to listen on all interfaces
        local mariadb_conf="/etc/mysql/mariadb.conf.d/50-server.cnf"
        if [[ -f "$mariadb_conf" ]]; then
            print_status "Configuring MariaDB to listen on all interfaces..."
            # Backup the config file
            sudo cp "$mariadb_conf" "${mariadb_conf}.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Change bind-address from 127.0.0.1 to 0.0.0.0
            if sudo sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' "$mariadb_conf"; then
                print_status "MariaDB bind-address updated to 0.0.0.0"
            else
                print_warning "Could not update bind-address, may already be configured"
            fi
            
            # Restart MariaDB to apply changes
            print_status "Restarting MariaDB to apply bind-address changes..."
            sudo systemctl restart mariadb
            sleep 2
        else
            print_warning "MariaDB config file not found at $mariadb_conf"
            print_warning "Please manually configure bind-address to 0.0.0.0"
        fi
        
        if sudo mysql -e "SELECT User FROM mysql.user WHERE User = '$REMOTE_DB_USER';" 2>/dev/null | grep -q "$REMOTE_DB_USER"; then
            print_status "Remote user '$REMOTE_DB_USER' already exists, updating password..."
            if sudo mysql -e "ALTER USER '$REMOTE_DB_USER'@'$REMOTE_ACCESS_HOST' IDENTIFIED BY '$REMOTE_DB_PASS';" 2>/dev/null; then
                print_status "Remote user password updated successfully"
                remote_user_created=true
            else
                print_error "Failed to update remote user password"
                return 1
            fi
        else
            print_status "Creating remote database user..."
            if sudo mysql -e "CREATE USER IF NOT EXISTS '$REMOTE_DB_USER'@'$REMOTE_ACCESS_HOST' IDENTIFIED BY '$REMOTE_DB_PASS';" 2>/dev/null; then
                print_status "Remote user created successfully"
                remote_user_created=true
            else
                print_error "Failed to create remote database user"
                return 1
            fi
        fi
        
        # Grant privileges to remote user (all databases for root-like access)
        if sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$REMOTE_DB_USER'@'$REMOTE_ACCESS_HOST' WITH GRANT OPTION;" 2>/dev/null; then
            print_status "Remote database privileges granted successfully (all databases with GRANT OPTION)"
        else
            print_error "Failed to grant remote database privileges"
            return 1
        fi
    fi
    
    # Flush privileges
    if sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null; then
        print_status "Privileges flushed successfully"
    else
        print_error "Failed to flush privileges"
        return 1
    fi
    
    # Summary
    print_status "Database server setup completed successfully"
    print_status "MariaDB installed: $mariadb_installed"
    print_status "Database created: $db_created"
    print_status "Local user created: $user_created"
    print_status "Remote access enabled: $REMOTE_ACCESS_ENABLED"
    if [[ "$REMOTE_ACCESS_ENABLED" == "true" ]]; then
        print_status "Remote user created: $remote_user_created"
    fi
    
    return 0
}

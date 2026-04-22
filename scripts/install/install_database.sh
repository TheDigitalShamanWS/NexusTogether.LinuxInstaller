#!/bin/bash

# NexusForever Linux Installer - Unified Database Setup Function

# Complete database setup
install_database() {
    print_header "Setup NexusForever Database"
    
    # Check system requirements first
    if ! install_requirements; then
        print_error "System requirements check failed"
        return 1
    fi
    
    # Check if server directory exists (needed for migrations)
    if [[ ! -d "$SERVER_DIR/Source" ]]; then
        print_error "NexusForever source not found. Please install server first."
        return 1
    fi
    
    # Clone database repository if needed
    if [[ -d "$DATABASE_DIR" ]]; then
        print_status "Database directory exists: $DATABASE_DIR"
        print_status "Updating existing database repository..."
        cd "$DATABASE_DIR"
        
        if [[ -d ".git" ]]; then
            print_status "Fetching latest changes from $WORLD_DATABASE_BRANCH..."
            git fetch origin
            
            if git rev-parse HEAD != git rev-parse origin/$WORLD_DATABASE_BRANCH 2>/dev/null; then
                print_status "Pulling latest changes..."
                git pull origin "$WORLD_DATABASE_BRANCH"
                local db_action="updated"
            else
                print_status "Repository is already up to date"
                local db_action="checked"
            fi
        else
            print_error "Directory exists but is not a git repository"
            print_error "Cannot update - please remove directory manually and retry"
            return 1
        fi
    else
        local db_action="fresh_install"
        
        # Create parent directory if it doesn't exist
        local parent_dir=$(dirname "$DATABASE_DIR")
        if [[ ! -d "$parent_dir" ]]; then
            print_status "Creating parent directory: $parent_dir"
            sudo mkdir -p "$parent_dir"
            sudo chown $USER:$USER "$parent_dir"
        fi
        
        # Clone repository
        print_status "Cloning database repository from $WORLD_DATABASE_REPO_URL (branch: $WORLD_DATABASE_BRANCH)..."
        if git clone -b "$WORLD_DATABASE_BRANCH" "$WORLD_DATABASE_REPO_URL" "$DATABASE_DIR"; then
            print_status "Database repository cloned successfully"
            cd "$DATABASE_DIR"
        else
            print_error "Failed to clone database repository"
            return 1
        fi
    fi
    
    # Step 1: Install configuration files first (so EF uses correct database names)
    print_status "Installing configuration files..."
    if install_configs; then
        print_status "Configuration files installed successfully"
    else
        print_error "Configuration installation failed"
        return 1
    fi
    
    # Step 2: Verify dotnet-ef tool is available (installed in requirements)
    print_status "Verifying dotnet-ef tool..."
    if ! sudo -u "$SERVICE_USER" bash -c 'export PATH=$HOME/.dotnet:$HOME/.dotnet/tools:$PATH && export DOTNET_ROOT=$HOME/.dotnet && dotnet-ef --version'; then
        print_error "dotnet-ef tool not found. Please run requirements installation first."
        return 1
    fi
    print_status "dotnet-ef tool verified"
    
    # Step 3: Run Entity Framework migrations (as per wiki)
    print_status "Running Entity Framework migrations..."
    
    # WorldServer migrations
    print_status "Running WorldServer migrations..."
    if sudo -u "$SERVICE_USER" bash -c "export PATH=\$HOME/.dotnet:\$HOME/.dotnet/tools:\$PATH && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$SERVER_DIR/Source/NexusForever.WorldServer' && dotnet-ef database update --context AuthContext --configuration $CONFIG_MODE"; then
        print_status "AuthContext migrations completed successfully"
    else
        print_error "AuthContext migrations failed"
        return 1
    fi

    if sudo -u "$SERVICE_USER" bash -c "export PATH=\$HOME/.dotnet:\$HOME/.dotnet/tools:\$PATH && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$SERVER_DIR/Source/NexusForever.WorldServer' && dotnet-ef database update --context CharacterContext --configuration $CONFIG_MODE"; then
        print_status "CharacterContext migrations completed successfully"
    else
        print_error "CharacterContext migrations failed"
        return 1
    fi

    if sudo -u "$SERVICE_USER" bash -c "export PATH=\$HOME/.dotnet:\$HOME/.dotnet/tools:\$PATH && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$SERVER_DIR/Source/NexusForever.WorldServer' && dotnet-ef database update --context WorldContext --configuration $CONFIG_MODE"; then
        print_status "WorldContext migrations completed successfully"
    else
        print_error "WorldContext migrations failed"
        return 1
    fi
    
    # ChatServer migrations
    print_status "Running ChatServer migrations..."
    if sudo -u "$SERVICE_USER" bash -c "export PATH=\$HOME/.dotnet:\$HOME/.dotnet/tools:\$PATH && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$SERVER_DIR/Source/NexusForever.Server.ChatServer' && dotnet-ef database update --configuration $CONFIG_MODE"; then
        print_status "ChatServer migrations completed successfully"
    else
        print_error "ChatServer migrations failed"
        return 1
    fi
    
    # GroupServer migrations
    print_status "Running GroupServer migrations..."
    if sudo -u "$SERVICE_USER" bash -c "export PATH=\$HOME/.dotnet:\$HOME/.dotnet/tools:\$PATH && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$SERVER_DIR/Source/NexusForever.Server.GroupServer' && dotnet-ef database update --configuration $CONFIG_MODE"; then
        print_status "GroupServer migrations completed successfully"
    else
        print_error "GroupServer migrations failed"
        return 1
    fi
    
    # Step 3: Import world data if available
    print_status "Looking for world data SQL files..."
    cd "$DATABASE_DIR"
    
    # Create import log file in service user's home directory
    local import_log="/home/$SERVICE_USER/.nexusforever_imported_sql.log"
    touch "$import_log"
    chown $SERVICE_USER:$SERVICE_USER "$import_log" 2>/dev/null
    
    # Find and import all SQL files
    local sql_files_found=false
    local new_imports=false
    
    while IFS= read -r -d '' sql_file; do
        local file_hash=$(sha256sum "$sql_file" | cut -d' ' -f1)
        local file_basename=$(basename "$sql_file")
        
        # Check if this file has already been imported
        if grep -q "^${file_basename}|${file_hash}$" "$import_log" 2>/dev/null; then
            print_status "Skipping already imported: $file_basename"
            continue
        fi
        
        print_status "Importing SQL file: $file_basename"
        if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" "$DB_NAME_WORLD" < "$sql_file"; then
            print_status "Successfully imported: $file_basename"
            echo "${file_basename}|${file_hash}" >> "$import_log"
            sql_files_found=true
            new_imports=true
        else
            print_error "Failed to import: $file_basename"
            return 1
        fi
    done < <(find . -type f -name '*.sql' -print0)
    
    if [[ "$new_imports" == true ]]; then
        print_status "New SQL files imported successfully"
    elif [[ "$sql_files_found" == true ]]; then
        print_status "All SQL files were already imported (no new imports needed)"
    elif [[ "$db_action" != "checked" ]]; then
        print_status "No SQL files found for import"
    else
        print_status "No world data import needed (repository was already up to date)"
    fi
    
    # Update server host in auth database
    print_status "Updating server host in auth database..."
    
    # Detect public IP
    local server_host=$(get_public_ip)
    
    if [[ -n "$server_host" ]]; then
        print_status "Using public IP for server host: $server_host"
    else
        print_warning "Could not detect public IP, using localhost"
        server_host="localhost"
    fi
    
    # Update the server table with the correct host
    if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" "$DB_NAME_AUTH" -e "UPDATE server SET host = '$server_host' WHERE id = 1;" 2>/dev/null; then
        print_status "Server host updated to: $server_host"
    else
        print_warning "Failed to update server host in database (may not exist yet or table structure different)"
    fi
    
    print_status "Database setup completed successfully"
    return 0
}

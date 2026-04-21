#!/bin/bash

# NexusForever Linux Installer - Configuration Setup Function (Wiki Compliant)

# Copy configuration files (as per wiki)
install_configs() {
    print_header "Setup Configuration Files"
    
    if [[ ! -d "$SERVER_DIR/Source" ]]; then
        print_error "NexusForever source not found. Please clone and build first."
        return 1
    fi
    
    cd "$SERVER_DIR/Source"
    
    local configs_updated=0
    local build_path="bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
    
    # AuthServer configuration
    if [[ -d "NexusForever.AuthServer/$build_path" ]]; then
        cd "NexusForever.AuthServer/$build_path"
        if [[ -f "AuthServer.example.json" ]]; then
            if [[ -f "AuthServer.json" ]]; then
                print_status "Backing up existing AuthServer.json..."
                sudo cp AuthServer.json "AuthServer.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp AuthServer.example.json AuthServer.json
            
            # Update database connection strings
            print_status "Updating AuthServer configuration..."
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_auth/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_AUTH/g" AuthServer.json
            
            # Update AuthServer port
            sudo sed -i "s/"Port": 23115/"Port": $WORLD_SERVER_PORT/g" AuthServer.json
            
            print_status "AuthServer configuration copied and updated"
            ((configs_updated++))
        else
            print_error "AuthServer.example.json not found"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_error "AuthServer build directory not found: NexusForever.AuthServer/$build_path"
    fi
    
    # StsServer configuration
    if [[ -d "NexusForever.StsServer/$build_path" ]]; then
        cd "NexusForever.StsServer/$build_path"
        if [[ -f "StsServer.example.json" ]]; then
            if [[ -f "StsServer.json" ]]; then
                print_status "Backing up existing StsServer.json..."
                sudo cp StsServer.json "StsServer.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp StsServer.example.json StsServer.json
            
            # Update database connection strings
            print_status "Updating StsServer configuration..."
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_auth/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_AUTH/g" StsServer.json
            
            # Update StsServer port
            sudo sed -i "s/"Port": 6600/"Port": $AUTH_SERVER_PORT/g" StsServer.json
            
            print_status "StsServer configuration copied and updated"
            ((configs_updated++))
        else
            print_error "StsServer.example.json not found"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_error "StsServer build directory not found: NexusForever.StsServer/$build_path"
    fi
    
    # WorldServer configuration
    if [[ -d "NexusForever.WorldServer/$build_path" ]]; then
        cd "NexusForever.WorldServer/$build_path"
        if [[ -f "WorldServer.example.json" ]]; then
            if [[ -f "WorldServer.json" ]]; then
                print_status "Backing up existing WorldServer.json..."
                sudo cp WorldServer.json "WorldServer.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp WorldServer.example.json WorldServer.json
            
            # Update database connection strings
            print_status "Updating WorldServer configuration..."
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_auth/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_AUTH/g" WorldServer.json
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_character/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_CHAR/g" WorldServer.json
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_world/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_WORLD/g" WorldServer.json
            
            # Update message broker connection
            sudo sed -i 's|"amqp://nexusforever:nexusforever@localhost:5672"|"amqp://'$BROKER_USER':'$BROKER_PASS'@'$BROKER_HOST':'$BROKER_PORT'/'$BROKER_VHOST'"|g' WorldServer.json
            
            # Update API server port
            sudo sed -i "s/"Port": 24000/"Port": $API_SERVER_PORT/g" WorldServer.json

            # Update Values from World.conf
            sudo sed -i "s/Welcome to this NexusForever server!/$WORLD_MOTD/g" WorldServer.json
            sudo sed -i 's/"MaxPlayers": 50/"MaxPlayers": '"$WORLD_MAXPLAYERS"'/g' WorldServer.json
            sudo sed -i "s/"CrossFactionChat": true/"CrossFactionChat": '"$WORLD_CROSSFACTIONCHAT"'/g" WorldServer.json

            print_status "WorldServer configuration copied and updated"
            ((configs_updated++))
        else
            print_error "WorldServer.example.json not found"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_error "WorldServer build directory not found: NexusForever.WorldServer/$build_path"
    fi
    
    # ChatServer configuration (if exists)
    if [[ -d "NexusForever.Server.ChatServer/$build_path" ]]; then
        cd "NexusForever.Server.ChatServer/$build_path"
        if [[ -f "ChatServer.example.json" ]]; then
            if [[ -f "ChatServer.json" ]]; then
                print_status "Backing up existing ChatServer.json..."
                sudo cp ChatServer.json "ChatServer.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp ChatServer.example.json ChatServer.json
            
            # Update database connection strings
            print_status "Updating ChatServer configuration..."
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_chat/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_CHAT/g" ChatServer.json
            
            # Update message broker connection
            sudo sed -i 's|"amqp://nexusforever:nexusforever@localhost:5672"|"amqp://'$BROKER_USER':'$BROKER_PASS'@'$BROKER_HOST':'$BROKER_PORT'/'$BROKER_VHOST'"|g' ChatServer.json
            
            print_status "ChatServer configuration copied and updated"
            ((configs_updated++))
        else
            print_error "ChatServer.example.json not found"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_status "ChatServer not found - skipping"
    fi
    
    # GroupServer configuration (if exists)
    if [[ -d "NexusForever.Server.GroupServer/$build_path" ]]; then
        cd "NexusForever.Server.GroupServer/$build_path"
        if [[ -f "GroupServer.example.json" ]]; then
            if [[ -f "GroupServer.json" ]]; then
                print_status "Backing up existing GroupServer.json..."
                sudo cp GroupServer.json "GroupServer.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp GroupServer.example.json GroupServer.json
            
            # Update database connection strings
            print_status "Updating GroupServer configuration..."
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_group/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_GROUP/g" GroupServer.json
            
            # Update message broker connection
            sudo sed -i 's|"amqp://nexusforever:nexusforever@localhost:5672"|"amqp://'$BROKER_USER':'$BROKER_PASS'@'$BROKER_HOST':'$BROKER_PORT'/'$BROKER_VHOST'"|g' GroupServer.json
            
            print_status "GroupServer configuration copied and updated"
            ((configs_updated++))
        else
            print_error "GroupServer.example.json not found"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_status "GroupServer not found - skipping"
    fi
    
    # CharacterAPI configuration
    if [[ -d "NexusForever.API.Character/$build_path" ]]; then
        cd "NexusForever.API.Character/$build_path"
        if [[ -f "CharacterAPI.example.json" ]]; then
            if [[ -f "CharacterAPI.json" ]]; then
                print_status "Backing up existing CharacterAPI.json..."
                sudo cp CharacterAPI.json "CharacterAPI.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp CharacterAPI.example.json CharacterAPI.json
            
            # Update database connection strings
            print_status "Updating CharacterAPI configuration..."
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_auth/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_AUTH/g" CharacterAPI.json
            sudo sed -i "s/server=127.0.0.1;port=3306;user=nexusforever;password=nexusforever;database=nexus_forever_character/server=$DB_HOST;port=$DB_PORT;user=$DB_USER;password=$DB_PASS;database=$DB_NAME_CHAR/g" CharacterAPI.json
            
            print_status "CharacterAPI configuration copied and updated"
            ((configs_updated++))
        else
            print_error "CharacterAPI.example.json not found"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_error "CharacterAPI build directory not found: NexusForever.API.Character/$build_path"
    fi
    
    # Patcher configuration
    if [[ -d "$PATCHER_DIR/Source/Nexus.Patch.Server/$build_path" ]]; then
        cd "$PATCHER_DIR/Source/Nexus.Patch.Server/$build_path"
        if [[ -f "appsettings.example.json" ]]; then
            if [[ -f "appsettings.json" ]]; then
                print_status "Backing up existing appsettings.json..."
                sudo cp appsettings.json "appsettings.json.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            sudo cp appsettings.example.json appsettings.json
            
            # Update patcher configuration
            print_status "Updating patcher configuration..."
            
            # Determine public URL if patcher is public
            local final_url="$PATCHER_URL"
            if [[ "$PATCHER_SERVER_PUBLIC" == "true" ]]; then
                # Check if current URL is localhost and patcher is public
                if [[ "$PATCHER_URL" == *"localhost"* || "$PATCHER_URL" == *"127.0.0.1"* ]]; then
                    print_status "Patcher is public but URL is localhost - detecting public IP..."
                    local public_ip=$(get_public_ip)
                    if [[ -n "$public_ip" ]]; then
                        final_url="http://$public_ip:$PATCHER_SERVER_PORT"
                        print_status "Updated patcher URL to public: $final_url"
                        
                        # Update patcher.conf file with new URL
                        update_patcher_config "PATCHER_URL" "$final_url"
                    else
                        print_warning "Could not detect public IP, keeping localhost URL"
                        print_warning "Please manually update PATCHER_URL in configs/patcher.conf"
                    fi
                fi
            fi
            
            # Update URL with final URL (public IP if detected)
            sudo sed -i "s|\"Url\": \".*\"|\"Url\": \"$final_url\"|g" appsettings.json
            print_status "Updated patcher URL: $final_url"
            
            # Update GameFiles path if PATCHER_GAME_FILES is set
            if [[ -n "$PATCHER_GAME_FILES" ]]; then
                sudo sed -i "s|\"GameFiles\": \".*\"|\"GameFiles\": \"$PATCHER_GAME_FILES\"|g" appsettings.json
                print_status "Updated game files path: $PATCHER_GAME_FILES"
            fi
            
            # Update Build number if PATCHER_BUILD is set
            if [[ -n "$PATCHER_BUILD" ]]; then
                sudo sed -i "s|\"Build\": [0-9]*|\"Build\": $PATCHER_BUILD|g" appsettings.json
                print_status "Updated build number: $PATCHER_BUILD"
            fi
            
            print_status "Patcher configuration copied and updated"
            ((configs_updated++))
        else
            print_error "appsettings.example.json not found"
            print_error "This indicates a build issue - please ensure patcher was built successfully"
        fi
        cd "$SERVER_DIR/Source"
    else
        print_error "Patcher build directory not found: $PATCHER_DIR/Source/Nexus.Patch.Server/$build_path"
    fi
    
    # Summary
    if [[ $configs_updated -gt 0 ]]; then
        print_status "Configuration files setup completed successfully"
        print_status "Updated $configs_updated configuration files"
        print_status "Build path: $build_path"
        return 0
    else
        print_error "No configuration files were updated"
        print_error "Please ensure the server has been built successfully"
        return 1
    fi
}

# Update patcher.conf file
update_patcher_config() {
    local key="$1"
    local value="$2"
    local config_file="$SCRIPT_DIR/../configs/patcher.conf"
    
    if [[ ! -f "$config_file" ]]; then
        print_error "Patcher config file not found: $config_file"
        return 1
    fi
    
    sudo sed -i "s|^$key=.*|$key=\"$value\"|g" "$config_file"
    
    print_status "Updated $key in patcher.conf: $value"
    return 0
}

#!/bin/bash

# NexusForever Linux Installer - Client Data Installation Function

# Install client data files (map and tbl)
install_client_data() {
    print_header "Installing Client Data Files"
    
    # Check if CLIENT_DATA_PATH is set
    if [[ -z "$CLIENT_DATA_PATH" ]]; then
        print_error "CLIENT_DATA_PATH is not configured"
        print_status "Please set CLIENT_DATA_PATH in configs/patcher.conf"
        return 1
    fi
    
    # Check if client data directory exists
    if [[ ! -d "$CLIENT_DATA_PATH" ]]; then
        print_error "Client data directory not found: $CLIENT_DATA_PATH"
        print_status "Please extract client data to this directory"
        return 1
    fi
    
    # Check for required subdirectories
    local map_dir="$CLIENT_DATA_PATH/map"
    local tbl_dir="$CLIENT_DATA_PATH/tbl"
    
    if [[ ! -d "$map_dir" ]]; then
        print_error "map directory not found in: $CLIENT_DATA_PATH"
        print_status "Please ensure client data contains a 'map' folder"
        return 1
    fi
    
    if [[ ! -d "$tbl_dir" ]]; then
        print_error "tbl directory not found in: $CLIENT_DATA_PATH"
        print_status "Please ensure client data contains a 'tbl' folder"
        return 1
    fi
    
    print_status "Client data directory validated: $CLIENT_DATA_PATH"
    print_status "Found map and tbl directories"
    
    # Determine build path
    local build_path="bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
    
    # Check server build directories
    local world_server_dir="$SERVER_DIR/Source/NexusForever.WorldServer/$build_path"
    local chat_server_dir="$SERVER_DIR/Source/NexusForever.Server.ChatServer/$build_path"
    
    if [[ ! -d "$world_server_dir" ]]; then
        print_error "WorldServer build directory not found: $world_server_dir"
        print_status "Please ensure the server has been built successfully"
        return 1
    fi
    
    if [[ ! -d "$chat_server_dir" ]]; then
        print_error "ChatServer build directory not found: $chat_server_dir"
        print_status "Please ensure the server has been built successfully"
        return 1
    fi
    
    # Copy tbl files to WorldServer
    print_status "Copying tbl files to WorldServer..."
    sudo mkdir -p "$world_server_dir/tbl"
    sudo cp "$tbl_dir"/* "$world_server_dir/tbl/" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        print_status "tbl files copied to WorldServer successfully"
    else
        print_warning "No tbl files found or copy failed"
    fi
    
    # Copy tbl files to ChatServer
    print_status "Copying tbl files to ChatServer..."
    sudo mkdir -p "$chat_server_dir/tbl"
    sudo cp "$tbl_dir"/* "$chat_server_dir/tbl/" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        print_status "tbl files copied to ChatServer successfully"
    else
        print_warning "No tbl files found or copy failed"
    fi
    
    # Copy map files to WorldServer
    print_status "Copying map files to WorldServer..."
    sudo mkdir -p "$world_server_dir/map"
    sudo cp "$map_dir"/*.nfmap "$world_server_dir/map/" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        local map_count=$(ls -1 "$world_server_dir/map/"*.nfmap 2>/dev/null | wc -l)
        print_status "map files copied to WorldServer successfully ($map_count maps)"
    else
        print_warning "No map files found or copy failed"
    fi
    
    # Set ownership to service user
    print_status "Setting ownership to service user..."
    sudo chown -R "$SERVICE_USER:$SERVICE_USER" "$world_server_dir/tbl"
    sudo chown -R "$SERVICE_USER:$SERVICE_USER" "$world_server_dir/map"
    sudo chown -R "$SERVICE_USER:$SERVICE_USER" "$chat_server_dir/tbl"
    
    print_status "Client data installation completed successfully"
    return 0
}

#!/bin/bash

# NexusForever Linux Installer - Plugin Setup Function

# Setup plugin development environment
install_plugins() {
    print_header "Setup Plugin Development Environment"

    # Clone plugin repository if configured
    clone_plugin_repo() {
        if [[ -z "$PLUGINS_REPO_URL" ]]; then
            print_status "No plugin repository configured (PLUGINS_REPO_URL is empty)"
            print_status "Skipping repository clone - will use existing plugins in $PLUGINS_DIR"
            return 0
        fi

        print_status "Cloning plugin repository from $PLUGINS_REPO_URL (branch: $PLUGINS_BRANCH)..."
        
        # Check if directory already exists
        if [[ -d "$PLUGINS_DIR" ]]; then
            # Directory exists - update it
            print_status "Updating existing plugin repository..."
            cd "$PLUGINS_DIR"
            
            if [[ -d ".git" ]]; then
                print_status "Fetching latest changes from $PLUGINS_BRANCH..."
                sudo -u "$SERVICE_USER" git fetch origin
                
                if sudo -u "$SERVICE_USER" git rev-parse HEAD != sudo -u "$SERVICE_USER" git rev-parse origin/$PLUGINS_BRANCH 2>/dev/null; then
                    print_status "Pulling latest changes..."
                    sudo -u "$SERVICE_USER" git pull origin "$PLUGINS_BRANCH"
                    print_status "Plugin repository updated"
                else
                    print_status "Plugin repository is already up to date"
                fi
            else
                print_warning "Directory exists but is not a git repository"
                print_warning "Skipping update - will use existing plugins"
            fi
        else
            # Directory doesn't exist - fresh install
            print_status "Cloning plugin repository..."
            local parent_dir=$(dirname "$PLUGINS_DIR")
            if [[ ! -d "$parent_dir" ]]; then
                sudo -u "$SERVICE_USER" mkdir -p "$parent_dir"
            fi
            
            if sudo -u "$SERVICE_USER" git clone -b "$PLUGINS_BRANCH" "$PLUGINS_REPO_URL" "$PLUGINS_DIR"; then
                print_status "Plugin repository cloned successfully"
            else
                print_error "Failed to clone plugin repository"
                return 1
            fi
        fi
        
        return 0
    }

    # Clone plugin repository
    if ! clone_plugin_repo; then
        print_error "Failed to setup plugin repository"
        return 1
    fi

    # Create Plugins directory if it doesn't exist (in case repo clone was skipped)
    if [[ ! -d "$PLUGINS_DIR" ]]; then
        sudo -u "$SERVICE_USER" mkdir -p "$PLUGINS_DIR"
        print_status "Plugins directory created: $PLUGINS_DIR"
    else
        print_status "Plugins directory: $PLUGINS_DIR"
    fi

    # Create runtime Plugins directory
    print_status "Creating runtime Plugins directory..."
    
    if [[ ! -d "$SERVER_DIR/Plugins" ]]; then
        sudo -u "$SERVICE_USER" mkdir -p "$SERVER_DIR/Plugins"
        print_status "Runtime Plugins directory created: $SERVER_DIR/Plugins"
    else
        print_status "Runtime Plugins directory already exists: $SERVER_DIR/Plugins"
    fi

    # Create SDK directory
    print_status "Creating Plugin SDK directory..."
    
    local sdk_dir="$PLUGINS_DIR/SDK"
    
    if [[ ! -d "$sdk_dir" ]]; then
        sudo -u "$SERVICE_USER" mkdir -p "$sdk_dir"
    fi
    
    # Find and copy API DLLs from server build
    print_status "Copying API DLLs from server build..."
    
    local build_dir="$SERVER_DIR/Source/NexusForever.WorldServer/bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
    
    if [[ ! -d "$build_dir" ]]; then
        print_error "Server build directory not found: $build_dir"
        print_error "Please build the server first using install_server"
        return 1
    fi
    
    # Copy required DLLs
    local dlls=(
        "NexusForever.Plugin.dll"
        "NexusForever.Game.Abstract.dll"
        "NexusForever.Shared.dll"
    )
    
    for dll in "${dlls[@]}"; do
        if [[ -f "$build_dir/$dll" ]]; then
            sudo -u "$SERVICE_USER" cp "$build_dir/$dll" "$sdk_dir/"
            print_status "Copied $dll"
        else
            print_warning "DLL not found: $dll"
        fi
    done
    
    # Copy dependency DLLs
    print_status "Copying dependency DLLs..."
    sudo -u "$SERVICE_USER" cp "$build_dir"/*.dll "$sdk_dir/" 2>/dev/null || true
    
    # Build and deploy plugins from PLUGINS_DIR
    build_and_deploy_plugins() {
        print_status "Scanning for plugin projects in $PLUGINS_DIR..."
        
        local plugin_count=0
        
        # Find all .csproj files in PLUGINS_DIR (excluding SDK)
        for csproj in $(find "$PLUGINS_DIR" -maxdepth 2 -name "*.csproj" -not -path "*/SDK/*"); do
            local plugin_dir=$(dirname "$csproj")
            local plugin_name=$(basename "$plugin_dir")
            
            print_status "Found plugin: $plugin_name"
            
            # Add SDK references if not present
            print_status "Adding SDK references to $plugin_name..."
            local needs_reference=false
            
            # Check if SDK references exist
            if ! grep -q "NexusForever.Plugin.dll" "$csproj"; then
                needs_reference=true
            fi
            
            if [[ "$needs_reference" == true ]]; then
                # Add SDK references to .csproj
                sudo -u "$SERVICE_USER" sed -i '/<\/Project>/i\  <ItemGroup>\n    <Reference Include="NexusForever.Plugin">\n      <HintPath>../SDK/NexusForever.Plugin.dll</HintPath>\n    </Reference>\n    <Reference Include="NexusForever.Game.Abstract">\n      <HintPath>../SDK/NexusForever.Game.Abstract.dll</HintPath>\n    </Reference>\n    <Reference Include="NexusForever.Shared">\n      <HintPath>../SDK/NexusForever.Shared.dll</HintPath>\n    </Reference>\n  </ItemGroup>' "$csproj"
                print_status "Added SDK references to $plugin_name"
            else
                print_status "SDK references already present in $plugin_name"
            fi
            
            # Build the plugin
            print_status "Building $plugin_name..."
            if sudo -u "$SERVICE_USER" bash -c "export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_ROOT=\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$plugin_dir' && dotnet build -c $CONFIG_MODE --framework $FRAMEWORK_VERSION"; then
                print_status "Built $plugin_name successfully"
                
                # Copy compiled DLL to runtime Plugins directory
                local output_dir="$plugin_dir/bin/$CONFIG_MODE/$FRAMEWORK_VERSION"
                if [[ -d "$output_dir" ]]; then
                    local plugin_dll=$(find "$output_dir" -name "*.dll" -not -name "*.deps.dll" | head -1)
                    if [[ -n "$plugin_dll" ]]; then
                        sudo -u "$SERVICE_USER" cp "$plugin_dll" "$SERVER_DIR/Plugins/"
                        print_status "Deployed $(basename $plugin_dll) to runtime Plugins directory"
                        plugin_count=$((plugin_count + 1))
                    fi
                fi
            else
                print_warning "Failed to build $plugin_name"
            fi
        done
        
        if [[ $plugin_count -eq 0 ]]; then
            print_status "No plugin projects found in $PLUGINS_DIR"
            print_status "Clone your plugin repositories here to have them built automatically"
        else
            print_status "Built and deployed $plugin_count plugin(s)"
        fi
    }
    
    build_and_deploy_plugins
    
    print_status "Plugin development environment setup completed"
    print_status "Plugin SDK: $PLUGINS_DIR/SDK"
    print_status "Runtime Plugins directory: $SERVER_DIR/Plugins"
    
    return 0
}

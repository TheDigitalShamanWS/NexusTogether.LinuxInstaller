#!/bin/bash

# NexusForever Linux Installer - Clone and Build Server Function

# Clone and build server
install_server() {
    print_header "Setup NexusForever Server"

    # Install server repository
    install_server_repo() {
        print_header "Setup NexusForever Server Repository"
        
        # Check if server directory already exists
        if [[ -d "$SERVER_DIR" ]]; then
            print_status "Server directory exists: $SERVER_DIR"
            print_status "Updating existing repository..."
            cd "$SERVER_DIR"
            
            # Check if we're in a git repository
            if [[ -d ".git" ]]; then
                print_status "Fetching latest changes from $SERVER_BRANCH..."
                git fetch origin
                
                # Check if there are changes to pull
                if git rev-parse HEAD != git rev-parse origin/$SERVER_BRANCH 2>/dev/null; then
                    print_status "Pulling latest changes..."
                    git pull origin "$SERVER_BRANCH"
                    local action_taken="updated"
                else
                    print_status "Repository is already up to date"
                    local action_taken="checked"
                fi
                
                print_status "Updating submodules..."
                git submodule update --init --recursive
                print_status "Submodules updated"
            else
                print_error "Directory exists but is not a git repository"
                print_error "Cannot update - please remove directory manually and retry"
                return 1
            fi
        else
            local action_taken="fresh_install"
        fi
        
        # Create parent directory if it doesn't exist
        local parent_dir=$(dirname "$SERVER_DIR")
        if [[ ! -d "$parent_dir" ]]; then
            print_status "Creating parent directory: $parent_dir"
            sudo mkdir -p "$parent_dir"
            sudo chown $USER:$USER "$parent_dir"
        fi
        
        # Clone repository if needed
        if [[ "$action_taken" == "fresh_install" ]]; then
            print_status "Cloning NexusForever server from $SERVER_REPO_URL (branch: $SERVER_BRANCH)..."
            if git clone -b "$SERVER_BRANCH" "$SERVER_REPO_URL" "$SERVER_DIR"; then
                print_status "Server repository cloned successfully"
                cd "$SERVER_DIR"
                git submodule update --init --recursive
                print_status "Submodules initialized"
            else
                print_error "Failed to clone server repository"
                return 1
            fi
        fi
        
        print_status "Server repository setup completed"
        return 0
    }

    # Install patcher repository
    install_patcher_repo() {
        print_header "Setup NexusForever Patcher Repository"
        
        # Check if directory already exists
        if [[ -d "$PATCHER_DIR" ]]; then
            # Directory exists - update it
            print_status "Updating existing patcher repository..."
            cd "$PATCHER_DIR"
            
            if [[ -d ".git" ]]; then
                print_status "Fetching latest changes from $PATCHER_BRANCH..."
                git fetch origin
                
                if git rev-parse HEAD != git rev-parse origin/$PATCHER_BRANCH 2>/dev/null; then
                    print_status "Pulling latest changes..."
                    git pull origin "$PATCHER_BRANCH"
                    local patcher_action="updated"
                else
                    print_status "Repository is already up to date"
                    local patcher_action="checked"
                fi
            else
                print_error "Directory exists but is not a git repository"
                print_error "Cannot update - remove directory manually for fresh install"
                return 1
            fi
        else
            # Directory doesn't exist - fresh install
            local patcher_action="fresh_install"
        fi
        
        # Clone repository if needed
        if [[ "$patcher_action" == "fresh_install" ]]; then
            # Create parent directory if it doesn't exist
            local parent_dir=$(dirname "$PATCHER_DIR")
            if [[ ! -d "$parent_dir" ]]; then
                print_status "Creating parent directory: $parent_dir"
                sudo mkdir -p "$parent_dir"
                sudo chown $USER:$USER "$parent_dir"
            fi
            
            # Clone repository
            print_status "Cloning NexusForever patcher from $PATCHER_REPO_URL (branch: $PATCHER_BRANCH)..."
            if git clone -b "$PATCHER_BRANCH" "$PATCHER_REPO_URL" "$PATCHER_DIR"; then
                print_status "Patcher repository cloned successfully"
            else
                print_error "Failed to clone patcher repository"
                return 1
            fi
        fi
        
        print_status "Patcher repository setup completed"
        return 0
    }

    # Build patcher using .NET 10
    build_patcher() {
        print_header "Building NexusForever Patcher"
        
        cd "$PATCHER_DIR"
        
        # Check if .NET 10 SDK is available
        if ! sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && command -v dotnet' &> /dev/null; then
            print_error ".NET SDK not found. Please install .NET 10.0 SDK first."
            return 1
        fi
        
        local dotnet_version=$(sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && dotnet --version' 2>/dev/null | grep -o '^10\.[0-9]\+' | head -1)
        if [[ -z "$dotnet_version" ]]; then
            print_error ".NET 10.0 SDK not found. Current version: $(sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && dotnet --version' 2>/dev/null || echo 'unknown')"
            return 1
        fi
        
        print_status "Using .NET $dotnet_version"
        print_status "Building patcher solution ($CONFIG_MODE mode)..."
        
        # Find the correct solution file in Source directory
        local solution_file=""
        if [[ -f "Nexus.Archive.sln" ]]; then
            solution_file="Nexus.Archive.sln"
        elif [[ -f "NexusForever.Patch.sln" ]]; then
            solution_file="NexusForever.Patch.sln"
        elif [[ -f "NexusForever.sln" ]]; then
            solution_file="NexusForever.sln"
        else
            print_error "No patcher solution file found in Source directory. Available files:"
            ls -la *.sln 2>/dev/null || print_error "No .sln files found in Source directory"
            return 1
        fi
        
        print_status "Solution file: $solution_file"
        
        # Update project files to target net10.0
        print_status "Updating patcher projects to target net10.0..."
        local project_files=(
            "src/Nexus.Archive/Nexus.Archive.csproj"
            "src/Nexus.Patch.Server/Nexus.Patch.Server.csproj"
            "src/TableExtractor/TableExtractor.csproj"
            "src/Unarchive/Unarchive.csproj"
            "tests/Nexus.Archive.Tests/Nexus.Archive.Tests.csproj"
        )
        
        for project_file in "${project_files[@]}"; do
            if [[ -f "$project_file" ]]; then
                print_status "Updating $project_file..."
                # Update TargetFramework from net9.0 to net10.0
                sed -i 's/<TargetFramework>net9\.0<\/TargetFramework>/<TargetFramework>net10.0<\/TargetFramework>/g' "$project_file"
            fi
        done
        
        # Clean obj directories to fix target framework issues
        print_status "Cleaning previous build artifacts..."
        if ! sudo -u "$SERVICE_USER" bash -c "export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$PATCHER_DIR' && dotnet clean '$solution_file'"; then
            print_warning "Clean failed, continuing anyway..."
        fi
        
        # Restore dependencies first (required for net10.0 targets)
        print_status "Restoring NuGet packages..."
        if ! sudo -u "$SERVICE_USER" bash -c "export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$PATCHER_DIR' && dotnet restore '$solution_file'"; then
            print_error "Failed to restore NuGet packages"
            return 1
        fi
        
        # Build the solution (now targeting net10.0)
        if [[ "$CONFIG_MODE" == "Release" ]]; then
            build_cmd="sudo -u \"$SERVICE_USER\" bash -c \"export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$PATCHER_DIR' && dotnet publish \"$solution_file\" -c $CONFIG_MODE --framework $FRAMEWORK_VERSION\""
        else
            build_cmd="sudo -u \"$SERVICE_USER\" bash -c \"export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$PATCHER_DIR' && dotnet build \"$solution_file\" -c $CONFIG_MODE --framework $FRAMEWORK_VERSION\""
        fi
        
        if ! eval "$build_cmd"; then
            print_error "Failed to build patcher solution"
            return 1
        fi
        
        print_status "Patcher built successfully"
        return 0
    }

    # Check system requirements first
    if ! install_requirements; then
        print_error "System requirements check failed"
        return 1
    fi
    
    # Install server repository
    if ! install_server_repo; then
        print_error "Failed to setup server repository"
        return 1
    fi
    
    # Install patcher repository
    if ! install_patcher_repo; then
        print_error "Failed to setup patcher repository"
        return 1
    fi
    
    # Build the server
    cd "$SERVER_DIR/Source"
    
    # Check if solution file exists
    if [[ ! -f "NexusForever.slnx" ]]; then
        print_error "NexusForever.slnx not found in $SERVER_DIR/Source"
        print_error "Please check if the repository was cloned correctly"
        return 1
    fi
    
    print_status "Building NexusForever server in $CONFIG_MODE mode..."
    if sudo -u "$SERVICE_USER" bash -c "export PATH=\$PATH:\$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && cd '$SERVER_DIR/Source' && dotnet build NexusForever.slnx -c '$CONFIG_MODE' --framework '$FRAMEWORK_VERSION'"; then
        print_status "Server built successfully in $CONFIG_MODE mode"
        print_status "Framework: $FRAMEWORK_VERSION"
    else
        print_error "Server build failed"
        return 1
    fi
    
    # Build the patcher
    if ! build_patcher; then
        print_error "Failed to build patcher"
        return 1
    fi
    
    print_status "Server and patcher installation completed successfully"
    return 0
}

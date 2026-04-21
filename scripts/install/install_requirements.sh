#!/bin/bash

# NexusForever Linux Installer - Requirements Check Function

# Check system requirements
install_requirements() {
    print_header "Checking System Requirements"
    
    # Ensure .NET cache directories exist with proper permissions
    local dotnet_cache_dir="/home/$SERVICE_USER/.local/share/NuGet"
    if [[ ! -d "$dotnet_cache_dir" ]]; then
        print_status "Creating .NET cache directory..."
        sudo mkdir -p "$dotnet_cache_dir"
        sudo chown "$SERVICE_USER:$SERVICE_USER" "$dotnet_cache_dir"
        sudo chmod 755 "$dotnet_cache_dir"
    fi
    
    # Fix ownership of existing .local directory if needed
    if [[ -d "/home/$SERVICE_USER/.local" ]]; then
        sudo chown -R "$SERVICE_USER:$SERVICE_USER" "/home/$SERVICE_USER/.local"
    fi
    
    # Check if .NET is installed
    if ! command -v dotnet &> /dev/null; then
        print_status ".NET is not installed. Installing .NET 10.0 SDK..."
        print_status "This may take a few minutes..."
        
        # Install .NET SDK directly from Ubuntu repositories
        sudo apt update
        sudo apt install -y dotnet-sdk-10.0
        
        if command -v dotnet &> /dev/null; then
            print_status ".NET 10.0 SDK installed successfully"
        else
            print_error "Failed to install .NET 10.0 SDK"
            return 1
        fi
    fi
    
    # Check if screen is installed
    if ! command -v screen &> /dev/null; then
        print_status "Screen is not installed. Installing screen..."
        sudo apt install -y screen
        
        if command -v screen &> /dev/null; then
            print_status "Screen installed successfully"
        else
            print_error "Failed to install screen"
            return 1
        fi
    fi
    
    # Check .NET version
    local dotnet_version=$(dotnet --version | cut -d. -f1)
    if [[ $dotnet_version -lt 10 ]]; then
        print_error ".NET 10.0 SDK is required. Current version: $(dotnet --version)"
        print_status "Please upgrade your .NET installation"
        return 1
    fi
    
    print_status ".NET version: $(dotnet --version)"
    
    # Install Entity Framework CLI tool (globally as per wiki)
    if ! command -v dotnet-ef &> /dev/null; then
        print_status "Installing Entity Framework CLI tool globally..."
        sudo dotnet tool install dotnet-ef --tool-path /usr/bin
        
        if ! command -v dotnet-ef &> /dev/null; then
            print_error "Failed to install Entity Framework CLI tool"
            return 1
        else
            print_status "Entity Framework CLI tool installed successfully"
        fi
    else
        print_status "Entity Framework CLI tool already installed"
    fi
    
    return 0
}

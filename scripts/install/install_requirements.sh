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
    
    # Install ICU library for .NET globalization support
    if ! dpkg -l | grep -q libicu; then
        print_status "Installing ICU library for .NET globalization support..."
        sudo apt update
        sudo apt install -y libicu-dev
    fi
    
    # Check if .NET is installed
    if ! sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && command -v dotnet' &> /dev/null; then
        print_status ".NET is not installed. Installing .NET 10.0 SDK..."
        print_status "This may take a few minutes..."
        
        # Install .NET 10.0 SDK using Microsoft's official script as service user
        sudo -u "$SERVICE_USER" bash -c 'export DOTNET_CLI_TELEMETRY_OPTOUT=1 && export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version latest --channel 10.0'
        
        # Add .NET to PATH, disable telemetry permanently, and set invariant globalization
        if ! sudo -u "$SERVICE_USER" bash -c 'grep -q ".dotnet" ~/.bashrc'; then
            sudo -u "$SERVICE_USER" bash -c 'echo "export PATH=\$PATH:\$HOME/.dotnet" >> ~/.bashrc'
        fi
        if ! sudo -u "$SERVICE_USER" bash -c 'grep -q "DOTNET_CLI_TELEMETRY_OPTOUT" ~/.bashrc'; then
            sudo -u "$SERVICE_USER" bash -c 'echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1" >> ~/.bashrc'
        fi
        if ! sudo -u "$SERVICE_USER" bash -c 'grep -q "DOTNET_SKIP_FIRST_TIME_EXPERIENCE" ~/.bashrc'; then
            sudo -u "$SERVICE_USER" bash -c 'echo "export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1" >> ~/.bashrc'
        fi
        if ! sudo -u "$SERVICE_USER" bash -c 'grep -q "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT" ~/.bashrc'; then
            sudo -u "$SERVICE_USER" bash -c 'echo "export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1" >> ~/.bashrc'
        fi
        
        if sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && command -v dotnet' &> /dev/null; then
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
    local dotnet_version=$(sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && dotnet --version' | cut -d. -f1)
    if [[ $dotnet_version -lt 10 ]]; then
        print_error ".NET 10.0 SDK is required. Current version: $(sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && dotnet --version')"
        print_status "Please upgrade your .NET installation"
        return 1
    fi
    
    print_status ".NET version: $(sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && dotnet --version')"
    
    # Install Entity Framework CLI tool (locally for service user)
    if ! sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet/tools && command -v dotnet-ef' &> /dev/null; then
        print_status "Installing Entity Framework CLI tool..."
        sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet && export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 && dotnet tool install --global dotnet-ef'
        
        # Add dotnet tools to PATH for service user
        if ! sudo -u "$SERVICE_USER" bash -c 'grep -q ".dotnet/tools" ~/.bashrc'; then
            sudo -u "$SERVICE_USER" bash -c 'echo "export PATH=\$PATH:\$HOME/.dotnet/tools" >> ~/.bashrc'
        fi
        
        # Verify installation with proper PATH
        if sudo -u "$SERVICE_USER" bash -c 'export PATH=$PATH:$HOME/.dotnet/tools && command -v dotnet-ef' &> /dev/null; then
            print_status "Entity Framework CLI tool installed successfully"
        else
            print_error "Failed to install Entity Framework CLI tool"
            return 1
        fi
    else
        print_status "Entity Framework CLI tool already installed"
    fi
    
    return 0
}

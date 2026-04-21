#!/bin/bash

# Get public IP address
get_public_ip() {
    # Try multiple methods to get public IP
    local public_ip=""
    
    # Method 1: curl ifconfig.me
    public_ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null)
    if [[ -n "$public_ip" && "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$public_ip"
        return 0
    fi
    
    # Method 2: curl icanhazip.com
    public_ip=$(curl -s --connect-timeout 5 icanhazip.com 2>/dev/null)
    if [[ -n "$public_ip" && "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$public_ip"
        return 0
    fi
    
    # Method 3: curl ipinfo.io
    public_ip=$(curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null)
    if [[ -n "$public_ip" && "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$public_ip"
        return 0
    fi
    
    # Method 4: Check local network interface (fallback)
    local interface_ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}' 2>/dev/null)
    if [[ -n "$interface_ip" && "$interface_ip" != "127.0.0.1" ]]; then
        echo "$interface_ip"
        return 0
    fi
    
    return 1
}
#!/bin/bash

# NexusForever Linux Installer - Password Utility Function

# Generate random password
generate_password() {
    local length="${1:-16}"
    openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
}

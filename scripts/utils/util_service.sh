#!/bin/bash

# NexusForever Linux Installer - Service Utility Functions

# Check if service is running
is_service_running() {
    local service_name="$1"
    pgrep -f "$service_name" > /dev/null
}

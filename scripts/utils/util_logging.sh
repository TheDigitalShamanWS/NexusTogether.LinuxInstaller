#!/bin/bash

# NexusForever Linux Installer - Logging Utility Function

# Logging function
log() {
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local level="$1"
        shift
        local message="$*"
        
        case "$LOG_LEVEL" in
            "DEBUG")
                echo "$timestamp - [$level] $message" >> "$LOG_FILE"
                ;;
            "INFO")
                if [[ "$level" == "INFO" || "$level" == "WARNING" || "$level" == "ERROR" ]]; then
                    echo "$timestamp - [$level] $message" >> "$LOG_FILE"
                fi
                ;;
            "WARNING")
                if [[ "$level" == "WARNING" || "$level" == "ERROR" ]]; then
                    echo "$timestamp - [$level] $message" >> "$LOG_FILE"
                fi
                ;;
            "ERROR")
                if [[ "$level" == "ERROR" ]]; then
                    echo "$timestamp - [$level] $message" >> "$LOG_FILE"
                fi
                ;;
        esac
    fi
}

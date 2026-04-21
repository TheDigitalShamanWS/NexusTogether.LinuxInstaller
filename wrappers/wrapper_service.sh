#!/bin/bash

# NexusForever Service Wrapper - Simple auto-restart loop

SERVICE_NAME="$1"
SERVICE_PATH="$2"
SERVICE_PROJECT_NAME="$3"

if [[ -z "$SERVICE_NAME" || -z "$SERVICE_PATH" || -z "$SERVICE_PROJECT_NAME" ]]; then
    echo "Usage: $0 <service_name> <service_path> <service_project_name>"
    exit 1
fi

# Simple log file in services directory
LOG_FILE="$SERVICES_DIR/nexus-${SERVICE_NAME}.log"

# Simple restart loop
while :
do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Starting $SERVICE_NAME ===" | tee -a "$LOG_FILE"
    
    # Change to service directory and run executable
    cd "$SERVICE_PATH"
    ./"$SERVICE_PROJECT_NAME" 2>&1 | tee -a "$LOG_FILE"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $SERVICE_NAME crashed! Restarting..." | tee -a "$LOG_FILE"
    sleep 5
done

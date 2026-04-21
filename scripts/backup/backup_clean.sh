#!/bin/bash

# Clean up old backups
cleanup_old_backups() {
    print_header "Clean Old Backups"
    
    local retention_days="${BACKUP_RETENTION_DAYS:-7}"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        print_status "Cleaning up backups older than $retention_days days..."
        local deleted_count=$(find "$BACKUP_DIR" -type d -mtime +$retention_days 2>/dev/null | wc -l)
        find "$BACKUP_DIR" -type d -mtime +$retention_days -exec rm -rf {} + 2>/dev/null
        print_status "Cleaned up $deleted_count backup directories older than $retention_days days"
    else
        print_warning "No backup directory found"
    fi
}

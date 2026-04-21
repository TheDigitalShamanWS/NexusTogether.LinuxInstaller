#!/bin/bash

# Menu Utility Functions
# Provides consistent formatting and helper functions for all menu systems

# Print a menu box header with title
print_menu_box() {
    local title="$1"
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│ $title"
    echo "├─────────────────────────────────────────────────────────┤"
}

# Print a menu option with number, icon, and text
print_menu_option() {
    local number="$1"
    local icon="$2"
    local text="$3"
    #echo "│ $number. $icon $text"
    echo "│ $number. $text"
}

# Print navigation section with customizable back text
print_menu_navigation() {
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│ 🚪 NAVIGATION                                           │"
    echo "├─────────────────────────────────────────────────────────┤"
    echo "│ b. ⬅️ Back                                               │"
    echo "│ q. 🚪 Quit                                              │"
    echo "└─────────────────────────────────────────────────────────┘"
}

# Print menu box footer
print_menu_footer() {
    echo "└─────────────────────────────────────────────────────────┘"
}

# Print a complete menu section
print_menu_section() {
    local title="$1"
    shift
    local options=("$@")
    
    print_menu_box "$title"
    for option in "${options[@]}"; do
        echo "│ $option"
    done
    print_menu_footer
}

# Print a separator line for visual spacing
print_menu_separator() {
    echo ""
}

# Get user choice with validation
get_menu_choice() {
    local prompt="$1"
    local valid_choices="$2"
    local choice
    
    while true; do
        read -p "$prompt" choice
        if [[ "$valid_choices" == *"$choice"* ]]; then
            echo "$choice"
            return 0
        else
            print_error "Invalid choice. Please try again."
        fi
    done
}

# Print a status message in menu format
print_menu_status() {
    local message="$1"
    echo "│ 📊 $message"
}

# Print an error message in menu format  
print_menu_error() {
    local message="$1"
    echo "│ ❌ $message"
}

# Print a success message in menu format
print_menu_success() {
    local message="$1"
    echo "│ ✅ $message"
}

# Print a warning message in menu format
print_menu_warning() {
    local message="$1"
    echo "│ ⚠️  $message"
}

# Print an info message in menu format
print_menu_info() {
    local message="$1"
    echo "│ ℹ️  $message"
}

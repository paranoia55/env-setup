#!/bin/bash

# macOS System Preferences Configuration
# This script configures macOS system preferences using defaults and system commands

# Source common functions
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    LIB_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source "$LIB_DIR/common.sh"

# Configure macOS system preferences
configure_macos() {
    log "INFO" "Configuring macOS system preferences..."
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log "WARN" "macOS configuration skipped - not running on macOS"
        return 0
    fi
    
    # Configure Dock
    configure_dock
    
    # Configure Finder
    configure_finder
    
    # Configure Keyboard
    configure_keyboard
    
    # Configure Trackpad
    configure_trackpad
    
    # Configure Display
    configure_display
    
    # Configure Accessibility
    configure_accessibility
    
    # Configure Date & Time
    configure_datetime
    
    # Configure Sound
    configure_sound
    
    # Configure Energy Saver
    configure_energy_saver
    
    # Configure Security
    configure_security
    
    log "SUCCESS" "macOS system preferences configured"
}

# Configure Dock settings
configure_dock() {
    log "INFO" "Configuring Dock settings..."
    
    # Dock size
    defaults write com.apple.dock tilesize -int "${DOCK_TILESIZE:-48}"
    
    # Dock magnification
    if [ "${DOCK_MAGNIFICATION:-false}" = "true" ]; then
        defaults write com.apple.dock magnification -bool true
    else
        defaults write com.apple.dock magnification -bool false
    fi
    
    # Show recent apps
    if [ "${DOCK_SHOW_RECENTS:-false}" = "true" ]; then
        defaults write com.apple.dock show-recents -bool true
    else
        defaults write com.apple.dock show-recents -bool false
    fi
    
    # Auto-hide dock
    if [ "${DOCK_AUTOHIDE:-true}" = "true" ]; then
        defaults write com.apple.dock autohide -bool true
        defaults write com.apple.dock autohide-delay -float "${DOCK_AUTOHIDE_DELAY:-0}"
        defaults write com.apple.dock autohide-time-modifier -float "${DOCK_AUTOHIDE_TIME_MODIFIER:-0.5}"
    else
        defaults write com.apple.dock autohide -bool false
    fi
    
    # Dock position
    local position="${DOCK_POSITION:-bottom}"
    case "$position" in
        "left")
            defaults write com.apple.dock orientation -string "left"
            ;;
        "right")
            defaults write com.apple.dock orientation -string "right"
            ;;
        "bottom"|*)
            defaults write com.apple.dock orientation -string "bottom"
            ;;
    esac
    
    # Restart Dock
    killall Dock 2>/dev/null || true
}

# Configure Finder settings
configure_finder() {
    log "INFO" "Configuring Finder settings..."
    
    # Show path bar
    if [ "${FINDER_SHOW_PATHBAR:-true}" = "true" ]; then
        defaults write com.apple.finder ShowPathbar -bool true
    else
        defaults write com.apple.finder ShowPathbar -bool false
    fi
    
    # Show status bar
    if [ "${FINDER_SHOW_STATUSBAR:-true}" = "true" ]; then
        defaults write com.apple.finder ShowStatusBar -bool true
    else
        defaults write com.apple.finder ShowStatusBar -bool false
    fi
    
    # Show all file extensions
    if [ "${FINDER_SHOW_ALL_EXTENSIONS:-true}" = "true" ]; then
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    else
        defaults write NSGlobalDomain AppleShowAllExtensions -bool false
    fi
    
    # Show hidden files
    if [ "${FINDER_SHOW_HIDDEN_FILES:-true}" = "true" ]; then
        defaults write com.apple.finder AppleShowAllFiles -bool true
    else
        defaults write com.apple.finder AppleShowAllFiles -bool false
    fi
    
    # Default search scope (SCcf = Current folder)
    defaults write com.apple.finder FXDefaultSearchScope -string "${FINDER_DEFAULT_SEARCH_SCOPE:-SCcf}"
    
    # Restart Finder
    killall Finder 2>/dev/null || true
}

# Configure Keyboard settings
configure_keyboard() {
    log "INFO" "Configuring Keyboard settings..."
    
    # Key repeat rate (0 = Fast, 1 = Medium, 2 = Slow)
    defaults write NSGlobalDomain KeyRepeat -int "${KEYBOARD_REPEAT:-1}"
    
    # Initial key repeat delay (10 = Short, 15 = Medium, 30 = Long)
    defaults write NSGlobalDomain InitialKeyRepeat -int "${KEYBOARD_INITIAL_REPEAT:-15}"
    
    # Disable press and hold for special characters
    if [ "${KEYBOARD_PRESS_AND_HOLD_DISABLED:-true}" = "true" ]; then
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    else
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true
    fi
}

# Configure Trackpad settings
configure_trackpad() {
    log "INFO" "Configuring Trackpad settings..."
    
    # Tap to click
    if [ "${TRACKPAD_TAP_TO_CLICK:-true}" = "true" ]; then
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
        defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    else
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
        defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 0
    fi
    
    # Three finger drag
    if [ "${TRACKPAD_THREE_FINGER_DRAG:-true}" = "true" ]; then
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    else
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
    fi
    
    # Natural scrolling
    if [ "${TRACKPAD_NATURAL_SCROLLING:-true}" = "true" ]; then
        defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
    else
        defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    fi
}

# Configure Display settings
configure_display() {
    log "INFO" "Configuring Display settings..."
    
    # Night Shift
    local night_shift="${DISPLAY_NIGHT_SHIFT:-auto}"
    case "$night_shift" in
        "on")
            defaults write com.apple.CoreBrightness CBBlueLightReductionEnabled -bool true
            ;;
        "off")
            defaults write com.apple.CoreBrightness CBBlueLightReductionEnabled -bool false
            ;;
        "auto"|*)
            # Auto mode (sunset to sunrise) - this is the default
            defaults write com.apple.CoreBrightness CBBlueLightReductionEnabled -bool true
            defaults write com.apple.CoreBrightness CBBlueLightReductionSchedule -bool true
            ;;
    esac
    
    # True Tone
    local true_tone="${DISPLAY_TRUE_TONE:-auto}"
    case "$true_tone" in
        "on")
            defaults write com.apple.CoreBrightness CBTrueToneEnabled -bool true
            ;;
        "off")
            defaults write com.apple.CoreBrightness CBTrueToneEnabled -bool false
            ;;
        "auto"|*)
            # Auto mode - this is the default
            defaults write com.apple.CoreBrightness CBTrueToneEnabled -bool true
            ;;
    esac
    
    # Auto-brightness
    if [ "${DISPLAY_AUTO_BRIGHTNESS:-true}" = "true" ]; then
        defaults write com.apple.CoreBrightness CBBlueLightReductionEnabled -bool true
    else
        defaults write com.apple.CoreBrightness CBBlueLightReductionEnabled -bool false
    fi
}

# Configure Accessibility settings
configure_accessibility() {
    log "INFO" "Configuring Accessibility settings..."
    
    # Reduce motion
    if [ "${ACCESSIBILITY_REDUCE_MOTION:-false}" = "true" ]; then
        defaults write NSGlobalDomain AppleReduceMotion -bool true 2>/dev/null || log "WARN" "Could not set reduce motion (may require accessibility permissions)"
    else
        defaults write NSGlobalDomain AppleReduceMotion -bool false 2>/dev/null || log "WARN" "Could not set reduce motion (may require accessibility permissions)"
    fi
    
    # Reduce transparency
    if [ "${ACCESSIBILITY_REDUCE_TRANSPARENCY:-false}" = "true" ]; then
        defaults write NSGlobalDomain AppleReduceTransparency -bool true 2>/dev/null || log "WARN" "Could not set reduce transparency (may require accessibility permissions)"
    else
        defaults write NSGlobalDomain AppleReduceTransparency -bool false 2>/dev/null || log "WARN" "Could not set reduce transparency (may require accessibility permissions)"
    fi
    
    # Increase contrast
    if [ "${ACCESSIBILITY_INCREASE_CONTRAST:-false}" = "true" ]; then
        defaults write NSGlobalDomain AppleIncreaseContrast -bool true 2>/dev/null || log "WARN" "Could not set increase contrast (may require accessibility permissions)"
    else
        defaults write NSGlobalDomain AppleIncreaseContrast -bool false 2>/dev/null || log "WARN" "Could not set increase contrast (may require accessibility permissions)"
    fi
}

# Configure Date & Time settings
configure_datetime() {
    log "INFO" "Configuring Date & Time settings..."
    
    # Set time zone automatically
    if [ "${DATETIME_SET_TIMEZONE_AUTO:-true}" = "true" ]; then
        sudo systemsetup -setusingnetworktime on 2>/dev/null || true
    else
        sudo systemsetup -setusingnetworktime off 2>/dev/null || true
    fi
    
    # Show date and time in menu bar
    if [ "${DATETIME_SHOW_IN_MENUBAR:-true}" = "true" ]; then
        defaults write com.apple.menuextra.clock IsAnalog -bool false
        defaults write com.apple.menuextra.clock ShowDate -bool true
        defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
    else
        defaults write com.apple.menuextra.clock IsAnalog -bool false
        defaults write com.apple.menuextra.clock ShowDate -bool false
        defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false
    fi
    
    # 24-hour format
    if [ "${DATETIME_24_HOUR_FORMAT:-false}" = "true" ]; then
        defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
    else
        defaults write NSGlobalDomain AppleICUForce24HourTime -bool false
    fi
}

# Configure Sound settings
configure_sound() {
    log "INFO" "Configuring Sound settings..."
    
    # Show volume in menu bar
    if [ "${SOUND_SHOW_VOLUME_MENUBAR:-true}" = "true" ]; then
        defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Volume.menu"
    fi
    
    # Play sound effects
    if [ "${SOUND_PLAY_EFFECTS:-true}" = "true" ]; then
        defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -bool true
    else
        defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -bool false
    fi
    
    # Play feedback when volume is changed
    if [ "${SOUND_PLAY_VOLUME_FEEDBACK:-true}" = "true" ]; then
        defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool true
    else
        defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false
    fi
}

# Configure Energy Saver settings
configure_energy_saver() {
    log "INFO" "Configuring Energy Saver settings..."
    
    # Prevent computer from sleeping when display is off
    if [ "${ENERGY_PREVENT_SLEEP:-false}" = "true" ]; then
        sudo pmset -a sleep 0 2>/dev/null || true
    else
        sudo pmset -a sleep 1 2>/dev/null || true
    fi
    
    # Put hard disks to sleep when possible
    if [ "${ENERGY_PUT_DISKS_TO_SLEEP:-true}" = "true" ]; then
        sudo pmset -a disksleep 10 2>/dev/null || true
    else
        sudo pmset -a disksleep 0 2>/dev/null || true
    fi
    
    # Wake for network access
    if [ "${ENERGY_WAKE_FOR_NETWORK:-true}" = "true" ]; then
        sudo pmset -a womp 1 2>/dev/null || true
    else
        sudo pmset -a womp 0 2>/dev/null || true
    fi
}

# Configure Security settings
configure_security() {
    log "INFO" "Configuring Security settings..."
    
    # Require password immediately after sleep
    if [ "${SECURITY_REQUIRE_PASSWORD_IMMEDIATELY:-true}" = "true" ]; then
        defaults write com.apple.screensaver askForPassword -int 1
        defaults write com.apple.screensaver askForPasswordDelay -int 0
    else
        defaults write com.apple.screensaver askForPassword -int 0
    fi
    
    # Allow apps from (requires admin privileges)
    local allow_apps="${SECURITY_ALLOW_APPS_FROM:-AppStoreAndIdentifiedDevelopers}"
    case "$allow_apps" in
        "AppStore")
            sudo spctl --master-disable 2>/dev/null || true
            sudo spctl --enable 2>/dev/null || true
            ;;
        "AppStoreAndIdentifiedDevelopers")
            sudo spctl --master-disable 2>/dev/null || true
            sudo spctl --enable 2>/dev/null || true
            ;;
        "Anywhere")
            sudo spctl --master-disable 2>/dev/null || true
            ;;
    esac
    
    # FileVault (ask user)
    local filevault="${SECURITY_ENABLE_FILEVAULT:-ask_user}"
    if [ "$filevault" = "ask_user" ]; then
        log "INFO" "FileVault configuration requires user interaction"
        log "INFO" "Please enable FileVault manually in System Preferences > Security & Privacy > FileVault"
    elif [ "$filevault" = "true" ]; then
        log "INFO" "Enabling FileVault (requires admin privileges)..."
        sudo fdesetup enable 2>/dev/null || log "WARN" "Failed to enable FileVault - may require manual setup"
    fi
}

# Test macOS configuration
test_macos_config() {
    log "INFO" "Testing macOS configuration..."
    
    # Test Dock settings
    local dock_size
    dock_size=$(defaults read com.apple.dock tilesize 2>/dev/null || echo "not set")
    log "INFO" "Dock size: $dock_size"
    
    # Test Finder settings
    local show_pathbar
    show_pathbar=$(defaults read com.apple.finder ShowPathbar 2>/dev/null || echo "not set")
    log "INFO" "Finder show pathbar: $show_pathbar"
    
    # Test Keyboard settings
    local key_repeat
    key_repeat=$(defaults read NSGlobalDomain KeyRepeat 2>/dev/null || echo "not set")
    log "INFO" "Keyboard repeat rate: $key_repeat"
    
    log "SUCCESS" "macOS configuration test completed"
}

# Main function
main() {
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" = "${0}" ]; then
        # Script is being executed directly
        load_config "${CONFIG_FILE:-config.yaml}"
        configure_macos
        test_macos_config
    fi
}

# Run main function if script is executed directly
main "$@"

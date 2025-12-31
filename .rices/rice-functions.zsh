#!/bin/zsh

# ==========================================
# RICE MANAGEMENT SYSTEM (SIMPLIFIED)
# ==========================================

# Configuration (single source of truth)
readonly RICES_DIR="$HOME/.rices"
readonly CONFIG_DIR="$HOME/.config"
readonly STATE_FILE="$RICES_DIR/.rice"

# Apps to link (only config folders inside bspwm/)
local -r LINK_APPS=(
    "alacritty"
    "betterlockscreen"
    "btop"
    "cava"
    "dunst"
    "eww"
    "geany"
    "kitty"
    "vicinae"
    "pomodorolm"
    "rofi"
    "deadd"
)

# ==========================================
# UTILITY: Get/Set Current Rice
# ==========================================
get_current_rice() {
    cat "$STATE_FILE" 2>/dev/null || echo ""
}

set_current_rice() {
    echo "$1" > "$STATE_FILE"
}

# ==========================================
# CORE: Unlink Satellites
# ==========================================
unlink_satellites() {
    echo "🔗 Unlinking Satellites..."
    
    # Unlink all config apps
    for app in "${LINK_APPS[@]}"; do
        [ -L "$CONFIG_DIR/$app" ] && rm "$CONFIG_DIR/$app" && echo "   ✓ $app"
    done
    
    # Unlink the Hub
    [ -L "$CONFIG_DIR/bspwm" ] && rm "$CONFIG_DIR/bspwm" && echo "   ✓ bspwm (Hub)"
}

# ==========================================
# CORE: Link Satellites
# ==========================================
link_satellites() {
    local rice_name=$1
    local bspwm_path="$RICES_DIR/$rice_name/bspwm"
    
    echo "🔗 Linking Satellites to: $rice_name"
    
    # STEP 1: Link the Hub (Master Link)
    if [ ! -d "$bspwm_path" ]; then
        echo "   ❌ Error: $bspwm_path does not exist"
        return 1
    fi
    ln -s "$bspwm_path" "$CONFIG_DIR/bspwm"
    echo "   ✓ Hub: bspwm"
    
    # STEP 2: Link Config Apps (pointing into the Hub)
    for app in "${LINK_APPS[@]}"; do
        if [ -d "$bspwm_path/$app" ]; then
            ln -s "$CONFIG_DIR/bspwm/$app" "$CONFIG_DIR/$app"
            echo "   ✓ $app"
        fi
    done
    
    echo "   ✅ All satellites linked"
}

# ==========================================
# CORE: Reload System
# ==========================================
reload_rice() {
    echo "⚡ Reloading Configuration..."
    
    # Reload hotkeys
    pkill sxhkd && echo "   ✓ sxhkd killed"
    pkill polybar && echo "   ✓ polybar killed"


    
    # Reload notifications
    pkill dunst && echo "   ✓ dunst killed"
    sleep 0.1
    dunst > /dev/null 2>&1 &
    echo "   ✓ dunst"
    # Reload window manager
    bspc wm -r 2>/dev/null && echo "   ✓ bspwm reloaded."
    echo "   ✅ Reloaded the rice"
}

# ==========================================
# MAIN: Switch Rice
# ==========================================
switch_rice() {
    local rice_name=$1
    
    # Validation
    if [ -z "$rice_name" ]; then
        echo "❌ Usage: switch_rice <rice-name>"
        list_rices
        return 1
    fi
    
    if [ ! -d "$RICES_DIR/$rice_name" ]; then
        echo "❌ Error: Rice '$rice_name' not found"
        return 1
    fi
    
    # If already active, skip
    if [ "$(get_current_rice)" = "$rice_name" ]; then
        echo "ℹ️  Already using: $rice_name"
        return 0
    fi
    
    echo "🔄 Switching to: $rice_name"
    notify-send "BSPWM RiceSwitcher 🎨" "Don't you like this rice? Few seconds, you will jump into another rabittt hole : $rice_name" -u "critical"
    unlink_satellites || return 1
    link_satellites "$rice_name" || return 1
    set_current_rice "$rice_name"
    sleep 3
    reload_rice
    
    echo "✅ Successfully switched to: $rice_name"
}

# ==========================================
# UTILITY: List Rices
# ==========================================
list_rices() {
    local current=$(get_current_rice)
    local rices=()
    
    # Collect all valid rice directories
    for item in "$RICES_DIR"/*; do
        if [ -d "$item" ] && [ -d "$item/bspwm" ]; then
            rices+=("$(basename "$item")")
        fi
    done
    
    if [ ${#rices[@]} -eq 0 ]; then
        echo "❌ No rices found in $RICES_DIR"
        return 1
    fi
    
    echo "📁 Available Rices:"
    echo ""
    
    for rice in $(printf '%s
' "${rices[@]}" | sort); do
        if [ "$rice" = "$current" ]; then
            printf "   ✓ %-25s (active)
" "$rice"
        else
            printf "   • %-25s
" "$rice"
        fi
    done
    
    echo ""
}

# ==========================================
# UTILITY: Show Current Rice
# ==========================================
show_current_rice() {
    local current=$(get_current_rice)
    if [ -n "$current" ]; then
        echo "🎨 Current Rice: $current"
    else
        echo "⚠️  No rice currently set"
    fi
}

# ==========================================
# UTILITY: Verify Links
# ==========================================
verify_links() {
    local current=$(get_current_rice)
    local broken=0
    
    echo "🔍 Verifying Links..."
    echo "Active Rice: $current"
    echo ""
    
    # Check Hub
    if [ -L "$CONFIG_DIR/bspwm" ]; then
        if [ -e "$CONFIG_DIR/bspwm" ]; then
            echo "   ✓ bspwm"
        else
            echo "   ❌ bspwm → BROKEN"
            ((broken++))
        fi
    else
        echo "   ❌ bspwm → NOT A SYMLINK"
        ((broken++))
    fi
    
    # Check Satellites
    for app in "${LINK_APPS[@]}"; do
        if [ -L "$CONFIG_DIR/$app" ]; then
            if [ -e "$CONFIG_DIR/$app" ]; then
                echo "   ✓ $app"
            else
                echo "   ❌ $app → BROKEN"
                ((broken++))
            fi
        fi
    done
    
    echo ""
    if [ $broken -eq 0 ]; then
        echo "✅ All links are valid"
    else
        echo "⚠️  Found $broken broken link(s)"
        echo "Run: switch_rice $current"
        echo "none" > ~/.rices/.rice
        return 1
    fi
}

# ==========================================
# UTILITY: Show Help
# ==========================================
rice_help() {
    cat << EOF
🎨 Rice Management Commands:

  switch_rice <name>    Switch to a specific rice
  list_rices            List all available rices
  show_current_rice     Show the active rice
  verify_links          Check if all links are valid
  rice_help             Show this help message

Examples:
  switch_rice catppuccin
  list_rices
  verify_links

EOF
}

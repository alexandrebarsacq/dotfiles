#!/bin/bash
# Save as ~/.config/sway/swaybar-script.sh and make executable with chmod +x

# Function to get battery status
battery() {
    local BAT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
    local STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    
    local ICON=""
    if [[ "$STATUS" == "Charging" ]]; then
        ICON="⚡"
    elif (( BAT >= 90 )); then
        ICON="󰁹"
    elif (( BAT >= 75 )); then
        ICON="󰂀"
    elif (( BAT >= 50 )); then
        ICON="󰁿"
    elif (( BAT >= 25 )); then
        ICON="󰁾"
    else
        ICON="󰁻"
    fi
    
    echo "$ICON $BAT%"
}

# Function to get CPU usage
cpu_usage() {
    local CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    
    # Select icon based on CPU load
    local ICON="󰘚"  # Default CPU icon
    if (( $(echo "$CPU > 80" | bc -l) )); then
        ICON="󰓅"  # High CPU load
    elif (( $(echo "$CPU > 50" | bc -l) )); then
        ICON="󰾆"  # Low-medium CPU load
    fi 
    # Colorize if CPU is high
    if (( $(echo "$CPU > 80" | bc -l) )); then
        printf "<span color='#FF5555'>%s %.1f%%</span>" "$ICON" "$CPU"
    else
        printf "%s %.1f%%" "$ICON" "$CPU"
    fi
}

# Function to get memory usage
memory() {
    local TOTAL=$(free -m | awk '/Mem/{print $2}')
    local USED=$(free -m | awk '/Mem/{print $3}')
    local PERCENTAGE=$((USED * 100 / TOTAL))
    
    # Select icon based on memory usage
    local ICON="󰍛"  # Default memory icon
    if (( PERCENTAGE > 80 )); then
        ICON="󰍛"  # High memory usage
    elif (( PERCENTAGE > 50 )); then
        ICON="󰘚"  # Medium memory usage
    elif (( PERCENTAGE > 20 )); then
        ICON="󱘲"  # Low memory usage
    fi
    
    # Colorize if memory usage is high
    if (( PERCENTAGE > 80 )); then
        echo "<span color='#FF5555'>$ICON $PERCENTAGE%</span>"
    else
        echo "$ICON $PERCENTAGE%"
    fi
}
# Network status
network() {
    local WIFI=$(grep "^\s*w" /proc/net/wireless | awk '{ print int($3 * 100 / 70) "%" }')
    local ETH=$(cat /sys/class/net/e*/operstate 2>/dev/null)
    
    if [[ -n "$WIFI" ]]; then
        echo "󰖩 $WIFI"
    elif [[ "$ETH" == "up" ]]; then
        echo "󰈀 Connected"
    else
        echo "󰈂 Disconnected"
    fi
}

# Function to get current volume
volume() {
    local VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1)
    local MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)')
    
    if [[ "$MUTE" == "yes" ]]; then
        echo "󰖁 Muted"
    else
        if (( VOL >= 70 )); then
            echo "󰕾 $VOL%"
        elif (( VOL >= 30 )); then
            echo "󰖀 $VOL%"
        else
            echo "󰕿 $VOL%"
        fi
    fi
}



# Date and time
clock() {
    LC_TIME=fr_FR.UTF-8 date +"󰃰 %Y-%m-%d  󱑏 %H:%M"
}

# Current player status
media_player() {
    if command -v playerctl &>/dev/null; then
        local STATUS=$(playerctl status 2>/dev/null)
        if [[ "$STATUS" == "Playing" ]]; then
            local ARTIST=$(playerctl metadata artist 2>/dev/null | cut -c 1-15)
            local TITLE=$(playerctl metadata title 2>/dev/null | cut -c 1-20)
            echo "󰎆 $ARTIST - $TITLE"
        elif [[ "$STATUS" == "Paused" ]]; then
            echo "󰏤 Paused"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Weather (requires curl and jq)
# weather() {
#     if command -v curl &>/dev/null && command -v jq &>/dev/null; then
#         # Update this every hour in a separate file and read from there
#         local WEATHER_CACHE="/tmp/weather_cache"
#         if [[ ! -f "$WEATHER_CACHE" ]] || [[ $(find "$WEATHER_CACHE" -mmin +60 -print) ]]; then
#             curl -s "https://wttr.in/?format=j1" > "$WEATHER_CACHE" 2>/dev/null
#         fi
#         
#         if [[ -f "$WEATHER_CACHE" ]]; then
#             local TEMP=$(jq -r '.current_condition[0].temp_C' "$WEATHER_CACHE" 2>/dev/null)
#             local CONDITION=$(jq -r '.current_condition[0].weatherDesc[0].value' "$WEATHER_CACHE" 2>/dev/null)
#             
#             if [[ -n "$TEMP" && -n "$CONDITION" ]]; then
#                 echo "󰖐 ${TEMP}°C, ${CONDITION}"
#             else
#                 echo ""
#             fi
#         else
#             echo ""
#         fi
#     else
#         echo ""
#     fi
# }

weather() {
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        # Update this every hour in a separate file and read from there
        local WEATHER_CACHE="/tmp/weather_cache"
        if [[ ! -f "$WEATHER_CACHE" ]] || [[ $(find "$WEATHER_CACHE" -mmin +60 -print) ]]; then
            curl -s "https://wttr.in/?format=j1" > "$WEATHER_CACHE" 2>/dev/null
        fi
        
        if [[ -f "$WEATHER_CACHE" ]]; then
            # Current weather data
            local TEMP=$(jq -r '.current_condition[0].temp_C' "$WEATHER_CACHE" 2>/dev/null)
            local CONDITION=$(jq -r '.current_condition[0].weatherDesc[0].value' "$WEATHER_CACHE" 2>/dev/null)
            local HUMIDITY=$(jq -r '.current_condition[0].humidity' "$WEATHER_CACHE" 2>/dev/null)
            
            # Rain data for today
            local PRECIP_MM=$(jq -r '.weather[0].hourly[0].precipMM' "$WEATHER_CACHE" 2>/dev/null)
            local CHANCE_OF_RAIN=$(jq -r '.weather[0].hourly[0].chanceofrain' "$WEATHER_CACHE" 2>/dev/null)
            local MAX_RAIN_CHANCE=0
            
            # Get maximum chance of rain for today (checking all hourly forecasts)
            for hour in {0..7}; do
                local HOUR_RAIN=$(jq -r ".weather[0].hourly[$hour].chanceofrain" "$WEATHER_CACHE" 2>/dev/null)
                if [[ -n "$HOUR_RAIN" && "$HOUR_RAIN" -gt "$MAX_RAIN_CHANCE" ]]; then
                    MAX_RAIN_CHANCE=$HOUR_RAIN
                fi
            done
            
            # Weather icon based on condition
            local WEATHER_ICON="󰖐"
            if [[ "$CONDITION" == *"rain"* || "$CONDITION" == *"Rain"* || "$CONDITION" == *"drizzle"* || "$CONDITION" == *"Drizzle"* ]]; then
                WEATHER_ICON="󰖗"
            elif [[ "$CONDITION" == *"snow"* || "$CONDITION" == *"Snow"* ]]; then
                WEATHER_ICON="󰖘"
            elif [[ "$CONDITION" == *"cloud"* || "$CONDITION" == *"Cloud"* || "$CONDITION" == *"overcast"* || "$CONDITION" == *"Overcast"* ]]; then
                WEATHER_ICON="󰖐"
            elif [[ "$CONDITION" == *"sun"* || "$CONDITION" == *"Sun"* || "$CONDITION" == *"clear"* || "$CONDITION" == *"Clear"* ]]; then
                WEATHER_ICON="󰖙"
            fi
            
            # Rain indicator for today with color coding
            local RAIN_INDICATOR=""
            if [[ "$MAX_RAIN_CHANCE" -gt 0 ]]; then
                # Rain icon with chance percentage and color
                if [[ "$MAX_RAIN_CHANCE" -ge 70 ]]; then
                    # Red for high chance
                    RAIN_INDICATOR=" | <span color='#FF5555'>󰖖 ${MAX_RAIN_CHANCE}%</span>"
                elif [[ "$MAX_RAIN_CHANCE" -ge 40 ]]; then
                    # Orange/yellow for medium chance
                    RAIN_INDICATOR=" | <span color='#F1FA8C'>󰖔 ${MAX_RAIN_CHANCE}%</span>"
                elif [[ "$MAX_RAIN_CHANCE" -ge 10 ]]; then
                    # Blue for low chance
                    RAIN_INDICATOR=" | <span color='#8BE9FD'>󰖑 ${MAX_RAIN_CHANCE}%</span>"
                fi
            else
                    RAIN_INDICATOR=" | 󰖖 ${MAX_RAIN_CHANCE}%"
            fi
            
            if [[ -n "$TEMP" && -n "$CONDITION" ]]; then
                echo "${WEATHER_ICON} ${TEMP}°C, ${CONDITION}${RAIN_INDICATOR}"
            else
                echo ""
            fi
        else
            echo ""
        fi
    else
        echo ""
    fi
}


# System updates indicator
system_updates() {
    if command -v apt &>/dev/null; then
        # For Debian/Ubuntu based systems
        local UPDATES_CACHE="/tmp/updates_cache"
        # Update cache once every 3 hours
        if [[ ! -f "$UPDATES_CACHE" ]] || [[ $(find "$UPDATES_CACHE" -mmin +180 -print) ]]; then
            apt-get update -qq &>/dev/null
            apt-get --just-print upgrade 2>&1 | grep "^Inst" | wc -l > "$UPDATES_CACHE"
        fi
        
        local UPDATES=$(cat "$UPDATES_CACHE")
        if [[ "$UPDATES" -gt 0 ]]; then
            echo "󰚰 $UPDATES"
        fi
    elif command -v pacman &>/dev/null; then
        # For Arch-based systems
        local UPDATES_CACHE="/tmp/updates_cache"
        # Update cache once every 3 hours
        if [[ ! -f "$UPDATES_CACHE" ]] || [[ $(find "$UPDATES_CACHE" -mmin +180 -print) ]]; then
            pacman -Sy &>/dev/null
            pacman -Qu | wc -l > "$UPDATES_CACHE"
        fi
        
        local UPDATES=$(cat "$UPDATES_CACHE")
        if [[ "$UPDATES" -gt 0 ]]; then
            echo "󰚰 $UPDATES"
        fi
    fi
}

# Disk space indicator
disk_space() {
    local ROOT_USAGE=$(df -h / | awk 'NR==2 {print $5}')
    local HOME_USAGE=$(df -h $HOME | awk 'NR==2 {print $5}')
    
    # Only show if getting full (>80%)
    local ROOT_PCT=${ROOT_USAGE%\%}
    local HOME_PCT=${HOME_USAGE%\%}
    
    if [[ "$ROOT_PCT" -gt 90 || "$HOME_PCT" -gt 90 ]]; then
        echo "<span color='#FF5555'>󰋊 $ROOT_USAGE</span>"
    elif [[ "$ROOT_PCT" -gt 80 || "$HOME_PCT" -gt 80 ]]; then
        echo "<span color='#F1FA8C'>󰋊 $ROOT_USAGE</span>"
    else
        echo ""
    fi
}

# CPU temperature
cpu_temp() {
    if [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
        local TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP=$((TEMP/1000))
        
        # Color based on temperature
        if [[ "$TEMP" -gt 80 ]]; then
            echo "<span color='#FF5555'>󰔏 ${TEMP}°C</span>"
        elif [[ "$TEMP" -gt 60 ]]; then
            echo "<span color='#F1FA8C'>󰔏 ${TEMP}°C</span>"
        else
            echo "󰔏 ${TEMP}°C"
        fi
    fi
}

# Keyboard layout
keyboard_layout() {
    local LAYOUT=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name' | head -1)
    if [[ -n "$LAYOUT" ]]; then
        # Extract just the language code if it's a complex string
        LAYOUT=$(echo "$LAYOUT" | cut -d'(' -f1 | xargs)
        echo "󰌌 $LAYOUT"
    fi
}

# VPN status
vpn_status() {
    # Check for OpenVPN
    if pgrep -x "openvpn" &>/dev/null; then
        echo "󰖂 VPN"
        return
    fi
    
    # Check for Wireguard
    if ip -brief link show | grep -q "wg"; then
        echo "󰖂 VPN"
        return
    fi
    
    # No VPN detected
    echo ""
}

# Microphone status
microphone_status() {
    local MIC_MUTE=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -Po '(?<=Mute: )(yes|no)')
    
    if [[ "$MIC_MUTE" == "yes" ]]; then
        echo "󰍭"
    else
        # Add volume percentage
        local MIC_VOL=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -Po '[0-9]{1,3}(?=%)' | head -1)
        echo "󰍬 ${MIC_VOL}%"
    fi
}

# Bluetooth status
bluetooth_status() {
    if command -v bluetoothctl &>/dev/null; then
        if bluetoothctl show | grep -q "Powered: yes"; then
            # Check for connected devices
            if bluetoothctl info | grep -q "Connected: yes"; then
                echo "󰂱"
            else
                echo "󰂯"
            fi
        fi
    fi
}

# Screen brightness
brightness() {
    if [[ -d /sys/class/backlight ]]; then
        # Get the first backlight device
        local BACKLIGHT_DIR=$(find /sys/class/backlight -type d | head -n 1)
        if [[ -n "$BACKLIGHT_DIR" ]]; then
            local MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")
            local CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/brightness")
            local PERCENT=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
            
            echo "󰃞 $PERCENT%"
        fi
    fi
}

# Simple Pomodoro timer
# Create a toggle with: touch /tmp/pomodoro_active && echo "25" > /tmp/pomodoro_minutes
pomodoro() {
    local POMODORO_FILE="/tmp/pomodoro_active"
    local MINUTES_FILE="/tmp/pomodoro_minutes"
    
    if [[ -f "$POMODORO_FILE" ]]; then
        local START_TIME=$(stat -c %Y "$POMODORO_FILE")
        local CURRENT_TIME=$(date +%s)
        local ELAPSED=$((CURRENT_TIME - START_TIME))
        
        # Default 25 minutes
        local DURATION=1500
        if [[ -f "$MINUTES_FILE" ]]; then
            local MINUTES=$(cat "$MINUTES_FILE")
            DURATION=$((MINUTES * 60))
        fi
        
        local REMAINING=$((DURATION - ELAPSED))
        
        if [[ "$REMAINING" -le 0 ]]; then
            # Timer finished
            rm -f "$POMODORO_FILE"
            echo "<span color='#50FA7B'>󰔟 Done!</span>"
        else
            local MINS=$((REMAINING / 60))
            local SECS=$((REMAINING % 60))
            echo "󰔟 ${MINS}:$(printf "%02d" $SECS)"
        fi
    fi
}

# Currently focused window (truncated)
focused_window() {
    local TITLE=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .name' )
    
    if [[ -n "$TITLE" ]]; then
        echo "󰆍 $TITLE"
    fi
}


# Add these to your main output line in the script
# For example, at the end of your script, modify to include the modules you want:

# Output all info
# MEDIA=$(media_player)
# UPDATES=$(system_updates)
DISK=$(disk_space)
# TEMP=$(cpu_temp)
# VPN=$(vpn_status)
# MIC=$(microphone_status)
# BT=$(bluetooth_status)
# BRIGHT=$(brightness)
POMO=$(pomodoro)
WINDOW=$(focused_window)
# KB=$(keyboard_layout)

# Build the status line with only non-empty components
STATUS=""
for COMPONENT in "$UPDATES" "$DISK" "$TEMP" "$VPN" "$MIC" "$BT" "$BRIGHT" "$POMO" "$KB"; do
    if [[ -n "$COMPONENT" ]]; then
        if [[ -n "$STATUS" ]]; then
            STATUS="$STATUS | $COMPONENT"
        else
            STATUS="$COMPONENT"
        fi
    fi
done

# Add window title at the beginning if available
if [[ -n "$WINDOW" ]]; then
    if [[ -n "$STATUS" ]]; then
        STATUS="$WINDOW | $STATUS"
    else
        STATUS="$WINDOW"
    fi
fi

# Add media info at the beginning
if [[ -n "$MEDIA" ]]; then
    if [[ -n "$STATUS" ]]; then
        STATUS="$MEDIA | $STATUS"
    else
        STATUS="$MEDIA"
    fi
fi

# Output the final status line
echo -n "$STATUS | $(cpu_usage) | $(memory) | $(network) | $(volume) | $(battery) | $(weather) | $(clock)"



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
    
    printf "%s %3d%%" "$ICON" "$BAT"
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
        printf "<span color='#FF5555'>%s %5.1f%%</span>" "$ICON" "$CPU"
    else
        printf "%s %5.1f%%" "$ICON" "$CPU"
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
        printf "<span color='#FF5555'>%s %3d%%</span>" "$ICON" "$PERCENTAGE"
    else
        printf "%s %3d%%" "$ICON" "$PERCENTAGE"
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
            printf "󰕾 %3d%%" "$VOL"
        elif (( VOL >= 30 )); then
            printf "󰖀 %3d%%" "$VOL"
        else
            printf "󰕿 %3d%%" "$VOL"
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
    


# Air quality with fixed width
air_quality_paris() {
    # Cache air quality data for 1 hour to avoid excessive API calls
    local AQ_CACHE="/tmp/air_quality_paris_cache"
    if [[ ! -f "$AQ_CACHE" ]] || [[ $(find "$AQ_CACHE" -mmin +60 -size +0c -print) ]]; then
        # Using the World Air Quality Index public API for Paris
        curl -s "https://api.waqi.info/feed/paris/?token=58b158ac127d35ffb902051b7166ee736a57443d" > "$AQ_CACHE" 2>/dev/null
    fi
    
    if [[ -f "$AQ_CACHE" ]]; then
        # Extract AQI value
        local AQI=$(jq -r '.data.aqi' "$AQ_CACHE" 2>/dev/null)
        
        if [[ -n "$AQI" && "$AQI" != "null" ]]; then
            # Choose icon and color based on AQI level
            local ICON="󰌪"
            local COLOR=""
            
            # AQI categories according to international standards
            if [[ "$AQI" -le 50 ]]; then
                # Good
                COLOR="#50FA7B"  # Green
            elif [[ "$AQI" -le 100 ]]; then
                # Moderate
                COLOR="#F9FA9C"  # Yellow
            elif [[ "$AQI" -le 150 ]]; then
                # Unhealthy for Sensitive Groups
                COLOR="#FFB86C"  # Orange
            elif [[ "$AQI" -le 200 ]]; then
                # Unhealthy
                COLOR="#FF5555"  # Red
            elif [[ "$AQI" -le 300 ]]; then
                # Very Unhealthy
                COLOR="#FF79C6"  # Purple
            else
                # Hazardous
                COLOR="#BD93F9"  # Dark Purple
            fi
            
            printf "<span color='%s'>%s %3d</span>" "$COLOR" "$ICON" "$AQI"
        else
            # Data not available
            echo "<span color='#6272A4'>󰌫 N/A</span>"
        fi
    else
        # Could not fetch data
        echo ""
    fi
}

weather() {
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        # Update this every hour in a separate file and read from there
        local WEATHER_CACHE="/tmp/weather_cache"
        if [[ ! -f "$WEATHER_CACHE" ]] || [[ $(find "$WEATHER_CACHE" -mmin +1 -size +0c -print) ]]; then
            curl -s "https://wttr.in/Bagnolet?format=j1" > "$WEATHER_CACHE" 2>/dev/null
        fi
        
        if [[ -f "$WEATHER_CACHE" && -s "$WEATHER_CACHE" ]]; then
            # Current weather data
            local TEMP=$(jq -r '.current_condition[0].temp_C' "$WEATHER_CACHE" 2>/dev/null)
            local CONDITION=$(jq -r '.current_condition[0].weatherDesc[0].value' "$WEATHER_CACHE" 2>/dev/null)
            local WIND_DIR=$(jq -r '.current_condition[0].winddir16Point' "$WEATHER_CACHE" 2>/dev/null)
            local WIND_SPEED=$(jq -r '.current_condition[0].windspeedKmph' "$WEATHER_CACHE" 2>/dev/null)
            
            # Get rain chance at 18:00 by explicitly checking the time value
            local RAIN_CHANCE_18H=0
            # Loop through hourly forecasts to find the 18:00 entry
            local HOURLY_COUNT=$(jq -r '.weather[0].hourly | length' "$WEATHER_CACHE" 2>/dev/null)
            for ((i=0; i<$HOURLY_COUNT; i++)); do
                local HOUR_TIME=$(jq -r ".weather[0].hourly[$i].time" "$WEATHER_CACHE" 2>/dev/null)
                # wttr.in uses time format like "1800" for 18:00
                if [[ "$HOUR_TIME" == "1800" ]]; then
                    RAIN_CHANCE_18H=$(jq -r ".weather[0].hourly[$i].chanceofrain" "$WEATHER_CACHE" 2>/dev/null)
                    break
                fi
            done
            
            # Default to 0 if we couldn't get the data
            if [[ -z "$RAIN_CHANCE_18H" || "$RAIN_CHANCE_18H" == "null" ]]; then
                RAIN_CHANCE_18H=0
            fi
            
            # Weather icon based on condition
            local WEATHER_ICON="󰖐"
            if [[ "$CONDITION" =~ [Rr]ain|[Dd]rizzle ]]; then
                WEATHER_ICON="󰖗"
            elif [[ "$CONDITION" =~ [Ss]now ]]; then
                WEATHER_ICON="󰖘"
            elif [[ "$CONDITION" =~ [Cc]loud|[Oo]vercast ]]; then
                WEATHER_ICON="󰖐"
            elif [[ "$CONDITION" =~ [Ss]un|[Cc]lear ]]; then
                WEATHER_ICON="󰖙"
            fi
            
            # Wind direction icon
            local WIND_ICON="󰞍"
            case "$WIND_DIR" in
                "N")   WIND_ICON="↓" ;;
                "NNE") WIND_ICON="↓" ;;
                "NE")  WIND_ICON="↙" ;;
                "ENE") WIND_ICON="↙" ;;
                "E")   WIND_ICON="←" ;;
                "ESE") WIND_ICON="←" ;;
                "SE")  WIND_ICON="↖" ;;
                "SSE") WIND_ICON="↖" ;;
                "S")   WIND_ICON="↑" ;;
                "SSW") WIND_ICON="↑" ;;
                "SW")  WIND_ICON="↗" ;;
                "WSW") WIND_ICON="↗" ;;
                "W")   WIND_ICON="→" ;;
                "WNW") WIND_ICON="→" ;;
                "NW")  WIND_ICON="↘" ;;
                "NNW") WIND_ICON="↘" ;;
            esac
            
            # Rain indicator for 18:00 with color coding and fixed width
            local RAIN_INDICATOR=""
            if [[ "$RAIN_CHANCE_18H" -gt 0 ]]; then
                # Rain icon with chance percentage and color
                if [[ "$RAIN_CHANCE_18H" -ge 70 ]]; then
                    # Red for high chance
                    RAIN_INDICATOR=" <span color='#FF5555'>󰖖 $(printf "%2d" $RAIN_CHANCE_18H)%%</span>"
                elif [[ "$RAIN_CHANCE_18H" -ge 40 ]]; then
                    # Orange/yellow for medium chance
                    RAIN_INDICATOR=" <span color='#F1FA8C'>󰖔 $(printf "%2d" $RAIN_CHANCE_18H)%%</span>"
                elif [[ "$RAIN_CHANCE_18H" -ge 10 ]]; then
                    # Blue for low chance
                    RAIN_INDICATOR=" <span color='#8BE9FD'>󰖑 $(printf "%2d" $RAIN_CHANCE_18H)%%</span>"
                else
                    RAIN_INDICATOR=" 󰖖 $(printf "%2d" $RAIN_CHANCE_18H)%%"
                fi
            else
                RAIN_INDICATOR=" | 󰖖 $(printf "%2d" $RAIN_CHANCE_18H)%"
            fi
            
            # Add wind information
            local WIND_INFO=""
            if [[ -n "$WIND_DIR" && -n "$WIND_SPEED" && "$WIND_DIR" != "null" && "$WIND_SPEED" != "null" ]]; then
                WIND_INFO=" ${WIND_ICON}${WIND_SPEED}km/h"
            fi
            
            if [[ -n "$TEMP" && -n "$CONDITION" && "$TEMP" != "null" && "$CONDITION" != "null" ]]; then
                printf " %s  %2d°C%s%s" "$WEATHER_ICON" "$TEMP" "$WIND_INFO" "$RAIN_INDICATOR"
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
        if [[ ! -f "$UPDATES_CACHE" ]] || [[ $(find "$UPDATES_CACHE" -mmin +180 -size +0c -print) ]]; then
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
        echo "<span color='#FF5555'>󰋊 $(printf "%3d" $ROOT_PCT)%</span>"
    elif [[ "$ROOT_PCT" -gt 80 || "$HOME_PCT" -gt 80 ]]; then
        echo "<span color='#F1FA8C'>󰋊 $(printf "%3d" $ROOT_PCT)%</span>"
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
            printf "<span color='#FF5555'>󰔏 %3d°C</span>" "$TEMP"
        elif [[ "$TEMP" -gt 60 ]]; then
            printf "<span color='#F1FA8C'>󰔏 %3d°C</span>" "$TEMP"
        else
            printf "󰔏 %3d°C" "$TEMP"
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
# KB=$(keyboard_layout)
POMO=$(pomodoro)
WINDOW=$(focused_window)


CPU_USAGE=$(cpu_usage)
MEMORY_USAGE=$(memory)
NETWORK=$(network)
VOLUME=$(volume)
BATTERY=$(battery)
WEATHER=$(weather)
CLOCK=$(clock)
AIR_QUALITY=$(air_quality_paris)



# Build the status line with only non-empty components
STATUS=""
for COMPONENT in "$UPDATES" "$DISK" "$TEMP" "$VPN" "$MIC" "$BT" "$BRIGHT" "$POMO" "$KB" "$CPU_USAGE" "$MEMORY_USAGE" "$NETWORK" "$VOLUME" "$BATTERY" "$AIR_QUALITY $WEATHER" "$CLOCK"; do
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
echo -n "$STATUS"



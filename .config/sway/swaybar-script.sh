#!/bin/bash
# Save as ~/.config/sway/swaybar-script.sh and make executable with chmod +x

# Logging configuration
ENABLE_LOGGING=true  # Set to false to disable logging
LOG_DIR="/tmp/swaybar_logs"
LOG_FILE="$LOG_DIR/swaybar_$(date +%Y%m%d).log"
LOG_LEVEL="DEBUG"  # DEBUG, INFO, ERROR

# Create log directory if it doesn't exist
if [[ "$ENABLE_LOGGING" == "true" ]]; then
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== Swaybar script started =====" >> "$LOG_FILE"
fi

# Enhanced logging function with log levels
log_message() {
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        local level="INFO"
        if [[ $# -gt 1 ]]; then
            level="$1"
            shift
        fi
        
        # Only log if the current level is appropriate
        if [[ "$level" == "ERROR" || 
              ("$level" == "INFO" && "$LOG_LEVEL" != "ERROR") || 
              ("$level" == "DEBUG" && "$LOG_LEVEL" == "DEBUG") ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" >> "$LOG_FILE"
        fi
    fi
}

# Function to log file status
log_file_status() {
    local file="$1"
    local description="$2"
    
    if [[ "$ENABLE_LOGGING" == "true" && "$LOG_LEVEL" == "DEBUG" ]]; then
        if [[ -f "$file" ]]; then
            local size=$(du -h "$file" 2>/dev/null | cut -f1)
            local mtime=$(stat -c %y "$file" 2>/dev/null)
            local content_sample=$(head -c 100 "$file" 2>/dev/null | tr -d '\n' | tr -d '\r')
            
            log_message "DEBUG" "$description exists (size: $size, modified: $mtime)"
            log_message "DEBUG" "Content sample: ${content_sample:0:50}..."
            
            # Check if file is valid JSON (for JSON files)
            if [[ "$file" == *".json" || "$file" == *"_cache" ]]; then
                if command -v jq &>/dev/null; then
                    if jq empty "$file" 2>/dev/null; then
                        log_message "DEBUG" "$description contains valid JSON"
                    else
                        log_message "ERROR" "$description contains INVALID JSON"
                    fi
                fi
            fi
        else
            log_message "DEBUG" "$description does not exist"
        fi
    fi
}

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
    log_file_status "$AQ_CACHE" "Air quality cache"
    
    if [[ ! -f "$AQ_CACHE" ]] || [[ $(find "$AQ_CACHE" -mmin +60 -size +0c -print) ]]; then
        log_message "Fetching air quality data for Paris"
        # Using the World Air Quality Index public API for Paris
        local API_URL="https://api.waqi.info/feed/paris/?token=58b158ac127d35ffb902051b7166ee736a57443d"
        
        # Create a temporary file for the response
        local TEMP_RESPONSE="/tmp/air_quality_temp_response"
        curl -v "$API_URL" > "$TEMP_RESPONSE" 2> "${TEMP_RESPONSE}.headers" 
        local CURL_STATUS=$?
        
        if [[ $CURL_STATUS -eq 0 && -s "$TEMP_RESPONSE" ]]; then
            # Check if the response is valid JSON
            if jq empty "$TEMP_RESPONSE" 2>/dev/null; then
                log_message "Successfully fetched air quality data (size: $(du -h "$TEMP_RESPONSE" | cut -f1))"
                # Only update the cache if we got valid JSON
                mv "$TEMP_RESPONSE" "$AQ_CACHE"
            else
                log_message "ERROR" "Invalid JSON in air quality response"
                log_message "DEBUG" "Response content: $(cat "$TEMP_RESPONSE" | tr -d '\n' | tr -d '\r')"
                # Don't update cache with invalid data
            fi
        else
            log_message "ERROR" "Failed to fetch air quality data (curl status: $CURL_STATUS)"
            log_message "DEBUG" "Curl headers: $(cat "${TEMP_RESPONSE}.headers" 2>/dev/null)"
        fi
        
        # Clean up temp files
        rm -f "$TEMP_RESPONSE" "${TEMP_RESPONSE}.headers"
    fi
    
    if [[ -f "$AQ_CACHE" ]]; then
        # Extract AQI value
        local AQI=$(jq -r '.data.aqi' "$AQ_CACHE" 2>/dev/null)
        local JQ_STATUS=$?
        
        if [[ $JQ_STATUS -ne 0 ]]; then
            log_message "ERROR" "Failed to parse air quality data with jq (status: $JQ_STATUS)"
            log_message "DEBUG" "Cache content: $(head -c 200 "$AQ_CACHE" | tr -d '\n' | tr -d '\r')"
            echo "<span color='#6272A4'>󰌫 ERR</span>"
            return
        fi
        
        if [[ -n "$AQI" && "$AQI" != "null" ]]; then
            log_message "DEBUG" "Air quality index: $AQI"
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
            log_message "ERROR" "Air quality data is null or empty"
            # Check the structure of the response
            local DATA_STATUS=$(jq -r '.status' "$AQ_CACHE" 2>/dev/null)
            log_message "DEBUG" "API response status: $DATA_STATUS"
            log_message "DEBUG" "API response structure: $(jq -r 'keys' "$AQ_CACHE" 2>/dev/null)"
            
            # Data not available
            echo "<span color='#6272A4'>󰌫 N/A</span>"
        fi
    else
        log_message "ERROR" "Air quality cache file not found"
        # Could not fetch data
        echo "<span color='#6272A4'>󰌫 N/F</span>"
    fi
}

# Function to update and get weather cache
update_weather_cache() {
    local WEATHER_CACHE="/tmp/weather_cache"
    log_file_status "$WEATHER_CACHE" "Weather cache"
    
    if [[ ! -f "$WEATHER_CACHE" ]] || [[ $(find "$WEATHER_CACHE" -mmin +1 -size +0c -print) ]]; then
        log_message "Fetching weather data for Bagnolet"
        local API_URL="https://wttr.in/Bagnolet?format=j1"
        
        # Create a temporary file for the response
        local TEMP_RESPONSE="/tmp/weather_temp_response"
        curl -v "$API_URL" > "$TEMP_RESPONSE" 2> "${TEMP_RESPONSE}.headers"
        local CURL_STATUS=$?
        
        if [[ $CURL_STATUS -eq 0 && -s "$TEMP_RESPONSE" ]]; then
            # Check if the response is valid JSON
            if jq empty "$TEMP_RESPONSE" 2>/dev/null; then
                log_message "Successfully fetched weather data (size: $(du -h "$TEMP_RESPONSE" | cut -f1))"
                # Only update the cache if we got valid JSON
                mv "$TEMP_RESPONSE" "$WEATHER_CACHE"
            else
                log_message "ERROR" "Invalid JSON in weather response"
                log_message "DEBUG" "Response content: $(head -c 200 "$TEMP_RESPONSE" | tr -d '\n' | tr -d '\r')"
                # Don't update cache with invalid data
            fi
        else
            log_message "ERROR" "Failed to fetch weather data (curl status: $CURL_STATUS)"
            log_message "DEBUG" "Curl headers: $(cat "${TEMP_RESPONSE}.headers" 2>/dev/null)"
        fi
        
        # Clean up temp files
        rm -f "$TEMP_RESPONSE" "${TEMP_RESPONSE}.headers"
    fi
    echo "$WEATHER_CACHE"
}

# Current weather conditions
current_weather() {
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        # Get or update the weather cache
        local WEATHER_CACHE=$(update_weather_cache)
        
        if [[ -f "$WEATHER_CACHE" && -s "$WEATHER_CACHE" ]]; then
            # Check if the cache file contains valid JSON
            if ! jq empty "$WEATHER_CACHE" 2>/dev/null; then
                log_message "ERROR" "Weather cache contains invalid JSON"
                log_message "DEBUG" "Cache content: $(head -c 200 "$WEATHER_CACHE" | tr -d '\n' | tr -d '\r')"
                echo "<span color='#6272A4'> 󰖐 ERR</span>"
                return
            fi
            
            # Check if the expected structure exists
            if ! jq -e '.current_condition[0]' "$WEATHER_CACHE" >/dev/null 2>&1; then
                log_message "ERROR" "Weather cache missing expected structure"
                log_message "DEBUG" "JSON structure: $(jq -r 'keys' "$WEATHER_CACHE" 2>/dev/null)"
                echo "<span color='#6272A4'> 󰖐 FMT</span>"
                return
            fi
            
            # Current weather data
            local TEMP=$(jq -r '.current_condition[0].temp_C' "$WEATHER_CACHE" 2>/dev/null)
            local CONDITION=$(jq -r '.current_condition[0].weatherDesc[0].value' "$WEATHER_CACHE" 2>/dev/null)
            local WIND_DIR=$(jq -r '.current_condition[0].winddir16Point' "$WEATHER_CACHE" 2>/dev/null)
            local WIND_SPEED=$(jq -r '.current_condition[0].windspeedKmph' "$WEATHER_CACHE" 2>/dev/null)
            
            # Log the extracted values
            log_message "DEBUG" "Weather data - Temp: $TEMP, Condition: $CONDITION, Wind: $WIND_DIR $WIND_SPEED km/h"
            
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
            
            # Add wind information
            local WIND_INFO=""
            if [[ -n "$WIND_DIR" && -n "$WIND_SPEED" && "$WIND_DIR" != "null" && "$WIND_SPEED" != "null" ]]; then
                WIND_INFO=" ${WIND_ICON}${WIND_SPEED}km/h"
            fi
            
            if [[ -n "$TEMP" && -n "$CONDITION" && "$TEMP" != "null" && "$CONDITION" != "null" ]]; then
                printf " %s  %2d°C%s" "$WEATHER_ICON" "$TEMP" "$WIND_INFO"
            else
                log_message "ERROR" "Weather data missing or null values"
                log_message "DEBUG" "Temp: '$TEMP', Condition: '$CONDITION'"
                echo "<span color='#6272A4'> 󰖐 N/A</span>"
            fi
        else
            log_message "ERROR" "Weather cache file not found or empty"
            echo "<span color='#6272A4'> 󰖐 N/F</span>"
        fi
    else
        log_message "ERROR" "Missing required tools: curl or jq"
        echo ""
    fi
}

# Rain chance at 18:00
# rain_chance_18h() {
#     if command -v curl &>/dev/null && command -v jq &>/dev/null; then
#         # Get or update the weather cache
#         local WEATHER_CACHE=$(update_weather_cache)
#         
#         if [[ -f "$WEATHER_CACHE" && -s "$WEATHER_CACHE" ]]; then
#             # Get rain chance at 18:00 by explicitly checking the time value
#             local RAIN_CHANCE_18H=0
#             # Loop through hourly forecasts to find the 18:00 entry
#             local HOURLY_COUNT=$(jq -r '.weather[0].hourly | length' "$WEATHER_CACHE" 2>/dev/null)
#             for ((i=0; i<$HOURLY_COUNT; i++)); do
#                 local HOUR_TIME=$(jq -r ".weather[0].hourly[$i].time" "$WEATHER_CACHE" 2>/dev/null)
#                 # wttr.in uses time format like "1800" for 18:00
#                 if [[ "$HOUR_TIME" == "1800" ]]; then
#                     RAIN_CHANCE_18H=$(jq -r ".weather[0].hourly[$i].chanceofrain" "$WEATHER_CACHE" 2>/dev/null)
#                     break
#                 fi
#             done
#             
#             # Default to 0 if we couldn't get the data
#             if [[ -z "$RAIN_CHANCE_18H" || "$RAIN_CHANCE_18H" == "null" ]]; then
#                 RAIN_CHANCE_18H=0
#             fi
#             
#             # Rain indicator for 18:00 with color coding and fixed width
#             if [[ "$RAIN_CHANCE_18H" -gt 0 ]]; then
#                 # Rain icon with chance percentage and color
#                 if [[ "$RAIN_CHANCE_18H" -ge 70 ]]; then
#                     # Red for high chance
#                     printf " <span color='#FF5555'>󰖖 %2d%%</span>" "$RAIN_CHANCE_18H"
#                 elif [[ "$RAIN_CHANCE_18H" -ge 40 ]]; then
#                     # Orange/yellow for medium chance
#                     printf " <span color='#F1FA8C'>󰖔 %2d%%</span>" "$RAIN_CHANCE_18H"
#                 elif [[ "$RAIN_CHANCE_18H" -ge 10 ]]; then
#                     # Blue for low chance
#                     printf " <span color='#8BE9FD'>󰖑 %2d%%</span>" "$RAIN_CHANCE_18H"
#                 else
#                     printf " 󰖖 %2d%%" "$RAIN_CHANCE_18H"
#                 fi
#             else
#                 printf " | 󰖖 %2d%%" "$RAIN_CHANCE_18H"
#             fi
#         else
#             echo ""
#         fi
#     else
#         echo ""
#     fi
# }

# Rain precipitation between 18:00 and 19:30
rain_chance_18h() {
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        # Cache rain data for 15 minutes to avoid excessive API calls
        local RAIN_CACHE="/tmp/rain_forecast_cache"
        log_file_status "$RAIN_CACHE" "Rain forecast cache"
        
        if [[ ! -f "$RAIN_CACHE" ]] || [[ $(find "$RAIN_CACHE" -mmin +15 -size +0c -print) ]]; then
            log_message "Fetching rain forecast data"
            # API endpoint for Open-Meteo
            local API_URL="https://api.open-meteo.com/v1/forecast?latitude=48.8575&longitude=2.3514&minutely_15=precipitation&timezone=Europe%2FBerlin&past_minutely_15=48&forecast_days=1&forecast_minutely_15=48&models=meteofrance_seamless"
            
            # Create a temporary file for the response
            local TEMP_RESPONSE="/tmp/rain_temp_response"
            curl -v "$API_URL" > "$TEMP_RESPONSE" 2> "${TEMP_RESPONSE}.headers"
            local CURL_STATUS=$?
            
            if [[ $CURL_STATUS -eq 0 && -s "$TEMP_RESPONSE" ]]; then
                # Check if the response is valid JSON
                if jq empty "$TEMP_RESPONSE" 2>/dev/null; then
                    log_message "Successfully fetched rain forecast data (size: $(du -h "$TEMP_RESPONSE" | cut -f1))"
                    # Only update the cache if we got valid JSON
                    mv "$TEMP_RESPONSE" "$RAIN_CACHE"
                else
                    log_message "ERROR" "Invalid JSON in rain forecast response"
                    log_message "DEBUG" "Response content: $(head -c 200 "$TEMP_RESPONSE" | tr -d '\n' | tr -d '\r')"
                    # Don't update cache with invalid data
                fi
            else
                log_message "ERROR" "Failed to fetch rain forecast data (curl status: $CURL_STATUS)"
                log_message "DEBUG" "Curl headers: $(cat "${TEMP_RESPONSE}.headers" 2>/dev/null)"
            fi
            
            # Clean up temp files
            rm -f "$TEMP_RESPONSE" "${TEMP_RESPONSE}.headers"
        fi
        
        # Read from cache
        if [[ -f "$RAIN_CACHE" && -s "$RAIN_CACHE" ]]; then
            # Check if the cache file contains valid JSON
            if ! jq empty "$RAIN_CACHE" 2>/dev/null; then
                log_message "ERROR" "Rain forecast cache contains invalid JSON"
                log_message "DEBUG" "Cache content: $(head -c 200 "$RAIN_CACHE" | tr -d '\n' | tr -d '\r')"
                printf " | <span color='#6272A4'>󰖖 ERR</span>"
                return
            fi
            
            local WEATHER_DATA=$(cat "$RAIN_CACHE")
            
            # Check if the expected structure exists
            if ! jq -e '.minutely_15' "$RAIN_CACHE" >/dev/null 2>&1; then
                log_message "ERROR" "Rain forecast cache missing expected structure"
                log_message "DEBUG" "JSON structure: $(jq -r 'keys' "$RAIN_CACHE" 2>/dev/null)"
                printf " | <span color='#6272A4'>󰖖 FMT</span>"
                return
            fi
            
            if [[ -n "$WEATHER_DATA" && $(echo "$WEATHER_DATA" | jq -e '.minutely_15 != null' 2>/dev/null) == "true" ]]; then
            # Calculate total precipitation between 18:00 and 19:30
            local TOTAL_PRECIPITATION=$(echo "$WEATHER_DATA" | jq -r '
                [.minutely_15.time, .minutely_15.precipitation] as [$times, $precip] |
                [range(0; $times|length) as $i | 
                 select($times[$i] | contains("T18:") or contains("T19:00") or contains("T19:15") or contains("T19:30")) | 
                 $precip[$i]] | 
                add // 0
            ')
            local JQ_STATUS=$?
            
            if [[ $JQ_STATUS -ne 0 ]]; then
                log_message "ERROR" "Failed to calculate precipitation (jq status: $JQ_STATUS)"
                printf " | <span color='#6272A4'>󰖖 ERR</span>"
                return
            fi
            
            # Log the time entries for debugging
            local TIME_ENTRIES=$(echo "$WEATHER_DATA" | jq -r '.minutely_15.time | map(select(contains("T18:") or contains("T19:00") or contains("T19:15") or contains("T19:30"))) | join(", ")' 2>/dev/null)
            log_message "DEBUG" "Rain forecast time entries: $TIME_ENTRIES"
            
            # Ensure we have a valid number
            if [[ -z "$TOTAL_PRECIPITATION" || "$TOTAL_PRECIPITATION" == "null" ]]; then
                log_message "ERROR" "Invalid precipitation value: '$TOTAL_PRECIPITATION'"
                TOTAL_PRECIPITATION=0
            fi
            
            # Format to 1 decimal place
            TOTAL_PRECIPITATION=$(printf "%.1f" "$TOTAL_PRECIPITATION")
            log_message "DEBUG" "Total precipitation between 18:00-19:30: $TOTAL_PRECIPITATION mm"
            
            # Display with color coding based on precipitation amount
            if (( $(echo "$TOTAL_PRECIPITATION > 0" | bc -l) )); then
                if (( $(echo "$TOTAL_PRECIPITATION >= 2.0" | bc -l) )); then
                    # Heavy rain (red)
                    printf " <span color='#FF5555'>󰖖 %.1fmm</span>" "$TOTAL_PRECIPITATION"
                elif (( $(echo "$TOTAL_PRECIPITATION >= 0.5" | bc -l) )); then
                    # Moderate rain (yellow)
                    printf " <span color='#F1FA8C'>󰖔 %.1fmm</span>" "$TOTAL_PRECIPITATION"
                elif (( $(echo "$TOTAL_PRECIPITATION >= 0.1" | bc -l) )); then
                    # Light rain (blue)
                    printf " <span color='#8BE9FD'>󰖑 %.1fmm</span>" "$TOTAL_PRECIPITATION"
                else
                    # Very light rain
                    printf " 󰖖 %.1fmm" "$TOTAL_PRECIPITATION"
                fi
            else
                printf " | 󰖖 0.0mm"
            fi
            else
                # Invalid data in cache
                log_message "ERROR" "Invalid data structure in rain forecast cache"
                printf " | <span color='#6272A4'>󰖖 INV</span>"
            fi
        else
            # Cache file doesn't exist or is empty
            log_message "ERROR" "Rain forecast cache file not found or empty"
            printf " | <span color='#6272A4'>󰖖 N/F</span>"
        fi
    else
        # curl or jq not available
        log_message "ERROR" "Missing required tools: curl or jq"
        echo ""
    fi
}



#
#
# calculate_rain_precipitation() {
#     local JSON_FILE="$1"
#     
#     if [[ ! -f "$JSON_FILE" ]]; then
#         echo "Error: File not found: $JSON_FILE"
#         return 1
#     fi
#     
#     if command -v jq &>/dev/null; then
#         # Read the weather data from file
#         local WEATHER_DATA=$(cat "$JSON_FILE")
#         
#         if [[ -n "$WEATHER_DATA" && $(echo "$WEATHER_DATA" | jq -e '.minutely_15 != null' 2>/dev/null) == "true" ]]; then
#             # Calculate total precipitation between 18:00 and 19:30
#             local TOTAL_PRECIPITATION=$(echo "$WEATHER_DATA" | jq -r '
#                 [.minutely_15.time, .minutely_15.precipitation] as [$times, $precip] |
#                 [range(0; $times|length) as $i | 
#                  select($times[$i] | contains("T18:") or contains("T19:00") or contains("T19:15") or contains("T19:30")) | 
#                  $precip[$i]] | 
#                 add // 0
#             ')
#             
#             # Ensure we have a valid number
#             if [[ -z "$TOTAL_PRECIPITATION" || "$TOTAL_PRECIPITATION" == "null" ]]; then
#                 TOTAL_PRECIPITATION=0
#             fi
#             
#             # Format to 1 decimal place
#             TOTAL_PRECIPITATION=$(printf "%.1f" "$TOTAL_PRECIPITATION")
#             
#             # Display with color coding based on precipitation amount
#             echo -e "\nFormatted output with color code:"
#             if (( $(echo "$TOTAL_PRECIPITATION > 0" | bc -l) )); then
#                 if (( $(echo "$TOTAL_PRECIPITATION >= 2.0" | bc -l) )); then
#                     # Heavy rain (red)
#                     echo " Heavy rain: 󰖖 ${TOTAL_PRECIPITATION}mm (would be RED)"
#                 elif (( $(echo "$TOTAL_PRECIPITATION >= 0.5" | bc -l) )); then
#                     # Moderate rain (yellow)
#                     echo " Moderate rain: 󰖔 ${TOTAL_PRECIPITATION}mm (would be YELLOW)"
#                 elif (( $(echo "$TOTAL_PRECIPITATION >= 0.1" | bc -l) )); then
#                     # Light rain (blue)
#                     echo " Light rain: 󰖑 ${TOTAL_PRECIPITATION}mm (would be BLUE)"
#                 else
#                     # Very light rain
#                     echo " Very light rain: 󰖖 ${TOTAL_PRECIPITATION}mm (no color)"
#                 fi
#             else
#                 echo " No rain: 󰖖 0.0mm"
#             fi
#         else
#             echo "Error: Invalid JSON format or missing minutely_15 data"
#             return 1
#         fi
#     else
#         echo "Error: jq is required but not installed"
#         return 1
#     fi
# }
#

# Combined weather function for backward compatibility
weather() {
    local CURRENT=$(current_weather)
    local RAIN=$(rain_chance_18h)
    
    if [[ -n "$CURRENT" ]]; then
        echo "${CURRENT}${RAIN}"
    else
        echo ""
    fi
}



# System updates indicator
system_updates() {
    if command -v apt &>/dev/null; then
        # For Debian/Ubuntu based systems
        local UPDATES_CACHE="/tmp/updates_cache"
        log_file_status "$UPDATES_CACHE" "System updates cache"
        
        # Update cache once every 3 hours
        if [[ ! -f "$UPDATES_CACHE" ]] || [[ $(find "$UPDATES_CACHE" -mmin +180 -size +0c -print) ]]; then
            log_message "Checking for system updates (apt)"
            apt-get update -qq &>/dev/null
            local APT_STATUS=$?
            if [[ $APT_STATUS -ne 0 ]]; then
                log_message "ERROR" "apt-get update failed (status: $APT_STATUS)"
            fi
            
            apt-get --just-print upgrade 2>&1 | grep "^Inst" | wc -l > "$UPDATES_CACHE"
            log_message "Found $(cat "$UPDATES_CACHE") updates available"
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
            log_message "Checking for system updates (pacman)"
            pacman -Sy &>/dev/null
            pacman -Qu | wc -l > "$UPDATES_CACHE"
            log_message "Found $(cat "$UPDATES_CACHE") updates available"
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
UPDATES=$(system_updates)
DISK=$(disk_space)
# TEMP=$(cpu_temp)
# VPN=$(vpn_status)
# MIC=$(microphone_status)
# BT=$(bluetooth_status)
# BRIGHT=$(brightness)
# KB=$(keyboard_layout)
POMO=$(pomodoro)
WINDOW=$(focused_window)

log_message "DEBUG" "Starting to gather status information"

CPU_USAGE=$(cpu_usage)
log_message "DEBUG" "CPU usage gathered"

MEMORY_USAGE=$(memory)
log_message "DEBUG" "Memory usage gathered"

NETWORK=$(network)
log_message "DEBUG" "Network status gathered"

VOLUME=$(volume)
log_message "DEBUG" "Volume status gathered"

BATTERY=$(battery)
log_message "DEBUG" "Battery status gathered"

AIR_QUALITY=$(air_quality_paris)
log_message "DEBUG" "Air quality gathered"

CURRENT_WEATHER=$(current_weather)
log_message "DEBUG" "Current weather gathered"

RAIN_FORECAST=$(rain_chance_18h)
log_message "DEBUG" "Rain forecast gathered"

CLOCK=$(clock)
log_message "DEBUG" "Clock gathered"

log_message "DEBUG" "All status information gathered"



# Build the status line with only non-empty components
STATUS=""
for COMPONENT in "$UPDATES" "$DISK" "$TEMP" "$VPN" "$MIC" "$BT" "$BRIGHT" "$POMO" "$KB" "$CPU_USAGE" "$MEMORY_USAGE" "$NETWORK" "$VOLUME" "$BATTERY" "$AIR_QUALITY $CURRENT_WEATHER$RAIN_FORECAST" "$CLOCK"; do
    if [[ -n "$COMPONENT" ]]; then
        if [[ -n "$STATUS" ]]; then
            STATUS="$STATUS | $COMPONENT"
        else
            STATUS="$COMPONENT"
        fi
    fi
done

log_message "DEBUG" "Final status bar built"

# Add window title at the beginning if available
# if [[ -n "$WINDOW" ]]; then
#     if [[ -n "$STATUS" ]]; then
#         STATUS="$WINDOW | $STATUS"
#     else
#         STATUS="$WINDOW"
#     fi
# fi

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



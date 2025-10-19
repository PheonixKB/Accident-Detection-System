#!/bin/bash
clear
sleep 2
echo ""
echo ""
echo "    ___    ____  _____ "
echo "   /   |  / __ \/ ___/ "
echo "  / /| | / / / /\__ \  "
echo " / ___ |/ /_/ /___/ /  "
echo "/_/  |_/_____//____/   "
echo "                       "

echo "Accident Detection System - Prototype"
echo "Made by Kavya, Tirth, Jindal, and Yash"
echo ""
echo "Starting ADS..."

# Twilio credentials 
ACCOUNT_SID=""
AUTH_TOKEN=""

# Twilio phone numbers
TWILIO_SMS_NUMBER=""
TWILIO_WHATSAPP_NUMBER=""

# Recipient numbers ( They need to be verified by Twilio Console beforehand )
RECEIVER_SMS_NUMBERS=(
    ""

)

RECEIVER_WHATSAPP_NUMBERS=(
    "whatsapp:"
)

# Get location data of current machine from ip-api.com
LOCATION_DATA=$(curl -s --max-time 5 http://ip-api.com/json)
LAT=$(echo "$LOCATION_DATA" | grep -oP '(?<="lat":)[^,]*')
LON=$(echo "$LOCATION_DATA" | grep -oP '(?<="lon":)[^,]*')
CITY=$(echo "$LOCATION_DATA" | grep -oP '(?<="city":")[^"]*')
STATE=$(echo "$LOCATION_DATA" | grep -oP '(?<="regionName":")[^"]*')
COUNTRY=$(echo "$LOCATION_DATA" | grep -oP '(?<="country":")[^"]*')

if [[ -n "$LAT" && -n "$LON" ]]; then
    LOCATION_DETAILS="$CITY, $STATE, $COUNTRY"
    GOOGLE_MAPS_LINK="https://www.google.com/maps?q=${LAT},${LON}"
else
    LOCATION_DETAILS="Location not available"
    GOOGLE_MAPS_LINK="N/A"
fi

start_server() {
    echo "Starting The Server..."
    sleep 2
    mkdir -p ./server
    cd ./server || exit
    nohup python3 -m http.server 8080 --bind localhost > /dev/null 2>&1 &
    nohup ngrok http 8080 > /dev/null 2>&1 &
    cd - > /dev/null
    echo "Server Started Successfully"
}

run_ai() {
    echo "Running ADS AI Detection..."

    WATCH_DIR="./"
    DEST_DIR="./server/video.mp4"

    video_file=$(find "$WATCH_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \) | sort | head -n 1)

    output_folder="frames_output"
    mkdir -p "$output_folder"

    ffmpeg -hide_banner -loglevel quiet -i "$video_file" -vf "fps=1" "$output_folder/frame_%04d.jpg"

    for frame in "$output_folder"/*.jpg; do
        base64 "$frame" | curl -s -d @- \
        "https://detect.roboflow.com/" >> ai.json
    done

    sed 's/}{/},{/g' ai.json | sed '1s/^/[/' | sed '$s/$/]/' > output.json && mv output.json ai.json
    rm -rf "$output_folder"

    if grep -q '\baccident\b' ai.json; then
        detected=true
    else
        detected=false
    fi

    if [ "$detected" = true ]; then
        cp "$video_file" "$DEST_DIR"
        rm -rf "$video_file"
        echo -e "\033[31mAccident Detected\033[0m"
        # Send SMS messages
        for NUMBER in "${RECEIVER_SMS_NUMBERS[@]}"; do
            send_message "$TWILIO_SMS_NUMBER" "$NUMBER"
        done
        
        # Send WhatsApp messages
        for NUMBER in "${RECEIVER_WHATSAPP_NUMBERS[@]}"; do
            send_message "$TWILIO_WHATSAPP_NUMBER" "$NUMBER"
        done
        rm -rf ai.json
        sleep 3
        check_videos
        exit 0
    else
        rm -rf "$video_file"
        echo -e "\033[32mNo Accident Detected\033[0m"
        rm -rf ai.json
        sleep 3
        check_videos
        exit 0
    fi
}

monitor_videos() {
    echo "Looking for Video Files..."
    WATCH_DIR="./"

    while true; do
        mp4_files=$(find "$WATCH_DIR" -maxdepth 1 -type f -name "*.mp4")

        if [ ! -z "$mp4_files" ]; then
            echo "Found video file(s), Proceeding..."
            run_ai
            exit 0
        else 
            :
        fi

        sleep 3 
    done
}

check_videos() {
    echo "Rechecking for new videos..."
    monitor_videos
}

start_server

sleep 5
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[a-zA-Z0-9.-]*\.ngrok-free\.app' | head -n 1)
VIDEO_LINK="${NGROK_URL}/video.mp4"

MESSAGE_BODY="🚨 *ALERT* Accident Detected!, Location: ${GOOGLE_MAPS_LINK}, Video: ${VIDEO_LINK}"

send_message() {
    local FROM="$1"
    local TO="$2"
    curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/${ACCOUNT_SID}/Messages.json" \
        --data-urlencode "Body=${MESSAGE_BODY}" \
        --data-urlencode "From=${FROM}" \
        --data-urlencode "To=${TO}" \
        -u "${ACCOUNT_SID}:${AUTH_TOKEN}" > /dev/null && echo "Message sent to ${TO}" || echo "Failed to send to ${TO}"
}


monitor_videos

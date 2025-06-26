#!/bin/bash

# === CONFIG ===
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/#########" # replace this with your webhook

# === REQUIREMENTS CHECK ===
for cmd in jq wget curl java tmux; do
    if ! command -v $cmd &>/dev/null; then
        echo "Error: Required command '$cmd' is not installed or not in PATH."
        exit 1
    fi
done

# === FETCH VERSION INFO ===
manifest=$(curl -s https://piston-meta.mojang.com/mc/game/version_manifest.json)
latest_ver=$(echo "$manifest" | jq -r '.latest.release')
version_url=$(echo "$manifest" | jq -r --arg ver "$latest_ver" '.versions[] | select(.id == $ver) | .url')
durl=$(curl -s "$version_url" | jq -r '.downloads.server.url')
minever="minecraft_server.${latest_ver}.jar"

local_ver=$(ls minecraft_server*.jar 2>/dev/null | grep -oP 'minecraft_server\.\K[0-9]+\.[0-9]+(\.[0-9]+)?')
updated=false

# === FUNCTIONS ===
start_minecraft() {
    echo "Starting Minecraft server..."
    tmux new-session -d -s minecraft "java -Xmx7G -Xms1G -jar server.jar nogui | tee -a server.log"
}

send_discord_notification() {
    message="$1"
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$message\"}" \
         "$DISCORD_WEBHOOK_URL"
}

# === VERSION CHECK AND UPDATE ===
if [ "$local_ver" == "$latest_ver" ]; then
    echo "Local version ($local_ver) is up to date."
else
    echo "Updating to new version ($minever)..."
    rm -f minecraft_server*.jar server.jar
    wget "$durl" -O "$minever"
    cp "$minever" server.jar
    updated=true
    send_discord_notification ":pick: **Minecraft server updated** to version **$latest_ver**!"
fi

# === SERVER PROCESS MANAGEMENT ===
if tmux list-sessions 2>/dev/null | grep -q "^minecraft:"; then
    echo "Minecraft server is running."
    if [ "$updated" = true ]; then
        echo "Restarting server to apply update..."
        tmux kill-session -t minecraft
        start_minecraft
        send_discord_notification ":repeat: **Minecraft server restarted** after update to version **$latest_ver**."
    fi
else
    echo "Minecraft server is not running. Starting..."
    start_minecraft
    send_discord_notification ":white_check_mark: **Minecraft server started**. Running version **$latest_ver**."
fi

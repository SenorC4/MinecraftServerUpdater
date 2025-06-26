#!/bin/bash

# Fetching the HTML page with curl and extracting the relevant line with grep
durl=$(curl -s $(curl -s https://piston-meta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release as $latest | .versions[] | select(.id == $latest) | .url') | jq -r '.downloads.server.url')

# Extracting the Minecraft version from the line
minever=$(curl -s https://piston-meta.mojang.com/mc/game/version_manifest.json | jq -r '"minecraft_server.\(.latest.release).jar"')

# Extracting the URL from the line
#mineurl=$(echo "$durl" | awk -F'"' '{print $2}')

# Check if a local version exists
local_file=$(ls minecraft_server*.jar 2>/dev/null)

start_minecraft() {
    echo "Starting Minecraft server..."
    # Adjust this command to match your server's start command
    tmux new-session -d -s minecraft "java -Xmx7G -Xms1G -jar server.jar nogui"
}

updated=false

if [ -n "$local_file" ]; then
    # Compare versions
    if [ "$minever" == "$local_file" ]; then
        echo "Local version ($local_file) is up to date."
    else
        echo "Updating to new version ($minever)..."
	rm *.jar
        wget "$durl" -O "$minever"
	cp "$minever" server.jar
	updated=true
    fi
else
    # Download if no local version exists
    echo "No local version found. Downloading $minever..."
    rm *.jar
    wget "$durl" -O "$minever"
    cp "$minever" server.jar
    #kill and rerun minecraft
    updated=true
fi

# Check if the Minecraft tmux session is running
if tmux has-session -t minecraft 2>/dev/null; then
    echo "Minecraft server is running in a tmux session."
    
    # If an update occurred, kill the tmux session and restart
    if [ "$updated" = true ]; then
        echo "Stopping Minecraft server tmux session to apply the update..."
        tmux kill-session -t minecraft
        
        # Start the updated Minecraft server in a new tmux session
        start_minecraft
    else
        echo "No update detected; Minecraft server is already running in tmux."
    fi
else
    # Start the server in a new tmux session if it's not running and an update was applied
    if [ "$updated" = true ]; then
        echo "Minecraft server is not running, update was needed. Starting..."
	start_minecraft
    else
        echo "Minecraft server is not running, no update was needed. Starting..."
        start_minecraft
    fi
fi

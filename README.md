# MinecraftServerUpdater
A script to be run as a cronjob to keep your vanilla minecraft server up to date

## Requirements
* curl
* wget
* jq
* tmux
* java 21

## install
* clone the repo or download the bash file
* delete the old server.jar file
* run the script

## usage
* once ran the script creates a tmux session named "minecraft"
* you can then attach the the tmux session with `tmux a` or `tmux attach -t minecraft`
* to disconnect from the tmux session without closing it `ctrl+b` + `d`

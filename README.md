# MinecraftServerUpdater
A script to be run as a cronjob to keep your vanilla minecraft server up to date

## Requirements
* curl
* wget
* jq
* tmux
* java
* git

## install
* clone the repo or download the bash file
* delete the old server.jar file
* run the script
* add the cron job to restart minecraft at reboot and update every 12 hours (you can change this to meet your needs)
  * `@reboot cd /your/path/MinecraftServerUpdater && ./update.sh`
  * `0 */12 * * * cd /your/path/MinecraftServeUpdater && ./update.sh`

### Ex. install
`sudo apt install curl wget jq tmux git default-jre
git clone https://github.com/SenorC4/MinecraftServerUpdater
cd MinecraftServerUpdater
./updater.sh`

## usage
* once ran the script creates a tmux session named "minecraft"
* you can then attach the the tmux session with `tmux a` or `tmux attach -t minecraft`
* to disconnect from the tmux session without closing it `ctrl+b` + `d`

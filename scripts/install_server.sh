#!/bin/bash

# Exit on error
set -e

# Steam credentials from environment variables
STEAM_USERNAME="${STEAM_USERNAME}"
STEAM_PASSWORD="${STEAM_PASSWORD}"

# Arma 2 App IDs
APP_ID_ARMA2=33900
APP_ID_ARMA2_OA=33910
APP_ID_ARMA2_BAF=33930
APP_ID_ARMA2_BETA=219540

# DayZ Epoch Download URLs
DAYZ_EPOCH_SERVER_URL="https://drive.google.com/uc?export=download&id=1jDn86sfTwcRae4NZgHK76k_CaY1jOUP2"
DAYZ_EPOCH_SERVER_PASSWORD="123456"

# Installation directory
INSTALL_DIR="/home/dayz/server"

# Validate Steam credentials
if [ -z "$STEAM_USERNAME" ] || [ -z "$STEAM_PASSWORD" ]; then
    echo "Error: STEAM_USERNAME and STEAM_PASSWORD must be set in environment variables"
    echo "Please check your .env file or docker-compose environment configuration"
    exit 1
fi

# 1. Install Arma 2 using SteamCMD
echo "Installing Arma 2..."
/home/dayz/steamcmd/steamcmd.sh +login $STEAM_USERNAME $STEAM_PASSWORD \
    +force_install_dir $INSTALL_DIR \
    +@sSteamCmdForcePlatformType windows \
    +app_update $APP_ID_ARMA2 validate \
    +app_update $APP_ID_ARMA2_OA validate \
    +app_update $APP_ID_ARMA2_BAF validate \
    +app_update $APP_ID_ARMA2_BETA beta112555 validate \
    +quit

# 2. Download and extract DayZ Epoch server files
echo "Downloading and extracting DayZ Epoch server..."
cd /tmp
wget -O dayz_epoch_server.7z "$DAYZ_EPOCH_SERVER_URL"
7z x -p$DAYZ_EPOCH_SERVER_PASSWORD dayz_epoch_server.7z -o$INSTALL_DIR/@dayz_epoch_server
rm dayz_epoch_server.7z

# 3. Download and extract DayZ Epoch client files (for @dayz_epoch mod)
echo "Downloading and extracting DayZ Epoch client..."
DAYZ_EPOCH_CLIENT_URL="https://drive.google.com/uc?export=download&id=19iCJevU008g311vsxNR0PjYmkSv36YKv"
wget -O dayz_epoch_client.7z "$DAYZ_EPOCH_CLIENT_URL"
7z x dayz_epoch_client.7z -o$INSTALL_DIR/@dayz_epoch
rm dayz_epoch_client.7z

echo "Installation complete."


#!/bin/bash

# exit on error
set -e

# install or update server and verify files
$_STEAMCMD_PATH/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir /app +login ${STEAM_USERNAME} ${STEAM_PASSWORD} +app_update 1007 validate +app_update ${STEAM_APP_ID} -beta test -betapassword motortowndedi validate +quit

# copy steamclient.dll
cp /app/*.dll /app/MotorTown/Binaries/Win64/

# start server
proton run /app/MotorTown/Binaries/Win64/MotorTownServer-Win64-Shipping.exe Jeju_World?listen? -server -log -useperfthreads

wait $!

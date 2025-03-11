#!/bin/bash

# exit on error
set -e

mkdir -p "${STEAM_COMPAT_DATA_PATH}"

# install or update server and verify files
/opt/steamcmd/steamcmd.sh +force_install_dir /app +login anonymous +app_update 1007 validate +quit
/opt/steamcmd/steamcmd.sh +force_install_dir /app +login ${STEAM_USERNAME} ${STEAM_PASSWORD} +app_update ${STEAM_APP_ID} -beta test -betapassword motortowndedi validate +quit

# start server
proton run /app/MotorTown/Binaries/Win64/MotorTownServer-Win64-Shipping.exe Jeju_World?listen? -server -log -useperfthreads -multihome=0.0.0.0

wait $!

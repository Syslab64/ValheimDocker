#!/bin/bash

# update server's data
/home/steam/steamcmd/steamcmd.sh \
	    +login anonymous \
	        +force_install_dir /home/steam/valheim/server \
		    +app_update 896660 \
		        +exit

#Copy 64bit steamclient, since it keeps using 32bit
cp /home/steam/steamcmd/linux64/steamclient.so /home/steam/valheim/server/
cp -r /home/steam/bepinexvalheim/* /home/steam/valheim/server/

#Apply default values for server if not set
SERVER_NAME=${SERVER_NAME:-My\ server}
SERVER_PORT=${SERVER_PORT:-2456}
SERVER_WORLD=${SERVER_WORLD:-Dedicated}
SERVER_PASSWORD=${SERVER_PASSWORD:-secret}

# BepInEx-specific settings
# NOTE: Do not edit unless you know what you are doing!
####
export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH=/home/steam/valheim/server/BepInEx/core/BepInEx.Preloader.dll
export DOORSTOP_CORLIB_OVERRIDE_PATH=/home/steam/valheim/server/unstripped_corlib

export LD_LIBRARY_PATH="/home/steam/valheim/server/doorstop_libs:$LD_LIBRARY_PATH"
export LD_PRELOAD="libdoorstop_x64.so:$LD_PRELOAD"
####

#Launch server
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

/home/steam/valheim/server/valheim_server.x86_64 -name "$SERVER_NAME" -port $SERVER_PORT -world "$SERVER_WORLD" -password "$SERVER_PASSWORD" -savedir "/home/steam/valheim/data" -public 1 &

#Trap Container Stop for graceful exit
trap "kill -SIGINT $!;" SIGTERM

#Wait for server to exit
while wait $!; [ $? != 0 ]; do true; done

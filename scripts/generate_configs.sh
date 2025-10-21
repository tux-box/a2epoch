#!/bin/bash

# Generate server configuration files from environment variables
# This script is called during container startup to create configs

set -e

CONFIG_DIR="/home/dayz/server/cfgdayz"
mkdir -p "$CONFIG_DIR"

# Generate server.cfg
cat > "$CONFIG_DIR/server.cfg" << EOF
// Server Configuration Generated from Environment Variables

hostname = "${SERVER_HOSTNAME:-DayZ Epoch Server}";
password = "${SERVER_PASSWORD:-}";
passwordAdmin = "${SERVER_ADMIN_PASSWORD:-changeme}";
maxPlayers = ${SERVER_MAX_PLAYERS:-50};

motd[] = {
    "Welcome to ${SERVER_HOSTNAME:-DayZ Epoch Server}",
    "Visit our website for more information"
};

admins[] = {};

voteMissionPlayers = 1;
voteThreshold = 0.33;

disableVoN = 0;
vonCodecQuality = 10;
persistent = 1;

timeStampFormat = "short";
BattlEye = 1;

onUserConnected = "";
onUserDisconnected = "";
doubleIdDetected = "";

regularCheck = "";

class Missions {
    class DayZ_Epoch_11 {
        template = "DayZ_Epoch_11.Chernarus";
        difficulty = "Regular";
    };
    class DayZ_Epoch_13 {
        template = "DayZ_Epoch_13.Tavi";
        difficulty = "Regular";
    };
};
EOF

# Generate basic.cfg
cat > "$CONFIG_DIR/basic.cfg" << EOF
// Basic Configuration Generated from Environment Variables

language = "English";
adapter = -1;
3D_Performance = 1.000000;
Resolution_W = 0;
Resolution_H = 0;
Resolution_Bpp = 32;
refresh = 60;
Render_W = 1024;
Render_H = 768;
FSAA = 0;
postFX = 0;
GPU_MaxFramesAhead = 1;
GPU_DetectedFramesAhead = 1;
terrainGrid = 25;
viewDistance = 1600;
Windowed = 0;
EOF

# Generate BattlEye server configuration
mkdir -p "/home/dayz/server/expansion/battleye"
cat > "/home/dayz/server/expansion/battleye/beserver.cfg" << EOF
RConPassword ${RCON_PASSWORD:-changeme}
RConPort 2302
EOF

# Generate HiveExt.ini for database connection
cat > "/home/dayz/server/hiveext.ini" << EOF
[Database]
Type = mysql
Host = ${MYSQL_HOST:-mysql}
Port = 3306
Database = ${MYSQL_DATABASE:-dayz_epoch}
Username = ${MYSQL_USER:-dayz}
Password = ${MYSQL_PASSWORD:-dayz}

[Characters]
MaxLifetime = 999999

[Objects]
MaxLifetime = 8
EOF

# Update epoch.sh with environment variables
cat > "/home/dayz/server/epoch.sh" << EOF
#!/bin/bash
export LD_LIBRARY_PATH=.:/usr/lib32:\$LD_LIBRARY_PATH
./epoch -server \\
    -mod="@dayz_epoch;@dayz_epoch_server;" \\
    -config="cfgdayz/server.cfg" \\
    -cfg="cfgdayz/basic.cfg" \\
    -port=${SERVER_PORT:-2302} \\
    -beta="expansion/beta;expansion/beta/expansion" \\
    -noSound -noPause \\
    -world=Chernarus \\
    -profiles=cfgdayz \\
    -name=cfgdayz \\
    -cpucount=2 \\
    -exThreads=3 \\
    -showscripterrors \\
    -pid=${SERVER_PORT:-2302}.pid \\
    2>&1 | ./writer.pl
EOF

chmod +x "/home/dayz/server/epoch.sh"

echo "Configuration files generated successfully from environment variables"

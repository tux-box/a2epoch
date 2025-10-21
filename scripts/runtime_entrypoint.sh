#!/bin/bash

# Runtime entrypoint for DayZ Epoch Docker container
# This script handles Steam installation and server startup

set -e

echo "=========================================="
echo "DayZ Epoch Server Starting Up"
echo "=========================================="

# 1. Generate configuration files from environment variables
echo "Generating configuration files..."
/home/dayz/server/generate_configs.sh

# 2. Check if Arma 2 files are already installed
if [ ! -f "/home/dayz/server/epoch" ]; then
    echo "Arma 2 files not found. Installing..."
    
    # Validate Steam credentials
    if [ -z "$STEAM_USERNAME" ] || [ -z "$STEAM_PASSWORD" ]; then
        echo "ERROR: STEAM_USERNAME and STEAM_PASSWORD must be set"
        echo "Please check your .env file or docker-compose environment configuration"
        exit 1
    fi
    
    # Run the installation script
    /home/dayz/server/install_server.sh
    
    echo "Installation completed successfully!"
else
    echo "Arma 2 files already installed, skipping installation."
fi

# 3. Wait for external MySQL database to be ready
echo "Waiting for MySQL database to be ready..."
for i in {1..60}; do
    if mysql -h "${MYSQL_HOST:-mysql}" -u "${MYSQL_USER:-dayz}" -p"${MYSQL_PASSWORD:-dayz}" -e "SELECT 1" >/dev/null 2>&1; then
        echo "MySQL database is ready!"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "ERROR: MySQL database failed to respond within 60 seconds"
        echo "Please check your database configuration and ensure the MySQL container is running"
        exit 1
    fi
    echo "Waiting for database... ($i/60)"
    sleep 1
done

# Import database schema if not already imported
if ! mysql -h "${MYSQL_HOST:-mysql}" -u "${MYSQL_USER:-dayz}" -p"${MYSQL_PASSWORD:-dayz}" "${MYSQL_DATABASE:-dayz_epoch}" -e "SHOW TABLES;" 2>/dev/null | grep -q "Character_DATA"; then
    echo "Importing database schema..."
    mysql -h "${MYSQL_HOST:-mysql}" -u "${MYSQL_USER:-dayz}" -p"${MYSQL_PASSWORD:-dayz}" "${MYSQL_DATABASE:-dayz_epoch}" < /home/dayz/server/sql/database.sql
    echo "Database schema imported successfully!"
else
    echo "Database schema already exists, skipping import."
fi

# 4. Start the DayZ Epoch server
echo "Starting DayZ Epoch server..."
cd /home/dayz/server

# Check if server binary exists
if [ ! -f "./epoch" ]; then
    echo "ERROR: Server binary 'epoch' not found!"
    echo "This usually means the Steam installation failed."
    echo "Please check your Steam credentials and try again."
    exit 1
fi

# Start the server using the restarter script
exec ./restarter.pl

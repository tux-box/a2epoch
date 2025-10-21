#!/bin/bash

# DayZ Epoch Docker Setup Script
# This script helps you get started quickly with the DayZ Epoch server

set -e

echo "=========================================="
echo "DayZ Epoch Docker Setup"
echo "=========================================="
echo

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "✓ .env file created"
    echo
    echo "⚠️  IMPORTANT: You must edit the .env file with your actual values!"
    echo "   Required settings:"
    echo "   - STEAM_USERNAME and STEAM_PASSWORD"
    echo "   - MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD"
    echo "   - SERVER_ADMIN_PASSWORD and RCON_PASSWORD"
    echo
    read -p "Press Enter to open .env file for editing..."
    
    # Try to open with available editors
    if command -v nano >/dev/null 2>&1; then
        nano .env
    elif command -v vim >/dev/null 2>&1; then
        vim .env
    elif command -v vi >/dev/null 2>&1; then
        vi .env
    else
        echo "No text editor found. Please edit .env file manually."
    fi
else
    echo "✓ .env file already exists"
fi

echo
echo "Checking configuration..."

# Source the .env file to check variables
if [ -f ".env" ]; then
    source .env
    
    # Check required variables
    missing_vars=()
    
    [ -z "$STEAM_USERNAME" ] && missing_vars+=("STEAM_USERNAME")
    [ -z "$STEAM_PASSWORD" ] && missing_vars+=("STEAM_PASSWORD")
    [ -z "$MYSQL_ROOT_PASSWORD" ] && missing_vars+=("MYSQL_ROOT_PASSWORD")
    [ -z "$MYSQL_PASSWORD" ] && missing_vars+=("MYSQL_PASSWORD")
    [ -z "$SERVER_ADMIN_PASSWORD" ] && missing_vars+=("SERVER_ADMIN_PASSWORD")
    [ -z "$RCON_PASSWORD" ] && missing_vars+=("RCON_PASSWORD")
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "❌ Missing required configuration:"
        for var in "${missing_vars[@]}"; do
            echo "   - $var"
        done
        echo
        echo "Please edit .env file and set these variables, then run this script again."
        exit 1
    else
        echo "✓ All required variables are set"
    fi
fi

echo
echo "Checking Docker installation..."

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
else
    echo "✓ Docker is installed"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ Docker Compose is not installed"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
else
    echo "✓ Docker Compose is installed"
fi

# Check if user can run Docker commands
if ! docker ps >/dev/null 2>&1; then
    echo "❌ Cannot run Docker commands"
    echo "You may need to:"
    echo "1. Start Docker service: sudo systemctl start docker"
    echo "2. Add your user to docker group: sudo usermod -aG docker \$USER"
    echo "3. Log out and log back in"
    exit 1
else
    echo "✓ Docker is running and accessible"
fi

echo
echo "Creating required directories..."
mkdir -p logs missions
echo "✓ Directories created"

echo
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo
echo "To start the DayZ Epoch server:"
echo "  docker-compose up --build -d"
echo
echo "To view logs:"
echo "  docker-compose logs -f"
echo
echo "To stop the server:"
echo "  docker-compose down"
echo
echo "Server will be available on port ${SERVER_PORT:-2302}/UDP"
echo
echo "For more information, see README.md and DEPLOYMENT_GUIDE.md"
echo

read -p "Would you like to start the server now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting DayZ Epoch server..."
    docker-compose up --build -d
    echo
    echo "Server is starting up. Use 'docker-compose logs -f' to monitor progress."
else
    echo "Setup complete. Run 'docker-compose up --build -d' when ready to start."
fi

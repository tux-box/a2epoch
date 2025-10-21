#!/bin/bash

# Validate .env file parsing
# This script helps debug .env file issues

echo "=== .env File Validation ==="
echo

if [ ! -f ".env" ]; then
    echo "❌ .env file not found"
    echo "Run: cp .env.example .env"
    exit 1
fi

echo "✓ .env file exists"
echo

# Function to safely read .env file
read_env_var() {
    local var_name="$1"
    local var_value=""
    
    if [ -f ".env" ]; then
        # Read the variable value from .env file, handling quotes and comments
        var_value=$(grep "^${var_name}=" .env 2>/dev/null | head -n1 | cut -d'=' -f2- | sed 's/^["'\'']//' | sed 's/["'\'']$//')
    fi
    
    echo "$var_value"
}

echo "Reading variables from .env file:"
echo

# Test reading each variable
vars=(
    "STEAM_USERNAME"
    "STEAM_PASSWORD" 
    "MYSQL_ROOT_PASSWORD"
    "MYSQL_DATABASE"
    "MYSQL_USER"
    "MYSQL_PASSWORD"
    "MYSQL_HOST"
    "SERVER_HOSTNAME"
    "SERVER_PASSWORD"
    "SERVER_ADMIN_PASSWORD"
    "SERVER_MAX_PLAYERS"
    "SERVER_PORT"
    "RCON_PASSWORD"
)

for var in "${vars[@]}"; do
    value=$(read_env_var "$var")
    if [ -n "$value" ]; then
        if [[ "$var" == *"PASSWORD"* ]]; then
            echo "✓ $var=***hidden***"
        else
            echo "✓ $var=$value"
        fi
    else
        echo "❌ $var=(empty or not set)"
    fi
done

echo
echo "=== Raw .env file content (first 20 lines) ==="
head -20 .env

echo
echo "=== Lines that might cause issues ==="
# Check for problematic lines
grep -n '[^=]*=[^"]*[[:space:]]' .env || echo "No problematic lines found"

echo
echo "Validation complete."

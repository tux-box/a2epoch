#!/bin/bash

# Test the setup script functionality
echo "Testing setup script..."

# Create a test .env file
cat > test.env << 'EOF'
# Test .env file
STEAM_USERNAME=test_user
STEAM_PASSWORD=test_pass
MYSQL_ROOT_PASSWORD=root123
MYSQL_DATABASE=dayz_epoch
MYSQL_USER=dayz
MYSQL_PASSWORD=dayz123
MYSQL_HOST=mysql
SERVER_HOSTNAME="My Test Server"
SERVER_PASSWORD=
SERVER_ADMIN_PASSWORD=admin123
SERVER_MAX_PLAYERS=50
SERVER_PORT=2302
RCON_PASSWORD=rcon123
EOF

echo "Created test.env file"

# Function to safely read .env file (same as in setup.sh)
read_env_var() {
    local var_name="$1"
    local var_value=""
    local env_file="${2:-test.env}"
    
    if [ -f "$env_file" ]; then
        # Read the variable value from .env file, handling quotes and comments
        var_value=$(grep "^${var_name}=" "$env_file" 2>/dev/null | head -n1 | cut -d'=' -f2- | sed 's/^["'\'']//' | sed 's/["'\'']$//')
    fi
    
    echo "$var_value"
}

# Test reading variables
echo "Testing variable reading:"
echo "STEAM_USERNAME: $(read_env_var "STEAM_USERNAME")"
echo "SERVER_HOSTNAME: $(read_env_var "SERVER_HOSTNAME")"
echo "MYSQL_PASSWORD: $(read_env_var "MYSQL_PASSWORD")"

# Clean up
rm test.env
echo "Test completed successfully!"

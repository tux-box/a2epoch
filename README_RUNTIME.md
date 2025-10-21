# Runtime Installation Approach

## Why Runtime Installation?

The DayZ Epoch Docker setup now uses **runtime installation** instead of build-time installation. This approach has several advantages:

### Benefits:
1. **Faster builds** - No Steam authentication during Docker build
2. **Better security** - Steam credentials only used at runtime
3. **More reliable** - Avoids Docker layer caching issues with Steam
4. **Easier debugging** - Installation logs visible during container startup

## How It Works

### Build Time:
- Installs system dependencies
- Sets up user accounts and directories  
- Copies configuration files and scripts
- Compiles utilities (tolower)

### Runtime (Container Startup):
- Generates configuration from environment variables
- Downloads and installs Arma 2 files via SteamCMD (if not already present)
- Waits for MySQL database to be ready
- Imports database schema (if needed)
- Starts the DayZ Epoch server

## File Persistence

To avoid re-downloading Arma 2 files on every container restart, mount a volume for the server directory:

```yaml
volumes:
  - ./server_data:/home/dayz/server
  - ./config:/home/dayz/server/cfgdayz
  - ./logs:/home/dayz/server/logs
  - ./missions:/home/dayz/server/mpmissions
```

## Troubleshooting Runtime Issues

### Steam Installation Fails
- Check Steam credentials in .env file
- Verify Steam account owns required games
- Check container logs: `docker-compose logs dayz-epoch`

### Database Connection Issues  
- Ensure MySQL container is running: `docker-compose ps`
- Check database credentials in .env file
- Verify network connectivity between containers

### Server Binary Not Found
- Usually indicates Steam installation failed
- Check Steam credentials and account ownership
- Look for error messages in installation logs

## Migration from Build-Time Installation

If you were using the old Dockerfile, simply:

1. Pull the latest changes
2. Rebuild containers: `docker-compose up --build -d`
3. The new runtime approach will be used automatically

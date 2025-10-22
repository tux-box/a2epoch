# Security Guidelines for DayZ Epoch Docker Setup

This document outlines important security considerations when deploying your DayZ Epoch server using Docker.

## Environment Variables Security

### .env File Protection

The `.env` file contains sensitive information and should be protected:

**File Permissions**:
```bash
# Set restrictive permissions on .env file
chmod 600 .env
chown $USER:$USER .env
```

**Git Exclusion**:
- The `.env` file is automatically excluded from Git commits via `.gitignore`
- Never commit actual credentials to version control
- Always use `.env.example` for templates

### Password Security

**Strong Password Requirements**:
- Use passwords with at least 12 characters
- Include uppercase, lowercase, numbers, and special characters
- Avoid dictionary words and personal information
- Use unique passwords for each service

**Password Generation Examples**:
```bash
# Generate secure passwords using openssl
openssl rand -base64 32

# Or use pwgen if available
pwgen -s 16 1
```

## Steam Account Security

### Steam Guard Considerations

**Recommended Approach**:
1. Create a dedicated Steam account for server hosting
2. Purchase required games on this account
3. Enable Steam Guard but prepare for authentication challenges
4. Consider using Steam's family sharing as an alternative

**Authentication Issues**:
- Steam Guard may require additional verification
- Consider temporarily disabling Steam Guard during initial setup
- Use app-specific passwords if available
- Monitor Steam account for unusual activity

### Account Protection

**Best Practices**:
- Use a unique, strong password for your Steam account
- Enable two-factor authentication
- Regularly review account activity
- Don't share Steam credentials

## Database Security

### MySQL Configuration

**Default Security Measures**:
```bash
# Change default passwords immediately
MYSQL_ROOT_PASSWORD=your_very_secure_root_password
MYSQL_PASSWORD=your_secure_dayz_password
```

**Additional Hardening**:
- Disable remote root login in production
- Create specific users with limited privileges
- Regular database backups with encryption
- Monitor database access logs

### Database Access Control

**Network Security**:
```yaml
# In docker-compose.yml, restrict MySQL port exposure
ports:
  - "127.0.0.1:3306:3306"  # Only localhost access
```

## Network Security

### Firewall Configuration

**Essential Rules**:
```bash
# Allow only necessary ports
sudo ufw allow 2302/udp    # DayZ server port
sudo ufw deny 3306/tcp     # Block MySQL from external access
sudo ufw enable
```

**Port Management**:
- Only expose required ports (typically 2302/UDP)
- Use non-standard ports if possible
- Implement rate limiting for connection attempts
- Monitor for unusual traffic patterns

### Docker Network Security

**Container Isolation**:
```yaml
# Use custom networks for better isolation
networks:
  dayz-network:
    driver: bridge
    internal: true  # No external access
```

## Server Administration Security

### RCon Security

**RCon Password Protection**:
- Use strong, unique RCon passwords
- Change RCon passwords regularly
- Limit RCon access to trusted IP addresses
- Monitor RCon usage logs

**Admin Access Control**:
```bash
# Restrict RCon to specific IPs in BattlEye configuration
RConIP 192.168.1.100  # Your admin IP only
```

### BattlEye Configuration

**Anti-Cheat Security**:
- Keep BattlEye filters updated
- Monitor kick/ban logs regularly
- Implement custom detection rules
- Regular server integrity checks

## Container Security

### Docker Security Best Practices

**Image Security**:
- Use official base images only
- Regularly update base images
- Scan images for vulnerabilities
- Minimize installed packages

**Runtime Security**:
```bash
# Run containers with limited privileges
docker run --user 1000:1000 --read-only --tmpfs /tmp
```

**Resource Limits**:
```yaml
# In docker-compose.yml
deploy:
  resources:
    limits:
      memory: 4G
      cpus: '2.0'
```

### File System Security

**Volume Permissions**:
```bash
# Set proper ownership for mounted volumes
sudo chown -R 1000:1000 ./logs ./missions
chmod 755 ./logs ./missions
```

**Sensitive File Protection**:
- Store configuration backups securely
- Encrypt backup archives
- Use secure file transfer methods
- Regular security audits

## Monitoring and Logging

### Security Monitoring

**Log Analysis**:
- Monitor authentication attempts
- Track unusual player behavior
- Review server resource usage
- Implement automated alerting

**Log Retention**:
```bash
# Configure log rotation
echo '{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}' | sudo tee /etc/docker/daemon.json
```

### Incident Response

**Security Incident Checklist**:
1. Isolate affected systems
2. Preserve logs and evidence
3. Change all passwords immediately
4. Review access logs
5. Update security measures
6. Document lessons learned

## Backup Security

### Secure Backup Practices

**Backup Encryption**:
```bash
# Encrypt backups before storage
tar -czf - config/ sql/ | gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output backup.tar.gz.gpg
```

**Backup Storage**:
- Store backups in multiple locations
- Use encrypted storage solutions
- Test backup restoration regularly
- Implement automated backup verification

### Recovery Planning

**Disaster Recovery**:
- Document recovery procedures
- Test recovery processes regularly
- Maintain offline backup copies
- Prepare for various failure scenarios

## Compliance and Legal

### Data Protection

**Player Data**:
- Implement data retention policies
- Secure player information storage
- Provide data deletion capabilities
- Comply with applicable privacy laws

**Server Logs**:
- Define log retention periods
- Implement secure log storage
- Provide audit capabilities
- Document data handling procedures

## Regular Security Maintenance

### Security Checklist

**Monthly Tasks**:
- [ ] Update all passwords
- [ ] Review access logs
- [ ] Update Docker images
- [ ] Check for security patches
- [ ] Verify backup integrity
- [ ] Review firewall rules

**Quarterly Tasks**:
- [ ] Security audit
- [ ] Penetration testing
- [ ] Update security documentation
- [ ] Review incident response procedures
- [ ] Update backup and recovery tests

## Emergency Contacts

**Security Incident Response**:
- Document emergency procedures
- Maintain contact information for key personnel
- Establish communication channels
- Define escalation procedures

## Additional Resources

**Security Tools**:
- [Docker Bench Security](https://github.com/docker/docker-bench-security)
- [Lynis Security Auditing](https://cisofy.com/lynis/)
- [OWASP Security Guidelines](https://owasp.org/)

**Documentation**:
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [MySQL Security Guidelines](https://dev.mysql.com/doc/refman/8.0/en/security-guidelines.html)
- [Steam Security Features](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C)

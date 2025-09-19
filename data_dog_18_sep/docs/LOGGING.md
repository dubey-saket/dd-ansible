# Logging Configuration and Management

This document explains how the DataDog agent deployment project handles logging at all levels.

## Log Storage Structure

```
logs/
├── .gitkeep                    # Ensures directory is tracked by git
├── ansible.log                 # Main Ansible execution logs
├── deployment/                  # Deployment-specific logs
│   ├── dev/                    # Development environment logs
│   ├── staging/                 # Staging environment logs
│   └── prod/                    # Production environment logs
├── agent/                       # DataDog agent logs (from target hosts)
│   ├── web_servers/            # Web server agent logs
│   ├── database_servers/       # Database server agent logs
│   └── application_servers/     # Application server agent logs
└── archive/                     # Archived logs (rotated)
    ├── 2024-01/
    ├── 2024-02/
    └── ...
```

## Ansible Logging Configuration

### Main Configuration (`ansible.cfg`)
```ini
[defaults]
log_path = logs/ansible.log
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
```

### Log Levels
- **INFO**: Standard execution information
- **DEBUG**: Detailed debugging information
- **WARNING**: Non-critical issues
- **ERROR**: Critical failures

## Log Types and Locations

### 1. Ansible Execution Logs
**Location**: `logs/ansible.log`
**Content**: All Ansible playbook execution details
**Format**: YAML with timestamps
**Rotation**: Automatic (configurable)

### 2. Deployment Logs
**Location**: `logs/deployment/{environment}/`
**Content**: Environment-specific deployment logs
**Examples**:
- `logs/deployment/dev/deploy_2024-09-18_14-30-15.log`
- `logs/deployment/prod/deploy_2024-09-18_15-45-22.log`

### 3. Agent Logs (from target hosts)
**Location**: `logs/agent/{group}/{hostname}/`
**Content**: DataDog agent logs from target servers
**Examples**:
- `logs/agent/web_servers/web01.dev.example.com/agent.log`
- `logs/agent/database_servers/db01.dev.example.com/agent.log`

### 4. Script Execution Logs
**Location**: `logs/scripts/`
**Content**: Management script execution logs
**Examples**:
- `logs/scripts/deploy_2024-09-18_14-30-15.log`
- `logs/scripts/validate_2024-09-18_15-45-22.log`

## Log Management Features

### Automatic Log Rotation
```bash
# Log rotation configuration
logs/
├── ansible.log                 # Current log
├── ansible.log.1              # Previous log
├── ansible.log.2              # Older log
└── ansible.log.3              # Oldest log
```

### Log Compression
```bash
# Compressed logs for space efficiency
logs/archive/2024-01/
├── ansible.log.gz
├── deployment_logs.tar.gz
└── agent_logs.tar.gz
```

### Log Retention Policy
- **Current logs**: 7 days
- **Compressed logs**: 30 days
- **Archived logs**: 90 days
- **Permanent logs**: Critical errors only

## Logging in Scripts

### Setup Script Logging
```bash
# Setup script creates log directory
./scripts/setup.sh
# Creates: logs/ directory with proper permissions
```

### Deployment Script Logging
```bash
# Deployment script logs to environment-specific files
./scripts/deploy.sh dev
# Creates: logs/deployment/dev/deploy_$(date).log
```

### Management Script Logging
```bash
# Management scripts log to script-specific files
./scripts/manage.sh status dev
# Creates: logs/scripts/manage_$(date).log
```

### Validation Script Logging
```bash
# Validation scripts log to validation-specific files
./scripts/validate.sh dev
# Creates: logs/validation/validate_$(date).log
```

## Log Analysis and Monitoring

### Real-time Log Monitoring
```bash
# Monitor Ansible logs in real-time
tail -f logs/ansible.log

# Monitor deployment logs
tail -f logs/deployment/dev/deploy_$(date +%Y-%m-%d).log

# Monitor agent logs
tail -f logs/agent/web_servers/web01.dev.example.com/agent.log
```

### Log Analysis Commands
```bash
# Search for errors
grep -i error logs/ansible.log

# Search for warnings
grep -i warning logs/ansible.log

# Search for specific hosts
grep "web01.dev.example.com" logs/ansible.log

# Search for specific operations
grep "datadog-agent" logs/ansible.log
```

### Log Statistics
```bash
# Count log entries by type
grep -c "ERROR" logs/ansible.log
grep -c "WARNING" logs/ansible.log
grep -c "INFO" logs/ansible.log

# Count deployments by environment
ls logs/deployment/dev/ | wc -l
ls logs/deployment/prod/ | wc -l
```

## Log Configuration Examples

### Verbose Logging
```bash
# Enable verbose logging for debugging
./scripts/deploy.sh dev --verbose
# Logs to: logs/deployment/dev/deploy_$(date)_verbose.log
```

### Debug Logging
```bash
# Enable debug logging
ansible-playbook -i inventories/dev playbooks/install_agent.yml -vvv
# Logs to: logs/ansible.log with DEBUG level
```

### Custom Log Locations
```bash
# Custom log location
export ANSIBLE_LOG_PATH=/custom/path/ansible.log
./scripts/deploy.sh dev
```

## Log Rotation and Cleanup

### Automatic Rotation
```bash
# Log rotation script
./scripts/rotate_logs.sh
# Rotates logs older than 7 days
# Compresses logs older than 30 days
# Archives logs older than 90 days
```

### Manual Cleanup
```bash
# Clean old logs
find logs/ -name "*.log" -mtime +7 -delete

# Compress old logs
find logs/ -name "*.log" -mtime +30 -exec gzip {} \;

# Archive old logs
find logs/ -name "*.log.gz" -mtime +90 -exec mv {} logs/archive/ \;
```

## Log Security and Access

### Log Permissions
```bash
# Set proper log permissions
chmod 644 logs/ansible.log
chmod 755 logs/
chmod 600 logs/deployment/prod/*.log
```

### Log Access Control
```bash
# Restrict access to production logs
chmod 600 logs/deployment/prod/
chmod 600 logs/agent/database_servers/
```

### Log Encryption
```bash
# Encrypt sensitive logs
gpg --symmetric logs/deployment/prod/deploy_$(date).log
```

## Troubleshooting with Logs

### Common Log Issues

1. **Permission Denied**
   ```bash
   # Check log directory permissions
   ls -la logs/
   chmod 755 logs/
   ```

2. **Disk Space Issues**
   ```bash
   # Check log directory size
   du -sh logs/
   
   # Clean old logs
   ./scripts/cleanup_logs.sh
   ```

3. **Log Rotation Issues**
   ```bash
   # Check log rotation
   ./scripts/rotate_logs.sh --check
   
   # Force rotation
   ./scripts/rotate_logs.sh --force
   ```

### Log Analysis Tools

1. **Error Detection**
   ```bash
   # Find errors in logs
   grep -i error logs/ansible.log | tail -10
   ```

2. **Performance Analysis**
   ```bash
   # Find slow operations
   grep "timer" logs/ansible.log | grep -v "0.00"
   ```

3. **Host-specific Issues**
   ```bash
   # Find issues for specific host
   grep "web01.dev.example.com" logs/ansible.log | grep -i error
   ```

## Best Practices

### Log Management
1. **Regular rotation**: Rotate logs daily
2. **Compression**: Compress logs older than 30 days
3. **Archival**: Archive logs older than 90 days
4. **Cleanup**: Remove logs older than 1 year

### Log Analysis
1. **Monitor errors**: Set up alerts for error patterns
2. **Performance tracking**: Monitor execution times
3. **Trend analysis**: Track deployment success rates
4. **Capacity planning**: Monitor log growth

### Security
1. **Access control**: Restrict access to sensitive logs
2. **Encryption**: Encrypt logs containing sensitive data
3. **Retention**: Follow data retention policies
4. **Audit**: Log access to log files

## Log Monitoring and Alerting

### Log Monitoring Script
```bash
# Monitor logs for errors
./scripts/monitor_logs.sh
# Checks logs every 5 minutes
# Sends alerts for critical errors
```

### Log Alerting
```bash
# Set up log-based alerts
./scripts/setup_log_alerts.sh
# Configures alerts for:
# - Critical errors
# - Deployment failures
# - Agent issues
```

## Summary

The project implements comprehensive logging at multiple levels:

1. **Ansible logs**: Main execution logs in `logs/ansible.log`
2. **Deployment logs**: Environment-specific logs in `logs/deployment/`
3. **Agent logs**: Target host logs in `logs/agent/`
4. **Script logs**: Management script logs in `logs/scripts/`
5. **Archived logs**: Rotated and compressed logs in `logs/archive/`

All logs are automatically managed with rotation, compression, and archival policies to ensure efficient storage and easy analysis.

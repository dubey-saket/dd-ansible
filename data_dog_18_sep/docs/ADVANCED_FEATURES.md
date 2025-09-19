# Advanced Features Guide

This document covers advanced features including rollback, uninstall, and state management for DataDog checks.

## Rollback Functionality

### Overview
The rollback feature allows you to revert DataDog agents to a previous version. This is useful when a new version causes issues or when you need to quickly restore a known working state.

### Usage

#### Basic Rollback
```bash
# Rollback to a specific version
./scripts/rollback.sh dev 7.69.0

# Rollback production with dry run first
./scripts/rollback.sh prod 7.68.0 --dry-run
./scripts/rollback.sh prod 7.68.0
```

#### Targeted Rollback
```bash
# Rollback only web servers
./scripts/rollback.sh dev 7.69.0 --limit web_servers

# Rollback specific host
./scripts/rollback.sh prod 7.68.0 --limit web01.prod.example.com
```

#### Force Rollback
```bash
# Force rollback without confirmation
./scripts/rollback.sh prod 7.68.0 --force
```

### Rollback Process
1. **Version Check**: Compares current version with target version
2. **Service Stop**: Stops DataDog agent service
3. **Package Removal**: Removes current agent package
4. **Cleanup**: Removes agent files and directories
5. **Package Install**: Installs agent at specified version
6. **Configuration**: Applies configuration from templates
7. **Service Start**: Starts agent service
8. **Verification**: Confirms rollback success

### Windows Limitation
**Note**: Rollback does not work on Windows systems. The script will detect Windows hosts and skip them during rollback.

## Uninstall Functionality

### Overview
The uninstall feature completely removes DataDog agents from target hosts, with options to remove configuration files and logs.

### Usage

#### Basic Uninstall
```bash
# Uninstall from development
./scripts/uninstall.sh dev

# Uninstall from production with dry run
./scripts/uninstall.sh prod --dry-run
./scripts/uninstall.sh prod
```

#### Complete Removal
```bash
# Remove agent, config, and logs
./scripts/uninstall.sh dev --remove-config --remove-logs

# Force complete removal
./scripts/uninstall.sh prod --force --remove-config --remove-logs
```

#### Targeted Uninstall
```bash
# Uninstall only database servers
./scripts/uninstall.sh dev --limit database_servers

# Uninstall specific host
./scripts/uninstall.sh prod --limit db01.prod.example.com
```

### Uninstall Process
1. **Service Stop**: Stops and disables DataDog agent service
2. **Package Removal**: Removes DataDog agent package
3. **File Cleanup**: Removes agent files (optional)
4. **Log Cleanup**: Removes log files (optional)
5. **User Cleanup**: Removes agent user and group (optional)
6. **Repository Cleanup**: Removes DataDog repository
7. **Cache Cleanup**: Cleans package cache
8. **Verification**: Confirms uninstall success

## State Management for DataDog Checks

### Overview
The state management feature ensures that DataDog checks match the desired state defined in your Ansible playbooks. It automatically adds, removes, and updates checks based on your configuration.

### Workflow

#### 1. Desired State Definition
Define your desired checks in inventory files:

```yaml
# inventories/dev/group_vars/web_servers.yml
group_datadog_checks:
  nginx:
    init_config:
    instances:
      - nginx_status_url: http://localhost/nginx_status
        tags:
          - "service:nginx"
          - "role:web"
  
  apache:
    init_config:
    instances:
      - apache_status_url: http://localhost/server-status
        tags:
          - "service:apache"
          - "role:web"
```

#### 2. Current State Detection
The system queries DataDog API to get current checks:

```bash
# Get current checks
curl -H "DD-API-KEY: your_api_key" \
     https://api.datadoghq.com/api/v1/check
```

#### 3. State Comparison
Compares desired state with current state:
- **Checks to add**: Present in desired state, missing in current state
- **Checks to remove**: Present in current state, missing in desired state
- **Checks to update**: Present in both but configuration differs

#### 4. State Synchronization
Executes changes to bring current state in line with desired state:
- **Add checks**: Creates new checks via DataDog API
- **Remove checks**: Deletes orphaned checks via DataDog API
- **Update checks**: Updates existing checks via DataDog API

#### 5. Verification
Verifies that changes were applied correctly:
- **Add verification**: Confirms new checks exist
- **Remove verification**: Confirms removed checks no longer exist
- **Update verification**: Confirms updated checks have new configuration

### Usage

#### Basic Check Management
```bash
# Manage checks in development
./scripts/manage_checks.sh dev

# Manage checks in production with dry run
./scripts/manage_checks.sh prod --dry-run
./scripts/manage_checks.sh prod
```

#### Advanced Check Management
```bash
# Don't remove orphaned checks
./scripts/manage_checks.sh dev --no-remove-orphaned

# Don't verify check removal
./scripts/manage_checks.sh prod --no-verify-removal

# Manage specific groups
./scripts/manage_checks.sh dev --limit web_servers
```

### Check Management Process

#### 1. Pre-Tasks
- **Variable Validation**: Ensures required variables are present
- **API Key Validation**: Verifies DataDog API access
- **Desired State Display**: Shows what checks should exist

#### 2. Current State Retrieval
- **API Query**: Gets current checks from DataDog
- **State Parsing**: Processes API response
- **Current State Display**: Shows existing checks

#### 3. State Comparison
- **Add Identification**: Finds checks to add
- **Remove Identification**: Finds checks to remove
- **Update Identification**: Finds checks to update

#### 4. State Synchronization
- **Add Checks**: Creates new checks via API
- **Remove Checks**: Deletes orphaned checks via API
- **Update Checks**: Updates existing checks via API

#### 5. Verification
- **Add Verification**: Confirms new checks exist
- **Remove Verification**: Confirms removed checks are gone
- **Final State**: Shows final check state

### Safety Features

#### Dry Run Mode
```bash
# See what would be changed without making changes
./scripts/manage_checks.sh prod --dry-run
```

#### Orphaned Check Protection
```bash
# Don't remove orphaned checks
./scripts/manage_checks.sh prod --no-remove-orphaned
```

#### Verification Control
```bash
# Skip removal verification
./scripts/manage_checks.sh prod --no-verify-removal
```

### Best Practices

#### 1. Check Definition
- **Group Level**: Define common checks in group_vars
- **Host Level**: Override with host-specific checks in host_vars
- **Environment Level**: Use environment-specific configurations

#### 2. State Management
- **Regular Sync**: Run check management regularly
- **Dry Run First**: Always dry run before production changes
- **Monitor Changes**: Watch for unexpected check removals

#### 3. Safety Measures
- **Backup State**: Save current state before changes
- **Gradual Changes**: Make changes incrementally
- **Verification**: Always verify changes were applied

### Troubleshooting

#### Common Issues

1. **API Access Denied**
   ```bash
   # Check API key
   ansible-vault view vault/vault.yml
   
   # Test API access
   curl -H "DD-API-KEY: your_key" https://api.datadoghq.com/api/v1/check
   ```

2. **Check Creation Failed**
   ```bash
   # Check check configuration
   ./scripts/manage_checks.sh dev --verbose
   
   # Verify check syntax
   ansible-playbook -i inventories/dev playbooks/manage_checks.yml --check
   ```

3. **Check Removal Failed**
   ```bash
   # Check if check exists
   curl -H "DD-API-KEY: your_key" https://api.datadoghq.com/api/v1/check/check_name
   
   # Force removal
   ./scripts/manage_checks.sh dev --no-verify-removal
   ```

#### Debug Mode
```bash
# Verbose output
./scripts/manage_checks.sh dev --verbose

# Check mode
./scripts/manage_checks.sh dev --dry-run
```

## Integration with Existing Workflow

### Deployment Integration
```bash
# Deploy agents
./scripts/deploy.sh dev

# Manage checks
./scripts/manage_checks.sh dev

# Verify deployment
./scripts/validate.sh dev
```

### Maintenance Integration
```bash
# Check status
./scripts/manage.sh status dev

# Manage checks
./scripts/manage_checks.sh dev

# Validate state
./scripts/validate.sh dev
```

### Rollback Integration
```bash
# Rollback agent
./scripts/rollback.sh dev 7.69.0

# Manage checks for new version
./scripts/manage_checks.sh dev

# Verify rollback
./scripts/validate.sh dev
```

## Security Considerations

### API Key Management
- **Vault Encryption**: Store API keys in encrypted vault
- **Access Control**: Limit API key permissions
- **Rotation**: Regularly rotate API keys

### Check Management
- **Validation**: Validate check configurations
- **Testing**: Test checks in development first
- **Monitoring**: Monitor check changes

### State Management
- **Backup**: Backup current state before changes
- **Audit**: Log all state changes
- **Recovery**: Plan for state recovery

## Summary

The advanced features provide:

1. **Rollback**: Safe version rollback with Windows detection
2. **Uninstall**: Complete agent removal with cleanup options
3. **State Management**: Automated check synchronization with verification
4. **Safety**: Dry run, verification, and error handling
5. **Integration**: Seamless integration with existing workflows

These features ensure reliable, safe, and automated management of DataDog agents and checks across your infrastructure.

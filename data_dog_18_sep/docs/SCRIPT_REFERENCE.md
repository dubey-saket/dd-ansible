# Script Reference Guide

This document provides a comprehensive reference for all management scripts included in this DataDog agent deployment solution.

## Available Scripts

### 1. Setup Script (`scripts/setup.sh`)

**Purpose**: Initial environment setup and validation

**Usage**:
```bash
./scripts/setup.sh
```

**Features**:
- Checks prerequisites (Ansible, Python, SSH)
- Creates required directories
- Installs Ansible collections
- Validates vault file encryption
- Creates example inventory
- Sets up environment variables

**Output**:
- Creates `logs/` directory
- Creates `.ansible/facts_cache/` directory
- Installs DataDog collection
- Creates example inventory if missing
- Creates `.env.example` file

### 2. Deployment Script (`scripts/deploy.sh`)

**Purpose**: Deploy DataDog agents to specified environments

**Usage**:
```bash
./scripts/deploy.sh [OPTIONS] ENVIRONMENT
```

**Parameters**:
- `ENVIRONMENT`: `dev`, `staging`, or `prod`
- `-l, --limit HOSTS`: Limit to specific hosts or groups
- `-d, --dry-run`: Perform dry run (check mode)
- `-v, --verbose`: Enable verbose output
- `--no-vault-pass`: Don't ask for vault password
- `--become-pass`: Ask for become password

**Examples**:
```bash
# Deploy to development
./scripts/deploy.sh dev

# Deploy to specific group
./scripts/deploy.sh dev --limit web_servers

# Dry run on production
./scripts/deploy.sh prod --dry-run

# Verbose deployment
./scripts/deploy.sh dev --verbose
```

**Features**:
- Tests connectivity before deployment
- Supports dry run mode
- Production safety checks
- Comprehensive error handling
- Post-deployment verification

### 3. Management Script (`scripts/manage.sh`)

**Purpose**: Manage DataDog agent services

**Usage**:
```bash
./scripts/manage.sh OPERATION [OPTIONS] ENVIRONMENT
```

**Operations**:
- `start`: Start DataDog agent service
- `stop`: Stop DataDog agent service
- `restart`: Restart DataDog agent service
- `status`: Show agent status
- `logs`: Show agent logs
- `config`: Show agent configuration
- `version`: Show agent version
- `reload`: Reload agent configuration
- `check`: Check agent configuration
- `health`: Check agent health
- `tags`: Show agent tags
- `metrics`: Show agent metrics

**Examples**:
```bash
# Start agents in dev
./scripts/manage.sh start dev

# Check status
./scripts/manage.sh status dev

# Show logs
./scripts/manage.sh logs dev

# Restart specific group
./scripts/manage.sh restart prod --limit web_servers
```

### 4. Validation Script (`scripts/validate.sh`)

**Purpose**: Validate DataDog agent installation and configuration

**Usage**:
```bash
./scripts/validate.sh [OPTIONS] ENVIRONMENT
```

**Options**:
- `-l, --limit HOSTS`: Limit to specific hosts
- `-v, --verbose`: Enable verbose output
- `--no-agent`: Skip agent status checks
- `--no-config`: Skip configuration checks
- `--no-logs`: Skip log checks
- `--dashboard`: Check DataDog dashboard

**Examples**:
```bash
# Validate all dev hosts
./scripts/validate.sh dev

# Validate specific group
./scripts/validate.sh prod --limit web_servers

# Verbose validation
./scripts/validate.sh dev --verbose

# Include dashboard check
./scripts/validate.sh dev --dashboard
```

**Features**:
- Connectivity testing
- Agent status verification
- Configuration validation
- Log analysis
- Dashboard integration

### 5. Backup Script (`scripts/backup.sh`)

**Purpose**: Backup inventory, configuration, and vault files

**Usage**:
```bash
./scripts/backup.sh [OPTIONS]
```

**Options**:
- `-d, --dir DIRECTORY`: Backup directory
- `--include-vault`: Include vault files
- `--compress`: Compress backup
- `-v, --verbose`: Enable verbose output

**Examples**:
```bash
# Basic backup
./scripts/backup.sh

# Full backup with compression
./scripts/backup.sh --include-vault --compress

# Custom backup directory
./scripts/backup.sh --dir /path/to/backup
```

**Features**:
- Comprehensive backup of all files
- Optional vault inclusion
- Compression support
- Backup manifest creation
- Security warnings

### 6. Restore Script (`scripts/restore.sh`)

**Purpose**: Restore from backup

**Usage**:
```bash
./scripts/restore.sh [OPTIONS] BACKUP_PATH
```

**Options**:
- `-f, --force`: Force restore (overwrite)
- `-v, --verbose`: Enable verbose output

**Examples**:
```bash
# Restore from directory
./scripts/restore.sh /path/to/backup

# Restore from compressed backup
./scripts/restore.sh backup.tar.gz

# Force restore
./scripts/restore.sh /path/to/backup --force
```

**Features**:
- Supports compressed backups
- Conflict detection
- Permission setting
- Comprehensive validation

## Quick Reference

### Common Workflows

#### 1. Initial Setup
```bash
# Run setup
./scripts/setup.sh

# Configure vault
ansible-vault encrypt vault/vault.yml
ansible-vault edit vault/vault.yml

# Update inventory
vim inventories/dev/hosts.yml

# Test connectivity
ansible -i inventories/dev all -m ping
```

#### 2. Development Deployment
```bash
# Deploy to dev
./scripts/deploy.sh dev

# Check status
./scripts/manage.sh status dev

# Validate installation
./scripts/validate.sh dev
```

#### 3. Production Deployment
```bash
# Dry run first
./scripts/deploy.sh prod --dry-run

# Deploy to production
./scripts/deploy.sh prod

# Verify deployment
./scripts/validate.sh prod
```

#### 4. Maintenance
```bash
# Check agent health
./scripts/manage.sh health prod

# View logs
./scripts/manage.sh logs prod

# Restart if needed
./scripts/manage.sh restart prod
```

#### 5. Backup and Restore
```bash
# Create backup
./scripts/backup.sh --include-vault --compress

# Restore from backup
./scripts/restore.sh backup.tar.gz --force
```

### Error Handling

#### Common Issues and Solutions

1. **SSH Connection Failed**
   ```bash
   # Test SSH manually
   ssh user@server
   
   # Test with Ansible
   ansible -i inventories/dev all -m ping -vvv
   ```

2. **Vault Password Issues**
   ```bash
   # Test vault file
   ansible-vault view vault/vault.yml
   
   # Re-encrypt if needed
   ansible-vault rekey vault/vault.yml
   ```

3. **Agent Not Starting**
   ```bash
   # Check status
   ./scripts/manage.sh status dev
   
   # Check logs
   ./scripts/manage.sh logs dev
   
   # Restart agent
   ./scripts/manage.sh restart dev
   ```

4. **Deployment Failures**
   ```bash
   # Check logs
   tail -f logs/ansible.log
   
   # Verbose deployment
   ./scripts/deploy.sh dev --verbose
   
   # Validate configuration
   ./scripts/validate.sh dev
   ```

### Best Practices

1. **Always test in development first**
2. **Use dry run for production deployments**
3. **Regular backups before major changes**
4. **Monitor logs for issues**
5. **Validate deployments after completion**
6. **Keep vault files secure**
7. **Document any custom configurations**

### Troubleshooting

#### Debug Mode
```bash
# Verbose deployment
./scripts/deploy.sh dev --verbose

# Verbose validation
./scripts/validate.sh dev --verbose

# Verbose management
./scripts/manage.sh logs dev --verbose
```

#### Log Analysis
```bash
# Check Ansible logs
tail -f logs/ansible.log

# Check agent logs
./scripts/manage.sh logs dev

# Check for errors
./scripts/manage.sh logs dev | grep -i error
```

#### Health Checks
```bash
# Check agent health
./scripts/manage.sh health dev

# Check configuration
./scripts/manage.sh check dev

# Check tags
./scripts/manage.sh tags dev
```

## Support

For additional help:
1. Check logs in `logs/ansible.log`
2. Review documentation in `docs/` directory
3. Test in development environment first
4. Use verbose mode for debugging
5. Verify SSH connectivity and permissions

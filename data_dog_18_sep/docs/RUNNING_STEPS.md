# Running Steps Guide

This document provides step-by-step instructions for running the DataDog agent deployment solution.

## Prerequisites

Before running any scripts, ensure you have:

1. **Ansible 2.9+** installed
2. **SSH access** to target servers
3. **DataDog API key**
4. **Sudo access** on target servers

## Step-by-Step Execution

### Phase 1: Initial Setup (5 minutes)

#### 1.1 Run Setup Script
```bash
cd /Users/saketdubey/Downloads/data_dog_18_sep
./scripts/setup.sh
```

**What this does**:
- Checks prerequisites
- Creates required directories
- Installs Ansible collections
- Creates example inventory
- Sets up environment

#### 1.2 Configure Vault
```bash
# Encrypt vault file
ansible-vault encrypt vault/vault.yml

# Edit vault file
ansible-vault edit vault/vault.yml
```

**Add your DataDog API key**:
```yaml
---
datadog_api_key: "your_actual_datadog_api_key_here"
```

#### 1.3 Update Inventory
Edit `inventories/dev/hosts.yml` with your server details:

```yaml
all:
  children:
    web_servers:
      hosts:
        web01.dev.example.com:
          ansible_host: YOUR_SERVER_IP
          ansible_user: YOUR_SSH_USER
```

### Phase 2: Connectivity Testing (2 minutes)

#### 2.1 Test SSH Connection
```bash
# Test individual server
ssh user@your-server

# Test with Ansible
ansible -i inventories/dev all -m ping
```

#### 2.2 Verify Sudo Access
```bash
# Test sudo access
ansible -i inventories/dev all -m shell -a "sudo whoami"
```

### Phase 3: Deployment (10 minutes)

#### 3.1 Development Deployment
```bash
# Deploy to development
./scripts/deploy.sh dev

# Or dry run first
./scripts/deploy.sh dev --dry-run
```

#### 3.2 Production Deployment
```bash
# Always dry run first
./scripts/deploy.sh prod --dry-run

# Deploy to production
./scripts/deploy.sh prod
```

### Phase 4: Verification (5 minutes)

#### 4.1 Check Agent Status
```bash
# Check if agents are running
./scripts/manage.sh status dev

# Check agent version
./scripts/manage.sh version dev
```

#### 4.2 Validate Installation
```bash
# Run comprehensive validation
./scripts/validate.sh dev

# Check specific group
./scripts/validate.sh dev --limit web_servers
```

#### 4.3 Check DataDog Dashboard
1. Log into your DataDog dashboard
2. Navigate to Infrastructure → Host Map
3. Verify hosts appear with correct tags

## Common Running Scenarios

### Scenario 1: First-Time Deployment

```bash
# 1. Setup
./scripts/setup.sh

# 2. Configure vault
ansible-vault encrypt vault/vault.yml
ansible-vault edit vault/vault.yml

# 3. Update inventory
vim inventories/dev/hosts.yml

# 4. Test connectivity
ansible -i inventories/dev all -m ping

# 5. Deploy
./scripts/deploy.sh dev

# 6. Verify
./scripts/validate.sh dev
```

### Scenario 2: Production Deployment

```bash
# 1. Dry run
./scripts/deploy.sh prod --dry-run

# 2. Deploy
./scripts/deploy.sh prod

# 3. Verify
./scripts/validate.sh prod

# 4. Check dashboard
# Log into DataDog dashboard
```

### Scenario 3: Maintenance

```bash
# 1. Check status
./scripts/manage.sh status prod

# 2. Check logs
./scripts/manage.sh logs prod

# 3. Restart if needed
./scripts/manage.sh restart prod

# 4. Validate
./scripts/validate.sh prod
```

### Scenario 4: Troubleshooting

```bash
# 1. Check connectivity
ansible -i inventories/dev all -m ping -vvv

# 2. Check vault
ansible-vault view vault/vault.yml

# 3. Verbose deployment
./scripts/deploy.sh dev --verbose

# 4. Check logs
tail -f logs/ansible.log
```

## Environment-Specific Steps

### Development Environment

```bash
# Deploy to dev
./scripts/deploy.sh dev

# Check status
./scripts/manage.sh status dev

# View logs
./scripts/manage.sh logs dev

# Validate
./scripts/validate.sh dev
```

### Staging Environment

```bash
# Deploy to staging
./scripts/deploy.sh staging

# Check status
./scripts/manage.sh status staging

# Validate
./scripts/validate.sh staging
```

### Production Environment

```bash
# Always dry run first
./scripts/deploy.sh prod --dry-run

# Deploy to production
./scripts/deploy.sh prod

# Verify deployment
./scripts/validate.sh prod

# Check dashboard
# Log into DataDog dashboard
```

## Group-Specific Deployment

### Web Servers Only
```bash
./scripts/deploy.sh dev --limit web_servers
./scripts/validate.sh dev --limit web_servers
```

### Database Servers Only
```bash
./scripts/deploy.sh dev --limit database_servers
./scripts/validate.sh dev --limit database_servers
```

### Application Servers Only
```bash
./scripts/deploy.sh dev --limit application_servers
./scripts/validate.sh dev --limit application_servers
```

## Host-Specific Deployment

### Single Host
```bash
./scripts/deploy.sh dev --limit web01.dev.example.com
./scripts/validate.sh dev --limit web01.dev.example.com
```

### Multiple Specific Hosts
```bash
./scripts/deploy.sh dev --limit "web01.dev.example.com,db01.dev.example.com"
./scripts/validate.sh dev --limit "web01.dev.example.com,db01.dev.example.com"
```

## Monitoring and Maintenance

### Daily Checks
```bash
# Check agent status
./scripts/manage.sh status prod

# Check logs for errors
./scripts/manage.sh logs prod | grep -i error

# Check agent health
./scripts/manage.sh health prod
```

### Weekly Maintenance
```bash
# Full validation
./scripts/validate.sh prod

# Check agent metrics
./scripts/manage.sh metrics prod

# Check agent tags
./scripts/manage.sh tags prod
```

### Monthly Maintenance
```bash
# Create backup
./scripts/backup.sh --include-vault --compress

# Update agent version
# Edit vars/versions.yml
# Redeploy
./scripts/deploy.sh prod
```

## Error Recovery

### Agent Not Starting
```bash
# Check status
./scripts/manage.sh status dev

# Check logs
./scripts/manage.sh logs dev

# Restart agent
./scripts/manage.sh restart dev

# Check configuration
./scripts/manage.sh check dev
```

### Deployment Failures
```bash
# Check Ansible logs
tail -f logs/ansible.log

# Verbose deployment
./scripts/deploy.sh dev --verbose

# Validate configuration
./scripts/validate.sh dev
```

### SSH Issues
```bash
# Test SSH manually
ssh user@server

# Test with Ansible
ansible -i inventories/dev all -m ping -vvv

# Check SSH keys
ssh-keygen -l -f ~/.ssh/id_rsa.pub
```

## Best Practices

### Before Deployment
1. **Test in development first**
2. **Verify inventory configuration**
3. **Check SSH connectivity**
4. **Validate vault file**
5. **Run dry run for production**

### During Deployment
1. **Monitor logs in real-time**
2. **Use verbose mode for debugging**
3. **Deploy in small batches**
4. **Verify each step**

### After Deployment
1. **Validate installation**
2. **Check DataDog dashboard**
3. **Monitor agent logs**
4. **Set up alerts**

### Maintenance
1. **Regular health checks**
2. **Monitor logs for errors**
3. **Keep backups current**
4. **Update documentation**

## Troubleshooting Checklist

### Connectivity Issues
- [ ] SSH keys configured
- [ ] Network connectivity
- [ ] Firewall rules
- [ ] User permissions

### Vault Issues
- [ ] Vault file encrypted
- [ ] API key correct
- [ ] Vault password correct
- [ ] File permissions

### Agent Issues
- [ ] Agent installed
- [ ] Service running
- [ ] Configuration valid
- [ ] Logs accessible

### Deployment Issues
- [ ] Inventory correct
- [ ] Playbook valid
- [ ] Dependencies installed
- [ ] Permissions set

## Support

For additional help:
1. Check logs in `logs/ansible.log`
2. Review documentation in `docs/` directory
3. Test in development environment first
4. Use verbose mode for debugging
5. Verify SSH connectivity and permissions

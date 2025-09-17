# DataDog Agent Deployment Guide

This guide provides step-by-step instructions for deploying DataDog agents using the modernized Ansible playbook.

## Prerequisites

Before starting, ensure you have:

1. **Ansible installed** (version 2.9 or later)
2. **Python 3.6+** for monitoring scripts
3. **SSH access** to all target servers
4. **DataDog API key** from your DataDog dashboard
5. **Teams webhook URL** (optional, for notifications)

## Initial Setup

### 1. Install Requirements

```bash
# Install Ansible collections
make install

# Install Python dependencies
pip install -r requirements.txt
```

### 2. Configure Vault Files

```bash
# Initialize vault files from examples
make vault-init

# Edit and encrypt vault files
ansible-vault edit vault/dev.yml
ansible-vault edit vault/staging.yml
ansible-vault edit vault/prod.yml
```

**Required vault variables:**
- `vault_datadog_api_key`: Your DataDog API key
- `vault_datadog_site`: DataDog site (e.g., datadoghq.com)
- `vault_webhook_url`: Teams webhook URL (optional)
- `vault_company_name`: Your company name

### 3. Configure Inventories

Update inventory files with your server information:

```bash
# Edit development inventory
vim inventories/dev/hosts.yml

# Edit staging inventory  
vim inventories/staging/hosts.yml

# Edit production inventory
vim inventories/prod/hosts.yml
```

**Example inventory structure:**
```yaml
all:
  children:
    dev_servers:
      hosts:
        dev-web-01:
          ansible_host: 192.168.1.10
          datadog_host_tags:
            - "role:web"
            - "service:nginx"
```

## Deployment Process

### Development Environment

```bash
# 1. Validate configuration
./scripts/deploy.sh dev --check

# 2. Deploy with dry run first
./scripts/deploy.sh dev --dry-run

# 3. Deploy to development
./scripts/deploy.sh dev

# 4. Monitor deployment
python3 scripts/monitor_deployment.py dev
```

### Staging Environment

```bash
# 1. Deploy to staging
./scripts/deploy.sh staging

# 2. Verify deployment
ansible staging_servers -i inventories/staging/hosts.yml -m command -a "datadog-agent status"
```

### Production Environment

```bash
# 1. Deploy to production (with confirmation)
make deploy-prod

# 2. Monitor deployment closely
python3 scripts/monitor_deployment.py prod -i 15 -d 7200
```

## Configuration Customization

### Environment-Specific Settings

Each environment can be customized by editing the respective files:

**Development** (`vars/environments/dev.yml`):
- Relaxed batch sizes (50%)
- Debug logging enabled
- Webhook notifications disabled

**Staging** (`vars/environments/staging.yml`):
- Moderate batch sizes (25%)
- Warning level logging
- Webhook notifications enabled

**Production** (`vars/environments/prod.yml`):
- Conservative batch sizes (10%)
- Error level logging
- Enhanced monitoring enabled

### Custom Checks

Add custom DataDog checks by updating environment-specific files:

```yaml
datadog_checks_dev:
  http_check:
    init_config:
    instances:
      - name: "My Custom Check"
        url: "http://localhost:8080/health"
        timeout: 10
        tags:
          - "env:dev"
          - "service:myapp"
```

### Host-Specific Configuration

Override settings per host in inventory files:

```yaml
prod-web-01:
  ansible_host: 10.0.1.10
  datadog_host_tags:
    - "role:web"
    - "service:nginx"
    - "critical:true"
  datadog_log_level: "ERROR"
  batch_size: "5%"
```

## Monitoring and Notifications

### Webhook Configuration

Configure Teams webhook notifications:

1. Create a Teams webhook in your Teams channel
2. Add the URL to vault files
3. Enable notifications in environment configs

```yaml
# In vault files
vault_webhook_url: "https://your-teams-webhook-url"

# In environment files
monitoring:
  webhook_enabled: true
```

### Log Monitoring

Deployment logs are stored in multiple locations:

- **Project logs**: `logs/deployment_*.log`
- **System logs**: `/var/log/datadog-deployment/`
- **Agent logs**: `/var/log/datadog-agent/`

### Health Checks

The playbook includes automatic health checks:

1. **Pre-deployment**: System resources, network connectivity
2. **Post-deployment**: Agent status, configuration validation
3. **Ongoing**: Service monitoring, connectivity tests

## Rollback Procedures

### Automatic Rollback

```bash
# Rollback to previous version
./scripts/rollback.sh dev

# Rollback to specific version
./scripts/rollback.sh staging 7.69.0

# Dry run rollback
./scripts/rollback.sh prod --dry-run
```

### Manual Rollback

If automatic rollback fails:

1. **Stop the agent service**:
   ```bash
   ansible all -i inventories/prod/hosts.yml -m systemd -a "name=datadog-agent state=stopped"
   ```

2. **Restore from backup**:
   ```bash
   # Find backup files
   ls -la /tmp/datadog-backup-*
   
   # Restore configuration
   tar -xzf /tmp/datadog-backup-*.tar.gz -C /
   ```

3. **Reinstall previous version**:
   ```bash
   # Use the rollback script with specific version
   ./scripts/rollback.sh prod 7.69.0 --force
   ```

## Troubleshooting

### Common Issues

#### Agent Installation Fails

**Symptoms**: Agent service fails to start or install

**Solutions**:
1. Check system requirements:
   ```bash
   ansible all -i inventories/dev/hosts.yml -m setup -a "filter=ansible_memtotal_mb"
   ```

2. Verify network connectivity:
   ```bash
   ansible all -i inventories/dev/hosts.yml -m ping
   ```

3. Check package repository access:
   ```bash
   ansible all -i inventories/dev/hosts.yml -m command -a "curl -I https://yum.datadoghq.com/"
   ```

#### Configuration Issues

**Symptoms**: Agent starts but doesn't send data

**Solutions**:
1. Validate configuration:
   ```bash
   ./scripts/deploy.sh dev --tags validation
   ```

2. Check agent configuration:
   ```bash
   ansible all -i inventories/dev/hosts.yml -m command -a "datadog-agent configcheck"
   ```

3. Verify API key:
   ```bash
   ansible all -i inventories/dev/hosts.yml -m command -a "datadog-agent status"
   ```

#### Performance Issues

**Symptoms**: High system load during deployment

**Solutions**:
1. Reduce batch size:
   ```bash
   ./scripts/deploy.sh prod --batch-size 5%
   ```

2. Check system resources:
   ```bash
   ansible all -i inventories/prod/hosts.yml -m command -a "uptime"
   ```

3. Monitor deployment:
   ```bash
   python3 scripts/monitor_deployment.py prod -i 10
   ```

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
# Deploy with verbose output
./scripts/deploy.sh dev -vvv

# Check specific host
ansible dev-web-01 -i inventories/dev/hosts.yml -m setup -a "filter=ansible_distribution"

# Validate configuration
ansible-playbook --check --diff playbooks/datadog_agent.yml -i inventories/dev/hosts.yml -e target_environment=dev
```

### Log Analysis

Analyze deployment logs:

```bash
# View recent deployments
ls -la logs/

# Check deployment status
tail -f logs/deployment_*.log

# Analyze error patterns
grep -i error logs/deployment_*.log

# Check troubleshooting information
ls -la /var/log/datadog-deployment/troubleshooting/
```

## Best Practices

### Pre-Deployment

1. **Always test in development first**
2. **Use dry-run mode for validation**
3. **Verify vault files are encrypted**
4. **Check inventory accuracy**
5. **Ensure SSH access works**

### During Deployment

1. **Monitor deployment progress**
2. **Watch system resources**
3. **Check for error notifications**
4. **Validate each batch completion**
5. **Document any issues**

### Post-Deployment

1. **Verify agent functionality**
2. **Check DataDog dashboard**
3. **Monitor system performance**
4. **Update documentation**
5. **Plan next deployment**

### Security

1. **Encrypt all vault files**
2. **Use SSH keys for authentication**
3. **Limit sudo privileges**
4. **Regular security updates**
5. **Audit access logs**

## Maintenance

### Regular Tasks

1. **Update agent versions** (quarterly)
2. **Review and update configurations**
3. **Clean up old log files**
4. **Test rollback procedures**
5. **Update documentation**

### Monitoring

1. **Set up proper alerting**
2. **Monitor deployment metrics**
3. **Track system performance**
4. **Regular health checks**
5. **Document incidents**

## Support

For additional support:

1. **Check the troubleshooting section**
2. **Review log files**
3. **Validate configuration**
4. **Test with dry-run mode**
5. **Contact the team**

Remember: Always test changes in development before deploying to production!

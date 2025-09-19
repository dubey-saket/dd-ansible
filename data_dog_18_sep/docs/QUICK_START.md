# Quick Start Guide

This guide provides the fastest way to get DataDog agents deployed using this Ansible playbook.

## Prerequisites

- Ansible 2.9+
- SSH access to target servers
- DataDog API key

## 1. Initial Setup (5 minutes)

```bash
# Navigate to project directory
cd /Users/saketdubey/Downloads/data_dog_18_sep

# Run setup script
./scripts/setup.sh

# Install required collections
ansible-galaxy collection install -r roles/requirements.yml --force
```

## 2. Configure Vault (2 minutes)

```bash
# Encrypt vault file
ansible-vault encrypt vault/vault.yml

# Edit vault file to add your API key
ansible-vault edit vault/vault.yml
```

**Add your DataDog API key:**
```yaml
---
datadog_api_key: "your_actual_datadog_api_key_here"
```

## 3. Update Inventory (5 minutes)

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

## 4. Test Connectivity (1 minute)

```bash
# Test SSH connection
ansible -i inventories/dev all -m ping
```

## 5. Deploy Agents (5 minutes)

```bash
# Deploy to development
./scripts/deploy.sh dev

# Or deploy to specific group
./scripts/deploy.sh dev --limit web_servers

# Or dry run first
./scripts/deploy.sh dev --dry-run
```

## 6. Verify Installation (2 minutes)

```bash
# Check agent status
./scripts/manage.sh status dev

# Check agent logs
./scripts/manage.sh logs dev

# Validate installation
./scripts/validate.sh dev
```

## 7. Check DataDog Dashboard

1. Log into your DataDog dashboard
2. Navigate to Infrastructure → Host Map
3. Verify your hosts appear with correct tags

## Common Commands

### Deployment
```bash
# Deploy to all environments
./scripts/deploy.sh dev
./scripts/deploy.sh staging
./scripts/deploy.sh prod

# Deploy with safety checks
./scripts/deploy.sh prod --dry-run
./scripts/deploy.sh prod --verbose
```

### Management
```bash
# Start/stop/restart agents
./scripts/manage.sh start dev
./scripts/manage.sh stop dev
./scripts/manage.sh restart dev

# Check status and logs
./scripts/manage.sh status dev
./scripts/manage.sh logs dev
./scripts/manage.sh version dev
```

### Validation
```bash
# Validate installation
./scripts/validate.sh dev
./scripts/validate.sh dev --verbose
./scripts/validate.sh dev --dashboard
```

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Test SSH manually
   ssh user@your-server
   
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
   # Check agent status
   ./scripts/manage.sh status dev
   
   # Check logs
   ./scripts/manage.sh logs dev
   
   # Restart agent
   ./scripts/manage.sh restart dev
   ```

### Debug Mode

```bash
# Verbose deployment
./scripts/deploy.sh dev --verbose

# Verbose validation
./scripts/validate.sh dev --verbose

# Verbose management
./scripts/manage.sh logs dev --verbose
```

## Next Steps

1. **Set up monitoring**: Configure alerts and dashboards in DataDog
2. **Scale up**: Add more servers to your inventory
3. **Customize**: Modify group_vars and host_vars for your needs
4. **Automate**: Set up CI/CD pipelines for automated deployments

## Support

- Check logs in `logs/ansible.log`
- Review documentation in `docs/` directory
- Test changes in development environment first
- Use verbose mode for debugging

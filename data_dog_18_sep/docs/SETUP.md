# DataDog Agent Setup Guide

This guide provides step-by-step instructions for setting up and deploying DataDog agents using Ansible.

## Prerequisites

### System Requirements
- Ansible 2.9+ (recommended: 2.12+)
- Python 3.6+
- SSH access to target servers
- DataDog account with API key

### Required Software
```bash
# Install Ansible
pip install ansible

# Or using package manager
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# CentOS/RHEL
sudo yum install ansible

# macOS
brew install ansible
```

## Initial Setup

### 1. Clone and Navigate to Repository
```bash
cd /Users/saketdubey/Downloads/data_dog_18_sep
```

### 2. Install Required Collections
```bash
# Install DataDog collection
ansible-galaxy collection install -r roles/requirements.yml --force

# Verify installation
ansible-galaxy collection list | grep datadog
```

### 3. Create Required Directories
```bash
# Create logs directory
mkdir -p logs

# Create facts cache directory
mkdir -p .ansible/facts_cache

# Set proper permissions
chmod 755 logs .ansible/facts_cache
```

### 4. Configure Vault
```bash
# Encrypt the vault file
ansible-vault encrypt vault/vault.yml

# Edit vault to add your DataDog API key
ansible-vault edit vault/vault.yml
```

**Vault Content Example:**
```yaml
---
# Encrypt this file with ansible-vault in real use.
datadog_api_key: "your_actual_datadog_api_key_here"
```

### 5. Update Inventory Files

#### Development Environment
Edit `inventories/dev/hosts.yml`:
```yaml
all:
  children:
    web_servers:
      hosts:
        web01.dev.example.com:
          ansible_host: YOUR_WEB_SERVER_IP
          ansible_user: YOUR_SSH_USER
        web02.dev.example.com:
          ansible_host: YOUR_WEB_SERVER_IP_2
          ansible_user: YOUR_SSH_USER
      vars:
        datadog_role_tags:
          - "role:web"
          - "service:nginx"
    
    database_servers:
      hosts:
        db01.dev.example.com:
          ansible_host: YOUR_DB_SERVER_IP
          ansible_user: YOUR_SSH_USER
      vars:
        datadog_role_tags:
          - "role:database"
          - "service:postgresql"
```

#### Staging/Production Environments
Copy and modify the dev inventory structure for staging and production:
```bash
# Copy dev structure to staging
cp -r inventories/dev inventories/staging

# Copy dev structure to production  
cp -r inventories/dev inventories/prod

# Update environment-specific variables in each inventory
```

### 6. Configure SSH Access

#### Option A: SSH Key Authentication (Recommended)
```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy public key to target servers
ssh-copy-id -i ~/.ssh/id_rsa.pub user@target-server

# Test SSH connection
ssh user@target-server
```

#### Option B: Password Authentication
```bash
# Test SSH connection with password
ssh user@target-server

# Ansible will prompt for passwords when needed
```

### 7. Test Connectivity
```bash
# Test connection to all hosts
ansible -i inventories/dev all -m ping

# Test specific group
ansible -i inventories/dev web_servers -m ping

# Test with verbose output
ansible -i inventories/dev all -m ping -vvv
```

## Configuration

### Environment Variables
Set these environment variables for easier management:

```bash
# Add to ~/.bashrc or ~/.zshrc
export ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible_vault_pass
export ANSIBLE_CONFIG=/Users/saketdubey/Downloads/data_dog_18_sep/ansible.cfg
export ANSIBLE_INVENTORY=/Users/saketdubey/Downloads/data_dog_18_sep/inventories/dev
```

### Vault Password File (Optional)
```bash
# Create vault password file
echo "your_vault_password" > ~/.ansible_vault_pass
chmod 600 ~/.ansible_vault_pass

# Use with ansible commands
ansible-playbook -i inventories/dev playbooks/install_agent.yml
```

## Deployment

### Basic Deployment
```bash
# Deploy to development environment
ansible-playbook -i inventories/dev playbooks/install_agent.yml --ask-vault-pass

# Deploy to staging
ansible-playbook -i inventories/staging playbooks/install_agent.yml --ask-vault-pass

# Deploy to production
ansible-playbook -i inventories/prod playbooks/install_agent.yml --ask-vault-pass
```

### Targeted Deployment
```bash
# Deploy to specific group
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit web_servers --ask-vault-pass

# Deploy to specific host
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit web01.dev.example.com --ask-vault-pass

# Deploy to multiple groups
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit "web_servers,database_servers" --ask-vault-pass
```

### Safe Deployment (Recommended for Production)
```bash
# Check what would be changed (dry run)
ansible-playbook -i inventories/prod playbooks/install_agent.yml --check --ask-vault-pass

# Show differences
ansible-playbook -i inventories/prod playbooks/install_agent.yml --check --diff --ask-vault-pass

# Deploy with confirmation
ansible-playbook -i inventories/prod playbooks/install_agent.yml --ask-vault-pass --ask-become-pass
```

## Verification

### Check DataDog Agent Status
```bash
# Check agent status on target hosts
ansible -i inventories/dev all -m shell -a "sudo systemctl status datadog-agent"

# Check agent version
ansible -i inventories/dev all -m shell -a "sudo datadog-agent version"

# Check agent configuration
ansible -i inventories/dev all -m shell -a "sudo datadog-agent configcheck"
```

### Verify in DataDog Dashboard
1. Log into your DataDog dashboard
2. Navigate to Infrastructure → Host Map
3. Verify your hosts appear with correct tags
4. Check for any configuration issues

## Troubleshooting

### Common Issues

#### 1. SSH Connection Issues
```bash
# Test SSH connectivity
ssh -v user@target-server

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Test with Ansible
ansible -i inventories/dev all -m ping -vvv
```

#### 2. Permission Issues
```bash
# Check sudo access
ansible -i inventories/dev all -m shell -a "sudo whoami"

# Test with become
ansible -i inventories/dev all -m shell -a "whoami" --become
```

#### 3. Vault Issues
```bash
# Test vault file
ansible-vault view vault/vault.yml

# Re-encrypt vault
ansible-vault rekey vault/vault.yml
```

#### 4. DataDog Agent Issues
```bash
# Check agent logs
ansible -i inventories/dev all -m shell -a "sudo tail -f /var/log/datadog/agent.log"

# Restart agent
ansible -i inventories/dev all -m shell -a "sudo systemctl restart datadog-agent"

# Check agent status
ansible -i inventories/dev all -m shell -a "sudo datadog-agent status"
```

### Debug Mode
```bash
# Enable verbose output
ansible-playbook -i inventories/dev playbooks/install_agent.yml -vvv --ask-vault-pass

# Check specific task
ansible-playbook -i inventories/dev playbooks/install_agent.yml --start-at-task="Install and configure Datadog Agent" --ask-vault-pass
```

## Best Practices

### Security
1. **Use SSH keys** instead of passwords
2. **Encrypt sensitive data** with ansible-vault
3. **Limit sudo access** to necessary commands
4. **Regular security updates** for Ansible and target systems

### Performance
1. **Use fact caching** for large inventories
2. **Optimize SSH settings** in ansible.cfg
3. **Use appropriate fork count** (50 for 300+ servers)
4. **Monitor execution time** with timer callbacks

### Maintenance
1. **Regular backups** of inventory and configuration
2. **Version control** for all configuration changes
3. **Documentation updates** for any changes
4. **Regular testing** in development environment

## Support

For additional help:
1. Check logs in `logs/ansible.log`
2. Review DataDog documentation
3. Test in development environment first
4. Use verbose mode for debugging

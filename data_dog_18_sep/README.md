# DataDog Agent Deployment with Ansible

This repository contains a modernized, scalable Ansible playbook for deploying DataDog agents across multiple environments with comprehensive tagging and monitoring capabilities.

## Features

- **Environment-aware deployment**: Separate configurations for dev, staging, and production
- **Comprehensive tagging**: Global, environment, application, role, and host-specific tags
- **Scalable architecture**: Supports 300+ servers with varying operating systems
- **Role-based configuration**: Different settings for web servers, database servers, and application servers
- **Security**: Encrypted vault for sensitive data
- **Monitoring**: Built-in logging, error handling, and performance tracking
- **Best practices**: Follows both Ansible and DataDog recommended practices

## Directory Structure

```
├── ansible.cfg                 # Ansible configuration with logging and performance settings
├── playbooks/
│   └── install_agent.yml     # Main playbook for DataDog agent installation
├── inventories/
│   ├── dev/                   # Development environment
│   │   ├── hosts.yml         # Host inventory
│   │   ├── group_vars/
│   │   │   ├── all.yml       # Global environment variables
│   │   │   ├── web_servers.yml
│   │   │   ├── database_servers.yml
│   │   │   └── application_servers.yml
│   │   └── host_vars/
│   │       ├── example-web-server.yml
│   │       └── example-database-server.yml
│   ├── staging/              # Staging environment (same structure as dev)
│   └── prod/                 # Production environment (same structure as dev)
├── vars/
│   └── versions.yml          # DataDog agent version configuration
├── vault/
│   └── vault.yml             # Encrypted sensitive data
├── roles/
│   └── requirements.yml      # Ansible collection requirements
└── logs/                     # Ansible execution logs
```

## Quick Start

### 1. Install Dependencies

```bash
# Install required Ansible collections
ansible-galaxy collection install -r roles/requirements.yml --force

# Create logs directory
mkdir -p logs
```

### 2. Configure Vault

```bash
# Encrypt the vault file with your DataDog API key
ansible-vault encrypt vault/vault.yml

# Edit the vault file to add your API key
ansible-vault edit vault/vault.yml
```

### 3. Update Inventory

Edit the inventory files in `inventories/{env}/hosts.yml` to match your infrastructure:

```yaml
# Example for inventories/dev/hosts.yml
all:
  children:
    web_servers:
      hosts:
        web01.dev.example.com:
          ansible_host: 10.0.1.10
          ansible_user: ubuntu
```

### 4. Run the Playbook

```bash
# Deploy to development environment
ansible-playbook -i inventories/dev playbooks/install_agent.yml --ask-vault-pass

# Deploy to specific group
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit web_servers --ask-vault-pass

# Deploy to production (with extra safety)
ansible-playbook -i inventories/prod playbooks/install_agent.yml --ask-vault-pass --check --diff
```

## Configuration

### Tagging Strategy

The playbook implements a hierarchical tagging system:

1. **Global tags**: Applied to all hosts (company, managed_by, datacenter)
2. **Environment tags**: Applied per environment (env:dev, tier:development)
3. **Application tags**: Applied per application (app:webapp, app:database)
4. **Role tags**: Applied per server role (role:web, role:database, role:app)
5. **Host tags**: Applied per individual host (hostname, instance_id)

### Environment-Specific Configuration

Each environment has tailored settings:

- **Development**: Debug logging, comprehensive monitoring
- **Staging**: Standard logging, production-like monitoring
- **Production**: Optimized logging, full monitoring with metadata collection

### Role-Based Configuration

Different server types get appropriate monitoring:

- **Web servers**: Nginx/Apache monitoring, log collection
- **Database servers**: PostgreSQL/MySQL monitoring, connection tracking
- **Application servers**: JMX monitoring, APM integration

## Usage Examples

### Deploy to Specific Environment

```bash
# Development
ansible-playbook -i inventories/dev playbooks/install_agent.yml --ask-vault-pass

# Staging
ansible-playbook -i inventories/staging playbooks/install_agent.yml --ask-vault-pass

# Production
ansible-playbook -i inventories/prod playbooks/install_agent.yml --ask-vault-pass
```

### Deploy to Specific Groups

```bash
# Only web servers
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit web_servers --ask-vault-pass

# Only database servers
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit database_servers --ask-vault-pass
```

### Deploy to Specific Hosts

```bash
# Single host
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit web01.dev.example.com --ask-vault-pass

# Multiple specific hosts
ansible-playbook -i inventories/dev playbooks/install_agent.yml --limit "web01.dev.example.com,db01.dev.example.com" --ask-vault-pass
```

### Dry Run and Validation

```bash
# Check what would be changed without making changes
ansible-playbook -i inventories/dev playbooks/install_agent.yml --check --ask-vault-pass

# Show differences
ansible-playbook -i inventories/dev playbooks/install_agent.yml --check --diff --ask-vault-pass
```

## Customization

### Adding New Applications

1. Create application-specific group variables in `inventories/{env}/group_vars/{app_name}.yml`
2. Define application tags and monitoring checks
3. Add hosts to the appropriate group in `hosts.yml`

### Adding Custom Checks

Add custom DataDog checks in group or host variables:

```yaml
# In group_vars or host_vars
group_datadog_checks:
  custom_check:
    init_config:
    instances:
      - host: localhost
        port: 8080
        tags:
          - "service:custom"
```

### Host-Specific Configuration

Create host-specific files in `inventories/{env}/host_vars/{hostname}.yml`:

```yaml
# inventories/dev/host_vars/web01.dev.example.com.yml
datadog_host_tags:
  - "hostname:web01"
  - "instance_id:i-1234567890abcdef0"

host_datadog_checks:
  custom_check:
    init_config:
    instances:
      - host: localhost
        port: 8080
```

## Monitoring and Logging

### Ansible Logs

- Execution logs: `logs/ansible.log`
- Performance metrics: Built-in timer and profile callbacks
- Error handling: Comprehensive error reporting and failure notifications

### DataDog Integration

- Automatic agent installation and configuration
- Environment-specific monitoring
- Comprehensive tagging for filtering and alerting
- Log collection and APM integration

## Security Best Practices

1. **Encrypt sensitive data**: Use `ansible-vault` for API keys and passwords
2. **Limit access**: Use SSH keys and limit sudo access
3. **Audit trails**: All changes are logged
4. **Environment separation**: Clear separation between environments

## Troubleshooting

### Common Issues

1. **Vault password required**: Use `--ask-vault-pass` or set `ANSIBLE_VAULT_PASSWORD_FILE`
2. **SSH connection issues**: Check SSH keys and connectivity
3. **Permission denied**: Ensure proper sudo access
4. **API key issues**: Verify DataDog API key in vault

### Debug Mode

```bash
# Enable verbose output
ansible-playbook -i inventories/dev playbooks/install_agent.yml -vvv --ask-vault-pass

# Check specific host connectivity
ansible -i inventories/dev web_servers -m ping
```

## Contributing

1. Follow Ansible best practices
2. Test changes in development environment first
3. Update documentation for new features
4. Ensure backward compatibility

## Support

For issues and questions:
1. Check the logs in `logs/ansible.log`
2. Verify inventory configuration
3. Test connectivity with `ansible -m ping`
4. Review DataDog agent status on target hosts

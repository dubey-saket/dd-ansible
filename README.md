# DataDog Agent Ansible Deployment

A modern, scalable, and production-ready Ansible playbook for deploying DataDog agents across multiple environments with comprehensive monitoring, logging, and rollback capabilities.

## 🚀 Features

### Scalability & Reliability
- **Batch Processing**: Configurable batch sizes (25% default, 10% for production)
- **Serial Execution**: Safe deployment across 300+ servers
- **Failure Thresholds**: Prevent cascading failures with configurable limits
- **Multi-OS Support**: RedHat, Debian, SUSE Linux, and **Windows** distributions
- **Cross-Platform Compatibility**: Full Windows and Linux support with OS-specific configurations

### Environment Management
- **Environment-Specific Configurations**: Separate configs for dev, staging, and production
- **Hierarchical Configuration**: Base → OS → Environment → Application → Group → Host inheritance
- **Template-Based Checks**: Maintainable configuration templates
- **Vault Encryption**: Secure storage of sensitive data
- **Application Detection**: Automatic detection and configuration of application servers
- **OS-Based Defaults**: Automatic configuration generation based on operating system

### Monitoring & Logging
- **Webhook Notifications**: Teams integration with deployment status updates
- **Comprehensive Logging**: Detailed deployment logs with timestamps
- **Health Checks**: Pre and post-deployment system validation
- **Real-time Monitoring**: Python script for deployment tracking

### Operational Excellence
- **Deployment Scripts**: Command-line tools with comprehensive options
- **Rollback Capabilities**: Safe rollback with version management (Linux only)
- **Configuration Validation**: Pre-deployment validation checks
- **Error Handling**: Graceful error handling with troubleshooting information
- **State Management**: Server state tracking and remote comparison capabilities
- **Cleanup Management**: Orphaned checks handling and bidirectional sync
- **Comprehensive File Management**: All configuration files updated during execution

## 📁 Project Structure

```
data_dog_ansible/
├── ansible.cfg                 # Ansible configuration
├── requirements.yml            # Ansible collections and roles
├── Makefile                    # Common operations
├── README.md                   # This file
├── monitor_config.yml          # Monitoring configuration
├── .gitignore                  # Git ignore rules
├── playbooks/
│   ├── datadog_agent.yml       # Main deployment playbook
│   ├── rollback.yml           # Rollback playbook
│   └── tasks/
│       ├── validate.yml       # Validation tasks
│       ├── health_check.yml   # Health check tasks
│       ├── notifications.yml  # Notification tasks
│       ├── verify_installation.yml # Installation verification
│       ├── configure_checks.yml # Custom checks configuration
│       ├── error_handling.yml # Error handling tasks
│       ├── generate_report.yml # Report generation
│       └── install_previous_version.yml # Version rollback
├── vars/
│   ├── base.yml               # Base configuration
│   ├── redhat.yml             # RedHat-specific settings
│   ├── debian.yml             # Debian-specific settings
│   ├── suse.yml               # SUSE-specific settings
│   └── environments/
│       ├── dev.yml            # Development environment
│       ├── staging.yml        # Staging environment
│       └── prod.yml           # Production environment
├── inventories/
│   ├── dev/
│   │   ├── hosts.yml          # Development hosts
│   │   └── group_vars/
│   │       └── all.yml        # Development variables
│   ├── staging/
│   │   ├── hosts.yml          # Staging hosts
│   │   └── group_vars/
│   │       └── all.yml        # Staging variables
│   └── prod/
│       ├── hosts.yml          # Production hosts
│       └── group_vars/
│           └── all.yml        # Production variables
├── templates/
│   ├── http_check.yaml.j2     # HTTP check template
│   ├── disk_check.yaml.j2     # Disk check template
│   └── system_check.yaml.j2   # System check template
├── vault/
│   ├── dev.yml.example        # Development vault template
│   ├── staging.yml.example    # Staging vault template
│   ├── prod.yml.example       # Production vault template
│   └── .gitkeep              # Keep vault directory in git
└── scripts/
    ├── deploy.sh              # Deployment script
    ├── rollback.sh            # Rollback script
    └── monitor_deployment.py  # Deployment monitoring
```

## 🛠️ Quick Start

### 1. Prerequisites

- Ansible 2.9 or later
- Python 3.6 or later
- Access to target servers via SSH
- DataDog API key

### 2. Setup

```bash
# Clone the repository
git clone <repository-url>
cd data_dog_ansible

# Install requirements
make install

# Initialize vault files
make vault-init

# Edit vault files with your DataDog API key
ansible-vault edit vault/dev.yml
```

### 3. Configure Environments

Update the inventory files with your server information:

```bash
# Edit development inventory
vim inventories/dev/hosts.yml

# Edit staging inventory
vim inventories/staging/hosts.yml

# Edit production inventory
vim inventories/prod/hosts.yml
```

### 4. Deploy

```bash
# Deploy to development
make deploy-dev

# Deploy to staging
make deploy-staging

# Deploy to production (with confirmation)
make deploy-prod
```

## 📋 Usage

### Deployment Commands

```bash
# Basic deployment
./scripts/deploy.sh dev

# Dry run
./scripts/deploy.sh staging --dry-run

# Limited deployment
./scripts/deploy.sh prod --limit prod-web-01

# Custom batch size
./scripts/deploy.sh staging --batch-size 10%

# With specific tags
./scripts/deploy.sh dev --tags validation

# Skip notifications
./scripts/deploy.sh dev --skip-tags notifications
```

### Rollback Commands

```bash
# Rollback to previous version
./scripts/rollback.sh dev

# Rollback to specific version
./scripts/rollback.sh staging 7.69.0

# Dry run rollback
./scripts/rollback.sh prod --dry-run

# List available versions
./scripts/rollback.sh dev --list-versions
```

### Monitoring

```bash
# Start monitoring
python3 scripts/monitor_deployment.py dev

# Monitor with custom interval
python3 scripts/monitor_deployment.py staging -i 60 -d 7200
```

## 🔧 Configuration

### Environment Variables

Each environment has specific configuration:

- **Development**: Relaxed settings, debug logging, larger batch sizes
- **Staging**: Moderate settings, warning logs, medium batch sizes
- **Production**: Strict settings, error logs, small batch sizes

### Batch Sizes by Environment

- **Development**: 50% (faster deployment)
- **Staging**: 25% (balanced approach)
- **Production**: 10% (conservative approach)

### Failure Thresholds

- **Development**: 20% failure tolerance
- **Staging**: 15% failure tolerance
- **Production**: 5% failure tolerance

## 🔐 Security

### Vault Management

```bash
# Edit vault files
make vault-edit-dev
make vault-edit-staging
make vault-edit-prod

# Create vault password file
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

### Sensitive Data

All sensitive data is stored in encrypted vault files:
- DataDog API keys
- Webhook URLs
- Company information
- Additional configuration

## 📊 Monitoring & Notifications

### Webhook Integration

Configure Teams webhook notifications in vault files:

```yaml
vault_webhook_url: "https://your-teams-webhook-url"
```

### Log Files

Deployment logs are stored in:
- `/var/log/datadog-deployment/deployment.log`
- `/var/log/datadog-deployment/troubleshooting/`
- `logs/` directory in project root

### Health Checks

The playbook includes comprehensive health checks:
- System resource validation
- Network connectivity tests
- DataDog agent status verification
- Configuration validation

## 🚨 Error Handling

### Automatic Error Handling

- Graceful failure handling with rescue blocks
- Automatic cleanup on failure
- Detailed error logging
- Troubleshooting information collection

### Manual Troubleshooting

```bash
# Check deployment status
make status

# View logs
tail -f logs/deployment_*.log

# Check specific host
ansible dev-web-01 -i inventories/dev/hosts.yml -m ping
```

## 🔄 Rollback Process

### Automatic Rollback

1. Stop DataDog agent service
2. Backup current configuration
3. Remove current installation
4. Install previous version
5. Restore configuration
6. Start service and verify

### Emergency Recovery

If rollback fails, the system will:
1. Attempt to restore from backup
2. Send failure notifications
3. Log detailed error information
4. Provide manual recovery instructions

## 📈 Best Practices

### Deployment Best Practices

1. **Always test in development first**
2. **Use dry-run mode for validation**
3. **Monitor deployments in real-time**
4. **Keep rollback plans ready**
5. **Document any custom configurations**

### Security Best Practices

1. **Encrypt all vault files**
2. **Use SSH keys for authentication**
3. **Limit sudo privileges**
4. **Regular security updates**
5. **Audit access logs**

### Monitoring Best Practices

1. **Set up proper alerting**
2. **Monitor system resources**
3. **Track deployment metrics**
4. **Regular health checks**
5. **Document incidents**

## 🆘 Troubleshooting

### Common Issues

#### Agent Installation Fails
```bash
# Check system requirements
ansible all -i inventories/dev/hosts.yml -m setup -a "filter=ansible_memtotal_mb"

# Verify network connectivity
ansible all -i inventories/dev/hosts.yml -m ping
```

#### Configuration Issues
```bash
# Validate configuration
./scripts/deploy.sh dev --tags validation

# Check agent configuration
ansible all -i inventories/dev/hosts.yml -m command -a "datadog-agent configcheck"
```

#### Performance Issues
```bash
# Check system load
ansible all -i inventories/dev/hosts.yml -m command -a "uptime"

# Monitor resource usage
ansible all -i inventories/dev/hosts.yml -m command -a "free -m"
```

### Getting Help

1. Check the logs in `logs/` directory
2. Review troubleshooting information in `/var/log/datadog-deployment/`
3. Validate configuration with `--check` mode
4. Use verbose output with `-vvv` flag

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the logs for error details

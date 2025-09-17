# Teams Notifications Configuration Guide

## Overview
The DataDog Ansible playbook includes comprehensive Teams notification functionality that provides real-time updates about deployment status, failures, and rollback operations. This guide covers setup, configuration, and troubleshooting.

## Features

### Notification Types
- **Deployment Start**: Sent when deployment begins
- **Deployment Completion**: Sent on successful deployment
- **Deployment Failure**: Sent when deployment fails
- **Rollback Start**: Sent when rollback begins
- **Rollback Completion**: Sent on successful rollback
- **Rollback Failure**: Sent when rollback fails

### Notification Content
Each notification includes:
- Environment information (dev/staging/prod)
- Host details
- Deployment status
- Timestamp
- Deployment ID
- OS Family
- Agent Version
- Error details (for failures)

## Setup Instructions

### 1. Create Teams Webhook

1. **Open Teams Channel**:
   - Navigate to your Teams channel
   - Click the three dots (...) next to the channel name
   - Select "Connectors"

2. **Configure Incoming Webhook**:
   - Find "Incoming Webhook" in the list
   - Click "Configure"
   - Provide a name (e.g., "DataDog Deployments")
   - Upload an icon (optional)
   - Click "Create"

3. **Copy Webhook URL**:
   - Copy the generated webhook URL
   - Store it securely for use in vault files

### 2. Configure Vault Files

#### For Development Environment
```bash
# Edit development vault
ansible-vault edit vault/dev.yml
```

Add the following configuration:
```yaml
---
# Development environment vault variables
vault_datadog_api_key: "your_datadog_api_key_here"
vault_datadog_site: "datadoghq.com"
vault_webhook_url: "https://your-teams-webhook-url-here"
vault_company_name: "Your Company Name"
```

#### For Staging Environment
```bash
# Edit staging vault
ansible-vault edit vault/staging.yml
```

```yaml
---
# Staging environment vault variables
vault_datadog_api_key: "your_datadog_api_key_here"
vault_datadog_site: "datadoghq.com"
vault_webhook_url: "https://your-teams-webhook-url-here"
vault_company_name: "Your Company Name"
```

#### For Production Environment
```bash
# Edit production vault
ansible-vault edit vault/prod.yml
```

```yaml
---
# Production environment vault variables
vault_datadog_api_key: "your_datadog_api_key_here"
vault_datadog_site: "datadoghq.com"
vault_webhook_url: "https://your-teams-webhook-url-here"
vault_company_name: "Your Company Name"
```

### 3. Enable/Disable Notifications

#### Environment-Level Configuration

**Development Environment** (`vars/environments/dev.yml`):
```yaml
---
# Development environment - notifications disabled by default
monitoring:
  webhook_enabled: false
  log_level: DEBUG
  health_check_interval: 60
  health_check_timeout: 180
```

**Staging Environment** (`vars/environments/staging.yml`):
```yaml
---
# Staging environment - notifications enabled
monitoring:
  webhook_enabled: true
  log_level: INFO
  health_check_interval: 30
  health_check_timeout: 240
```

**Production Environment** (`vars/environments/prod.yml`):
```yaml
---
# Production environment - notifications enabled
monitoring:
  webhook_enabled: true
  log_level: WARN
  health_check_interval: 15
  health_check_timeout: 300
```

#### Command-Line Override
```bash
# Enable notifications for specific deployment
./scripts/deploy.sh dev --webhook true

# Disable notifications for specific deployment
./scripts/deploy.sh staging --webhook false
```

## Configuration Options

### Webhook Configuration
```yaml
monitoring:
  webhook_enabled: true/false          # Enable/disable webhook notifications
  webhook_url: "https://..."           # Teams webhook URL (in vault)
  log_level: INFO                      # Log level for notifications
  health_check_interval: 30            # Health check interval in seconds
  health_check_timeout: 300            # Health check timeout in seconds
```

### Notification Payload Customization
The notification payload can be customized by modifying the `enhanced_notifications.yml` task file:

```yaml
notification_payload:
  text: "DataDog Agent Deployment {{ notification_type | title }}"
  attachments:
    - color: "{{ 'good' if notification_type == 'completion' else 'danger' if notification_type in ['failure', 'rollback_failure'] else 'warning' }}"
      fields:
        - title: "Environment"
          value: "{{ target_environment | upper }}"
          short: true
        # Add more fields as needed
```

## Usage Examples

### Basic Deployment with Notifications
```bash
# Deploy to development with notifications enabled
./scripts/deploy.sh dev --webhook true

# Deploy to staging (notifications enabled by default)
./scripts/deploy.sh staging

# Deploy to production (notifications enabled by default)
./scripts/deploy.sh prod
```

### Deployment Without Notifications
```bash
# Deploy without notifications
./scripts/deploy.sh dev --webhook false

# Skip notification tags entirely
./scripts/deploy.sh staging --skip-tags notifications
```

### Rollback with Notifications
```bash
# Rollback with notifications
./scripts/rollback.sh staging 7.69.0

# Rollback without notifications
./scripts/rollback.sh prod --skip-tags notifications
```

## Notification Examples

### Successful Deployment
```
DataDog Agent Deployment Completion

Environment: DEV
Host: dev-web-01
Status: Completion
Timestamp: 2024-01-15T10:30:00Z
Deployment ID: 1705312200-dev-web-01
OS Family: RedHat
Agent Version: 7.70.1
```

### Failed Deployment
```
DataDog Agent Deployment Failure

Environment: STAGING
Host: staging-db-01
Status: Failure
Timestamp: 2024-01-15T11:45:00Z
Deployment ID: 1705316700-staging-db-01
OS Family: Debian
Agent Version: 7.70.1
Error Details: DNS resolution failed for datadoghq.com
```

### Rollback Notification
```
DataDog Agent Deployment Rollback Completion

Environment: PROD
Host: prod-app-01
Status: Rollback Completion
Timestamp: 2024-01-15T12:15:00Z
Deployment ID: 1705318500-prod-app-01
OS Family: RedHat
Agent Version: 7.69.0
```

## Troubleshooting

### Common Issues

#### 1. No Notifications Received

**Symptoms**:
- Deployments complete but no Teams notifications appear
- Log shows "Webhook notifications are disabled"

**Solutions**:
1. Check webhook configuration:
   ```bash
   ansible-vault view vault/dev.yml | grep webhook
   ```

2. Verify environment configuration:
   ```bash
   grep -r "webhook_enabled" vars/environments/
   ```

3. Enable notifications:
   ```bash
   ./scripts/deploy.sh dev --webhook true
   ```

#### 2. Webhook URL Invalid

**Symptoms**:
- Error: "Invalid webhook URL format"
- Deployment fails during validation

**Solutions**:
1. Verify webhook URL format:
   - Must start with `https://`
   - Must be a valid Teams webhook URL
   - Must be properly configured in vault

2. Test webhook URL:
   ```bash
   curl -X POST -H 'Content-type: application/json' \
     --data '{"text":"Test notification"}' \
     YOUR_WEBHOOK_URL
   ```

#### 3. Partial Notification Failures

**Symptoms**:
- Some notifications work, others don't
- Intermittent webhook failures

**Solutions**:
1. Check network connectivity:
   ```bash
   ping hooks.teams.microsoft.com
   ```

2. Verify firewall settings:
   - Ensure outbound HTTPS (443) is allowed
   - Check proxy configuration if applicable

3. Review webhook logs:
   ```bash
   tail -f /var/log/datadog-deployment/deployment.log | grep webhook
   ```

#### 4. Missing Webhook URL

**Symptoms**:
- Warning: "Webhook notifications enabled but URL not configured"
- Notifications skipped

**Solutions**:
1. Add webhook URL to vault:
   ```bash
   ansible-vault edit vault/dev.yml
   ```

2. Add the following line:
   ```yaml
   vault_webhook_url: "https://your-webhook-url-here"
   ```

### Debug Mode

Enable debug mode for detailed notification logging:

```bash
# Run with verbose output
./scripts/deploy.sh dev --verbose

# Check notification logs
tail -f /var/log/datadog-deployment/deployment.log | grep -i notification
```

### Log Files

Notification activities are logged in multiple locations:

1. **Main deployment log**:
   ```
   /var/log/datadog-deployment/deployment.log
   ```

2. **Structured JSON logs**:
   ```
   /var/log/datadog-deployment/notifications-*.json
   ```

3. **Test results**:
   ```
   tests/results/test_results_*.csv
   ```

## Security Considerations

### Webhook URL Security
- Store webhook URLs in encrypted vault files
- Never commit webhook URLs to version control
- Rotate webhook URLs periodically
- Use environment-specific webhooks

### Access Control
- Limit webhook access to specific Teams channels
- Monitor webhook usage in Teams admin center
- Consider using webhook secrets for additional security

## Best Practices

### 1. Environment-Specific Configuration
- Disable notifications in development by default
- Enable notifications in staging and production
- Use different webhook URLs for different environments

### 2. Notification Content
- Keep notifications informative but concise
- Include relevant context (environment, host, version)
- Provide actionable information for failures

### 3. Error Handling
- Always log notifications to files as backup
- Handle webhook failures gracefully
- Provide fallback notification methods

### 4. Testing
- Test webhook functionality before production use
- Validate notification content and formatting
- Test both success and failure scenarios

## Advanced Configuration

### Custom Notification Templates
Create custom notification templates by modifying the payload structure in `enhanced_notifications.yml`:

```yaml
notification_payload:
  text: "Custom DataDog Deployment {{ notification_type | title }}"
  attachments:
    - color: "{{ notification_color }}"
      title: "{{ notification_title }}"
      text: "{{ notification_text }}"
      fields:
        # Custom fields here
```

### Multiple Webhook Support
To support multiple webhooks (e.g., different channels), modify the notification task to loop through multiple URLs:

```yaml
- name: Send to multiple webhooks
  uri:
    url: "{{ item }}"
    method: POST
    body_format: json
    body: "{{ notification_payload }}"
  loop: "{{ vault_webhook_urls | default([vault_webhook_url]) }}"
```

This comprehensive guide ensures proper setup and configuration of Teams notifications for the DataDog Ansible playbook, providing real-time visibility into deployment operations across all environments.

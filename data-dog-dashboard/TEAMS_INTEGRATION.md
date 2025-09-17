# Microsoft Teams Integration Guide

This guide explains how to integrate Microsoft Teams with your Datadog monitoring solution for alert notifications.

## 🔧 Teams Integration Options

### Option 1: Datadog Teams Integration (Recommended)

If you have a Teams webhook URL, you can use Datadog's built-in Teams integration:

#### 1. Create Teams Webhook
1. In Microsoft Teams, go to your channel
2. Click the **...** (More options) menu
3. Select **Connectors**
4. Find **Incoming Webhook** and click **Configure**
5. Give it a name (e.g., "Datadog Alerts")
6. Click **Create**
7. Copy the webhook URL

#### 2. Configure in Datadog
1. In Datadog, go to **Integrations** → **Microsoft Teams**
2. Click **Configuration** tab
3. Add your webhook URL
4. Configure the integration

#### 3. Update terraform.tfvars
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  teams = "#alerts"  # Your Teams channel name
  # Other channels...
}
```

### Option 2: Teams Power Automate Integration

If you don't have a Teams webhook but have Power Automate, you can use this approach:

#### 1. Create Power Automate Flow
1. Go to [Power Automate](https://flow.microsoft.com)
2. Create a new flow
3. Add a trigger: **When an HTTP request is received**
4. Add an action: **Post a message in a chat or channel**
5. Configure the Teams action with your channel
6. Save and get the HTTP request URL

#### 2. Update terraform.tfvars
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  teams_power_automation = "https://your-power-automate-url.com/alerts"
  # Other channels...
}
```

### Option 3: Custom Webhook to Teams

If you have a custom webhook that forwards to Teams:

#### 1. Create Custom Webhook
Create a webhook service that:
1. Receives Datadog alerts
2. Formats them for Teams
3. Posts to Teams channel

#### 2. Update terraform.tfvars
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  webhook = "https://your-custom-webhook-url.com/alerts"
  # Other channels...
}
```

## 📋 Configuration Examples

### Basic Teams Configuration
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  teams = "#alerts"
}
```

### Teams with Power Automate
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  teams_power_automation = "https://your-power-automate-url.com/alerts"
}
```

### Teams with Multiple Channels
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  teams = "#alerts"
  teams_power_automation = "https://your-power-automate-url.com/alerts"
}
```

### Teams with Other Integrations
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  teams = "#alerts"
  pagerduty = "your-pagerduty-service-key"
  webhook = "https://your-webhook-url.com/alerts"
}
```

## 🚀 Deployment with Teams

### Deploy with Teams Integration
```bash
# Update your terraform.tfvars with Teams configuration
# Then deploy
./scripts/deploy.sh
```

### Deploy Alerts Only with Teams
```bash
# Deploy only alerts with Teams notifications
./scripts/deploy-alerts.sh
```

### Deploy Dashboards Only
```bash
# Deploy only dashboards (no Teams needed)
./scripts/deploy-dashboards.sh
```

## 🔍 Testing Teams Integration

### Test Teams Notifications
1. Deploy your configuration
2. Trigger a test alert in Datadog
3. Check your Teams channel for the notification
4. Verify the message format and content

### Troubleshooting Teams Integration
1. **Check Webhook URL**: Ensure the webhook URL is correct
2. **Verify Permissions**: Ensure the webhook has permission to post to the channel
3. **Check Datadog Integration**: Verify the Teams integration is configured in Datadog
4. **Test Manually**: Send a test message to verify the webhook works

## 📊 Teams Message Format

### Alert Message Format
Teams messages will include:
- **Alert Title**: The alert name
- **Alert Status**: Warning or Critical
- **Metric Value**: Current metric value
- **Threshold**: Alert threshold
- **Host/Service**: Affected host or service
- **Timestamp**: When the alert occurred

### Example Teams Message
```
🚨 **AWS EC2 High CPU Usage - Production**

**Status**: Critical
**Instance**: i-1234567890abcdef0
**CPU Usage**: 87%
**Threshold**: 85%
**Time**: 2024-01-15 10:30:00 UTC

@admin @ops-team
```

## 🛠️ Advanced Teams Configuration

### Custom Message Formatting
You can customize the Teams message format by:
1. Modifying the alert message templates in the Terraform modules
2. Using Teams message formatting options
3. Adding custom fields and attachments

### Teams Channel Management
- **Create Multiple Channels**: Set up different channels for different alert types
- **Channel Permissions**: Control who can see alerts
- **Message Threading**: Use Teams threading for related alerts

### Teams Bot Integration
Consider creating a Teams bot for:
- Interactive alert management
- Alert acknowledgment
- Status updates
- Custom commands

## 🔒 Security Considerations

### Webhook Security
- **Use HTTPS**: Always use HTTPS for webhook URLs
- **Authentication**: Implement authentication for webhooks
- **Rate Limiting**: Implement rate limiting to prevent abuse
- **Monitoring**: Monitor webhook usage and failures

### Teams Security
- **Channel Permissions**: Control who can see alerts
- **Message Retention**: Configure message retention policies
- **Audit Logging**: Enable audit logging for Teams activities

## 📈 Best Practices

### Teams Integration Best Practices
1. **Use Appropriate Channels**: Route alerts to relevant channels
2. **Avoid Alert Fatigue**: Use appropriate thresholds and grouping
3. **Include Context**: Provide enough context in alert messages
4. **Test Regularly**: Test the integration regularly
5. **Monitor Performance**: Monitor webhook performance and reliability

### Alert Management
1. **Acknowledge Alerts**: Use Teams to acknowledge alerts
2. **Update Status**: Provide status updates in Teams
3. **Escalate When Needed**: Use Teams for escalation
4. **Document Incidents**: Use Teams for incident documentation

## 🆘 Troubleshooting

### Common Issues

#### 1. Teams Notifications Not Working
- Check webhook URL configuration
- Verify Teams integration in Datadog
- Test webhook manually
- Check Teams channel permissions

#### 2. Message Format Issues
- Review alert message templates
- Check Teams message formatting
- Verify webhook payload format

#### 3. Performance Issues
- Monitor webhook response times
- Check Teams service status
- Implement retry logic
- Use appropriate rate limiting

### Getting Help
1. **Datadog Support**: Contact Datadog support for integration issues
2. **Teams Support**: Contact Microsoft Teams support for Teams issues
3. **Power Automate Support**: Contact Power Automate support for flow issues
4. **Community**: Check Datadog and Teams community forums

## 📚 Additional Resources

- [Datadog Teams Integration Documentation](https://docs.datadoghq.com/integrations/microsoft_teams/)
- [Microsoft Teams Webhook Documentation](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)
- [Power Automate Documentation](https://docs.microsoft.com/en-us/power-automate/)
- [Teams Message Formatting](https://docs.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-format)

---

**Note**: This integration guide assumes you have the necessary permissions and access to configure Teams integrations. Contact your Teams administrator if you need help with permissions or configuration.

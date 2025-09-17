# Deployment Options Guide

This guide explains the different deployment options available for the Datadog monitoring solution.

## 🎯 Deployment Options Overview

The solution supports three main deployment options:

1. **Full Deployment**: Dashboards + Alerts (Complete solution)
2. **Dashboards Only**: Just the monitoring dashboards
3. **Alerts Only**: Just the alerting rules

## 🚀 Option 1: Full Deployment (Recommended)

Deploy the complete monitoring solution with both dashboards and alerts.

### When to Use
- First-time deployment
- Complete monitoring setup
- Production environments
- When you want everything configured at once

### What Gets Deployed
- ✅ AWS Infrastructure Dashboard
- ✅ On-Premises Infrastructure Dashboard
- ✅ Unified Monitoring Dashboard
- ✅ AWS Alerts (12 different alert types)
- ✅ On-Premises Alerts (14 different alert types)
- ✅ Application Alerts (13 different alert types)

### How to Deploy
```bash
# Interactive deployment
./scripts/deploy.sh

# Automated deployment
./scripts/deploy.sh --auto-approve
```

### Configuration Required
- Datadog API keys
- Environment configuration
- Notification channels (email, Teams, etc.)
- AWS and on-premises settings

## 📊 Option 2: Dashboards Only

Deploy only the monitoring dashboards without any alerting rules.

### When to Use
- You already have alerting configured
- You want to see the monitoring setup first
- You're using a different alerting system
- You want to evaluate the dashboards before setting up alerts

### What Gets Deployed
- ✅ AWS Infrastructure Dashboard
- ✅ On-Premises Infrastructure Dashboard
- ✅ Unified Monitoring Dashboard
- ❌ No alerts configured

### How to Deploy
```bash
# Interactive deployment
./scripts/deploy-dashboards.sh

# Automated deployment
./scripts/deploy-dashboards.sh --auto-approve
```

### Configuration Required
- Datadog API keys
- Environment configuration
- AWS and on-premises settings
- No notification channels needed

## 🚨 Option 3: Alerts Only

Deploy only the alerting rules without any dashboards.

### When to Use
- You already have dashboards configured
- You want to add alerting to existing setup
- You're using a different dashboard solution
- You want to focus on alerting first

### What Gets Deployed
- ❌ No dashboards created
- ✅ AWS Alerts (12 different alert types)
- ✅ On-Premises Alerts (14 different alert types)
- ✅ Application Alerts (13 different alert types)

### How to Deploy
```bash
# Interactive deployment
./scripts/deploy-alerts.sh

# Automated deployment
./scripts/deploy-alerts.sh --auto-approve
```

### Configuration Required
- Datadog API keys
- Environment configuration
- Notification channels (email, Teams, etc.)
- AWS and on-premises settings

## 🔄 Deployment Workflow

### Step-by-Step Process

#### 1. Prepare Configuration
```bash
# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

#### 2. Validate Configuration
```bash
# Always validate before deployment
./scripts/validate.sh
```

#### 3. Choose Deployment Option
```bash
# Option A: Full deployment
./scripts/deploy.sh

# Option B: Dashboards only
./scripts/deploy-dashboards.sh

# Option C: Alerts only
./scripts/deploy-alerts.sh
```

#### 4. Verify Deployment
- Check Terraform outputs
- Access dashboards in Datadog
- Test alert notifications
- Verify monitoring coverage

## 📋 Configuration Examples

### Full Deployment Configuration
```hcl
# terraform.tfvars
datadog_api_key = "your-api-key"
datadog_app_key = "your-app-key"
environment = "production"

# Notification channels for alerts
notification_channels = {
  email = ["admin@company.com", "ops@company.com"]
  teams = "#alerts"
  teams_power_automation = "https://your-power-automate-url.com"
}

# AWS and on-premises settings
aws_region = "us-east-1"
onprem_datacenter = "primary-datacenter"
```

### Dashboards Only Configuration
```hcl
# terraform.tfvars
datadog_api_key = "your-api-key"
datadog_app_key = "your-app-key"
environment = "production"

# No notification channels needed for dashboards only
notification_channels = {
  email = []
}

# AWS and on-premises settings
aws_region = "us-east-1"
onprem_datacenter = "primary-datacenter"
```

### Alerts Only Configuration
```hcl
# terraform.tfvars
datadog_api_key = "your-api-key"
datadog_app_key = "your-app-key"
environment = "production"

# Notification channels required for alerts
notification_channels = {
  email = ["admin@company.com", "ops@company.com"]
  teams = "#alerts"
}

# AWS and on-premises settings
aws_region = "us-east-1"
onprem_datacenter = "primary-datacenter"
```

## 🔧 Management and Updates

### Updating Deployments
```bash
# Update full deployment
./scripts/update.sh

# Update dashboards only
./scripts/update.sh  # (works for any deployment type)

# Update alerts only
./scripts/update.sh  # (works for any deployment type)
```

### Adding Components Later
If you deployed dashboards only and want to add alerts later:

1. **Update Configuration**: Add notification channels to terraform.tfvars
2. **Deploy Alerts**: Run `./scripts/deploy-alerts.sh`
3. **Verify**: Check that alerts are working

If you deployed alerts only and want to add dashboards later:

1. **Deploy Dashboards**: Run `./scripts/deploy-dashboards.sh`
2. **Verify**: Check that dashboards are accessible

### Switching Between Options
You can switch between deployment options by:

1. **Backup Current State**: Scripts automatically backup your configuration
2. **Choose New Option**: Run the appropriate deployment script
3. **Verify Changes**: Check that the new deployment works correctly

## 🛠️ Troubleshooting

### Common Issues

#### 1. Configuration Conflicts
If you have conflicts between different deployment types:
```bash
# Clean up and start fresh
./scripts/destroy.sh
./scripts/deploy.sh  # or your chosen option
```

#### 2. Missing Dependencies
If you deployed alerts only but need dashboards:
```bash
# Add dashboards to existing setup
./scripts/deploy-dashboards.sh
```

#### 3. Notification Issues
If alerts aren't working:
```bash
# Check notification configuration
./scripts/validate.sh

# Update alerts with new configuration
./scripts/update.sh
```

### Getting Help
1. **Check Logs**: Review Terraform output for errors
2. **Validate Configuration**: Run `./scripts/validate.sh`
3. **Check Datadog**: Verify resources in Datadog console
4. **Review Documentation**: Check setup guides and troubleshooting

## 📈 Best Practices

### Deployment Strategy
1. **Start Small**: Begin with dashboards only to evaluate
2. **Add Gradually**: Add alerts after dashboards are working
3. **Test Thoroughly**: Validate each component before moving to the next
4. **Document Changes**: Keep track of what you've deployed

### Configuration Management
1. **Version Control**: Keep terraform.tfvars in version control
2. **Environment Separation**: Use different configurations for different environments
3. **Backup Regularly**: Backup your Terraform state files
4. **Test Changes**: Test configuration changes in staging first

### Monitoring and Maintenance
1. **Regular Updates**: Update configurations based on monitoring needs
2. **Performance Review**: Review dashboard and alert effectiveness
3. **Cost Optimization**: Monitor Datadog usage and costs
4. **Team Training**: Train team on using the monitoring solution

## 🎯 Choosing the Right Option

### For New Teams
- **Start with**: Dashboards only
- **Then add**: Alerts after dashboards are working
- **Finally**: Full deployment for production

### For Existing Teams
- **If you have dashboards**: Use alerts only
- **If you have alerts**: Use dashboards only
- **If you have neither**: Use full deployment

### For Evaluation
- **Start with**: Dashboards only
- **Evaluate**: Dashboard usefulness and coverage
- **Decide**: Whether to add alerts or use different solution

### For Production
- **Use**: Full deployment
- **Ensure**: All notification channels are configured
- **Test**: All components before going live

---

**Remember**: You can always start with one option and add the other components later. The modular design makes it easy to expand your monitoring solution as needed.

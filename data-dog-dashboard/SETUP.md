# Datadog Dashboard and Alerting Setup Guide

This guide provides step-by-step instructions for setting up the Datadog monitoring infrastructure using Terraform.

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Terraform** (version >= 1.0) installed
- [ ] **jq** installed for JSON processing
- [ ] **curl** installed for API testing
- [ ] **Git** installed for version control
- [ ] **Datadog Account** with active subscription
- [ ] **Datadog API Key** with appropriate permissions
- [ ] **Datadog Application Key** with appropriate permissions
- [ ] **AWS Integration** configured in Datadog
- [ ] **On-Premises Datadog Agents** installed and configured

## 🔑 Obtaining Datadog Credentials

### 1. Get Your API Key
1. Log into your Datadog account
2. Navigate to **Organization Settings** → **API Keys**
3. Click **New Key**
4. Give it a name (e.g., "Terraform Automation")
5. Copy the generated API key

### 2. Get Your Application Key
1. Navigate to **Organization Settings** → **Application Keys**
2. Click **New Key**
3. Give it a name (e.g., "Terraform Automation")
4. Copy the generated application key

### 3. Determine Your API URL
- **US**: `https://api.datadoghq.com`
- **EU**: `https://api.datadoghq.eu`

## 🚀 Step-by-Step Setup

### Step 1: Clone and Prepare
```bash
# Clone the repository
git clone <repository-url>
cd data-dog-dashboard

# Make scripts executable
chmod +x scripts/*.sh
```

### Step 2: Configure Variables
```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### Step 3: Required Configuration
Edit `terraform.tfvars` with your actual values:

```hcl
# REQUIRED: Datadog API Configuration
datadog_api_key = "dd1234567890abcdef1234567890abcdef"  # Your actual API key
datadog_app_key = "dd1234567890abcdef1234567890abcdef"  # Your actual app key
datadog_api_url = "https://api.datadoghq.com"           # Your API URL

# REQUIRED: Environment Configuration
environment = "production"  # or staging, development

# REQUIRED: AWS Configuration
aws_region    = "us-east-1"        # Your AWS region
aws_account_id = "123456789012"    # Your AWS account ID

# REQUIRED: On-Premises Configuration
onprem_datacenter = "primary-datacenter"  # Your datacenter name

# REQUIRED: Notification Configuration
notification_channels = {
  email = [
    "admin@yourcompany.com",
    "ops-team@yourcompany.com"
  ]
  slack = "#alerts"  # Your Slack channel
  pagerduty = "your-pagerduty-service-key"  # Optional
  webhook = "https://your-webhook-url.com/alerts"  # Optional
}
```

### Step 4: Validate Configuration
```bash
# Run validation script
./scripts/validate.sh
```

This will check:
- ✅ Terraform installation and version
- ✅ Required tools (jq, curl)
- ✅ Configuration files
- ✅ Terraform syntax
- ✅ Datadog API connectivity
- ✅ Notification channel configuration

### Step 5: Deploy Infrastructure
```bash
# Interactive deployment (recommended for first time)
./scripts/deploy.sh

# Or automated deployment
./scripts/deploy.sh --auto-approve
```

The deployment will:
1. Initialize Terraform
2. Create a deployment plan
3. Apply the configuration
4. Create dashboards and alerts
5. Show deployment outputs

### Step 6: Verify Deployment
1. **Check Terraform Output**: Review the output URLs
2. **Access Dashboards**: Open the provided dashboard URLs
3. **Test Alerts**: Verify alert configurations in Datadog
4. **Check Notifications**: Ensure notification channels are working

## 🔧 Configuration Details

### Environment-Specific Setup

#### Production Environment
```hcl
environment = "production"
cpu_threshold_warning = 70
cpu_threshold_critical = 85
memory_threshold_warning = 80
memory_threshold_critical = 90
```

#### Staging Environment
```hcl
environment = "staging"
cpu_threshold_warning = 80
cpu_threshold_critical = 95
memory_threshold_warning = 85
memory_threshold_critical = 95
```

#### Development Environment
```hcl
environment = "development"
cpu_threshold_warning = 90
cpu_threshold_critical = 98
memory_threshold_warning = 90
memory_threshold_critical = 98
```

### AWS Integration Setup

#### 1. Install Datadog Agent on EC2
```bash
# On your EC2 instances
DD_API_KEY="your-api-key" DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
```

#### 2. Configure AWS Integration
1. In Datadog, go to **Integrations** → **AWS**
2. Click **Configuration** tab
3. Add your AWS account
4. Configure IAM role or access keys
5. Enable required services (EC2, RDS, ELB, etc.)

#### 3. Install CloudWatch Integration
```bash
# Install CloudWatch integration
datadog-agent integration install -t datadog-cloudwatch==1.0.0
```

### On-Premises Integration Setup

#### 1. Install Datadog Agent
```bash
# Linux
DD_API_KEY="your-api-key" DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Windows
# Download and run the Windows installer from Datadog
```

#### 2. Configure Agent
```yaml
# /etc/datadog-agent/datadog.yaml
api_key: your-api-key
site: datadoghq.com
tags:
  - env:production
  - datacenter:primary-datacenter
```

#### 3. Enable Integrations
```bash
# Enable system monitoring
datadog-agent integration enable system

# Enable database monitoring
datadog-agent integration enable mysql
datadog-agent integration enable postgres

# Enable web server monitoring
datadog-agent integration enable nginx
datadog-agent integration enable apache
```

## 📊 Dashboard Configuration

### Customizing Dashboards

#### Adding New Widgets
1. Edit the appropriate dashboard module
2. Add new widget definitions
3. Run `./scripts/update.sh` to apply changes

#### Modifying Existing Widgets
1. Update widget configurations in modules
2. Adjust time ranges, queries, or visualizations
3. Deploy updates

### Dashboard Permissions
1. In Datadog, go to **Dashboards** → **Dashboard List**
2. Find your dashboards
3. Click **Settings** → **Permissions**
4. Configure team access

## 🚨 Alert Configuration

### Notification Channel Setup

#### Email Notifications
```hcl
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com",
    "oncall@company.com"
  ]
}
```

#### Slack Integration
1. In Datadog, go to **Integrations** → **Slack**
2. Configure Slack integration
3. Add webhook URL
4. Configure channel notifications

#### PagerDuty Integration
1. In Datadog, go to **Integrations** → **PagerDuty**
2. Configure PagerDuty integration
3. Add service key
4. Configure escalation policies

### Alert Thresholds

#### CPU Alerts
```hcl
cpu_threshold_warning = 70   # 70% CPU usage
cpu_threshold_critical = 85  # 85% CPU usage
```

#### Memory Alerts
```hcl
memory_threshold_warning = 80   # 80% memory usage
memory_threshold_critical = 90  # 90% memory usage
```

#### Disk Alerts
```hcl
disk_threshold_warning = 80   # 80% disk usage
disk_threshold_critical = 90  # 90% disk usage
```

## 🔄 Ongoing Management

### Regular Maintenance

#### Weekly Tasks
- [ ] Review alert effectiveness
- [ ] Check dashboard usage
- [ ] Verify notification delivery

#### Monthly Tasks
- [ ] Update alert thresholds based on trends
- [ ] Review and optimize dashboard layouts
- [ ] Update team notifications
- [ ] Backup Terraform state

#### Quarterly Tasks
- [ ] Review overall monitoring strategy
- [ ] Update monitoring scope
- [ ] Evaluate new Datadog features
- [ ] Conduct disaster recovery testing

### Updating Configuration

#### Adding New Services
1. Update `monitor_aws_services` or `monitor_onprem_services`
2. Add new alert rules if needed
3. Run `./scripts/update.sh`

#### Modifying Thresholds
1. Update threshold variables in `terraform.tfvars`
2. Run `./scripts/update.sh --show-changes`
3. Review and apply changes

#### Adding New Environments
1. Copy configuration for new environment
2. Update environment-specific variables
3. Deploy using same scripts

## 🛠️ Troubleshooting

### Common Issues

#### 1. API Key Authentication Failed
```bash
# Check API key format
echo $DD_API_KEY | wc -c  # Should be 32 characters

# Test API connectivity
curl -H "DD-API-KEY: $DD_API_KEY" \
     -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
     "https://api.datadoghq.com/api/v1/validate"
```

#### 2. Terraform State Issues
```bash
# Check state file
terraform state list

# Refresh state
terraform refresh

# Import existing resources if needed
terraform import datadog_dashboard.example dashboard-id
```

#### 3. Resource Limits Exceeded
- Check Datadog account limits
- Review resource usage in Datadog console
- Contact Datadog support if needed

#### 4. Alert Notifications Not Working
- Verify notification channel configuration
- Test Slack/PagerDuty integrations
- Check email delivery settings

### Getting Help

#### 1. Validation Script
```bash
./scripts/validate.sh
```

#### 2. Terraform Debug
```bash
export TF_LOG=DEBUG
terraform plan
```

#### 3. Datadog Support
- Check Datadog documentation
- Contact Datadog support team
- Review community forums

## 📈 Best Practices

### Security
- Store API keys securely
- Use least privilege access
- Regular key rotation
- Monitor access logs

### Performance
- Optimize dashboard queries
- Use appropriate time ranges
- Limit widget count per dashboard
- Regular performance reviews

### Reliability
- Backup Terraform state
- Version control all changes
- Test in staging first
- Monitor deployment success

### Cost Optimization
- Review Datadog usage regularly
- Optimize log retention
- Use appropriate monitoring levels
- Monitor cost trends

## 🎯 Next Steps

After successful setup:

1. **Baseline Establishment**: Run for 1-2 weeks to establish baselines
2. **Threshold Tuning**: Adjust thresholds based on actual usage
3. **Team Training**: Train team on dashboard usage and alert response
4. **Documentation**: Document environment-specific procedures
5. **Automation**: Integrate with CI/CD pipelines
6. **Expansion**: Add monitoring for additional services

## 📞 Support Contacts

- **Datadog Support**: support@datadoghq.com
- **Terraform Support**: HashiCorp Community
- **Project Issues**: GitHub Issues
- **Internal Support**: Your DevOps team

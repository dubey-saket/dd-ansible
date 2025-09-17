# Datadog Dashboard and Alerting Automation

This project provides a comprehensive Terraform-based automation solution for creating and managing Datadog dashboards and alerting rules across AWS and on-premises environments.

## 🚀 Features

### Comprehensive Monitoring
- **AWS Infrastructure Monitoring**: EC2, RDS, ELB, S3, CloudFront, Lambda, ECS, EKS
- **On-Premises Infrastructure Monitoring**: System metrics, databases, web servers, network
- **Application Performance Monitoring**: Response times, error rates, throughput
- **Unified Dashboard**: Combined view of AWS and on-premises metrics

### Advanced Alerting
- **Multi-tier Alerting**: Warning and critical thresholds
- **Multiple Notification Channels**: Email, Slack, PagerDuty, Webhooks
- **Environment-specific Configuration**: Production, staging, development
- **Customizable Thresholds**: CPU, memory, disk, network, application metrics

### Infrastructure as Code
- **Terraform Modules**: Modular, reusable components
- **Version Control**: Complete infrastructure versioning
- **Automated Deployment**: Scripts for deployment, updates, and destruction
- **Configuration Management**: Centralized variable management

## 📋 Prerequisites

### Required Software
- **Terraform**: Version >= 1.0
- **jq**: JSON processor for script functionality
- **curl**: For API connectivity testing
- **Git**: For version control

### Datadog Requirements
- **Datadog Account**: Active Datadog subscription
- **API Key**: Datadog API key with appropriate permissions
- **Application Key**: Datadog application key
- **AWS Integration**: AWS accounts integrated with Datadog
- **On-Premises Integration**: Datadog agents installed on on-premises systems

## 🛠️ Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd data-dog-dashboard
```

### 2. Configure Variables
```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your configuration
nano terraform.tfvars
```

### 3. Required Configuration
Edit `terraform.tfvars` and set the following required variables:

```hcl
# Datadog API Configuration (REQUIRED)
datadog_api_key = "your-actual-datadog-api-key"
datadog_app_key = "your-actual-datadog-app-key"
datadog_api_url = "https://api.datadoghq.com"  # or https://api.datadoghq.eu for EU

# Environment Configuration
environment = "production"  # or staging, development

# AWS Configuration
aws_region    = "us-east-1"
aws_account_id = "123456789012"

# On-Premises Configuration
onprem_datacenter = "primary-datacenter"

# Notification Configuration
notification_channels = {
  email = [
    "admin@company.com",
    "ops-team@company.com"
  ]
  slack = "#alerts"
  pagerduty = "your-pagerduty-service-key"
  webhook = "https://your-webhook-url.com/alerts"
}
```

## 🚀 Quick Start

### 1. Validate Configuration
```bash
./scripts/validate.sh
```

### 2. Choose Deployment Option

#### Option A: Full Deployment (Dashboards + Alerts)
```bash
# Interactive deployment
./scripts/deploy.sh

# Automated deployment (no prompts)
./scripts/deploy.sh --auto-approve
```

#### Option B: Dashboards Only
```bash
# Deploy only dashboards
./scripts/deploy-dashboards.sh

# Automated deployment
./scripts/deploy-dashboards.sh --auto-approve
```

#### Option C: Alerts Only
```bash
# Deploy only alerts
./scripts/deploy-alerts.sh

# Automated deployment
./scripts/deploy-alerts.sh --auto-approve
```

### 3. Access Your Resources
After deployment, you can access your resources in the Datadog console:
- **Dashboards**: AWS Infrastructure, On-Premises Infrastructure, Unified Monitoring
- **Alerts**: AWS alerts, On-Premises alerts, Application alerts

## 📊 Dashboard Overview

### AWS Infrastructure Dashboard
- **EC2 Monitoring**: CPU, memory, network, status checks
- **RDS Performance**: CPU utilization, connections, query performance
- **Load Balancer Metrics**: Request count, latency, error rates
- **S3 Storage**: Bucket sizes, request metrics
- **Lambda Functions**: Duration, errors, invocations
- **CloudFront**: Cache hit rates, error rates
- **ECS/EKS**: Service health, node status

### On-Premises Infrastructure Dashboard
- **System Metrics**: CPU, memory, disk, load average
- **Database Performance**: MySQL, PostgreSQL metrics
- **Web Server Performance**: Nginx, Apache metrics
- **Network Monitoring**: Traffic, interface status
- **File System**: Usage, inodes
- **Process Monitoring**: Count, resource usage

### Unified Dashboard
- **Cross-Environment Comparison**: AWS vs on-premises metrics
- **Application Performance**: Response times, error rates
- **Service Health**: Overall infrastructure status
- **Cost Monitoring**: AWS cost trends
- **Alert Summary**: Active alerts across environments

## 🚨 Alerting Configuration

### Alert Types
1. **Infrastructure Alerts**
   - High CPU usage (>85%)
   - High memory usage (>90%)
   - High disk usage (>90%)
   - Service down/offline

2. **Application Alerts**
   - High response times (>2000ms)
   - High error rates (>5%)
   - Low throughput (<10 req/min)
   - Database connection issues

3. **Security Alerts**
   - Authentication failures
   - Authorization errors
   - Security-related log events

### Notification Channels
- **Email**: Direct email notifications
- **Slack**: Channel-based notifications (optional)
- **Microsoft Teams**: Teams channel notifications
- **Teams Power Automate**: Power Automate webhook integration
- **PagerDuty**: Escalation for critical alerts
- **Webhooks**: Custom integrations

## 🔧 Management Scripts

### Full Deployment Script (`./scripts/deploy.sh`)
```bash
# Interactive deployment (dashboards + alerts)
./scripts/deploy.sh

# Automated deployment
./scripts/deploy.sh --auto-approve
```

### Dashboards Only Script (`./scripts/deploy-dashboards.sh`)
```bash
# Deploy only dashboards
./scripts/deploy-dashboards.sh

# Automated deployment
./scripts/deploy-dashboards.sh --auto-approve
```

### Alerts Only Script (`./scripts/deploy-alerts.sh`)
```bash
# Deploy only alerts
./scripts/deploy-alerts.sh

# Automated deployment
./scripts/deploy-alerts.sh --auto-approve
```

### Update Script (`./scripts/update.sh`)
```bash
# Interactive update
./scripts/update.sh

# Show changes before applying
./scripts/update.sh --show-changes

# Show current status
./scripts/update.sh --show-status

# Automated update
./scripts/update.sh --auto-approve
```

### Validation Script (`./scripts/validate.sh`)
```bash
# Validate configuration and connectivity
./scripts/validate.sh
```

### Destruction Script (`./scripts/destroy.sh`)
```bash
# Interactive destruction
./scripts/destroy.sh

# Automated destruction (DANGEROUS)
./scripts/destroy.sh --auto-approve
```

## 📁 Project Structure

```
data-dog-dashboard/
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Variable definitions
├── outputs.tf                       # Output definitions
├── versions.tf                      # Provider version constraints
├── terraform.tfvars.example         # Example variables file
├── .gitignore                       # Git ignore rules
├── README.md                        # This documentation
├── scripts/                         # Management scripts
│   ├── deploy.sh                    # Deployment script
│   ├── update.sh                    # Update script
│   ├── validate.sh                  # Validation script
│   └── destroy.sh                   # Destruction script
└── modules/                         # Terraform modules
    ├── aws-dashboard/               # AWS dashboard module
    ├── onprem-dashboard/            # On-premises dashboard module
    ├── unified-dashboard/           # Unified dashboard module
    ├── aws-alerts/                  # AWS alerts module
    ├── onprem-alerts/               # On-premises alerts module
    └── application-alerts/          # Application alerts module
```

## ⚙️ Configuration Options

### Environment Variables
You can also set configuration using environment variables:
```bash
export TF_VAR_datadog_api_key="your-api-key"
export TF_VAR_datadog_app_key="your-app-key"
export TF_VAR_environment="production"
```

### Custom Thresholds
Adjust alert thresholds in `terraform.tfvars`:
```hcl
# CPU thresholds
cpu_threshold_warning = 70
cpu_threshold_critical = 85

# Memory thresholds
memory_threshold_warning = 80
memory_threshold_critical = 90

# Disk thresholds
disk_threshold_warning = 80
disk_threshold_critical = 90
```

### Service Monitoring
Configure which services to monitor:
```hcl
# AWS services
monitor_aws_services = ["ec2", "rds", "elb", "s3", "cloudfront", "lambda", "ecs", "eks"]

# On-premises services
monitor_onprem_services = ["system", "network", "database", "application", "storage"]

# Applications
application_names = ["web-app", "api-service", "database", "cache-service"]
```

## 🔄 Ongoing Management

### Regular Updates
1. **Review and Update Thresholds**: Adjust alert thresholds based on historical data
2. **Add New Services**: Extend monitoring to new AWS services or on-premises systems
3. **Update Notification Channels**: Add new team members or notification methods
4. **Version Control**: Commit changes to version control for tracking

### Monitoring Best Practices
1. **Baseline Establishment**: Run the system for 1-2 weeks to establish baselines
2. **Threshold Tuning**: Adjust thresholds based on actual usage patterns
3. **Alert Fatigue Prevention**: Ensure alerts are actionable and not too frequent
4. **Regular Reviews**: Monthly review of alert effectiveness and dashboard usage

### Troubleshooting
1. **Validation Issues**: Run `./scripts/validate.sh` to check configuration
2. **API Connectivity**: Verify Datadog API keys and network connectivity
3. **Terraform State**: Check for state file corruption or conflicts
4. **Resource Limits**: Ensure Datadog account limits are not exceeded

## 🛡️ Security Considerations

### API Key Management
- **Secure Storage**: Store API keys in secure locations (not in version control)
- **Key Rotation**: Regularly rotate API keys
- **Least Privilege**: Use keys with minimal required permissions
- **Environment Variables**: Use environment variables for sensitive data

### Access Control
- **Team Permissions**: Configure appropriate Datadog team permissions
- **Dashboard Access**: Control who can view and modify dashboards
- **Alert Management**: Restrict who can modify alert configurations

## 📈 Scaling and Extensions

### Adding New Environments
1. Copy the configuration for a new environment
2. Update environment-specific variables
3. Deploy using the same scripts

### Custom Metrics
1. Add custom metrics to the appropriate modules
2. Update alerting rules for new metrics
3. Extend dashboards with new widgets

### Integration with CI/CD
1. Add Terraform validation to CI pipeline
2. Automated deployment on configuration changes
3. Environment-specific deployments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Datadog documentation
3. Open an issue in the repository
4. Contact your Datadog support team

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📱 Microsoft Teams Integration

This solution supports Microsoft Teams integration for alert notifications. You can use either:

- **Teams Webhook**: Direct Teams channel integration
- **Teams Power Automate**: Power Automate webhook integration
- **Custom Webhook**: Custom webhook that forwards to Teams

### Quick Teams Setup
1. **Get Teams Webhook URL** (if available)
2. **Or Create Power Automate Flow** (if no webhook)
3. **Update terraform.tfvars** with Teams configuration
4. **Deploy with Teams integration**

For detailed Teams integration instructions, see [TEAMS_INTEGRATION.md](TEAMS_INTEGRATION.md).

## 🔗 Useful Links

- [Datadog Terraform Provider Documentation](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
- [Datadog API Documentation](https://docs.datadoghq.com/api/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Datadog Best Practices](https://docs.datadoghq.com/monitors/guide/)
- [Microsoft Teams Integration Guide](TEAMS_INTEGRATION.md)

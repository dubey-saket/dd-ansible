# Datadog Dashboard and Alerting Automation
# This Terraform configuration creates comprehensive monitoring dashboards
# and alerting rules for AWS and On-Prem environments

terraform {
  required_version = ">= 1.0"
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

# Configure the Datadog Provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

# Data sources for existing resources
data "datadog_monitor" "existing_monitors" {
  depends_on = [datadog_monitor.critical_alerts]
}

# Local values for common configurations
locals {
  common_tags = [
    "env:${var.environment}",
    "managed-by:terraform",
    "project:datadog-automation"
  ]
  
  aws_tags = concat(local.common_tags, [
    "cloud-provider:aws",
    "region:${var.aws_region}"
  ])
  
  onprem_tags = concat(local.common_tags, [
    "cloud-provider:on-premises",
    "datacenter:${var.onprem_datacenter}"
  ])
}

# Import dashboard modules
module "aws_dashboard" {
  source = "./modules/aws-dashboard"
  
  environment = var.environment
  aws_region  = var.aws_region
  tags        = local.aws_tags
}

module "onprem_dashboard" {
  source = "./modules/onprem-dashboard"
  
  environment = var.environment
  datacenter  = var.onprem_datacenter
  tags        = local.onprem_tags
}

module "unified_dashboard" {
  source = "./modules/unified-dashboard"
  
  environment = var.environment
  aws_region  = var.aws_region
  datacenter  = var.onprem_datacenter
  tags        = local.common_tags
}

# Import alerting modules
module "aws_alerts" {
  source = "./modules/aws-alerts"
  
  environment = var.environment
  aws_region  = var.aws_region
  tags        = local.aws_tags
  
  notification_channels = var.notification_channels
}

module "onprem_alerts" {
  source = "./modules/onprem-alerts"
  
  environment = var.environment
  datacenter  = var.onprem_datacenter
  tags        = local.onprem_tags
  
  notification_channels = var.notification_channels
}

module "application_alerts" {
  source = "./modules/application-alerts"
  
  environment = var.environment
  tags        = local.common_tags
  
  notification_channels = var.notification_channels
}

# Output important information
output "dashboard_urls" {
  description = "URLs of created dashboards"
  value = {
    aws_dashboard     = module.aws_dashboard.dashboard_url
    onprem_dashboard  = module.onprem_dashboard.dashboard_url
    unified_dashboard = module.unified_dashboard.dashboard_url
  }
}

output "monitor_count" {
  description = "Number of monitors created"
  value = {
    aws_monitors      = module.aws_alerts.monitor_count
    onprem_monitors   = module.onprem_alerts.monitor_count
    app_monitors      = module.application_alerts.monitor_count
  }
}

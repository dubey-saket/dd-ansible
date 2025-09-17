# Alerts Only Configuration
# This file deploys only the alerting components

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

# Local values for common configurations
locals {
  common_tags = [
    "env:${var.environment}",
    "managed-by:terraform",
    "project:datadog-automation",
    "component:alerts"
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

# Import alerting modules only
module "aws_alerts" {
  source = "./modules/aws-alerts"
  
  environment = var.environment
  aws_region  = var.aws_region
  tags        = local.aws_tags
  
  notification_channels = var.notification_channels
  
  cpu_threshold_warning = var.cpu_threshold_warning
  cpu_threshold_critical = var.cpu_threshold_critical
  memory_threshold_warning = var.memory_threshold_warning
  memory_threshold_critical = var.memory_threshold_critical
}

module "onprem_alerts" {
  source = "./modules/onprem-alerts"
  
  environment = var.environment
  datacenter  = var.onprem_datacenter
  tags        = local.onprem_tags
  
  notification_channels = var.notification_channels
  
  cpu_threshold_warning = var.cpu_threshold_warning
  cpu_threshold_critical = var.cpu_threshold_critical
  memory_threshold_warning = var.memory_threshold_warning
  memory_threshold_critical = var.memory_threshold_critical
  disk_threshold_warning = var.disk_threshold_warning
  disk_threshold_critical = var.disk_threshold_critical
}

module "application_alerts" {
  source = "./modules/application-alerts"
  
  environment = var.environment
  tags        = local.common_tags
  
  notification_channels = var.notification_channels
}

# Output alert information
output "monitor_count" {
  description = "Number of monitors created"
  value = {
    aws_monitors      = length(module.aws_alerts.monitor_count)
    onprem_monitors   = length(module.onprem_alerts.monitor_count)
    app_monitors      = length(module.application_alerts.monitor_count)
  }
}

output "monitor_names" {
  description = "Names of created monitors"
  value = concat(
    module.aws_alerts.monitor_names,
    module.onprem_alerts.monitor_names,
    module.application_alerts.monitor_names
  )
}

output "deployment_type" {
  description = "Type of deployment"
  value = "alerts-only"
}

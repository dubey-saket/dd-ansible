# Dashboards Only Configuration
# This file deploys only the dashboard components

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
    "component:dashboards"
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

# Import dashboard modules only
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

# Output dashboard information
output "dashboard_urls" {
  description = "URLs of created dashboards"
  value = {
    aws_dashboard     = module.aws_dashboard.dashboard_url
    onprem_dashboard  = module.onprem_dashboard.dashboard_url
    unified_dashboard = module.unified_dashboard.dashboard_url
  }
}

output "dashboard_count" {
  description = "Number of dashboards created"
  value = 3
}

output "deployment_type" {
  description = "Type of deployment"
  value = "dashboards-only"
}

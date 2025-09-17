# Outputs for the main Datadog automation configuration

output "terraform_version" {
  description = "Terraform version used"
  value       = terraform.version
}

output "datadog_provider_version" {
  description = "Datadog provider version used"
  value       = "~> 3.0"
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "onprem_datacenter" {
  description = "On-premises datacenter name"
  value       = var.onprem_datacenter
}

output "notification_channels" {
  description = "Configured notification channels"
  value = {
    email_count = length(var.notification_channels.email)
    slack_configured = var.notification_channels.slack != null
    pagerduty_configured = var.notification_channels.pagerduty != null
    webhook_configured = var.notification_channels.webhook != null
  }
  sensitive = true
}

output "monitoring_scope" {
  description = "Monitoring scope configuration"
  value = {
    aws_services = var.monitor_aws_services
    onprem_services = var.monitor_onprem_services
    applications = var.application_names
    services = var.service_names
  }
}

output "thresholds" {
  description = "Alert thresholds configuration"
  value = {
    cpu_warning = var.cpu_threshold_warning
    cpu_critical = var.cpu_threshold_critical
    memory_warning = var.memory_threshold_warning
    memory_critical = var.memory_threshold_critical
    disk_warning = var.disk_threshold_warning
    disk_critical = var.disk_threshold_critical
  }
}

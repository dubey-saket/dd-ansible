# Variables for Datadog Dashboard and Alerting Automation

# Datadog API Configuration
variable "datadog_api_key" {
  description = "Datadog API key for authentication"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application key for authentication"
  type        = string
  sensitive   = true
}

variable "datadog_api_url" {
  description = "Datadog API URL (default: https://api.datadoghq.com)"
  type        = string
  default     = "https://api.datadoghq.com"
}

# Environment Configuration
variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for monitoring"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID for resource identification"
  type        = string
  default     = ""
}

# On-Premises Configuration
variable "onprem_datacenter" {
  description = "On-premises datacenter name"
  type        = string
  default     = "primary-datacenter"
}

# Notification Configuration
variable "notification_channels" {
  description = "Notification channels for alerts"
  type = object({
    email = list(string)
    slack = optional(string)
    pagerduty = optional(string)
    webhook = optional(string)
    teams = optional(string)
    teams_power_automation = optional(string)
  })
  default = {
    email = []
    slack = null
    pagerduty = null
    webhook = null
    teams = null
    teams_power_automation = null
  }
}

# Dashboard Configuration
variable "dashboard_refresh_interval" {
  description = "Dashboard refresh interval in seconds"
  type        = number
  default     = 30
}

variable "dashboard_timeframe" {
  description = "Default dashboard timeframe"
  type        = string
  default     = "1h"
}

# Alert Configuration
variable "alert_evaluation_delay" {
  description = "Alert evaluation delay in seconds"
  type        = number
  default     = 300
}

variable "alert_new_host_delay" {
  description = "New host delay for alerts in seconds"
  type        = number
  default     = 300
}

variable "alert_new_group_delay" {
  description = "New group delay for alerts in seconds"
  type        = number
  default     = 300
}

# Threshold Configuration
variable "cpu_threshold_warning" {
  description = "CPU usage warning threshold percentage"
  type        = number
  default     = 70
}

variable "cpu_threshold_critical" {
  description = "CPU usage critical threshold percentage"
  type        = number
  default     = 85
}

variable "memory_threshold_warning" {
  description = "Memory usage warning threshold percentage"
  type        = number
  default     = 80
}

variable "memory_threshold_critical" {
  description = "Memory usage critical threshold percentage"
  type        = number
  default     = 90
}

variable "disk_threshold_warning" {
  description = "Disk usage warning threshold percentage"
  type        = number
  default     = 80
}

variable "disk_threshold_critical" {
  description = "Disk usage critical threshold percentage"
  type        = number
  default     = 90
}

# Application-specific Configuration
variable "application_names" {
  description = "List of application names to monitor"
  type        = list(string)
  default     = ["web-app", "api-service", "database"]
}

variable "service_names" {
  description = "List of service names to monitor"
  type        = list(string)
  default     = ["nginx", "apache", "mysql", "redis"]
}

# Custom Tags
variable "custom_tags" {
  description = "Additional custom tags to apply to all resources"
  type        = list(string)
  default     = []
}

# Monitoring Scope
variable "monitor_aws_services" {
  description = "List of AWS services to monitor"
  type        = list(string)
  default     = ["ec2", "rds", "elb", "s3", "cloudfront", "lambda"]
}

variable "monitor_onprem_services" {
  description = "List of on-premises services to monitor"
  type        = list(string)
  default     = ["system", "network", "database", "application"]
}

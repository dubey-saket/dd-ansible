# Variables for AWS Alerts Module

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the monitors"
  type        = list(string)
  default     = []
}

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
}

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

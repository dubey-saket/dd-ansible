# Variables for Application Alerts Module

variable "environment" {
  description = "Environment name"
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
  })
}

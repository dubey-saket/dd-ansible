# Variables for Notification Helper Module

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

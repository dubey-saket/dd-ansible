# Outputs for Notification Helper Module

output "notification_string" {
  description = "Formatted notification string for regular alerts"
  value       = local.notification_string
}

output "escalation_string" {
  description = "Formatted escalation string for critical alerts"
  value       = local.escalation_string
}

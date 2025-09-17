# Outputs for Unified Dashboard Module

output "dashboard_id" {
  description = "ID of the created unified dashboard"
  value       = datadog_dashboard.unified_comprehensive.id
}

output "dashboard_url" {
  description = "URL of the created unified dashboard"
  value       = datadog_dashboard.unified_comprehensive.url
}

output "dashboard_title" {
  description = "Title of the created unified dashboard"
  value       = datadog_dashboard.unified_comprehensive.title
}

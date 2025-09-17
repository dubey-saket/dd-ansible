# Outputs for On-Premises Dashboard Module

output "dashboard_id" {
  description = "ID of the created on-premises dashboard"
  value       = datadog_dashboard.onprem_comprehensive.id
}

output "dashboard_url" {
  description = "URL of the created on-premises dashboard"
  value       = datadog_dashboard.onprem_comprehensive.url
}

output "dashboard_title" {
  description = "Title of the created on-premises dashboard"
  value       = datadog_dashboard.onprem_comprehensive.title
}

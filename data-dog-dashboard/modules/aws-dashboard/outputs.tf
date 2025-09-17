# Outputs for AWS Dashboard Module

output "dashboard_id" {
  description = "ID of the created AWS dashboard"
  value       = datadog_dashboard.aws_comprehensive.id
}

output "dashboard_url" {
  description = "URL of the created AWS dashboard"
  value       = datadog_dashboard.aws_comprehensive.url
}

output "dashboard_title" {
  description = "Title of the created AWS dashboard"
  value       = datadog_dashboard.aws_comprehensive.title
}

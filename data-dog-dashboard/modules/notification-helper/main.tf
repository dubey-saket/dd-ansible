# Notification Helper Module
# Provides formatted notification strings for alerts

locals {
  # Build notification string for regular alerts
  notification_string = join(" ", compact([
    var.notification_channels.slack != null ? "@slack-${var.notification_channels.slack}" : "",
    var.notification_channels.teams != null ? "@teams-${var.notification_channels.teams}" : "",
    length(var.notification_channels.email) > 0 ? "@${join(" @", var.notification_channels.email)}" : ""
  ]))
  
  # Build escalation string for critical alerts
  escalation_string = join(" ", compact([
    var.notification_channels.pagerduty != null ? "@pagerduty-${var.notification_channels.pagerduty}" : "",
    var.notification_channels.teams_power_automation != null ? "@webhook-${var.notification_channels.teams_power_automation}" : "",
    var.notification_channels.slack != null ? "@slack-${var.notification_channels.slack}" : "",
    var.notification_channels.teams != null ? "@teams-${var.notification_channels.teams}" : ""
  ]))
}

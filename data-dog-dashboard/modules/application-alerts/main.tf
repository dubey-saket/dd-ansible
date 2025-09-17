# Application Alerts Module
# Creates comprehensive alerting rules for application performance

# Application Response Time Alert
resource "datadog_monitor" "app_response_time_high" {
  name               = "Application High Response Time - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has high response time: {{value}}ms @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} response time is critically high: {{value}}ms @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:trace.web.request.duration{*} by {service} > 2000"

  monitor_thresholds {
    warning  = 1000
    critical = 2000
  }

  tags = concat(var.tags, ["service:application", "alert:performance"])
}

# Application Error Rate Alert
resource "datadog_monitor" "app_error_rate_high" {
  name               = "Application High Error Rate - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has high error rate: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} error rate is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:trace.web.request.errors{*} by {service} > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = concat(var.tags, ["service:application", "alert:errors"])
}

# Application Throughput Alert
resource "datadog_monitor" "app_throughput_low" {
  name               = "Application Low Throughput - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has low throughput: {{value}} requests/min @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} throughput is critically low: {{value}} requests/min @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:trace.web.request.hits{*} by {service} < 10"

  monitor_thresholds {
    warning  = 20
    critical = 10
  }

  tags = concat(var.tags, ["service:application", "alert:throughput"])
}

# Database Connection Pool Alert
resource "datadog_monitor" "app_db_connection_pool_high" {
  name               = "Application High DB Connection Pool - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has high database connection pool usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} database connection pool usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:custom.db.connection_pool.usage{*} by {service} > 90"

  monitor_thresholds {
    warning  = 80
    critical = 90
  }

  tags = concat(var.tags, ["service:database", "alert:connection"])
}

# Cache Hit Rate Alert
resource "datadog_monitor" "app_cache_hit_rate_low" {
  name               = "Application Low Cache Hit Rate - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has low cache hit rate: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} cache hit rate is critically low: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:custom.cache.hit_rate{*} by {service} < 70"

  monitor_thresholds {
    warning  = 80
    critical = 70
  }

  tags = concat(var.tags, ["service:cache", "alert:performance"])
}

# Memory Leak Alert
resource "datadog_monitor" "app_memory_leak" {
  name               = "Application Memory Leak - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} may have a memory leak: {{value}}MB @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} memory usage is critically high, possible memory leak: {{value}}MB @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_1h):avg:custom.app.memory.usage{*} by {service} > 1000"

  monitor_thresholds {
    warning  = 500
    critical = 1000
  }

  tags = concat(var.tags, ["service:application", "alert:memory"])
}

# API Rate Limit Alert
resource "datadog_monitor" "app_api_rate_limit" {
  name               = "Application API Rate Limit - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} is hitting API rate limits: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} is critically hitting API rate limits: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:custom.api.rate_limit.hits{*} by {service} > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = concat(var.tags, ["service:api", "alert:rate-limit"])
}

# Queue Depth Alert
resource "datadog_monitor" "app_queue_depth_high" {
  name               = "Application High Queue Depth - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has high queue depth: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} queue depth is critically high: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:custom.queue.depth{*} by {service} > 1000"

  monitor_thresholds {
    warning  = 500
    critical = 1000
  }

  tags = concat(var.tags, ["service:queue", "alert:performance"])
}

# Dead Letter Queue Alert
resource "datadog_monitor" "app_dead_letter_queue" {
  name               = "Application Dead Letter Queue - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} has messages in dead letter queue: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} has critical messages in dead letter queue: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:custom.queue.dead_letter{*} by {service} > 0"

  monitor_thresholds {
    warning  = 0
    critical = 0
  }

  tags = concat(var.tags, ["service:queue", "alert:errors"])
}

# Service Health Check Alert
resource "datadog_monitor" "app_health_check_failed" {
  name               = "Application Health Check Failed - ${var.environment}"
  type               = "service check"
  message            = "Application {{service}} health check failed @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} health check failed @pagerduty-${var.notification_channels.pagerduty}"

  query = "\"custom.health.check\".over(\"*\").by(\"service\").last(2).count_by_status()"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  tags = concat(var.tags, ["service:health", "alert:availability"])
}

# Custom Business Metric Alert
resource "datadog_monitor" "app_business_metric_anomaly" {
  name               = "Application Business Metric Anomaly - ${var.environment}"
  type               = "metric alert"
  message            = "Application {{service}} business metric shows anomaly: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} business metric shows critical anomaly: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_1h):avg:custom.business.metric{*} by {service} > 100"

  monitor_thresholds {
    warning  = 80
    critical = 100
  }

  tags = concat(var.tags, ["service:business", "alert:anomaly"])
}

# Log Error Rate Alert
resource "datadog_monitor" "app_log_errors_high" {
  name               = "Application High Log Error Rate - ${var.environment}"
  type               = "log alert"
  message            = "Application {{service}} has high log error rate: {{value}} errors/min @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} log error rate is critically high: {{value}} errors/min @pagerduty-${var.notification_channels.pagerduty}"

  query = "logs(\"status:error service:{{service}}\").index(\"*\").rollup(\"count\").last(\"5m\") > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = concat(var.tags, ["service:logging", "alert:errors"])
}

# Security Alert
resource "datadog_monitor" "app_security_alert" {
  name               = "Application Security Alert - ${var.environment}"
  type               = "log alert"
  message            = "Application {{service}} security alert: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "Application {{service}} critical security alert: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "logs(\"status:error service:{{service}} (authentication OR authorization OR security)\").index(\"*\").rollup(\"count\").last(\"5m\") > 0"

  monitor_thresholds {
    warning  = 0
    critical = 0
  }

  tags = concat(var.tags, ["service:security", "alert:security"])
}

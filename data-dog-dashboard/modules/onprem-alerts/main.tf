# On-Premises Alerts Module
# Creates comprehensive alerting rules for on-premises infrastructure

# System CPU Alert
resource "datadog_monitor" "onprem_cpu_high" {
  name               = "On-Premises High CPU Usage - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} has high CPU usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} CPU usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.cpu.user{*} by {host} > ${var.cpu_threshold_critical}"

  monitor_thresholds {
    warning  = var.cpu_threshold_warning
    critical = var.cpu_threshold_critical
  }

  tags = concat(var.tags, ["service:system", "alert:onprem"])
}

# System Memory Alert
resource "datadog_monitor" "onprem_memory_high" {
  name               = "On-Premises High Memory Usage - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} has high memory usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} memory usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.mem.pct_usable{*} by {host} < ${100 - var.memory_threshold_critical}"

  monitor_thresholds {
    warning  = 100 - var.memory_threshold_warning
    critical = 100 - var.memory_threshold_critical
  }

  tags = concat(var.tags, ["service:system", "alert:onprem"])
}

# Disk Usage Alert
resource "datadog_monitor" "onprem_disk_high" {
  name               = "On-Premises High Disk Usage - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} disk {{device}} has high usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} disk {{device}} usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.disk.in_use{*} by {host,device} > ${var.disk_threshold_critical}"

  monitor_thresholds {
    warning  = var.disk_threshold_warning
    critical = var.disk_threshold_critical
  }

  tags = concat(var.tags, ["service:system", "alert:onprem"])
}

# Load Average Alert
resource "datadog_monitor" "onprem_load_high" {
  name               = "On-Premises High Load Average - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} has high load average: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} load average is critically high: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.load.1{*} by {host} > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = concat(var.tags, ["service:system", "alert:onprem"])
}

# MySQL Performance Alert
resource "datadog_monitor" "onprem_mysql_slow_queries" {
  name               = "On-Premises MySQL Slow Queries - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises MySQL host {{host}} has slow queries: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises MySQL host {{host}} slow queries are critically high: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:mysql.performance.slow_queries{*} by {host} > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = concat(var.tags, ["service:mysql", "alert:onprem"])
}

# PostgreSQL Performance Alert
resource "datadog_monitor" "onprem_postgresql_connections" {
  name               = "On-Premises PostgreSQL High Connections - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises PostgreSQL host {{host}} has high connection count: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises PostgreSQL host {{host}} connection count is critically high: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:postgresql.connections{*} by {host} > 80"

  monitor_thresholds {
    warning  = 60
    critical = 80
  }

  tags = concat(var.tags, ["service:postgresql", "alert:onprem"])
}

# Nginx Error Rate Alert
resource "datadog_monitor" "onprem_nginx_errors" {
  name               = "On-Premises Nginx High Error Rate - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises Nginx host {{host}} has high error rate: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises Nginx host {{host}} error rate is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:nginx.net.4xx{*} by {host} > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = concat(var.tags, ["service:nginx", "alert:onprem"])
}

# Apache Error Rate Alert
resource "datadog_monitor" "onprem_apache_errors" {
  name               = "On-Premises Apache High Error Rate - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises Apache host {{host}} has high error rate: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises Apache host {{host}} error rate is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:apache.performance.4xx{*} by {host} > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = concat(var.tags, ["service:apache", "alert:onprem"])
}

# Redis Memory Usage Alert
resource "datadog_monitor" "onprem_redis_memory" {
  name               = "On-Premises Redis High Memory Usage - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises Redis host {{host}} has high memory usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises Redis host {{host}} memory usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:redis.memory.used_memory_percentage{*} by {host} > 90"

  monitor_thresholds {
    warning  = 80
    critical = 90
  }

  tags = concat(var.tags, ["service:redis", "alert:onprem"])
}

# Network Interface Down Alert
resource "datadog_monitor" "onprem_network_down" {
  name               = "On-Premises Network Interface Down - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} network interface {{device}} is down @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} network interface {{device}} is down @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.net.bytes_sent{*} by {host,device} < 1"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  tags = concat(var.tags, ["service:network", "alert:onprem"])
}

# File System Inodes Alert
resource "datadog_monitor" "onprem_inodes_high" {
  name               = "On-Premises High Inode Usage - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} filesystem {{mountpoint}} has high inode usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} filesystem {{mountpoint}} inode usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.fs.inodes.in_use{*} by {host,mountpoint} > 90"

  monitor_thresholds {
    warning  = 80
    critical = 90
  }

  tags = concat(var.tags, ["service:filesystem", "alert:onprem"])
}

# Swap Usage Alert
resource "datadog_monitor" "onprem_swap_high" {
  name               = "On-Premises High Swap Usage - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} has high swap usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} swap usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.swap.pct_free{*} by {host} < 10"

  monitor_thresholds {
    warning  = 20
    critical = 10
  }

  tags = concat(var.tags, ["service:system", "alert:onprem"])
}

# Process Count Alert
resource "datadog_monitor" "onprem_process_count_high" {
  name               = "On-Premises High Process Count - ${var.environment}"
  type               = "metric alert"
  message            = "On-premises host {{host}} has high process count: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} process count is critically high: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:system.proc.total{*} by {host} > 1000"

  monitor_thresholds {
    warning  = 500
    critical = 1000
  }

  tags = concat(var.tags, ["service:system", "alert:onprem"])
}

# Datadog Agent Down Alert
resource "datadog_monitor" "onprem_agent_down" {
  name               = "On-Premises Datadog Agent Down - ${var.environment}"
  type               = "service check"
  message            = "On-premises host {{host}} Datadog agent is down @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "On-premises host {{host}} Datadog agent is down @pagerduty-${var.notification_channels.pagerduty}"

  query = "\"datadog.agent.up\".over(\"*\").by(\"host\").last(2).count_by_status()"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  tags = concat(var.tags, ["service:datadog-agent", "alert:onprem"])
}

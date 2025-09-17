# AWS Alerts Module
# Creates comprehensive alerting rules for AWS resources

# EC2 CPU Alert
resource "datadog_monitor" "aws_ec2_cpu_high" {
  name               = "AWS EC2 High CPU Usage - ${var.environment}"
  type               = "metric alert"
  message            = "AWS EC2 instance {{instance-id}} has high CPU usage: {{value}}% ${var.notification_channels.slack != null ? "@slack-" + var.notification_channels.slack : ""} ${var.notification_channels.teams != null ? "@teams-" + var.notification_channels.teams : ""} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS EC2 instance {{instance-id}} CPU usage is critically high: {{value}}% ${var.notification_channels.pagerduty != null ? "@pagerduty-" + var.notification_channels.pagerduty : ""} ${var.notification_channels.teams_power_automation != null ? "@webhook-" + var.notification_channels.teams_power_automation : ""}"

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{*} by {instance-id} > ${var.cpu_threshold_critical}"

  monitor_thresholds {
    warning  = var.cpu_threshold_warning
    critical = var.cpu_threshold_critical
  }

  tags = concat(var.tags, ["service:ec2", "alert:aws"])
}

# EC2 Memory Alert
resource "datadog_monitor" "aws_ec2_memory_high" {
  name               = "AWS EC2 High Memory Usage - ${var.environment}"
  type               = "metric alert"
  message            = "AWS EC2 instance {{instance-id}} has high memory usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS EC2 instance {{instance-id}} memory usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.ec2.memoryutilization{*} by {instance-id} > ${var.memory_threshold_critical}"

  monitor_thresholds {
    warning  = var.memory_threshold_warning
    critical = var.memory_threshold_critical
  }

  tags = concat(var.tags, ["service:ec2", "alert:aws"])
}

# RDS CPU Alert
resource "datadog_monitor" "aws_rds_cpu_high" {
  name               = "AWS RDS High CPU Usage - ${var.environment}"
  type               = "metric alert"
  message            = "AWS RDS instance {{dbinstance-identifier}} has high CPU usage: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS RDS instance {{dbinstance-identifier}} CPU usage is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.rds.cpuutilization{*} by {dbinstance-identifier} > ${var.cpu_threshold_critical}"

  monitor_thresholds {
    warning  = var.cpu_threshold_warning
    critical = var.cpu_threshold_critical
  }

  tags = concat(var.tags, ["service:rds", "alert:aws"])
}

# RDS Connection Alert
resource "datadog_monitor" "aws_rds_connections_high" {
  name               = "AWS RDS High Connection Count - ${var.environment}"
  type               = "metric alert"
  message            = "AWS RDS instance {{dbinstance-identifier}} has high connection count: {{value}} @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS RDS instance {{dbinstance-identifier}} connection count is critically high: {{value}} @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.rds.database_connections{*} by {dbinstance-identifier} > 80"

  monitor_thresholds {
    warning  = 60
    critical = 80
  }

  tags = concat(var.tags, ["service:rds", "alert:aws"])
}

# ELB High Latency Alert
resource "datadog_monitor" "aws_elb_latency_high" {
  name               = "AWS ELB High Latency - ${var.environment}"
  type               = "metric alert"
  message            = "AWS ELB {{loadbalancername}} has high latency: {{value}}ms @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS ELB {{loadbalancername}} latency is critically high: {{value}}ms @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.elb.latency{*} by {loadbalancername} > 1000"

  monitor_thresholds {
    warning  = 500
    critical = 1000
  }

  tags = concat(var.tags, ["service:elb", "alert:aws"])
}

# Lambda Error Rate Alert
resource "datadog_monitor" "aws_lambda_errors_high" {
  name               = "AWS Lambda High Error Rate - ${var.environment}"
  type               = "metric alert"
  message            = "AWS Lambda function {{functionname}} has high error rate: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS Lambda function {{functionname}} error rate is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.lambda.errors{*} by {functionname} > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = concat(var.tags, ["service:lambda", "alert:aws"])
}

# Lambda Duration Alert
resource "datadog_monitor" "aws_lambda_duration_high" {
  name               = "AWS Lambda High Duration - ${var.environment}"
  type               = "metric alert"
  message            = "AWS Lambda function {{functionname}} has high duration: {{value}}ms @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS Lambda function {{functionname}} duration is critically high: {{value}}ms @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.lambda.duration{*} by {functionname} > 30000"

  monitor_thresholds {
    warning  = 10000
    critical = 30000
  }

  tags = concat(var.tags, ["service:lambda", "alert:aws"])
}

# S3 Bucket Size Alert
resource "datadog_monitor" "aws_s3_bucket_size_high" {
  name               = "AWS S3 Bucket Size High - ${var.environment}"
  type               = "metric alert"
  message            = "AWS S3 bucket {{bucketname}} size is high: {{value}}GB @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS S3 bucket {{bucketname}} size is critically high: {{value}}GB @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_1h):avg:aws.s3.bucket_size_bytes{*} by {bucketname} > 1000000000000"

  monitor_thresholds {
    warning  = 500000000000
    critical = 1000000000000
  }

  tags = concat(var.tags, ["service:s3", "alert:aws"])
}

# CloudFront Error Rate Alert
resource "datadog_monitor" "aws_cloudfront_errors_high" {
  name               = "AWS CloudFront High Error Rate - ${var.environment}"
  type               = "metric alert"
  message            = "AWS CloudFront distribution {{distributionid}} has high error rate: {{value}}% @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS CloudFront distribution {{distributionid}} error rate is critically high: {{value}}% @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.cloudfront.4xx_error_rate{*} by {distributionid} > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = concat(var.tags, ["service:cloudfront", "alert:aws"])
}

# EC2 Status Check Failed Alert
resource "datadog_monitor" "aws_ec2_status_check_failed" {
  name               = "AWS EC2 Status Check Failed - ${var.environment}"
  type               = "metric alert"
  message            = "AWS EC2 instance {{instance-id}} status check failed @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS EC2 instance {{instance-id}} status check failed @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.ec2.status_check_failed{*} by {instance-id} > 0"

  monitor_thresholds {
    warning  = 0
    critical = 0
  }

  tags = concat(var.tags, ["service:ec2", "alert:aws"])
}

# ECS Service Down Alert
resource "datadog_monitor" "aws_ecs_service_down" {
  name               = "AWS ECS Service Down - ${var.environment}"
  type               = "metric alert"
  message            = "AWS ECS service {{servicename}} is down @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS ECS service {{servicename}} is down @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.ecs.running_count{*} by {servicename} < 1"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  tags = concat(var.tags, ["service:ecs", "alert:aws"])
}

# EKS Node Ready Alert
resource "datadog_monitor" "aws_eks_node_not_ready" {
  name               = "AWS EKS Node Not Ready - ${var.environment}"
  type               = "metric alert"
  message            = "AWS EKS node {{nodename}} is not ready @slack-${var.notification_channels.slack} @${join(" @", var.notification_channels.email)}"
  escalation_message = "AWS EKS node {{nodename}} is not ready @pagerduty-${var.notification_channels.pagerduty}"

  query = "avg(last_5m):avg:aws.eks.node_ready{*} by {nodename} < 1"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  tags = concat(var.tags, ["service:eks", "alert:aws"])
}

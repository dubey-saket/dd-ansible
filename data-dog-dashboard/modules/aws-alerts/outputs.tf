# Outputs for AWS Alerts Module

output "monitor_count" {
  description = "Number of AWS monitors created"
  value = {
    ec2_cpu_high              = datadog_monitor.aws_ec2_cpu_high.id
    ec2_memory_high           = datadog_monitor.aws_ec2_memory_high.id
    rds_cpu_high              = datadog_monitor.aws_rds_cpu_high.id
    rds_connections_high      = datadog_monitor.aws_rds_connections_high.id
    elb_latency_high          = datadog_monitor.aws_elb_latency_high.id
    lambda_errors_high        = datadog_monitor.aws_lambda_errors_high.id
    lambda_duration_high      = datadog_monitor.aws_lambda_duration_high.id
    s3_bucket_size_high       = datadog_monitor.aws_s3_bucket_size_high.id
    cloudfront_errors_high    = datadog_monitor.aws_cloudfront_errors_high.id
    ec2_status_check_failed   = datadog_monitor.aws_ec2_status_check_failed.id
    ecs_service_down          = datadog_monitor.aws_ecs_service_down.id
    eks_node_not_ready        = datadog_monitor.aws_eks_node_not_ready.id
  }
}

output "monitor_names" {
  description = "Names of created AWS monitors"
  value = [
    datadog_monitor.aws_ec2_cpu_high.name,
    datadog_monitor.aws_ec2_memory_high.name,
    datadog_monitor.aws_rds_cpu_high.name,
    datadog_monitor.aws_rds_connections_high.name,
    datadog_monitor.aws_elb_latency_high.name,
    datadog_monitor.aws_lambda_errors_high.name,
    datadog_monitor.aws_lambda_duration_high.name,
    datadog_monitor.aws_s3_bucket_size_high.name,
    datadog_monitor.aws_cloudfront_errors_high.name,
    datadog_monitor.aws_ec2_status_check_failed.name,
    datadog_monitor.aws_ecs_service_down.name,
    datadog_monitor.aws_eks_node_not_ready.name
  ]
}

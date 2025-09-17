# Outputs for Application Alerts Module

output "monitor_count" {
  description = "Number of application monitors created"
  value = {
    response_time_high        = datadog_monitor.app_response_time_high.id
    error_rate_high          = datadog_monitor.app_error_rate_high.id
    throughput_low           = datadog_monitor.app_throughput_low.id
    db_connection_pool_high  = datadog_monitor.app_db_connection_pool_high.id
    cache_hit_rate_low       = datadog_monitor.app_cache_hit_rate_low.id
    memory_leak              = datadog_monitor.app_memory_leak.id
    api_rate_limit           = datadog_monitor.app_api_rate_limit.id
    queue_depth_high         = datadog_monitor.app_queue_depth_high.id
    dead_letter_queue        = datadog_monitor.app_dead_letter_queue.id
    health_check_failed      = datadog_monitor.app_health_check_failed.id
    business_metric_anomaly  = datadog_monitor.app_business_metric_anomaly.id
    log_errors_high          = datadog_monitor.app_log_errors_high.id
    security_alert           = datadog_monitor.app_security_alert.id
  }
}

output "monitor_names" {
  description = "Names of created application monitors"
  value = [
    datadog_monitor.app_response_time_high.name,
    datadog_monitor.app_error_rate_high.name,
    datadog_monitor.app_throughput_low.name,
    datadog_monitor.app_db_connection_pool_high.name,
    datadog_monitor.app_cache_hit_rate_low.name,
    datadog_monitor.app_memory_leak.name,
    datadog_monitor.app_api_rate_limit.name,
    datadog_monitor.app_queue_depth_high.name,
    datadog_monitor.app_dead_letter_queue.name,
    datadog_monitor.app_health_check_failed.name,
    datadog_monitor.app_business_metric_anomaly.name,
    datadog_monitor.app_log_errors_high.name,
    datadog_monitor.app_security_alert.name
  ]
}

# Outputs for On-Premises Alerts Module

output "monitor_count" {
  description = "Number of on-premises monitors created"
  value = {
    cpu_high                = datadog_monitor.onprem_cpu_high.id
    memory_high             = datadog_monitor.onprem_memory_high.id
    disk_high               = datadog_monitor.onprem_disk_high.id
    load_high               = datadog_monitor.onprem_load_high.id
    mysql_slow_queries      = datadog_monitor.onprem_mysql_slow_queries.id
    postgresql_connections  = datadog_monitor.onprem_postgresql_connections.id
    nginx_errors            = datadog_monitor.onprem_nginx_errors.id
    apache_errors           = datadog_monitor.onprem_apache_errors.id
    redis_memory            = datadog_monitor.onprem_redis_memory.id
    network_down            = datadog_monitor.onprem_network_down.id
    inodes_high             = datadog_monitor.onprem_inodes_high.id
    swap_high               = datadog_monitor.onprem_swap_high.id
    process_count_high      = datadog_monitor.onprem_process_count_high.id
    agent_down              = datadog_monitor.onprem_agent_down.id
  }
}

output "monitor_names" {
  description = "Names of created on-premises monitors"
  value = [
    datadog_monitor.onprem_cpu_high.name,
    datadog_monitor.onprem_memory_high.name,
    datadog_monitor.onprem_disk_high.name,
    datadog_monitor.onprem_load_high.name,
    datadog_monitor.onprem_mysql_slow_queries.name,
    datadog_monitor.onprem_postgresql_connections.name,
    datadog_monitor.onprem_nginx_errors.name,
    datadog_monitor.onprem_apache_errors.name,
    datadog_monitor.onprem_redis_memory.name,
    datadog_monitor.onprem_network_down.name,
    datadog_monitor.onprem_inodes_high.id,
    datadog_monitor.onprem_swap_high.name,
    datadog_monitor.onprem_process_count_high.name,
    datadog_monitor.onprem_agent_down.name
  ]
}

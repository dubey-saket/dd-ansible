# Unified Dashboard Module
# Creates a comprehensive dashboard combining AWS and On-Premises metrics

resource "datadog_dashboard" "unified_comprehensive" {
  title         = "Unified Infrastructure Monitoring - ${var.environment}"
  description   = "Unified monitoring dashboard for AWS and On-Premises infrastructure in ${var.environment} environment"
  layout_type   = "ordered"
  is_read_only  = false
  tags          = var.tags

  # Infrastructure Overview
  widget {
    widget_layout {
      x      = 0
      y      = 0
      width  = 24
      height = 4
    }
    
    timeseries_definition {
      title = "Infrastructure Overview - CPU Utilization"
      request {
        q = "avg:aws.ec2.cpuutilization{*} by {cloud-provider}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.cpu.user{*} by {cloud-provider}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "CPU %"
        scale = "linear"
        min = "0"
        max = "100"
      }
    }
  }

  # Memory Utilization Across Environments
  widget {
    widget_layout {
      x      = 0
      y      = 4
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Memory Utilization - AWS vs On-Prem"
      request {
        q = "avg:aws.ec2.memoryutilization{*} by {cloud-provider}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.mem.pct_usable{*} by {cloud-provider}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Memory %"
        scale = "linear"
        min = "0"
        max = "100"
      }
    }
  }

  # Network Performance Comparison
  widget {
    widget_layout {
      x      = 12
      y      = 4
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Network Performance Comparison"
      request {
        q = "avg:aws.ec2.network_in{*} by {cloud-provider}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.net.bytes_rcvd{*} by {cloud-provider}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Bytes/sec"
        scale = "linear"
      }
    }
  }

  # Application Performance
  widget {
    widget_layout {
      x      = 0
      y      = 8
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Application Response Times"
      request {
        q = "avg:trace.web.request.duration{*} by {service}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:trace.http.request.duration{*} by {service}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Duration (ms)"
        scale = "linear"
      }
    }
  }

  # Error Rates
  widget {
    widget_layout {
      x      = 12
      y      = 8
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Error Rates Across Services"
      request {
        q = "avg:trace.web.request.errors{*} by {service}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:aws.lambda.errors{*} by {functionname}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Error Rate"
        scale = "linear"
      }
    }
  }

  # Database Performance
  widget {
    widget_layout {
      x      = 0
      y      = 12
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Database Performance"
      request {
        q = "avg:aws.rds.cpuutilization{*} by {dbinstance-identifier}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:mysql.performance.queries{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:postgresql.queries{*} by {host}"
        display_type = "line"
        style {
          palette = "cool"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Utilization/Queries"
        scale = "linear"
      }
    }
  }

  # Storage Usage
  widget {
    widget_layout {
      x      = 12
      y      = 12
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Storage Usage"
      request {
        q = "avg:aws.s3.bucket_size_bytes{*} by {bucketname}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.disk.used{*} by {host,device}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Storage (bytes)"
        scale = "log"
      }
    }
  }

  # Service Health Status
  widget {
    widget_layout {
      x      = 0
      y      = 16
      width  = 12
      height = 4
    }
    
    check_status_definition {
      title = "AWS Service Health"
      check = "aws.ec2.status_check_failed"
      group_by = ["instance-id"]
      tags = ["*"]
      group = "*"
    }
  }

  widget {
    widget_layout {
      x      = 12
      y      = 16
      width  = 12
      height = 4
    }
    
    check_status_definition {
      title = "On-Premises Host Health"
      check = "datadog.agent.up"
      group_by = ["host"]
      tags = ["*"]
      group = "*"
    }
  }

  # Cost and Resource Utilization
  widget {
    widget_layout {
      x      = 0
      y      = 20
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Resource Utilization Trends"
      request {
        q = "avg:aws.ec2.cpuutilization{*} by {instance-type}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.cpu.user{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "CPU %"
        scale = "linear"
        min = "0"
        max = "100"
      }
    }
  }

  # Alert Summary
  widget {
    widget_layout {
      x      = 12
      y      = 20
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Alert Activity"
      request {
        q = "sum:datadog.alert.active{*} by {alert_name}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Active Alerts"
        scale = "linear"
      }
    }
  }

  # Top N Widgets
  widget {
    widget_layout {
      x      = 0
      y      = 24
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top Services by Response Time"
      request {
        q = "top(avg:trace.web.request.duration{*} by {service}, 10, 'mean', 'desc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  widget {
    widget_layout {
      x      = 8
      y      = 24
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top Hosts by CPU Usage"
      request {
        q = "top(avg:system.cpu.user{*} by {host}, 10, 'mean', 'desc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  widget {
    widget_layout {
      x      = 16
      y      = 24
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top EC2 Instances by CPU"
      request {
        q = "top(avg:aws.ec2.cpuutilization{*} by {instance-id}, 10, 'mean', 'desc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  # Log Analysis
  widget {
    widget_layout {
      x      = 0
      y      = 28
      width  = 24
      height = 4
    }
    
    log_stream_definition {
      title = "Recent Logs"
      query = "status:error OR status:warning"
      columns = ["timestamp", "host", "service", "status", "message"]
      show_date_column = true
      show_message_column = true
      message_display = "expanded-md"
    }
  }
}

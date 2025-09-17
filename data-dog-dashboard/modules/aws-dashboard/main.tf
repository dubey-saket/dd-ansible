# AWS Dashboard Module
# Creates comprehensive monitoring dashboard for AWS resources

resource "datadog_dashboard" "aws_comprehensive" {
  title         = "AWS Infrastructure - ${var.environment}"
  description   = "Comprehensive AWS monitoring dashboard for ${var.environment} environment"
  layout_type   = "ordered"
  is_read_only  = false
  tags          = var.tags

  # EC2 Instances Overview
  widget {
    widget_layout {
      x      = 0
      y      = 0
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "EC2 CPU Utilization"
      request {
        q = "avg:aws.ec2.cpuutilization{*} by {instance-type,availability-zone}"
        display_type = "line"
        style {
          palette = "dog_classic"
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
      legend {
        show_legend = true
        legend_size = "0"
      }
    }
  }

  # EC2 Memory Utilization
  widget {
    widget_layout {
      x      = 12
      y      = 0
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "EC2 Memory Utilization"
      request {
        q = "avg:aws.ec2.memoryutilization{*} by {instance-type,availability-zone}"
        display_type = "line"
        style {
          palette = "dog_classic"
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

  # RDS Performance
  widget {
    widget_layout {
      x      = 0
      y      = 4
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "RDS Database Performance"
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
        q = "avg:aws.rds.database_connections{*} by {dbinstance-identifier}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Utilization"
        scale = "linear"
      }
    }
  }

  # Load Balancer Metrics
  widget {
    widget_layout {
      x      = 12
      y      = 4
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Load Balancer Performance"
      request {
        q = "avg:aws.elb.request_count{*} by {loadbalancername}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:aws.elb.latency{*} by {loadbalancername}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Requests/Latency"
        scale = "linear"
      }
    }
  }

  # S3 Storage Metrics
  widget {
    widget_layout {
      x      = 0
      y      = 8
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "S3 Storage Usage"
      request {
        q = "avg:aws.s3.bucket_size_bytes{*} by {bucketname}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Bytes"
        scale = "log"
      }
    }
  }

  # Lambda Performance
  widget {
    widget_layout {
      x      = 12
      y      = 8
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Lambda Function Performance"
      request {
        q = "avg:aws.lambda.duration{*} by {functionname}"
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
        label = "Duration/Errors"
        scale = "linear"
      }
    }
  }

  # Network Performance
  widget {
    widget_layout {
      x      = 0
      y      = 12
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Network Performance"
      request {
        q = "avg:aws.ec2.network_in{*} by {instance-type,availability-zone}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:aws.ec2.network_out{*} by {instance-type,availability-zone}"
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

  # Cost Monitoring
  widget {
    widget_layout {
      x      = 12
      y      = 12
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "AWS Cost Trends"
      request {
        q = "sum:aws.billing.estimated_charges{*} by {service}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "USD"
        scale = "linear"
      }
    }
  }

  # Top N Widgets for Resource Utilization
  widget {
    widget_layout {
      x      = 0
      y      = 16
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

  widget {
    widget_layout {
      x      = 8
      y      = 16
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top RDS Instances by Connections"
      request {
        q = "top(avg:aws.rds.database_connections{*} by {dbinstance-identifier}, 10, 'mean', 'desc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  widget {
    widget_layout {
      x      = 16
      y      = 16
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top Lambda Functions by Duration"
      request {
        q = "top(avg:aws.lambda.duration{*} by {functionname}, 10, 'mean', 'desc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  # Service Health Status
  widget {
    widget_layout {
      x      = 0
      y      = 20
      width  = 24
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
}

# On-Premises Dashboard Module
# Creates comprehensive monitoring dashboard for on-premises infrastructure

resource "datadog_dashboard" "onprem_comprehensive" {
  title         = "On-Premises Infrastructure - ${var.environment}"
  description   = "Comprehensive on-premises monitoring dashboard for ${var.environment} environment"
  layout_type   = "ordered"
  is_read_only  = false
  tags          = var.tags

  # System Overview
  widget {
    widget_layout {
      x      = 0
      y      = 0
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "System CPU Utilization"
      request {
        q = "avg:system.cpu.user{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.cpu.system{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.cpu.iowait{*} by {host}"
        display_type = "line"
        style {
          palette = "cool"
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

  # Memory Utilization
  widget {
    widget_layout {
      x      = 12
      y      = 0
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Memory Utilization"
      request {
        q = "avg:system.mem.used{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.mem.free{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Memory (bytes)"
        scale = "linear"
      }
    }
  }

  # Disk Usage
  widget {
    widget_layout {
      x      = 0
      y      = 4
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Disk Usage"
      request {
        q = "avg:system.disk.used{*} by {host,device}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.disk.free{*} by {host,device}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Disk (bytes)"
        scale = "linear"
      }
    }
  }

  # Network Traffic
  widget {
    widget_layout {
      x      = 12
      y      = 4
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Network Traffic"
      request {
        q = "avg:system.net.bytes_sent{*} by {host,device}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.net.bytes_rcvd{*} by {host,device}"
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

  # Database Performance
  widget {
    widget_layout {
      x      = 0
      y      = 8
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Database Performance"
      request {
        q = "avg:mysql.performance.queries{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:postgresql.queries{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Queries/sec"
        scale = "linear"
      }
    }
  }

  # Web Server Performance
  widget {
    widget_layout {
      x      = 12
      y      = 8
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Web Server Performance"
      request {
        q = "avg:nginx.net.request_per_s{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:apache.performance.hits{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Requests/sec"
        scale = "linear"
      }
    }
  }

  # Load Average
  widget {
    widget_layout {
      x      = 0
      y      = 12
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "System Load Average"
      request {
        q = "avg:system.load.1{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.load.5{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.load.15{*} by {host}"
        display_type = "line"
        style {
          palette = "cool"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Load Average"
        scale = "linear"
      }
    }
  }

  # Process Count
  widget {
    widget_layout {
      x      = 12
      y      = 12
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Process Count"
      request {
        q = "avg:system.proc.running{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      request {
        q = "avg:system.proc.total{*} by {host}"
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Process Count"
        scale = "linear"
      }
    }
  }

  # File System Usage
  widget {
    widget_layout {
      x      = 0
      y      = 16
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "File System Usage"
      request {
        q = "avg:system.fs.inodes.used{*} by {host,mountpoint}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Inodes Used"
        scale = "linear"
      }
    }
  }

  # Swap Usage
  widget {
    widget_layout {
      x      = 12
      y      = 16
      width  = 12
      height = 4
    }
    
    timeseries_definition {
      title = "Swap Usage"
      request {
        q = "avg:system.swap.used{*} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
          line_type = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        label = "Swap (bytes)"
        scale = "linear"
      }
    }
  }

  # Top N Widgets
  widget {
    widget_layout {
      x      = 0
      y      = 20
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
      x      = 8
      y      = 20
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top Hosts by Memory Usage"
      request {
        q = "top(avg:system.mem.pct_usable{*} by {host}, 10, 'mean', 'asc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  widget {
    widget_layout {
      x      = 16
      y      = 20
      width  = 8
      height = 4
    }
    
    toplist_definition {
      title = "Top Hosts by Disk Usage"
      request {
        q = "top(avg:system.disk.in_use{*} by {host,device}, 10, 'mean', 'desc')"
        style {
          palette = "dog_classic"
        }
      }
    }
  }

  # Host Status
  widget {
    widget_layout {
      x      = 0
      y      = 24
      width  = 24
      height = 4
    }
    
    check_status_definition {
      title = "Host Status"
      check = "datadog.agent.up"
      group_by = ["host"]
      tags = ["*"]
      group = "*"
    }
  }
}

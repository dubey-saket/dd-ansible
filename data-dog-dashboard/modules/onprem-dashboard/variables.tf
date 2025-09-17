# Variables for On-Premises Dashboard Module

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "datacenter" {
  description = "Datacenter name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the dashboard"
  type        = list(string)
  default     = []
}

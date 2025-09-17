# Variables for AWS Dashboard Module

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the dashboard"
  type        = list(string)
  default     = []
}

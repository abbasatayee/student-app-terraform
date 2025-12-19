# variables.tf
# Input variables for the load-balancer module

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be created"
  type        = string
}


variable "ssm_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}


variable "aws_region" {
  description = "Security group ID for web servers"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}


variable "private_subnet_ids" {
  description = "Private subnet ids"
  type        = list(string)
}


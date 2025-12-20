# variables.tf
# Input variables for the compute module

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS EC2 Key Pair"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets (for bootstrap instance)"
  type = map(object({
    id = string
  }))
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ASG"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "asg_target_cpu_utilization" {
  description = "Target CPU utilization for auto scaling"
  type        = number
}

variable "target_group_arn" {
  description = "ARN of the target group for ASG"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint for user data script"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "nodeapp"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "student12"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "STUDENTS"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

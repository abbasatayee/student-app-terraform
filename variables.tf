# variables.tf
# Input variables for the Terraform configuration

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets (should be in different AZs)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets (should be in different AZs)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "db_username" {
  description = "Master username for RDS MySQL database"
  type        = string
  default     = "nodeapp"
  sensitive   = false
}

variable "db_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "STUDENTS"
}

variable "db_password" {
  description = "Master password for RDS MySQL database. ⚠️ Change this in production!"
  type        = string
  default     = "student12"
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS EC2 Key Pair for SSH access"
  type        = string
  default     = "webapp-key"
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_target_cpu_utilization" {
  description = "Target CPU utilization percentage for Auto Scaling"
  type        = number
  default     = 80.0
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS instance in GB"
  type        = number
  default     = 20
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS (increases cost but provides high availability)"
  type        = bool
  default     = true
}

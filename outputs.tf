# outputs.tf
# Root module outputs that reference module outputs

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

# Subnet Information
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

# Load Balancer Information
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.load_balancer.alb_arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.load_balancer.alb_zone_id
}

# Target Group Information
output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.load_balancer.target_group_arn
}

# RDS Information
output "rds_endpoint" {
  description = "RDS MySQL instance endpoint"
  value       = module.database.rds_endpoint
}

output "rds_port" {
  description = "RDS MySQL instance port"
  value       = module.database.rds_port
}

output "rds_database_name" {
  description = "Name of the RDS database"
  value       = module.database.rds_database_name
}

# EC2 Information
output "bootstrap_instance_id" {
  description = "ID of the bootstrap EC2 instance"
  value       = module.compute.bootstrap_instance_id
}

output "bootstrap_instance_public_ip" {
  description = "Public IP address of the bootstrap EC2 instance"
  value       = module.compute.bootstrap_instance_public_ip
}

# Auto Scaling Group Information
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.asg_arn
}

# Launch Template Information
output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.compute.launch_template_id
}

# AMI Information
output "web_ami_id" {
  description = "ID of the custom AMI created from bootstrap instance"
  value       = module.compute.web_ami_id
}

# Secrets Manager Information
output "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  value       = module.secrets.db_secret_arn
  sensitive   = false
}

# Key Pair Information
output "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  value       = module.compute.key_pair_name
}

# Application URL
output "application_url" {
  description = "URL to access the application (HTTP)"
  value       = "http://${module.load_balancer.alb_dns_name}"
}

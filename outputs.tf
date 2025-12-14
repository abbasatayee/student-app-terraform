# outputs.tf
# Output values for important resource information

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Information
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

# Load Balancer Information
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web_alb.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.web_alb.zone_id
}

# Target Group Information
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web_tg.arn
}

# RDS Information
output "rds_endpoint" {
  description = "RDS MySQL instance endpoint"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS MySQL instance port"
  value       = aws_db_instance.mysql.port
}

output "rds_database_name" {
  description = "Name of the RDS database"
  value       = aws_db_instance.mysql.db_name
}

# EC2 Information
output "bootstrap_instance_id" {
  description = "ID of the bootstrap EC2 instance"
  value       = aws_instance.web.id
}

output "bootstrap_instance_public_ip" {
  description = "Public IP address of the bootstrap EC2 instance"
  value       = aws_instance.web.public_ip
}

# Auto Scaling Group Information
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.arn
}

# Launch Template Information
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.web_lt.id
}

# AMI Information
output "web_ami_id" {
  description = "ID of the custom AMI created from bootstrap instance"
  value       = aws_ami_from_instance.web_ami.id
}

# Secrets Manager Information
output "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_secret.arn
  sensitive   = false
}

# Key Pair Information
output "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  value       = aws_key_pair.webapp_key.key_name
}

# Application URL
output "application_url" {
  description = "URL to access the application (HTTP)"
  value       = "http://${aws_lb.web_alb.dns_name}"
}

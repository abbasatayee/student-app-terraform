# outputs.tf
# Output values for the network module

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets" {
  description = "Map of public subnets (key: CIDR, value: subnet object)"
  value       = aws_subnet.public
}

output "private_subnets" {
  description = "Map of private subnets (key: CIDR, value: subnet object)"
  value       = aws_subnet.private
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

output "web_sg_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web_sg.id
}

output "db_sg_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db_sg.id
}

output "lb_sg_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb_sg.id
}

output "ssm_vpc_endpoint_sg_id" {
  value       = try(aws_security_group.ssm_vpc_endpoint_sg.id, null)
  description = "SSM VPC endpoint security group ID"
}
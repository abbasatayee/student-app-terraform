# outputs.tf
# Output values for the database module

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

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.mysql.id
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.mysql.arn
}

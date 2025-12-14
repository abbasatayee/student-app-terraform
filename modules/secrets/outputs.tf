# outputs.tf
# Output values for the secrets module

output "db_secret_arn" {
  description = "ARN of the database secret"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "db_secret_id" {
  description = "ID of the database secret"
  value       = aws_secretsmanager_secret.db_secret.id
}

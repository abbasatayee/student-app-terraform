# secrets.tf
# AWS Secrets Manager for storing database credentials securely

# Secret to store database credentials
# Note: Secret name is fixed as "Mydbsecret" as per project requirements
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "Mydbsecret"
  description = "Database credentials for student records application"

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    {
      Name = "Mydbsecret"
    },
    var.common_tags
  )
}

# Secret version containing the actual database credentials
# This allows EC2 instances to retrieve credentials programmatically via IAM role
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    user     = var.db_username
    password = var.db_password
    host     = var.rds_endpoint
    port     = 3306
    db       = var.db_name
  })
}

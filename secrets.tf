# secrets.tf
# AWS Secrets Manager for storing database credentials securely

# Secret to store database credentials
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${local.name_prefix}-db-secret"
  description = "Database credentials for student records application"

  tags = {
    Name = "${local.name_prefix}-db-secret"
  }
}

# Secret version containing the actual database credentials
# This allows EC2 instances to retrieve credentials programmatically via IAM role
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = var.db_name
  })
}

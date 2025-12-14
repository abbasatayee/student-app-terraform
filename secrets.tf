# secrets.tf
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "Mydbsecret"
  description = "Database credentials for student records app"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    user = var.db_username
    password = var.db_password,
    host = aws_db_instance.mysql.address,
    db = "STUDENTS"
  })
}

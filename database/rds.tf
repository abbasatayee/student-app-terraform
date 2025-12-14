# rds.tf
# RDS MySQL Database and Subnet Group

# DB Subnet Group
# Defines which subnets the RDS instance can be deployed in (private subnets only)
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.private : s.id]

  description = "Private subnets for RDS MySQL database"

  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

# RDS MySQL Database Instance
# Multi-AZ deployment for high availability and automatic failover
resource "aws_db_instance" "mysql" {
  identifier     = "${local.name_prefix}-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.rds_instance_class

  # Database configuration
  allocated_storage    = var.rds_allocated_storage
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false

  # High availability
  multi_az = var.rds_multi_az

  # Backup and maintenance
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Deletion protection (set to false for easier cleanup, enable in production)
  deletion_protection = false
  skip_final_snapshot = true

  # Storage encryption
  storage_encrypted = true

  tags = {
    Name = "${local.name_prefix}-database"
  }
}

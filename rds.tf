# rds.tf
resource "aws_db_instance" "mysql" {
  identifier           = "student-database"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  multi_az             = true
  publicly_accessible  = false
  deletion_protection  = false
  skip_final_snapshot  = true
  tags = {
    Name = "Student Database"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = [for s in aws_subnet.private : s.id]
  description = "Private subnets for RDS"
}

# security.tf
# Security Groups for network access control

# Security Group for Web Servers (EC2 instances)
# Allows HTTP traffic from the Load Balancer only
resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}-web-sg"
  description = "Security group for web servers - allows HTTP from Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from Load Balancer security group
  ingress {
    description     = "Allow HTTP traffic from Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  # Allow all outbound traffic (for package updates, API calls, etc.)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-web-sg"
    },
    var.common_tags
  )
}

# Security Group for Database (RDS)
# Only allows MySQL access from web servers
resource "aws_security_group" "db_sg" {
  name        = "${var.name_prefix}-db-sg"
  description = "Security group for RDS MySQL - allows access from web servers only"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL access from web security group only
  ingress {
    description     = "Allow MySQL access from web security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # Allow all outbound traffic (for database operations)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-db-sg"
    },
    var.common_tags
  )
}

# Security Group for Load Balancer
# Allows HTTP and HTTPS traffic from the internet
resource "aws_security_group" "lb_sg" {
  name        = "${var.name_prefix}-lb-sg"
  description = "Security group for Application Load Balancer - allows HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from anywhere
  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from anywhere (for future SSL/TLS support)
  ingress {
    description = "Allow HTTPS traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-lb-sg"
    },
    var.common_tags
  )
}


resource "aws_security_group" "ssm_vpc_endpoint_sg" {
  name        = "ssm-vpc-endpoint-sg"
  description = "Allow HTTPS from private EC2 instances to SSM VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "ssm-vpc-endpoint-sg"
    },
    var.common_tags
  )
}

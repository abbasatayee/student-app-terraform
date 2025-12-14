# ec2.tf
# EC2 Instance for initial setup and AMI creation

# Data source to fetch the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance (Bootstrap Instance)
# This instance is used to configure the application and create an AMI
# The AMI is then used by the Auto Scaling Group for production instances
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webapp_key.key_name

  # Deploy in first public subnet for initial setup
  subnet_id                   = values(var.public_subnets)[0].id
  associate_public_ip_address = true

  vpc_security_group_ids = [var.web_security_group_id]

  # IAM instance profile for accessing AWS services
  iam_instance_profile = var.iam_instance_profile_name

  # User data script to bootstrap the instance
  # This script installs dependencies, sets up the database, and configures the application
  user_data = <<-EOF
    #!/bin/bash -xe
    
    # Update system packages
    apt update -y
    apt install -y nodejs unzip wget npm mysql-client
    
    # Database connection variables
    DB_HOST="${var.rds_endpoint}"
    DB_USER="${var.db_username}"
    DB_PASS="${var.db_password}"
    DB_NAME="${var.db_name}"
    
    # Wait for RDS to be available
    echo "Waiting for RDS to be available..."
    until mysql -h $${DB_HOST} -u $${DB_USER} -p$${DB_PASS} -e "SELECT 1" &> /dev/null; do
      echo "RDS not ready yet, waiting 30 seconds..."
      sleep 30
    done
    
    # Create database table if it doesn't exist
    echo "RDS is available, checking if table exists..."
    TABLE_EXISTS=$(mysql -h $${DB_HOST} -u $${DB_USER} -p$${DB_PASS} $${DB_NAME} -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$${DB_NAME}' AND table_name='students';" 2>/dev/null || echo "0")
    
    if [ "$${TABLE_EXISTS}" -eq "0" ]; then
      echo "Table does not exist, creating students table..."
      mysql -h $${DB_HOST} -u $${DB_USER} -p$${DB_PASS} $${DB_NAME} -e "CREATE TABLE IF NOT EXISTS students(
        id INT NOT NULL AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        address VARCHAR(255) NOT NULL,
        city VARCHAR(255) NOT NULL,
        state VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        phone VARCHAR(100) NOT NULL,
        PRIMARY KEY (id)
      );"
      echo "Table created successfully!"
    else
      echo "Table 'students' already exists, skipping creation."
    fi
    
    # Download and setup application
    wget https://public-bucketabbas.s3.us-east-1.amazonaws.com/code.zip -P /home/ubuntu
    cd /home/ubuntu
    unzip -q code.zip -x "resources/codebase_partner/node_modules/*"
    cd resources/codebase_partner
    npm install aws aws-sdk
    
    # Start application
    export APP_PORT=80
    nohup npm start > /var/log/app.log 2>&1 &
    
    # Create startup script for automatic restart on boot
    cat > /etc/rc.local <<'SCRIPT'
    #!/bin/bash -xe
    cd /home/ubuntu/resources/codebase_partner
    export APP_PORT=80
    nohup npm start > /var/log/app.log 2>&1 &
    SCRIPT
    chmod +x /etc/rc.local
  EOF

  tags = merge(
    {
      Name = "${var.name_prefix}-bootstrap-instance"
    },
    var.common_tags
  )
}

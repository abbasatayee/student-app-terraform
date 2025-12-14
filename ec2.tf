# Fetch latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webapp_key.key_name
  subnet_id     = aws_subnet.public["10.0.1.0/24"].id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.web_sg.id]
 
  # IAM instance profile
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # User data script
  user_data = <<-EOF
    #!/bin/bash -xe
    apt update -y
    apt install nodejs unzip wget npm mysql-client -y
    
    # Wait for RDS to be available and create table
    DB_HOST="${aws_db_instance.mysql.address}"
    DB_USER="${var.db_username}"
    DB_PASS="${var.db_password}"
    DB_NAME="${var.db_name}"
    
    echo "Waiting for RDS to be available..."
    until mysql -h $${DB_HOST} -u $${DB_USER} -p$${DB_PASS} -e "SELECT 1" &> /dev/null; do
      echo "RDS not ready yet, waiting 30 seconds..."
      sleep 30
    done
    
    echo "RDS is available, checking if table exists..."
    TABLE_EXISTS=$(mysql -h $${DB_HOST} -u $${DB_USER} -p$${DB_PASS} $${DB_NAME} -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$${DB_NAME}' AND table_name='students';")
    
    if [ "$${TABLE_EXISTS}" -eq "0" ]; then
      echo "Table does not exist, creating students table..."
      mysql -h $${DB_HOST} -u $${DB_USER} -p$${DB_PASS} $${DB_NAME} -e "CREATE TABLE students(id INT NOT NULL AUTO_INCREMENT, name VARCHAR(255) NOT NULL, address VARCHAR(255) NOT NULL, city VARCHAR(255) NOT NULL, state VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL, phone VARCHAR(100) NOT NULL, PRIMARY KEY (id));"
      echo "Table created successfully!"
    else
      echo "Table 'students' already exists, skipping creation."
    fi
    
    # Download and setup application
    wget https://public-bucketabbas.s3.us-east-1.amazonaws.com/code.zip -P /home/ubuntu
    cd /home/ubuntu
    unzip code.zip -x "resources/codebase_partner/node_modules/*"
    cd resources/codebase_partner
    npm install aws aws-sdk
    export APP_PORT=80
    npm start &
    echo '#!/bin/bash -xe
    cd /home/ubuntu/resources/codebase_partner
    export APP_PORT=80
    npm start' > /etc/rc.local
    chmod +x /etc/rc.local
  EOF

  tags = {
    Name = "student-web-server"
  }
}

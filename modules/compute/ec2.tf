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
  user_data = <<EOF
#!/bin/bash -xe
apt update -y
apt install nodejs unzip wget npm mysql-client -y

#wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-DEV/code.zip -P /home/ubuntu
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-91571/1-lab-capstone-project-1/code.zip -P /home/ubuntu
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

  tags = merge(
    {
      Name = "${var.name_prefix}-bootstrap-instance"
    },
    var.common_tags
  )
}
# asg.tf
# Auto Scaling Group, Launch Template, and Scaling Policies

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


resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webapp_key.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_security_group_id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
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
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.name_prefix}-asg-instance"
      },
      var.common_tags
    )
  }
}


# Auto Scaling Group
# Automatically maintains the desired number of EC2 instances
# Instances are distributed across private subnets in different availability zones
resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.name_prefix}-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  # Launch template configuration
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  # Target group for load balancer health checks
  target_group_arns = [var.target_group_arn]

  # Health check configuration
  # Uses ELB health checks (more reliable than EC2 health checks)
  health_check_type         = "ELB"
  health_check_grace_period = 120

  # Wait for launch template to be ready
  depends_on = [aws_launch_template.web_lt]

  # Tags applied to instances launched by the ASG
  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg-instance"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - CPU-based Scaling
# Automatically scales the number of instances based on CPU utilization
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${var.name_prefix}-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.asg_target_cpu_utilization
  }
}


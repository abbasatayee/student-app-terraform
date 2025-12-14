# asg.tf
# Auto Scaling Group, Launch Template, and Scaling Policies

# AMI from Instance
# Creates a custom AMI from the bootstrap EC2 instance
# This AMI contains the configured application and is used by the Auto Scaling Group
resource "aws_ami_from_instance" "web_ami" {
  name               = "${local.name_prefix}-web-ami-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  source_instance_id = aws_instance.web.id

  tags = {
    Name = "${local.name_prefix}-web-ami"
  }

  # Ensure the bootstrap instance is fully configured before creating AMI
  depends_on = [aws_instance.web]
}

# Launch Template
# Defines the configuration for EC2 instances launched by the Auto Scaling Group
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webapp_key.key_name

  # IAM instance profile for accessing AWS services
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # Network configuration
  # Instances are launched in private subnets without public IPs
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  # Tag specifications for instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-asg-instance"
    }
  }

  # Ensure AMI is created before launch template
  depends_on = [aws_ami_from_instance.web_ami]
}

# Auto Scaling Group
# Automatically maintains the desired number of EC2 instances
# Instances are distributed across private subnets in different availability zones
resource "aws_autoscaling_group" "web_asg" {
  name                = "${local.name_prefix}-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]

  # Launch template configuration
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  # Target group for load balancer health checks
  target_group_arns = [aws_lb_target_group.web_tg.arn]

  # Health check configuration
  # Uses ELB health checks (more reliable than EC2 health checks)
  health_check_type         = "ELB"
  health_check_grace_period = 120

  # Wait for load balancer and target group to be ready
  depends_on = [aws_lb.web_alb, aws_lb_target_group.web_tg, aws_launch_template.web_lt]

  # Tags applied to instances launched by the ASG
  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg-instance"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - CPU-based Scaling
# Automatically scales the number of instances based on CPU utilization
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${local.name_prefix}-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.asg_target_cpu_utilization
  }
}


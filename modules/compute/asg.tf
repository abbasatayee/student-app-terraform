# asg.tf
# Auto Scaling Group, Launch Template, and Scaling Policies

# AMI from Instance
# Creates a custom AMI from the bootstrap EC2 instance
# This AMI contains the configured application and is used by the Auto Scaling Group
resource "aws_ami_from_instance" "web_ami" {
  name               = "${var.name_prefix}-web-ami-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  source_instance_id = aws_instance.web.id

  tags = merge(
    {
      Name = "${var.name_prefix}-web-ami"
    },
    var.common_tags
  )

  # Ensure the bootstrap instance is fully configured before creating AMI
  depends_on = [aws_instance.web]
}

# Launch Template
# Defines the configuration for EC2 instances launched by the Auto Scaling Group
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webapp_key.key_name

  # IAM instance profile for accessing AWS services
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # Network configuration
  # Instances are launched in private subnets without public IPs
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_security_group_id]
  }

  # Tag specifications for instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.name_prefix}-asg-instance"
      },
      var.common_tags
    )
  }

  # Ensure AMI is created before launch template
  depends_on = [aws_ami_from_instance.web_ami]
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


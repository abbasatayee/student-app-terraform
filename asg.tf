# Create an AMI from the configured EC2 instance
resource "aws_ami_from_instance" "web_ami" {
  name               = "student-web-ami"
  source_instance_id = aws_instance.web.id

  tags = {
    Name = "student-web-ami"
  }
}


# Create Launch template from web_ami 
resource "aws_launch_template" "web_lt" {
  name_prefix   = "student-web-lt-"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.webapp_key.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "student-web-asg"
    }
  }
}

# Create Auto Scanling Group
resource "aws_autoscaling_group" "web_asg" {
  name                = "student-web-asg"
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  depends_on = [aws_lb.web_alb, aws_lb_target_group.web_tg]

  tag {
    key                 = "Name"
    value               = "student-web-server"
    propagate_at_launch = true
  }
}



resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}


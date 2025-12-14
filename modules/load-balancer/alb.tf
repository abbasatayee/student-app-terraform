# alb.tf
# Application Load Balancer, Target Group, and Listener

# Target Group
# Defines which EC2 instances the load balancer will route traffic to
resource "aws_lb_target_group" "web_tg" {
  name        = "${var.name_prefix}-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Health check configuration
  # The load balancer will check the health of instances by making HTTP requests to the root path
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    protocol            = "HTTP"
  }

  # Connection draining - wait for in-flight requests to complete before deregistering unhealthy instances
  deregistration_delay = 30

  tags = merge(
    {
      Name = "${var.name_prefix}-web-tg"
    },
    var.common_tags
  )
}

# Application Load Balancer
# Distributes incoming HTTP/HTTPS traffic across multiple EC2 instances
resource "aws_lb" "web_alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets            = var.public_subnet_ids

  # Enable deletion protection in production
  enable_deletion_protection = false

  # Enable access logs for monitoring (optional)
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      Name = "${var.name_prefix}-alb"
    },
    var.common_tags
  )
}

# HTTP Listener
# Listens on port 80 and forwards traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

########################
# ALB + Target Group + Listener
########################

resource "aws_lb" "app_alb" {
  name               = "assignment-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = { Name = "assignment-alb" }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "assignment-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
  }

  tags = { Name = "assignment-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

########################
# Outputs (optional)
########################

output "alb_dns" {
  description = "ALB DNS name"
  value       = aws_lb.app_alb.dns_name
}

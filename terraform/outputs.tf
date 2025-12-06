########################
# Common Outputs
########################

# ALB DNS Name for testing
output "alb_dns" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

# VPC ID (good for debugging)
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Public Subnets
output "public_subnets" {
  description = "Public subnet IDs"
  value       = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

# Private Subnets
output "private_subnets" {
  description = "Private subnet IDs"
  value       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

# Target Group ARN (health checks)
output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.app_tg.arn
}

# Auto Scaling Group name (optional visibility)
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app_asg.name
}


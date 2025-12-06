########################
# IAM Role for EC2 (SSM + Logs)
########################

resource "aws_iam_role" "ec2_role" {
  name = "assignment-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# SSM access (so you don't need SSH)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Logs (optional)
resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "assignment-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

########################
# User Data for API
########################

locals {
  app_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3

    mkdir -p /opt/app
    cat > /opt/app/app.py << 'PYEOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from the DevOps assignment!"

@app.route("/health")
def health():
    return "ok"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PYEOF

    pip3 install flask
    nohup python3 /opt/app/app.py > /var/log/app.log 2>&1 &
  EOF
}

########################
# AMI (Amazon Linux)
########################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

########################
# Launch Template
########################

resource "aws_launch_template" "app_lt" {
  name_prefix   = "assignment-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(local.app_user_data)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "assignment-ec2"
    }
  }
}

########################
# Auto Scaling Group
########################

resource "aws_autoscaling_group" "app_asg" {
  name                      = "assignment-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "assignment-ec2"
    propagate_at_launch = true
  }
}

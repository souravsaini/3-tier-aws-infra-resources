provider "aws" {
  region = var.region
  profile = var.profile
}

# Fetch VPC CIDR block using data source
data "aws_vpc" "my_vpc" {
  id = var.vpc_id
}

# Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.my_vpc.cidr_block] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public_alb_sg.id]
  }
}

resource "aws_security_group" "public_alb_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = <<-EOT
#!/bin/bash
sudo apt-get -y update && sudo apt-get -y upgrade

sudo apt-get install -y nginx


multiline_content=$(cat << 'EOF'
  server {
    listen 80;
    server_name ${aws_lb.public_lb.dns_name} ;

    location / {
        proxy_pass http://${var.internal_alb_endpoint}:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
  }  
  server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;
        server_name _;
        location / {
                try_files $uri $uri/ =404;
        }
  }
EOF
)

echo "$multiline_content" > /etc/nginx/sites-available/default
cat /etc/nginx/sites-available/default

nginx_content=$(cat << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}

http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        server_names_hash_bucket_size 128;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
EOF
)

echo "$nginx_content" > /etc/nginx/nginx.conf

nginx -t

sudo service nginx restart
sudo service nginx status
EOT
}

# Launch Configuration
resource "aws_launch_configuration" "web_lc" {
  name = var.lc_name
  image_id = var.ami_id

  instance_type = var.instance_type

  security_groups = [aws_security_group.web_sg.id]

  key_name             = var.ssh_key_name
  
  root_block_device {
    volume_size = var.root_volume_size
  }

  user_data = data.template_file.user_data.rendered
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                 = var.asg_name
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.private_subnet_ids
  launch_configuration = aws_launch_configuration.web_lc.id

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }

  health_check_type          = "EC2"
  health_check_grace_period  = 300  # 5 minutes
  force_delete                = true
  wait_for_capacity_timeout  = "0"
}

# CloudWatch Alarms for Average CPU Usage
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name          = "web-cpu-alarm-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 80
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.web_scale_up_policy.arn]
}

resource "aws_autoscaling_policy" "web_scale_up_policy" {
  name                   = "web-scale-up-policy"
  scaling_adjustment     = 1
  cooldown               = 300  # 5 minutes
  adjustment_type        = "ChangeInCapacity"

  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_name          = "web-cpu-alarm-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 20  # Adjust as needed for the low threshold
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.web_scale_down_policy.arn]
}

resource "aws_autoscaling_policy" "web_scale_down_policy" {
  name                      = "web-scale-down-policy"
  scaling_adjustment        = -1
  cooldown                  = 300  # 5 minutes
  adjustment_type           = "ChangeInCapacity"

  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}


# Private Load Balancer
resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = var.public_subnet_ids
}

# Listener for Port 8000
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}


# Listener Rule for Target Group
resource "aws_lb_listener_rule" "web_lb_rule" {
  listener_arn = aws_lb_listener.web_lb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name        = "public-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = 80
  }
}

# Attach ASG to Target Group
resource "aws_autoscaling_attachment" "web_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lb_target_group_arn   = aws_lb_target_group.web_tg.arn
}
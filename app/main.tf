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
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.my_vpc.cidr_block] 
  }
}

# Key Pair
resource "aws_key_pair" "app_key_pair" {
  key_name   = "webapp-key-pair"
  public_key = var.ssh_public_key
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "secret_username" {
  arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.db_username}"
}


#Fetch DB Password from AWS Secret Manager
data "aws_secretsmanager_secret_version" "rds_username" {
  secret_id = data.aws_secretsmanager_secret.secret_username.id
}


data "aws_secretsmanager_secret" "secret_password" {
  arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.db_secret_name}"
}

#Fetch DB Password from AWS Secret Manager
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.secret_password.id
}

data "aws_db_instance" "db_instance" {
  db_instance_identifier = var.db_instance_identifier
}

data "template_file" "user_data" {
  template = <<-EOT
#!/bin/bash
sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get install curl

# Install Php
sudo apt update
sudo apt install php8.0-fpm
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository -y ppa:ondrej/php
sudo apt install php8.0 -y
php -v

# Install Composer
sudo apt install php8.0-cli php8.0-common php8.0-imap php8.0-redis php8.0-xml php8.0-zip php8.0-mbstring
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
composer --version


# Install Symfony 7 (Replace with your Symfony installation steps)
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo apt install symfony-cli

# Install php-mysql
sudo apt-get install php-mysql

# Clone Git Repo
git clone https://github.com/souravsaini/expense-calculator-app.git
cd expense-calculator-app

echo 'DATABASE_URL="mysql://${data.aws_secretsmanager_secret_version.rds_username.secret_string}:${data.aws_secretsmanager_secret_version.rds_password.secret_string}@${data.aws_db_instance.db_instance.endpoint}:3306/${data.aws_db_instance.db_instance.db_name}"' > .env

# Run the application in the background
nohup symfony serve --daemon --host=YOUR_PRIVATE_IP --port=8000 > /dev/null 2>&1 &
EOT
}

# Launch Configuration
resource "aws_launch_configuration" "app_lc" {
  name = var.lc_name
  image_id = var.ami_id

  instance_type = var.instance_type

  security_groups = [aws_security_group.web_sg.id]

  key_name             = aws_key_pair.app_key_pair.key_name
  
  root_block_device {
    volume_size = var.root_volume_size
  }

  user_data = data.template_file.user_data.rendered
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                 = var.asg_name
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.app_lc.id

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

  autoscaling_group_name = aws_autoscaling_group.app_asg.name
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

  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}


# Private Load Balancer
resource "aws_lb" "private_lb" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.subnet_ids
}

# Listener for Port 8000
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.private_lb.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "web-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

# Listener Rule for Target Group
resource "aws_lb_listener_rule" "web_lb_rule" {
  listener_arn = aws_lb_listener.web_lb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
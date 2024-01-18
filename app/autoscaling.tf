
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

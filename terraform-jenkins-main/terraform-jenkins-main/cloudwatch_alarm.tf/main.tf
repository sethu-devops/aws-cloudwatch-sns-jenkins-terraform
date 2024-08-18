 

variable "instance_id" {
  description = "The ID of the EC2 instance to monitor"
  type        = string
}

variable "log_stream_name" {
  description = "The name of the CloudWatch log stream"
  type        = string
  
}

variable "alarm_name" {
  description = "The alarm we deploy"
  type = string
  
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}


resource "aws_cloudwatch_log_group" "t2s_jenkins_server_log_group" {
  name = var.log_group_name
}





 resource "aws_cloudwatch_log_stream" "t2s_jenkins_server_log_stream" {
  name           = var.log_stream_name
  log_group_name = aws_cloudwatch_log_group.t2s_jenkins_server_log_group.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    InstanceId = var.instance_id
  }
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  alarm_name          = "HighMemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    InstanceId = var.instance_id
  }
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_disk_space" {
  alarm_name          = "LowDiskSpace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    InstanceId = var.instance_id
  }
  unit = "Percent"
}

resource "aws_sns_topic" "alarm_topic" {
  name = var.alarm_name
}



output "log_group_name" {
  value = aws_cloudwatch_log_group.t2s_jenkins_server_log_group.name
}

output "log_stream_name" {
  value = aws_cloudwatch_log_stream.t2s_jenkins_server_log_stream.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alarm_topic.arn
}
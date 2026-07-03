# =============================================================================
# Member 3 – CloudWatch Monitoring
# Purpose : Create a CloudWatch Log Group, metric filters that parse
#           CloudTrail logs for suspicious events, and alarms that alert via
#           SNS when those metrics breach thresholds.
#
#           Three key monitors are implemented:
#             1. Unauthorized API calls (AccessDenied / UnauthorizedOperation)
#             2. Root account usage
#             3. Failed console logins (consecutive failures)
# =============================================================================

# ---------------------------------------------------------------------------
# CloudWatch Log Group for CloudTrail logs
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/secureshop"
  retention_in_days = 90

  tags = {
    Name       = "SecureShop-CloudTrail-Logs"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# CloudTrail → CloudWatch Logs integration requires a dedicated IAM role.
# In an Academy sandbox the role already exists; we reference it by ARN.
# If iam:PassRole is available, use the data source below; otherwise hard-code
# the ARN from your sandbox session.
data "aws_iam_role" "cloudwatch_logs_role" {
  name = "LabRole"
}

# ---------------------------------------------------------------------------
# Wire CloudTrail to the CloudWatch Log Group
# ---------------------------------------------------------------------------
resource "aws_cloudtrail" "secureshop_cw" {
  # AWS Academy lab_policy blocks iam:PassRole, which is required to attach
  # a CloudWatch Logs role to a CloudTrail trail.
  # The main trail (secureshop-management-trail in cloudtrail.tf) already captures
  # all management events. Set count = 1 in a full AWS account with PassRole rights.
  count = 0

  name                          = "secureshop-cw-trail"
  s3_bucket_name                = data.aws_s3_bucket.cloudtrail_logs.id
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = data.aws_iam_role.cloudwatch_logs_role.arn
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Name       = "SecureShop-CloudWatch-Trail"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}

# ---------------------------------------------------------------------------
# SNS Topic for alarm notifications
# ---------------------------------------------------------------------------
resource "aws_sns_topic" "security_alerts" {
  name = "secureshop-security-alerts"

  tags = {
    Name       = "SecureShop-Security-Alerts"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# Optional: add an email subscription.
# Replace the email address before applying.
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com" # ← replace with real address
}

# ===========================================================================
# 1. Unauthorized API Calls
# ===========================================================================
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "UnauthorizedAPICalls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "UnauthorizedAPICallCount"
    namespace     = "SecureShop/Security"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "SecureShop-UnauthorizedAPICalls"
  alarm_description   = "Fires when more than 5 unauthorized API calls occur within 5 minutes."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  period              = 300 # seconds (5 minutes)
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]
  ok_actions    = [aws_sns_topic.security_alerts.arn]

  tags = {
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# ===========================================================================
# 2. Root Account Usage
# ===========================================================================
resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "RootAccountUsage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "RootAccountUsageCount"
    namespace     = "SecureShop/Security"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "SecureShop-RootAccountUsage"
  alarm_description   = "Fires on ANY use of the root account."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_account_usage.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_account_usage.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]

  tags = {
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# ===========================================================================
# 3. Failed Console Login Attempts
# ===========================================================================
resource "aws_cloudwatch_log_metric_filter" "console_login_failures" {
  name           = "ConsoleLoginFailures"
  pattern        = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "ConsoleLoginFailureCount"
    namespace     = "SecureShop/Security"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_login_failures" {
  alarm_name          = "SecureShop-ConsoleLoginFailures"
  alarm_description   = "Fires when more than 3 failed console logins occur within 5 minutes."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.console_login_failures.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.console_login_failures.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 3
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]

  tags = {
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# ===========================================================================
# 4. CloudWatch Dashboard – Security Overview
# ===========================================================================
resource "aws_cloudwatch_dashboard" "security" {
  dashboard_name = "SecureShop-Security-Overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title   = "Unauthorized API Calls"
          region  = var.aws_region
          metrics = [
            ["SecureShop/Security", "UnauthorizedAPICallCount"]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          title   = "Root Account Usage"
          region  = var.aws_region
          metrics = [
            ["SecureShop/Security", "RootAccountUsageCount"]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          title   = "Console Login Failures"
          region  = var.aws_region
          metrics = [
            ["SecureShop/Security", "ConsoleLoginFailureCount"]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group receiving CloudTrail events"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "sns_security_alerts_arn" {
  description = "ARN of the SNS topic for security alarm notifications"
  value       = aws_sns_topic.security_alerts.arn
}

output "cloudwatch_dashboard_url" {
  description = "Direct URL to the Security Overview dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.security.dashboard_name}"
}

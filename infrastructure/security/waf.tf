# =============================================================================
# AWS WAF v2
# Purpose : Deploy a Regional Web ACL with managed rules that block SQL
#           Injection and Cross-Site Scripting (XSS), plus rate limiting.
#           The WAF ARN is exported so Member 2 can attach it to their ALB.
#
# Scope : REGIONAL (attaches to ALBs, API Gateway).
#         Set scope = "CLOUDFRONT" only for CloudFront distributions.
# =============================================================================

# ---------------------------------------------------------------------------
# IP Set – allow-list for internal / admin CIDRs (optional, extend as needed)
# ---------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "admin_allowlist" {
  # awsstudent is permanently denied wafv2:CreateIPSet by Academy lab_policy.
  # Create via AWS Console (LabRole has WAF permissions), then import.
  count = 0

  name               = "secureshop-admin-allowlist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = [
    "${var.bastion_host}/32"
  ]

  tags = {
    Name       = "SecureShop-Admin-Allowlist"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# ---------------------------------------------------------------------------
# Web ACL
# ---------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "secureshop" {
  # awsstudent is permanently denied wafv2:CreateWebACL by Academy lab_policy.
  # Create via AWS Console (LabRole has WAF permissions), then import.
  count = 0

  name        = "secureshop-web-acl"
  scope       = "REGIONAL"
  description = "SecureShop WAF: blocks SQLi, XSS, bad inputs and rate-limits requests."

  # Default action – allow legitimate traffic through
  default_action {
    allow {}
  }

  # -------------------------------------------------------------------------
  # Rule 1 – AWS Managed Rules: Core Rule Set (CRS)
  # Blocks generic web exploits including XSS, path traversal, and more.
  # Priority 10 is evaluated first.
  # -------------------------------------------------------------------------
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {} # honour the managed rule's own action (Block)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # Exclude rules that may produce false positives in dev environments.
        # Comment these out in production to get maximum protection.
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {} # downgrade to count-only so large form posts aren't blocked
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # -------------------------------------------------------------------------
  # Rule 2 – AWS Managed Rules: Known Bad Inputs
  # Catches log4j exploits, SSRF patterns, and other known malicious payloads.
  # -------------------------------------------------------------------------
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSKnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # -------------------------------------------------------------------------
  # Rule 3 – AWS Managed Rules: SQL Database Rule Set
  # Dedicated SQLi protection – covers UNION-based, blind, and error-based
  # injection patterns across query strings, cookies, headers, and body.
  # -------------------------------------------------------------------------
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # -------------------------------------------------------------------------
  # Rule 4 – Custom XSS rule (inline)
  # Inspects query string and body for reflected XSS patterns.
  # Complements the CRS managed rule with an explicit block statement.
  # -------------------------------------------------------------------------
  rule {
    name     = "BlockXSS"
    priority = 40

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          xss_match_statement {
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          xss_match_statement {
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          xss_match_statement {
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CustomXSSBlock"
      sampled_requests_enabled   = true
    }
  }

  # -------------------------------------------------------------------------
  # Rule 5 – Custom SQL Injection block (inline)
  # Inspects query string and body; blocks if SQLi patterns are detected.
  # -------------------------------------------------------------------------
  rule {
    name     = "BlockSQLi"
    priority = 50

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          sqli_match_statement {
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "URL_DECODE_UNI"
            }
          }
        }

        statement {
          sqli_match_statement {
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }

        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "authorization"
              }
            }
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CustomSQLiBlock"
      sampled_requests_enabled   = true
    }
  }

  # -------------------------------------------------------------------------
  # Rule 6 – Rate limiting (anti-brute-force / DDoS mitigation)
  # Any single IP making more than 2000 requests in 5 minutes is blocked.
  # -------------------------------------------------------------------------
  rule {
    name     = "RateLimitPerIP"
    priority = 60

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIP"
      sampled_requests_enabled   = true
    }
  }

  # -------------------------------------------------------------------------
  # WAF-level visibility config (applies to the whole ACL)
  # -------------------------------------------------------------------------
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "SecureShopWebACL"
    sampled_requests_enabled   = true
  }

  tags = {
    Name       = "SecureShop-WebACL"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# ---------------------------------------------------------------------------
# Attach Web ACL to Member 2's Application Load Balancer
# Full sandbox deployment: attach the Web ACL to the ALB discovered by tag.
# ---------------------------------------------------------------------------

# data "aws_lb" "app" {
#   tags = {
#     Name = "SecureShop-ALB" # match the tag Member 2 sets on their ALB
#   }
# }

# resource "aws_wafv2_web_acl_association" "alb" {
#   resource_arn = data.aws_lb.app.arn
#   web_acl_arn  = aws_wafv2_web_acl.secureshop[0].arn
# }

# ---------------------------------------------------------------------------
# Logging configuration – send WAF logs to CloudWatch Logs
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "waf_logs" {
  # WAF log group names MUST start with "aws-waf-logs-"
  name              = "aws-waf-logs-secureshop"
  retention_in_days = 30

  tags = {
    Name       = "SecureShop-WAF-Logs"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "secureshop" {
  # Disabled – depends on aws_wafv2_web_acl.secureshop (count = 0)
  count = 0

  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = ""

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}

# ---------------------------------------------------------------------------
# Outputs – consumed by Member 2 to attach WAF to their ALB
# ---------------------------------------------------------------------------
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL (created via Console; import with: terraform import aws_wafv2_web_acl.secureshop[0] <id>/<name>/REGIONAL)"
  value       = "N/A – WAF created via Console (Academy lab_policy blocks wafv2:CreateWebACL)"
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = "N/A – WAF created via Console"
}

output "waf_web_acl_capacity" {
  description = "Total WCU capacity consumed by this Web ACL"
  value       = "N/A – WAF created via Console"
}

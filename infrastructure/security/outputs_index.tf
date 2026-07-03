# =============================================================================
# Security Module Outputs
# Purpose : Consolidate all cross-module outputs in one place so Member 1
#           (VPC) and Member 2 (Servers) can copy-paste the values they need.
# =============================================================================

# --- IAM -----------------------------------------------------------------
# lab_role_arn               → data.aws_iam_role.lab_role.arn         (iam.tf)
# lab_instance_profile_arn   → instance profile ARN                    (iam.tf)
# lab_instance_profile_name  → profile name for EC2 launch config      (iam.tf)

# --- CloudTrail ----------------------------------------------------------
# cloudtrail_trail_arn       → trail ARN                               (cloudtrail.tf)
# cloudtrail_s3_bucket_name  → log bucket name                         (cloudtrail.tf)

# --- CloudWatch ----------------------------------------------------------
# cloudwatch_log_group_name  → /aws/cloudtrail/secureshop              (cloudwatch.tf)
# sns_security_alerts_arn    → SNS topic ARN                           (cloudwatch.tf)
# cloudwatch_dashboard_url   → direct URL to Security Overview dash    (cloudwatch.tf)

# --- WAF -----------------------------------------------------------------
# waf_web_acl_id             → Web ACL ID  (for console attachment)    (waf.tf)
# waf_web_acl_arn            → Web ACL ARN (for Terraform attachment)  (waf.tf)

# --- ACM / Route 53 ------------------------------------------------------
# acm_certificate_arn        → cert ARN for HTTPS listener             (acm_route53.tf)
# acm_certificate_status     → ISSUED / PENDING_VALIDATION             (acm_route53.tf)
# route53_app_fqdn           → A-alias FQDN for the app               (acm_route53.tf)

# All outputs are already declared in their respective files.
# This file is a reference index only.

# =============================================================================
# Member 3 – ACM (AWS Certificate Manager) + Route 53 (optional)
# Purpose : Request an ACM public certificate for HTTPS on the ALB and,
#           optionally, configure Route 53 DNS validation records and an
#           alias record pointing to Member 2's ALB.
#
# NOTE: DNS validation requires a hosted zone in Route 53. If your domain
# is managed elsewhere, switch validation_method to "EMAIL" and remove the
# Route 53 blocks.
# =============================================================================

# ---------------------------------------------------------------------------
# Variable: your domain name
# ---------------------------------------------------------------------------
variable "domain_name" {
  description = "Primary domain for the ACM certificate (e.g. secureshop.example.com)"
  type        = string
  default     = "secureshop.example.com" # ← replace before applying
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for DNS validation (leave empty to skip DNS record creation)"
  type        = string
  default     = "" # ← replace with your Hosted Zone ID
}

# ---------------------------------------------------------------------------
# ACM Certificate
# ---------------------------------------------------------------------------
resource "aws_acm_certificate" "secureshop" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  # Enable certificate transparency logging
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  # Lifecycle rule: create a replacement cert before destroying the old one
  # to avoid ALB downtime during renewal.
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name       = "SecureShop-ACM-Cert"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# ---------------------------------------------------------------------------
# Route 53 – DNS Validation Records (optional)
# Only created when hosted_zone_id is set.
# ---------------------------------------------------------------------------
resource "aws_route53_record" "cert_validation" {
  # One record per domain_validation_option (covers main domain + SANs)
  for_each = var.hosted_zone_id != "" ? {
    for dvo in aws_acm_certificate.secureshop.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
  allow_overwrite = true
}

# Wait for validation to complete (used as a dependency by the ALB listener)
resource "aws_acm_certificate_validation" "secureshop" {
  count = var.hosted_zone_id != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.secureshop.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ---------------------------------------------------------------------------
# Route 53 – Alias record to Member 2's ALB (optional)
# ISOLATED DEMO: these records reference data.aws_lb.app which does not exist
# in a standalone sandbox. They are commented out here.
# Un-comment for the integrated (full-team) deployment.
# ---------------------------------------------------------------------------

# resource "aws_route53_record" "app_alias" {
#   count = var.hosted_zone_id != "" ? 1 : 0
#
#   zone_id = var.hosted_zone_id
#   name    = var.domain_name
#   type    = "A"
#
#   alias {
#     name                   = data.aws_lb.app.dns_name
#     zone_id                = data.aws_lb.app.zone_id
#     evaluate_target_health = true
#   }
# }

# # www → apex alias
# resource "aws_route53_record" "app_www_alias" {
#   count = var.hosted_zone_id != "" ? 1 : 0
#
#   zone_id = var.hosted_zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"
#
#   alias {
#     name                   = data.aws_lb.app.dns_name
#     zone_id                = data.aws_lb.app.zone_id
#     evaluate_target_health = true
#   }
# }

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate – attach this to Member 2's HTTPS listener"
  value       = aws_acm_certificate.secureshop.arn
}

output "acm_certificate_status" {
  description = "Current validation status of the certificate"
  value       = aws_acm_certificate.secureshop.status
}

output "acm_domain_validation_options" {
  description = "DNS records required for domain validation (if not using Route 53)"
  value       = aws_acm_certificate.secureshop.domain_validation_options
  sensitive   = false
}

output "route53_app_fqdn" {
  description = "FQDN of the A-alias record pointing to the ALB (disabled in isolated demo; re-enable Route 53 alias blocks for integrated deployment)"
  value       = "N/A – Route 53 alias records disabled for isolated demo deployment"
}

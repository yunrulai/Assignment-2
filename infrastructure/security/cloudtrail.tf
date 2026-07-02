# =============================================================================
# Member 3 – CloudTrail Logging
# Purpose : Enable AWS CloudTrail to record all management (control-plane)
#           events and persist them to a dedicated S3 bucket with server-side
#           encryption and a bucket policy that permits CloudTrail writes.
# =============================================================================

# ---------------------------------------------------------------------------
# S3 bucket for CloudTrail logs
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "secureshop-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # safe for labs – allows terraform destroy to clean up

  tags = {
    Name       = "SecureShop-CloudTrail-Logs"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning so log files are protected from accidental deletion
resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule – expire logs after 90 days to control storage costs
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# ---------------------------------------------------------------------------
# Bucket policy – grants CloudTrail service permission to write logs
# (aws_caller_identity.current is declared once in providers.tf)
# ---------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudTrail must be able to check the bucket ACL before writing
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        # CloudTrail writes log files under /AWSLogs/<account-id>/CloudTrail/
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# CloudTrail trail – log all management events, multi-region
# ---------------------------------------------------------------------------
resource "aws_cloudtrail" "secureshop" {
  name                          = "secureshop-management-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true  # capture IAM, STS, etc.
  is_multi_region_trail         = true  # catch activity in every region
  enable_log_file_validation    = true  # SHA-256 digest for tamper detection

  # Log all management events (Read + Write)
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Name       = "SecureShop-Management-Trail"
    ManagedBy  = "Terraform"
    Owner      = "Member3"
    Assignment = "Assignment2"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "cloudtrail_trail_arn" {
  description = "ARN of the CloudTrail management trail"
  value       = aws_cloudtrail.secureshop.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

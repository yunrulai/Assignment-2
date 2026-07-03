# =============================================================================
# Member 3 – Terraform Provider & Backend Configuration
# Purpose : Pin provider versions and configure the AWS provider for the
#           us-east-1 region (AWS Academy default).
#           A local state backend is used; switch to S3 backend in production.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # -----------------------------------------------------------------
  # Optional: remote state backend (uncomment and fill in after
  # Member 1 has created the state S3 bucket and DynamoDB table).
  # -----------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "secureshop-tfstate-<account-id>"
  #   key            = "security/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "secureshop-tflock"
  #   encrypt        = true
  # }
}

# ---------------------------------------------------------------------------
# AWS Provider – credentials are sourced from environment variables or the
# AWS CLI profile set up in the Academy lab session.
# ---------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = "SecureShop"
      Assignment = "Assignment2"
      ManagedBy  = "Terraform"
      Team       = "Member3"
    }
  }
}

# ---------------------------------------------------------------------------
# Variables shared across all security modules
# ---------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

# ---------------------------------------------------------------------------
# Shared data sources – used by multiple files in this module.
# Declared here (once) to avoid duplicate-resource errors.
# ---------------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

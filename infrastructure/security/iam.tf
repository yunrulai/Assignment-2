# =============================================================================
# Member 3 – IAM Role Attachment
# Purpose : Import the pre-existing "LabRole" (AWS Academy sandbox) and
#           attach it to Member 2's EC2 instances via an instance profile.
#           Role CREATION is intentionally omitted – sandbox policies forbid
#           iam:CreateRole.
# =============================================================================

# ---------------------------------------------------------------------------
# Data source – look up the existing LabRole by name
# ---------------------------------------------------------------------------
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# ---------------------------------------------------------------------------
# Instance Profile wrapping LabRole
# The profile is what EC2 actually uses; the raw role cannot be attached
# directly to an instance.
# ---------------------------------------------------------------------------
resource "aws_iam_instance_profile" "lab_instance_profile" {
  name = "LabInstanceProfile"
  role = data.aws_iam_role.lab_role.name

  tags = {
    Name        = "LabInstanceProfile"
    ManagedBy   = "Terraform"
    Owner       = "Member3"
    Assignment  = "Assignment2"
  }
}

# ---------------------------------------------------------------------------
# Associate profile with Member 2's EC2 instances
# Member 2 exposes instance IDs via outputs; we reference them with
# data sources so this file stays independent of their Terraform state.
#
# Replace the "id" filter values with the actual instance IDs once
# Member 2 has applied their configuration.
# ---------------------------------------------------------------------------
data "aws_instance" "app_server" {
  filter {
    name   = "tag:Name"
    values = ["AppServer"] # Member 2's EC2 instance tag
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "stopped"]
  }
}

# Attach the profile to the running EC2 instance
# NOTE: aws_iam_instance_profile_association requires the instance to exist
#       and the profile to be created first.  Run `terraform apply` after
#       Member 2 has deployed their instances.
resource "aws_iam_instance_profile_association" "app_server_profile" {
  instance_id  = data.aws_instance.app_server.id
  iam_arn      = aws_iam_instance_profile.lab_instance_profile.arn
}

# ---------------------------------------------------------------------------
# Outputs – consumed by other members and the CI pipeline
# ---------------------------------------------------------------------------
output "lab_role_arn" {
  description = "ARN of the imported LabRole"
  value       = data.aws_iam_role.lab_role.arn
}

output "lab_instance_profile_arn" {
  description = "ARN of the instance profile wrapping LabRole"
  value       = aws_iam_instance_profile.lab_instance_profile.arn
}

output "lab_instance_profile_name" {
  description = "Name of the instance profile (used by Member 2 when launching EC2)"
  value       = aws_iam_instance_profile.lab_instance_profile.name
}

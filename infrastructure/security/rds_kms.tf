# =============================================================================
# RDS & KMS Encryption
# Purpose : Provision an encrypted SQL Server RDS instance backed by a KMS key
#           so the SecureShop database can run with managed encryption at rest.
#
# Notes:
# - This module is written to be standalone-friendly for the assignment.
# - Provide subnet IDs, a VPC ID, and a source CIDR via tfvars when deploying.
# - If you are using a different network layout, wire the security group to the
#   application server's security group instead of a broad CIDR block.
# =============================================================================

variable "rds_database_name" {
  description = "Initial database name for the SecureShop RDS instance"
  type        = string
  default     = "SecureShopDB"
}

variable "rds_master_username" {
  description = "Master username for the RDS SQL Server instance"
  type        = string
  default     = "adminuser"
  sensitive   = true
}

variable "rds_master_password" {
  description = "Master password for the RDS SQL Server instance"
  type        = string
  sensitive   = true
}

variable "rds_instance_class" {
  description = "RDS instance class for the SQL Server database"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GiB for the RDS instance"
  type        = number
  default     = 20
}

variable "rds_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
  default     = []
}

variable "rds_vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
  default     = ""
}

variable "rds_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to SQL Server on 1433"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# KMS key used to encrypt the RDS storage volume.
# ---------------------------------------------------------------------------
resource "aws_kms_key" "rds" {
  description             = "SecureShop KMS key for RDS SQL Server encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = false

  tags = {
    Name       = "SecureShop-RDS-KMS-Key"
    ManagedBy  = "Terraform"
    Owner      = "Security"
    Assignment = "Assignment2"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/secureshop-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# ---------------------------------------------------------------------------
# RDS networking.
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "secure_shop" {
  count = length(var.rds_subnet_ids) > 0 ? 1 : 0

  name        = "secureshop-rds-subnet-group"
  description = "Private subnets for SecureShop RDS"
  subnet_ids  = var.rds_subnet_ids

  tags = {
    Name       = "SecureShop-RDS-Subnet-Group"
    ManagedBy  = "Terraform"
    Owner      = "Security"
    Assignment = "Assignment2"
  }
}

resource "aws_security_group" "rds" {
  count = var.rds_vpc_id != "" ? 1 : 0

  name        = "secureshop-rds-sg"
  description = "Allow SQL Server access to SecureShop RDS"
  vpc_id      = var.rds_vpc_id

  ingress {
    description = "SQL Server"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = var.rds_allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "SecureShop-RDS-Security-Group"
    ManagedBy  = "Terraform"
    Owner      = "Security"
    Assignment = "Assignment2"
  }
}

# ---------------------------------------------------------------------------
# Encrypted RDS instance.
# ---------------------------------------------------------------------------
resource "aws_db_instance" "secure_shop" {
  identifier = "secureshop-sqlserver"

  engine         = "sqlserver-se"
  engine_version = "15.00"
  instance_class = var.rds_instance_class

  allocated_storage          = var.rds_allocated_storage
  storage_type               = "gp3"
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.rds.arn
  db_name                    = var.rds_database_name
  username                   = var.rds_master_username
  password                   = var.rds_master_password
  port                       = 1433
  publicly_accessible        = false
  multi_az                   = false
  skip_final_snapshot        = true
  deletion_protection        = false
  auto_minor_version_upgrade = true
  backup_retention_period    = 7

  db_subnet_group_name   = length(aws_db_subnet_group.secure_shop) > 0 ? aws_db_subnet_group.secure_shop[0].name : null
  vpc_security_group_ids = var.rds_vpc_id != "" ? [aws_security_group.rds[0].id] : []

  performance_insights_enabled = false
  monitoring_interval          = 0
  apply_immediately            = true
  copy_tags_to_snapshot        = true

  tags = {
    Name       = "SecureShop-RDS-SQLServer"
    ManagedBy  = "Terraform"
    Owner      = "Security"
    Assignment = "Assignment2"
  }

  depends_on = [aws_kms_alias.rds]
}

# ---------------------------------------------------------------------------
# Helpful outputs for wiring the application layer.
# ---------------------------------------------------------------------------
output "rds_kms_key_arn" {
  description = "KMS key ARN used by the RDS instance"
  value       = aws_kms_key.rds.arn
}

output "rds_kms_alias_name" {
  description = "Friendly alias for the RDS KMS key"
  value       = aws_kms_alias.rds.name
}

output "rds_instance_endpoint" {
  description = "RDS endpoint host name"
  value       = aws_db_instance.secure_shop.address
}

output "rds_instance_port" {
  description = "RDS endpoint port"
  value       = aws_db_instance.secure_shop.port
}

output "rds_instance_identifier" {
  description = "RDS DB instance identifier"
  value       = aws_db_instance.secure_shop.identifier
}
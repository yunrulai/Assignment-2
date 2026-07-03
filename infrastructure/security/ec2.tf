# =============================================================================
# EC2 Instance
# Purpose : Provision a demo EC2 instance inside the consolidated VPC so the
#           security module can show a complete compute target in the sandbox.
# =============================================================================

variable "ec2_instance_name" {
  description = "Name tag for the demo EC2 instance"
  type        = string
  default     = "SecureShop-EC2"
}

variable "ec2_instance_type" {
  description = "Instance type for the demo EC2 instance"
  type        = string
  default     = "t3.small"
}

variable "ec2_key_name" {
  description = "Optional EC2 key pair name for SSH access"
  type        = string
  default     = ""
}

variable "ec2_ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into the EC2 instance"
  type        = list(string)
  default     = []
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_security_group" "ec2" {
  name        = "secureshop-ec2-sg"
  description = "Security group for the SecureShop demo EC2 instance"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = length(var.ec2_ssh_allowed_cidrs) > 0 ? [1] : []

    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ec2_ssh_allowed_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "SecureShop-EC2-Security-Group"
    ManagedBy  = "Terraform"
    Owner      = "Security"
    Assignment = "Assignment2"
  }
}

resource "aws_instance" "demo" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = data.aws_iam_instance_profile.lab_instance_profile.name
  key_name                    = var.ec2_key_name != "" ? var.ec2_key_name : null

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name       = var.ec2_instance_name
    ManagedBy  = "Terraform"
    Owner      = "Security"
    Assignment = "Assignment2"
  }
}

output "ec2_instance_id" {
  description = "ID of the demo EC2 instance"
  value       = aws_instance.demo.id
}

output "ec2_public_ip" {
  description = "Public IP address of the demo EC2 instance"
  value       = aws_instance.demo.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the demo EC2 instance"
  value       = aws_instance.demo.public_dns
}

output "ec2_security_group_id" {
  description = "Security group ID attached to the demo EC2 instance"
  value       = aws_security_group.ec2.id
}

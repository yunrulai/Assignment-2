# =========================
# PUBLIC NACL
# =========================

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-nacl"
  }
}

# =========================
# INBOUND RULES
# =========================

resource "aws_network_acl_rule" "public_in_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 80
  to_port    = 80
}

resource "aws_network_acl_rule" "public_in_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 443
  to_port    = 443
}

# Ephemeral ports (ONLY for return traffic)
resource "aws_network_acl_rule" "public_in_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 1024
  to_port    = 65535
}

# Explicit deny (optional for assignment clarity)
resource "aws_network_acl_rule" "public_in_deny" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 140
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"

  cidr_block = "0.0.0.0/0"
}

# =========================
# OUTBOUND RULES
# =========================

resource "aws_network_acl_rule" "public_out_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 80
  to_port    = 80
}

resource "aws_network_acl_rule" "public_out_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 443
  to_port    = 443
}

resource "aws_network_acl_rule" "public_out_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 1024
  to_port    = 65535
}

resource "aws_network_acl_rule" "public_out_deny" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 140
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"

  cidr_block = "0.0.0.0/0"
}
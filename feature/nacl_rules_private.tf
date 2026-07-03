# =========================
# PRIVATE NACL RULES
# =========================

# HTTP from private subnet 1
resource "aws_network_acl_rule" "in_http_1" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "10.0.0.0/20"
  from_port  = 80
  to_port    = 80
}

# Ephemeral ports from subnet 1
resource "aws_network_acl_rule" "in_ephemeral_1" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "10.0.0.0/20"
  from_port  = 1024
  to_port    = 65535
}

# HTTP from subnet 2
resource "aws_network_acl_rule" "in_http_2" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "10.0.16.0/20"
  from_port  = 80
  to_port    = 80
}

# Ephemeral ports from subnet 2
resource "aws_network_acl_rule" "in_ephemeral_2" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "10.0.16.0/20"
  from_port  = 1024
  to_port    = 65535
}

# Deny all inbound (implicit but added for clarity)
resource "aws_network_acl_rule" "in_deny_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 140
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"

  cidr_block = "0.0.0.0/0"
}

# =========================
# OUTBOUND RULES
# =========================

resource "aws_network_acl_rule" "out_http" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 80
  to_port    = 80
}

resource "aws_network_acl_rule" "out_https" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 443
  to_port    = 443
}

resource "aws_network_acl_rule" "out_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  cidr_block = "0.0.0.0/0"
  from_port  = 1024
  to_port    = 65535
}

resource "aws_network_acl_rule" "out_deny_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 140
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"

  cidr_block = "0.0.0.0/0"
}
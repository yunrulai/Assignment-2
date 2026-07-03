# =============================================================================
# Network Layer
# Purpose : Consolidate the VPC, subnets, routing, NAT, and NACL resources
#           into the security infrastructure module.
# =============================================================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "assignment-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "assignment-igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt-1"
  }
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt-2"
  }
}

resource "aws_eip" "nat_1" {
  domain = "vpc"
}

resource "aws_eip" "nat_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_1" {
  subnet_id     = aws_subnet.public_1.id
  allocation_id = aws_eip.nat_1.id

  tags = {
    Name = "nat-1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  subnet_id     = aws_subnet.public_2.id
  allocation_id = aws_eip.nat_2.id

  tags = {
    Name = "nat-2"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_1_nat" {
  route_table_id         = aws_route_table.private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route" "private_2_nat" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

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
# PRIVATE NACL
# =========================

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-nacl"
  }
}

# =========================
# PUBLIC NACL RULES
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

resource "aws_network_acl_rule" "public_in_deny" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 140
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"

  cidr_block = "0.0.0.0/0"
}

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

# =========================
# PRIVATE NACL RULES
# =========================

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

resource "aws_network_acl_rule" "in_deny_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 140
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"

  cidr_block = "0.0.0.0/0"
}

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

# =========================
# NACL ASSOCIATIONS
# =========================

resource "aws_network_acl_association" "public_1" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_network_acl_association" "public_2" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public_2.id
}

resource "aws_network_acl_association" "private_1" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_network_acl_association" "private_2" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private_2.id
}
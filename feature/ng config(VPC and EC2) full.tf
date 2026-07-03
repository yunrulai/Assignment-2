terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_subnet" "EC2Subnet" {
    availability_zone = "us-east-1b"
    cidr_block = "10.0.16.0/20"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet2" {
    availability_zone = "us-east-1a"
    cidr_block = "10.0.128.0/20"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet3" {
    availability_zone = "us-east-1a"
    cidr_block = "10.0.0.0/20"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet4" {
    availability_zone = "us-east-1b"
    cidr_block = "10.0.144.0/20"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_vpc" "EC2VPC" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = {
        Name = "assignment-vpc"
    }
}

resource "aws_internet_gateway" "EC2InternetGateway" {
    tags = {
        Name = "assignment-igw"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
}

resource "aws_network_acl" "EC2NetworkAcl" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        Name = "Private_subnet"
    }
}

resource "aws_network_acl" "EC2NetworkAcl2" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        Name = "Public_subnet"
    }
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry" {
    cidr_block = "0.0.0.0/0"
    egress = true
    network_acl_id = "acl-07c3ee1b165e0cab9"
    protocol = 6
    rule_action = "allow"
    rule_number = 1
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry2" {
    cidr_block = "0.0.0.0/0"
    egress = true
    network_acl_id = "acl-07c3ee1b165e0cab9"
    protocol = 6
    rule_action = "allow"
    rule_number = 2
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry3" {
    cidr_block = "0.0.0.0/0"
    egress = true
    network_acl_id = "acl-07c3ee1b165e0cab9"
    protocol = 6
    rule_action = "allow"
    rule_number = 3
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry4" {
    cidr_block = "0.0.0.0/0"
    egress = false
    network_acl_id = "acl-07c3ee1b165e0cab9"
    protocol = 6
    rule_action = "allow"
    rule_number = 1
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry5" {
    cidr_block = "0.0.0.0/0"
    egress = false
    network_acl_id = "acl-07c3ee1b165e0cab9"
    protocol = 6
    rule_action = "allow"
    rule_number = 2
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry6" {
    cidr_block = "0.0.0.0/0"
    egress = false
    network_acl_id = "acl-07c3ee1b165e0cab9"
    protocol = 6
    rule_action = "allow"
    rule_number = 3
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry7" {
    cidr_block = "0.0.0.0/0"
    egress = true
    network_acl_id = "acl-002336bf20b3a943a"
    protocol = 6
    rule_action = "allow"
    rule_number = 1
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry8" {
    cidr_block = "0.0.0.0/0"
    egress = true
    network_acl_id = "acl-002336bf20b3a943a"
    protocol = 6
    rule_action = "allow"
    rule_number = 2
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry9" {
    cidr_block = "0.0.0.0/0"
    egress = true
    network_acl_id = "acl-002336bf20b3a943a"
    protocol = 6
    rule_action = "allow"
    rule_number = 3
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry10" {
    cidr_block = "0.0.0.0/0"
    egress = false
    network_acl_id = "acl-002336bf20b3a943a"
    protocol = 6
    rule_action = "allow"
    rule_number = 1
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry11" {
    cidr_block = "0.0.0.0/0"
    egress = false
    network_acl_id = "acl-002336bf20b3a943a"
    protocol = 6
    rule_action = "allow"
    rule_number = 2
}

resource "aws_network_acl_rule" "EC2NetworkAclEntry12" {
    cidr_block = "0.0.0.0/0"
    egress = false
    network_acl_id = "acl-002336bf20b3a943a"
    protocol = 6
    rule_action = "allow"
    rule_number = 3
}

resource "aws_route_table" "EC2RouteTable" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        Name = "assignment-rtb-public"
    }
}

resource "aws_route_table" "EC2RouteTable2" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        Name = "assignment-rtb-private2-us-east-1b"
    }
}

resource "aws_route_table" "EC2RouteTable3" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        Name = "assignment-rtb-private1-us-east-1a"
    }
}

resource "aws_route_table" "EC2RouteTable4" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {}
}

resource "aws_route" "EC2Route" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "igw-05925649f9617a4cb"
    route_table_id = "rtb-0e4e81e9fbbdd9c11"
}

resource "aws_route" "EC2Route2" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "nat-06cb61dda8f4ff938"
    route_table_id = "rtb-0dc7b2cf9700745c1"
}

resource "aws_route" "EC2Route3" {
    gateway_id = "vpce-0c716536791b6fcbf"
    route_table_id = "rtb-0dc7b2cf9700745c1"
}

resource "aws_route" "EC2Route4" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "nat-0ac66a3f6d4dff0d6"
    route_table_id = "rtb-065f4276cd0aa3620"
}

resource "aws_route" "EC2Route5" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "igw-00ef2ea54ae4020f1"
    route_table_id = "rtb-0735f8e7846d877df"
}

resource "aws_nat_gateway" "EC2NatGateway" {
    subnet_id = "subnet-08b4b2543b7a6d22d"
    tags = {
        Name = "assignment-nat-public1-us-east-1a"
    }
    allocation_id = "eipalloc-0dc6ac43f1359898c"
}

resource "aws_nat_gateway" "EC2NatGateway2" {
    subnet_id = "subnet-099e741a35aae91c7"
    tags = {
        Name = "assignment-nat-public2-us-east-1b"
    }
    allocation_id = "eipalloc-0d0bce73c2f2ad6a1"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation" {
    route_table_id = "rtb-0e4e81e9fbbdd9c11"
    subnet_id = "subnet-08b4b2543b7a6d22d"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation2" {
    route_table_id = "rtb-0e4e81e9fbbdd9c11"
    subnet_id = "subnet-099e741a35aae91c7"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation3" {
    route_table_id = "rtb-0dc7b2cf9700745c1"
    subnet_id = "subnet-0cf8a4e44aae378e9"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation4" {
    route_table_id = "rtb-065f4276cd0aa3620"
    subnet_id = "subnet-0394bca7e32938981"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation5" {
    route_table_id = "rtb-0735f8e7846d877df"
    subnet_id = "subnet-0aa4e4eede6438fcf"
}

resource "aws_instance" "EC2Instance" {
    ami = "ami-06067086cf86c58e6"
    instance_type = "t3.small"
    key_name = "assignment"
    availability_zone = "us-east-1a"
    tenancy = "default"
    subnet_id = "subnet-0394bca7e32938981"
    ebs_optimized = true
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup2.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 8
        volume_type = "gp3"
        delete_on_termination = true
    }
    iam_instance_profile = "LabInstanceProfile"
    tags = {
        Name = "SecureShop1"
    }
}

resource "aws_instance" "EC2Instance2" {
    ami = "ami-06067086cf86c58e6"
    instance_type = "t3.small"
    key_name = "assignment"
    availability_zone = "us-east-1b"
    tenancy = "default"
    subnet_id = "subnet-0cf8a4e44aae378e9"
    ebs_optimized = true
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup2.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 8
        volume_type = "gp3"
        delete_on_termination = true
    }
    iam_instance_profile = "LabInstanceProfile"
    tags = {
        Name = "SecureShop2"
    }
}

resource "aws_lb_listener" "ElasticLoadBalancingV2Listener" {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:986447608599:loadbalancer/app/RefionalLoadBalancer/216aabdd7cbec837"
    port = 80
    protocol = "HTTP"
    default_action {
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:986447608599:targetgroup/TargetWebApp/fa1cac167567f27e"
        type = "forward"
    }
}

resource "aws_lb" "ElasticLoadBalancingV2LoadBalancer" {
    name = "RefionalLoadBalancer"
    internal = false
    load_balancer_type = "application"
    subnets = [
        "subnet-08b4b2543b7a6d22d",
        "subnet-099e741a35aae91c7"
    ]
    security_groups = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    ip_address_type = "ipv4"
    access_logs {
        enabled = false
        bucket = ""
        prefix = ""
    }
    idle_timeout = "60"
    enable_deletion_protection = "false"
    enable_http2 = "true"
    enable_cross_zone_load_balancing = "true"
}

resource "aws_security_group" "EC2SecurityGroup" {
    description = "Use for load balancer group only"
    name = "LoadBalancerSecurityGroup"
    tags = {}
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 80
        protocol = "tcp"
        to_port = 80
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 465
        protocol = "tcp"
        to_port = 465
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 1024
        protocol = "tcp"
        to_port = 65535
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "EC2SecurityGroup2" {
    description = "For EC2 use"
    name = "EC2SecurityGroup"
    tags = {}
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 80
        protocol = "tcp"
        to_port = 80
    }
    ingress {
        cidr_blocks = [
            "1.32.119.241/32"
        ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 443
        protocol = "tcp"
        to_port = 443
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "EC2SecurityGroup3" {
    description = "VPC Security Group"
    name = "Ec2SecurityGroup"
    tags = {
        cloudlab = "c214974a5430356l15748374t1w986447608599"
    }
    vpc_id = "vpc-066d7d032d6cbb370"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup" {
    health_check {
        interval = 30
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealthy_threshold = 2
        healthy_threshold = 5
        matcher = "200"
    }
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    name = "TargetWebApp"
}

resource "aws_ebs_volume" "EC2Volume" {
    availability_zone = "us-east-1a"
    encrypted = false
    size = 8
    type = "gp3"
    snapshot_id = "snap-0e816f8302c2ccc0f"
    tags = {}
}

resource "aws_ebs_volume" "EC2Volume2" {
    availability_zone = "us-east-1b"
    encrypted = false
    size = 8
    type = "gp3"
    snapshot_id = "snap-04d040cd8bcb1ae39"
    tags = {}
}

resource "aws_ebs_volume" "EC2Volume3" {
    availability_zone = "us-east-1a"
    encrypted = false
    size = 8
    type = "gp3"
    snapshot_id = "snap-04d040cd8bcb1ae39"
    tags = {}
}

resource "aws_volume_attachment" "EC2VolumeAttachment" {
    volume_id = "vol-08b2d4e7fb49939da"
    instance_id = "i-028009262ecb2a0eb"
    device_name = "/dev/xvda"
}

resource "aws_volume_attachment" "EC2VolumeAttachment2" {
    volume_id = "vol-0ddcd5d3fddbdd514"
    instance_id = "i-0d3078dd04d93d286"
    device_name = "/dev/xvda"
}

resource "aws_volume_attachment" "EC2VolumeAttachment3" {
    volume_id = "vol-0858e4f814e0d92a8"
    instance_id = "i-0b3e3b68c436ec279"
    device_name = "/dev/xvda"
}

resource "aws_network_interface" "EC2NetworkInterface" {
    description = "ELB app/RefionalLoadBalancer/216aabdd7cbec837"
    private_ips = [
        "10.0.23.248"
    ]
    subnet_id = "subnet-099e741a35aae91c7"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface2" {
    description = "Interface for NAT Gateway nat-06cb61dda8f4ff938"
    private_ips = [
        "10.0.22.226"
    ]
    subnet_id = "subnet-099e741a35aae91c7"
    source_dest_check = false
}

resource "aws_network_interface" "EC2NetworkInterface3" {
    description = "ELB app/RefionalLoadBalancer/216aabdd7cbec837"
    private_ips = [
        "10.0.14.112"
    ]
    subnet_id = "subnet-08b4b2543b7a6d22d"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface4" {
    description = "Interface for NAT Gateway nat-0ac66a3f6d4dff0d6"
    private_ips = [
        "10.0.4.35"
    ]
    subnet_id = "subnet-08b4b2543b7a6d22d"
    source_dest_check = false
}

resource "aws_network_interface" "EC2NetworkInterface5" {
    description = ""
    private_ips = [
        "10.0.154.192"
    ]
    subnet_id = "subnet-0cf8a4e44aae378e9"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup2.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface6" {
    description = ""
    private_ips = [
        "10.0.132.232"
    ]
    subnet_id = "subnet-0394bca7e32938981"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup2.id}"
    ]
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment" {
    network_interface_id = "eni-09ab0712de73d9de9"
    device_index = 0
    instance_id = "i-0d3078dd04d93d286"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment2" {
    network_interface_id = "eni-0fb0d1f36c0929f7d"
    device_index = 0
    instance_id = "i-0b3e3b68c436ec279"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment3" {
    network_interface_id = "eni-0150fdb50916018b4"
    device_index = 0
    instance_id = "i-028009262ecb2a0eb"
}

resource "aws_key_pair" "EC2KeyPair" {
    public_key = "MIIEpQIBAAKCAQEArurppiDqbyaWmRNmdAdo2cUGcHoqEG7eM9mWOqUJZRkmajxT
n4h2hph+DbzSLM3SVNHqGadDvW11qXBBW4YEEXyDGrh3/tq1kM8Bo7iBNsM0sAik
4UhTCtQEmefymz9nTsEY0Xv41+4z0C2nz5cdJLegzPD9qrVuSNivqGqEpgOX43aY
4oq4aXEa1ooUbto7utxiX6hmn8sfZ1ZS2EbNWzdondUJbReS+e41lf2w79RSneja
qaeTCyMc7KhK3S6zt/31hRH/mQ86g8Xx/575ZNxl3bWeL83noR37nWCqXfy0ktZ8
iKRg0FbGfnZ4XPJrcu/7smPXiakYLp7Jr+UVwQIDAQABAoIBAQCf/h0zKH5mpqwv
XhBjZvef4ViPfx6Eo3Q5hvejsptSTtvVZlKy5JZNbKQ4GpNACg8uKEdxqY4LcVij
YBtYBNAp0nL0+PBBO3nB96avQy9lkM3bijyOF6JlkCKZSBCfsjHjVjpGOpgVojrg
WzJYbgdpM1Eww+mywHscxJ5/dNbaJYIWmjsZNcuK4XFndMbAgQhOKHpj8d6A9BIZ
oiaqIUWBK1lB/xiIEhIrX9Sos6n19D7HMDKBxXDHICjH0KA4TI54yajnVsA4dysU
Gj5Sz0fcYcqsax6cgLVIrA+Zm/ekpvmBDhtD0Fp6n5tBE2M1zXLqVlazCEHwVoDs
mgDq/xhlAoGBANdqQmqb6y6NIiQ4JbtnjLZJK/eK63uWJJB6yWSUzVPNcmYypw/r
GbVK7IIERVRs7vywsgDeogQdtgTX9sZDMr7Wa0y+UYMyvZzp15Iz5VAhrbaXNNnw
VMucJe6l8l6NtqhgwfAIARk8QBRFZxgLVKh3cimbotUuTh0SUloCz8+nAoGBAM/f
aQjl2i7mCXITz5OwIwwAMfETLmlCf4ZjbfsEwuRWeYZs1ca+H4aQ7c8WKY34dbVD
94pqd+aZncMTNJ263C82J8w/cbvpLSJN3ueCqEOlOCTOH+5YPKBJRoI0NRPr/K/a
S72PGpkwezNYY/zxCvP8/C/foAyKJol7lG+e3txXAoGAA9sGB0x1ICcshkNvAXSw
Aw86NzsITfT5AJECC8fSCP7zXjrn3JQTqLgHlagn6YPtnx42gWd6tOInQNzwsMnB
HcNOtlfts5Bz7lwNHLPLFe0UY+E+8+umSOKplyTnOqQEsezRa89o3Z/DcdlwJ/ED
+ePxaic7+d7TTRfn226Tc58CgYEAm0FNfavOzYBaRa2uN6wyQOBUbK3a2BsmjATv
O7BOr6Q2l8Pp1sphWWwdcbInzzVnFL9yvxrN+pl5Tx2lCrlpgol8J/yqwaJiZ2Cp
v1fCvONFj5e0GZwli8Guu8iqa/qxe9YbA7VCNHAVVEAMTfrqJ1koMclgDH2SUtTO
BKAv63kCgYEAwTyhGPeelEKl8zYHNG0VLyo3xPdcrk7WqW+da4eGsM8ofXlcn0AN
1YTtOGGtZ3Pyea3UwIdZqRyA7ZLKMuEJngmbQoWk1l8mdPFcdBdFhb6omem5rcmH
TyCpryzJyu8cDG/xomfdCtBn3MJX5h09Y89e2BA82nlvol1tchxYzAE=
"
    key_name = "assignment"
}

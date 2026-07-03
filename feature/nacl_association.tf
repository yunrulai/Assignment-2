resource "aws_network_acl_association" "public_1" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_network_acl_association" "public_2" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.public_2.id
}
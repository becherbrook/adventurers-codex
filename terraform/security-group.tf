resource "aws_security_group" "adventurers_codex" {
  name        = "adventurers-codex"
  description = "Security group for Adventurers Codex EC2 instance"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.adventurers_codex.id

  cidr_ipv4   = var.allowed_ssh_cidr
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "api" {
  security_group_id = aws_security_group.adventurers_codex.id

  cidr_ipv4   = var.allowed_api_cidr
  from_port   = 8000
  ip_protocol = "tcp"
  to_port     = 8000
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.adventurers_codex.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

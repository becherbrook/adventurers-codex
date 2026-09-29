terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "adventurers_codex" {
  ami           = "ami-0224ce6f9504665ee"
  instance_type = "t3.micro"

  key_name               = "adventurers-codex-ec2"
  subnet_id              = "subnet-0f75952e6edcacd94"
  vpc_security_group_ids = [aws_security_group.adventurers_codex.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "adventurers-codex-ec2"
  }
}

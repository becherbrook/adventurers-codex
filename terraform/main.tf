terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "adventurers_codex" {
  ami           = "ami-0224ce6f9504665ee"
  instance_type = var.instance_type

  key_name               = "adventurers-codex-ec2"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.adventurers_codex.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "adventurers-codex-ec2"
  }
}

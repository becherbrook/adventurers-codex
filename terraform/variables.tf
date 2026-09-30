variable "aws_region" {
  description = "AWS region for the Adventurers Codex infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "EC2 instance type for the Adventurers Codex server"
  type        = string
  default     = "t3.micro"
}
variable "vpc_id" {
  description = "VPC containing the Adventurers Codex infrastructure"
  type        = string
}

variable "subnet_id" {
  description = "Subnet for the Adventurers Codex EC2 instance"
  type        = string
}
variable "allowed_ssh_cidr" {
  description = "CIDR range allowed to connect to SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid IPv4 CIDR range."
  }
}

variable "allowed_api_cidr" {
  description = "CIDR range allowed to connect to the API"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_api_cidr, 0))
    error_message = "allowed_api_cidr must be a valid IPv4 CIDR range."
  }
}

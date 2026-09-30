output "instance_id" {
  description = "ID of the Adventurers Codex EC2 instance"
  value       = aws_instance.adventurers_codex.id
}

output "private_ip" {
  description = "Private IP address of the Adventurers Codex EC2 instance"
  value       = aws_instance.adventurers_codex.private_ip
}

output "security_group_id" {
  description = "ID of the Adventurers Codex security group"
  value       = aws_security_group.adventurers_codex.id
}

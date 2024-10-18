# outputs.tf

output "build_instance_public_ip" {
  description = "Public IP address of the BUILD instance"
  value       = aws_instance.build_instance.public_ip
}

output "test_instance_public_ip" {
  description = "Public IP address of the TEST instance"
  value       = aws_instance.test_instance.public_ip
}

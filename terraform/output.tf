output "instance_ip" {
  value       = aws_instance.instance.public_ip
  description = "The public ip for the instance"
}

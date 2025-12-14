# outputs.tf
# Output values for the compute module

output "bootstrap_instance_id" {
  description = "ID of the bootstrap EC2 instance"
  value       = aws_instance.web.id
}

output "bootstrap_instance_public_ip" {
  description = "Public IP address of the bootstrap EC2 instance"
  value       = aws_instance.web.public_ip
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.web_lt.id
}

output "web_ami_id" {
  description = "ID of the custom AMI"
  value       = aws_ami_from_instance.web_ami.id
}

output "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  value       = aws_key_pair.webapp_key.key_name
}

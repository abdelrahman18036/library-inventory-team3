output "public_ec2_instance_id" {
  value = aws_instance.public_ec2[0].id
}

output "public_ec2_instance_public_ip" {
  value = aws_instance.public_ec2[0].public_ip
}

output "public_ec2_instance_public_dns" {
  value = aws_instance.public_ec2[0].public_dns
}

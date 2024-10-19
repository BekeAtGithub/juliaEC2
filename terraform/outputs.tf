# Output the public IP of the EC2 instance running the Julia app
output "app_public_ip" {
  description = "The public IP address of the EC2 instance running the Julia app"
  value       = aws_instance.app.public_ip
}

# Output the public IP of the EC2 instance running NGINX
output "nginx_public_ip" {
  description = "The public IP address of the EC2 instance running NGINX"
  value       = aws_instance.nginx.public_ip
}

# Output the RDS endpoint
output "rds_endpoint" {
  description = "The RDS endpoint for connecting to the PostgreSQL database"
  value       = aws_db_instance.rds.endpoint
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Output the Subnet IDs
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

# Output the name of the RDS database
output "rds_db_name" {
  description = "The name of the RDS database"
  value       = aws_db_instance.rds.name
}

# Output the security group for the EC2 instances
output "app_security_group_id" {
  description = "The security group ID for the EC2 instances"
  value       = aws_security_group.app_sg.id
}

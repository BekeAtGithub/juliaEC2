provider "aws" {
  region = var.aws_region
}

# VPC setup
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = var.vpc_name
  }
}

# Security group for EC2 and NGINX
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow traffic for the app and NGINX"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic to the app on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS (PostgreSQL) setup
resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.5"
  instance_class       = "db.t3.micro"
  name                 = var.db_name
  username             = var.db_user
  password             = var.db_password
  parameter_group_name = "default.postgres12"
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "RDS Subnet Group"
  }
}

# EC2 instance for the Julia app
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name
  subnet_id     = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "App Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install docker.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker pull ${var.docker_image}
              sudo docker run -d -p 8080:8080 \
                --env DB_HOST=${aws_db_instance.rds.address} \
                --env DB_NAME=${var.db_name} \
                --env DB_USER=${var.db_user} \
                --env DB_PASSWORD=${var.db_password} \
                ${var.docker_image}
              EOF
}

# Elastic IP for NGINX Load Balancer
resource "aws_eip" "nginx_eip" {
  vpc = true
}

# NGINX Load Balancer EC2 Instance
resource "aws_instance" "nginx" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name
  subnet_id     = module.vpc.public_subnets[1]
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "NGINX Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
}

# Attach Elastic IP to NGINX instance
resource "aws_eip_association" "nginx_eip_association" {
  instance_id = aws_instance.nginx.id
  allocation_id = aws_eip.nginx_eip.id
}

# Output public IPs for EC2 instances
output "app_public_ip" {
  description = "Public IP of the App EC2 instance"
  value       = aws_instance.app.public_ip
}

output "nginx_public_ip" {
  description = "Public IP of the NGINX EC2 instance"
  value       = aws_instance.nginx.public_ip
}

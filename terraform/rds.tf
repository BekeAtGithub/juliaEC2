# Create a subnet group for the RDS instance, which includes private subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "julia-app-rds-subnet-group"
  description = "Subnet group for the Julia app RDS instance"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "julia-app-rds-subnet-group"
  }
}

# Create the RDS PostgreSQL instance
resource "aws_db_instance" "julia_app_rds" {
  allocated_storage      = 20                     # Size of the RDS storage in GB
  engine                 = "postgres"             # Use PostgreSQL engine
  engine_version         = "12.5"                 # PostgreSQL version
  instance_class         = var.db_instance_class   # Instance class for RDS
  name                   = var.db_name            # Database name
  username               = var.db_user            # Database username
  password               = var.db_password        # Database password
  publicly_accessible    = false                  # Should not be publicly accessible
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # Attach to security group
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name # Subnet group
  multi_az               = false                  # Single availability zone
  backup_retention_period = 7                     # Retain backups for 7 days
  skip_final_snapshot    = true                   # Do not take final snapshot on deletion

  tags = {
    Name = "julia-app-rds"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "julia-app-rds-sg"
  description = "Security group for the Julia app RDS instance"
  vpc_id      = module.vpc.vpc_id

  # Ingress rule: allow incoming traffic from the EC2 app instance on PostgreSQL port
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.app_sg.vpc_id]  # Allow traffic from the app security group
  }

  # Egress rule: allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "julia-app-rds-sg"
  }
}

# Output the RDS endpoint and database name
output "rds_endpoint" {
  description = "The RDS endpoint for the PostgreSQL database"
  value       = aws_db_instance.julia_app_rds.endpoint
}

output "rds_db_name" {
  description = "The name of the PostgreSQL database"
  value       = aws_db_instance.julia_app_rds.name
}

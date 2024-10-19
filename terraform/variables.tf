# AWS region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-west-2"  # Modify as per your preferred region
}

# VPC configuration
variable "vpc_name" {
  description = "Name of the VPC"
  default     = "my-app-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]  # Modify as per your region
}

variable "public_subnets" {
  description = "Public subnets for the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets for the VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EC2 instance settings
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Example for Ubuntu 20.04 in us-west-2, modify as needed
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key pair name to use for SSH access to EC2 instances"
  type        = string
}

# Docker image for the Julia app
variable "docker_image" {
  description = "The Docker image to run the Julia app"
  default     = "julia-app:latest"  # Replace with your actual Docker image
}

# RDS (PostgreSQL) settings
variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "myappdb"
}

variable "db_user" {
  description = "The username for the RDS database"
  type        = string
  default     = "dbuser"
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  default     = "dbpassword"  # Replace with a strong password or use a secret manager
}

variable "db_instance_class" {
  description = "The instance class for RDS"
  default     = "db.t3.micro"
}

# Environment variables for deployment (optional)
variable "env" {
  description = "Environment tag (e.g., dev, prod)"
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state"
}

variable "s3_state_key" {
  description = "The path within the S3 bucket where the state file will be stored"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for state locking"
}

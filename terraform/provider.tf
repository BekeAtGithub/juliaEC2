# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Optionally configure the backend to store Terraform state in S3
terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name        # S3 bucket name for storing Terraform state
    key            = var.s3_state_key          # Path to store the state file in the bucket
    region         = var.aws_region            # AWS region of the S3 bucket
    dynamodb_table = var.dynamodb_table_name   # DynamoDB table for state locking (optional)
    encrypt        = true                      # Enable encryption for the state file
  }
}

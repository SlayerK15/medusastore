# terraform/s3.tf
# Configures Terraform to store state in S3 bucket

terraform {
  backend "s3" {
    bucket = "medusa-store-tf"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
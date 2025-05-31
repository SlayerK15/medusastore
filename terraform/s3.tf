# terraform/s3.tf
# S3 backend configuration only

terraform {
  backend "s3" {
    bucket = "medusa-store-tf"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
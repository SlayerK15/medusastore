variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "medusa"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "medusa"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "medusa"
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "medusa"
}

variable "jwt_secret" {
  description = "JWT secret for authentication"
  type        = string
  default     = "supersecret"
  sensitive   = true
}

variable "cookie_secret" {
  description = "Cookie secret"
  type        = string
  default     = "supersecret"
  sensitive   = true
}

variable "ecr_image_uri" {
  description = "ECR image URI for the Medusa backend"
  type        = string
  default     = "841162667281.dkr.ecr.ap-south-1.amazonaws.com/medusa-store:latest"
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "1024"
}

variable "task_memory" {
  description = "Memory for the ECS task"
  type        = string
  default     = "3072"
}
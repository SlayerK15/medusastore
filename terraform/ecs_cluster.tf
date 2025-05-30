# ECS Cluster
resource "aws_ecs_cluster" "medusa" {
  name = "${var.project_name}-cluster"

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}
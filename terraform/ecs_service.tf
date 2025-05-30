# ECS Service
resource "aws_ecs_service" "medusa" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.medusa.id
  task_definition = aws_ecs_task_definition.medusa.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.medusa.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.project_name}-service"
    Environment = var.environment
  }
}
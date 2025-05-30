# ECS Task Definition
resource "aws_ecs_task_definition" "medusa" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "postgres"
      image     = "postgres:15-alpine"
      essential = true
      environment = [
        {
          name  = "POSTGRES_USER"
          value = var.postgres_user
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = var.postgres_password
        },
        {
          name  = "POSTGRES_DB"
          value = var.postgres_db
        }
      ]
      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-postgres"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    },
    {
      name      = "redis"
      image     = "redis:alpine"
      essential = true
      portMappings = [
        {
          containerPort = 6379
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-redis"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    },
    {
      name      = "${var.project_name}-backend"
      image     = var.ecr_image_uri
      essential = true
      dependsOn = [
        {
          containerName = "postgres"
          condition     = "START"
        },
        {
          containerName = "redis"
          condition     = "START"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "DATABASE_URL"
          value = "postgres://${var.postgres_user}:${var.postgres_password}@localhost:5432/${var.postgres_db}?sslmode=disable"
        },
        {
          name  = "ADMIN_CORS"
          value = "http://localhost:9000"
        },
        {
          name  = "STORE_CORS"
          value = "http://localhost:8000,http://localhost:3000"
        },
        {
          name  = "AUTH_CORS"
          value = "http://localhost:9000"
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        },
        {
          name  = "COOKIE_SECRET"
          value = var.cookie_secret
        },
        {
          name  = "MEDUSA_BACKEND_URL"
          value = "http://localhost:9000"
        },
        {
          name  = "REDIS_URL"
          value = "redis://localhost:6379"
        },
        {
          name  = "REDIS_URI"
          value = "redis://localhost:6379"
        }
      ]
      portMappings = [
        {
          containerPort = 9000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-task-definition"
    Environment = var.environment
  }
}
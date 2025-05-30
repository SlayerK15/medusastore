# Outputs
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.medusa.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.medusa.name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.medusa.id
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.medusa.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}
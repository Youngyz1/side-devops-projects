# outputs.tf - Information displayed after deployment

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.youngyz.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.youngyzapp.name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.youngyzapp.name
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.youngyzapp_sg.id
}

output "task_definition_arn" {
  description = "Task definition ARN"
  value       = aws_ecs_task_definition.youngyzapp.arn
}

output "next_steps" {
  description = "What to do next"
  value = <<EOF
Your infrastructure is ready! Next steps:

1. Check ECS Console: https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${aws_ecs_cluster.youngyz.name}
2. Find your running task and get its public IP
3. Open http://[PUBLIC_IP] in your browser
4. Check logs in CloudWatch: https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logStream:group=${aws_cloudwatch_log_group.youngyzapp.name}

To get the public IP via CLI:
aws ecs list-tasks --cluster ${aws_ecs_cluster.youngyz.name} --service-name ${aws_ecs_service.youngyzapp.name}
EOF
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.youngyzapp.repository_url
}

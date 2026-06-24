output "alb_dns_name" {
  description = "Public URL of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "ARN to set as AWS_ROLE_ARN secret in GitHub"
  value       = aws_iam_role.github_actions.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "backend_repository_url" {
  value       = aws_ecr_repository.ai_portal_backend.repository_url
  description = "ECR repository URL for backend"
}

output "frontend_repository_url" {
  value       = aws_ecr_repository.ai_portal_frontend.repository_url
  description = "ECR repository URL for frontend"
}

output "github_actions_ecr_role_arn" {
  value       = aws_iam_role.github_actions_ecr.arn
  description = "ARN of the IAM role for GitHub Actions to push to ECR"
}
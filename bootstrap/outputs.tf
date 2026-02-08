output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "backend_config" {
  description = "Backend configuration to use in main Terraform project"
  value = <<-EOT
    backend "s3" {
      bucket         = "${aws_s3_bucket.terraform_state.id}"
      key            = "eks/terraform.tfstate"
      region         = "us-east-1"
      use_lockfile   = true
      encrypt        = true
    }
  EOT
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
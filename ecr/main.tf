resource "aws_ecr_repository" "ai_portal_backend" {
  name                 = "ai-portal/backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Application = "ai-portal"
    Component   = "backend"
  }
}

resource "aws_ecr_repository" "ai_portal_frontend" {
  name                 = "ai-portal/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Application = "ai-portal"
    Component   = "frontend"
  }
}

# Lifecycle policy to clean up old images
resource "aws_ecr_lifecycle_policy" "ai_portal_backend" {
  repository = aws_ecr_repository.ai_portal_backend.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = {
        type = "expire"
      }
    }]
  })
}

data "aws_caller_identity" "current" {}

# IAM role for GitHub Actions to push to ECR
resource "aws_iam_role" "github_actions_ecr" {
  name = "github-actions-ecr-push-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Jtwoolbright/ai-infrastructure-self-service-portal:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "GitHub Actions ECR Push Role"
  }
}

# Policy for ECR push permissions
resource "aws_iam_role_policy" "github_actions_ecr_push" {
  name = "ecr-push-policy"
  role = aws_iam_role.github_actions_ecr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          aws_ecr_repository.ai_portal_backend.arn,
          aws_ecr_repository.ai_portal_frontend.arn
        ]
      }
    ]
  })
}

# SSM Parameter to store Anthropic API Key
resource "aws_ssm_parameter" "anthropic_key_ssm" {
  name  = "/ai_portal/anthropic_key"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE" // Update this one time through CLI or console

  description = "Anthropic API Key"
  
  tags = {
    ManagedBy = "Terraform"
    Layer     = "ecr"
  }
}

################################################################################
# IAM Roles & Policies
################################################################################

# CodePipeline IAM Role
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-${var.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

# CodePipeline IAM Policy (S3 + CodeStar permissions)
resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:DescribeConnection"
        ],
        Resource = var.codestar_connection_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.artifacts.bucket}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:StopBuild"
        ],
        Resource = [for key, service in var.services : aws_codebuild_project.build[key].arn]
      }
    ]
  })
}

# CodeBuild IAM Roles (one per service)
resource "aws_iam_role" "codebuild_role" {
  for_each = var.services
  name     = "codebuild-role-${each.key}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

# CodeBuild IAM Policies (ECR + Logs/S3 permissions)
resource "aws_iam_role_policy" "codebuild_policy" {
  for_each = var.services
  role     = aws_iam_role.codebuild_role[each.key].name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = aws_ecr_repository.repo[each.key].arn
      },
      {
        Effect   = "Allow",
        Action   = ["logs:*", "s3:*"],
        Resource = "*"
      }
    ]
  })
}

################################################################################
# Storage Resources
################################################################################

# Random suffix for S3 bucket name
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 Bucket for Pipeline Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
}

# ECR Repositories (one per service)
resource "aws_ecr_repository" "repo" {
  for_each = var.services
  name     = each.key
}

################################################################################
# CI/CD Pipeline Components
################################################################################

# CodeBuild Projects (one per service)
resource "aws_codebuild_project" "build" {
  for_each      = var.services
  name          = "${each.key}-build"
  service_role  = aws_iam_role.codebuild_role[each.key].arn
  build_timeout = "5"

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "SERVICE_DIR"
      value = each.value.path
    }
    environment_variable {
      name  = "ECR_REPO_URI"
      value = aws_ecr_repository.repo[each.key].repository_url
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2
      phases:
        pre_build:
          commands:
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI
        build:
          commands:
            - cd $SERVICE_DIR
            - docker build -t $ECR_REPO_URI:latest .
            - docker tag $ECR_REPO_URI:latest $ECR_REPO_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
        post_build:
          commands:
            - docker push $ECR_REPO_URI:latest
            - docker push $ECR_REPO_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
    EOT
  }
}

# CodePipelines (one per service)
resource "aws_codepipeline" "pipeline" {
  for_each = var.services
  name     = "${each.key}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "${each.value.github_owner}/${each.value.github_repo}"
        BranchName           = each.value.branch
        DetectChanges        = true
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName      = aws_codebuild_project.build[each.key].name
        EnvironmentVariables = jsonencode([{
          name  = "ENV"
          value = var.environment
          type  = "PLAINTEXT"
        }])
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Pipeline Module - CodePipeline, CodeBuild, and Supporting Resources
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# S3 Artifact Bucket with Server-Side Encryption
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name_prefix}-pipeline-artifacts"

  tags = {
    Name        = "${local.name_prefix}-pipeline-artifacts"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for CodeBuild Projects
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${local.name_prefix}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-codebuild-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# IAM Module - Least-Privilege Roles
# -----------------------------------------------------------------------------

module "iam" {
  source = "../iam"

  project_name        = var.project_name
  environment         = var.environment
  artifact_bucket_arn = aws_s3_bucket.artifacts.arn
  state_bucket_arn    = var.state_bucket_arn
  lock_table_arn      = var.lock_table_arn
  connection_arn      = var.connection_arn
  log_group_arn       = aws_cloudwatch_log_group.codebuild.arn
}

# -----------------------------------------------------------------------------
# CodeBuild Project - Validate (fmt -check + validate)
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "validate" {
  name         = "${local.name_prefix}-codebuild-validate"
  description  = "Runs terraform fmt -check and terraform validate for ${var.environment}"
  service_role = module.iam.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/validate.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
      status     = "ENABLED"
    }
  }

  tags = {
    Name        = "${local.name_prefix}-codebuild-validate"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# CodeBuild Project - Apply (init + plan + apply)
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "apply" {
  name         = "${local.name_prefix}-codebuild-apply"
  description  = "Runs terraform init, plan, and apply for ${var.environment}"
  service_role = module.iam.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "TF_ENV"
      value = var.environment
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/apply.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
      status     = "ENABLED"
    }
  }

  tags = {
    Name        = "${local.name_prefix}-codebuild-apply"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# CodePipeline - Source, Validate, Apply Stages
# -----------------------------------------------------------------------------

resource "aws_codepipeline" "this" {
  name     = "${local.name_prefix}-pipeline-deploy"
  role_arn = module.iam.codepipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  # ---------------------------------------------------------------------------
  # Stage 1: Source - CodeStar Connection to Git repository
  # ---------------------------------------------------------------------------
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
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repository_id
        BranchName       = var.source_branch
        DetectChanges    = "true"
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Stage 2: Validate - terraform fmt -check + terraform validate
  # ---------------------------------------------------------------------------
  stage {
    name = "Validate"

    action {
      name            = "Validate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.validate.name
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Stage 3: Apply - terraform init + plan + apply
  # ---------------------------------------------------------------------------
  stage {
    name = "Apply"

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.apply.name
      }
    }
  }

  tags = {
    Name        = "${local.name_prefix}-pipeline-deploy"
    Project     = var.project_name
    Environment = var.environment
  }
}

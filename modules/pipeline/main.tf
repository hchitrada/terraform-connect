# -----------------------------------------------------------------------------
# Pipeline Module - Single Pipeline with Dev, Approval, Prod stages
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-pipeline"
}

# -----------------------------------------------------------------------------
# SNS Topic for Manual Approval Notifications
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "approval" {
  name = "${local.name_prefix}-approval"

  tags = {
    Name    = "${local.name_prefix}-approval"
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "approval_email" {
  topic_arn = aws_sns_topic.approval.arn
  protocol  = "email"
  endpoint  = var.approval_email
}

# -----------------------------------------------------------------------------
# S3 Artifact Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name_prefix}-artifacts"

  tags = {
    Name    = "${local.name_prefix}-artifacts"
    Project = var.project_name
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
# CloudWatch Log Group
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name    = "${local.name_prefix}-codebuild-logs"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# IAM Module
# -----------------------------------------------------------------------------

module "iam" {
  source = "../iam"

  project_name        = var.project_name
  environment         = "shared"
  artifact_bucket_arn = aws_s3_bucket.artifacts.arn
  state_bucket_arn    = var.state_bucket_arn
  lock_table_arn      = var.lock_table_arn
  connection_arn      = var.connection_arn
  log_group_arn       = aws_cloudwatch_log_group.codebuild.arn
}

# -----------------------------------------------------------------------------
# CodeBuild - Validate
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "validate" {
  name         = "${var.project_name}-codebuild-validate"
  description  = "Runs terraform fmt -check and terraform validate"
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
    Name    = "${var.project_name}-codebuild-validate"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodeBuild - Deploy Dev
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "deploy_dev" {
  name         = "${var.project_name}-codebuild-deploy-dev"
  description  = "Terraform apply for dev environment"
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
      value = "dev"
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
    Name    = "${var.project_name}-codebuild-deploy-dev"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodeBuild - Deploy Prod
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "deploy_prod" {
  name         = "${var.project_name}-codebuild-deploy-prod"
  description  = "Terraform apply for prod environment"
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
      value = "prod"
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
    Name    = "${var.project_name}-codebuild-deploy-prod"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodeBuild - Build Website (generates HTML with phone numbers)
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "build_website" {
  name         = "${var.project_name}-codebuild-build-website"
  description  = "Generates the support page HTML with both phone numbers"
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
      name  = "WEBSITE_BUCKET"
      value = var.website_bucket
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/website.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
      status     = "ENABLED"
    }
  }

  tags = {
    Name    = "${var.project_name}-codebuild-build-website"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodeBuild - Build Website Dev (dev number only, before approval)
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "build_website_dev" {
  name         = "${var.project_name}-codebuild-build-website-dev"
  description  = "Generates the support page HTML with dev phone number only"
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
      name  = "WEBSITE_BUCKET"
      value = var.website_bucket
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/website-dev.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
      status     = "ENABLED"
    }
  }

  tags = {
    Name    = "${var.project_name}-codebuild-build-website-dev"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodePipeline
# Source → Validate → Build-Dev → Deploy-Website-Dev → Approval → Build-Prod → Deploy-Website
# -----------------------------------------------------------------------------

resource "aws_codepipeline" "this" {
  name     = "${var.project_name}-pipeline"
  role_arn = module.iam.codepipeline_role_arn

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
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repository_id
        BranchName       = var.source_branch
        DetectChanges    = "true"
      }
    }
  }

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

  stage {
    name = "Build-Dev"

    action {
      name            = "Build-Dev"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_dev.name
      }
    }
  }

  stage {
    name = "Deploy-Website-Dev"

    action {
      name            = "Deploy-Website-Dev"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build_website_dev.name
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "Manual-Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn    = aws_sns_topic.approval.arn
        ExternalEntityLink = "https://${var.cloudfront_domain}"
        CustomData         = "Dev deployed. Click the link to view the dev number, dial it to verify, then approve for Production."
      }
    }
  }

  stage {
    name = "Build-Prod"

    action {
      name            = "Build-Prod"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_prod.name
      }
    }
  }

  stage {
    name = "Deploy-Website"

    action {
      name            = "Deploy-Website"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build_website.name
      }
    }
  }

  tags = {
    Name    = "${var.project_name}-pipeline"
    Project = var.project_name
  }
}

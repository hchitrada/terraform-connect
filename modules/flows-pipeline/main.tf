# -----------------------------------------------------------------------------
# Flows Pipeline - Deploys contact flow updates (dev → approval → prod)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# CodeBuild - Deploy Flow to Dev
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "deploy_flow_dev" {
  name         = "${var.project_name}-flows-deploy-dev"
  description  = "Updates contact flow content in dev"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "INSTANCE_ID"
      value = var.dev_instance_id
    }

    environment_variable {
      name  = "CONTACT_FLOW_ID"
      value = var.dev_contact_flow_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.log_group_name
      status     = "ENABLED"
    }
  }

  tags = {
    Name    = "${var.project_name}-flows-deploy-dev"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodeBuild - Deploy Flow to Prod
# -----------------------------------------------------------------------------

resource "aws_codebuild_project" "deploy_flow_prod" {
  name         = "${var.project_name}-flows-deploy-prod"
  description  = "Updates contact flow content in prod"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "INSTANCE_ID"
      value = var.prod_instance_id
    }

    environment_variable {
      name  = "CONTACT_FLOW_ID"
      value = var.prod_contact_flow_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.log_group_name
      status     = "ENABLED"
    }
  }

  tags = {
    Name    = "${var.project_name}-flows-deploy-prod"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodePipeline - Source → Deploy-Dev → Approval → Deploy-Prod
# -----------------------------------------------------------------------------

resource "aws_codepipeline" "flows" {
  name     = "${var.project_name}-flows-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket
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
        FullRepositoryId = var.flows_repository_id
        BranchName       = "main"
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "Deploy-Dev"

    action {
      name            = "Deploy-Flow-Dev"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_flow_dev.name
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
        NotificationArn    = var.approval_sns_topic_arn
        ExternalEntityLink = "https://${var.cloudfront_domain}"
        CustomData         = "Flow updated in dev. Dial the dev number to verify, then approve for Production."
      }
    }
  }

  stage {
    name = "Deploy-Prod"

    action {
      name            = "Deploy-Flow-Prod"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_flow_prod.name
      }
    }
  }

  tags = {
    Name    = "${var.project_name}-flows-pipeline"
    Project = var.project_name
  }
}

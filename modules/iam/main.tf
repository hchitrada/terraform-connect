# -----------------------------------------------------------------------------
# IAM Module - Least-Privilege Roles for CodePipeline and CodeBuild
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# CodePipeline IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "codepipeline" {
  name_prefix = "${local.name_prefix}-cp-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${local.name_prefix}-codepipeline-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codepipeline_artifact" {
  name = "${local.name_prefix}-codepipeline-artifact-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_codestar" {
  name = "${local.name_prefix}-codepipeline-codestar-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = var.connection_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_codebuild" {
  name = "${local.name_prefix}-codepipeline-codebuild-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_sns" {
  name = "${local.name_prefix}-codepipeline-sns-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# CodeBuild IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "codebuild" {
  name_prefix = "${local.name_prefix}-cb-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${local.name_prefix}-codebuild-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codebuild_artifact" {
  name = "${local.name_prefix}-codebuild-artifact-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_logs" {
  name = "${local.name_prefix}-codebuild-logs-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          var.log_group_arn,
          "${var.log_group_arn}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_state_backend" {
  name = "${local.name_prefix}-codebuild-state-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          var.state_bucket_arn,
          "${var.state_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = var.lock_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_connect" {
  name = "${local.name_prefix}-codebuild-connect-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "connect:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ds:CheckAlias",
          "ds:CreateAlias",
          "ds:AuthorizeApplication",
          "ds:UnauthorizeApplication",
          "ds:CreateIdentityPoolDirectory",
          "ds:CreateDirectory",
          "ds:DescribeDirectories"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy"
        ]
        Resource = "arn:aws:iam::*:role/aws-service-role/connect.amazonaws.com/*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "connect.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:CreateBucket",
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:connectcc/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_s3_deploy" {
  name = "${local.name_prefix}-codepipeline-s3-deploy-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::connectcc-website",
          "arn:aws:s3:::connectcc-website/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_s3_website" {
  name = "${local.name_prefix}-codebuild-s3-website-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::connectcc-website",
          "arn:aws:s3:::connectcc-website/*"
        ]
      }
    ]
  })
}

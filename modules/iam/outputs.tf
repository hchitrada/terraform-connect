# -----------------------------------------------------------------------------
# IAM Module - Outputs
# -----------------------------------------------------------------------------

output "codepipeline_role_arn" {
  description = "ARN of the IAM role assumed by CodePipeline"
  value       = aws_iam_role.codepipeline.arn
}

output "codebuild_role_arn" {
  description = "ARN of the IAM role assumed by CodeBuild projects"
  value       = aws_iam_role.codebuild.arn
}

# -----------------------------------------------------------------------------
# Pipeline Module - Outputs
# -----------------------------------------------------------------------------

output "pipeline_arn" {
  description = "ARN of the CodePipeline resource"
  value       = aws_codepipeline.this.arn
}

output "pipeline_name" {
  description = "Name of the CodePipeline resource"
  value       = aws_codepipeline.this.name
}

output "codebuild_validate_name" {
  description = "Name of the CodeBuild project used for the Validate stage"
  value       = aws_codebuild_project.validate.name
}

output "codebuild_apply_name" {
  description = "Name of the CodeBuild project used for the Apply stage"
  value       = aws_codebuild_project.apply.name
}

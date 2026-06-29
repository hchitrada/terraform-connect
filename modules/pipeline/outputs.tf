# -----------------------------------------------------------------------------
# Pipeline Module - Outputs
# -----------------------------------------------------------------------------

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.this.arn
}

output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.this.name
}

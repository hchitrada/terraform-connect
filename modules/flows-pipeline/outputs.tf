output "pipeline_name" {
  description = "Name of the flows pipeline"
  value       = aws_codepipeline.flows.name
}

output "pipeline_arn" {
  description = "ARN of the flows pipeline"
  value       = aws_codepipeline.flows.arn
}

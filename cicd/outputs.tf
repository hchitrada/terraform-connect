# -----------------------------------------------------------------------------
# CI/CD Layer - Outputs
# -----------------------------------------------------------------------------

output "dev_pipeline_arn" {
  description = "ARN of the Development environment CodePipeline"
  value       = module.pipeline["dev"].pipeline_arn
}

output "prod_pipeline_arn" {
  description = "ARN of the Production environment CodePipeline"
  value       = module.pipeline["prod"].pipeline_arn
}

output "dev_pipeline_name" {
  description = "Name of the Development environment CodePipeline"
  value       = module.pipeline["dev"].pipeline_name
}

output "prod_pipeline_name" {
  description = "Name of the Production environment CodePipeline"
  value       = module.pipeline["prod"].pipeline_name
}

# -----------------------------------------------------------------------------
# CI/CD Layer - Outputs
# -----------------------------------------------------------------------------

output "pipeline_arn" {
  description = "ARN of the CI/CD pipeline"
  value       = module.pipeline.pipeline_arn
}

output "pipeline_name" {
  description = "Name of the CI/CD pipeline"
  value       = module.pipeline.pipeline_name
}

output "website_url" {
  description = "CloudFront URL for the support page"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "website_bucket" {
  description = "S3 bucket for website content"
  value       = aws_s3_bucket.website.bucket
}

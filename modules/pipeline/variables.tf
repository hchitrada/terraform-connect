# -----------------------------------------------------------------------------
# Pipeline Module - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployments"
  type        = string
}

variable "source_branch" {
  description = "Git branch that triggers this pipeline"
  type        = string
}

variable "connection_arn" {
  description = "ARN of the CodeStar Connection"
  type        = string
}

variable "repository_id" {
  description = "Full repository identifier (owner/repo)"
  type        = string
}

variable "state_bucket_arn" {
  description = "ARN of the S3 state bucket (for IAM scoping)"
  type        = string
}

variable "lock_table_arn" {
  description = "ARN of the DynamoDB lock table (for IAM scoping)"
  type        = string
}

variable "approval_email" {
  description = "Email address for manual approval notifications"
  type        = string
}

variable "website_bucket" {
  description = "S3 bucket name for website deployment"
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront domain name for the approval link"
  type        = string
}

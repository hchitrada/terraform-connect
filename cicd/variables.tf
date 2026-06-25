# -----------------------------------------------------------------------------
# CI/CD Layer - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region where CI/CD resources will be provisioned"
  type        = string
}

variable "connection_arn" {
  description = "ARN of the CodeStar Connection for source repository access"
  type        = string
}

variable "repository_id" {
  description = "Full repository identifier in owner/repo format (e.g., org/terraform-cicd-solution)"
  type        = string
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state storage"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
}

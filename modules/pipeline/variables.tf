# -----------------------------------------------------------------------------
# Pipeline Module - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod) used in resource naming and scoping"
  type        = string
}

variable "aws_region" {
  description = "Target AWS region for the pipeline and CodeBuild projects"
  type        = string
}

variable "source_branch" {
  description = "Git branch that triggers this pipeline (e.g., develop, main)"
  type        = string
}

variable "connection_arn" {
  description = "ARN of the CodeStar Connection for source repository access"
  type        = string
}

variable "repository_id" {
  description = "Full repository identifier in owner/repo format"
  type        = string
}

variable "artifact_bucket_arn" {
  description = "ARN of the S3 artifact bucket used by CodePipeline"
  type        = string
}

variable "state_bucket_arn" {
  description = "ARN of the S3 state backend bucket for Terraform state"
  type        = string
}

variable "lock_table_arn" {
  description = "ARN of the DynamoDB lock table for Terraform state locking"
  type        = string
}

variable "tfvars_file" {
  description = "Path to the environment-specific tfvars file (e.g., env/dev.tfvars)"
  type        = string
}

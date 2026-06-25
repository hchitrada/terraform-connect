# -----------------------------------------------------------------------------
# IAM Module - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod) used in resource naming and scoping"
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

variable "connection_arn" {
  description = "ARN of the CodeStar Connection for source repository access"
  type        = string
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch Logs log group for CodeBuild"
  type        = string
}

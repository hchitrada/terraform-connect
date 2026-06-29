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
  description = "ARN of the CodeStar Connection"
  type        = string
}

variable "repository_id" {
  description = "Full repository identifier (owner/repo)"
  type        = string
}

variable "approval_email" {
  description = "Email address for pipeline approval notifications"
  type        = string
}

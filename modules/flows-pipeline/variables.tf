variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "connection_arn" {
  description = "CodeStar Connection ARN"
  type        = string
}

variable "flows_repository_id" {
  description = "GitHub repository for flows (owner/repo)"
  type        = string
}

variable "dev_instance_id" {
  description = "Connect instance ID for dev"
  type        = string
}

variable "dev_contact_flow_id" {
  description = "Contact flow ID for dev"
  type        = string
}

variable "prod_instance_id" {
  description = "Connect instance ID for prod"
  type        = string
}

variable "prod_contact_flow_id" {
  description = "Contact flow ID for prod"
  type        = string
}

variable "approval_sns_topic_arn" {
  description = "SNS topic ARN for approval notifications"
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront domain for approval link"
  type        = string
}

variable "codebuild_role_arn" {
  description = "CodeBuild IAM role ARN"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "CodePipeline IAM role ARN"
  type        = string
}

variable "artifact_bucket" {
  description = "S3 bucket for pipeline artifacts"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

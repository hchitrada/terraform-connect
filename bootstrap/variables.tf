variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
}

variable "git_provider_type" {
  description = "The type of Git provider for the CodeStar Connection (e.g., GitHub, Bitbucket, GitHubEnterpriseServer)"
  type        = string
  default     = "GitHub"
}

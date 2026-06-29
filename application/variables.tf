# -----------------------------------------------------------------------------
# Application Layer - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where application resources will be provisioned"
  type        = string
}

variable "identity_management_type" {
  description = "Identity management type for the Connect instance"
  type        = string
  default     = "CONNECT_MANAGED"
}

variable "instance_alias" {
  description = "Alias for the Amazon Connect instance (must be globally unique)"
  type        = string
}

variable "phone_number_type" {
  description = "Type of phone number to claim (DID or TOLL_FREE)"
  type        = string
}

variable "phone_number_country_code" {
  description = "ISO country code for the phone number (e.g., US)"
  type        = string
}

variable "contact_flow_files" {
  description = "Map of contact flow name to JSON file path"
  type        = map(string)
}

variable "admin_username" {
  description = "Username for the Connect admin user"
  type        = string
  default     = "admin"
}

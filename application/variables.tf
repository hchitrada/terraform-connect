# -----------------------------------------------------------------------------
# Application Layer - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod) used in resource naming and state isolation"
  type        = string
}

variable "aws_region" {
  description = "AWS region where application resources will be provisioned"
  type        = string
}

variable "identity_management_type" {
  description = "Identity management type for the Connect instance (SAML, CONNECT_MANAGED, or EXISTING_DIRECTORY)"
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
  description = "ISO country code for the phone number (e.g., US, GB)"
  type        = string
}

variable "contact_flow_files" {
  description = "Map of contact flow name to JSON file path containing the flow definition"
  type        = map(string)
}

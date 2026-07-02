# -----------------------------------------------------------------------------
# Connect Module - Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "identity_management_type" {
  description = "Identity management type for the Connect instance"
  type        = string
  default     = "CONNECT_MANAGED"

  validation {
    condition     = contains(["CONNECT_MANAGED", "SAML", "EXISTING_DIRECTORY"], var.identity_management_type)
    error_message = "identity_management_type must be one of: CONNECT_MANAGED, SAML, EXISTING_DIRECTORY."
  }
}

variable "instance_alias" {
  description = "Alias for the Amazon Connect instance (must be globally unique)"
  type        = string
}

variable "phone_number_type" {
  description = "Type of phone number to claim (DID or TOLL_FREE)"
  type        = string

  validation {
    condition     = contains(["DID", "TOLL_FREE"], var.phone_number_type)
    error_message = "phone_number_type must be either \"DID\" or \"TOLL_FREE\"."
  }
}

variable "phone_number_country_code" {
  description = "ISO country code for the phone number (e.g., US)"
  type        = string

  validation {
    condition     = can(regex("^[A-Z]{2}$", var.phone_number_country_code))
    error_message = "phone_number_country_code must be a 2-letter uppercase ISO code (e.g., US, GB)."
  }
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

variable "admin_password" {
  description = "Password for the Connect admin user"
  type        = string
  sensitive   = true
}

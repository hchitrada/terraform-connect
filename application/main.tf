# -----------------------------------------------------------------------------
# Application Layer - Connect Module Instantiation
# -----------------------------------------------------------------------------

module "connect" {
  source = "../modules/connect"

  project_name              = var.project_name
  environment               = var.environment
  identity_management_type  = var.identity_management_type
  instance_alias            = var.instance_alias
  phone_number_type         = var.phone_number_type
  phone_number_country_code = var.phone_number_country_code
  contact_flow_files        = var.contact_flow_files
}

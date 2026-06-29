# -----------------------------------------------------------------------------
# Application Layer - Development Environment Configuration
# -----------------------------------------------------------------------------

environment               = "dev"
project_name              = "connectcc"
aws_region                = "us-east-1"
identity_management_type  = "CONNECT_MANAGED"
instance_alias            = "connectcc-dev"
phone_number_type         = "DID"
phone_number_country_code = "US"
admin_username            = "admin"
contact_flow_files = {
  "inbound-greeting" = "flows/inbound-greeting.json"
}

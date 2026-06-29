# -----------------------------------------------------------------------------
# Application Layer - Outputs
# -----------------------------------------------------------------------------

output "connect_instance_id" {
  description = "ID of the Connect instance"
  value       = module.connect.connect_instance_id
}

output "contact_number" {
  description = "Phone number in E.164 format"
  value       = module.connect.contact_number_e164
}

output "contact_flow_ids" {
  description = "Map of contact flow names to IDs"
  value       = module.connect.contact_flow_ids
}

output "login_url" {
  description = "Connect login URL"
  value       = "https://${module.connect.instance_alias}.my.connect.aws"
}

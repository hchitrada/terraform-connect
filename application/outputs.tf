# -----------------------------------------------------------------------------
# Application Layer - Outputs
# -----------------------------------------------------------------------------

output "connect_instance_id" {
  description = "ID of the Amazon Connect instance"
  value       = module.connect.connect_instance_id
}

output "contact_number" {
  description = "Claimed phone number in E.164 format"
  value       = module.connect.contact_number_e164
}

output "contact_flow_ids" {
  description = "Map of contact flow names to their IDs"
  value       = module.connect.contact_flow_ids
}

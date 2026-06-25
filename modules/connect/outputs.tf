# -----------------------------------------------------------------------------
# Connect Module - Outputs
# -----------------------------------------------------------------------------

output "connect_instance_id" {
  description = "ID of the Amazon Connect instance"
  value       = aws_connect_instance.this.id
}

output "contact_number_e164" {
  description = "Claimed phone number in E.164 format"
  value       = aws_connect_phone_number.this.phone_number
}

output "contact_flow_ids" {
  description = "Map of contact flow names to their IDs"
  value       = { for k, v in aws_connect_contact_flow.this : k => v.contact_flow_id }
}

# -----------------------------------------------------------------------------
# Connect Module - Outputs
# -----------------------------------------------------------------------------

output "connect_instance_id" {
  description = "ID of the Connect instance"
  value       = aws_connect_instance.this.id
}

output "connect_instance_arn" {
  description = "ARN of the Connect instance"
  value       = aws_connect_instance.this.arn
}

output "contact_number_e164" {
  description = "Phone number in E.164 format"
  value       = aws_connect_phone_number.this.phone_number
}

output "contact_flow_ids" {
  description = "Map of contact flow names to IDs"
  value       = { for k, v in aws_connect_contact_flow.this : k => v.contact_flow_id }
}

output "instance_alias" {
  description = "Connect instance alias (used for login URL)"
  value       = aws_connect_instance.this.instance_alias
}

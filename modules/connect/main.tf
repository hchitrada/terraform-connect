# -----------------------------------------------------------------------------
# Connect Module - Amazon Connect Instance, Contact Flows, and Phone Numbers
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Amazon Connect Instance
# -----------------------------------------------------------------------------

resource "aws_connect_instance" "this" {
  identity_management_type = var.identity_management_type
  instance_alias           = var.instance_alias
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true

  tags = {
    Name        = "${local.name_prefix}-connect-instance"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Contact Flows (one per entry in contact_flow_files)
# -----------------------------------------------------------------------------

resource "aws_connect_contact_flow" "this" {
  for_each = var.contact_flow_files

  instance_id = aws_connect_instance.this.id
  name        = "${local.name_prefix}-flow-${each.key}"
  type        = "CONTACT_FLOW"
  content     = file(each.value)

  tags = {
    Name        = "${local.name_prefix}-flow-${each.key}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Phone Number (mapped to the first contact flow)
# -----------------------------------------------------------------------------

resource "aws_connect_phone_number" "this" {
  target_arn   = aws_connect_instance.this.arn
  country_code = var.phone_number_country_code
  type         = var.phone_number_type

  tags = {
    Name        = "${local.name_prefix}-phone-number"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Associate Phone Number with Contact Flow
# -----------------------------------------------------------------------------

resource "terraform_data" "phone_flow_association" {
  triggers_replace = [
    aws_connect_phone_number.this.id,
    aws_connect_contact_flow.this[keys(var.contact_flow_files)[0]].contact_flow_id
  ]

  provisioner "local-exec" {
    command = "aws connect associate-phone-number-contact-flow --phone-number-id ${aws_connect_phone_number.this.id} --instance-id ${aws_connect_instance.this.id} --contact-flow-id ${aws_connect_contact_flow.this[keys(var.contact_flow_files)[0]].contact_flow_id}"
  }
}

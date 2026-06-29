# -----------------------------------------------------------------------------
# Connect Module - Amazon Connect Instance, Flows, Phone Numbers, Admin User
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
# Contact Flows
# -----------------------------------------------------------------------------

resource "aws_connect_contact_flow" "this" {
  for_each = var.contact_flow_files

  instance_id = aws_connect_instance.this.id
  name        = "${local.name_prefix}-flow-${each.key}"
  type        = "CONTACT_FLOW"
  content     = file(each.value)

  lifecycle {
    ignore_changes = [content]
  }

  tags = {
    Name        = "${local.name_prefix}-flow-${each.key}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Phone Number
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
    command = "aws connect associate-phone-number-contact-flow --phone-number-id ${aws_connect_phone_number.this.id} --instance-id ${aws_connect_instance.this.id} --contact-flow-id ${aws_connect_contact_flow.this[keys(var.contact_flow_files)[0]].contact_flow_id} --region ${data.aws_region.current.name}"
  }
}

data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Admin User
# -----------------------------------------------------------------------------

data "aws_connect_routing_profile" "basic" {
  instance_id = aws_connect_instance.this.id
  name        = "Basic Routing Profile"
}

data "aws_connect_security_profile" "admin" {
  instance_id = aws_connect_instance.this.id
  name        = "Admin"
}

resource "aws_connect_user" "admin" {
  instance_id          = aws_connect_instance.this.id
  name                 = var.admin_username
  password             = var.admin_password
  routing_profile_id   = data.aws_connect_routing_profile.basic.routing_profile_id
  security_profile_ids = [data.aws_connect_security_profile.admin.security_profile_id]

  identity_info {
    first_name = "Admin"
    last_name  = "User"
  }

  phone_config {
    phone_type = "SOFT_PHONE"
  }

  tags = {
    Name        = "${local.name_prefix}-admin-user"
    Project     = var.project_name
    Environment = var.environment
  }
}

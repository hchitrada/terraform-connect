# -----------------------------------------------------------------------------
# CI/CD Layer - Development Environment Configuration
# -----------------------------------------------------------------------------

project_name      = "connectcc"
aws_region        = "us-east-1"
connection_arn    = "arn:aws:codestar-connections:us-east-1:264161240947:connection/072306d0-71a7-4fc8-9bd6-b448ead2a802"
repository_id     = "hchitrada/terraform-connect"
state_bucket_name = "connectcc-tfstate"
lock_table_name   = "connectcc-tfstate-lock"

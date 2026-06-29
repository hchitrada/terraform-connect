# -----------------------------------------------------------------------------
# Application Layer - Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_secretsmanager_secret_version" "connect_admin_password" {
  secret_id = "${var.project_name}/connect-admin-password"
}

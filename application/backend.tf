# -----------------------------------------------------------------------------
# Application Layer - Remote State Backend (Workspace-based)
# -----------------------------------------------------------------------------
# Workspaces automatically create separate state files:
#   env:/dev/terraform.tfstate
#   env:/prod/terraform.tfstate
# -----------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket  = "connectcc-tfstate"
    key     = "connect/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

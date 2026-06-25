# -----------------------------------------------------------------------------
# Application Layer - Remote State Backend
# -----------------------------------------------------------------------------
# Backend values are provided via -backend-config during terraform init.
# Key pattern: connect/<env>/terraform.tfstate
# Example:
#   terraform init \
#     -backend-config="bucket=<project>-tfstate" \
#     -backend-config="key=connect/dev/terraform.tfstate" \
#     -backend-config="region=us-east-1" \
#     -backend-config="dynamodb_table=<project>-tfstate-lock"
# -----------------------------------------------------------------------------

terraform {
  backend "s3" {
    # Values populated via -backend-config at init time
    # bucket         = "<project>-tfstate"
    # key            = "connect/<env>/terraform.tfstate"
    # region         = "<aws_region>"
    # dynamodb_table = "<project>-tfstate-lock"
    encrypt = true
  }
}

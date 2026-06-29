# -----------------------------------------------------------------------------
# CI/CD Layer - Remote State Backend
# -----------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "connectcc-tfstate"
    key            = "cicd/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "connectcc-tfstate-lock"
    encrypt        = true
  }
}

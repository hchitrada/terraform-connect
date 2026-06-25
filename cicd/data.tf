# -----------------------------------------------------------------------------
# CI/CD Layer - Data Sources
# -----------------------------------------------------------------------------

data "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}

data "aws_dynamodb_table" "lock" {
  name = var.lock_table_name
}

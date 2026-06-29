locals {
  state_bucket_name = "${var.project_name}-tfstate"
  lock_table_name   = "${var.project_name}-tfstate-lock"
  connection_name   = "${var.project_name}-codestar-connection"
}

# -----------------------------------------------------------------------------
# S3 State Bucket
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "state" {
  bucket = local.state_bucket_name

  tags = {
    Name    = local.state_bucket_name
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# DynamoDB Lock Table
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "lock" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = local.lock_table_name
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# CodeStar Connection
# -----------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "this" {
  name          = local.connection_name
  provider_type = var.git_provider_type

  tags = {
    Name    = local.connection_name
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Secrets Manager - Connect Admin Password
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "connect_admin_password" {
  name        = "${var.project_name}/connect-admin-password"
  description = "Admin password for Amazon Connect instances"

  tags = {
    Name    = "${var.project_name}-connect-admin-password"
    Project = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "connect_admin_password" {
  secret_id     = aws_secretsmanager_secret.connect_admin_password.id
  secret_string = var.connect_admin_password
}

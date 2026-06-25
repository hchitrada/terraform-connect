# -----------------------------------------------------------------------------
# CI/CD Layer - Pipeline Module Instantiation Per Environment
# -----------------------------------------------------------------------------

locals {
  environments = {
    dev = {
      source_branch = "develop"
      tfvars_file   = "env/dev.tfvars"
    }
    prod = {
      source_branch = "main"
      tfvars_file   = "env/prod.tfvars"
    }
  }
}

module "pipeline" {
  source   = "../modules/pipeline"
  for_each = local.environments

  project_name        = var.project_name
  environment         = each.key
  aws_region          = var.aws_region
  source_branch       = each.value.source_branch
  connection_arn      = var.connection_arn
  repository_id       = var.repository_id
  artifact_bucket_arn = data.aws_s3_bucket.state.arn
  state_bucket_arn    = data.aws_s3_bucket.state.arn
  lock_table_arn      = data.aws_dynamodb_table.lock.arn
  tfvars_file         = each.value.tfvars_file
}

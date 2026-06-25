# Pipeline Module

## Purpose

This module provisions an AWS CodePipeline with associated CodeBuild projects to automate Terraform deployments. The pipeline follows a three-stage workflow: Source (fetching code from Git), Validate (formatting and syntax checks), and Apply (deploying infrastructure). It is designed to be instantiated once per environment, with each instance triggered by a specific Git branch.

## Architecture

The module creates:

- **S3 Artifact Bucket** — stores pipeline artifacts between stages with server-side encryption (AWS KMS)
- **CloudWatch Log Group** — centralized logging for CodeBuild executions
- **CodeBuild Validate Project** — runs `terraform fmt -check` and `terraform validate` using `buildspecs/validate.yml`
- **CodeBuild Apply Project** — runs `terraform init`, `plan`, and `apply` using `buildspecs/apply.yml`
- **CodePipeline** — orchestrates the three stages with automatic trigger on branch push
- **IAM Roles** — least-privilege roles via the IAM module for both CodePipeline and CodeBuild

### Pipeline Stages

1. **Source** — Uses CodeStar Connection to detect changes on the configured branch and fetch source code
2. **Validate** — Runs formatting and validation checks; if this stage fails, the pipeline halts and does not proceed to Apply
3. **Apply** — Runs Terraform init, plan, and apply against the target environment

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `project_name` | `string` | Project name used as a prefix for resource naming |
| `environment` | `string` | Environment name (e.g., dev, prod) used in resource naming and scoping |
| `aws_region` | `string` | Target AWS region for the pipeline and CodeBuild projects |
| `source_branch` | `string` | Git branch that triggers this pipeline (e.g., develop, main) |
| `connection_arn` | `string` | ARN of the CodeStar Connection for source repository access |
| `repository_id` | `string` | Full repository identifier in owner/repo format |
| `artifact_bucket_arn` | `string` | ARN of the S3 artifact bucket used by CodePipeline |
| `state_bucket_arn` | `string` | ARN of the S3 state backend bucket for Terraform state |
| `lock_table_arn` | `string` | ARN of the DynamoDB lock table for Terraform state locking |
| `tfvars_file` | `string` | Path to the environment-specific tfvars file (e.g., env/dev.tfvars) |

## Outputs

| Name | Description |
|------|-------------|
| `pipeline_arn` | ARN of the CodePipeline resource |
| `pipeline_name` | Name of the CodePipeline resource |
| `codebuild_validate_name` | Name of the CodeBuild project used for the Validate stage |
| `codebuild_apply_name` | Name of the CodeBuild project used for the Apply stage |

## Usage

```hcl
module "pipeline_dev" {
  source = "../modules/pipeline"

  project_name        = "connectcc"
  environment         = "dev"
  aws_region          = "us-east-1"
  source_branch       = "develop"
  connection_arn      = data.aws_codestarconnections_connection.this.arn
  repository_id       = "my-org/terraform-connect"
  artifact_bucket_arn = aws_s3_bucket.artifacts.arn
  state_bucket_arn    = data.aws_s3_bucket.state.arn
  lock_table_arn      = data.aws_dynamodb_table.lock.arn
  tfvars_file         = "env/dev.tfvars"
}
```

## Requirements

This module satisfies:

- **Requirement 2.1**: CodePipeline with source stage connected to Git repository
- **Requirement 2.2**: CodeBuild projects to execute Terraform plan and apply
- **Requirement 2.3**: S3 artifact bucket with server-side encryption
- **Requirement 2.5**: Buildspec executing Terraform init, plan, and apply
- **Requirement 2.6**: Validation stage with format check and validate before apply
- **Requirement 2.8**: Environment variables passing target environment and region
- **Requirement 2.9**: Pipeline halts on validation failure
- **Requirement 5.1**: Pipeline triggers on commits to designated branch
- **Requirement 5.2**: Source stage detects changes from Git repository
- **Requirement 5.5**: Branch-to-environment mapping through source configuration
- **Requirement 1.5**: Consistent naming convention `<project>-<environment>-<resource_type>-<identifier>`
- **Requirement 1.7**: Reusable module with inputs, outputs, and documentation

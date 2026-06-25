# IAM Module

## Purpose

This module provisions least-privilege IAM roles and policies for AWS CodePipeline and CodeBuild. The policies are scoped to specific resource ARNs rather than using wildcards, ensuring each service has only the permissions it needs to operate.

### CodePipeline Role Permissions

- **S3 artifact bucket**: `GetObject`, `PutObject`, `GetBucketVersioning` — scoped to the artifact bucket ARN
- **CodeStar Connection**: `UseConnection` — scoped to the specific connection ARN
- **CodeBuild**: `StartBuild`, `BatchGetBuilds` — to trigger and monitor build projects

### CodeBuild Role Permissions

- **S3 artifact bucket**: `GetObject`, `PutObject` — scoped to the artifact bucket ARN
- **CloudWatch Logs**: `CreateLogStream`, `PutLogEvents` — scoped to the specific log group ARN
- **S3 state backend**: `GetObject`, `PutObject`, `ListBucket` — scoped to the state bucket and environment-specific key prefix
- **DynamoDB lock table**: `GetItem`, `PutItem`, `DeleteItem` — scoped to the lock table ARN
- **Amazon Connect**: Full Connect API access scoped to environment-specific instance resources, plus limited account-level actions required for instance provisioning

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `project_name` | `string` | Project name used as a prefix for resource naming |
| `environment` | `string` | Environment name (e.g., dev, prod) used in resource naming and scoping |
| `artifact_bucket_arn` | `string` | ARN of the S3 artifact bucket used by CodePipeline |
| `state_bucket_arn` | `string` | ARN of the S3 state backend bucket for Terraform state |
| `lock_table_arn` | `string` | ARN of the DynamoDB lock table for Terraform state locking |
| `connection_arn` | `string` | ARN of the CodeStar Connection for source repository access |
| `log_group_arn` | `string` | ARN of the CloudWatch Logs log group for CodeBuild |

## Outputs

| Name | Description |
|------|-------------|
| `codepipeline_role_arn` | ARN of the IAM role assumed by CodePipeline |
| `codebuild_role_arn` | ARN of the IAM role assumed by CodeBuild projects |

## Usage

```hcl
module "iam" {
  source = "../modules/iam"

  project_name        = "connectcc"
  environment         = "dev"
  artifact_bucket_arn = aws_s3_bucket.artifacts.arn
  state_bucket_arn    = data.aws_s3_bucket.state.arn
  lock_table_arn      = data.aws_dynamodb_table.lock.arn
  connection_arn      = data.aws_codestarconnections_connection.this.arn
  log_group_arn       = aws_cloudwatch_log_group.codebuild.arn
}
```

## Requirements

This module satisfies:

- **Requirement 2.4**: IAM roles and policies scoped to only specific resources they operate on
- **Requirement 1.5**: Consistent naming convention following `<project>-<environment>-<resource_type>-<identifier>` pattern
- **Requirement 1.7**: Reusable module with inputs, outputs, and documentation

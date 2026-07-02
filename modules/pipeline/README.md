## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.52.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_iam"></a> [iam](#module\_iam) | ../iam | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.build_website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.build_website_dev](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.deploy_dev](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.deploy_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.validate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_sns_topic.approval](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.approval_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_approval_email"></a> [approval\_email](#input\_approval\_email) | Email address for manual approval notifications | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for deployments | `string` | n/a | yes |
| <a name="input_cloudfront_domain"></a> [cloudfront\_domain](#input\_cloudfront\_domain) | CloudFront domain name for the approval link | `string` | n/a | yes |
| <a name="input_connection_arn"></a> [connection\_arn](#input\_connection\_arn) | ARN of the CodeStar Connection | `string` | n/a | yes |
| <a name="input_lock_table_arn"></a> [lock\_table\_arn](#input\_lock\_table\_arn) | ARN of the DynamoDB lock table (for IAM scoping) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used as a prefix for resource naming | `string` | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | Full repository identifier (owner/repo) | `string` | n/a | yes |
| <a name="input_source_branch"></a> [source\_branch](#input\_source\_branch) | Git branch that triggers this pipeline | `string` | n/a | yes |
| <a name="input_state_bucket_arn"></a> [state\_bucket\_arn](#input\_state\_bucket\_arn) | ARN of the S3 state bucket (for IAM scoping) | `string` | n/a | yes |
| <a name="input_website_bucket"></a> [website\_bucket](#input\_website\_bucket) | S3 bucket name for website deployment | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pipeline_arn"></a> [pipeline\_arn](#output\_pipeline\_arn) | ARN of the CodePipeline |
| <a name="output_pipeline_name"></a> [pipeline\_name](#output\_pipeline\_name) | Name of the CodePipeline |

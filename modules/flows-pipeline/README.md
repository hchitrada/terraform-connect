## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_codebuild_project.deploy_flow_dev](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.deploy_flow_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.flows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_approval_sns_topic_arn"></a> [approval\_sns\_topic\_arn](#input\_approval\_sns\_topic\_arn) | SNS topic ARN for approval notifications | `string` | n/a | yes |
| <a name="input_artifact_bucket"></a> [artifact\_bucket](#input\_artifact\_bucket) | S3 bucket for pipeline artifacts | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_cloudfront_domain"></a> [cloudfront\_domain](#input\_cloudfront\_domain) | CloudFront domain for approval link | `string` | n/a | yes |
| <a name="input_codebuild_role_arn"></a> [codebuild\_role\_arn](#input\_codebuild\_role\_arn) | CodeBuild IAM role ARN | `string` | n/a | yes |
| <a name="input_codepipeline_role_arn"></a> [codepipeline\_role\_arn](#input\_codepipeline\_role\_arn) | CodePipeline IAM role ARN | `string` | n/a | yes |
| <a name="input_connection_arn"></a> [connection\_arn](#input\_connection\_arn) | CodeStar Connection ARN | `string` | n/a | yes |
| <a name="input_dev_contact_flow_id"></a> [dev\_contact\_flow\_id](#input\_dev\_contact\_flow\_id) | Contact flow ID for dev | `string` | n/a | yes |
| <a name="input_dev_instance_id"></a> [dev\_instance\_id](#input\_dev\_instance\_id) | Connect instance ID for dev | `string` | n/a | yes |
| <a name="input_flows_repository_id"></a> [flows\_repository\_id](#input\_flows\_repository\_id) | GitHub repository for flows (owner/repo) | `string` | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | CloudWatch log group name | `string` | n/a | yes |
| <a name="input_prod_contact_flow_id"></a> [prod\_contact\_flow\_id](#input\_prod\_contact\_flow\_id) | Contact flow ID for prod | `string` | n/a | yes |
| <a name="input_prod_instance_id"></a> [prod\_instance\_id](#input\_prod\_instance\_id) | Connect instance ID for prod | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name prefix | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pipeline_arn"></a> [pipeline\_arn](#output\_pipeline\_arn) | ARN of the flows pipeline |
| <a name="output_pipeline_name"></a> [pipeline\_name](#output\_pipeline\_name) | Name of the flows pipeline |

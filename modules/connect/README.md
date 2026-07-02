## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.52.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_connect_contact_flow.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_contact_flow) | resource |
| [aws_connect_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance) | resource |
| [aws_connect_phone_number.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_phone_number) | resource |
| [aws_connect_user.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_user) | resource |
| [terraform_data.phone_flow_association](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_connect_routing_profile.basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/connect_routing_profile) | data source |
| [aws_connect_security_profile.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/connect_security_profile) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password for the Connect admin user | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Username for the Connect admin user | `string` | `"admin"` | no |
| <a name="input_contact_flow_files"></a> [contact\_flow\_files](#input\_contact\_flow\_files) | Map of contact flow name to JSON file path | `map(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, prod) | `string` | n/a | yes |
| <a name="input_identity_management_type"></a> [identity\_management\_type](#input\_identity\_management\_type) | Identity management type for the Connect instance | `string` | `"CONNECT_MANAGED"` | no |
| <a name="input_instance_alias"></a> [instance\_alias](#input\_instance\_alias) | Alias for the Amazon Connect instance (must be globally unique) | `string` | n/a | yes |
| <a name="input_phone_number_country_code"></a> [phone\_number\_country\_code](#input\_phone\_number\_country\_code) | ISO country code for the phone number (e.g., US) | `string` | n/a | yes |
| <a name="input_phone_number_type"></a> [phone\_number\_type](#input\_phone\_number\_type) | Type of phone number to claim (DID or TOLL\_FREE) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used as a prefix for resource naming | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_connect_instance_arn"></a> [connect\_instance\_arn](#output\_connect\_instance\_arn) | ARN of the Connect instance |
| <a name="output_connect_instance_id"></a> [connect\_instance\_id](#output\_connect\_instance\_id) | ID of the Connect instance |
| <a name="output_contact_flow_ids"></a> [contact\_flow\_ids](#output\_contact\_flow\_ids) | Map of contact flow names to IDs |
| <a name="output_contact_number_e164"></a> [contact\_number\_e164](#output\_contact\_number\_e164) | Phone number in E.164 format |
| <a name="output_instance_alias"></a> [instance\_alias](#output\_instance\_alias) | Connect instance alias (used for login URL) |

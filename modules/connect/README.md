# Connect Module

## Purpose

This module provisions an Amazon Connect contact center instance with contact flows and a phone number. It creates a fully functional Connect instance where contact flows define the call handling logic, and a claimed phone number is mapped to the instance for inbound routing.

### Resources Provisioned

- **Amazon Connect Instance** — configured with the specified identity management type and instance alias
- **Contact Flows** — one per entry in `contact_flow_files`, each loaded from a JSON file in the repository
- **Phone Number** — claimed from the specified country and type, mapped to the Connect instance

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_name` | `string` | — | Project name used as a prefix for resource naming |
| `environment` | `string` | — | Environment name (e.g., dev, prod) used in resource naming |
| `identity_management_type` | `string` | `CONNECT_MANAGED` | Identity management type for the Connect instance |
| `instance_alias` | `string` | — | Alias for the Amazon Connect instance (must be globally unique) |
| `phone_number_type` | `string` | — | Type of phone number to claim (DID or TOLL_FREE) |
| `phone_number_country_code` | `string` | — | ISO country code for the phone number (e.g., US, GB) |
| `contact_flow_files` | `map(string)` | — | Map of contact flow name to JSON file path containing the flow definition |

## Outputs

| Name | Description |
|------|-------------|
| `connect_instance_id` | ID of the Amazon Connect instance |
| `contact_number_e164` | Claimed phone number in E.164 format |
| `contact_flow_ids` | Map of contact flow names to their IDs |

## Usage

```hcl
module "connect" {
  source = "../modules/connect"

  project_name              = "connectcc"
  environment               = "dev"
  identity_management_type  = "CONNECT_MANAGED"
  instance_alias            = "connectcc-dev"
  phone_number_type         = "DID"
  phone_number_country_code = "US"
  contact_flow_files = {
    "inbound-greeting" = "${path.module}/flows/inbound-greeting.json"
  }
}
```

## Requirements

This module satisfies:

- **Requirement 3.1**: Connect instance with configurable identity management type defaulting to CONNECT_MANAGED
- **Requirement 3.2**: Contact flow within the instance defining call handling logic
- **Requirement 3.3**: Phone number associated with the instance, specifying type and country code as configurable inputs
- **Requirement 3.5**: Phone number output in E.164 format
- **Requirement 3.6**: Contact flow definitions managed as Terraform resources with content stored in the repository
- **Requirement 1.5**: Consistent naming convention following `<project>-<environment>-<resource_type>-<identifier>` pattern
- **Requirement 1.7**: Reusable module with inputs, outputs, and documentation

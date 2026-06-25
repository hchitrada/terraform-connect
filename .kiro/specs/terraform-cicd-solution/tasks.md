# Implementation Plan: Terraform CI/CD Solution

## Overview

This plan implements a Terraform-based CI/CD solution that provisions AWS CodePipeline and CodeBuild resources to automate the deployment of an Amazon Connect contact center across two isolated environments (Development and Production). The implementation follows a layered approach: bootstrap, CI/CD, and application layers, each with separate state management.

## Tasks

- [x] 1. Set up project structure and bootstrap layer
  - [x] 1.1 Create repository directory structure and root README
    - Create all top-level directories: `bootstrap/`, `cicd/`, `application/`, `modules/pipeline/`, `modules/connect/`, `modules/iam/`, `buildspecs/`, `docs/`, and `application/flows/`
    - Create root `README.md` with project summary, architecture overview, prerequisites, quick-start instructions, and links to detailed documentation
    - _Requirements: 1.6, 7.5_

  - [x] 1.2 Implement bootstrap module (S3 state bucket, DynamoDB lock table, CodeStar Connection)
    - Create `bootstrap/providers.tf` with AWS provider using pessimistic version constraint (`~> 5.0`) and region as input variable
    - Create `bootstrap/variables.tf` defining `project_name`, `aws_region`, and `git_provider_type` with descriptions and type constraints
    - Create `bootstrap/main.tf` provisioning: S3 state bucket (versioning enabled, SSE enabled, public access blocked), DynamoDB lock table (`LockID` String hash key, on-demand billing), and CodeStar Connection
    - Create `bootstrap/outputs.tf` exposing state bucket name, lock table name, and connection ARN with description strings
    - All resource names follow `<project>-<environment>-<resource_type>-<identifier>` pattern using a `locals` block
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 2. Checkpoint - Validate bootstrap layer
  - Ensure `terraform validate` and `terraform fmt -check` pass for the bootstrap module. Ask the user if questions arise.

- [x] 3. Implement reusable IAM module
  - [x] 3.1 Create IAM module for least-privilege CodePipeline and CodeBuild roles
    - Create `modules/iam/variables.tf` with inputs: `project_name`, `environment`, `artifact_bucket_arn`, `state_bucket_arn`, `lock_table_arn`, `connection_arn`, `log_group_arn`
    - Create `modules/iam/main.tf` provisioning IAM roles and policies for CodePipeline and CodeBuild scoped to specific resource ARNs (artifact bucket, CloudWatch Logs, state backend, CodeStar Connection, Connect API surface)
    - Create `modules/iam/outputs.tf` exposing `codepipeline_role_arn` and `codebuild_role_arn`
    - Create `modules/iam/README.md` documenting module purpose, inputs, outputs, and usage
    - _Requirements: 2.4, 1.5, 1.7_

- [x] 4. Implement reusable pipeline module
  - [x] 4.1 Create pipeline module for CodePipeline and CodeBuild resources
    - Create `modules/pipeline/variables.tf` with inputs: `project_name`, `environment`, `aws_region`, `source_branch`, `connection_arn`, `repository_id`, `artifact_bucket_arn`, `state_bucket_arn`, `lock_table_arn`, `tfvars_file`
    - Create `modules/pipeline/main.tf` provisioning: `aws_codepipeline` with Source, Validate, and Apply stages; two `aws_codebuild_project` resources (validate + apply); S3 artifact bucket with SSE; IAM module reference
    - Configure Source stage with `CodeStarSourceConnection` action, `BranchName = source_branch`, `DetectChanges = true`
    - Configure Validate stage running `buildspecs/validate.yml`; on failure pipeline halts
    - Configure Apply stage running `buildspecs/apply.yml` with environment variables `TF_ENV` and `AWS_REGION`
    - Create `modules/pipeline/outputs.tf` exposing `pipeline_arn`, `pipeline_name`, `codebuild_validate_name`, `codebuild_apply_name`
    - Create `modules/pipeline/README.md` documenting module purpose, inputs, outputs, and usage
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6, 2.8, 2.9, 5.1, 5.2, 5.5, 1.5, 1.7_

- [x] 5. Implement reusable Connect module
  - [x] 5.1 Create Connect module for Amazon Connect instance, flows, and phone numbers
    - Create `modules/connect/variables.tf` with inputs: `project_name`, `environment`, `identity_management_type` (default `CONNECT_MANAGED`), `instance_alias`, `phone_number_type`, `phone_number_country_code`, `contact_flow_files`
    - Create `modules/connect/main.tf` provisioning: `aws_connect_instance`, `aws_connect_contact_flow` (one per flow file using `for_each` over `contact_flow_files`), `aws_connect_phone_number` mapped to the contact flow
    - Create `modules/connect/outputs.tf` exposing `connect_instance_id`, `contact_number_e164`, `contact_flow_ids`
    - Create `modules/connect/README.md` documenting module purpose, inputs, outputs, and usage
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 3.6, 1.5, 1.7_

- [x] 6. Checkpoint - Validate modules
  - Ensure `terraform validate` and `terraform fmt -check` pass for all modules. Ask the user if questions arise.

- [x] 7. Implement CI/CD root module
  - [x] 7.1 Create CI/CD layer root configuration
    - Create `cicd/providers.tf` with AWS provider using pessimistic version constraint and region variable
    - Create `cicd/backend.tf` with S3 backend configuration (bucket, key `cicd/<env>/terraform.tfstate`, DynamoDB lock table)
    - Create `cicd/variables.tf` defining all CI/CD-specific variables with descriptions and type constraints
    - Create `cicd/data.tf` for any data sources needed
    - Create `cicd/main.tf` instantiating the pipeline module once per environment (dev pipeline triggered by `develop` branch, prod pipeline triggered by `main` branch)
    - Create `cicd/outputs.tf` exposing pipeline ARNs per environment
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 4.7, 5.3, 5.4, 5.5_

  - [x] 7.2 Create CI/CD environment-specific tfvars files
    - Create `cicd/env/dev.tfvars` with development environment configuration (environment name, source branch `develop`, region, project name)
    - Create `cicd/env/prod.tfvars` with production environment configuration (environment name, source branch `main`, region, project name)
    - _Requirements: 4.3, 4.6_

- [x] 8. Implement application root module
  - [x] 8.1 Create application layer root configuration
    - Create `application/providers.tf` with AWS provider using pessimistic version constraint and region variable
    - Create `application/backend.tf` with S3 backend configuration (bucket, key `connect/<env>/terraform.tfstate`, DynamoDB lock table)
    - Create `application/variables.tf` defining all application-specific variables with descriptions and type constraints
    - Create `application/data.tf` for any data sources needed
    - Create `application/main.tf` instantiating the Connect module
    - Create `application/outputs.tf` exposing `connect_instance_id`, `contact_number` (E.164), and relevant IDs
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 3.4, 3.5_

  - [x] 8.2 Create application environment-specific tfvars files
    - Create `application/env/dev.tfvars` with development configuration (environment, project_name, region, identity_management_type, instance_alias, phone_number_type, phone_number_country_code, contact_flow_files)
    - Create `application/env/prod.tfvars` with production configuration
    - _Requirements: 4.3, 4.5, 4.6_

  - [x] 8.3 Create contact flow JSON definitions
    - Create `application/flows/inbound-greeting.json` with a sample contact flow that plays a greeting message and disconnects (valid Amazon Connect flow-language JSON with `Version`, `StartAction`, and reachable `Actions`)
    - _Requirements: 3.2, 3.6, 3.7_

- [x] 9. Implement buildspec files
  - [x] 9.1 Create validate and apply buildspec YAML files
    - Create `buildspecs/validate.yml` running `terraform fmt -check -recursive` and `terraform validate` in the application directory
    - Create `buildspecs/apply.yml` running `terraform init` (with backend-config for environment key), `terraform plan -var-file`, and `terraform apply` with explicit failure reporting (echo failing command + exit non-zero)
    - Configure environment variables `TF_ENV` and `AWS_REGION` in apply buildspec
    - _Requirements: 2.5, 2.6, 2.7, 2.8, 2.9_

- [x] 10. Checkpoint - Full static validation
  - Ensure `terraform validate` and `terraform fmt -check` pass for all root modules (`bootstrap`, `cicd`, `application`). Ask the user if questions arise.

- [ ] 11. Create documentation set
  - [ ] 11.1 Write architecture and code structure documentation
    - Create `docs/architecture.md` with solution architecture overview including Mermaid diagram depicting CodePipeline, CodeBuild, Connect Instance, Contact Flow, Contact Number, their relationships, and data flow
    - Create `docs/code-structure.md` explaining Terraform code structure, design decisions for module boundaries, file organization, and separation of CI/CD and application resources
    - _Requirements: 6.1, 6.2_

  - [ ] 11.2 Write environment strategy and CI/CD workflow documentation
    - Create `docs/environment-strategy.md` explaining environment separation strategy (state backend isolation, distinct S3 keys, configuration differentiation per environment)
    - Create `docs/cicd-workflow.md` describing CI/CD workflow design (CodePipeline stages, source triggers, CodeBuild buildspec logic, deployment sequence)
    - _Requirements: 6.3, 6.4_

  - [ ] 11.3 Write deployment guide
    - Create `docs/deployment-guide.md` listing all prerequisites (AWS accounts, IAM permissions, CLI tools, access credentials) followed by numbered steps: repository setup, bootstrap initialization, CodeStar Connection handshake, CI/CD layer deployment, and pipeline execution for each environment
    - _Requirements: 6.5_

  - [ ] 11.4 Write troubleshooting and FAQ documentation
    - Create `docs/troubleshooting.md` covering at least five common issues: state lock conflicts, CodeBuild permission errors, Connect resource limits, pipeline failures, contact flow validation errors (each with symptom, cause, resolution)
    - Create `docs/faq.md` addressing at least five questions on solution operation, maintenance, and environment management
    - _Requirements: 6.6, 6.7_

  - [ ] 11.5 Add known limitations, assumptions, and future improvements
    - Add to documentation: at least three known limitations, three assumptions, and three potential future improvements
    - _Requirements: 7.4_

- [ ] 12. Implement Terraform test configurations
  - [ ] 12.1 Create plan-based assertion tests using Terraform test framework
    - Create `.tftest.hcl` files for key plan assertions: artifact bucket has SSE, pipeline has correct stages in order, IAM policies have no wildcard `Resource = "*"` for scoped statements, Connect instance defaults to `CONNECT_MANAGED`, phone number references a contact flow, resource names match naming pattern, backend keys are distinct per environment
    - _Requirements: 1.5, 1.9, 2.3, 2.4, 2.6, 3.1, 3.3, 4.2_

  - [ ] 12.2 Create contact flow JSON schema validation script
    - Create a validation script that checks each flow JSON for well-formed structure, required `Version` field, `StartAction` field, and reachable `Actions`
    - _Requirements: 3.2, 3.6_

- [ ] 13. Final checkpoint - Complete validation
  - Ensure all `terraform validate`, `terraform fmt -check`, and Terraform test assertions pass across the entire solution. Ask the user if questions arise.

## Notes

- This is an Infrastructure-as-Code project; all tasks produce Terraform HCL, YAML buildspecs, JSON flow definitions, or Markdown documentation
- No property-based tests are included because the design explicitly omits correctness properties (IaC with no pure functions to exercise)
- The bootstrap layer must be applied manually once per account before the CI/CD layer can be deployed
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation of Terraform configurations
- Testing relies on static validation (`fmt`, `validate`), plan-based assertions (`.tftest.hcl`), and schema validation rather than property-based tests

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2"] },
    { "id": 2, "tasks": ["3.1", "5.1"] },
    { "id": 3, "tasks": ["4.1"] },
    { "id": 4, "tasks": ["7.1", "8.1", "8.3", "9.1"] },
    { "id": 5, "tasks": ["7.2", "8.2"] },
    { "id": 6, "tasks": ["11.1", "11.2", "11.3", "11.4", "11.5"] },
    { "id": 7, "tasks": ["12.1", "12.2"] }
  ]
}
```

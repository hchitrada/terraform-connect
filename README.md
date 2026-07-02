# Terraform CI/CD Solution for Amazon Connect

An end-to-end infrastructure-as-code solution that uses Terraform to provision AWS CodePipeline and CodeBuild, automating the deployment of an Amazon Connect contact center across two environments (Development and Production).

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          connectcc-pipeline                                  │
│                                                                             │
│  Source ─→ Validate ─→ Build-Dev ─→ Deploy-Website-Dev ─→ Approval         │
│  (main)    (fmt+val)   (tf apply)   (HTML + dev number)   (email)           │
│                                                              │              │
│                                         ┌────────────────────┘              │
│                                         ▼                                   │
│                                    Build-Prod ─→ Deploy-Website              │
│                                    (tf apply)    (HTML + both numbers)       │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐     ┌──────────────────┐     ┌──────────────────────┐
│  Dev Environment │     │ Prod Environment │     │   Website (S3+CF)    │
├──────────────────┤     ├──────────────────┤     ├──────────────────────┤
│ Connect Instance │     │ Connect Instance │     │ CloudFront CDN       │
│ Contact Flow     │     │ Contact Flow     │     │ Private S3 Bucket    │
│ Phone Number     │     │ Phone Number     │     │ Support page HTML    │
│ Admin User       │     │ Admin User       │     │ (shows both numbers) │
└──────────────────┘     └──────────────────┘     └──────────────────────┘
```

## How It Works

1. **You push code** to the `main` branch of this repository
2. **CodePipeline triggers** automatically via CodeStar Connection
3. **Validate stage** runs `terraform fmt -check` and `terraform validate`
4. **Build-Dev stage** runs `terraform apply` using the `dev` workspace — creates/updates the Connect instance, flow, phone number, and admin user for development
5. **Deploy-Website-Dev** generates an HTML page showing the dev phone number and uploads it to S3 (served via CloudFront)
6. **Approval stage** sends you an email with a link to the website — you dial the dev number to test, then approve
7. **Build-Prod stage** runs `terraform apply` using the `prod` workspace — same resources for production
8. **Deploy-Website** regenerates the HTML with both phone numbers

## Repository Structure

```
├── bootstrap/              # One-time setup: S3, DynamoDB, CodeStar, Secrets Manager
├── cicd/                   # Pipeline infrastructure: CodePipeline, CodeBuild, CloudFront, S3
├── application/            # Connect resources: instance, flows, phone numbers, admin user
│   ├── env/
│   │   ├── dev.tfvars      # Dev environment config
│   │   └── prod.tfvars     # Prod environment config
│   └── flows/
│       └── inbound-greeting.json  # Initial flow definition
├── modules/
│   ├── connect/            # Reusable Connect module
│   ├── pipeline/           # Reusable pipeline module
│   ├── iam/                # Least-privilege IAM roles
│   └── flows-pipeline/     # Flows-only deployment pipeline (for connect-flows repo)
├── buildspecs/
│   ├── validate.yml        # terraform fmt + validate
│   ├── apply.yml           # terraform init + workspace + plan + apply
│   ├── website-dev.yml     # Generate HTML with dev number, upload to S3
│   └── website.yml         # Generate HTML with both numbers, upload to S3
└── website/
    └── index.html          # HTML template for the support page
```

## Prerequisites

- AWS account with admin access
- Terraform >= 1.0 installed locally
- AWS CLI configured
- GitHub account with a repository for this code
- Git installed

## Deployment Guide

### Step 1: Bootstrap (one-time)

Creates the S3 state bucket, DynamoDB lock table, CodeStar Connection, and stores the Connect admin password in Secrets Manager.

```bash
cd bootstrap

# Create terraform.tfvars with your values:
cat > terraform.tfvars << 'EOF'
project_name           = "connectcc"
aws_region             = "us-east-1"
git_provider_type      = "GitHub"
connect_admin_password = "YourSecurePassword1!"
EOF

terraform init
terraform apply
```

Note the `connection_arn` output — you'll need it next.

### Step 2: Complete CodeStar Connection Handshake

1. Go to AWS Console → Developer Tools → Settings → Connections
2. Click on `connectcc-codestar-connection` (status: Pending)
3. Click **Update pending connection**
4. Authorize AWS to access your GitHub account
5. Install the connector on your repository

### Step 3: Deploy CI/CD Layer

Creates the pipeline, CodeBuild projects, CloudFront distribution, and website bucket.

```bash
cd cicd

# Update cicd/env/dev.tfvars with the connection_arn from Step 1
# Then:
terraform init
terraform apply -var-file="env/dev.tfvars"
```

Note the `website_url` output — this is your support page URL.

### Step 4: Push Code to GitHub

```bash
git add -A
git commit -m "Deploy infrastructure"
git push origin main
```

The pipeline triggers automatically and deploys:
- Dev Connect instance + flow + phone number + admin user
- HTML support page with the dev phone number

### Step 5: Approve Production Deployment

1. Check your email for the approval notification (or go to CodePipeline in the console)
2. Click the CloudFront URL to see the dev phone number
3. Dial the number to verify the flow works
4. Approve the pipeline to deploy production

## Updating Contact Flows

Contact flows use `ignore_changes = [content]` in Terraform, so flow updates are decoupled from infrastructure changes.

**Option A: AWS CLI (immediate)**
```bash
aws connect update-contact-flow-content \
  --instance-id <instance-id> \
  --contact-flow-id <flow-id> \
  --content file://application/flows/inbound-greeting.json \
  --region us-east-1
```

**Option B: Flows Pipeline (automated)**

A separate `connect-flows` repo exists at `hchitrada/connect-flows`. Once the flows pipeline is wired up, pushing flow JSON changes to that repo auto-deploys to dev, waits for approval, then deploys to prod.

## Connect Login

After deployment:
- **URL:** `https://<instance-alias>.my.connect.aws`
- **Username:** `admin`
- **Password:** stored in Secrets Manager at `connectcc/connect-admin-password`

## Environment Isolation

- Uses **Terraform workspaces** (`dev` and `prod`)
- Each workspace has its own state file in S3: `env:/dev/connect/terraform.tfstate`
- Separate Connect instances, phone numbers, and flows per environment
- Single pipeline with approval gate between environments

## Teardown

Destroy in reverse order:

```bash
# 1. Destroy application (both workspaces)
cd application
terraform init
terraform workspace select dev
terraform destroy -var-file="env/dev.tfvars"
terraform workspace select prod
terraform destroy -var-file="env/prod.tfvars"

# 2. Destroy CI/CD
cd ../cicd
terraform destroy -var-file="env/dev.tfvars"

# 3. Empty and destroy bootstrap
aws s3 rm s3://connectcc-tfstate --recursive
cd ../bootstrap
terraform destroy
```

## Key Technologies

- **Terraform** — Infrastructure as Code
- **AWS CodePipeline** — CI/CD orchestration
- **AWS CodeBuild** — Build/deploy execution
- **Amazon Connect** — Cloud contact center
- **AWS CloudFront** — CDN for the support page
- **AWS S3** — State storage, artifacts, website hosting
- **AWS DynamoDB** — Terraform state locking
- **AWS Secrets Manager** — Credential storage
- **AWS SNS** — Approval notifications
- **Terraform Workspaces** — Environment isolation

## Terraform Best Practices

This project follows the [AWS I&A Terraform Standards](https://aws-ia.github.io/standards-terraform/):

| Practice | Status |
|----------|--------|
| Standard file naming (`main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`) | ✅ |
| Provider blocks only in root modules | ✅ |
| All variables have `type` and `description` | ✅ |
| Variable validation blocks | ✅ |
| `for_each` preferred over `count` | ✅ |
| Attachment resources over embedded | ✅ |
| `default_tags` in provider blocks | ✅ |
| `name_prefix` for IAM roles | ✅ |
| Module READMEs auto-generated via `terraform-docs` | ✅ |
| Pre-commit hooks (fmt, validate, tflint, tfsec, terraform-docs) | ✅ |
| Contextual resource meta names | ✅ |

### Future Improvements

| Practice | Status |
|----------|--------|
| `examples/` directory with working deployment examples | 🔲 TODO |
| Automated tests (Terratest or `terraform test`) | 🔲 TODO |
| Semantic versioning with Git tags | 🔲 TODO |

## Pre-commit Hooks Setup

Pre-commit hooks run `terraform fmt`, `validate`, `tflint`, `tfsec`, and `terraform-docs` automatically before each commit.

### Installation

```bash
# Install pre-commit
brew install pre-commit

# Install terraform-docs
brew install terraform-docs

# Install tflint
brew install tflint

# Install tfsec
brew install tfsec

# Install the hooks in this repo
pre-commit install
```

### Usage

After installation, hooks run automatically on `git commit`. To run manually:

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run a specific hook
pre-commit run terraform_fmt --all-files
pre-commit run terraform_tfsec --all-files
```

### What Each Hook Does

| Hook | Purpose |
|------|---------|
| `terraform_fmt` | Formats all `.tf` files consistently |
| `terraform_validate` | Checks for syntax and configuration errors |
| `terraform_tflint` | Lints for AWS best practices and deprecated features |
| `terraform_tfsec` | Scans for security misconfigurations (unencrypted resources, overly permissive IAM) |
| `terraform_docs` | Auto-generates module READMEs from variables and outputs |
